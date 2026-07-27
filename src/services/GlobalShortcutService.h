#pragma once

#include <QObject>
#include <QHash>
#include <QAbstractNativeEventFilter>

class OverlayController;
class QQuickWindow;

class GlobalShortcutService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentProfile READ currentProfile NOTIFY profileChanged FINAL)

public:
    struct Shortcut {
        Qt::KeyboardModifiers mods = Qt::NoModifier;
        Qt::Key key = Qt::Key_unknown;
        QString action;
    };

    explicit GlobalShortcutService(OverlayController *controller, QObject *parent = nullptr);
    ~GlobalShortcutService() override;

    bool load(const QString &filePath);
    bool save(const QString &filePath) const;

    void addShortcut(const Shortcut &sc);
    void clearShortcuts();
    void setProfile(const QString &profileName);
    [[nodiscard]] QString currentProfile() const { return m_currentProfile; }

    Q_INVOKABLE QString getShortcutString(const QString &action) const;

    void registerAll();
    void unregisterAll();

signals:
    void activateAction(const QString &action);
    void profileChanged(const QString &profile);

private:
    OverlayController *m_controller = nullptr;
    QList<Shortcut> m_shortcuts;
    QHash<int, QString> m_idToAction;
    int m_nextId = 1;
    QString m_currentProfile {QStringLiteral("Default")};

    class Filter : public QAbstractNativeEventFilter
    {
    public:
        explicit Filter(QObject *receiver) : m_receiver(receiver) {}
        bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;
    private:
        QObject *m_receiver;
    };
    Filter *m_filter = nullptr;
};

