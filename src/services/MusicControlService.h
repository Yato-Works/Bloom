#pragma once

#include <QObject>

class MusicControlService final : public QObject
{
    Q_OBJECT
public:
    explicit MusicControlService(QObject *parent = nullptr);
    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
};
