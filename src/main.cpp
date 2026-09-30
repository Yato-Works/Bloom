#include <windows.h>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QDir>
#include <QFontDatabase>
#include <QLockFile>
#include <QLocalServer>
#include <QLocalSocket>
#include <QMutex>
#include <cstdio>

#include "services/ServiceManager.h"
#include "services/ThemeBridge.h"
#include "services/CaelestiaColours.h"
static QString g_logPath;

static bool writeBootLog(const QString &path, const QByteArray &data) {
    if (path.isEmpty()) return false;
    QFile f(path);
    if (f.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        f.write(data);
        f.close();
        return true;
    }
    QByteArray local = path.toLocal8Bit();
    if (local.isEmpty()) return false;
    FILE *fp = fopen(local.constData(), "ab");
    if (!fp) return false;
    fwrite(data.constData(), 1, data.size(), fp);
    fclose(fp);
    return true;
}

static void setupLogging() {
    QString logDir;
    if (QCoreApplication::instance()) {
        logDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
        if (logDir.isEmpty()) {
            logDir = QCoreApplication::applicationDirPath() + "/logs";
        }
    }
    if (logDir.isEmpty()) {
        logDir = QStringLiteral("./logs");
    }
    QDir().mkpath(logDir);
    g_logPath = logDir + "/bloom.log";

    // Keep the log bounded: rotate away an oversized file from a previous run
    // instead of appending forever.
    QFileInfo logInfo(g_logPath);
    if (logInfo.size() > 5 * 1024 * 1024) {
        QFile::remove(g_logPath);
    }

    writeBootLog(g_logPath, "BOOT: setupLogging path=" + g_logPath.toUtf8() + "\n");

    static QMutex logMutex;
    qInstallMessageHandler([](QtMsgType type, const QMessageLogContext &context, const QString &msg) {
        const char *level = type == QtDebugMsg ? "DEBUG"
                          : type == QtInfoMsg ? "INFO"
                          : type == QtWarningMsg ? "WARN"
                          : type == QtCriticalMsg ? "CRIT"
                          : "FATAL";
        const QString file = context.file ? QString::fromLatin1(context.file) : QStringLiteral("-");
        QByteArray logMsg = QString("[%1] %2 (%3:%4)\n").arg(
            level, msg, file, QString::number(context.line)).toUtf8();

        // The handler can be invoked from any thread.
        QMutexLocker lock(&logMutex);
        writeBootLog(g_logPath, logMsg);
    });
}

static void bootMark(const char *mark) {
    QByteArray line = QByteArray("BOOT: ") + mark + "\n";
    writeBootLog(g_logPath, line);
    qDebug() << "BOOT:" << mark;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    setupLogging();
    bootMark("main start");
    QQuickStyle::setStyle(QStringLiteral("Basic"));
    bootMark("QGuiApplication created");

    // Icon font for the shell chrome (Material Symbols, bundled in assets/).
    {
        const QString iconFont = QCoreApplication::applicationDirPath()
            + QStringLiteral("/assets/fonts/MaterialSymbolsOutlined.ttf");
        if (QFile::exists(iconFont)) {
            if (QFontDatabase::addApplicationFont(iconFont) < 0) {
                qWarning() << "Failed to load icon font" << iconFont;
            }
        } else {
            qWarning() << "Icon font missing at" << iconFont;
        }
    }

    app.setQuitOnLastWindowClosed(false);    app.setOrganizationName(QStringLiteral("Bloom"));

    ServiceManager services;
    services.initialize();
    bootMark("services initialized");

    // Dynamic wallpaper palette: regenerate the Colours singleton whenever the
    // desktop background changes, and once at startup.
    if (auto *colours = CaelestiaColours::instance()) {
        auto refreshPalette = [colours, &services]() {
            colours->applyWallpaperPalette(services.wallpaperService()->currentWallpaperPath());
        };
        QObject::connect(services.wallpaperService(), &WallpaperService::currentWallpaperChanged,
                         colours, refreshPalette);
        refreshPalette();
    }

    const bool singleInstanceDisabled = qEnvironmentVariableIntValue("BLOOM_NO_SINGLE_INSTANCE") != 0;
    const QString serverName = QStringLiteral("Bloom_SingleInstance_Server");
    QLocalServer localServer;
    if (!singleInstanceDisabled) {
        QLocalServer::removeServer(serverName);

        QLocalSocket socket;
        socket.connectToServer(serverName);
        if (socket.waitForConnected(500)) {
            bootMark("another instance running, sending SHOW request and exiting");
            socket.write("SHOW\n");
            socket.waitForBytesWritten(500);
            socket.disconnectFromServer();
            return 0;
        }

        QLocalServer::removeServer(serverName);
    }

    if (!singleInstanceDisabled && localServer.listen(serverName)) {
        bootMark("single instance server listening");
        QObject::connect(&localServer, &QLocalServer::newConnection, [&localServer, &services]() {
            QLocalSocket *client = localServer.nextPendingConnection();
            if (client) {
                QObject::connect(client, &QLocalSocket::readyRead, [client, &services]() {
                    QByteArray data = client->readAll();
                    if (data.contains("SHOW")) {
                        bootMark("Received SHOW request from secondary instance");
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
    engine.addImportPath(QCoreApplication::applicationDirPath() + QStringLiteral("/qml"));
    engine.addImportPath(QStringLiteral("qrc:/qt/qml"));
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
    engine.rootContext()->setContextProperty(QStringLiteral("lockService"), services.lockService());
    engine.rootContext()->setContextProperty(QStringLiteral("applicationDirPath"), QCoreApplication::applicationDirPath());

    static ThemeBridge themeBridge;
    ConfigService *config = services.configService();
    themeBridge.setThemeByName(config->themeName());
    QObject::connect(&themeBridge, &ThemeBridge::themeChanged, config, [config]() {
        config->setThemeName(themeBridge.themeName());
    });
    engine.rootContext()->setContextProperty(QStringLiteral("Theme"), &themeBridge);

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError> &warnings) {
        for (const auto &w : warnings) {
            bootMark(QString("QML Warning: " + w.toString()).toUtf8().constData());
        }
    });

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, [](const QUrl &url) {
        bootMark(QString("QQmlApplicationEngine objectCreationFailed: " + url.toString()).toUtf8().constData());
    });

    bootMark("before engine.loadFromModule");
    engine.loadFromModule("Bloom", "Main");
    bootMark("after engine.loadFromModule");

    const QList<QObject*> roots = engine.rootObjects();
    bootMark(QString("rootObjects count: " + QString::number(roots.size())).toUtf8().constData());
    if (roots.isEmpty()) {
        bootMark("QML load failed - no root objects");
        return 1;
    }

    if (auto *window = qobject_cast<QQuickWindow*>(roots.first())) {
        services.shellController()->setWindow(window);
        services.overlayController()->setWindow(window);
        services.shellController()->setLocked(false);
    }
    bootMark("entering event loop");

    const int ret = app.exec();
    bootMark("event loop exited");
    return ret;
}
