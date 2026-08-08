#pragma once

#include "IWorkspaceSwitcher.h"
#include "GlobalHotkeyService.h"
#include <QObject>
#include <QString>

class WorkspaceService;
class ExperimentalWorkspaceSwitcher;

class WorkspaceController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentWorkspace READ currentWorkspace NOTIFY currentWorkspaceChanged FINAL)
    Q_PROPERTY(int targetWorkspace READ targetWorkspace NOTIFY targetWorkspaceChanged FINAL)
    Q_PROPERTY(bool isSwitching READ isSwitching NOTIFY isSwitchingChanged FINAL)
    Q_PROPERTY(QString switchingMode READ switchingMode NOTIFY switchingModeChanged FINAL)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged FINAL)
    Q_PROPERTY(bool experimentalAvailable READ experimentalAvailable NOTIFY availabilityChanged FINAL)
    Q_PROPERTY(bool shortcutAvailable READ shortcutAvailable NOTIFY availabilityChanged FINAL)
public:
    explicit WorkspaceController(QObject *parent = nullptr);
    ~WorkspaceController() override;

    WorkspaceController(const WorkspaceController &) = delete;
    WorkspaceController &operator=(const WorkspaceController &) = delete;

    [[nodiscard]] int currentWorkspace() const { return m_currentWorkspace; }
    [[nodiscard]] int targetWorkspace() const { return m_targetWorkspace; }
    [[nodiscard]] bool isSwitching() const { return m_isSwitching; }
    [[nodiscard]] QString switchingMode() const { return m_switchingMode; }
    [[nodiscard]] QString statusText() const { return m_statusText; }
    [[nodiscard]] bool experimentalAvailable() const { return m_experimentalAvailable; }
    [[nodiscard]] bool shortcutAvailable() const { return m_shortcutAvailable; }

    Q_INVOKABLE void switchTo(int index);
    Q_INVOKABLE void switchNext();
    Q_INVOKABLE void switchPrevious();
    Q_INVOKABLE void setSwitchingMode(const QString &mode);

    void setHotkeyService(GlobalHotkeyService *svc);
    void setWorkspaceService(WorkspaceService *svc);
    void setShortcutSwitcher(IWorkspaceSwitcher *switcher);
    void setExperimentalSwitcher(ExperimentalWorkspaceSwitcher *switcher);

signals:
    void currentWorkspaceChanged();
    void targetWorkspaceChanged();
    void isSwitchingChanged();
    void switchingModeChanged();
    void statusTextChanged();
    void availabilityChanged();
    void switchCompleted(int workspace);

private:
    enum class SwitchingState {
        Idle,
        Switching,
        FallingBack
    };

    void queueRequest(int target);
    void executeSwitch(int target);
    void finishSwitch(int workspace);
    void setStatusText(const QString &text);
    bool trySwitchWith(int target, IWorkspaceSwitcher *switcher, SwitchResult *outResult);

    GlobalHotkeyService *m_hotkeyService = nullptr;
    WorkspaceService *m_workspaceService = nullptr;
    IWorkspaceSwitcher *m_shortcutSwitcher = nullptr;
    ExperimentalWorkspaceSwitcher *m_experimentalSwitcher = nullptr;

    int m_currentWorkspace = 1;
    int m_targetWorkspace = 0;
    int m_pendingTarget = 0;
    bool m_isSwitching = false;
    QString m_switchingMode = QStringLiteral("standard");
    QString m_statusText;

    bool m_experimentalAvailable = false;
    bool m_shortcutAvailable = false;

    SwitchingState m_state = SwitchingState::Idle;
};
