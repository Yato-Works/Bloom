#include "WallpaperService.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QSettings>
#include <QStandardPaths>

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
        paths << QString::fromWCharArray(documents) + QStringLiteral("\\Bloom Wallpapers");
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
    const QStringList roots = defaultGalleryPaths();
    for (const QString &root : roots) {
        QDir dir(root);
        if (!dir.exists()) {
            continue;
        }
        const QStringList files = dir.entryList(imageFilters(), QDir::Files, QDir::Name);
        for (const QString &file : files) {
            m_names << QFileInfo(file).completeBaseName();
            m_paths << dir.filePath(file);
        }
    }

    refreshCurrent();
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
