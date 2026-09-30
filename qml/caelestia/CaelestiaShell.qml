import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root

        readonly property string fontDisplay: "Rubik"

    // --- Redesigned shell surface state -----------------------------------
    property bool barOpen: false            // top bar currently revealed (edge hover / armed / pinned)
    property bool panelOpen: false          // detail panel is hovering-open
    property bool panelPinned: false        // panel held open by user pin
    readonly property bool panelExpanded: panelOpen || panelPinned  // panel visible
    property bool dashboardOpen: false      // legacy alias (kept to avoid breaking external refs)
    property bool rightDrawerOpen: false
    property int activeWorkspace: (typeof workspaceController !== "undefined" && workspaceController)
                                  ? workspaceController.currentWorkspace : 1
    property string wallSrc: ""
    property real lastKeepTime: 0           // hover-grace bookkeeping
    readonly property bool windowAppeared: shellController.armed

    function toggleDashboardPinned(): void {
        // Repurposed: toggles the detail panel pin (and bar/panel reveal).
        if (root.panelPinned) {
            root.panelPinned = false;
            root.panelOpen  = false;
            root.barOpen    = false;
        } else {
            root.barOpen    = true;
            root.panelOpen  = true;
            root.panelPinned = true;
        }
    }

    function noteKeepAlive(): void { root.lastKeepTime = Date.now(); }

    onBarOpenChanged:       root.armHost()
    onPanelExpandedChanged: root.armHost()

    // Keep the host window alive while any chrome is open, then mirror back the
    // chord-re-press disarm so the panel never lingers on a hidden window.
    function armHost(): void {
        shellController.forceArmed = root.barOpen || root.panelExpanded || root.rightDrawerOpen
                                     || (typeof bottomLauncher !== "undefined" && bottomLauncher.open)
                                     || (typeof wallpaperSelector !== "undefined" && wallpaperSelector.visible)
                                     || (typeof themePopover !== "undefined" && themePopover.visible)
                                     || (typeof calculatorModal !== "undefined" && calculatorModal.visible);
    }
    Connections {
        target: shellController
        function onForceArmedChanged(): void {
            if (!shellController.forceArmed) {
                if (root.panelExpanded) {
                    root.panelPinned = false; root.panelOpen = false; root.barOpen = false;
                }
                if (typeof bottomLauncher !== "undefined") bottomLauncher.hideLauncher();
                if (typeof wallpaperSelector !== "undefined") wallpaperSelector.close();
                if (typeof themePopover !== "undefined") themePopover.close();
                if (typeof calculatorModal !== "undefined") calculatorModal.close();
            }
        }
        function onRequestShowLauncher(): void {
            if (typeof bottomLauncher !== "undefined") {
                bottomLauncher.showLauncher();
            }
        }
    }

    function updateWallSrc(): void {
        try {
            const paths = wallpaperService.wallpaperPaths();
            const idx = wallpaperService.currentIndex();
            root.wallSrc = (paths && idx >= 0 && idx < paths.length) ? String(paths[idx]) : "";
        } catch (e) {
            root.wallSrc = "";
        }
    }

    readonly property var cavaBars: (cavaService && cavaService.bars) ? cavaService.bars : []
    readonly property int cavaBarsCount: cavaBars ? cavaBars.length : 0
    readonly property var cavaPeaks: (cavaService && cavaService.peaks) ? cavaService.peaks : []

    function spectrumValue(index: int, count: int): real {
        if (cavaBarsCount === 0) return 0.0;
        const srcIdx = Math.floor(index * cavaBarsCount / Math.max(1, count));
        const val = Number(cavaBars[Math.min(cavaBarsCount - 1, Math.max(0, srcIdx))]);
        return isNaN(val) ? 0.0 : Math.max(0.0, Math.min(1.0, val));
    }

    function spectrumPeak(index: int, count: int): real {
        if (!cavaPeaks || cavaPeaks.length === 0) return 0.0;
        const srcIdx = Math.floor(index * cavaPeaks.length / Math.max(1, count));
        const val = Number(cavaPeaks[Math.min(cavaPeaks.length - 1, Math.max(0, srcIdx))]);
        return isNaN(val) ? 0.0 : Math.max(0.0, Math.min(1.0, val));
    }

    Component.onCompleted: updateWallSrc()

    Connections {
        target: wallpaperService
        function onCurrentWallpaperChanged(): void { root.updateWallSrc(); }
    }

    Shortcut {
        sequence: "Esc"
        enabled: root.barOpen || root.panelExpanded || root.rightDrawerOpen
                 || bottomLauncher.open || wallpaperSelector.visible
                 || themePopover.visible || calculatorModal.visible
        onActivated: {
            root.panelPinned = false;
            root.panelOpen  = false;
            root.barOpen    = false;
            root.rightDrawerOpen = false;
            bottomLauncher.hideLauncher();
            wallpaperSelector.close();
            themePopover.close();
            calculatorModal.close();
        }
    }

    // Seamless hover close: when the surface was revealed by hovering (not
    // pinned), collapse the panel / bar once the cursor leaves everything.
    Timer {
        id: hoverCloseTimer
        interval: 260
        repeat: true
        running: root.barOpen && !root.panelPinned
        onTriggered: {
            if (!topEdgeZone.containsMouse && !bloomBar.hovered
                && !controlPanel.hovered && (Date.now() - root.lastKeepTime) > 320) {
                root.panelOpen = false;
                if (!root.panelPinned)
                    root.barOpen = false;
            }
        }
    }

    // Top edge reveal zone — a thin strip at the very top.
    MouseArea {
        id: topEdgeZone
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 14
        z: 70
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: root.windowAppeared
        onEntered: {
            if (root.windowAppeared) {
                root.barOpen = true;
            }
            root.noteKeepAlive();
        }
        onContainsMouseChanged: root.noteKeepAlive()
    }

    // Bottom edge reveal zone — hover bottom edge to summon Smart Launcher (sample4.png)
    MouseArea {
        id: bottomEdgeZone
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 36
        z: 70
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: root.windowAppeared
        onEntered: {
            if (root.windowAppeared && !bottomLauncher.open) {
                bottomLauncher.showLauncher();
            }
            root.noteKeepAlive();
        }
        onContainsMouseChanged: root.noteKeepAlive()
    }

    // Right edge reveal zone — hover right edge to summon Audio/Brightness sliders & drawer (sample10.png)
    MouseArea {
        id: rightEdgeZone
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 16
        z: 70
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: root.windowAppeared
        onEntered: {
            if (root.windowAppeared) {
                root.rightDrawerOpen = true;
            }
            root.noteKeepAlive();
        }
        onContainsMouseChanged: root.noteKeepAlive()
    }


    // ------------------------------------------------------------- 1. Left Dock
    CaelestiaLeftDock {
        id: leftDock
        activeWorkspace: root.activeWorkspace
        z: 25
        onRequestOpenDashboard: root.toggleDashboardPinned()
        onRequestToggleLock: shellController.toggleLock()
        onRequestOpenSettings: {
            if (typeof shell !== "undefined" && shell.openSettings)
                shell.openSettings();
        }

        transform: Translate {
            x: root.windowAppeared ? 0 : -74
            Behavior on x {
                BloomAnim { type: BloomAnim.DefaultSpatial }
            }
        }
    }

    // ------------------------------------------------------------- 2. Top Bar + Slide-down Control Panel
    // New chrome: a slim status bar anchored to the top edge, revealed by a
    // single-pixel-ish hover strip. Detail cards slide down beneath it.
    Item {
        id: topSurface
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width
        height: bloomBar.height + (root.panelExpanded ? controlPanel.height : 0)
        z: 30
        clip: false

        // ---- status bar itself ----
        BloomTopBar {
            id: bloomBar
            anchors.left: parent.left
            anchors.right: parent.right
            panelOpen: root.panelOpen
            pinned: root.panelPinned
            armed: root.barOpen && root.windowAppeared
            onHoveredChanged: {
                if (bloomBar.hovered && root.barOpen)
                    root.panelOpen = true
            }
            onTogglePin: root.toggleDashboardPinned()
            onTogglePanel: root.panelOpen = !root.panelOpen
            onOpenSettings: root.rightDrawerOpen = true
        }

        // ---- tabbed tile dashboard below the bar ----
        BloomDashPanel {
            id: controlPanel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: bloomBar.bottom
            open: root.panelExpanded
            wallSrc: root.wallSrc
        }

        // Slide the whole stack in/out from the top edge with the authentic
        // M3 expressive motion: spatial spring on open, emphasized on close.
        transform: Translate {
            id: topSurfaceMove
            y: root.barOpen ? 0 : -(bloomBar.height + controlPanel.height + 10)
            Behavior on y {
                BloomAnim { type: root.barOpen ? BloomAnim.DefaultSpatial : BloomAnim.Emphasized }
            }
        }
        opacity: root.barOpen ? 1 : 0
        Behavior on opacity {
            BloomAnim { type: root.barOpen ? BloomAnim.DefaultEffects : BloomAnim.FastEffects }
        }
    }

    // ------------------------------------------------------------- 3. Desktop Background Elements
    // Soft ambient shadow keeps the thin display face legible over light or
    // ---- Clock date/time formatters (bound to systemInfo.formattedTime tick) ----
    readonly property string clockHours: {
        const _ = systemInfo.formattedTime;
        const d = new Date();
        return ("0" + d.getHours()).slice(-2);
    }
    readonly property string clockMinutes: {
        const _ = systemInfo.formattedTime;
        const d = new Date();
        return ("0" + d.getMinutes()).slice(-2);
    }
    readonly property string clockMonth: {
        const _ = systemInfo.formattedTime;
        const d = new Date();
        const m = ["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"];
        return m[d.getMonth()] || "";
    }
    readonly property string clockDay: {
        const _ = systemInfo.formattedTime;
        const d = new Date();
        return ("0" + d.getDate()).slice(-2);
    }
    readonly property string clockWeekday: {
        const _ = systemInfo.formattedTime;
        const d = new Date();
        const w = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
        return w[d.getDay()] || "";
    }

    // ------------------------------------------------------------- 3. Desktop Background Elements
    // Minimal, serene floating desktop clock (unboxed, gentle understated tones, minimal effects)
    Item {
        id: desktopClockCard
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -24
        implicitWidth: clockLayout.implicitWidth
        implicitHeight: clockLayout.implicitHeight
        opacity: (root.panelExpanded || root.barOpen || root.dashboardOpen) ? 0 : 0.72
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 220 } }

        RowLayout {
            id: clockLayout
            anchors.centerIn: parent
            spacing: 20

            // Time Row: Hours : Minutes (soft discernible off-white tones)
            RowLayout {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: root.clockHours
                    font.family: root.fontDisplay
                    font.pixelSize: 84
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.65)
                }

                Text {
                    text: ":"
                    font.family: root.fontDisplay
                    font.pixelSize: 76
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.22)
                    Layout.alignment: Qt.AlignVCenter
                    Layout.topMargin: -8
                }

                Text {
                    text: root.clockMinutes
                    font.family: root.fontDisplay
                    font.pixelSize: 84
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.52)
                }
            }

            // Subtle vertical separator line (soft muted tone)
            Rectangle {
                Layout.preferredWidth: 2
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignVCenter
                radius: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Date Stack (soft discerning hierarchy)
            ColumnLayout {
                spacing: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: root.clockMonth
                    font.family: root.fontDisplay
                    font.pixelSize: 13
                    font.letterSpacing: 4
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.35)
                }

                Text {
                    text: root.clockDay
                    font.family: root.fontDisplay
                    font.pixelSize: 32
                    font.letterSpacing: 1
                    font.weight: Font.Bold
                    color: Qt.rgba(1, 1, 1, 0.60)
                }

                Text {
                    text: root.clockWeekday
                    font.family: root.fontDisplay
                    font.pixelSize: 11
                    font.letterSpacing: 2
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.30)
                }
            }
        }
    }

    // Bottom spectrum — dense mirrored capsules with a breathing gap at the
    // centre; echoes the cover-art visualiser on a wallpaper scale.
    Item {
        id: spectrum
        anchors.left: leftDock.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 28
        anchors.rightMargin: 34
        anchors.bottomMargin: 22
        height: 118
        readonly property int barCount: 96
        readonly property int centerGap: 12
        readonly property real slotW: width / barCount
        readonly property int gapStart: (barCount - centerGap) / 2
        opacity: root.dashboardOpen ? 0.14 : 0.85
        Behavior on opacity { NumberAnimation { duration: 200 } }

        // Living breath wave phase for idle shimmer
        property real ambientPhase: 0
        NumberAnimation on ambientPhase {
            from: 0; to: Math.PI * 2
            duration: 4500
            loops: Animation.Infinite
        }

        transform: Translate {
            y: root.windowAppeared ? 0 : 46
            Behavior on y { BloomAnim { type: BloomAnim.DefaultSpatial } }
        }

        // Mirror the right half onto the left for a symmetric "wings" layout.
        function bandForSlot(slot: int): int {
            return slot < barCount / 2 ? slot : barCount - 1 - slot;
        }

        Repeater {
            model: spectrum.barCount
            Item {
                id: slotItem
                required property int index
                readonly property bool inGap: index >= spectrum.gapStart
                                               && index < spectrum.gapStart + spectrum.centerGap
                readonly property int band: spectrum.bandForSlot(index)
                readonly property real rawLevel: inGap ? 0 : root.spectrumValue(band, spectrum.barCount)
                // Bloom's Living Breath idle wave: rippling organically across the bars when quiet
                readonly property real idleWave: inGap ? 0 : (0.040 * Math.sin((index / spectrum.barCount) * Math.PI) * (0.5 + 0.5 * Math.sin(spectrum.ambientPhase + index * 0.14)))
                readonly property real level: rawLevel > 0.02 ? rawLevel : Math.max(rawLevel, idleWave)
                readonly property real cap: inGap ? 0 : root.spectrumPeak(band, spectrum.barCount)
                readonly property real barWidth: Math.max(3, Math.min(7, spectrum.slotW * 0.40))

                visible: !inGap
                width: barWidth
                height: spectrum.height
                x: (index + 0.5) * spectrum.slotW - width / 2

                // Bloom Glow halo behind bar (radiates when audio levels peak)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: parent.width + 8
                    height: Math.max(6, slotItem.level * spectrum.height + 6)
                    radius: width / 2
                    antialiasing: true
                    color: Qt.alpha(Colours.m3primary, slotItem.level * 0.35)
                    opacity: slotItem.level > 0.12 ? 1.0 : 0.0
                    z: -1
                }

                // Body: driven straight by WASAPI loopback levels with Bloom luminescence
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(4, slotItem.level * spectrum.height)
                    radius: width / 2
                    antialiasing: true
                    color: Qt.alpha(Colours.m3primary, 0.35 + slotItem.level * 0.55)

                    // Subtle specular tip on bar
                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: Math.min(parent.height, 4)
                        radius: width / 2
                        color: Qt.rgba(1, 1, 1, 0.45 * slotItem.level)
                    }
                }

                // Cap: floating peak with crystal glow
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height - Math.max(6, slotItem.cap * spectrum.height) - 6
                    width: parent.width + 2
                    height: 3.5
                    radius: height / 2
                    antialiasing: true
                    opacity: (slotItem.cap > slotItem.level + 0.02) ? 0.95 : 0.0
                    color: Qt.lighter(Colours.m3primary, 1.25)
                }
            }
        }
    }

    // ------------------------------------------------------------- 5. Right Drawer
    CaelestiaRightDrawer {
        id: rightDrawer
        open: root.rightDrawerOpen
        z: 40
        onRequestOpenSettings: {
            if (typeof shell !== "undefined" && shell.openSettings)
                shell.openSettings();
        }
    }

    // ------------------------------------------------------------- 6. Bottom Edge Launcher (sample4.png, 13, 14, 15)
    CaelestiaBottomLauncher {
        id: bottomLauncher
        anchors.fill: parent
        z: 1100
    }

    // ------------------------------------------------------------- 7. Modals: Wallpaper, Theme, Calculator
    WallpaperSelector {
        id: wallpaperSelector
        anchors.fill: parent
        z: 1200
    }

    ThemePopover {
        id: themePopover
        anchors.fill: parent
        z: 1300
    }

    BloomCalculatorModal {
        id: calculatorModal
        anchors.fill: parent
        z: 1400
    }
}

