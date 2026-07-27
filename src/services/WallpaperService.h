#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class WallpaperService : public QObject
{
    Q_OBJECT
public:
    explicit WallpaperService(QObject *parent = nullptr);

    Q_INVOKABLE bool setWallpaper(const QString &filePath);
    Q_INVOKABLE bool setWallpaperByIndex(int index);

    Q_INVOKABLE QStringList wallpaperNames() const;
    Q_INVOKABLE QStringList wallpaperPaths() const;
    Q_INVOKABLE int currentIndex() const;

signals:
    void currentWallpaperChanged();

private:
    QStringList m_names;
    QStringList m_paths;
    int m_currentIndex = -1;
    void refreshCurrent();
};
