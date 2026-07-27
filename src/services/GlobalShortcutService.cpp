#include "GlobalShortcutService.h"

#include "OverlayController.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaObject>
#include <QGuiApplication>
#include <QKeySequence>
#include <QTimer>
#include <QDebug>
#include <windows.h>

// デバッグ用：簡易ファイルログ
static void debugLog(const QString &msg)
{
    QFile f(QStringLiteral("C:\\Users\\smily\\Bloom\\bloom_debug.log"));
    if (f.open(QIODevice::Append | QIODevice::Text)) {
        f.write(msg.toUtf8() + "\n");
        f.close();
    }
}

GlobalShortcutService::GlobalShortcutService(OverlayController *controller, QObject *parent)
    : QObject(parent), m_controller(controller)
{
    m_filter = new Filter(this);
    QGuiApplication::instance()->installNativeEventFilter(m_filter);
    debugLog(QStringLiteral("GlobalShortcutService constructed, native event filter installed"));
}

GlobalShortcutService::~GlobalShortcutService()
{
    unregisterAll();
    QGuiApplication::instance()->removeNativeEventFilter(m_filter);
    delete m_filter;
}

namespace {
inline UINT qModToWin(Qt::KeyboardModifiers mods)
{
    UINT m = 0;
    if (mods & Qt::ControlModifier) m |= MOD_CONTROL;
    if (mods & Qt::AltModifier)     m |= MOD_ALT;
    if (mods & Qt::ShiftModifier)   m |= MOD_SHIFT;
    if (mods & Qt::MetaModifier)    m |= MOD_WIN;
    return m;
}

inline UINT qKeyToVk(Qt::Key k)
{
    switch (k) {
    case Qt::Key_Escape:       return VK_ESCAPE;
    case Qt::Key_Tab:          return VK_TAB;
    case Qt::Key_Backspace:    return VK_BACK;
    case Qt::Key_Return:
    case Qt::Key_Enter:        return VK_RETURN;
    case Qt::Key_Insert:       return VK_INSERT;
    case Qt::Key_Delete:       return VK_DELETE;
    case Qt::Key_Home:         return VK_HOME;
    case Qt::Key_End:          return VK_END;
    case Qt::Key_Left:         return VK_LEFT;
    case Qt::Key_Up:           return VK_UP;
    case Qt::Key_Right:        return VK_RIGHT;
    case Qt::Key_Down:         return VK_DOWN;
    case Qt::Key_PageUp:       return VK_PRIOR;
    case Qt::Key_PageDown:     return VK_NEXT;
    case Qt::Key_F1:  case Qt::Key_F2:  case Qt::Key_F3:  case Qt::Key_F4:
    case Qt::Key_F5:  case Qt::Key_F6:  case Qt::Key_F7:  case Qt::Key_F8:
    case Qt::Key_F9:  case Qt::Key_F10: case Qt::Key_F11: case Qt::Key_F12:
        return static_cast<UINT>(k - Qt::Key_F1 + VK_F1);
    default:
        if (k >= Qt::Key_A && k <= Qt::Key_Z)
            return static_cast<UINT>('A' + (k - Qt::Key_A));
        if (k >= Qt::Key_0 && k <= Qt::Key_9)
            return static_cast<UINT>('0' + (k - Qt::Key_0));
        return static_cast<UINT>(static_cast<int>(k));
    }
}
}

bool GlobalShortcutService::Filter::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
#ifdef Q_OS_WIN
    if (eventType != QStringLiteral("windows_generic_MSG"))
        return false;

    MSG *msg = static_cast<MSG *>(message);
    if (msg->message != WM_HOTKEY)
        return false;

    const int id = static_cast<int>(msg->wParam);
    debugLog(QStringLiteral("WM_HOTKEY received: id=%1").arg(id));
    GlobalShortcutService *self = qobject_cast<GlobalShortcutService *>(m_receiver);
    if (!self)
        return false;

    auto it = self->m_idToAction.constFind(id);
    if (it == self->m_idToAction.constEnd())
        return false;

    const QString action = it.value();
    debugLog(QStringLiteral("WM_HOTKEY received: id=%1 action=%2").arg(id).arg(action));
    qDebug() << "GlobalShortcutService: hotkey id=" << id << "action=" << action;
    debugLog(QStringLiteral("Calling activateAction directly: action=%1").arg(action));

    // 直接呼び出し（即座に状態を変更）
    self->m_controller->activateAction(action);

    *result = 0;
    return true;
#else
    Q_UNUSED(eventType); Q_UNUSED(message); Q_UNUSED(result);
    return false;
#endif
}

void GlobalShortcutService::clearShortcuts()
{
    unregisterAll();
    m_shortcuts.clear();
}

QString GlobalShortcutService::getShortcutString(const QString &action) const
{
    for (const Shortcut &sc : m_shortcuts) {
        if (sc.action.toLower() == action.toLower()) {
            QStringList parts;
            if (sc.mods & Qt::ControlModifier) parts << QStringLiteral("Ctrl");
            if (sc.mods & Qt::MetaModifier)    parts << QStringLiteral("Win");
            if (sc.mods & Qt::AltModifier)     parts << QStringLiteral("Alt");
            if (sc.mods & Qt::ShiftModifier)   parts << QStringLiteral("Shift");

            if (sc.key >= Qt::Key_F1 && sc.key <= Qt::Key_F12) {
                parts << QString("F%1").arg(sc.key - Qt::Key_F1 + 1);
            } else if (static_cast<int>(sc.key) < 0x01000000) {
                QString keyName = QKeySequence(sc.key).toString(QKeySequence::NativeText);
                if (keyName.length() == 1)
                    keyName = keyName.toUpper();
                if (!keyName.isEmpty())
                    parts << keyName;
            }
            return parts.join(QStringLiteral("+"));
        }
    }
    return QString();
}

void GlobalShortcutService::setProfile(const QString &profileName)
{
    clearShortcuts();
    m_currentProfile = profileName;

    if (profileName == QStringLiteral("VSCode")) {
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_P, QStringLiteral("launcher")});
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_W, QStringLiteral("weather")});
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_M, QStringLiteral("music")});
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_S, QStringLiteral("settings")});
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_N, QStringLiteral("notion")});
        addShortcut({Qt::MetaModifier | Qt::AltModifier, Qt::Key_E, QStringLiteral("explorer")});
    } else if (profileName == QStringLiteral("JetBrains")) {
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_P, QStringLiteral("launcher")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_W, QStringLiteral("weather")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_M, QStringLiteral("music")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_S, QStringLiteral("settings")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_N, QStringLiteral("notion")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier | Qt::ShiftModifier, Qt::Key_E, QStringLiteral("explorer")});
    } else if (profileName == QStringLiteral("Blender")) {
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_P, QStringLiteral("launcher")});
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_W, QStringLiteral("weather")});
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_M, QStringLiteral("music")});
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_S, QStringLiteral("settings")});
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_N, QStringLiteral("notion")});
        addShortcut({Qt::AltModifier | Qt::ShiftModifier, Qt::Key_E, QStringLiteral("explorer")});
    } else if (profileName == QStringLiteral("Unreal Engine")) {
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F1, QStringLiteral("launcher")});
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F2, QStringLiteral("weather")});
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F3, QStringLiteral("music")});
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F4, QStringLiteral("settings")});
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F5, QStringLiteral("notion")});
        addShortcut({Qt::ControlModifier | Qt::ShiftModifier, Qt::Key_F6, QStringLiteral("explorer")});
    } else { // Default / Standard Bloom
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_P, QStringLiteral("launcher")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_W, QStringLiteral("weather")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_M, QStringLiteral("music")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_S, QStringLiteral("settings")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_N, QStringLiteral("notion")});
        addShortcut({Qt::ControlModifier | Qt::AltModifier, Qt::Key_E, QStringLiteral("explorer")});
    }

    addShortcut({Qt::NoModifier, Qt::Key_Escape, QStringLiteral("close")});

    registerAll();
    emit profileChanged(m_currentProfile);
}

void GlobalShortcutService::addShortcut(const Shortcut &sc)
{
    m_shortcuts.append(sc);
}

void GlobalShortcutService::registerAll()
{
    unregisterAll();
    m_idToAction.clear();
    m_nextId = 1;

    debugLog(QStringLiteral("registerAll: %1 shortcuts to register").arg(m_shortcuts.size()));

    for (const Shortcut &sc : m_shortcuts) {
        const UINT mods = qModToWin(sc.mods);
        const UINT vk   = qKeyToVk(sc.key);

        if (!vk) {
            qWarning() << "GlobalShortcutService: unsupported key for" << sc.action
                       << static_cast<int>(sc.key);
            debugLog(QStringLiteral("SKIP (unsupported key): %1").arg(sc.action));
            continue;
        }

        if (!RegisterHotKey(nullptr, m_nextId, mods, vk)) {
            const DWORD err = GetLastError();
            qWarning() << "GlobalShortcutService: RegisterHotKey failed action=" << sc.action
                       << QString("mods=0x%1 vk=0x%2 err=%3").arg(mods, 0, 16).arg(vk, 2, 16).arg(err);
            debugLog(QStringLiteral("FAILED: action=%1 mods=0x%2 vk=0x%3 err=%4")
                         .arg(sc.action)
                         .arg(mods, 0, 16)
                         .arg(vk, 2, 16)
                         .arg(err));
            continue;
        }

        qDebug() << "GlobalShortcutService: registered" << sc.action
                 << QString("id=%1 mods=0x%2 vk=0x%3").arg(m_nextId).arg(mods, 0, 16).arg(vk, 2, 16);
        debugLog(QStringLiteral("OK: id=%1 action=%2 mods=0x%3 vk=0x%4")
                     .arg(m_nextId)
                     .arg(sc.action)
                     .arg(mods, 0, 16)
                     .arg(vk, 2, 16));
        m_idToAction.insert(m_nextId, sc.action);
        ++m_nextId;
    }
}

void GlobalShortcutService::unregisterAll()
{
    for (auto it = m_idToAction.constBegin(); it != m_idToAction.constEnd(); ++it) {
        UnregisterHotKey(nullptr, it.key());
    }
    m_idToAction.clear();
    m_nextId = 1;
}

bool GlobalShortcutService::load(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "GlobalShortcutService: JSON parse error:" << err.errorString();
        return false;
    }

    const QJsonObject root = doc.object();
    for (auto it = root.constBegin(); it != root.constEnd(); ++it) {
        const QString action = it.key();
        const QString shortcutStr = it.value().toString();

        Qt::KeyboardModifiers mods = Qt::NoModifier;
        Qt::Key key = Qt::Key_unknown;

        const QStringList parts = shortcutStr.split(QChar('+'), Qt::SkipEmptyParts);
        for (const QString &p : parts) {
            const QString lower = p.trimmed().toLower();
            if (lower == QStringLiteral("ctrl"))       mods |= Qt::ControlModifier;
            else if (lower == QStringLiteral("alt"))   mods |= Qt::AltModifier;
            else if (lower == QStringLiteral("shift")) mods |= Qt::ShiftModifier;
            else if (lower == QStringLiteral("meta"))  mods |= Qt::MetaModifier;
            else if (!p.trimmed().isEmpty()) {
                bool ok = false;
                int val = p.trimmed().toInt(&ok);
                if (ok) {
                    key = static_cast<Qt::Key>(val);
                } else {
                    const QByteArray upper = p.trimmed().toUpper().toLocal8Bit();
                    if (upper.size() == 1)
                        key = static_cast<Qt::Key>(upper.at(0));
                }
            }
        }

        if (!action.isEmpty())
            m_shortcuts.append(Shortcut{mods, key, action});
    }
    return !m_shortcuts.isEmpty();
}

bool GlobalShortcutService::save(const QString &filePath) const
{
    QJsonObject obj;
    for (const Shortcut &sc : m_shortcuts) {
        QStringList parts;
        if (sc.mods & Qt::ControlModifier) parts << QStringLiteral("Ctrl");
        if (sc.mods & Qt::AltModifier)     parts << QStringLiteral("Alt");
        if (sc.mods & Qt::ShiftModifier)   parts << QStringLiteral("Shift");
        if (sc.mods & Qt::MetaModifier)    parts << QStringLiteral("Meta");
        if (static_cast<int>(sc.key) < 0x01000000) {
            QString keyName = QKeySequence(sc.key).toString(QKeySequence::NativeText);
            if (keyName.length() == 1)
                keyName = keyName.toUpper();
            if (!keyName.isEmpty())
                parts << keyName;
        }
        obj.insert(sc.action, parts.join(QStringLiteral("+")));
    }

    QJsonDocument doc(obj);
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}
