#include "ShellController.h"

#include <QCursor>
#include <QGuiApplication>
#include <QQuickWindow>
#include <QScreen>

#ifdef Q_OS_WIN
#  include <windows.h>
#endif

ShellController::ShellController(QObject *parent)
    : QObject(parent)
{
    m_pollTimer.setInterval(20);
    connect(&m_pollTimer, &QTimer::timeout, this, &ShellController::poll);
    m_statusText = QStringLiteral("Hold %1 · edge to open widgets").arg(holdHint());
}

QString ShellController::holdHint() const
{
    return m_useWinShift ? QStringLiteral("Win + Shift") : QStringLiteral("Ctrl + Win");
}

void ShellController::setWindow(QQuickWindow *window)
{
    m_window = window;
    if (m_window && !m_armed) {
        m_window->hide();
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
    setArmed(false);
}

void ShellController::setUseWinShift(bool enabled)
{
    if (m_useWinShift == enabled) {
        return;
    }
    m_useWinShift = enabled;
    m_statusText = QStringLiteral("Hold %1 · edge to open widgets").arg(holdHint());
    emit statusTextChanged();
}

bool ShellController::isHoldChordDown() const
{
#ifdef Q_OS_WIN
    const bool ctrl = (GetAsyncKeyState(VK_LCONTROL) & 0x8000)
                   || (GetAsyncKeyState(VK_RCONTROL) & 0x8000);
    const bool shift = (GetAsyncKeyState(VK_LSHIFT) & 0x8000)
                    || (GetAsyncKeyState(VK_RSHIFT) & 0x8000);
    const bool win = (GetAsyncKeyState(VK_LWIN) & 0x8000)
                  || (GetAsyncKeyState(VK_RWIN) & 0x8000);

    if (m_useWinShift) {
        return win && shift;
    }
    return ctrl && win;
#else
    return false;
#endif
}

void ShellController::poll()
{
    setArmed(isHoldChordDown());
}

void ShellController::setLocked(bool locked)
{
    if (m_locked == locked) {
        return;
    }
    m_locked = locked;
    emit lockedChanged();
}

void ShellController::toggleLock()
{
    setLocked(!m_locked);
}

void ShellController::setArmed(bool armed)
{
    if (m_armed == armed) {
        return;
    }

    m_armed = armed;
    if (!m_armed) {
        setLocked(false);
    }
    emit armedChanged();

    if (!m_window) {
        return;
    }

    if (m_armed) {
        applyWindowGeometry();
        m_window->show();
        m_window->raise();
        // Receive mouse for dim + hit zones; keyboard focus is fine while holding.
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
