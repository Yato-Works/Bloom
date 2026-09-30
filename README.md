<a name="top"></a>

# Bloom 🌸

<p align="center">
  <a href="./README.ja.md">日本語 (Japanese)</a> | <strong>English</strong>
</p>

> **Status:** Operational / Active Development  
> **Architecture:** Bloom_Core Native Engine (Modern C++20 + Qt 6.11 QML)  
> **Platform:** Windows 10 / 11 (64-bit)  
> **Inspiration & Attribution:** Deeply inspired by <a href="https://github.com/caelestia-dots/shell">Caelestia Shell</a> (GPL-3.0)  

<p align="center">
  <img src="assets/screenshots/hero_media_cava.png" alt="Bloom Windows Desktop Shell Live Experience" width="100%" />
</p>

<p align="center">
  <strong>Transcendent, Breathing Desktop Shell & Native Audio-Reactive Runtime for Windows</strong><br>
  <em>"Bringing Linux-grade aesthetic liberation, fluid motion, and deep ricing freedom natively to Windows."</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Status-Operational-brightgreen" alt="Status" />
  <img src="https://img.shields.io/badge/Platform-Windows_10%20%2F%2011-0078D6?logo=windows" alt="Platform" />
  <img src="https://img.shields.io/badge/Qt-6.5%2B%20%7C%206.11-41CD52?logo=qt" alt="Qt" />
  <img src="https://img.shields.io/badge/C%2B%2B-20-00599C?logo=c%2B%2B" alt="C++" />
  <img src="https://img.shields.io/badge/Audio-WASAPI%20Loopback%20%2B%20CAVA-blueviolet" alt="CAVA" />
  <img src="https://img.shields.io/badge/Backlight-Dxva2%20DDC%2FCI-informational" alt="DDC/CI" />
  <img src="https://img.shields.io/badge/Design-Caelestia_Inspired-ff69b4" alt="Caelestia" />
  <img src="https://img.shields.io/badge/License-GPLv3-blue" alt="License" />
</p>

---

## 🌌 Overview & The Ricing Manifesto

> *"Experience the breathtaking beauty, fluid motion, and serene elegance of modern Linux desktop customization — natively engineered for Windows."*

**Bloom** is an open-source, hardware-accelerated desktop shell for Windows 10 and 11, crafted with **Qt 6 (QML)**, modern **C++20**, and powered by the **Bloom_Core** architecture. Designed to stay completely out of your way until called, Bloom awakens with responsive edge-hover gestures and hotkeys (`Ctrl + Win`) to reveal a living, wallpaper-reactive interface.

### Breaking the Mold: Linux-Grade Freedom on Windows
For years, the Unix customization community has enjoyed unparalleled aesthetic liberation with tools like **Hyprland**, **Waybar**, and **Quickshell**. Meanwhile, Windows desktop customization has all too often felt constrained — either boxed into rigid taskbars or forced into sluggish, high-latency web wrappers.

**Bloom and Bloom_Core exist to shatter that boundary.** We believe that choosing Windows should never mean sacrificing fluid beauty, deep customization, or lightweight performance. Bloom is not merely a finished shell — it is an open invitation for developers, designers, and ricing enthusiasts to harness **Bloom_Core**, hack their desktop environments, and craft their own visionary desktop experiences without compromise!

---

## 📸 Interface Showcase

### 1. Floating Center Island & Unboxed Minimalist Clock (`Hover Top Edge` / `Ctrl + Win`)
- **Minimalist Floating Typography**: Free of boxed enclosures and distracting borders, displaying time in a delicate, understated off-white tone that rests naturally on any wallpaper.
- **Top Island Status Bar**: Slides down smoothly on top-edge hover with workspace indicators, CPU/RAM/LAN resource chips, live weather conditions, and mini media playback indicators.

### 2. Comprehensive Dashboard & Meteorological Weather Station
A complete telemetry and weather control center sliding down seamlessly from the top edge.

<p align="center">
  <img src="assets/screenshots/dashboard_overview.png" alt="Dashboard & Notifications Drawer" width="49%" />
  <img src="assets/screenshots/weather_forecast.png" alt="Detailed Weather & 7-Day Forecast" width="49%" />
</p>
<p align="center">
  <em><b>Left:</b> Dashboard Tab with quick toggles, mini player, and notification drawer &bull; <b>Right:</b> Weather Tab with 7-day forecast & active CAVA audio visualizer</em>
</p>

- **Dashboard Tab**: Living telemetry cards for CPU, GPU, memory, quick power toggles, and notification drawer with "Keep Awake" utility.
- **Media Tab**:
  - **Radial Spectrum**: 32-ray radial CAVA visualizer blooming dynamically around circular album artwork.
  - **Linear Spectrum**: 48-bar real-time audio equalizer reacting smoothly to music playback with organic fallback waves.
  - **Playback Controls & Metadata**: Track title, artist, seekable progress bar, animated equalizer badges, and playful animated Bongo Cat!
- **Weather Tab**: Dynamic hourly & weekly forecast with localized condition icons, atmospheric pressure, humidity, feels-like temperature, and wind velocity.
- **Performance Tab**: Deep hardware telemetry and system health graphs.

### 3. Smart Bottom Launcher & Command Palette (`Hover Bottom Edge`)
Moves into view with responsive fluid physics when moving the cursor to the bottom screen edge.

<p align="center">
  <img src="assets/screenshots/app_launcher_grid.png" alt="App Launcher Grid" width="49%" />
  <img src="assets/screenshots/command_palette.png" alt="Command Palette Runner" width="49%" />
</p>
<p align="center">
  <em><b>Left:</b> Squircle App Quick-Launch Grid &bull; <b>Right:</b> Command Palette (<kbd>&gt;</kbd>) for Wallpapers, Schemes, & System Utilities</em>
</p>

- **Quick-Launch Squircle Grid**: Fast, high-DPI access to frequent applications (Chrome, VS Code, Spotify, Terminal, Settings).
- **Inline Command Palette (`>`)**:
  - `>wallpaper`: Horizontal carousel preview to switch Windows wallpapers and dynamically regenerate Material You theme colors on the fly. Automatically scans `%USERPROFILE%\Pictures\Bloom-Wallpapers`, `%USERPROFILE%\Documents\Bloom-Wallpapers`, or `wallpapers/`. *(🎨 Looking for curated wallpapers? Check out [**Bloom_Wallpapers**](https://github.com/Yato-Works/Bloom_Wallpapers)!)*
  - `>scheme`: Switch between Catppuccin (Mocha, Macchiato, Frappé, Latte), Tokyo Night, Dracula, and Nord palettes with split swatches.
  - `>calc`: Instant mathematical expression evaluation powered by built-in expression parser (Qalc-inspired).
  - `>lock`, `>light`, `>dark`, `>snip`, `>folder`, and more.

### 4. Physical Hardware DDC/CI & Volume Edge Sliders (`Hover Right Edge`)
Interacts with physical monitors using **Dxva2 (DDC/CI)** and GDI gamma ramps. Adjust physical brightness and system volume directly from the screen edge with wheel scroll or mouse drag.

---

## ⚡ Technical Highlights

- 🌸 **Bloom_Core Native Foundation**:
  - Engineered in pure **C++20** and **Qt 6.5+ (QML)**. Completely avoids Electron, Chromium, or web-view overhead, maintaining ultra-low CPU and memory footprints.
- 🎵 **In-Engine WASAPI Loopback & CAVA DSP**:
  - Real-time DSP FFT frequency analysis pipeline directly sampling system audio output via Windows WASAPI loopback, driving 32-ray radial and 48-bar linear equalizers without external audio daemons.
- 🎨 **Dynamic Material You Color Engine**:
  - Algorithmic color extraction directly sampled from the user's active desktop wallpaper with automatic contrast calculations and Catppuccin / Tokyo Night / Nord color schemes.
- 🖥️ **True Hardware DDC/CI Monitor Communication**:
  - Direct Win32 `dxva2.dll` physical monitor VCP communication adjusting true hardware backlight and GDI gamma ramps.
- 🎛️ **Windows GSMTC Media Transport Integration**:
  - Full two-way metadata and control synchronization with Spotify, YouTube, browsers, and Windows media sessions.
- 🐈 **Interactive Micro-Delights**:
  - Playful audio-reactive Bongo Cat, bounce-back equalizers, and seamless edge hitboxes.

<details>
<summary>🔍 <strong>View In-Engine Real-Time WASAPI CAVA Frequency Processor (C++20: <code>src/services/CavaService.cpp</code>)</strong></summary>

```cpp
// In-place iterative radix-2 FFT (n must be a power of two)
template <typename T>
void fftInPlace(std::vector<T> &re, std::vector<T> &im)
{
    const size_t n = re.size();
    for (size_t i = 1, j = 0; i < n; ++i) {
        size_t bit = n >> 1;
        for (; j & bit; bit >>= 1)
            j ^= bit;
        j ^= bit;
        if (i < j) {
            std::swap(re[i], re[j]);
            std::swap(im[i], im[j]);
        }
    }
    for (size_t len = 2; len <= n; len <<= 1) {
        const double ang = -2.0 * M_PI / static_cast<double>(len);
        const double wr = std::cos(ang);
        const double wi = std::sin(ang);
        for (size_t i = 0; i < n; i += len) {
            double curWr = 1.0, curWi = 0.0;
            for (size_t k = 0; k < len / 2; ++k) {
                const size_t a = i + k, b = a + len / 2;
                const double ur = re[a], ui = im[a];
                const double vr = re[b] * curWr - im[b] * curWi;
                const double vi = re[b] * curWi + im[b] * curWr;
                re[a] = ur + vr; im[a] = ui + vi;
                re[b] = ur - vr; im[b] = ui - vi;
                const double nextWr = curWr * wr - curWi * wi;
                curWi = curWr * wi + curWi * wr;
                curWr = nextWr;
            }
        }
    }
}
```
</details>

---

## 🎮 Keybindings & Gestures

| Trigger / Hotkey | Action | Description |
|---|---|---|
| **Hover Top Edge** | **Slide Down Top Bar & Dashboard** | Reveals minimal clock, telemetry chips, and full dashboard drawer |
| **Hover Bottom Edge** | **Slide Up Smart App Launcher** | Reveals squircle application grid and command palette runner |
| **Hover Right Edge** | **Reveal Volume & DDC/CI Sliders** | Adjusts physical backlight and master volume via edge scroll |
| **`Ctrl + Win`** | **Arm / Toggle Bloom Shell Overlay** | Manually triggers the Bloom shell overlay and interactive widgets |
| **`Ctrl + Win + Space`** | **Pin / Unpin Overlay** | Locks overlay in an armed state without requiring key holds |
| **`Esc` or Background Click** | **Dismiss Panels** | Smoothly dismisses active modals, drawers, and popups |

---

## 💖 Upstream Attribution: Caelestia Shell

Bloom was born out of profound love and respect for **[Caelestia Shell](https://github.com/caelestia-dots/shell)**, created by the caelestia-dots community for Linux (Hyprland / Quickshell).

* **Upstream Project**: [https://github.com/caelestia-dots/shell](https://github.com/caelestia-dots/shell)
* **Our Mission & Relationship**:
  1. **Faithful Windows Architecture**: Caelestia is intrinsically tied to Linux compositor ecosystems (Wayland/Hyprland/Quickshell). Bloom reimagines and translates that iconic visual language to run natively on the Windows subsystem.
  2. **Native Windows Backend Integration**: Rather than a web-wrapper or imitation, Bloom connects Caelestia-styled QML components directly to Windows APIs (Dxva2, WASAPI, GSMTC, Win32 registry & wallpaper engine).
  3. **Original Polish & Refinement**: Taking the rock-solid Caelestia design language, Bloom introduces thoughtful adaptations suited for high-DPI Windows workflows, unboxed floating clocks, and lively organic equalizer animations.

*All adapted QML assets are distributed under the **GNU General Public License v3.0 (GPL-3.0)** in full compliance with upstream terms. See [`NOTICE`](NOTICE) and [`LICENSE`](LICENSE) for complete legal attribution.*

---

## 📂 Repository Layout

```text
Bloom/
├── assets/              Fonts, icons, Bongo Cat animations, and UI screenshots
│   ├── fonts/           MaterialSymbolsOutlined icon font
│   └── screenshots/     Curated high-resolution interface captures
├── src/                 C++20 native service layer and Win32 integration
│   ├── main.cpp         Application entry point, single-instance lock, crash handler
│   └── services/        Bloom_Core services (CAVA DSP, WASAPI, GSMTC, ThemeBridge, DDC/CI)
├── qml/                 Declarative Qt Quick / QML modular shell components
│   ├── Main.qml         Master window host and edge gesture hitbox coordinator
│   ├── components/      Glass cards, modals, sliders, and telemetry rings
│   └── caelestia/       Caelestia-adapted floating panels, drawers, and docks
├── CMakeLists.txt       CMake build definition with Qt 6 standard setup
├── LICENSE              GNU General Public License v3.0
└── NOTICE               Legal attribution and upstream copyright notices
```

---

## 🚀 Getting Started

### Pre-Built Binaries
> **Looking for ready-to-use binaries?**  
> Skip compiling from source! Check out the [Releases](https://github.com/Yato-Works/Bloom/releases) page to download the latest portable `.zip` package. Unzip and launch `Bloom.exe` immediately!

### Building from Source

#### Prerequisites
- **OS**: Windows 10 or 11 (64-bit)
- **Framework**: Qt 6.5+ (Qt 6.11 recommended, with `Qt Quick`, `Qt QML`, `Quick Controls 2`, `Quick Layouts`, `Quick Effects`)
- **Compiler**: C++20 compliant compiler:
  - **MinGW 64-bit** (GCC 13+ bundled with Qt / MSYS2) or **MSVC 2022**
- **Build System**: CMake 3.25+ & Ninja
- **Built-in Audio & DSP**: WASAPI Audio Loopback, CAVA FFT analysis, and Material You color generation are fully self-contained in modern C++20 — zero external CAVA daemons or third-party package managers required.

#### Command Line Build (MinGW / MSVC)
```powershell
# Clone repository (recursive ensures any present or future submodules are fetched)
git clone --recursive https://github.com/Yato-Works/Bloom.git
cd Bloom

# Configure
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build --config Release
```

#### Qt Creator
1. Open `CMakeLists.txt` in **Qt Creator**.
2. Select the **Desktop Qt 6.11.x MinGW 64-bit** kit.
3. Click **Build** and **Run** (`Ctrl + R`).

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
We inherit and honor the design vision of Caelestia Shell and develop this work alongside the global open-source community.  
See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE) for complete terms.

<div align="right">
  <a href="#top"><b>Back to top ↑</b></a>
</div>
