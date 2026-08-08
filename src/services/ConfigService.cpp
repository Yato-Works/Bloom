#include "ConfigService.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QUrl>

namespace {
QString configPath()
{
    const auto directory = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(directory);
    return directory + QStringLiteral("/config.json");
}
}

ConfigService::ConfigService(QObject *parent) : QObject(parent) { load(); }
QString ConfigService::accentColor() const { return m_accentColor; }
qreal ConfigService::overlayOpacity() const noexcept { return m_overlayOpacity; }
QString ConfigService::backgroundPath() const { return m_backgroundPath; }

void ConfigService::setAccentColor(const QString &color) { m_accentColor = color; save(); emit appearanceChanged(); }
void ConfigService::setOverlayOpacity(qreal opacity) { m_overlayOpacity = qBound<qreal>(0.65, opacity, 1.0); save(); emit appearanceChanged(); }
void ConfigService::setBackgroundPath(const QString &path) { m_backgroundPath = QUrl(path).isLocalFile() ? QUrl(path).toLocalFile() : path; save(); emit appearanceChanged(); }

void ConfigService::load()
{
    QFile file(configPath());
    if (!file.open(QIODevice::ReadOnly)) return;
    const auto data = QJsonDocument::fromJson(file.readAll()).object();
    m_accentColor = data.value("theme.accent").toString(m_accentColor);
    m_overlayOpacity = data.value("theme.opacity").toDouble(m_overlayOpacity);
    m_backgroundPath = data.value("theme.background").toString();
}

void ConfigService::save() const
{
    QJsonObject data;
    data["theme.accent"] = m_accentColor;
    data["theme.opacity"] = m_overlayOpacity;
    data["theme.background"] = m_backgroundPath;
    QFile file(configPath());
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) file.write(QJsonDocument(data).toJson(QJsonDocument::Indented));
}

