#include "SystemInfoService.h"

#include <QSysInfo>

#ifdef Q_OS_WIN
#include <windows.h>

namespace {
quint64 toUint64(const FILETIME &time)
{
    ULARGE_INTEGER value {};
    value.LowPart = time.dwLowDateTime;
    value.HighPart = time.dwHighDateTime;
    return value.QuadPart;
}
}
#endif

namespace {
quint64 previousIdle = 0;
quint64 previousKernel = 0;
quint64 previousUser = 0;
}

SystemInfoService::SystemInfoService(QObject *parent) : QObject(parent)
{
    m_refreshTimer.setInterval(1500);
    connect(&m_refreshTimer, &QTimer::timeout, this, &SystemInfoService::refresh);

    // Warm up CPU deltas so the very first refresh computes a real percentage,
    // not an average-since-boot value driven by all-zero baselines.
    FILETIME idle{}, kernel{}, user{};
    if (GetSystemTimes(&idle, &kernel, &user)) {
        previousIdle   = toUint64(idle);
        previousKernel = toUint64(kernel);
        previousUser   = toUint64(user);
    }
}

#include <QDateTime>

int SystemInfoService::cpuUsage() const noexcept { return m_cpuUsage; }
int SystemInfoService::memoryUsage() const noexcept { return m_memoryUsage; }
QString SystemInfoService::memorySummary() const { return m_memorySummary; }
QString SystemInfoService::uptime() const { return m_uptime; }
QString SystemInfoService::hostName() const { return QSysInfo::machineHostName(); }
QString SystemInfoService::formattedTime() const { return QTime::currentTime().toString(QStringLiteral("hh:mm")); }
QString SystemInfoService::formattedDate() const { return QDate::currentDate().toString(QStringLiteral("MMMM d, ddd")); }

void SystemInfoService::start()
{
    refresh();
    m_refreshTimer.start();
}

void SystemInfoService::refresh()
{
#ifdef Q_OS_WIN
    quint64 previousIdle = 0;
    quint64 previousKernel = 0;
    quint64 previousUser = 0;
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

    MEMORYSTATUSEX memory {sizeof(MEMORYSTATUSEX)};
    if (GlobalMemoryStatusEx(&memory)) {
        m_memoryUsage = static_cast<int>(memory.dwMemoryLoad);
        const auto usedGiB = (memory.ullTotalPhys - memory.ullAvailPhys) / (1024.0 * 1024.0 * 1024.0);
        const auto totalGiB = memory.ullTotalPhys / (1024.0 * 1024.0 * 1024.0);
        m_memorySummary = QStringLiteral("%1 / %2 GB").arg(usedGiB, 0, 'f', 1).arg(totalGiB, 0, 'f', 1);
    }

    const auto seconds = GetTickCount64() / 1000;
    m_uptime = QStringLiteral("%1h %2m").arg(seconds / 3600).arg((seconds % 3600) / 60, 2, 10, QLatin1Char('0'));
#endif
    emit metricsChanged();
}
