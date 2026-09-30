# ui_probe.ps1 — hold the Bloom arm chord (Ctrl+Win) via SendInput, drive the
# mouse, and capture a screenshot region. Used to verify the shell UI headlessly
# while iterating on the QML motion work.
param(
    [string]$Click = "",        # "x,y" to click (after arming)
    [string]$Hover = "",        # "x,y" to hover (after arming)
    [string]$Hover2 = "",       # "x,y" second hover step (bar -> panel)
    [string]$Out = "$PSScriptRoot\..\_probe.png",
    [string]$Rect = "470,40,980,400",   # "left,top,width,height" (width 0 -> full screen)
    [int]$WaitMs = 1200,
    [switch]$KeepArmed           # leave the chord held on exit
)

# Scripts launched with -File receive raw strings, so parse the numeric lists
# here instead of relying on parameter type coercion.
function Parse-Nums([string]$text) {
    if ([string]::IsNullOrWhiteSpace($text)) { return @() }
    return @($text -split '[,\s]+' | Where-Object { $_ -ne '' } | ForEach-Object { [int]$_ })
}

$ClickNums  = Parse-Nums $Click
$HoverNums  = Parse-Nums $Hover
$Hover2Nums = Parse-Nums $Hover2
$RectNums   = Parse-Nums $Rect

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class UiProbe {
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT {
        public uint type;
        public InputUnion u;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct InputUnion {
        [FieldOffset(0)] public MOUSEINPUT mi;
        [FieldOffset(0)] public KEYBDINPUT ki;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct MOUSEINPUT {
        public int dx; public int dy; public uint mouseData;
        public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public ushort wVk; public ushort wScan;
        public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
    }

    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);

    const uint INPUT_KEYBOARD = 1;
    const uint INPUT_MOUSE = 0;
    const uint KEYEVENTF_KEYUP = 0x0002;
    const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    const uint MOUSEEVENTF_LEFTUP = 0x0004;

    // Press Ctrl and Win in a single SendInput call so Windows never sees a
    // lone Win press (which would pop the Start menu).
    public static void ChordDown() {
        ushort[] keys = { 0x11, 0x5B };          // VK_CONTROL, VK_LWIN
        var inputs = new INPUT[keys.Length];
        for (int i = 0; i < keys.Length; i++) {
            inputs[i] = new INPUT();
            inputs[i].type = INPUT_KEYBOARD;
            inputs[i].u.ki.wVk = keys[i];
        }
        SendInput((uint)inputs.Length, inputs, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void ChordUp() {
        ushort[] keys = { 0x5B, 0x11 };
        var inputs = new INPUT[keys.Length];
        for (int i = 0; i < keys.Length; i++) {
            inputs[i] = new INPUT();
            inputs[i].type = INPUT_KEYBOARD;
            inputs[i].u.ki.wVk = keys[i];
            inputs[i].u.ki.dwFlags = KEYEVENTF_KEYUP;
        }
        SendInput((uint)inputs.Length, inputs, Marshal.SizeOf(typeof(INPUT)));
    }

    public static void Click(int x, int y) {
        SetCursorPos(x, y);
        System.Threading.Thread.Sleep(160);
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        System.Threading.Thread.Sleep(60);
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, UIntPtr.Zero);
    }
}
'@

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class KeyState {
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vk);
    public static bool Down(int vk) { return (GetAsyncKeyState(vk) & 0x8000) != 0; }
}
'@

[UiProbe]::ChordDown()
Start-Sleep -Milliseconds 400
Write-Output ("CTRL_DOWN=" + [KeyState]::Down(0x11) + " WIN_DOWN=" + [KeyState]::Down(0x5B))
Start-Sleep -Milliseconds 600

if ($HoverNums.Count -eq 2) {
    # Park the cursor away from the edge first, then step into the zone so Qt
    # actually sees an enter event (a single SetCursorPos onto an already-hovered
    # area produces no MouseArea::entered).
    [void][UiProbe]::SetCursorPos($HoverNums[0], [math]::Min(600, $HoverNums[1] + 300))
    Start-Sleep -Milliseconds 250
    [void][UiProbe]::SetCursorPos($HoverNums[0], $HoverNums[1] + 6)
    Start-Sleep -Milliseconds 200
    [void][UiProbe]::SetCursorPos($HoverNums[0], $HoverNums[1])
}
# Second step: bar -> panel (the tiled dashboard only opens once the bar itself
# is hovered, not just the top-edge strip).
if ($Hover2Nums.Count -eq 2) {
    Start-Sleep -Milliseconds 450
    [void][UiProbe]::SetCursorPos($Hover2Nums[0], $Hover2Nums[1] - 3)
    Start-Sleep -Milliseconds 200
    [void][UiProbe]::SetCursorPos($Hover2Nums[0], $Hover2Nums[1])
}
if ($ClickNums.Count -eq 2) { [UiProbe]::Click($ClickNums[0], $ClickNums[1]) }

Start-Sleep -Milliseconds $WaitMs

$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$full = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$gfx = [System.Drawing.Graphics]::FromImage($full)
$gfx.CopyFromScreen($bounds.Left, $bounds.Top, 0, 0, $full.Size)
$gfx.Dispose()

if ($RectNums.Count -eq 4 -and $RectNums[2] -gt 0 -and $RectNums[3] -gt 0) {
    $src = New-Object System.Drawing.Rectangle $RectNums[0], $RectNums[1], $RectNums[2], $RectNums[3]
    $crop = New-Object System.Drawing.Bitmap $RectNums[2], $RectNums[3]
    $cg = [System.Drawing.Graphics]::FromImage($crop)
    $cg.DrawImage($full, (New-Object System.Drawing.Rectangle 0, 0, $RectNums[2], $RectNums[3]), $src,
                  [System.Drawing.GraphicsUnit]::Pixel)
    $cg.Dispose()
    $crop.Save($Out)
    $crop.Dispose()
} else {
    $full.Save($Out)
}
$full.Dispose()

if (-not $KeepArmed) { [UiProbe]::ChordUp() }
Write-Output ("SAVED=" + $Out)