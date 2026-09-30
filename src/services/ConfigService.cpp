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
QString ConfigService::profile() const { return m_profile; }
QString ConfigService::themeName() const { return m_themeName; }
QString ConfigService::layoutName() const { return m_layoutName; }

void ConfigService::setAccentColor(const QString &color) { m_accentColor = color; save(); emit appearanceChanged(); }
void ConfigService::setOverlayOpacity(qreal opacity) { m_overlayOpacity = qBound<qreal>(0.65, opacity, 1.0); save(); emit appearanceChanged(); }
void ConfigService::setBackgroundPath(const QString &path) { m_backgroundPath = QUrl(path).isLocalFile() ? QUrl(path).toLocalFile() : path; save(); emit appearanceChanged(); }
void ConfigService::setProfile(const QString &profile) { m_profile = profile; save(); emit appearanceChanged(); }
void ConfigService::setThemeName(const QString &name) { m_themeName = name; save(); emit appearanceChanged(); }
void ConfigService::setLayoutName(const QString &layout) { m_layoutName = layout; save(); emit layoutChanged(); }

void ConfigService::load()
{
    QFile file(configPath());
    if (!file.open(QIODevice::ReadOnly)) return;
    const auto data = QJsonDocument::fromJson(file.readAll()).object();
    m_accentColor = data.value("theme.accent").toString(m_accentColor);
    m_overlayOpacity = data.value("theme.opacity").toDouble(m_overlayOpacity);
    m_backgroundPath = data.value("theme.background").toString();
    m_profile = data.value("shell.profile").toString(m_profile);
    m_themeName = data.value("theme.name").toString(m_themeName);
    m_layoutName = data.value("shell.layout").toString(m_layoutName);
}

void ConfigService::save() const
{
    QJsonObject data;
    data["theme.accent"] = m_accentColor;
    data["theme.opacity"] = m_overlayOpacity;
    data["theme.background"] = m_backgroundPath;
    data["shell.profile"] = m_profile;
    data["theme.name"] = m_themeName;
    data["shell.layout"] = m_layoutName;
    QFile file(configPath());
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) file.write(QJsonDocument(data).toJson(QJsonDocument::Indented));
}

