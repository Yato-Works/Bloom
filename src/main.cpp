#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDir>
#include <QLockFile>
#include <QLocalServer>
#include <QLocalSocket>
#include <fstream>

#include "services/ServiceManager.h"
#include "services/ThemeBridge.h"

static QString g_logPath;

void setupLogging() {
    const QString logDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(logDir);
    g_logPath = logDir + "/bloom.log";

    QFile f(g_logPath);
    if (f.open(QIODevice::WriteOnly | QIODevice::Append)) {
        f.close();
    }

    qInstallMessageHandler([](QtMsgType type, const QMessageLogContext &context, const QString &msg) {
        QByteArray logMsg = QString("[%1] %2 (%3:%4)\n").arg(
            type == QtDebugMsg ? "DEBUG" : type == QtWarningMsg ? "WARN" : "CRIT",
            msg, QString::number(context.line), QString::number(context.version)
        ).toUtf8();

        QFile logFile(g_logPath);
        if (logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
            logFile.write(logMsg);
            logFile.close();
        }
    });
}

int main(int argc, char *argv[])
{
    qDebug() << "BOOT: main start";
    setupLogging();

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Basic"));
    qDebug() << "BOOT: QGuiApplication created";
    app.setQuitOnLastWindowClosed(false);
    app.setOrganizationName(QStringLiteral("Bloom"));

    const QString serverName = QStringLiteral("Bloom_SingleInstance_Server");

    QLocalSocket socket;
    socket.connectToServer(serverName);
    if (socket.waitForConnected(500)) {
        qDebug() << "BOOT: another instance running, sending SHOW request and exiting";
        socket.write("SHOW\n");
        socket.waitForBytesWritten(500);
        socket.disconnectFromServer();
        return 0;
    }

    QLocalServer::removeServer(serverName);

    ServiceManager services;
    services.initialize();
    qDebug() << "BOOT: services initialized";

    QLocalServer localServer;
    if (localServer.listen(serverName)) {
        qDebug() << "BOOT: single instance server listening on" << serverName;
        QObject::connect(&localServer, &QLocalServer::newConnection, [&localServer, &services]() {
            QLocalSocket *client = localServer.nextPendingConnection();
            if (client) {
                QObject::connect(client, &QLocalSocket::readyRead, [client, &services]() {
                    QByteArray data = client->readAll();
                    if (data.contains("SHOW")) {
                        qDebug() << "BOOT: Received SHOW request from secondary instance";
                        if (services.overlayController()) {
                            services.overlayController()->showLauncher();
                        }
                        if (services.shellController()) {
                            services.shellController()->armPermanent(true);
                        }
                    }
                });
            }
        });
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("weatherService"), services.weatherService());
    engine.rootContext()->setContextProperty(QStringLiteral("overlayController"), services.overlayController());
    engine.rootContext()->setContextProperty(QStringLiteral("shellController"), services.shellController());
    engine.rootContext()->setContextProperty(QStringLiteral("systemInfo"), services.systemInfoService());
    engine.rootContext()->setContextProperty(QStringLiteral("musicControl"), services.musicControlService());
    engine.rootContext()->setContextProperty(QStringLiteral("config"), services.configService());
    engine.rootContext()->setContextProperty(QStringLiteral("wallpaperService"), services.wallpaperService());
    engine.rootContext()->setContextProperty(QStringLiteral("workspaceService"), services.workspaceService());
    engine.rootContext()->setContextProperty(QStringLiteral("workspaceController"), services.workspaceController());
    engine.rootContext()->setContextProperty(QStringLiteral("hotkeyService"), services.hotkeyService());
    engine.rootContext()->setContextProperty(QStringLiteral("experimentalSwitcher"), services.experimentalSwitcher());
    engine.rootContext()->setContextProperty(QStringLiteral("aiService"), services.aiService());
    engine.rootContext()->setContextProperty(QStringLiteral("notionService"), services.notionService());
    engine.rootContext()->setContextProperty(QStringLiteral("appLauncherService"), services.appLauncherService());
    engine.rootContext()->setContextProperty(QStringLiteral("cavaService"), services.cavaService());

    static ThemeBridge themeBridge;
    ConfigService *config = services.configService();
    // Restore the last selected profile & color theme from disk.
    themeBridge.setProfile(config->profile());
    themeBridge.setThemeByName(config->themeName());
    QObject::connect(&themeBridge, &ThemeBridge::themeChanged, config, [config, &themeBridge] {
        config->setThemeName(themeBridge.themeName());
    });
    QObject::connect(&themeBridge, &ThemeBridge::profileChanged, config, [config, &themeBridge] {
        config->setProfile(themeBridge.profile());
    });
    engine.rootContext()->setContextProperty(QStringLiteral("Theme"), &themeBridge);

    engine.loadFromModule("Bloom", "Main");
    qDebug() << "BOOT: QML load called";

    const QList<QObject*> roots = engine.rootObjects();
    qDebug() << "BOOT: rootObjects count =" << roots.count();
    if (roots.isEmpty()) {
        qCritical() << "BOOT: QML load failed - no root objects!";
        return 1;
    }

    if (auto *window = qobject_cast<QQuickWindow*>(roots.first())) {
        services.shellController()->setWindow(window);
        services.overlayController()->setWindow(window);
        services.shellController()->setLocked(false);
    }
    qDebug() << "BOOT: entering event loop";

    const int ret = app.exec();
    qDebug() << "BOOT: event loop exited, ret =" << ret;
    return ret;
}
