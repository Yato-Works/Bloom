#pragma once

#include <QObject>
#include <QTimer>

class SystemInfoService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int ramUsage READ memoryUsage NOTIFY metricsChanged FINAL)
    Q_PROPERTY(QString memorySummary READ memorySummary NOTIFY metricsChanged FINAL)
    Q_PROPERTY(QString uptime READ uptime NOTIFY metricsChanged FINAL)
    Q_PROPERTY(QString hostName READ hostName CONSTANT FINAL)
    Q_PROPERTY(QString formattedTime READ formattedTime NOTIFY metricsChanged FINAL)
    Q_PROPERTY(QString formattedDate READ formattedDate NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int batteryPercent READ batteryPercent NOTIFY metricsChanged FINAL)
    Q_PROPERTY(bool batteryCharging READ batteryCharging NOTIFY metricsChanged FINAL)
    Q_PROPERTY(bool hasBattery READ hasBattery NOTIFY metricsChanged FINAL)
    Q_PROPERTY(int volumeLevel READ volumeLevel NOTIFY metricsChanged FINAL)
    Q_PROPERTY(bool volumeMuted READ volumeMuted NOTIFY metricsChanged FINAL)

public:
    explicit SystemInfoService(QObject *parent = nullptr);
    ~SystemInfoService() override;

    [[nodiscard]] int cpuUsage() const noexcept;
    [[nodiscard]] int memoryUsage() const noexcept;
    [[nodiscard]] QString memorySummary() const;
    [[nodiscard]] QString uptime() const;
    [[nodiscard]] QString hostName() const;
    [[nodiscard]] QString formattedTime() const;
    [[nodiscard]] QString formattedDate() const;
    [[nodiscard]] int batteryPercent() const noexcept;
    [[nodiscard]] bool batteryCharging() const noexcept;
    [[nodiscard]] bool hasBattery() const noexcept;
    [[nodiscard]] int volumeLevel() const noexcept;
    [[nodiscard]] bool volumeMuted() const noexcept;

    Q_INVOKABLE void setVolume(int level);
    Q_INVOKABLE void toggleMute();

    void start();

signals:
    void metricsChanged();

private:
    void refresh();
    void refreshVolume();

    QTimer m_refreshTimer;
    int m_cpuUsage {0};
    int m_memoryUsage {0};
    QString m_memorySummary;
    QString m_uptime;
    int m_batteryPercent {100};
    bool m_batteryCharging {false};
    bool m_hasBattery {false};
    int m_volumeLevel {50};
    bool m_volumeMuted {false};

#ifdef Q_OS_WIN
    // COM interface for volume control
    struct IAudioEndpointVolume *m_volumeInterface {nullptr};
    void *m_deviceEnumerator {nullptr};
#endif
};