#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QString>
#include <QVariant>

class QJsonObject;

/// Now-playing service.
///
/// Primary source: the Windows GSMTC (Global System Media Transport Controls)
/// session manager — the same API yasb's media widget uses through PyWinRT —
/// polled by a bundled Windows PowerShell 5.1 helper that streams JSON lines
/// back to this process. When the helper is unavailable the service falls
/// back to window-title heuristics so the shell still shows something.
class MusicControlService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString trackTitle READ trackTitle NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString artistName READ artistName NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int position READ position NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int length READ length NOTIFY trackInfoChanged FINAL)
    // Continuous playback fraction (0..1). The SMTC helper only reports a new
    // position every ~0.5 s, so this value is interpolated at 30 fps between
    // reports — UI progress bars/rings glide instead of stepping.
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged FINAL)
    Q_PROPERTY(QString sourceApp READ sourceApp NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(QString thumbnailSource READ thumbnailSource NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canSeek READ canSeek NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool positionSupported READ positionSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canGoPrevious READ canGoPrevious NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canGoNext READ canGoNext NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool canTogglePlaying READ canTogglePlaying NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool shuffleSupported READ shuffleSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool shuffle READ shuffle WRITE setShuffle NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(bool loopSupported READ loopSupported NOTIFY trackInfoChanged FINAL)
    Q_PROPERTY(int loopState READ loopState WRITE setLoopState NOTIFY trackInfoChanged FINAL)

public:
    enum LoopState { None = 0, Track = 1, Playlist = 2 };
    Q_ENUM(LoopState)

    explicit MusicControlService(QObject *parent = nullptr);
    ~MusicControlService() override;

    [[nodiscard]] QString trackTitle() const noexcept { return m_trackTitle; }
    [[nodiscard]] QString artistName() const noexcept { return m_artistName; }
    [[nodiscard]] bool isPlaying() const noexcept { return m_isPlaying; }
    [[nodiscard]] int position() const noexcept { return m_position; }
    [[nodiscard]] int length() const noexcept { return m_length; }
    [[nodiscard]] qreal progress() const noexcept { return m_progress; }
    [[nodiscard]] QString sourceApp() const noexcept { return m_sourceApp; }
    // Album art as a data: URL (empty when the session has no thumbnail).
    [[nodiscard]] QString thumbnailSource() const noexcept { return m_thumbnailSource; }
    [[nodiscard]] bool canSeek() const noexcept { return m_canSeek; }
    [[nodiscard]] bool positionSupported() const noexcept { return m_positionSupported; }
    [[nodiscard]] bool canGoPrevious() const noexcept { return m_canGoPrevious; }
    [[nodiscard]] bool canGoNext() const noexcept { return m_canGoNext; }
    [[nodiscard]] bool canTogglePlaying() const noexcept { return m_canTogglePlaying; }
    [[nodiscard]] bool shuffleSupported() const noexcept { return m_shuffleSupported; }
    [[nodiscard]] bool shuffle() const noexcept { return m_shuffle; }
    void setShuffle(bool s) { m_shuffle = s; emit trackInfoChanged(); }
    [[nodiscard]] bool loopSupported() const noexcept { return m_loopSupported; }
    [[nodiscard]] int loopState() const noexcept { return m_loopState; }
    void setLoopState(int s) { m_loopState = s; emit trackInfoChanged(); }

    Q_INVOKABLE void playPause();
    Q_INVOKABLE void togglePlayPause();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void positionChanged();

    void start();

signals:
    void trackInfoChanged();
    void progressChanged();

private:
    void refresh();                                    // Fallback heuristics (SMTC off)
    void advanceProgress();                            // 30 fps interpolation tick
    void resyncProgress(qreal reportedSeconds);        // Snap when truth drifts
    void startSmtcHelper();                            // Write + launch the PS 5.1 helper
    void handleSmtcOutput();                           // Parse JSON lines from the helper
    void applySmtcState(const QJsonObject &state);     // Turn a JSON snapshot into properties

    QTimer m_refreshTimer;
    QTimer m_progressTimer;                            // 30 fps progress interpolation
    QProcess m_smtcProcess;
    QTimer m_smtcRestartTimer;                         // Backs off and respawns the helper
    QByteArray m_smtcBuffer;
    bool m_smtcActive {false};                         // Helper has produced valid data
    bool m_stopping {false};
    QString m_thumbnailSource;
    QString m_trackTitle;
    QString m_artistName;
    bool m_isPlaying {false};
    int m_position {0};
    int m_length {0};
    qreal m_progress {0.0};                            // Smoothed playback fraction
    QString m_sourceApp;
    bool m_canSeek {true};
    bool m_positionSupported {true};
    bool m_canGoPrevious {true};
    bool m_canGoNext {true};
    bool m_canTogglePlaying {true};
    bool m_shuffleSupported {false};
    bool m_shuffle {false};
    bool m_loopSupported {false};
    int m_loopState {None};
};
