#include "CavaService.h"

#include <QDebug>
#include <QRandomGenerator>
#include <QThread>
#include <QtMath>

#ifdef Q_OS_WIN
#  include <audioclient.h>
#  include <mmdeviceapi.h>
#endif

#include <algorithm>
#include <cmath>

namespace {

// Local GUIDs (MinGW-safe). CLSID_MMDeviceEnumerator is
// {BCDE0395-E52F-467C-8E3D-C4579291692E} — note 467C-8E3D, not 4670-8D3D.
#ifdef Q_OS_WIN
const CLSID k_CLSID_MMDeviceEnumerator = {0xbcde0395, 0xe52f, 0x467c, {0x8e, 0x3d, 0xc4, 0x57, 0x92, 0x91, 0x69, 0x2e}};
const IID k_IID_IMMDeviceEnumerator    = {0xa95664d2, 0x9614, 0x4f35, {0xa7, 0x46, 0xde, 0x8d, 0xb6, 0x36, 0x17, 0xe6}};
const IID k_IID_IAudioClient           = {0x1cb9ad4c, 0xdbfa, 0x4c32, {0xb1, 0x78, 0xc2, 0xf5, 0x68, 0xa7, 0x03, 0xb2}};
const IID k_IID_IAudioCaptureClient    = {0xc8adbd64, 0xe71e, 0x48a0, {0xa4, 0xde, 0x18, 0x5c, 0x39, 0x5c, 0xd3, 0x17}};
#endif

// In-place iterative radix-2 FFT (n must be a power of two).
template <typename T>
void fftInPlace(std::vector<T> &re, std::vector<T> &im)
{
    const size_t n = re.size();

    for (size_t i = 1, j = 0; i < n; ++i) {
        size_t bit = n >> 1;
        for (; j & bit; bit >>= 1)
            j ^= bit;
        j ^= bit;
        if (i < j) {
            std::swap(re[i], re[j]);
            std::swap(im[i], im[j]);
        }
    }

    for (size_t len = 2; len <= n; len <<= 1) {
        const double ang = -2.0 * M_PI / static_cast<double>(len);
        const double wr = std::cos(ang);
        const double wi = std::sin(ang);
        for (size_t i = 0; i < n; i += len) {
            double curWr = 1.0;
            double curWi = 0.0;
            for (size_t k = 0; k < len / 2; ++k) {
                const size_t a = i + k;
                const size_t b = a + len / 2;
                const double ur = re[a];
                const double ui = im[a];
                const double vr = re[b] * curWr - im[b] * curWi;
                const double vi = re[b] * curWi + im[b] * curWr;
                re[a] = ur + vr;
                im[a] = ui + vi;
                re[b] = ur - vr;
                im[b] = ui - vi;
                const double nextWr = curWr * wr - curWi * wi;
                curWi = curWr * wi + curWi * wr;
                curWr = nextWr;
            }
        }
    }
}

} // namespace

CavaService::CavaService(QObject *parent)
    : QObject(parent)
    , m_bars(kBarCount, 0.0)
    , m_window(kFftSize)
    , m_fftRe(kFftSize)
    , m_fftIm(kFftSize)
    , m_bandRaw(kBarCount)
    , m_smoothed(kBarCount, 0.0)
    , m_fallVel(kBarCount, 0.0f)
    , m_peaks(kBarCount, 0.0f)
{
    for (int i = 0; i < kFftSize; ++i) {
        m_window[i] = static_cast<float>(0.5 * (1.0 - qCos(2.0 * M_PI * i / (kFftSize - 1))));
    }

    connect(&m_timer, &QTimer::timeout, this, &CavaService::refresh);
    m_timer.setInterval(24);
}

CavaService::~CavaService()
{
    m_timer.stop();
    stopCaptureThread();
#ifdef Q_OS_WIN
    releaseWasapi();
#endif
}

void CavaService::start()
{
    if (m_captureActive) {
        return;
    }
    m_captureActive = true;
    emit activeChanged();

#ifdef Q_OS_WIN
    // COM + device activation happen on the main thread, exactly like
    // SystemInfoService's volume interface; the worker thread only pumps.
    setupWasapiLoopback();
#endif
    startCaptureThread();
    m_timer.start();
    qDebug() << "CavaService: started (WASAPI loopback capture with simulation fallback)";
}

void CavaService::stop()
{
    if (!m_captureActive) {
        return;
    }
    m_captureActive = false;
    m_timer.stop();
    stopCaptureThread();
#ifdef Q_OS_WIN
    releaseWasapi();
#endif
    emit activeChanged();
    qDebug() << "CavaService: stopped";
}

qreal CavaService::barAt(int index, int totalBars) const
{
    if (m_smoothed.empty()) return 0.0;
    if (totalBars <= 0 || totalBars == kBarCount) {
        if (index >= 0 && index < static_cast<int>(m_smoothed.size())) {
            return static_cast<qreal>(m_smoothed[index]);
        }
        return 0.0;
    }
    const int sourceIndex = std::min(static_cast<int>(m_smoothed.size()) - 1,
                                     static_cast<int>(index * m_smoothed.size() / totalBars));
    return static_cast<qreal>(m_smoothed[sourceIndex]);
}

qreal CavaService::peakAt(int index, int totalBars) const
{
    if (m_peaks.empty()) return 0.0;
    if (totalBars <= 0 || totalBars == kBarCount) {
        if (index >= 0 && index < static_cast<int>(m_peaks.size())) {
            return static_cast<qreal>(m_peaks[index]);
        }
        return 0.0;
    }
    const int sourceIndex = std::min(static_cast<int>(m_peaks.size()) - 1,
                                     static_cast<int>(index * m_peaks.size() / totalBars));
    return static_cast<qreal>(m_peaks[sourceIndex]);
}

void CavaService::refresh()
{
    if (!m_captureActive) {
        return;
    }

    bool analysed = false;
    if (m_everCaptured) {
        analysed = analyseSamples();
    }

    if (!analysed) {
        if (m_simulateWhilePlaying) {
            // Capture unavailable or silent + media detected playing: decorative fallback.
            simulateBars();
        } else {
            // Nothing playing and no capture: let the bars settle to zero —
            // the indicator must never move in silence. The fade is gentle so the
            // last bars glide away instead of dropping like a switch.
            for (int i = 0; i < kBarCount; ++i) {
                m_smoothed[i] *= 0.94f;
                if (m_smoothed[i] < 0.0015f)
                    m_smoothed[i] = 0.0f;
                m_peaks[i] = std::max(m_smoothed[i], m_peaks[i] - 0.008f);
            }
        }
    }

    // Once the panel has fully settled into silence there is nothing left to
    // animate: stop re-publishing the bar list at 60 fps so an idle desktop
    // never pays for a silent visualiser (and its QML bindings stay quiet).
    bool idle = true;
    for (int i = 0; i < kBarCount; ++i) {
        if (m_smoothed[i] > 0.0f || m_peaks[i] > 0.0f) {
            idle = false;
            break;
        }
    }
    if (idle && m_idleHold) {
        return;
    }
    m_idleHold = idle;

    m_bars.clear();
    m_bars.reserve(kBarCount);
    m_peaksList.clear();
    m_peaksList.reserve(kBarCount);
    for (int i = 0; i < kBarCount; ++i) {
        m_bars.append(m_smoothed[i]);
        m_peaksList.append(m_peaks[i]);
    }
    emit barsChanged();
}

void CavaService::simulateBars()
{
    m_simPhase += 0.15;
    for (int i = 0; i < kBarCount; ++i) {
        double base = qSin(m_simPhase + i * 0.2) * 0.5 + 0.5;
        double noise = QRandomGenerator::global()->generateDouble() * 0.3;
        double target = qMin(1.0, qMax(0.0, base + noise));

        double attack = 0.3;
        double decay = 0.15;
        if (target > m_smoothed[i]) {
            m_smoothed[i] += (target - m_smoothed[i]) * attack;
            m_fallVel[i] = 0.0f;
        } else {
            m_smoothed[i] += (target - m_smoothed[i]) * decay;
        }
        m_peaks[i] = std::max(m_smoothed[i], m_peaks[i] - 0.010f);
    }
}

void CavaService::startCaptureThread()
{
    if (m_runThread) {
        return;
    }
    m_runThread = true;
    m_thread = std::thread(&CavaService::captureLoop, this);
}

void CavaService::stopCaptureThread()
{
    if (!m_runThread) {
        return;
    }
    m_runThread = false;
    if (m_thread.joinable()) {
        m_thread.join();
    }
}

#ifdef Q_OS_WIN

// COM + WASAPI activation on the main thread (the same proven path
// SystemInfoService uses for the volume interface).
void CavaService::setupWasapiLoopback()
{
    if (m_wasapiReady) {
        return;
    }

    const HRESULT coInit = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    m_comInitializedHere = SUCCEEDED(coInit);

    IMMDeviceEnumerator *enumerator = nullptr;
    IMMDevice *device = nullptr;
    IAudioClient *client = nullptr;
    IAudioCaptureClient *capture = nullptr;
    WAVEFORMATEX *format = nullptr;

    auto bail = [&](const char *why, HRESULT hr) {
        qWarning() << "CavaService: loopback capture unavailable -" << why
                   << QString::number(static_cast<quint32>(hr), 16);
        if (format)
            CoTaskMemFree(format);
        if (capture)
            capture->Release();
        if (client)
            client->Release();
        if (device)
            device->Release();
        if (enumerator)
            enumerator->Release();
    };

    HRESULT hr = CoCreateInstance(k_CLSID_MMDeviceEnumerator, nullptr, CLSCTX_ALL,
                                  k_IID_IMMDeviceEnumerator, reinterpret_cast<void **>(&enumerator));
    if (FAILED(hr)) {
        bail("CoCreateInstance failed", hr);
        return;
    }

    hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
    if (FAILED(hr)) {
        bail("no default render endpoint", hr);
        return;
    }

    {
        LPWSTR devId = nullptr;
        if (SUCCEEDED(device->GetId(&devId))) {
            qDebug() << "CavaService: capturing endpoint" << QString::fromWCharArray(devId);
            CoTaskMemFree(devId);
        }
    }

    hr = device->Activate(k_IID_IAudioClient, CLSCTX_ALL, nullptr, reinterpret_cast<void **>(&client));
    if (FAILED(hr)) {
        bail("IAudioClient activate failed", hr);
        return;
    }

    hr = client->GetMixFormat(&format);
    if (FAILED(hr) || !format) {
        bail("GetMixFormat failed", hr);
        return;
    }

    // 1s buffer, shared-mode loopback on the render device.
    hr = client->Initialize(AUDCLNT_SHAREMODE_SHARED, AUDCLNT_STREAMFLAGS_LOOPBACK,
                            10000000, 0, format, nullptr);
    if (FAILED(hr)) {
        bail("loopback Initialize failed", hr);
        return;
    }

    hr = client->GetService(k_IID_IAudioCaptureClient, reinterpret_cast<void **>(&capture));
    if (FAILED(hr) || !capture) {
        bail("capture service unavailable", hr);
        return;
    }

    m_channels = std::max<int>(1, format->nChannels);
    m_isFloat = format->wFormatTag != WAVE_FORMAT_PCM;
    m_sampleRate = static_cast<int>(format->nSamplesPerSec);

    if (client->Start() != S_OK) {
        bail("capture Start failed", S_OK);
        return;
    }

    m_audioClient = client;
    m_captureClient = capture;
    m_wasapiReady = true;
    qDebug() << "CavaService: loopback capture running at" << format->nSamplesPerSec
             << "Hz," << m_channels << "ch, float:" << m_isFloat;

    CoTaskMemFree(format);
    device->Release();
    enumerator->Release();
}

void CavaService::releaseWasapi()
{
    if (!m_wasapiReady) {
        if (m_comInitializedHere) {
            CoUninitialize();
            m_comInitializedHere = false;
        }
        return;
    }
    m_wasapiReady = false;
    auto *client = static_cast<IAudioClient *>(m_audioClient);
    auto *capture = static_cast<IAudioCaptureClient *>(m_captureClient);
    if (capture)
        capture->Release();
    if (client)
        client->Release();
    m_audioClient = nullptr;
    m_captureClient = nullptr;
    if (m_comInitializedHere) {
        CoUninitialize();
        m_comInitializedHere = false;
    }
}

// Worker thread: pumps the loopback capture into the shared mono sample tail
// the GUI thread FFTs. COM interfaces were created on the main thread.
void CavaService::captureLoop()
{
    if (!m_wasapiReady) {
        return; // setup failed on the main thread - simulation fallback
    }

    auto *capture = static_cast<IAudioCaptureClient *>(m_captureClient);
    m_everCaptured = true;

    while (m_runThread) {
        QThread::msleep(6);

        UINT32 packet = 0;
        while (capture->GetNextPacketSize(&packet) == S_OK && packet > 0) {
            BYTE *data = nullptr;
            UINT32 frames = 0;
            DWORD flags = 0;
            if (capture->GetBuffer(&data, &frames, &flags, nullptr, nullptr) != S_OK)
                break;

            {
                std::lock_guard<std::mutex> lock(m_sampleMutex);
                if (flags & AUDCLNT_BUFFERFLAGS_SILENT) {
                    m_samples.insert(m_samples.end(), static_cast<size_t>(frames), 0.0f);
                } else if (m_isFloat) {
                    const float *src = reinterpret_cast<const float *>(data);
                    for (UINT32 i = 0; i < frames; ++i) {
                        float sum = 0.0f;
                        for (int c = 0; c < m_channels; ++c)
                            sum += src[i * m_channels + c];
                        m_samples.push_back(sum / static_cast<float>(m_channels));
                    }
                } else {
                    const int16_t *src = reinterpret_cast<const int16_t *>(data);
                    for (UINT32 i = 0; i < frames; ++i) {
                        int sum = 0;
                        for (int c = 0; c < m_channels; ++c)
                            sum += src[i * m_channels + c];
                        m_samples.push_back(sum / static_cast<float>(m_channels) / 32768.0f);
                    }
                }

                // Keep only a recent tail so memory stays bounded.
                constexpr size_t kMaxSamples = kFftSize * 8;
                if (m_samples.size() > kMaxSamples) {
                    m_samples.erase(m_samples.begin(), m_samples.end() - kMaxSamples);
                }
            }

            capture->ReleaseBuffer(frames);
        }
    }

    m_everCaptured = false;
    static_cast<IAudioClient *>(m_audioClient)->Stop();
}

#else

void CavaService::captureLoop()
{
    QThread::msleep(100);
    m_everCaptured = false;
}

#endif

bool CavaService::analyseSamples()
{
    std::vector<float> frame(kFftSize);
    {
        std::lock_guard<std::mutex> lock(m_sampleMutex);
        if (static_cast<int>(m_samples.size()) < kFftSize) {
            return false; // not enough audio yet
        }
        std::copy(m_samples.end() - kFftSize, m_samples.end(), frame.begin());
    }

    // Noise gate: with nothing playing the loopback buffer is digital
    // silence (or DAC dither). Let the spectrum settle instead of amplifying
    // the noise into visible bars.
    double rms = 0.0;
    for (const float s : frame)
        rms += double(s) * double(s);
    rms = std::sqrt(rms / kFftSize);
    if (rms < 2.5e-4) {
        for (int band = 0; band < kBarCount; ++band) {
            // Fade rather than cut: an abrupt collapse to zero read as a hard
            // "snap" the moment a track ended or dropped out.
            m_smoothed[band] *= 0.94f;
            m_fallVel[band] = 0.0f;
            if (m_smoothed[band] < 0.0015f)
                m_smoothed[band] = 0.0f;
            m_peaks[band] = std::max(m_smoothed[band], m_peaks[band] - 0.008f);
        }
        m_peakDb = std::max(-90.0, m_peakDb - 0.30);
        return false;
    }

    // Remove DC offset.
    double mean = 0.0;
    for (const float s : frame)
        mean += s;
    mean /= kFftSize;

    for (int i = 0; i < kFftSize; ++i) {
        m_fftRe[i] = (frame[i] - mean) * m_window[i];
        m_fftIm[i] = 0.0;
    }

    fftInPlace(m_fftRe, m_fftIm);

    // Log-spaced band edges: 30 Hz .. 16 kHz across kBarCount bands. Bands
    // are measured in dB so quiet detail stays visible and loud passages do
    // not flatten everything below them.
    const double binHz = static_cast<double>(m_sampleRate) / kFftSize;
    const double minHz = 30.0;
    const double maxHz = std::min(16000.0, m_sampleRate / 2.0);
    const double freqRatio = maxHz / minHz;

    double framePeakDb = -200.0;
    for (int band = 0; band < kBarCount; ++band) {
        const double f0 = minHz * std::pow(freqRatio, static_cast<double>(band) / kBarCount);
        const double f1 = minHz * std::pow(freqRatio, static_cast<double>(band + 1) / kBarCount);
        int bin0 = std::max(1, static_cast<int>(f0 / binHz));
        int bin1 = std::max(bin0 + 1, static_cast<int>(f1 / binHz));
        bin1 = std::min<int>(bin1, kFftSize / 2);

        double power = 0.0;
        for (int b = bin0; b < bin1; ++b) {
            const double p = m_fftRe[b] * m_fftRe[b] + m_fftIm[b] * m_fftIm[b];
            power = std::max(power, p);
        }

        // Gentle high-frequency tilt: music energy lives in the low end, so
        // lift the top octaves back into view (-7 dB at 30 Hz .. 0 dB at 16 kHz).
        const double tiltDb = 7.0 * (static_cast<double>(band) / kBarCount) - 7.0;
        const double bandDb = 10.0 * std::log10(power + 1e-12) + tiltDb;

        m_bandRaw[band] = static_cast<float>(bandDb);
        framePeakDb = std::max(framePeakDb, bandDb);
    }

    // Adaptive display window in dB: the ceiling follows the loudest band
    // (instant attack, slow release) with 3 dB of headroom, and 58 dB below
    // that is the floor of the visible range.
    m_peakDb = std::max(framePeakDb, m_peakDb - 0.35);
    const double hi = m_peakDb + 3.0;
    const double lo = hi - 58.0;

    for (int band = 0; band < kBarCount; ++band) {
        double v = (static_cast<double>(m_bandRaw[band]) - lo) / (hi - lo);
        v = std::pow(std::clamp(v, 0.0, 1.0), 1.18);
        if (v < 0.015)
            v = 0.0;

        // Liquid envelope: a soft, spring-like rise so a transient blooms into
        // place instead of snapping to its peak, then a gravity release whose
        // speed is capped by the distance remaining — the bar eases into the
        // new level rather than stopping dead on it.
        const float target = static_cast<float>(v);
        if (target > m_smoothed[band]) {
            m_smoothed[band] += (target - m_smoothed[band]) * 0.34f;
            m_fallVel[band] = 0.0f;
        } else if (m_smoothed[band] > target) {
            const float gap = m_smoothed[band] - target;
            m_fallVel[band] = std::min(m_fallVel[band] + 0.0022f, 0.050f);
            m_smoothed[band] -= std::min(m_fallVel[band], gap * 0.34f);
        }
        // Snap only at sub-pixel residue so the fade never ends visibly early.
        if (m_smoothed[band] < 0.0015f)
            m_smoothed[band] = 0.0f;

        // Peak caps drift down slowly and never sink below the bar.
        m_peaks[band] = std::max(m_smoothed[band], m_peaks[band] - 0.008f);
    }
    return true;
}
