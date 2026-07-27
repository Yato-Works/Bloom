#pragma once

#include <QObject>
#include <QString>

class WallpaperService : public QObject
{
    Q_OBJECT
public:
    explicit WallpaperService(QObject *parent = nullptr);

    Q_INVOKABLE bool setWallpaper(const QString &filePath);
};
