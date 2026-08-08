#include "WallpaperService.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QSettings>
#include <QStandardPaths>
#include <QDesktopServices>
#include <QUrl>

#ifdef Q_OS_WIN
#  include <qt_windows.h>
#  include <shlobj.h>
#endif

namespace {
QStringList defaultGalleryPaths()
{
    QStringList paths;

#ifdef Q_OS_WIN
    const QString appData = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QStringLiteral("/Bloom/wallpapers");
    QDir().mkpath(appData);
    paths << appData;

    WCHAR documents[MAX_PATH] = {0};
    if (SHGetFolderPathW(nullptr, CSIDL_MYDOCUMENTS, nullptr, SHGFP_TYPE_CURRENT, documents) == S_OK) {
        const QString docsPath = QString::fromWCharArray(documents) + QStringLiteral("\\Bloom Wallpapers");
        QDir().mkpath(docsPath);
        paths << docsPath;
    }
#endif

    return paths;
}

QStringList imageFilters()
{
    return {QStringLiteral("*.png"), QStringLiteral("*.jpg"), QStringLiteral("*.jpeg"), QStringLiteral("*.bmp"), QStringLiteral("*.webp")};
}
}

WallpaperService::WallpaperService(QObject *parent)
    : QObject(parent)
{
    refreshWallpapers();
}

void WallpaperService::refreshWallpapers()
{
    m_names.clear();
    m_paths.clear();

    loadDefaultWallpapers();

    const QStringList roots = defaultGalleryPaths();
    for (const QString &root : roots) {
        QDir dir(root);
        if (!dir.exists()) {
            dir.mkpath(QStringLiteral("."));
        }
        const QStringList files = dir.entryList(imageFilters(), QDir::Files, QDir::Name);
        for (const QString &file : files) {
            const QString fullPath = dir.filePath(file);
            const QString name = QFileInfo(file).completeBaseName();

            m_names << name;
            m_paths << fullPath;

            QVariantMap w;
            w["name"] = name;
            w["fileName"] = file;
            w["colorStart"] = QStringLiteral("#1e2233");
            w["colorEnd"] = QStringLiteral("#0b0d14");
            w["path"] = QUrl::fromLocalFile(fullPath).toString();
            m_wallpapers.append(w);
        }
    }

    emit wallpapersChanged();
    refreshCurrent();
}

void WallpaperService::openFolder()
{
    const QStringList roots = defaultGalleryPaths();
    if (!roots.isEmpty()) {
        const QString path = roots.first();
        QDir().mkpath(path);
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    }
}

QString WallpaperService::galleryFolderPath() const
{
    const QStringList roots = defaultGalleryPaths();
    return roots.isEmpty() ? QString() : roots.first();
}

void WallpaperService::loadDefaultWallpapers()
{
    struct DefaultWallpaper {
        QString name;
        QString fileName;
        QString colorStart;
        QString colorEnd;
    };

    const QList<DefaultWallpaper> defaults = {
        {"Deadly", "Deadly.png", "#1a1a1a", "#0d0d0d"},
        {"Edogawa Ranpo", "Edogawa_Ranpo.jpg", "#2c1f1d", "#4a3532"},
        {"Fall", "Fall.jpeg", "#0f0f14", "#1f1f2e"},
        {"Evangelion", "Evangelion.png", "#8a0f0f", "#3a0000"},
        {"Frieren", "Frieren.jpeg", "#3a4a5a", "#1e2936"}
    };

    m_wallpapers.clear();
    for (const auto &item : defaults) {
        QVariantMap w;
        w["name"] = item.name;
        w["fileName"] = item.fileName;
        w["colorStart"] = item.colorStart;
        w["colorEnd"] = item.colorEnd;
        w["path"] = "";
        m_wallpapers.append(w);
    }
    emit wallpapersChanged();
}

void WallpaperService::setSelectedIndex(int index)
{
    if (index >= 0 && index < m_wallpapers.size() && m_selectedIndex != index) {
        m_selectedIndex = index;
        emit selectedIndexChanged();

        const QVariantMap item = m_wallpapers.at(index).toMap();
        const QString path = item.value(QStringLiteral("path")).toString();
        if (!path.isEmpty()) {
            setWallpaper(path);
        }
    }
}

bool WallpaperService::setWallpaper(const QString &filePath)
{
    if (filePath.isEmpty()) {
        return false;
    }

    QString pathString = filePath;
    if (pathString.startsWith(QStringLiteral("file:///"))) {
        pathString = pathString.mid(8);
    } else if (pathString.startsWith(QStringLiteral("file://"))) {
        pathString = pathString.mid(7);
    }

#ifdef Q_OS_WIN
    pathString = QDir::toNativeSeparators(pathString);
    const bool ok = SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, (void*)pathString.utf16(), SPIF_UPDATEINIFILE | SPIF_SENDCHANGE) != 0;
#else
    const bool ok = false;
#endif

    if (ok) {
        refreshCurrent();
        emit currentWallpaperChanged();
    }
    return ok;
}

bool WallpaperService::setWallpaperByIndex(int index)
{
    if (index < 0 || index >= m_paths.size()) {
        return false;
    }
    return setWallpaper(m_paths.at(index));
}

QStringList WallpaperService::wallpaperNames() const
{
    return m_names;
}

QStringList WallpaperService::wallpaperPaths() const
{
    return m_paths;
}

int WallpaperService::currentIndex() const
{
    return m_currentIndex;
}

void WallpaperService::refreshCurrent()
{
    m_currentIndex = -1;
    if (m_paths.isEmpty()) {
        return;
    }

#ifdef Q_OS_WIN
    WCHAR path[MAX_PATH] = {0};
    if (SystemParametersInfoW(SPI_GETDESKWALLPAPER, std::size(path), path, 0)) {
        const QString current = QString::fromWCharArray(path);
        for (int i = 0; i < m_paths.size(); ++i) {
            if (QFileInfo(m_paths.at(i)).canonicalFilePath().compare(current, Qt::CaseInsensitive) == 0) {
                m_currentIndex = i;
                break;
            }
        }
    }
#endif
}
