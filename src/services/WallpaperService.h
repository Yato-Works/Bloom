#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class WallpaperService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList wallpapers READ wallpapers NOTIFY wallpapersChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)

public:
    explicit WallpaperService(QObject *parent = nullptr);

    QVariantList wallpapers() const { return m_wallpapers; }
    int selectedIndex() const { return m_selectedIndex; }
    void setSelectedIndex(int index);

    Q_INVOKABLE bool setWallpaper(const QString &filePath);
    Q_INVOKABLE bool setWallpaperByIndex(int index);
    Q_INVOKABLE bool setRandomWallpaper();

    Q_INVOKABLE void openFolder();
    Q_INVOKABLE void refreshWallpapers();
    Q_INVOKABLE QString galleryFolderPath() const;

    Q_INVOKABLE QStringList wallpaperNames() const;
    Q_INVOKABLE QStringList wallpaperPaths() const;
    Q_INVOKABLE int currentIndex() const;
    // Absolute path of the wallpaper currently active on the desktop (may live
    // outside the gallery list, e.g. the Windows theme cache).
    Q_INVOKABLE QString currentWallpaperPath() const;

signals:
    void currentWallpaperChanged();
    void wallpapersChanged();
    void selectedIndexChanged();

private:
    QStringList m_names;
    QStringList m_paths;
    QVariantList m_wallpapers;
    int m_currentIndex = -1;
    int m_selectedIndex = 2; // Default to Fall.jpeg (middle item)
    void refreshCurrent();
    void loadDefaultWallpapers();
};
