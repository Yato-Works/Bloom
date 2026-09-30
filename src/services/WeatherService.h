#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

#include "ServiceLifecycle.h"

class WeatherService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString city READ city NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString temperature READ temperature NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString condition READ condition NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString wind READ wind NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString humidity READ humidity NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString pressure READ pressure NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString updatedAt READ updatedAt NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QString feelsLike READ feelsLike NOTIFY weatherChanged FINAL)
    Q_PROPERTY(QVariantList forecast READ forecast NOTIFY weatherChanged FINAL)
    Q_PROPERTY(bool ready READ isReady NOTIFY lifecycleChanged FINAL)

public:
    explicit WeatherService(QObject *parent = nullptr);
    ~WeatherService() override;

    WeatherService(const WeatherService &) = delete;
    WeatherService &operator=(const WeatherService &) = delete;

    [[nodiscard]] QString city() const;
    [[nodiscard]] QString temperature() const;
    [[nodiscard]] QString condition() const;
    [[nodiscard]] QString wind() const;
    [[nodiscard]] QString humidity() const;
    [[nodiscard]] QString pressure() const;
    [[nodiscard]] QString updatedAt() const;
    [[nodiscard]] QString feelsLike() const noexcept { return m_feelsLike; }
    [[nodiscard]] QVariantList forecast() const noexcept { return m_forecast; }
    [[nodiscard]] bool isReady() const noexcept;

    Q_INVOKABLE void reload();
    void initialize();
    void shutdown();

signals:
    void weatherChanged();
    void lifecycleChanged();
    void reloadFinished(bool success, const QString &message);

private:
    void applyDemoForecast();
    void fetchGeoLocation();
    void fetchGeoLocationFallback();
    void fetchWeather(double latitude, double longitude);
    void finishReady(bool success, const QString &message);
    static QString conditionFromCode(int weatherCode);
    static QString emojiFromCode(int weatherCode);

    ServiceLifecycle m_lifecycle {ServiceLifecycle::Created};
    QTimer m_reloadTimer;
    QString m_city;
    QString m_temperature;
    QString m_condition;
    QString m_wind;
    QString m_humidity;
    QString m_pressure;
    QString m_updatedAt;
    QString m_feelsLike;
    QVariantList m_forecast;
    class QNetworkAccessManager *m_net {nullptr};
    double m_latitude {0.0};
    double m_longitude {0.0};
};
