#include "WeatherService.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>

#include <algorithm>

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
    m_net = new QNetworkAccessManager(this);
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
    if (m_lifecycle == ServiceLifecycle::ShuttingDown)
        return;

    if (!m_net) {
        // No network stack (service used outside initialize/shutdown flow)
        applyDemoForecast();
        finishReady(true, QStringLiteral("Demo weather"));
        return;
    }

    fetchGeoLocation();
}

void WeatherService::fetchGeoLocation()
{
    QNetworkRequest request{QUrl(QStringLiteral("https://ipapi.co/json/"))};
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
    request.setTransferTimeout(8000);

    QNetworkReply *reply = m_net->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            fetchGeoLocationFallback();
            return;
        }

        const QJsonObject obj = QJsonDocument::fromJson(reply->readAll()).object();
        const double lat = obj.value(QStringLiteral("latitude")).toDouble(-1000.0);
        const double lon = obj.value(QStringLiteral("longitude")).toDouble(-1000.0);
        m_city = obj.value(QStringLiteral("city")).toString();

        if (lat == -1000.0 || lon == -1000.0) {
            fetchGeoLocationFallback();
            return;
        }

        m_latitude = lat;
        m_longitude = lon;
        fetchWeather(lat, lon);
    });
}

void WeatherService::fetchGeoLocationFallback()
{
    // HTTPS only: the geolocation request reveals the user's network context,
    // so it must not travel over plaintext even as a fallback.
    QNetworkRequest request{QUrl(QStringLiteral("https://get.geojs.io/v1/ip/geo.json"))};
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
    request.setTransferTimeout(8000);

    QNetworkReply *reply = m_net->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            applyDemoForecast();
            finishReady(false, QStringLiteral("Geolocation unavailable"));
            return;
        }

        const QJsonObject obj = QJsonDocument::fromJson(reply->readAll()).object();
        bool latOk = false, lonOk = false;
        const double lat = obj.value(QStringLiteral("latitude")).toString().toDouble(&latOk);
        const double lon = obj.value(QStringLiteral("longitude")).toString().toDouble(&lonOk);

        if (!latOk || !lonOk) {
            applyDemoForecast();
            finishReady(false, QStringLiteral("Geolocation failed"));
            return;
        }

        m_city = obj.value(QStringLiteral("city")).toString();
        m_latitude = lat;
        m_longitude = lon;
        fetchWeather(lat, lon);
    });
}

void WeatherService::fetchWeather(double latitude, double longitude)
{
    QUrl url(QStringLiteral("https://api.open-meteo.com/v1/forecast"));
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("latitude"), QString::number(latitude, 'f', 4));
    query.addQueryItem(QStringLiteral("longitude"), QString::number(longitude, 'f', 4));
    query.addQueryItem(QStringLiteral("current"),
                       QStringLiteral("temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,surface_pressure,apparent_temperature"));
    query.addQueryItem(QStringLiteral("daily"),
                       QStringLiteral("weather_code,temperature_2m_max,temperature_2m_min"));
    query.addQueryItem(QStringLiteral("forecast_days"), QStringLiteral("7"));
    query.addQueryItem(QStringLiteral("timezone"), QStringLiteral("auto"));
    url.setQuery(query);

    QNetworkRequest request{url};
    request.setTransferTimeout(10000);

    QNetworkReply *reply = m_net->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            applyDemoForecast();
            finishReady(false, QStringLiteral("Weather request failed"));
            return;
        }

        const QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
        const QJsonObject current = root.value(QStringLiteral("current")).toObject();
        if (current.isEmpty()) {
            applyDemoForecast();
            finishReady(false, QStringLiteral("Weather response invalid"));
            return;
        }

        const double temp = current.value(QStringLiteral("temperature_2m")).toDouble(0.0);
        const int humidity = static_cast<int>(current.value(QStringLiteral("relative_humidity_2m")).toDouble(0.0));
        const double feelsLike = current.value(QStringLiteral("apparent_temperature")).toDouble(0.0);
        const double wind = current.value(QStringLiteral("wind_speed_10m")).toDouble(0.0);
        const int pressure = static_cast<int>(current.value(QStringLiteral("surface_pressure")).toDouble(0.0));
        const int code = static_cast<int>(current.value(QStringLiteral("weather_code")).toDouble(-1.0));

        if (m_city.isEmpty())
            m_city = QStringLiteral("Current location");

        m_temperature = QStringLiteral("%1°").arg(QString::number(temp, 'f', 0));
        m_condition = conditionFromCode(code);
        m_wind = QStringLiteral("%1 km/h").arg(QString::number(wind, 'f', 1));
        m_humidity = QStringLiteral("%1%").arg(humidity);
        m_pressure = QStringLiteral("%1 hPa").arg(pressure);
        m_feelsLike = QStringLiteral("%1°").arg(QString::number(feelsLike, 'f', 0));
        m_updatedAt = QDateTime::currentDateTime().toString(QStringLiteral("HH:mm"));

        // 7-day forecast from the real daily block.
        const QJsonObject daily = root.value(QStringLiteral("daily")).toObject();
        const QJsonArray codes = daily.value(QStringLiteral("weather_code")).toArray();
        const QJsonArray tMax = daily.value(QStringLiteral("temperature_2m_max")).toArray();
        const QJsonArray tMin = daily.value(QStringLiteral("temperature_2m_min")).toArray();

        QVariantList forecast;
        const QLocale en(QLocale::English);
        const int count = std::min(7, static_cast<int>(std::min(codes.size(), std::min(tMax.size(), tMin.size()))));
        for (int i = 0; i < count; ++i) {
            const QDate day = QDate::currentDate().addDays(i);
            QVariantMap entry;
            entry[QStringLiteral("day")] = i == 0 ? QStringLiteral("Today") : en.toString(day, QStringLiteral("ddd"));
            entry[QStringLiteral("date")] = en.toString(day, QStringLiteral("MMM d"));
            entry[QStringLiteral("glyph")] = emojiFromCode(static_cast<int>(codes.at(i).toDouble(-1)));
            entry[QStringLiteral("hi")] = QStringLiteral("%1°").arg(QString::number(tMax.at(i).toDouble(0.0), 'f', 0));
            entry[QStringLiteral("lo")] = QStringLiteral("%1°").arg(QString::number(tMin.at(i).toDouble(0.0), 'f', 0));
            forecast.append(entry);
        }
        m_forecast = forecast;

        finishReady(true, QStringLiteral("Live weather updated"));
    });
}

void WeatherService::finishReady(bool success, const QString &message)
{
    m_lifecycle = ServiceLifecycle::Ready;
    emit weatherChanged();
    emit lifecycleChanged();
    emit reloadFinished(success, message);
}

QString WeatherService::conditionFromCode(int weatherCode)
{    switch (weatherCode) {
    case 0: return QStringLiteral("Clear skies");
    case 1: return QStringLiteral("Mainly clear");
    case 2: return QStringLiteral("Partly cloudy");
    case 3: return QStringLiteral("Overcast");
    case 45:
    case 48: return QStringLiteral("Foggy");
    case 51:
    case 53:
    case 55: return QStringLiteral("Drizzle");
    case 56:
    case 57: return QStringLiteral("Freezing drizzle");
    case 61: return QStringLiteral("Light rain");
    case 63: return QStringLiteral("Rain");
    case 65: return QStringLiteral("Heavy rain");
    case 66:
    case 67: return QStringLiteral("Freezing rain");
    case 71: return QStringLiteral("Light snow");
    case 73: return QStringLiteral("Snow");
    case 75:
    case 77: return QStringLiteral("Heavy snow");
    case 80: return QStringLiteral("Light showers");
    case 81:
    case 82: return QStringLiteral("Rain showers");
    case 85:
    case 86: return QStringLiteral("Snow showers");
    case 95: return QStringLiteral("Thunderstorm");
    case 96:
    case 99: return QStringLiteral("Thunderstorm with hail");
    default: return QStringLiteral("Unknown");
    }
}

void WeatherService::applyDemoForecast()
{
    m_city = QStringLiteral("Tokyo, Japan");
    m_temperature = QStringLiteral("23°");
    m_condition = QStringLiteral("晴れ時々くもり");
    m_wind = QStringLiteral("3.2 m/s");
    m_humidity = QStringLiteral("56%");
    m_pressure = QStringLiteral("1012 hPa");
    m_feelsLike = QStringLiteral("24°");
    m_updatedAt = QDateTime::currentDateTime().toString(QStringLiteral("HH:mm"));

    QVariantList forecast;
    const QLocale en(QLocale::English);
    const QList<QPair<int, QPair<int, int>>> demo = {
        {2, {23, 18}}, {3, {21, 17}}, {61, {19, 15}}, {80, {22, 16}}, {1, {24, 18}}, {0, {26, 19}}, {2, {25, 20}}
    };
    for (int i = 0; i < demo.size(); ++i) {
        const QDate day = QDate::currentDate().addDays(i);
        QVariantMap entry;
        entry[QStringLiteral("day")] = i == 0 ? QStringLiteral("Today") : en.toString(day, QStringLiteral("ddd"));
        entry[QStringLiteral("date")] = en.toString(day, QStringLiteral("MMM d"));
        entry[QStringLiteral("glyph")] = emojiFromCode(demo.at(i).first);
        entry[QStringLiteral("hi")] = QStringLiteral("%1°").arg(demo.at(i).second.first);
        entry[QStringLiteral("lo")] = QStringLiteral("%1°").arg(demo.at(i).second.second);
        forecast.append(entry);
    }
    m_forecast = forecast;
}

QString WeatherService::emojiFromCode(int weatherCode)
{
    switch (weatherCode) {
    case 0: return QStringLiteral("☀️");
    case 1:
    case 2: return QStringLiteral("🌤️");
    case 3: return QStringLiteral("☁️");
    case 45:
    case 48: return QStringLiteral("🌫️");
    case 51:
    case 53:
    case 55:
    case 56:
    case 57: return QStringLiteral("🌦️");
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 80:
    case 81:
    case 82: return QStringLiteral("🌧️");
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86: return QStringLiteral("❄️");
    case 95:
    case 96:
    case 99: return QStringLiteral("⛈️");
    default: return QStringLiteral("🌤️");
    }
}
