#include "CaelestiaConfig.h"
#include <QSettings>
#include <QStandardPaths>
#include <QDir>

CaelestiaConfig::CaelestiaConfig(QObject* parent)
    : QObject(parent)
{
    load();
}

void CaelestiaConfig::persist() {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/Bloom";
    QDir().mkpath(dir);
    QSettings s(dir + "/caelestia-compat.ini", QSettings::IniFormat, this);
    s.beginGroup("dashboard");
    s.setValue("mediaUpdateInterval", m_dashboard.mediaUpdateInterval);
    s.endGroup();
    s.beginGroup("services");
    s.setValue("useTwelveHourClock", m_services.useTwelveHourClock ? 1 : 0);
    s.setValue("useFahrenheit", m_services.useFahrenheit ? 1 : 0);
    s.endGroup();
    s.sync();
}

void CaelestiaConfig::load() {
    const QString path = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/Bloom/caelestia-compat.ini";
    QSettings s(path, QSettings::IniFormat, this);
    s.beginGroup("dashboard");
    m_dashboard.mediaUpdateInterval = s.value("mediaUpdateInterval", m_dashboard.mediaUpdateInterval).toInt();
    s.endGroup();
    s.beginGroup("services");
    m_services.useTwelveHourClock = s.value("useTwelveHourClock", m_services.useTwelveHourClock).toBool();
    m_services.useFahrenheit = s.value("useFahrenheit", m_services.useFahrenheit).toBool();
    s.endGroup();
}
