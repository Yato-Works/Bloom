#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <QRect>

class QQuickWindow;

/// Hold-to-arm desktop shell (Bloom style).
/// Default chord: Ctrl + Win (A2). Release always disarms (B1).
/// State machine: Idle -> Armed (dim only) -> Latched (panel sticky) -> Armed -> Idle
class ShellController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool armed READ isArmed NOTIFY armedChanged FINAL)
    Q_PROPERTY(bool locked READ isLocked WRITE setLocked NOTIFY lockedChanged FINAL)
    Q_PROPERTY(bool forceArmed READ forceArmed WRITE setForceArmed NOTIFY forceArmedChanged FINAL)
    Q_PROPERTY(qreal dimOpacity READ dimOpacity NOTIFY armedChanged FINAL)
    Q_PROPERTY(int hitZoneSize READ hitZoneSize CONSTANT FINAL)
    Q_PROPERTY(QString holdHint READ holdHint CONSTANT FINAL)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged FINAL)

    // Panel side enumeration for QML interop
    enum class PanelSide { None, Top, Bottom, Left, Right };
    Q_ENUM(PanelSide)

    // Keyboard navigation direction
    enum class NavDirection { Next, Prev, Select, Cancel };
    Q_ENUM(NavDirection)

public:
    explicit ShellController(QObject *parent = nullptr);

    [[nodiscard]] bool isArmed() const noexcept { return m_armed; }
    [[nodiscard]] bool isLocked() const noexcept { return m_locked; }
    [[nodiscard]] bool forceArmed() const noexcept { return m_forceArmed; }
    [[nodiscard]] bool isLatched() const noexcept { return m_latched; }
    [[nodiscard]] PanelSide latchedSide() const noexcept { return m_latchedSide; }

    void setLocked(bool locked);
    void setForceArmed(bool forceArmed);
    Q_INVOKABLE void armPermanent(bool armed);
    Q_INVOKABLE void toggleLock();
    Q_INVOKABLE void disarm();
    Q_INVOKABLE void dismiss();

    // State-dependent dim opacity:
    // Armed (dim only) = 0.12, Latched (panel open) = 0.18, Locked = 0.22
    [[nodiscard]] qreal dimOpacity() const noexcept;
    [[nodiscard]] int hitZoneSize() const noexcept { return 16; }
    [[nodiscard]] QString holdHint() const;
    [[nodiscard]] QString statusText() const { return m_statusText; }

    // Cursor enter/leave notifications from QML hit zones & panels
    Q_INVOKABLE void notifyCursorEnter(PanelSide side);
    Q_INVOKABLE void notifyCursorLeave(PanelSide side);

    // Keyboard navigation (Tab/Shift+Tab/Enter/Esc)
    Q_INVOKABLE void navigatePanel(NavDirection dir);

    void setWindow(QQuickWindow *window);
    void start();
    void stop();

signals:
    void armedChanged();
    void lockedChanged();
    void forceArmedChanged();
    void statusTextChanged();

private:
    void poll();
    void setArmed(bool armed);
    void applyWindowGeometry();
    [[nodiscard]] bool isHoldChordDown() const;

    // Latch logic
    void tryLatch(PanelSide side);
    void tryUnlatch();
    void updateExtendedHitRect(PanelSide side);
    [[nodiscard]] bool isCursorInExtendedHitRect() const;
    [[nodiscard]] QRect getPanelGeometry(PanelSide side) const;
    [[nodiscard]] QRect getHitZoneGeometry(PanelSide side) const;

    QQuickWindow *m_window = nullptr;
    QTimer m_pollTimer;
    QTimer m_leaveGraceTimer;          // 120ms grace after cursor leaves extended hit rect

    // State
    bool m_armed {false};              // Dim showing (key held or latched)
    bool m_locked {false};             // Win+Ctrl+Space lock
    bool m_forceArmed {false};         // Programmatic arm (launcher, calc, etc.)
    bool m_latched {false};            // Panel is sticky-open
    PanelSide m_latchedSide {PanelSide::None};  // Which panel is latched
    bool m_spaceWasPressed {false};
    bool m_chordWasDown {false};
    QString m_statusText;

    // Geometry for leave detection
    QRect m_extendedHitRect;           // Union of hitZone + panel + margin
};
