#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class AppLauncherService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList apps READ apps NOTIFY appsChanged)

public:
    explicit AppLauncherService(QObject *parent = nullptr);

    QVariantList apps() const { return m_apps; }

    Q_INVOKABLE QVariantList searchApps(const QString &query);
    Q_INVOKABLE bool launchApp(const QString &execPathOrName);
    Q_INVOKABLE bool launchAppByIndex(int index);

    Q_INVOKABLE QVariantMap evaluateMath(const QString &expr);
    Q_INVOKABLE QVariantList availableCommands() const;
    Q_INVOKABLE QVariantList searchCliCommands(const QString &query);

    // UI navigation signals
    Q_INVOKABLE void requestThemeSettings();
    Q_INVOKABLE void requestSettings();

signals:
    void appsChanged();
    void themeSettingsRequested();
    void settingsRequested();

private:
    QVariantList m_apps;
    void initSystemApps();
};
