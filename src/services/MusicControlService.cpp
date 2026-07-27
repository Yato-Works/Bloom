#include "MusicControlService.h"

#ifdef Q_OS_WIN
#include <windows.h>
#endif

MusicControlService::MusicControlService(QObject *parent) : QObject(parent) {}

namespace {
void sendMediaKey(const unsigned char key)
{
#ifdef Q_OS_WIN
    keybd_event(key, 0, 0, 0);
    keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
#else
    Q_UNUSED(key)
#endif
}
}

void MusicControlService::togglePlayPause() { sendMediaKey(VK_MEDIA_PLAY_PAUSE); }
void MusicControlService::next() { sendMediaKey(VK_MEDIA_NEXT_TRACK); }
void MusicControlService::previous() { sendMediaKey(VK_MEDIA_PREV_TRACK); }
