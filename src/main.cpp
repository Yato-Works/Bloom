#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QDebug>
#include <QFileInfo>
#include <QStandardPaths>
#include <QLockFile>
#include <fstream>

#include "services/ServiceManager.h"
#include "services/ThemeBridge.h"

int main(int argc, char *argv[])
{
    qDebug() << "BOOT: main start";
    // デバッグ出力をファイルにリダイレクト
    std::ofstream log("C:\\Users\\smily\\Bloom\\bloom_qml_errors.log");
    if (log.is_open()) {
        qInstallMessageHandler([](QtMsgType type, const QMessageLogContext &context, const QString &msg) {
            QByteArray logMsg = QString("[%1] %2 (%3:%4)\n").arg(
                type == QtDebugMsg ? "DEBUG" : type == QtWarningMsg ? "WARN" : "CRIT",
                msg, QString::number(context.line), QString::number(context.version)
            ).toUtf8();
            std::ofstream log("C:\\Users\\smily\\Bloom\\bloom_qml_errors.log", std::ios::app);
            if (log.is_open()) log << logMsg.constData();
        });
    }
    // ---- シングルインスタンス制御 ----
    const QString lockPath = QStandardPaths::writableLocation(QStandardPaths::TempLocation)
                             + QStringLiteral("/Bloom.lock");
    QLockFile lockFile(lockPath);
    lockFile.setStaleLockTime(0); // クラッシュ後も自動復旧

    if (!lockFile.tryLock()) {
        qDebug() << "BOOT: lock failed, another instance running";
        qDebug() << "Bloom: another instance is already running. Exiting.";
        return 0; // 既に起動中なら何もせず終了
    }
    qDebug() << "BOOT: lock acquired";

    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Basic"));
    qDebug() << "BOOT: QGuiApplication created";
    // Prevent the application from exiting when the overlay window is hidden.
    app.setQuitOnLastWindowClosed(false);

    app.setOrganizationName(QStringLiteral("Bloom"));

    ServiceManager services;
    services.initialize();
    qDebug() << "BOOT: services initialized";

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("weatherService"), services.weatherService());
    engine.rootContext()->setContextProperty(QStringLiteral("overlayController"), services.overlayController());
    engine.rootContext()->setContextProperty(QStringLiteral("shellController"), services.shellController());
    engine.rootContext()->setContextProperty(QStringLiteral("systemInfo"), services.systemInfoService());
    engine.rootContext()->setContextProperty(QStringLiteral("musicControl"), services.musicControlService());
    engine.rootContext()->setContextProperty(QStringLiteral("config"), services.configService());
    engine.rootContext()->setContextProperty(QStringLiteral("wallpaperService"), services.wallpaperService());
    engine.rootContext()->setContextProperty(QStringLiteral("globalShortcuts"), services.globalShortcutService());

    static ThemeBridge themeBridge;
    engine.rootContext()->setContextProperty(QStringLiteral("Theme"), &themeBridge);

    engine.loadFromModule("Bloom", "Main");
    qDebug() << "BOOT: QML load called";

    const QList<QObject*> roots = engine.rootObjects();
    qDebug() << "BOOT: rootObjects count =" << roots.count();
    if (roots.isEmpty()) {
        qCritical() << "BOOT: QML load failed - no root objects!";
        return 1;
    }

    // Shell host window — hold chord arms it; release hides (B1).
    if (auto *window = qobject_cast<QQuickWindow*>(roots.first())) {
        services.shellController()->setWindow(window);
        services.overlayController()->setWindow(window);
    }
    qDebug() << "BOOT: entering event loop";

    const int ret = app.exec();
    qDebug() << "BOOT: event loop exited, ret =" << ret;
    return ret;
}
