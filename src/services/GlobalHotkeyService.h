#pragma once

#include <QObject>

#ifdef Q_OS_WIN
#  include <windows.h>
#endif

/// Global-hotkey capture for the Bloom workspace system.
///
/// Mechanism: a low-level keyboard hook (WH_KEYBOARD_LL) observes raw key
/// events, so it CAN see the Windows-controlled shortcuts (Ctrl+Win+Left /
/// Ctrl+Win+Right / Ctrl+Win+1..9) that RegisterHotKey cannot steal. Bloom
/// keeps its own "current workspace" state in sync, then hands the key back
/// to Windows (re-injection via SendInput) so WINDOWS itself performs the
/// real virtual-desktop switch. No undocumented shell COM API is used.
class GlobalHotkeyService final : public QObject
{
    Q_OBJECT
public:
    explicit GlobalHotkeyService(QObject *parent = nullptr);
    ~GlobalHotkeyService() override;

    GlobalHotkeyService(const GlobalHotkeyService &) = delete;
    GlobalHotkeyService &operator=(const GlobalHotkeyService &) = delete;

    bool start();
    void stop();

    /// Synthesize the native "Ctrl+Win+Arrow" combo via SendInput so Windows
    /// performs its own virtual-desktop switch (forward = Right).
    static void injectNativeArrowSwitch(bool forward);

    /// Post <count> native arrow switches in the given direction with a small
    /// gap so the shell processes each one (used for direct workspace jumps).
    static void injectNativeArrowSwitches(bool forward, int count);

signals:
    void switchPrevRequested();               // Ctrl+Win+Left
    void switchNextRequested();               // Ctrl+Win+Right
    void jumpRequested(int workspaceIndex);   // Ctrl+Win+1..9 (1-based)

private:
    void handleAction(int action);

#ifdef Q_OS_WIN
    static HHOOK s_hook;
    static HWND  s_msgWindow;
    static GlobalHotkeyService *s_instance;

    static LRESULT CALLBACK llKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
    static LRESULT CALLBACK msgWindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

    static constexpr int ACT_PREV = 1;
    static constexpr int ACT_NEXT = 2;
    static constexpr int ACT_JUMP = 0x10;   // + (1..9)
#endif
};
