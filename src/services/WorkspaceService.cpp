#include "WorkspaceService.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QStandardPaths>

#ifdef Q_OS_WIN
#  include <qt_windows.h>
#  include <shellapi.h>
#endif

WorkspaceService::WorkspaceService(QObject *parent)
    : QObject(parent)
{
    setStatusText(QStringLiteral("Ready"));
}

QString WorkspaceService::storagePath() const
{
    const QString dirPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
                           + QStringLiteral("/Bloom");
    QDir().mkpath(dirPath);
    return dirPath + QStringLiteral("/workspaces.json");
}

#ifdef Q_OS_WIN
static bool isDesktopWindow(HWND hwnd)
{
    const DWORD exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
    if ((exStyle & WS_EX_TOOLWINDOW) != 0) {
        return false;
    }
    if (!IsWindowVisible(hwnd)) {
        return false;
    }

    WCHAR className[256] = {0};
    GetClassName(hwnd, className, std::size(className));
    if (::lstrcmpW(className, L"Shell_TrayWnd") == 0
     || ::lstrcmpW(className, L"Progman") == 0
     || ::lstrcmpW(className, L"WorkerW") == 0) {
        return false;
    }

    RECT rc = {0};
    GetWindowRect(hwnd, &rc);
    if (rc.right - rc.left < 100 || rc.bottom - rc.top < 50) {
        return false;
    }
    return true;
}

static QString windowText(HWND hwnd)
{
    const int len = GetWindowTextLengthW(hwnd);
    if (len <= 0) {
        return {};
    }
    WCHAR buffer[512] = {0};
    GetWindowTextW(hwnd, buffer, std::size(buffer));
    return QString::fromWCharArray(buffer);
}

static QString executablePathForWindow(HWND hwnd)
{
    DWORD pid = 0;
    GetWindowThreadProcessId(hwnd, &pid);
    if (pid == 0) {
        return {};
    }

    HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (process == nullptr) {
        return {};
    }

    WCHAR buffer[MAX_PATH] = {0};
    DWORD size = std::size(buffer);
    if (!QueryFullProcessImageNameW(process, 0, buffer, &size)) {
        CloseHandle(process);
        return {};
    }

    CloseHandle(process);
    return QString::fromWCharArray(buffer);
}
#endif

QList<WindowRecord> WorkspaceService::captureWindows() const
{
    QList<WindowRecord> records;

#ifdef Q_OS_WIN
    struct WindowInfo {
        HWND hwnd;
        QString title;
        QString path;
        RECT rc;
        bool maximized;
    };
    QList<WindowInfo> infos;

    EnumWindows([](HWND hwnd, LPARAM lparam) -> BOOL {
        if (!isDesktopWindow(hwnd)) {
            return TRUE;
        }
        WindowInfo info;
        info.hwnd = hwnd;
        info.title = windowText(hwnd);
        info.path = executablePathForWindow(hwnd);
        GetWindowRect(hwnd, &info.rc);
        info.maximized = IsZoomed(hwnd) != 0;

        if (!info.path.isEmpty()) {
            auto *list = reinterpret_cast<QList<WindowInfo>*>(lparam);
            list->append(info);
        }
        return TRUE;
    }, reinterpret_cast<LPARAM>(&infos));

    for (const WindowInfo &info : infos) {
        WindowRecord record;
        record.title = info.title;
        record.executablePath = info.path;
        record.left = info.rc.left;
        record.top = info.rc.top;
        record.right = info.rc.right;
        record.bottom = info.rc.bottom;
        record.maximized = info.maximized;
        records.append(record);
    }
#endif

    return records;
}

bool WorkspaceService::launchAndPosition(const QString &executablePath, const WindowRecord &record) const
{
    Q_UNUSED(record);
#ifdef Q_OS_WIN
    const QString file = record.executablePath.isEmpty() ? executablePath : record.executablePath;
    if (file.isEmpty()) {
        return false;
    }

    SHELLEXECUTEINFOW sei = {0};
    sei.cbSize = sizeof(sei);
    sei.fMask = SEE_MASK_NOCLOSEPROCESS;
    sei.lpFile = reinterpret_cast<LPCWSTR>(file.utf16());
    sei.nShow = record.maximized ? SW_MAXIMIZE : SW_RESTORE;

    if (!ShellExecuteExW(&sei)) {
        return false;
    }

    Sleep(320);
    if (sei.hProcess) {
        CloseHandle(sei.hProcess);
    }
    return true;
#else
    return false;
#endif
}

QStringList WorkspaceService::workspaceNames() const
{
    return m_workspaces.keys();
}

bool WorkspaceService::saveWorkspace(const QString &name)
{
    const QString path = storagePath();
    QFile file(path);
    QJsonArray root;

    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isArray()) {
            root = doc.array();
        }
        file.close();
    }

    const QList<WindowRecord> captures = captureWindows();
    if (captures.isEmpty()) {
        setStatusText(QStringLiteral("No windows captured"));
        return false;
    }

    QJsonArray windows;
    for (const WindowRecord &record : captures) {
        QJsonObject obj;
        obj.insert(QStringLiteral("title"), record.title);
        obj.insert(QStringLiteral("executablePath"), record.executablePath);
        obj.insert(QStringLiteral("left"), record.left);
        obj.insert(QStringLiteral("top"), record.top);
        obj.insert(QStringLiteral("right"), record.right);
        obj.insert(QStringLiteral("bottom"), record.bottom);
        obj.insert(QStringLiteral("maximized"), record.maximized);
        windows.append(obj);
    }

    for (int i = 0; i < root.size(); ++i) {
        if (root.at(i).toObject().value(QStringLiteral("name")) == name) {
            root.removeAt(i);
            break;
        }
    }

    QJsonObject entry;
    entry.insert(QStringLiteral("name"), name);
    entry.insert(QStringLiteral("windows"), windows);
    root.append(entry);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        setStatusText(QStringLiteral("Failed to save workspace"));
        return false;
    }

    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    file.close();

    m_workspaces.insert(name, captures);
    setStatusText(QStringLiteral("Saved %1 (%2 windows)").arg(name).arg(captures.size()));
    return true;
}

bool WorkspaceService::restoreWorkspace(const QString &name)
{
    if (!m_workspaces.contains(name)) {
        const QString path = storagePath();
        QFile file(path);
        if (!file.exists() || !file.open(QIODevice::ReadOnly)) {
            setStatusText(QStringLiteral("Workspace not found"));
            return false;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        const QJsonArray root = doc.array();
        for (const QJsonValue &value : root) {
            const QJsonObject object = value.toObject();
            if (object.value(QStringLiteral("name")) != name) {
                continue;
            }

            QList<WindowRecord> records;
            const QJsonArray windows = object.value(QStringLiteral("windows")).toArray();
            for (const QJsonValue &win : windows) {
                const QJsonObject obj = win.toObject();
                WindowRecord record;
                record.title = obj.value(QStringLiteral("title")).toString();
                record.executablePath = obj.value(QStringLiteral("executablePath")).toString();
                record.left = obj.value(QStringLiteral("left")).toInt();
                record.top = obj.value(QStringLiteral("top")).toInt();
                record.right = obj.value(QStringLiteral("right")).toInt();
                record.bottom = obj.value(QStringLiteral("bottom")).toInt();
                record.maximized = obj.value(QStringLiteral("maximized")).toBool();
                records.append(record);
            }
            m_workspaces.insert(name, records);
            break;
        }
    }

    const QList<WindowRecord> records = m_workspaces.value(name);
    if (records.isEmpty()) {
        setStatusText(QStringLiteral("Workspace empty or not found"));
        return false;
    }

    int launched = 0;
    for (const WindowRecord &record : records) {
        if (launchAndPosition(record.executablePath, record)) {
            ++launched;
        }
    }

    if (launched == 0) {
        setStatusText(QStringLiteral("No apps launched"));
        return false;
    }

    setStatusText(QStringLiteral("Restoring %1...").arg(name));
    return true;
}

bool WorkspaceService::deleteWorkspace(const QString &name)
{
    const QString path = storagePath();
    QFile file(path);
    QJsonArray root;

    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isArray()) {
            root = doc.array();
        }
        file.close();
    }

    for (int i = 0; i < root.size(); ++i) {
        if (root.at(i).toObject().value(QStringLiteral("name")) == name) {
            root.removeAt(i);
            break;
        }
    }

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        return false;
    }
    file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    file.close();

    m_workspaces.remove(name);
    setStatusText(QStringLiteral("Deleted %1").arg(name));
    return true;
}

void WorkspaceService::setStatusText(const QString &text)
{
    if (m_statusText == text) {
        return;
    }
    m_statusText = text;
    emit statusTextChanged();
}