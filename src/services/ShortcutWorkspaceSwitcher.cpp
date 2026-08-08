#include "ShortcutWorkspaceSwitcher.h"

#include "GlobalHotkeyService.h"
#include <QDebug>

ShortcutWorkspaceSwitcher::ShortcutWorkspaceSwitcher(QObject *parent)
    : QObject(parent)
{
}

ShortcutWorkspaceSwitcher::~ShortcutWorkspaceSwitcher() = default;

bool ShortcutWorkspaceSwitcher::initialize()
{
    m_available = false;
    return true;
}

void ShortcutWorkspaceSwitcher::setHotkeyService(GlobalHotkeyService *svc)
{
    m_hotkeyService = svc;
}

SwitchResult ShortcutWorkspaceSwitcher::switchTo(int currentWorkspace, int targetWorkspace)
{
    Q_UNUSED(currentWorkspace)
    SwitchResult result;
    result.accepted = true;
    result.completed = false;

    if (!m_hotkeyService) {
        result.errorCode = QStringLiteral("SWITCHER_NOT_AVAILABLE");
        return result;
    }

    const int delta = targetWorkspace - currentWorkspace;
    if (delta == 0) {
        result.completed = true;
        return result;
    }

    const bool forward = delta > 0;
    const int count = qAbs(delta);
    GlobalHotkeyService::injectNativeArrowSwitches(forward, count);
    result.completed = true;
    result.accepted = true;
    return result;
}

void ShortcutWorkspaceSwitcher::shutdown()
{
    m_available = false;
}
