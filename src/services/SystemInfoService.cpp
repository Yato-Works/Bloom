#include "SystemInfoService.h"

#include <QSysInfo>
#include <QDateTime>

#ifdef Q_OS_WIN
#include <windows.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>

namespace {
quint64 previousIdle = 0;
quint64 previousKernel = 0;
quint64 previousUser = 0;

quint64 toUint64(const FILETIME &time)
{
    ULARGE_INTEGER value {};
    value.LowPart = time.dwLowDateTime;
    value.HighPart = time.dwHighDateTime;
    return value.QuadPart;
}
}
#endif

SystemInfoService::SystemInfoService(QObject *parent) : QObject(parent)
{
    m_refreshTimer.setInterval(1500);
    connect(&m_refreshTimer, &QTimer::timeout, this, &SystemInfoService::refresh);

#ifdef Q_OS_WIN
    // Warm up CPU deltas
    FILETIME idle{}, kernel{}, user{};
    if (GetSystemTimes(&idle, &kernel, &user)) {
        previousIdle   = toUint64(idle);
        previousKernel = toUint64(kernel);
        previousUser   = toUint64(user);
    }

    // COM initialization for volume control
    CoInitializeEx(nullptr, COINIT_MULTITHREADED);

    // Get IMMDeviceEnumerator and IAudioEndpointVolume
    // Correct GUIDs from Windows SDK (mitigated for MinGW)
    IMMDeviceEnumerator *enumerator = nullptr;
    const CLSID CLSID_MMDeviceEnumerator_ = {0xbcde0395, 0xe52f, 0x4670, {0x8d, 0x3d, 0xc4, 0x57, 0x92, 0x91, 0x69, 0x2e}};
    const IID IID_IMMDeviceEnumerator_ = {0xa95664d2, 0x9614, 0x4f35, {0xa7, 0x46, 0xde, 0x8d, 0xb6, 0x36, 0x17, 0xe6}};

    HRESULT hr = CoCreateInstance(CLSID_MMDeviceEnumerator_, nullptr, CLSCTX_ALL,
                                  IID_IMMDeviceEnumerator_, reinterpret_cast<void**>(&enumerator));
    if (SUCCEEDED(hr) && enumerator) {
        m_deviceEnumerator = enumerator;
        IMMDevice *device = nullptr;
        hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
        if (SUCCEEDED(hr) && device) {
            const IID IID_IAudioEndpointVolume_ = {0x5cdf2c82, 0x841e, 0x4546, {0x97, 0x22, 0x0c, 0xf7, 0x40, 0x78, 0x22, 0x9a}};
            hr = device->Activate(IID_IAudioEndpointVolume_, CLSCTX_ALL, nullptr,
                                  reinterpret_cast<void**>(&m_volumeInterface));
            device->Release();
        }
    }
#endif
}

SystemInfoService::~SystemInfoService()
{
#ifdef Q_OS_WIN
    if (m_volumeInterface) {
        static_cast<IAudioEndpointVolume*>(m_volumeInterface)->Release();
        m_volumeInterface = nullptr;
    }
    if (m_deviceEnumerator) {
        static_cast<IMMDeviceEnumerator*>(m_deviceEnumerator)->Release();
        m_deviceEnumerator = nullptr;
    }
    CoUninitialize();
#endif
}

int SystemInfoService::cpuUsage() const noexcept { return m_cpuUsage; }
int SystemInfoService::memoryUsage() const noexcept { return m_memoryUsage; }
QString SystemInfoService::memorySummary() const { return m_memorySummary; }
QString SystemInfoService::uptime() const { return m_uptime; }
QString SystemInfoService::hostName() const { return QSysInfo::machineHostName(); }
QString SystemInfoService::formattedTime() const { return QTime::currentTime().toString(QStringLiteral("hh:mm")); }
QString SystemInfoService::formattedDate() const { return QDate::currentDate().toString(QStringLiteral("MMMM d · ddd")); }
int SystemInfoService::batteryPercent() const noexcept { return m_batteryPercent; }
bool SystemInfoService::batteryCharging() const noexcept { return m_batteryCharging; }
bool SystemInfoService::hasBattery() const noexcept { return m_hasBattery; }
int SystemInfoService::volumeLevel() const noexcept { return m_volumeLevel; }
bool SystemInfoService::volumeMuted() const noexcept { return m_volumeMuted; }

void SystemInfoService::start()
{
    refresh();
    m_refreshTimer.start();
}

void SystemInfoService::setVolume(int level)
{
#ifdef Q_OS_WIN
    if (m_volumeInterface) {
        level = qBound(0, level, 100);
        const float fLevel = level / 100.0f;
        static_cast<IAudioEndpointVolume*>(m_volumeInterface)->SetMasterVolumeLevelScalar(fLevel, nullptr);
        m_volumeLevel = level;
        m_volumeMuted = false;
        emit metricsChanged();
    }
#else
    Q_UNUSED(level)
#endif
}

void SystemInfoService::toggleMute()
{
#ifdef Q_OS_WIN
    if (m_volumeInterface) {
        auto *vol = static_cast<IAudioEndpointVolume*>(m_volumeInterface);
        BOOL muted = FALSE;
        if (SUCCEEDED(vol->GetMute(&muted))) {
            vol->SetMute(!muted, nullptr);
            m_volumeMuted = !muted;
            emit metricsChanged();
        }
    }
#endif
}

void SystemInfoService::refreshVolume()
{
#ifdef Q_OS_WIN
    if (m_volumeInterface) {
        auto *vol = static_cast<IAudioEndpointVolume*>(m_volumeInterface);
        float level = 0.0f;
        if (SUCCEEDED(vol->GetMasterVolumeLevelScalar(&level))) {
            m_volumeLevel = static_cast<int>(level * 100.0f + 0.5f);
        }
        BOOL muted = FALSE;
        if (SUCCEEDED(vol->GetMute(&muted))) {
            m_volumeMuted = muted != FALSE;
        }
    }
#endif
}

void SystemInfoService::refresh()
{
#ifdef Q_OS_WIN
    // CPU usage (bug fix: removed local variable shadowing)
    FILETIME idle {}, kernel {}, user {};
    if (GetSystemTimes(&idle, &kernel, &user)) {
        const auto currentIdle = toUint64(idle);
        const auto currentKernel = toUint64(kernel);
        const auto currentUser = toUint64(user);
        const auto total = (currentKernel - previousKernel) + (currentUser - previousUser);
        if (total > 0)
            m_cpuUsage = static_cast<int>(100 - ((currentIdle - previousIdle) * 100 / total));
        previousIdle = currentIdle;
        previousKernel = currentKernel;
        previousUser = currentUser;
    }

    // Memory usage
    MEMORYSTATUSEX memory {sizeof(MEMORYSTATUSEX)};
    if (GlobalMemoryStatusEx(&memory)) {
        m_memoryUsage = static_cast<int>(memory.dwMemoryLoad);
        const auto usedGiB = (memory.ullTotalPhys - memory.ullAvailPhys) / (1024.0 * 1024.0 * 1024.0);
        const auto totalGiB = memory.ullTotalPhys / (1024.0 * 1024.0 * 1024.0);
        m_memorySummary = QStringLiteral("%1 / %2 GB").arg(usedGiB, 0, 'f', 1).arg(totalGiB, 0, 'f', 1);
    }

    // Uptime
    const auto seconds = GetTickCount64() / 1000;
    m_uptime = QStringLiteral("%1h %2m").arg(seconds / 3600).arg((seconds % 3600) / 60, 2, 10, QLatin1Char('0'));

    // Battery status
    SYSTEM_POWER_STATUS powerStatus {};
    if (GetSystemPowerStatus(&powerStatus)) {
        m_hasBattery = powerStatus.BatteryFlag != 128;
        if (powerStatus.BatteryLifePercent <= 100 && powerStatus.BatteryLifePercent != 255) {
            m_batteryPercent = powerStatus.BatteryLifePercent;
        }
        m_batteryCharging = (powerStatus.ACLineStatus == 1) && (powerStatus.BatteryFlag & 8);
    }

    // Volume level
    refreshVolume();
#endif
    emit metricsChanged();
}