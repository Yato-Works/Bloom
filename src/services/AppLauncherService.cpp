#include "AppLauncherService.h"

#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QDesktopServices>
#include <QUrl>
#include <QStandardPaths>
#include <QDebug>

#ifdef Q_OS_WIN
#  include <qt_windows.h>
#  include <shlobj.h>
#endif

AppLauncherService::AppLauncherService(QObject *parent)
    : QObject(parent)
{
    initSystemApps();
}

void AppLauncherService::initSystemApps()
{
    struct AppPreset {
        QString name;
        QString category;
        QString icon;
        QString exec;
        QString description;
    };

    const QList<AppPreset> presets = {
        {"Google Chrome", "Web Browser", "🌐", "chrome.exe", "Fast web browser"},
        {"Visual Studio Code", "Developer Tools", "💻", "code.cmd", "Code editor"},
        {"Notepad", "Utilities", "📝", "notepad.exe", "Text editor"},
        {"Calculator", "Utilities", "🧮", "bloom-calculator", "Bloom Custom Calculator"},
        {"File Explorer", "System", "📂", "explorer.exe", "Windows file manager"},
        {"Command Prompt", "Terminal", "⚡", "cmd.exe", "Windows CLI shell"},
        {"PowerShell", "Terminal", "💙", "powershell.exe", "PowerShell automation"},
        {"Task Manager", "System", "📊", "taskmgr.exe", "System performance monitor"},
        {"Settings", "System", "⚙", "ms-settings:", "Windows configuration"},
        {"Paint", "Media", "🎨", "mspaint.exe", "Graphics & drawing"},
        {"Spotify", "Media", "🎵", "spotify.exe", "Music streaming"},
        {"Discord", "Social", "💬", "discord.exe", "Voice & text chat"},
        {"Microsoft Edge", "Web Browser", "🌊", "msedge.exe", "Microsoft browser"}
    };

    m_apps.clear();
    for (const auto &p : presets) {
        QVariantMap item;
        item["name"] = p.name;
        item["category"] = p.category;
        item["icon"] = p.icon;
        item["exec"] = p.exec;
        item["description"] = p.description;
        m_apps.append(item);
    }

#ifdef Q_OS_WIN
    // Scan Windows Start Menu Programs
    const QStringList startDirs = {
        QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation),
        QStringLiteral("C:/ProgramData/Microsoft/Windows/Start Menu/Programs")
    };

    for (const QString &startDir : startDirs) {
        QDir dir(startDir);
        if (!dir.exists()) continue;

        const QFileInfoList entries = dir.entryInfoList({QStringLiteral("*.lnk")}, QDir::Files, QDir::Name);
        for (const QFileInfo &fi : entries) {
            const QString baseName = fi.completeBaseName();
            if (baseName.contains(QStringLiteral("Uninstall"), Qt::CaseInsensitive)) continue;

            bool duplicate = false;
            for (const auto &existing : m_apps) {
                if (existing.toMap().value("name").toString().compare(baseName, Qt::CaseInsensitive) == 0) {
                    duplicate = true;
                    break;
                }
            }

            if (!duplicate) {
                QVariantMap item;
                item["name"] = baseName;
                item["category"] = QStringLiteral("Installed Application");
                item["icon"] = QStringLiteral("🚀");
                item["exec"] = fi.absoluteFilePath();
                item["description"] = QStringLiteral("Start Menu Shortcut");
                m_apps.append(item);
            }
        }
    }
#endif

    emit appsChanged();
}

QVariantList AppLauncherService::searchApps(const QString &query)
{
    if (query.trimmed().isEmpty()) {
        return m_apps;
    }

    const QString q = query.trimmed().toLower();
    QVariantList exactStarts;
    QVariantList contains;

    for (const auto &item : m_apps) {
        const QVariantMap map = item.toMap();
        const QString name = map.value("name").toString().toLower();
        const QString cat = map.value("category").toString().toLower();
        const QString exec = map.value("exec").toString().toLower();

        if (name.startsWith(q) || exec.startsWith(q)) {
            exactStarts.append(map);
        } else if (name.contains(q) || cat.contains(q) || exec.contains(q)) {
            contains.append(map);
        }
    }

    QVariantList results = exactStarts;
    results.append(contains);
    return results;
}

#include <QJSEngine>
#include <QJSValue>

bool AppLauncherService::launchApp(const QString &execPathOrName)
{
    if (execPathOrName.isEmpty()) return false;

    if (execPathOrName.startsWith(QStringLiteral("ms-settings:"))) {
        return QDesktopServices::openUrl(QUrl(execPathOrName));
    }

    if (execPathOrName.endsWith(QStringLiteral(".lnk"), Qt::CaseInsensitive)) {
        return QDesktopServices::openUrl(QUrl::fromLocalFile(execPathOrName));
    }

    return QProcess::startDetached(execPathOrName, {});
}

bool AppLauncherService::launchAppByIndex(int index)
{
    if (index < 0 || index >= m_apps.size()) return false;
    const QVariantMap map = m_apps.at(index).toMap();
    return launchApp(map.value("exec").toString());
}

QVariantMap AppLauncherService::evaluateMath(const QString &input)
{
    QVariantMap res;
    res["valid"] = false;

    QString expr = input.trimmed();
    if (expr.startsWith('=')) {
        expr = expr.mid(1).trimmed();
    }

    if (expr.isEmpty()) return res;

    expr.replace(QStringLiteral("x"), QStringLiteral("*"), Qt::CaseInsensitive);
    expr.replace(QStringLiteral("×"), QStringLiteral("*"));
    expr.replace(QStringLiteral("÷"), QStringLiteral("/"));
    expr.replace(QStringLiteral("^"), QStringLiteral("**"));

    QJSEngine jsEngine;
    QJSValue val = jsEngine.evaluate(expr);
    if (!val.isError() && (val.isNumber() || val.isString())) {
        const double num = val.toNumber();
        res["valid"] = true;
        res["expression"] = expr;
        res["result"] = QString::number(num, 'g', 10);
        res["formatted"] = "= " + QString::number(num, 'g', 10);
    }

    return res;
}

QVariantList AppLauncherService::availableCommands() const
{
    struct CmdDef {
        QString name;
        QString syntax;
        QString desc;
        QString icon;
        QString category;
    };

    const QList<CmdDef> cmds = {
        {">calculator", ">calculator", "Launch Bloom Custom Calculator (Alias: >c, >calc)", "🧮", "Utility"},
        {">theme", ">theme [mocha|macchiato|frappe|latte]", "Cycle or switch Catppuccin color theme", "🎨", "Appearance"},
        {">lock", ">lock", "Toggle overlay lock mode (Space bar)", "🔒", "System Control"},
        {">snip", ">snip", "Launch Snipping Tool for screen capture", "✂️", "Utility"},
        {">wallpaper", ">wallpaper", "Open Wallpaper Carousel & Manager", "🖼️", "Appearance"},
        {">folder", ">folder", "Open Local Wallpapers Storage Folder", "📂", "Appearance"},
        {">reload", ">reload", "Refresh Local Wallpapers & Assets", "🔄", "Appearance"},
        {">volume", ">volume [0-100]", "Set system master audio volume level", "🔊", "System Control"},
        {">music", ">music", "Open Media Player & CAVA Audio Visualizer", "🎵", "Dashboard"},
        {">system", ">system", "Open System Resource Gauges & Telemetry", "⚙️", "Dashboard"},
        {">weather", ">weather", "Open Weather Forecast & Climate Tab", "☁️", "Dashboard"},
        {">power", ">power [lock|sleep|shutdown]", "Trigger system power options menu", "⏻", "System Control"}
    };

    QVariantList list;
    for (const auto &c : cmds) {
        QVariantMap m;
        m["name"] = c.name;
        m["syntax"] = c.syntax;
        m["desc"] = c.desc;
        m["icon"] = c.icon;
        m["category"] = c.category;
        list.append(m);
    }
    return list;
}

QVariantList AppLauncherService::searchCliCommands(const QString &query)
{
    QVariantList all = availableCommands();
    QString q = query.trimmed();
    if (q.startsWith('>')) {
        q = q.mid(1).trimmed();
    }
    if (q.isEmpty()) {
        return all;
    }

    q = q.toLower();
    QVariantList exactStarts;
    QVariantList contains;

    for (const auto &item : all) {
        QVariantMap map = item.toMap();
        QString name = map.value("name").toString().toLower();
        QString desc = map.value("desc").toString().toLower();
        QString category = map.value("category").toString().toLower();

        if (name.startsWith(">" + q) || name.startsWith(q) || (q == "c" && name.contains("calculator")) || (q == "calc" && name.contains("calculator"))) {
            exactStarts.append(map);
        } else if (name.contains(q) || desc.contains(q) || category.contains(q)) {
            contains.append(map);
        }
    }

    QVariantList filtered = exactStarts;
    filtered.append(contains);
    return filtered;
}

void AppLauncherService::requestThemeSettings()
{
    emit themeSettingsRequested();
}

void AppLauncherService::requestSettings()
{
    emit settingsRequested();
}
