#include <windows.h>
#include <dbghelp.h>
#include <QStandardPaths>
#include <QDir>
#include <QFile>

#pragma comment(lib, "dbghelp.lib")

// Resolved once at install time: the crash filter must not allocate (QString,
// QStandardPaths) while the heap may be corrupted.
static WCHAR g_dumpPath[MAX_PATH] = {0};

static LONG WINAPI BloomCrashHandler(EXCEPTION_POINTERS *ep) {
    if (g_dumpPath[0] == 0) {
        return EXCEPTION_EXECUTE_HANDLER;
    }

    HANDLE hFile = CreateFileW(g_dumpPath, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hFile != INVALID_HANDLE_VALUE) {
        MINIDUMP_EXCEPTION_INFORMATION mei;
        mei.ThreadId = GetCurrentThreadId();
        mei.ExceptionPointers = ep;
        mei.ClientPointers = FALSE;
        MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hFile, MiniDumpNormal, &mei, NULL, NULL);
        CloseHandle(hFile);
    }
    return EXCEPTION_EXECUTE_HANDLER;
}

void installCrashHandler() {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    if (!dir.isEmpty() && QDir().mkpath(dir)) {
        const QString path = dir + "/crash.dmp";
        if (path.size() < MAX_PATH) {
            path.toWCharArray(g_dumpPath);
        }
    }
    SetUnhandledExceptionFilter(BloomCrashHandler);
}
