#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>
#include <QSettings>

// Minimal Caelestia config singleton for Bloom Compatibility Layer.
// Exposes only the properties referenced by our ported QML files.
class CaelestiaConfig : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Config)

    // dashboard
    Q_PROPERTY(int mediaUpdateInterval READ mediaUpdateInterval WRITE setMediaUpdateInterval NOTIFY dashboardChanged FINAL)

    // services
    Q_PROPERTY(bool useTwelveHourClock READ useTwelveHourClock WRITE setUseTwelveHourClock NOTIFY servicesChanged FINAL)
    Q_PROPERTY(bool useFahrenheit READ useFahrenheit WRITE setUseFahrenheit NOTIFY servicesChanged FINAL)

public:
    explicit CaelestiaConfig(QObject* parent = nullptr);

    // dashboard
    [[nodiscard]] int mediaUpdateInterval() const { return m_dashboard.mediaUpdateInterval; }
    void setMediaUpdateInterval(int v) {
        if (m_dashboard.mediaUpdateInterval != v) {
            m_dashboard.mediaUpdateInterval = v;
            persist();
            emit dashboardChanged();
        }
    }

    // services
    [[nodiscard]] bool useTwelveHourClock() const { return m_services.useTwelveHourClock; }
    void setUseTwelveHourClock(bool v) {
        if (m_services.useTwelveHourClock != v) {
            m_services.useTwelveHourClock = v;
            persist();
            emit servicesChanged();
        }
    }
    [[nodiscard]] bool useFahrenheit() const { return m_services.useFahrenheit; }
    void setUseFahrenheit(bool v) {
        if (m_services.useFahrenheit != v) {
            m_services.useFahrenheit = v;
            persist();
            emit servicesChanged();
        }
    }

signals:
    void dashboardChanged();
    void servicesChanged();

private:
    void persist();
    void load();

    struct {
        int mediaUpdateInterval = 500;
    } m_dashboard;
    struct {
        bool useTwelveHourClock = false;
        bool useFahrenheit = false;
    } m_services;
};
