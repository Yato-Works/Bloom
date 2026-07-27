#pragma once

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

class QQuickWindow;

class OverlayController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool visible READ isVisible NOTIFY visibleChanged FINAL)
    Q_PROPERTY(QString mode READ mode NOTIFY modeChanged FINAL)
    Q_PROPERTY(QString backgroundPath READ backgroundPath WRITE setBackgroundPath NOTIFY backgroundChanged FINAL)
    Q_PROPERTY(qreal blurRadius READ blurRadius WRITE setBlurRadius NOTIFY blurChanged FINAL)

public:
    explicit OverlayController(QObject *parent = nullptr);

    [[nodiscard]] bool isVisible() const noexcept;
    [[nodiscard]] QString mode() const;
    [[nodiscard]] QString backgroundPath() const;
    [[nodiscard]] qreal blurRadius() const noexcept;

    void setBackgroundPath(const QString &path);
    void setBlurRadius(qreal radius);

    Q_INVOKABLE void showHome();
    Q_INVOKABLE void showLauncher();
    Q_INVOKABLE void showSystem();
    Q_INVOKABLE void showMusic();
    Q_INVOKABLE void showWeather();
    Q_INVOKABLE void showNotion();
    Q_INVOKABLE void showSettings();
    Q_INVOKABLE void showExplorer();
    Q_INVOKABLE void hide();
    Q_INVOKABLE void activateAction(const QString &actionId);

    /// QMLウィンドウを直接操作するためにセット
    void setWindow(QQuickWindow *window);

signals:
    void visibleChanged();
    void modeChanged();
    void backgroundChanged();
    void blurChanged();
    void actionRequested(const QString &actionId);

private:
    void showMode(const QString &mode);

    bool m_visible {false};
    QString m_mode {QStringLiteral("launcher")};
    QString m_backgroundPath;
    qreal m_blurRadius {20.0};
    QQuickWindow *m_window = nullptr;
};
