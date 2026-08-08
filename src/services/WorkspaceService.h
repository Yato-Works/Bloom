#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QMap>

struct WindowRecord {
    QString title;
    QString executablePath;
    int left = 0;
    int top = 0;
    int right = 0;
    int bottom = 0;
    bool maximized = false;
};

/// Workspace tracking + app registry.
///
/// Two responsibilities:
///  1. (legacy) Named window-snapshot save/restore (saveWorkspace / restoreWorkspace).
///  2. (new, P1) Virtual-desktop app tracking: records which applications are
///     open on the *current* virtual desktop and persists them to a JSON file.
///     The "current workspace" is driven by shortcuts captured by
///     GlobalHotkeyService (Ctrl+Win+Arrow / Ctrl+Win+1..9), so Bloom never
///     polls the system state - it reacts to the entry point it controls.
///     App launch/close is observed via a native shell hook (RegisterShellHookWindow)
///     delivered to a message-only window, so no polling is used there either.
class WorkspaceService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged FINAL)
    Q_PROPERTY(int currentWorkspace READ currentWorkspace WRITE setCurrentWorkspace NOTIFY currentWorkspaceChanged FINAL)
    Q_PROPERTY(QStringList workspaceApps READ workspaceApps NOTIFY workspaceAppsChanged FINAL)
public:
    explicit WorkspaceService(QObject *parent = nullptr);
    ~WorkspaceService() override;

    WorkspaceService(const WorkspaceService &) = delete;
    WorkspaceService &operator=(const WorkspaceService &) = delete;

    [[nodiscard]] QString statusText() const { return m_statusText; }
    [[nodiscard]] QStringList workspaceNames() const;

    Q_INVOKABLE bool saveWorkspace(const QString &name);
    Q_INVOKABLE bool restoreWorkspace(const QString &name);
    Q_INVOKABLE bool deleteWorkspace(const QString &name);

    // ---- P1: virtual-desktop app tracking ----
    [[nodiscard]] int currentWorkspace() const { return m_currentWorkspace; }
    void setCurrentWorkspace(int index);

    [[nodiscard]] QStringList workspaceApps() const;                 // apps on current workspace
    [[nodiscard]] QStringList appsOnWorkspace(int index) const;      // 1-based workspace index

    void switchToNext();
    void switchToPrevious();
    void jumpTo(int index);                                          // 1-based

    // Register a shell hook so app launch/close updates the map.
    bool startTracking();
    void stopTracking();

    // Internal callback invoked by the native shell-hook window procedure.
    void handleShellEvent(unsigned int code, void *hwnd);

signals:
    void statusTextChanged();
    void currentWorkspaceChanged();
    void workspaceAppsChanged();

private:
    void setStatusText(const QString &text);

    // legacy snapshot support
    QString storagePath() const;
    QList<WindowRecord> captureWindows() const;
    bool launchAndPosition(const QString &executablePath, const WindowRecord &record) const;
    bool restoreWindow(const WindowRecord &record) const;

    // P1 app tracking
    QString jsonPath() const;
    void loadFromJson();
    void saveToJson() const;
    void addCurrentApp(const QString &exe);
    void removeCurrentApp(const QString &exe);

    void *createHookWindow();

    QString m_statusText;
    QMap<QString, QList<WindowRecord>> m_workspaces;

    // P1 state
    int m_currentWorkspace = 1;
    QMap<int, QStringList> m_workspaceApps;
    void *m_hookWindow = nullptr;
};
