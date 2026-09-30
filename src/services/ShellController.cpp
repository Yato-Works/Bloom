#include "ShellController.h"

#include <QCursor>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>
#include <QQuickItem>

#ifdef Q_OS_WIN
#  include <windows.h>
#endif

ShellController::ShellController(QObject *parent)
    : QObject(parent)
{
    m_pollTimer.setInterval(20);
    connect(&m_pollTimer, &QTimer::timeout, this, &ShellController::poll);

    // Leave grace timer: 350ms after cursor leaves extended hit rect
    m_leaveGraceTimer.setSingleShot(true);
    m_leaveGraceTimer.setInterval(350);
    connect(&m_leaveGraceTimer, &QTimer::timeout, this, &ShellController::tryUnlatch);

    m_statusText = QStringLiteral("Hold %1 · edge to open widgets").arg(holdHint());
}

// ===== Public getters =====

qreal ShellController::dimOpacity() const noexcept
{
    if (m_locked) return 0.22;        // Locked: slightly more visible
    if (m_latched) return 0.18;       // Latched (panel open)
    if (m_armed) return 0.12;         // Armed only (dim, no panel)
    return 0.0;                       // Idle
}
QString ShellController::holdHint() const
{
    return QStringLiteral("Ctrl + Win");
}

// ===== Public API =====

void ShellController::setWindow(QQuickWindow *window)
{
    m_window = window;
    if (m_window) {
        setArmed(m_forceArmed || m_locked || m_latched || isHoldChordDown());
    }
}

void ShellController::start()
{
    if (!m_pollTimer.isActive()) {
        m_pollTimer.start();
    }
}

void ShellController::stop()
{
    m_pollTimer.stop();
    m_leaveGraceTimer.stop();
    setArmed(false);
    m_latched = false;
    m_latchedSide = PanelSide::None;
}

void ShellController::setLocked(bool locked)
{
    if (m_locked == locked) {
        return;
    }
    m_locked = locked;
    emit lockedChanged();

    if (m_locked) {
        // Lock overrides latch - panel stays open
        m_latched = true;
    } else {
        // Unlock: go back to armed if chord held, else idle
        m_latched = m_forceArmed || isHoldChordDown();
        if (!m_latched) m_latchedSide = PanelSide::None;
    }
    setArmed(m_forceArmed || m_locked || m_latched || isHoldChordDown());
    emit armedChanged(); // triggers dimOpacity update
}

void ShellController::setForceArmed(bool forceArmed)
{
    if (m_forceArmed == forceArmed) {
        return;
    }
    m_forceArmed = forceArmed;
    emit forceArmedChanged();

    // Force arm can trigger latch if cursor already in zone
    const bool shouldBeArmed = m_forceArmed || m_locked || m_latched || isHoldChordDown();
    setArmed(shouldBeArmed);
    emit armedChanged();
}

void ShellController::armPermanent(bool armed)
{
    setForceArmed(armed);
}

void ShellController::setLockScreenActive(bool active)
{
    if (m_lockScreenActive == active) {
        return;
    }
    m_lockScreenActive = active;
    if (active) {
        // Force the host window up so the lock overlay has a surface. The
        // lock overlay itself sits above everything in QML; the shell's own
        // latch state is left untouched.
        setForceArmed(true);
        setArmed(true);
    }
}

void ShellController::disarm()
{
    setForceArmed(false);
    setLocked(false);
}

void ShellController::dismiss()
{
    setForceArmed(false);
    setLocked(false);
    // Dismiss also clears latch immediately
    if (m_latched) {
        m_latched = false;
        m_latchedSide = PanelSide::None;
        m_leaveGraceTimer.stop();
        emit armedChanged();
    }
}

void ShellController::triggerLauncher()
{
    armPermanent(true);
    emit requestShowLauncher();
}

void ShellController::toggleLock()
{
    setLocked(!m_locked);
}

// ===== Cursor notifications from QML =====

void ShellController::notifyCursorEnter(PanelSide side)
{
    if (!m_armed || m_locked) return;           // Only latch in Armed state (not Locked)
    if (m_latched && m_latchedSide != side) return; // Already latched to another side

    // Cancel any pending leave grace
    m_leaveGraceTimer.stop();

    // Update extended hit rect for this panel (hitZone + panel + margin)
    updateExtendedHitRect(side);

    // Try to latch
    tryLatch(side);
}

void ShellController::notifyCursorLeave(PanelSide side)
{
    if (!m_latched || m_latchedSide != side) return; // Only care if we're latched to this side

    // Start grace timer - if cursor re-enters within 120ms, timer cancels
    if (!m_leaveGraceTimer.isActive()) {
        m_leaveGraceTimer.start();
    }
}

// ===== Keyboard navigation =====

void ShellController::navigatePanel(NavDirection dir)
{
    if (!m_armed && !m_latched) return; // Only works when shell is active

    using PD = PanelSide;
    static const std::array<PD, 4> order = { PD::Top, PD::Right, PD::Bottom, PD::Left };

    auto findIndex = [&](PD side) -> int {
        for (int i = 0; i < 4; ++i) if (order[i] == side) return i;
        return -1;
    };

    int currentIdx = -1;
    if (m_latched) {
        currentIdx = findIndex(m_latchedSide);
    }

    PD targetSide = PD::None;

    switch (dir) {
    case NavDirection::Next: {
        int nextIdx = (currentIdx + 1) % 4;
        targetSide = order[nextIdx];
        break;
    }
    case NavDirection::Prev: {
        int prevIdx = (currentIdx - 1 + 4) % 4;
        targetSide = order[prevIdx];
        break;
    }
    case NavDirection::Select: {
        if (m_latched) {
            // Already latched - this would focus inside panel (handled by QML focus)
            // For now, just ensure we're armed
            setForceArmed(true);
        } else if (currentIdx >= 0) {
            // Latch the currently focused panel
            tryLatch(order[currentIdx]);
        }
        return;
    }
    case NavDirection::Cancel: {
        // Full dismiss to Idle
        dismiss();
        return;
    }
    }

    if (targetSide != PD::None) {
        if (m_latched) {
            // Move latch to adjacent panel
            tryLatch(targetSide);
        } else {
            // Armed but not latched - just set focus indicator (visual only)
            // Could add a "focusedSide" property for visual feedback
        }
    }
}

// ===== Private: Latch logic =====

void ShellController::tryLatch(PanelSide side)
{
    if (m_latched && m_latchedSide == side) return; // Already latched here

    m_latched = true;
    m_latchedSide = side;
    m_leaveGraceTimer.stop(); // Cancel any pending unlatch

    emit armedChanged(); // Triggers dimOpacity update + QML bindings re-evaluate

    // Status text update
    static const QMap<PanelSide, QString> names = {
        { PanelSide::Top,    QStringLiteral("Top panel latched") },
        { PanelSide::Bottom, QStringLiteral("Bottom panel latched") },
        { PanelSide::Left,   QStringLiteral("Left drawer latched") },
        { PanelSide::Right,  QStringLiteral("Right drawer latched") }
    };
    m_statusText = names.value(side, QStringLiteral("Panel latched"));
    emit statusTextChanged();
}

void ShellController::tryUnlatch()
{
    // Double-check cursor is actually outside extended hit rect
    if (isCursorInExtendedHitRect()) {
        // Cursor came back - cancel unlatch
        return;
    }

    m_latched = false;
    m_latchedSide = PanelSide::None;
    m_leaveGraceTimer.stop();

    // If still armed (key held or forceArmed), stay armed; else go idle
    const bool shouldStayArmed = m_forceArmed || m_locked || isHoldChordDown();
    setArmed(shouldStayArmed);

    emit armedChanged(); // Triggers dimOpacity + panel close

    m_statusText = QStringLiteral("Hold %1 · edge to open widgets").arg(holdHint());
    emit statusTextChanged();
}

void ShellController::updateExtendedHitRect(PanelSide side)
{
    if (!m_window) return;

    QRect panelRect = getPanelGeometry(side);
    QRect hitRect = getHitZoneGeometry(side);

    // Margin: 12px default, 20px for Bottom (launcher)
    int margin = (side == PanelSide::Bottom) ? 20 : 12;

    QRect united = panelRect.united(hitRect);
    m_extendedHitRect = united.marginsAdded(QMargins(margin, margin, margin, margin));
}

bool ShellController::isCursorInExtendedHitRect() const
{
    if (m_extendedHitRect.isNull()) return false;

    QPoint globalPos = QCursor::pos();
    // Map to window coordinates if needed (window covers full screen anyway)
    return m_extendedHitRect.contains(globalPos);
}

QRect ShellController::getPanelGeometry(PanelSide side) const
{
    if (!m_window) return QRect();

    // Panels are QML items; we need to ask QML for their geometry.
    // For now, estimate based on known sizes and window geometry.
    // TODO: Could expose panel geometry from QML via properties.
    QRect winGeo = m_window->geometry();
    int hz = hitZoneSize();

    switch (side) {
    case PanelSide::Top: {
        // TopShellPanel: compact 52px, expanded ~310px, centered horizontally
        int panelW = qMin(int(winGeo.width() * 0.92), 1080);
        int panelH = 310; // expanded height estimate
        int x = winGeo.left() + (winGeo.width() - panelW) / 2;
        int y = winGeo.top() + 10; // topMargin
        return QRect(x, y, panelW, panelH);
    }
    case PanelSide::Bottom: {
        // BottomShellPanel: up to 310px, centered, attached to bottom
        int panelW = qMin(int(winGeo.width() * 0.92), 1060);
        int panelH = 310;
        int x = winGeo.left() + (winGeo.width() - panelW) / 2;
        int y = winGeo.bottom() - panelH; // anchored to bottom
        return QRect(x, y, panelW, panelH);
    }
    case PanelSide::Left: {
        // LeftDrawer: full height, ~280px wide
        return QRect(winGeo.left(), winGeo.top(), 280, winGeo.height());
    }
    case PanelSide::Right: {
        // RightDrawer: full height, ~280px wide
        return QRect(winGeo.right() - 280, winGeo.top(), 280, winGeo.height());
    }
    default:
        return QRect();
    }
}

QRect ShellController::getHitZoneGeometry(PanelSide side) const
{
    if (!m_window) return QRect();

    QRect winGeo = m_window->geometry();
    int hz = hitZoneSize();

    switch (side) {
    case PanelSide::Top:
        return QRect(winGeo.left(), winGeo.top(), winGeo.width(), hz);
    case PanelSide::Bottom:
        return QRect(winGeo.left(), winGeo.bottom() - hz, winGeo.width(), hz);
    case PanelSide::Left:
        return QRect(winGeo.left(), winGeo.top(), hz, winGeo.height());
    case PanelSide::Right:
        return QRect(winGeo.right() - hz, winGeo.top(), hz, winGeo.height());
    default:
        return QRect();
    }
}

// ===== Poll loop =====

bool ShellController::isHoldChordDown() const
{
#ifdef Q_OS_WIN
    const bool ctrl = ((GetAsyncKeyState(VK_CONTROL) & 0x8000) != 0)
                   || ((GetAsyncKeyState(VK_LCONTROL) & 0x8000) != 0)
                   || ((GetAsyncKeyState(VK_RCONTROL) & 0x8000) != 0);
    const bool win = ((GetAsyncKeyState(VK_LWIN) & 0x8000) != 0)
                  || ((GetAsyncKeyState(VK_RWIN) & 0x8000) != 0);

    return ctrl && win;
#else
    return false;
#endif
}

void ShellController::poll()
{
    const bool chord = isHoldChordDown();
#ifdef Q_OS_WIN
    const bool space = (GetAsyncKeyState(VK_SPACE) & 0x8000) != 0;
#else
    const bool space = false;
#endif

    // Win+Ctrl+Space -> toggle lock
    if (chord && space && !m_spaceWasPressed) {
        toggleLock();
    }
    m_spaceWasPressed = space;

    // Chord press/release handling
    if (chord && !m_chordWasDown) {
        // Chord just pressed
        if (m_armed && !m_latched) {
            // Armed but not latched -> toggle off (press again to dismiss)
            setForceArmed(false);
        } else if (!m_armed) {
            // Fresh arm
            setForceArmed(true);
        }
        // If already latched, chord press does nothing (stay latched)
    }
    m_chordWasDown = chord;

    // Global bottom-edge cursor auto-summon:
    // When the user moves the cursor to the bottom edge of the screen, auto-summon the launcher.
#ifdef Q_OS_WIN
    POINT pt;
    if (GetCursorPos(&pt)) {
        QScreen *screen = QGuiApplication::screenAt(QPoint(pt.x, pt.y));
        if (!screen) screen = QGuiApplication::primaryScreen();
        if (screen) {
            const QRect geom = screen->geometry();
            // Trigger when cursor hits within 4px of the screen bottom, avoiding corners
            const bool atBottomEdge = (pt.y >= geom.bottom() - 4)
                                   && (pt.x >= geom.left() + 40)
                                   && (pt.x <= geom.right() - 40);

            if (atBottomEdge) {
                m_bottomHoverTicks++;
                if (m_bottomHoverTicks >= 3) { // ~60ms of resting at bottom edge
                    if (!m_armed || !m_forceArmed) {
                        armPermanent(true);
                        emit requestShowLauncher();
                    }
                    m_bottomHoverTicks = 0;
                }
            } else {
                m_bottomHoverTicks = 0;
            }
        }
    }
#endif

    // Determine armed state: programmatic arm (launcher / lock screen / panel
    // pin), the overlay lock, a latched panel, or the Ctrl+Win chord.
    const bool shouldBeArmed = m_forceArmed || m_locked || m_latched || chord;
    setArmed(shouldBeArmed);
}

void ShellController::setArmed(bool armed)
{
    if (m_armed == armed) {
        return;
    }

    m_armed = armed;
    emit armedChanged();

    if (!m_window) {
        return;
    }

    if (m_armed) {
        applyWindowGeometry();
        m_window->show();
        m_window->raise();
        m_window->requestActivate();
    } else {
        m_window->hide();
    }
}

void ShellController::applyWindowGeometry()
{
    if (!m_window) {
        return;
    }

    QScreen *screen = QGuiApplication::screenAt(QCursor::pos());
    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }
    if (!screen) {
        return;
    }

    // Cover the monitor under the cursor (virtual desktop coords).
    m_window->setGeometry(screen->geometry());
}
