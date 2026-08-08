#include "OverlayController.h"
#include <QFile>
#include <QMetaObject>
#include <QQuickWindow>

OverlayController::OverlayController(QObject *parent)
    : QObject(parent)
{
}

void OverlayController::setWindow(QQuickWindow *window)
{
    m_window = window;
}

bool OverlayController::isVisible() const noexcept
{
    return m_visible;
}

QString OverlayController::mode() const
{
    return m_mode;
}

void OverlayController::showHome()
{
    showMode(QStringLiteral("home"));
}

void OverlayController::showLauncher()
{
    showHome();
}

void OverlayController::showSystem()
{
    showMode(QStringLiteral("system"));
}

void OverlayController::showMusic()
{
    showMode(QStringLiteral("music"));
}

void OverlayController::showWeather()
{
    showMode(QStringLiteral("weather"));
}

void OverlayController::showNotion()
{
    showMode(QStringLiteral("notion"));
}

void OverlayController::showSettings()
{
    showMode(QStringLiteral("settings"));
}

QString OverlayController::backgroundPath() const
{
    return m_backgroundPath;
}

qreal OverlayController::blurRadius() const noexcept
{
    return m_blurRadius;
}

void OverlayController::setBackgroundPath(const QString &path)
{
    if (m_backgroundPath != path) {
        m_backgroundPath = path;
        emit backgroundChanged();
    }
}

void OverlayController::setBlurRadius(qreal radius)
{
    m_blurRadius = radius;
    emit blurChanged();
}

void OverlayController::showExplorer()
{
    // Explorer is mapped to launcher for now - can be expanded later
    showLauncher();
}

void OverlayController::hide()
{
    if (!m_visible)
        return;

    m_visible = false;
    if (m_window)
        m_window->hide();
    emit visibleChanged();
}

void OverlayController::activateAction(const QString &actionId)
{
    emit actionRequested(actionId);

    if (actionId == QLatin1String("close")) {
        hide();
    } else {
        showHome();
    }
}

void OverlayController::showMode(const QString &mode)
{
    const bool hasModeChanged = m_mode != mode;
    m_mode = mode;
    m_visible = true;

    if (hasModeChanged)
        emit modeChanged();

    emit visibleChanged();

    if (m_window) {
        m_window->show();
        m_window->raise();
        m_window->requestActivate();
    }

    QFile f(QStringLiteral("C:\\Users\\smily\\Bloom\\bloom_debug.log"));
    if (f.open(QIODevice::Append | QIODevice::Text)) {
        f.write(QStringLiteral("showMode: mode=%1 visible=%2 window=%3\n")
                    .arg(m_mode).arg(m_visible).arg(m_window ? "exists" : "null")
                    .toUtf8());
        f.close();
    }
}
