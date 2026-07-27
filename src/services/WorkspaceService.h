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

class WorkspaceService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged FINAL)
public:
    explicit WorkspaceService(QObject *parent = nullptr);
    ~WorkspaceService() override = default;

    WorkspaceService(const WorkspaceService &) = delete;
    WorkspaceService &operator=(const WorkspaceService &) = delete;

    [[nodiscard]] QString statusText() const { return m_statusText; }
    [[nodiscard]] QStringList workspaceNames() const;

    Q_INVOKABLE bool saveWorkspace(const QString &name);
    Q_INVOKABLE bool restoreWorkspace(const QString &name);
    Q_INVOKABLE bool deleteWorkspace(const QString &name);

signals:
    void statusTextChanged();

private:
    void setStatusText(const QString &text);
    QString storagePath() const;
    QList<WindowRecord> captureWindows() const;
    bool launchAndPosition(const QString &executablePath, const WindowRecord &record) const;
    bool restoreWindow(const WindowRecord &record) const;

    QString m_statusText;
    QMap<QString, QList<WindowRecord>> m_workspaces;
};
