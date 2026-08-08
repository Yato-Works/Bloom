#include "WorkspaceController.h"

#include "ExperimentalWorkspaceSwitcher.h"
#include "IWorkspaceSwitcher.h"
#include "WorkspaceService.h"
#include <QDebug>

WorkspaceController::WorkspaceController(QObject *parent)
    : QObject(parent)
{
}

WorkspaceController::~WorkspaceController() = default;

void WorkspaceController::setShortcutSwitcher(IWorkspaceSwitcher *switcher)
{
    m_shortcutSwitcher = switcher;
}

void WorkspaceController::setExperimentalSwitcher(ExperimentalWorkspaceSwitcher *switcher)
{
    if (m_experimentalSwitcher == switcher) {
        return;
    }

    if (m_experimentalSwitcher) {
        disconnect(m_experimentalSwitcher, &ExperimentalWorkspaceSwitcher::availabilityChanged,
                   this, &WorkspaceController::availabilityChanged);
    }

    m_experimentalSwitcher = switcher;

    if (m_experimentalSwitcher) {
        m_experimentalAvailable = m_experimentalSwitcher->isAvailable();
        connect(m_experimentalSwitcher, &ExperimentalWorkspaceSwitcher::availabilityChanged,
                this, [this](bool available) {
                    m_experimentalAvailable = available;
                    emit availabilityChanged();
                });
    }
}

void WorkspaceController::setHotkeyService(GlobalHotkeyService *svc)
{
    m_hotkeyService = svc;
}

void WorkspaceController::setWorkspaceService(WorkspaceService *svc)
{
    m_workspaceService = svc;
}

void WorkspaceController::setSwitchingMode(const QString &mode)
{
    if (m_switchingMode == mode) {
        return;
    }

    m_switchingMode = mode;
    emit switchingModeChanged();
    setStatusText(QStringLiteral("Switching mode: %1").arg(mode));
}

void WorkspaceController::switchTo(int index)
{
    if (index < 1 || index > 9) {
        return;
    }

    if (m_state != SwitchingState::Idle) {
        queueRequest(index);
        return;
    }

    executeSwitch(index);
}

void WorkspaceController::switchNext()
{
    const int next = qMin(9, m_currentWorkspace + 1);
    switchTo(next);
}

void WorkspaceController::switchPrevious()
{
    const int prev = qMax(1, m_currentWorkspace - 1);
    switchTo(prev);
}

void WorkspaceController::queueRequest(int target)
{
    m_pendingTarget = target;
    setStatusText(QStringLiteral("Queued: WS %1").arg(target));
}

void WorkspaceController::executeSwitch(int target)
{
    if (target == m_currentWorkspace) {
        return;
    }

    m_state = SwitchingState::Switching;
    m_isSwitching = true;
    m_targetWorkspace = target;
    emit isSwitchingChanged();
    emit targetWorkspaceChanged();
    setStatusText(QStringLiteral("Switching to WS %1...").arg(target));

    if (m_switchingMode == QStringLiteral("experimental") && m_experimentalSwitcher && m_experimentalSwitcher->isAvailable()) {
        SwitchResult result;
        if (trySwitchWith(target, m_experimentalSwitcher, &result)) {
            if (result.completed) {
                finishSwitch(target);
                return;
            }
        }
    }

    if (m_switchingMode == QStringLiteral("automatic")) {
        if (m_experimentalSwitcher && m_experimentalSwitcher->isAvailable()) {
            SwitchResult result;
            if (trySwitchWith(target, m_experimentalSwitcher, &result)) {
                if (result.completed) {
                    finishSwitch(target);
                    return;
                }
                m_state = SwitchingState::FallingBack;
                setStatusText(QStringLiteral("Falling back to standard..."));
            }
        }
    }

    // Standard / fallback
    if (m_shortcutSwitcher) {
        SwitchResult result;
        if (trySwitchWith(target, m_shortcutSwitcher, &result) && result.completed) {
            finishSwitch(target);
            return;
        }
    }

    // If we get here, even fallback failed. Mark idle so next request can proceed.
    m_state = SwitchingState::Idle;
    m_isSwitching = false;
    m_targetWorkspace = 0;
    emit isSwitchingChanged();
    emit targetWorkspaceChanged();
    setStatusText(QStringLiteral("Switch failed"));
}

void WorkspaceController::finishSwitch(int workspace)
{
    m_currentWorkspace = workspace;
    m_isSwitching = false;
    m_state = SwitchingState::Idle;
    m_targetWorkspace = 0;

    emit currentWorkspaceChanged();
    emit isSwitchingChanged();
    emit targetWorkspaceChanged();
    emit switchCompleted(workspace);
    setStatusText(QStringLiteral("WS %1").arg(workspace));

    if (m_pendingTarget > 0 && m_pendingTarget != workspace) {
        const int pending = m_pendingTarget;
        m_pendingTarget = 0;
        executeSwitch(pending);
    }
}

bool WorkspaceController::trySwitchWith(int target, IWorkspaceSwitcher *switcher, SwitchResult *outResult)
{
    if (!switcher || !outResult) {
        return false;
    }

    *outResult = switcher->switchTo(m_currentWorkspace, target);
    if (outResult->fallbackRecommended) {
        m_experimentalAvailable = false;
        emit availabilityChanged();
    }
    return outResult->accepted;
}

void WorkspaceController::setStatusText(const QString &text)
{
    if (m_statusText == text) {
        return;
    }
    m_statusText = text;
    emit statusTextChanged();
}
