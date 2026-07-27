#include "WeatherService.h"

#include <QDateTime>

WeatherService::WeatherService(QObject *parent)
    : QObject(parent)
{
    m_reloadTimer.setInterval(30 * 60 * 1000);
    m_reloadTimer.setSingleShot(false);
    connect(&m_reloadTimer, &QTimer::timeout, this, &WeatherService::reload);
}

WeatherService::~WeatherService()
{
    shutdown();
}

QString WeatherService::city() const { return m_city; }
QString WeatherService::temperature() const { return m_temperature; }
QString WeatherService::condition() const { return m_condition; }
QString WeatherService::wind() const { return m_wind; }
QString WeatherService::humidity() const { return m_humidity; }
QString WeatherService::pressure() const { return m_pressure; }
QString WeatherService::updatedAt() const { return m_updatedAt; }
bool WeatherService::isReady() const noexcept { return m_lifecycle == ServiceLifecycle::Ready; }

void WeatherService::initialize()
{
    if (m_lifecycle != ServiceLifecycle::Created)
        return;

    m_lifecycle = ServiceLifecycle::Initializing;
    emit lifecycleChanged();
    reload();
    m_reloadTimer.start();
}

void WeatherService::shutdown()
{
    if (m_lifecycle == ServiceLifecycle::ShuttingDown)
        return;

    m_lifecycle = ServiceLifecycle::ShuttingDown;
    m_reloadTimer.stop();
    emit lifecycleChanged();
}

void WeatherService::reload()
{
    // The service remains asynchronous at its public boundary. This temporary
    // fixture is replaced by ApiClient without changing QML bindings.
    applyDemoForecast();
    m_lifecycle = ServiceLifecycle::Ready;
    emit weatherChanged();
    emit lifecycleChanged();
    emit reloadFinished(true, QStringLiteral("Weather updated"));
}

void WeatherService::applyDemoForecast()
{
    m_city = QStringLiteral("Tokyo, Japan");
    m_temperature = QStringLiteral("23°");
    m_condition = QStringLiteral("晴れ時々くもり");
    m_wind = QStringLiteral("3.2 m/s");
    m_humidity = QStringLiteral("56%");
    m_pressure = QStringLiteral("1012 hPa");
    m_updatedAt = QDateTime::currentDateTime().toString(QStringLiteral("HH:mm"));
}
