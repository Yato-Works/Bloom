#pragma once

#include <QObject>
#include <QTimer>
#include <QString>

class MusicControlService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString artistName READ artistName NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int position READ position NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int duration READ duration NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString sourceApp READ sourceApp NOTIFY trackInfoChanged FINAL)

public:
    explicit MusicControlService(QObject *parent = nullptr);
    ~MusicControlService() override;

    [[nodiscard]] QString trackTitle() const noexcept { return m_trackTitle; }
    [[nodiscard]] QString artistName() const noexcept { return m_artistName; }
    [[nodiscard]] bool isPlaying() const noexcept { return m_isPlaying; }
    [[nodiscard]] int position() const noexcept { return m_position; }
    [[nodiscard]] int duration() const noexcept { return m_duration; }
    [[nodiscard]] QString sourceApp() const noexcept { return m_sourceApp; }

    Q_INVOKABLE void playPause();
    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();

    void start();

signals:
    void trackInfoChanged();

private:
    void refresh();

    QTimer m_refreshTimer;
    QString m_trackTitle;
    QString m_artistName;
    bool m_isPlaying {false};
    int m_position {0};
    int m_duration {0};
    QString m_sourceApp;
};
