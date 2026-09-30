#pragma once

#include <QObject>
#include <QString>
#include <QTimer>

/// Auto-lock: after `idleTimeoutSeconds` of no mouse/keyboard input the shell
/// locks, and it unlocks only with the configured passcode (tryUnlock).
class LockService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged FINAL)
    Q_PROPERTY(int idleSeconds READ idleSeconds NOTIFY idleTick FINAL)
    Q_PROPERTY(int idleTimeoutSeconds READ idleTimeoutSeconds CONSTANT FINAL)

public:
    explicit LockService(QObject *parent = nullptr);

    [[nodiscard]] bool locked() const noexcept { return m_locked; }
    [[nodiscard]] int idleSeconds() const noexcept { return m_idleSeconds; }
    [[nodiscard]] int idleTimeoutSeconds() const noexcept { return m_idleTimeoutSeconds; }

    Q_INVOKABLE bool tryUnlock(const QString &password);
    Q_INVOKABLE void lockNow();

    void start();

signals:
    void lockedChanged();
    void idleTick();

private:
    void poll();

    QTimer m_timer;
    bool m_locked {false};
    int m_idleSeconds {0};
    const int m_idleTimeoutSeconds {300}; // 5 minutes
    // Default mock passcode (Change to your desired PIN/password)
    const QString m_password {QStringLiteral("1234")};
};
