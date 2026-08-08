#pragma once

#include "IWorkspaceSwitcher.h"
#include <QObject>
#include <QString>

class GlobalHotkeyService;

class ShortcutWorkspaceSwitcher final : public QObject, public IWorkspaceSwitcher
{
    Q_OBJECT
public:
    explicit ShortcutWorkspaceSwitcher(QObject *parent = nullptr);
    ~ShortcutWorkspaceSwitcher() override;

    bool initialize() override;
    bool isAvailable() const override { return m_available; }
    SwitchResult switchTo(int currentWorkspace, int targetWorkspace) override;
    void shutdown() override;

    void setHotkeyService(GlobalHotkeyService *svc);
    void setKeyIntervalMs(int ms) { m_keyIntervalMs = ms; }
    int keyIntervalMs() const { return m_keyIntervalMs; }

private:
    GlobalHotkeyService *m_hotkeyService = nullptr;
    bool m_available = false;
    int m_keyIntervalMs = 60;
};
