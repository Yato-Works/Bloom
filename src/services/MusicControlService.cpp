#include "MusicControlService.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

#include <algorithm>
#include <cmath>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

namespace {

// Windows PowerShell 5.1 helper: polls the GSMTC session manager — the same
// Windows API yasb's media widget drives through PyWinRT — and prints one
// compact JSON line per update. WinRT projections only exist on .NET
// Framework (Windows PowerShell 5.1), so this must run through powershell.exe
// rather than PowerShell 7.
const char *const kSmtcHelperScript = R"PS(
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Runtime.WindowsRuntime | Out-Null
Add-Type -AssemblyName System.Drawing | Out-Null
$null = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime]
$null = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties, Windows.Media.Control, ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.IRandomAccessStreamWithContentType, Windows.Storage.Streams, ContentType = WindowsRuntime]

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]

# Extension methods cannot be called directly from PowerShell, so bind the
# stream bridge through reflection instead.
$asStreamForRead = ([System.IO.WindowsRuntimeStreamExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsStreamForRead' -and $_.GetParameters().Count -eq 1
} | Select-Object -First 1)

function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    [void]$netTask.Wait(-1)
    $netTask.Result
}

function Emit-Json($Object) {
    Write-Output ($Object | ConvertTo-Json -Compress -Depth 3)
}

try {
    $managerType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]
    $manager = Await ($managerType::RequestAsync()) $managerType
} catch {
    Emit-Json @{ error = 'manager'; message = "$($_.Exception.Message)" }
    exit 1
}

$lastStateKey = ''
$lastPos = -1.0
$lastArtKey = ''

while ($true) {
    try {
        $cur = $manager.GetCurrentSession()
        if ($null -eq $cur) {
            if ($lastStateKey -ne '__none__') {
                $lastStateKey = '__none__'
                $lastArtKey = ''
                $lastPos = -1.0
                Emit-Json @{ none = $true }
            }
        } else {
            $info = $cur.GetPlaybackInfo()
            $props = Await ($cur.TryGetMediaPropertiesAsync()) ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])

            $pos = 0.0
            $len = 0.0
            try {
                $tl = $cur.GetTimelineProperties()
                $pos = [math]::Round($tl.Position.TotalSeconds, 1)
                $len = [math]::Round($tl.EndTime.TotalSeconds, 1)
            } catch { }

            $status = "$($info.PlaybackStatus)"
            $stateKey = "$($cur.SourceAppUserModelId)|$status|$($props.Title)|$($props.Artist)|$($props.AlbumTitle)"
            $playing = $status -eq 'Playing'

            if ($stateKey -ne $lastStateKey -or ($playing -and $pos -ne $lastPos)) {
                $o = [ordered]@{
                    app    = "$($cur.SourceAppUserModelId)"
                    status = $status
                    title  = "$($props.Title)"
                    artist = "$($props.Artist)"
                    album  = "$($props.AlbumTitle)"
                    pos    = $pos
                    len    = $len
                }

                # Album art is fetched once per track (the payload is large).
                $artKey = "$stateKey|$($null -ne $props.Thumbnail)"
                if ($artKey -ne $lastArtKey) {
                    $lastArtKey = $artKey
                    if ($null -ne $props.Thumbnail) {
                        try {
                            $stream = Await ($props.Thumbnail.OpenReadAsync()) ([Windows.Storage.Streams.IRandomAccessStreamWithContentType])
                            $netStream = $asStreamForRead.Invoke($null, @($stream))
                            $rawMs = New-Object System.IO.MemoryStream
                            $netStream.CopyTo($rawMs)
                            $rawBytes = $rawMs.ToArray()
                            $rawMs.Dispose()
                            if ($rawBytes.Length -gt 0 -and $rawBytes.Length -le 8000000) {
                                # GSMTC usually hands back a BMP; re-encode to PNG
                                # so the JSON line stays small.
                                $srcMs = New-Object System.IO.MemoryStream(, $rawBytes)
                                $img = [System.Drawing.Image]::FromStream($srcMs)
                                $pngMs = New-Object System.IO.MemoryStream
                                $img.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
                                $img.Dispose()
                                $srcMs.Dispose()
                                $pngBytes = $pngMs.ToArray()
                                $pngMs.Dispose()
                                if ($pngBytes.Length -gt 0 -and $pngBytes.Length -le 2000000) {
                                    $o['art'] = 'data:image/png;base64,' + [Convert]::ToBase64String($pngBytes)
                                }
                            }
                        } catch { }
                    }
                }

                Emit-Json $o
                $lastStateKey = $stateKey
                $lastPos = $pos
            }
        }
    } catch { }
    Start-Sleep -Milliseconds 500
}
)PS";

} // namespace

// "SpotifyAB.SpotifyMusic_zpdnekdrzrea0!Spotify" -> "Spotify",
// "chrome.exe" -> "Chrome", "Microsoft.ZuneMusic_...!Microsoft.ZuneMusic" ->
// "Media Player".
static QString friendlySourceName(const QString &aumId)
{
    if (aumId.isEmpty()) {
        return {};
    }

    QString id = aumId;
    const int bang = id.indexOf(QLatin1Char('!'));
    if (bang >= 0) {
        id = id.mid(bang + 1);
    }

    QString key = id.toLower();
    if (key.endsWith(QLatin1String(".exe"))) {
        key.chop(4);
    }

    static const QHash<QString, QString> kNames = {
        { QStringLiteral("microsoft.zunemusic"), QStringLiteral("Media Player") },
        { QStringLiteral("spotifymusic"),        QStringLiteral("Spotify") },
        { QStringLiteral("spotify"),             QStringLiteral("Spotify") },
        { QStringLiteral("chrome"),              QStringLiteral("Chrome") },
        { QStringLiteral("msedge"),              QStringLiteral("Edge") },
        { QStringLiteral("firefox"),             QStringLiteral("Firefox") },
        { QStringLiteral("brave"),               QStringLiteral("Brave") },
        { QStringLiteral("opera"),               QStringLiteral("Opera") },
        { QStringLiteral("vlc"),                 QStringLiteral("VLC") },
        { QStringLiteral("musicbee"),            QStringLiteral("MusicBee") },
        { QStringLiteral("foobar2000"),          QStringLiteral("foobar2000") },
    };

    if (const auto it = kNames.constFind(key); it != kNames.constEnd()) {
        return it.value();
    }

    if (id.endsWith(QLatin1String(".exe"), Qt::CaseInsensitive)) {
        id.chop(4);
    }
    if (!id.isEmpty()) {
        id[0] = id[0].toUpper();
    }
    return id;
}

MusicControlService::MusicControlService(QObject *parent)
    : QObject(parent)
{
    m_refreshTimer.setInterval(1000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &MusicControlService::refresh);

    // 30 fps interpolation between the helper's ~0.5 s position reports, so the
    // QML progress bars / rings flow instead of jumping in visible steps.
    m_progressTimer.setInterval(33);
    connect(&m_progressTimer, &QTimer::timeout, this, &MusicControlService::advanceProgress);

    m_smtcRestartTimer.setSingleShot(true);
    m_smtcRestartTimer.setInterval(5000);
    connect(&m_smtcRestartTimer, &QTimer::timeout, this, &MusicControlService::startSmtcHelper);

    connect(&m_smtcProcess, &QProcess::readyReadStandardOutput,
            this, &MusicControlService::handleSmtcOutput);
    connect(&m_smtcProcess, &QProcess::errorOccurred, this, [this](QProcess::ProcessError) {
        if (!m_stopping) {
            qWarning() << "MusicControlService: SMTC helper failed to start";
            m_smtcRestartTimer.start();
        }
    });
    connect(&m_smtcProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int, QProcess::ExitStatus) {
        if (m_stopping) {
            return;
        }
        if (m_smtcActive) {
            m_smtcActive = false;
            qWarning() << "MusicControlService: SMTC helper exited - window titles take over";
        }
        m_smtcRestartTimer.start();
    });
}

MusicControlService::~MusicControlService()
{
    m_stopping = true;
    m_smtcRestartTimer.stop();
    m_progressTimer.stop();
    if (m_smtcProcess.state() != QProcess::NotRunning) {
        m_smtcProcess.closeReadChannel(QProcess::StandardOutput);
        m_smtcProcess.kill();
        m_smtcProcess.waitForFinished(1500);
    }
}

void MusicControlService::start()
{
    refresh();
    m_refreshTimer.start();
    m_progressTimer.start();
    startSmtcHelper();
}

// Interpolate the playback fraction between the helper's half-second reports.
// Paused sessions simply hold their value, so pausing freezes the bar in place
// instead of letting it creep forward.
void MusicControlService::advanceProgress()
{
    if (!m_isPlaying || m_length <= 0) {
        return;
    }

    const qreal step = qreal(m_progressTimer.interval()) / 1000.0 / qreal(m_length);
    m_progress = qMin(qreal(1.0), m_progress + step);
    emit progressChanged();
}

// Snap the interpolated fraction onto a freshly reported position when the two
// disagree by more than a fraction of a second (seek, track change, loop) —
// otherwise keep the interpolated value so the bar never stutters backwards.
void MusicControlService::resyncProgress(qreal reportedSeconds)
{
    if (m_length <= 0) {
        if (!qFuzzyIsNull(m_progress)) {
            m_progress = 0.0;
            emit progressChanged();
        }
        return;
    }

    const qreal interpolated = m_progress * qreal(m_length);
    if (std::abs(reportedSeconds - interpolated) > 0.5) {
        m_progress = std::clamp(reportedSeconds / qreal(m_length), qreal(0.0), qreal(1.0));
        emit progressChanged();
    }
}

void MusicControlService::startSmtcHelper()
{
#ifdef Q_OS_WIN
    if (m_stopping || m_smtcActive || m_smtcProcess.state() != QProcess::NotRunning) {
        return;
    }

    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    if (dir.isEmpty()) {
        dir = QDir::homePath() + QStringLiteral("/AppData/Local/Bloom");
    }
    QDir().mkpath(dir);

    const QString scriptPath = dir + QStringLiteral("/smtc_helper.ps1");
    QFile script(scriptPath);
    if (!script.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        qWarning() << "MusicControlService: cannot write SMTC helper script" << scriptPath;
        return;
    }
    script.write(kSmtcHelperScript);
    script.close();

    m_smtcBuffer.clear();
    m_smtcProcess.setProgram(QStringLiteral("powershell.exe"));
    m_smtcProcess.setArguments({ QStringLiteral("-NoProfile"), QStringLiteral("-NoLogo"),
                                 QStringLiteral("-NonInteractive"), QStringLiteral("-ExecutionPolicy"),
                                 QStringLiteral("Bypass"), QStringLiteral("-File"), scriptPath });
    m_smtcProcess.setProcessChannelMode(QProcess::SeparateChannels);
    m_smtcProcess.start();
    qDebug() << "MusicControlService: SMTC helper launched";
#endif
}

void MusicControlService::handleSmtcOutput()
{
    m_smtcBuffer.append(m_smtcProcess.readAllStandardOutput());

    int newline = -1;
    while ((newline = m_smtcBuffer.indexOf('\n')) >= 0) {
        const QByteArray line = m_smtcBuffer.left(newline).trimmed();
        m_smtcBuffer.remove(0, newline + 1);
        if (line.isEmpty()) {
            continue;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(line);
        if (doc.isObject()) {
            applySmtcState(doc.object());
        }
    }
}

void MusicControlService::applySmtcState(const QJsonObject &state)
{
    if (state.contains(QStringLiteral("none"))) {
        m_smtcActive = true;
        const bool changed = !m_trackTitle.isEmpty() || !m_artistName.isEmpty()
                             || !m_thumbnailSource.isEmpty() || m_isPlaying;
        m_trackTitle.clear();
        m_artistName.clear();
        m_sourceApp.clear();
        m_thumbnailSource.clear();
        m_isPlaying = false;
        m_position = 0;
        m_length = 0;
        if (!qFuzzyIsNull(m_progress)) {
            m_progress = 0.0;
            emit progressChanged();
        }
        if (changed) {
            emit trackInfoChanged();
        }
        return;
    }

    if (state.contains(QStringLiteral("error"))) {
        qWarning() << "MusicControlService: SMTC helper error"
                   << state.value(QStringLiteral("message")).toString();
        return;
    }

    m_smtcActive = true;

    const QString status = state.value(QStringLiteral("status")).toString();
    const QString title = state.value(QStringLiteral("title")).toString();
    const QString artist = state.value(QStringLiteral("artist")).toString();
    const QString app = friendlySourceName(state.value(QStringLiteral("app")).toString());
    const bool playing = status == QLatin1String("Playing");
    const bool newTrack = title != m_trackTitle;

    bool changed = title != m_trackTitle
                || artist != m_artistName
                || app != m_sourceApp
                || playing != m_isPlaying;

    m_trackTitle = title;
    m_artistName = artist;
    m_sourceApp = app;
    m_isPlaying = playing;
    m_position = static_cast<int>(state.value(QStringLiteral("pos")).toDouble());
    m_length = static_cast<int>(state.value(QStringLiteral("len")).toDouble());
    if (newTrack) {
        // Fresh track: restart the interpolation from the reported position.
        m_progress = m_length > 0
            ? std::clamp(qreal(m_position) / qreal(m_length), qreal(0.0), qreal(1.0))
            : 0.0;
        emit progressChanged();
    } else {
        resyncProgress(state.value(QStringLiteral("pos")).toDouble());
    }

    if (state.contains(QStringLiteral("art"))) {
        m_thumbnailSource = state.value(QStringLiteral("art")).toString();
        changed = true;
    }

    if (changed) {
        emit trackInfoChanged();
    }
}

void MusicControlService::playPause()
{
    togglePlayPause();
}

void MusicControlService::togglePlayPause()
{
#ifdef Q_OS_WIN
    keybd_event(VK_MEDIA_PLAY_PAUSE, 0, 0, 0);
    keybd_event(VK_MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0);
#endif
    // Optimistically flip state; refresh() will correct it on next tick
    m_isPlaying = !m_isPlaying;
    emit trackInfoChanged();
}

void MusicControlService::next()
{
#ifdef Q_OS_WIN
    keybd_event(VK_MEDIA_NEXT_TRACK, 0, 0, 0);
    keybd_event(VK_MEDIA_NEXT_TRACK, 0, KEYEVENTF_KEYUP, 0);
#endif
}

void MusicControlService::previous()
{
#ifdef Q_OS_WIN
    keybd_event(VK_MEDIA_PREV_TRACK, 0, 0, 0);
    keybd_event(VK_MEDIA_PREV_TRACK, 0, KEYEVENTF_KEYUP, 0);
#endif
}

void MusicControlService::positionChanged()
{
    // QML calls this from a Timer to force position update
    resyncProgress(qreal(m_position));
    emit trackInfoChanged();
}

#ifdef Q_OS_WIN
struct EnumContext {
    QString trackTitle;
    QString artistName;
    bool isPlaying = false;
    QString sourceApp;
};

static QString getWindowTitle(HWND hwnd)
{
    wchar_t title[512] = {0};
    GetWindowTextW(hwnd, title, 512);
    return QString::fromWCharArray(title);
}

static BOOL CALLBACK enumWindowsProc(HWND hwnd, LPARAM lParam)
{
    auto *ctx = reinterpret_cast<EnumContext*>(lParam);
    if (!IsWindowVisible(hwnd)) return TRUE;

    QString title = getWindowTitle(hwnd);
    if (title.isEmpty()) return TRUE;

    if (title.contains("Spotify", Qt::CaseInsensitive)) {
        ctx->sourceApp = "Spotify";
        if (title == "Spotify" || title == "Spotify Free" || title == "Spotify Premium") {
            ctx->isPlaying = false;
            ctx->trackTitle = "";
            ctx->artistName = "";
        } else {
            ctx->isPlaying = true;
            QString info = title;
            info.remove(" - Spotify", Qt::CaseInsensitive);
            int sep = info.indexOf(" - ");
            if (sep > 0) {
                ctx->artistName = info.left(sep);
                ctx->trackTitle = info.mid(sep + 3);
            } else {
                ctx->trackTitle = info;
            }
        }
        return FALSE;
    }

    if (title.contains("YouTube", Qt::CaseInsensitive) &&
        (title.contains("Chrome", Qt::CaseInsensitive) ||
         title.contains("Edge", Qt::CaseInsensitive) ||
         title.contains("Firefox", Qt::CaseInsensitive) ||
         title.contains("Brave", Qt::CaseInsensitive))) {
        ctx->sourceApp = "Browser";
        ctx->isPlaying = true;
        int ytIdx = title.indexOf(" - YouTube", Qt::CaseInsensitive);
        if (ytIdx > 0) {
            ctx->trackTitle = title.left(ytIdx);
            ctx->artistName = "YouTube";
        } else {
            ctx->trackTitle = title;
        }
        return FALSE;
    }

    return TRUE;
}
#endif

void MusicControlService::refresh()
{
    if (m_smtcActive) {
        return; // The GSMTC helper is authoritative while it is running.
    }

#ifdef Q_OS_WIN
    EnumContext ctx;
    EnumWindows(enumWindowsProc, reinterpret_cast<LPARAM>(&ctx));

    bool changed = (ctx.trackTitle != m_trackTitle ||
                    ctx.artistName != m_artistName ||
                    ctx.isPlaying != m_isPlaying ||
                    ctx.sourceApp != m_sourceApp);

    m_trackTitle = ctx.trackTitle;
    m_artistName = ctx.artistName;
    m_sourceApp = ctx.sourceApp;

    if (ctx.isPlaying && !m_isPlaying) {
        m_isPlaying = true;
        changed = true;
    } else if (!ctx.isPlaying && m_isPlaying) {
        m_isPlaying = false;
        changed = true;
    }

    // Advance position while playing
    if (m_isPlaying) {
        m_position += 1;
        if (m_position >= m_length && m_length > 0) {
            m_position = 0;
        }
        changed = true;
    }

    // Keep the smooth fraction in step with the heuristic clock; the 30 fps
    // interpolator fills the gaps between these 1 s ticks.
    resyncProgress(qreal(m_position));

    if (changed) emit trackInfoChanged();
#endif
}
