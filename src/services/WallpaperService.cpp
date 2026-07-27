#include "WallpaperService.h"

#include <QDir>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

WallpaperService::WallpaperService(QObject *parent)
    : QObject(parent)
{
}

bool WallpaperService::setWallpaper(const QString &filePath)
{
    // Clean up file path if it's a URL (e.g., file:///C:/...)
    QString pathString = filePath;
    if (pathString.startsWith(QStringLiteral("file:///"))) {
        pathString = pathString.mid(8);
    }
    // Also handle just file://
    else if (pathString.startsWith(QStringLiteral("file://"))) {
        pathString = pathString.mid(7);
    }

#ifdef Q_OS_WIN
    // Convert / to \ for Windows
    pathString = QDir::toNativeSeparators(pathString);
    
    // Use SystemParametersInfoW for Unicode support
    const wchar_t *path = reinterpret_cast<const wchar_t *>(pathString.utf16());
    
    // SPI_SETDESKWALLPAPER = 20
    return SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, (void*)path, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
#else
    // For non-Windows platforms, we might need a different approach, 
    // but the requirement is Windows-focused.
    return false;
#endif
}

