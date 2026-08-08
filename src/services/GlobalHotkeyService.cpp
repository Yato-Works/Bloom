#include "GlobalHotkeyService.h"

#include <QDebug>

#ifdef Q_OS_WIN

HHOOK GlobalHotkeyService::s_hook = nullptr;
HWND  GlobalHotkeyService::s_msgWindow = nullptr;
GlobalHotkeyService *GlobalHotkeyService::s_instance = nullptr;

static const UINT WM_APP_ACTION = WM_APP + 1;

LRESULT CALLBACK GlobalHotkeyService::llKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    if (nCode == HC_ACTION && wParam == WM_KEYDOWN) {
        auto *info = reinterpret_cast<KBDLLHOOKSTRUCT *>(lParam);
        // Ignore injected events so our own re-injection never loops back.
        if (!(info->flags & LLKHF_INJECTED)) {
            const bool ctrl = (GetAsyncKeyState(VK_LCONTROL) & 0x8000)
                           || (GetAsyncKeyState(VK_RCONTROL) & 0x8000);
            const bool win  = (GetAsyncKeyState(VK_LWIN) & 0x8000)
                           || (GetAsyncKeyState(VK_RWIN) & 0x8000);
            if (ctrl && win) {
                int action = 0;
                if (info->vkCode == VK_LEFT) {
                    action = ACT_PREV;
                } else if (info->vkCode == VK_RIGHT) {
                    action = ACT_NEXT;
                } else if (info->vkCode >= '1' && info->vkCode <= '9') {
                    action = ACT_JUMP + (info->vkCode - '1' + 1);
                }
                if (action != 0 && s_msgWindow) {
                    PostMessageW(s_msgWindow, WM_APP_ACTION, static_cast<WPARAM>(action), 0);
                    return 1;   // swallow the physical key; Bloom re-injects below
                }
            }
        }
    }
    return CallNextHookEx(nullptr, nCode, wParam, lParam);
}

LRESULT CALLBACK GlobalHotkeyService::msgWindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    if (msg == WM_APP_ACTION) {
        auto *self = reinterpret_cast<GlobalHotkeyService *>(GetWindowLongPtrW(hwnd, GWLP_USERDATA));
        if (self) {
            self->handleAction(static_cast<int>(wParam));
        }
        return 0;
    }
    return DefWindowProcW(hwnd, msg, wParam, lParam);
}

bool GlobalHotkeyService::start()
{
    const HINSTANCE hInst = GetModuleHandleW(nullptr);

    // 1) Create an invisible top-level window to receive our posted actions.
    //    A real top-level window (not message-only) is reliably pumped by Qt's
    //    message loop; message-only windows may not receive such delivery.
    WNDCLASSEXW wc = {};
    wc.cbSize = sizeof(WNDCLASSEXW);
    wc.lpfnWndProc = msgWindowProc;
    wc.hInstance = hInst;
    wc.lpszClassName = L"BloomGlobalHotkeyMsgWin";
    RegisterClassExW(&wc);
    s_msgWindow = CreateWindowExW(WS_EX_TOOLWINDOW, wc.lpszClassName, L"BloomGlobalHotkey",
                                  WS_POPUP, 0, 0, 0, 0, nullptr, nullptr, hInst, nullptr);
    if (!s_msgWindow) {
        qWarning() << "GlobalHotkeyService: CreateWindowExW failed"
                   << static_cast<int>(GetLastError());
        return false;
    }
    SetWindowLongPtrW(s_msgWindow, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(this));
    s_instance = this;

    // 2) Install the low-level keyboard hook.
    s_hook = SetWindowsHookExW(WH_KEYBOARD_LL, llKeyboardProc, hInst, 0);
    if (!s_hook) {
        qWarning() << "GlobalHotkeyService: SetWindowsHookExW(WH_KEYBOARD_LL) failed"
                   << static_cast<int>(GetLastError());
        return false;
    }

    qDebug() << "GlobalHotkeyService: low-level keyboard hook installed";
    return true;
}

void GlobalHotkeyService::stop()
{
    if (s_hook) {
        UnhookWindowsHookEx(s_hook);
        s_hook = nullptr;
    }
    if (s_msgWindow) {
        DestroyWindow(s_msgWindow);
        s_msgWindow = nullptr;
    }
    s_instance = nullptr;
}

void GlobalHotkeyService::handleAction(int action)
{
    if (action == ACT_PREV) {
        emit switchPrevRequested();
    } else if (action == ACT_NEXT) {
        emit switchNextRequested();
    } else if (action >= ACT_JUMP + 1 && action <= ACT_JUMP + 9) {
        emit jumpRequested(action - ACT_JUMP);
    }
}

void GlobalHotkeyService::injectNativeArrowSwitch(bool forward)
{
    injectNativeArrowSwitches(forward, 1);
}

void GlobalHotkeyService::injectNativeArrowSwitches(bool forward, int count)
{
    if (count <= 0) {
        return;
    }
    const WORD arrow = forward ? VK_RIGHT : VK_LEFT;
    for (int i = 0; i < count; ++i) {
        auto key = [](WORD vk, DWORD flags) {
            INPUT in = {};
            in.type = INPUT_KEYBOARD;
            in.ki.wVk = vk;
            in.ki.dwFlags = flags;
            return in;
        };
        INPUT inputs[6] = {
            key(VK_LWIN, 0),
            key(VK_CONTROL, 0),
            key(arrow, 0),
            key(arrow, KEYEVENTF_KEYUP),
            key(VK_CONTROL, KEYEVENTF_KEYUP),
            key(VK_LWIN, KEYEVENTF_KEYUP)
        };
        SendInput(static_cast<UINT>(std::size(inputs)), inputs, sizeof(INPUT));
        if (i < count - 1) {
            Sleep(40);   // let the shell process each switch before the next
        }
    }
}

#else
bool GlobalHotkeyService::start() { return false; }
void GlobalHotkeyService::stop() {}
void GlobalHotkeyService::injectNativeArrowSwitch(bool /*forward*/) {}
void GlobalHotkeyService::injectNativeArrowSwitches(bool /*forward*/, int /*count*/) {}
#endif

GlobalHotkeyService::GlobalHotkeyService(QObject *parent)
    : QObject(parent)
{
}

GlobalHotkeyService::~GlobalHotkeyService()
{
    stop();
}
