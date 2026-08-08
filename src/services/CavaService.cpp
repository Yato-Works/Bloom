#include "CavaService.h"
#include <QFileInfo>
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>
#include <cmath>

CavaService::CavaService(QObject *parent) : QObject(parent)
{
    m_timer.setInterval(60);
    connect(&m_timer, &QTimer::timeout, this, &CavaService::refresh);
}

CavaService::~CavaService()
{
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished(1000);
        delete m_process;
    }
}

void CavaService::start()
{
    startCava();
    m_timer.start();
}

void CavaService::startCava()
{
#ifdef Q_OS_WIN
    // WSLでcavaが利用可能か確認
    QProcess checkProcess;
    checkProcess.start("wsl", QStringList() << "-e" << "which" << "cava");
    checkProcess.waitForFinished(3000);
    const QString cavaPath = QString::fromUtf8(checkProcess.readAllStandardOutput()).trimmed();

    if (cavaPath.isEmpty() || !cavaPath.contains("cava")) {
        // cavaが見つからない場合はシミュレーションモード
        m_active = false;
        emit activeChanged();
        return;
    }

    // cavaをraw出力モードで起動
    const QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(configDir);
    const QString configPath = configDir + "/cava_config";

    // cava設定ファイルを生成
    QString configContent = QStringLiteral(
        "[general]\n"
        "bars = 20\n"
        "framerate = 30\n"
        "[output]\n"
        "method = raw\n"
        "channels = mono\n"
        "raw_target = /dev/stdout\n"
        "bit_format = 8bit\n"
        "[input]\n"
        "method = pulse\n"
    );

    QFile configFile(configPath);
    if (configFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        configFile.write(configContent.toUtf8());
        configFile.close();
    }

    m_process = new QProcess(this);
    m_process->setProcessChannelMode(QProcess::MergedChannels);

    // WindowsパスをWSLパスに変換 (C:\Users\... -> /mnt/c/Users/...)
    QString wslConfigPath = configPath;
    wslConfigPath.replace(":", "");
    wslConfigPath.replace("\\", "/");
    wslConfigPath = "/mnt/" + wslConfigPath.left(1).toLower() + wslConfigPath.mid(1);

    connect(m_process, &QProcess::readyRead, this, &CavaService::readCavaOutput);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int, QProcess::ExitStatus) {
        m_active = false;
        emit activeChanged();
    });

    m_process->start("wsl", QStringList() << "-e" << "cava" << "-p" << wslConfigPath);

    if (m_process->waitForStarted(3000)) {
        m_active = true;
        emit activeChanged();
    } else {
        m_active = false;
        emit activeChanged();
        m_process->deleteLater();
        m_process = nullptr;
    }
#else
    m_active = false;
    emit activeChanged();
#endif
}

void CavaService::readCavaOutput()
{
    if (!m_process) return;

    // cavaのraw出力を読み取る (8bit = 0-255の値がバーごとに出力される)
    const QByteArray data = m_process->readAll();
    if (data.isEmpty()) return;

    // 最後の20バイト(20バー分)を取得
    const int barCount = 20;
    QVariantList newBars;
    const int startIdx = data.size() > barCount ? data.size() - barCount : 0;
    for (int i = startIdx; i < data.size() && newBars.size() < barCount; ++i) {
        const unsigned char val = static_cast<unsigned char>(data[i]);
        // 0-255を0-1.0に正規化
        newBars.append(val / 255.0);
    }

    if (newBars.size() == barCount) {
        m_bars = newBars;
        emit barsChanged();
    }
}

void CavaService::simulateBars()
{
    // cavaが利用できない場合のシミュレーション
    QVariantList newBars;
    const int barCount = 20;
    m_simPhase += 0.35;

    for (int i = 0; i < barCount; ++i) {
        const qreal value = (std::sin((i * 0.42) + m_simPhase) * 0.5 + 0.5) * 0.8;
        newBars.append(value);
    }

    m_bars = newBars;
    emit barsChanged();
}

void CavaService::refresh()
{
    if (m_active && m_process) {
        // cavaプロセスからの出力はreadyReadシグナルで処理される
        if (m_process->state() != QProcess::Running) {
            m_active = false;
            emit activeChanged();
            simulateBars();
        }
    } else {
        simulateBars();
    }
}