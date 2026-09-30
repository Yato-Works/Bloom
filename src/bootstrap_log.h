#ifndef BOOTSTRAP_LOG_H
#define BOOTSTRAP_LOG_H
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QStandardPaths>

class BootstrapLog {
public:
    static void write(const QString &msg) {
        QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
        if (dir.isEmpty()) {
            dir = QDir::homePath() + "/AppData/Local/Bloom/Bloom";
        }
        QDir().mkpath(dir);
        QFile f(dir + "/bootstrap.log");
        if (f.open(QIODevice::Append | QIODevice::Text)) {
            QTextStream t(&f);
            t << QDateTime::currentDateTime().toString("hh:mm:ss") << ": " << msg << "\n";
            t.flush();
        }
    }
};
#endif
