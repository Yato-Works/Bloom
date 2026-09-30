#include "LockService.h"

#include <QDebug>

#ifdef Q_OS_WIN
#  include <windows.h>
#endif

LockService::LockService(QObject *parent)
    : QObject(parent)
    , m_idleTimeoutSeconds([]() -> int {
        // Debug hook: BLOOM_IDLE_TIMEOUT overrides the 5-minute auto-lock.
        const int env = qEnvironmentVariableIntValue("BLOOM_IDLE_TIMEOUT");
        return env > 0 ? env : 300;
    }())
{
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &LockService::poll);
}

void LockService::start()
{
    poll();
    m_timer.start();
}

void LockService::poll()
{
#ifdef Q_OS_WIN
    LASTINPUTINFO info {};
    info.cbSize = sizeof(LASTINPUTINFO);
    if (GetLastInputInfo(&info)) {
        m_idleSeconds = static_cast<int>((GetTickCount64() - info.dwTime) / 1000);
    }
#endif

    emit idleTick();

    const bool autoLockEnabled = qEnvironmentVariableIntValue("BLOOM_AUTO_LOCK") == 1;
    if (autoLockEnabled && !m_locked && m_idleSeconds >= m_idleTimeoutSeconds) {
        m_locked = true;
        qDebug() << "LockService: idle for" << m_idleSeconds << "s - locking";
        emit lockedChanged();
    }
}

bool LockService::tryUnlock(const QString &password)
{
    if (!m_locked) {
        return true;
    }
    if (password.trimmed() == m_password) {
        m_locked = false;
        qDebug() << "LockService: unlocked";
        emit lockedChanged();
        return true;
    }
    return false;
}

void LockService::lockNow()
{
    if (!m_locked) {
        m_locked = true;
        emit lockedChanged();
    }
}
