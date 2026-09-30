#include "WallpaperService.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QSettings>
#include <QStandardPaths>
#include <QDesktopServices>
#include <QUrl>
#include <QRandomGenerator>

#ifdef Q_OS_WIN
#  include <qt_windows.h>
#  include <shlobj.h>
#endif

namespace {
QStringList defaultGalleryPaths()
{
    QStringList paths;

#ifdef Q_OS_WIN
    const QString home = QDir::homePath();
    const QString pictures = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    const QString docs = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    const QString appDir = QGuiApplication::applicationDirPath();

    const QStringList extraDirs = {
        pictures + QStringLiteral("/Bloom-Wallpapers"),
        pictures + QStringLiteral("/Bloom Wallpapers"),
        docs + QStringLiteral("/Bloom-Wallpapers"),
        docs + QStringLiteral("/Bloom Wallpapers"),
        home + QStringLiteral("/OneDrive/ドキュメント/Bloom-Wallpapers"),
        home + QStringLiteral("/OneDrive/Documents/Bloom-Wallpapers"),
        home + QStringLiteral("/OneDrive/ドキュメント/Bloom Wallpapers"),
        home + QStringLiteral("/OneDrive/Documents/Bloom Wallpapers"),
        home + QStringLiteral("/Pictures/Bloom-Wallpapers"),
        home + QStringLiteral("/Documents/Bloom-Wallpapers"),
        home + QStringLiteral("/Bloom-Wallpapers"),
        appDir + QStringLiteral("/wallpapers"),
        appDir + QStringLiteral("/assets/wallpapers")
    };
    for (const QString &p : extraDirs) {
        if (QDir(p).exists()) {
            paths << p;
        }
    }

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

    paths.removeDuplicates();
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
    m_wallpapers.clear();

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

            if (m_paths.contains(fullPath)) continue;

            m_names << name;
            m_paths << fullPath;

            QVariantMap w;
            w["name"] = name;
            w["fileName"] = file;
            w["colorStart"] = QStringLiteral("#1e2233");
            w["colorEnd"] = QStringLiteral("#0b0d14");
            w["path"] = QUrl::fromLocalFile(fullPath).toString();
            w["localPath"] = fullPath;
            m_wallpapers.append(w);
        }
    }

    if (m_wallpapers.isEmpty()) {
        loadDefaultWallpapers();
    }

    emit wallpapersChanged();
    refreshCurrent();
}

bool WallpaperService::setRandomWallpaper()
{
    if (m_wallpapers.isEmpty()) return false;
    const int idx = QRandomGenerator::global()->bounded(m_wallpapers.size());
    return setWallpaperByIndex(idx);
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
    // Scan Windows system wallpapers as a fallback when no user wallpapers are found
    m_wallpapers.clear();
    m_names.clear();
    m_paths.clear();

#ifdef Q_OS_WIN
    const QStringList systemDirs = {
        QStringLiteral("C:/Windows/Web/Wallpaper"),
        QStringLiteral("C:/Windows/Web/Screen"),
        QStringLiteral("C:/Windows/Web/4K/Wallpaper")
    };

    for (const QString &sysDir : systemDirs) {
        QDir dir(sysDir);
        if (!dir.exists()) continue;

        // Recurse into subdirectories
        const auto entries = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
        QList<QDir> searchDirs;
        searchDirs.append(dir);
        for (const auto &entry : entries) {
            searchDirs.append(QDir(entry.filePath()));
        }

        for (const QDir &d : searchDirs) {
            const QStringList files = d.entryList(imageFilters(), QDir::Files, QDir::Name);
            for (const QString &file : files) {
                const QString fullPath = d.filePath(file);
                const QString name = QFileInfo(file).completeBaseName();

                if (m_paths.contains(fullPath)) continue;

                // Skip tiny thumbnails (< 50KB)
                if (QFileInfo(fullPath).size() < 50000) continue;

                m_names << name;
                m_paths << fullPath;

                QVariantMap w;
                w["name"] = name;
                w["fileName"] = file;
                w["colorStart"] = QStringLiteral("#1e2233");
                w["colorEnd"] = QStringLiteral("#0b0d14");
                w["path"] = QUrl::fromLocalFile(fullPath).toString();
                w["localPath"] = fullPath;
                m_wallpapers.append(w);
            }
        }
    }
#endif

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

QString WallpaperService::currentWallpaperPath() const
{
#ifdef Q_OS_WIN
    WCHAR path[MAX_PATH] = {0};
    if (SystemParametersInfoW(SPI_GETDESKWALLPAPER, std::size(path), path, 0)) {
        const QString current = QString::fromWCharArray(path);
        if (!current.isEmpty())
            return current;
    }
#endif
    if (m_currentIndex >= 0 && m_currentIndex < m_paths.size())
        return m_paths.at(m_currentIndex);
    return m_paths.value(0);
}
