# Bloom

Bloom is a modular desktop **shell** built with Qt 6 / QML — Linux-widget vibes
on Windows. It stays hidden until you hold a key chord, then dims the desktop
and reveals edge hit-zones (no permanent bars).

## Hold shell (primary UX)

| 操作 | 動作 |
|---|---|
| **Hold `Ctrl + Win`** | Shell armed — light dim (clicks absorbed) |
| Move cursor to **top edge** | Top widgets slide in (clock / weather / system) |
| Move cursor to **bottom edge** | Bottom widgets slide in (wallpaper / music / workspace) |
| Keep cursor on panel | Panel stays open (mode β) |
| **Release keys** | Everything closes (B1) |

Optional chord: `shellController.setUseWinShift(true)` → hold `Win + Shift`
instead (more OS conflicts; off by default = A2).

## Legacy single-shot hotkeys

Still registered via `GlobalShortcutService` (`Ctrl+Alt` + letter). The main
interaction is now the hold shell above.

## Included UI foundation

- Hold-to-arm shell with dim + invisible edge hitboxes
- Top / bottom glass widget panels
- Theme tokens, `GlassPanel`, metric rings, wallpaper card
- Frameless always-on-top host window (hidden when disarmed)

## Build

Install Qt 6.5 or later with the Core, Gui, Qml, and Quick modules, plus a C++20
compiler and CMake generator (Visual Studio Build Tools or Ninja). Then run:

```powershell
cmake -S . -B build
cmake --build build --config Release
```

The sample `WeatherService` currently supplies a fixture. Replace its
`applyDemoForecast()` implementation with an asynchronous `ApiClient` call
without changing QML bindings or the service's public API.

Run `build-mingw/Bloom.exe` after deployment. The process starts hidden and
keeps running until closed; use the shortcut to summon the overlay.
