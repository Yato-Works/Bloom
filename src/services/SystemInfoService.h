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

public:
    explicit SystemInfoService(QObject *parent = nullptr);
    [[nodiscard]] int cpuUsage() const noexcept;
    [[nodiscard]] int memoryUsage() const noexcept;
    [[nodiscard]] QString memorySummary() const;
    [[nodiscard]] QString uptime() const;
    [[nodiscard]] QString hostName() const;
    [[nodiscard]] QString formattedTime() const;
    [[nodiscard]] QString formattedDate() const;

    void start();

signals:
    void metricsChanged();

private:
    void refresh();

    QTimer m_refreshTimer;
    int m_cpuUsage {0};
    int m_memoryUsage {0};
    QString m_memorySummary;
    QString m_uptime;
};
