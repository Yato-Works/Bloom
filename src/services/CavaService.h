#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

#include <atomic>
#include <mutex>
#include <thread>
#include <vector>

/// System audio spectrum analyser.
///
/// Captures the Windows default render endpoint via WASAPI loopback (so it
/// visualises exactly what the system is playing), runs a Hann-windowed FFT
/// over the captured samples and publishes log-spaced frequency bands to QML
/// through the same `bars` / `active` API the old cava-based service used.
class CavaService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList bars READ bars NOTIFY barsChanged FINAL)
    Q_PROPERTY(QVariantList peaks READ peaks NOTIFY barsChanged FINAL)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)

public:
    explicit CavaService(QObject *parent = nullptr);
    ~CavaService() override;

    [[nodiscard]] QVariantList bars() const noexcept { return m_bars; }
    [[nodiscard]] QVariantList peaks() const noexcept { return m_peaksList; }
    [[nodiscard]] bool active() const noexcept { return m_captureActive; }

    Q_INVOKABLE qreal barAt(int index, int totalBars = 0) const;
    Q_INVOKABLE qreal peakAt(int index, int totalBars = 0) const;

    void start();
    void stop();

    // Fallback visualiser runs only while media is actually playing
    // (wired by ServiceManager from MusicControlService).
    void setSimulateWhilePlaying(bool on) { m_simulateWhilePlaying = on; }

signals:
    void barsChanged();
    void activeChanged();

private:
    void refresh();          // GUI thread: analyse latest samples, emit bars
    void simulateBars();     // Fallback when audio capture is unavailable
    void startCaptureThread();
    void stopCaptureThread();
    void captureLoop();      // Worker thread: WASAPI loopback -> sample buffer
    bool analyseSamples();
#ifdef Q_OS_WIN
    void setupWasapiLoopback();   // Main thread: COM + device activation
    void releaseWasapi();         // Main thread: release COM interfaces
#endif

    static constexpr int kBarCount = 96;
    static constexpr int kFftSize = 4096;

    std::thread m_thread;
    std::atomic_bool m_runThread {false};
    std::atomic_bool m_captureActive {false};
    std::atomic_bool m_everCaptured {false};
    std::atomic<int> m_sampleRate {48000};

    std::mutex m_sampleMutex;
    std::vector<float> m_samples;      // Mono capture buffer (recent tail)

#ifdef Q_OS_WIN
    // WASAPI loopback interfaces created on the main thread (void* keeps COM
    // headers out of this header); the worker thread only pumps the buffer.
    void *m_audioClient {nullptr};     // IAudioClient*
    void *m_captureClient {nullptr};   // IAudioCaptureClient*
    bool m_wasapiReady {false};
    int m_channels {2};
    bool m_isFloat {true};
    bool m_comInitializedHere {false};
#endif

    QTimer m_timer;
    QVariantList m_bars;
    QVariantList m_peaksList;              // Peak caps for the QML spectrum
    bool m_simulateWhilePlaying {false};   // GUI thread only

    // Analysis state (GUI thread only)
    std::vector<float> m_window;       // Hann window
    std::vector<float> m_fftRe;
    std::vector<float> m_fftIm;
    std::vector<float> m_bandRaw;      // Band levels in dB for this frame
    std::vector<float> m_smoothed;     // Attack/decay smoothed output
    std::vector<float> m_fallVel;      // Per-band gravity velocity
    std::vector<float> m_peaks;        // Slowly-descending peak caps
    double m_peakDb {-90.0};           // Adaptive dB ceiling (auto-gain)
    qreal m_simPhase {0.0};
    bool m_idleHold {false};           // Last published frame was fully silent
};
