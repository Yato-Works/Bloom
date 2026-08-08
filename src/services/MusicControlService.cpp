#include "MusicControlService.h"

#ifdef Q_OS_WIN
#include <windows.h>
#endif

MusicControlService::MusicControlService(QObject *parent) : QObject(parent)
{
    m_refreshTimer.setInterval(2000);
    connect(&m_refreshTimer, &QTimer::timeout, this, &MusicControlService::refresh);
}

MusicControlService::~MusicControlService() = default;

void MusicControlService::start()
{
    refresh();
    m_refreshTimer.start();
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
    m_isPlaying = !m_isPlaying;
    emit trackInfoChanged();
#endif
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
#ifdef Q_OS_WIN
    EnumContext ctx;
    EnumWindows(enumWindowsProc, reinterpret_cast<LPARAM>(&ctx));

    bool changed = (ctx.trackTitle != m_trackTitle ||
                    ctx.artistName != m_artistName ||
                    ctx.isPlaying != m_isPlaying ||
                    ctx.sourceApp != m_sourceApp);

    m_trackTitle = ctx.trackTitle;
    m_artistName = ctx.artistName;
    m_isPlaying = ctx.isPlaying;
    m_sourceApp = ctx.sourceApp;

    if (changed) emit trackInfoChanged();
#endif
}