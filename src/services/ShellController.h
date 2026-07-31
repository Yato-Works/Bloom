#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

class QQuickWindow;

/// Hold-to-arm desktop shell (Caelestia-like).
/// Default chord: Ctrl + Win (A2). Release always disarms (B1).
class ShellController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool armed READ isArmed NOTIFY armedChanged FINAL)
    Q_PROPERTY(bool locked READ isLocked WRITE setLocked NOTIFY lockedChanged FINAL)
    Q_PROPERTY(qreal dimOpacity READ dimOpacity CONSTANT FINAL)
    Q_PROPERTY(int hitZoneSize READ hitZoneSize CONSTANT FINAL)
    Q_PROPERTY(QString holdHint READ holdHint CONSTANT FINAL)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged FINAL)

public:
    explicit ShellController(QObject *parent = nullptr);

    [[nodiscard]] bool isArmed() const noexcept { return m_armed; }
    [[nodiscard]] bool isLocked() const noexcept { return m_locked; }
    void setLocked(bool locked);
    Q_INVOKABLE void toggleLock();
    [[nodiscard]] qreal dimOpacity() const noexcept { return 0.22; }
    [[nodiscard]] int hitZoneSize() const noexcept { return 16; }
    [[nodiscard]] QString holdHint() const;
    [[nodiscard]] QString statusText() const { return m_statusText; }

    void setWindow(QQuickWindow *window);
    void start();
    void stop();

    /// Optional alternate chord (Win+Shift). Off by default (A2).
    Q_INVOKABLE void setUseWinShift(bool enabled);
    [[nodiscard]] Q_INVOKABLE bool useWinShift() const noexcept { return m_useWinShift; }

signals:
    void armedChanged();
    void lockedChanged();
    void statusTextChanged();

private:
    void poll();
    void setArmed(bool armed);
    void applyWindowGeometry();
    [[nodiscard]] bool isHoldChordDown() const;

    QQuickWindow *m_window = nullptr;
    QTimer m_pollTimer;
    bool m_armed {false};
    bool m_locked {false};
    bool m_useWinShift {false};
    QString m_statusText;
};
