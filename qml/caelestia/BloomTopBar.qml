// BloomTopBar — the full-width, edge-anchored status bar that slides down on
// top-edge hover. Left: logo + app launcher. Center: compact status widgets.
// Right: compact media controls + date / time + pin.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root
    BloomShellStyle { id: st }

    // Mirror of CaelestiaShell surface state.
    property bool launcherOpen: false
    property bool panelOpen: false
    property bool pinned: false
    property bool armed: false            // keep-alive gate for sparklines
    readonly property bool hovered: barHover.hovered

    signal toggleLauncher()
    signal togglePanel()
    signal togglePin()
    signal openSettings()

    // Bouncing rhythm for media indicator
    property real topBarAnimTick: 0
    NumberAnimation on topBarAnimTick {
        from: 0; to: Math.PI * 2
        duration: 1600
        loops: Animation.Infinite
        running: musicControl.isPlaying
    }

    // Launcher dropdown is self-managed from the launcher button.
    onToggleLauncher: root.launcherOpen = !root.launcherOpen

    width: parent.width
    height: st.barHeight

    // Full-surface hover catch-all (buttons' own HoverHandlers still fire).
    HoverHandler { id: barHover }

    Rectangle {
        id: barBg
        anchors.fill: parent
        color: Qt.alpha(st.barColor, 0.90)
        border.width: 1
        border.color: st.lineSoft

        // Specular bottom line (Mica Glass edge reflection)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(1, 1, 1, 0.14)
        }
    }

    // Soft elevation shadow — separates the floating bar from the wallpaper
    // the same way the reference shell's panels do. Auto padding lets the
    // blurred shadow render below the bar's own bounds.
    MultiEffect {
        anchors.fill: barBg
        source: barBg
        shadowEnabled: true
        shadowBlur: 0.65
        shadowColor: Qt.rgba(0, 0, 0, 0.45)
        shadowVerticalOffset: 4
        z: -1
    }

    // Compact status chip used in the center group: label + sparkline + value.
    component StatusChip: Item {
        id: c
        required property string label
        required property string value
        required property color sparkColor
        property color sparkFill: Qt.rgba(0.933, 0.70, 0.82, 0.12)
        required property bool armed
        Layout.preferredHeight: 30
        Layout.preferredWidth: 134
        Rectangle {
            anchors.fill: parent; anchors.margins: 1; radius: 15
            color: Qt.alpha(Colours.m3surfaceContainerLow, 0.72)
            border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.22)
            // Specular top highlight
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                anchors.margins: 1; height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.12)
            }
        }
        RowLayout {
            anchors.fill: parent; anchors.margins: 5; spacing: 6
            Text {
                text: c.label; color: st.textLow; font.family: st.fontMono; font.pixelSize: 9
                Layout.alignment: Qt.AlignVCenter
            }
            BloomSparkline {
                Layout.preferredWidth: 54; Layout.preferredHeight: 16
                lineColor: c.sparkColor; fillColor: c.sparkFill; sampling: c.armed
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: c.value; color: st.textHi; font.family: st.fontMono; font.pixelSize: 11
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2
        clip: false

        // ---- LEFT ----
        Row {
            id: leftGroup
            spacing: 10
            Text {
                text: "✦"; color: Colours.m3primary; font.pixelSize: 17
                font.family: st.fontUi; font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                width: 26; height: 30
                transform: Translate { y: -1 }
            }
            Text { text: "Bloom"; color: st.textHi; font.family: st.fontUi; font.pixelSize: 13; font.weight: Font.DemiBold }
            Rectangle { width: 1; height: 20; color: st.lineSoft }
            Item {
                id: btnLaunch; width: st.iconBtnSize; height: st.iconBtnSize
                Rectangle {
                    anchors.fill: parent; anchors.margins: 2; radius: 12
                    color: root.launcherOpen ? st.pinkSoft : (launchHover.hovered ? Qt.alpha(st.textHi, 0.08) : "transparent")
                    border.width: root.launcherOpen ? 1 : 0; border.color: st.pink
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.width { NumberAnimation { duration: 120 } }
                    HoverHandler { id: launchHover }
                    TapHandler { onTapped: root.toggleLauncher() }
                    BloomIcon {
                        anchors.centerIn: parent
                        text: "grid_view"
                        color: root.launcherOpen ? st.pink : st.textMid
                        font.pixelSize: 16
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
            Rectangle { width: 1; height: 20; color: st.lineSoft }
            Row {
                id: ws
                spacing: 4
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        readonly property bool active: workspaceController.currentWorkspace === (index + 1)
                        width: 24; height: 24; radius: 12
                        color: active ? Colours.m3secondaryContainer : (wsHover.hovered ? Qt.alpha(st.textHi, 0.08) : "transparent")
                        border.color: active ? Colours.m3secondary : "transparent"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: wsHover.hovered ? 1.08 : 1
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: wsHover }
                        TapHandler { onTapped: workspaceController.switchTo(index + 1) }
                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: active ? Colours.m3onSecondaryContainer : st.textLow
                            font.family: st.fontMono; font.pixelSize: 10
                            font.weight: active ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
        Item { Layout.fillWidth: true }
        // ---- CENTER ----
        RowLayout { id: centerGroup; spacing: 10
            StatusChip { label: "CPU"; value: systemInfo.cpuUsage + "%"
                sparkColor: systemInfo.cpuUsage > 85 ? st.bad : st.pink; armed: root.armed }
            StatusChip { label: "RAM"; value: systemInfo.memoryUsage + "%"
                sparkColor: st.blue; sparkFill: Qt.rgba(0.575, 0.70, 0.950, 0.13); armed: root.armed }
            StatusChip { label: "NET"; value: "LAN"
                sparkColor: st.green; sparkFill: Qt.rgba(0.337, 0.70, 0.43, 0.10); armed: root.armed }
            // weather summary
            Item {
                Layout.preferredHeight: 30; Layout.preferredWidth: 156
                Rectangle {
                    anchors.fill: parent; anchors.margins: 1; radius: 15
                    color: Qt.alpha(Colours.m3surfaceContainerLow, 0.72)
                    border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.22)
                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        anchors.margins: 1; height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.12)
                    }
                }
                RowLayout {
                    anchors.fill: parent; anchors.margins: 6; spacing: 6
                    BloomIcon {
                        text: {
                            const c = (weatherService.condition || "").toLowerCase()
                            if (c.indexOf("clear") !== -1 || c.indexOf("sunny") !== -1) return "sunny"
                            if (c.indexOf("cloud") !== -1 || c.indexOf("overcast") !== -1 || c.indexOf("くもり") !== -1) return "cloud"
                            if (c.indexOf("rain") !== -1 || c.indexOf("雨") !== -1) return "rainy"
                            if (c.indexOf("snow") !== -1 || c.indexOf("雪") !== -1) return "ac_unit"
                            return "partly_cloudy_day"
                        }
                        font.pixelSize: 15
                        color: Colours.m3primary
                    }
                    Text {
                        text: {
                            const t = (weatherService.temperature + "").replace(/[^0-9\-]/g, "")
                            return t === "" ? "—" : t + "° " + weatherService.condition
                        }
                        color: st.textMid; font.family: st.fontUi; font.pixelSize: 11; font.weight: Font.DemiBold
                        elide: Text.ElideRight; width: 120
                    }
                }
            }
            Rectangle { width: 1; height: 16; color: Qt.alpha(st.lineSoft, 0.7); Layout.alignment: Qt.AlignVCenter }

            // Minimal unboxed clock & date (subtle discernible tones, minimal effects)
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                Text {
                    text: systemInfo.formattedTime
                    color: Qt.alpha(st.textHi, 0.70)
                    font.family: st.fontMono
                    font.pixelSize: 11
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "·"
                    color: Qt.alpha(st.textLow, 0.28)
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: st.shortDate(new Date())
                    color: Qt.alpha(st.textLow, 0.48)
                    font.family: st.fontMono
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        Item { Layout.fillWidth: true }
        // ---- RIGHT ----
        Row { id: rightGroup; spacing: 8
            Item { width: 18 }
            Rectangle {
                id: mPrev
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: mPrevH.hovered ? st.pinkSoft : st.cardColor
                border.width: 1; border.color: st.lineSoft
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: mPrevH.hovered ? 1.06 : 1
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                HoverHandler { id: mPrevH }
                TapHandler { onTapped: musicControl.previous() }
                BloomIcon {
                    anchors.centerIn: parent
                    text: "skip_previous"
                    color: st.textMid
                    font.pixelSize: 16
                }
            }
            Rectangle {
                id: mPlay
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: musicControl.isPlaying ? st.pink : (mPlayH.hovered ? st.pinkSoft : st.cardColor)
                border.color: musicControl.isPlaying ? st.pink : st.lineSoft; border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: mPlayH.hovered ? 1.06 : 1
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                HoverHandler { id: mPlayH }
                TapHandler { onTapped: musicControl.togglePlayPause() }
                BloomIcon {
                    anchors.centerIn: parent
                    text: musicControl.isPlaying ? "pause" : "play_arrow"
                    color: musicControl.isPlaying ? Colours.m3onPrimary : st.textHi
                    font.pixelSize: 16
                }
            }
            Rectangle {
                id: mNext
                width: st.iconBtnSize - 4; height: st.iconBtnSize - 4; radius: st.radiusSharp
                color: mNextH.hovered ? st.pinkSoft : st.cardColor
                border.width: 1; border.color: st.lineSoft
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: mNextH.hovered ? 1.06 : 1
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                HoverHandler { id: mNextH }
                TapHandler { onTapped: musicControl.next() }
                BloomIcon {
                    anchors.centerIn: parent
                    text: "skip_next"
                    color: st.textMid
                    font.pixelSize: 16
                }
            }
            Text {
                text: musicControl.trackTitle === "" ? "Nothing Playing"
                      : (musicControl.trackTitle + (musicControl.artistName !== "" ? " \u00B7 " + musicControl.artistName : ""))
                color: musicControl.trackTitle === "" ? st.textLow : st.textHi
                font.family: st.fontUi; font.pixelSize: 11
                elide: Text.ElideRight; width: 140
                anchors.verticalCenter: parent.verticalCenter
            }
            // Animated mini equalizer indicator when media is playing
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2.5
                height: 12
                visible: musicControl.trackTitle !== ""

                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        width: 2.5
                        radius: 1.25
                        color: musicControl.isPlaying ? st.pink : Qt.alpha(st.textLow, 0.4)
                        anchors.bottom: parent.bottom
                        height: {
                            if (!musicControl.isPlaying) return 3;
                            const phase = (root.topBarAnimTick * (1.8 + index * 0.7)) % (Math.PI * 2);
                            return 3 + 8 * Math.abs(Math.sin(phase));
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
        Rectangle { width: 1; height: 22; color: st.lineSoft }
        Item { width: 12 }
        Row { spacing: 8
            BloomIcon {
                text: systemInfo.volumeMuted ? "volume_off" : "volume_up"
                color: st.textMid
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
                MouseArea { anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: systemInfo.toggleMute() }
            }
            // Mini volume meter — visible track with an animated fill so level
            // changes read as motion, not a jump.
            Item {
                width: 56; height: 5
                anchors.verticalCenter: parent.verticalCenter
                Rectangle { anchors.fill: parent; radius: 2.5; color: st.lineStrong }
                Rectangle {
                    height: parent.height
                    width: parent.width * (systemInfo.volumeMuted ? 0 : systemInfo.volumeLevel / 100)
                    radius: 2.5
                    color: systemInfo.volumeMuted ? st.textOff : st.pink
                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 160 } }
                }
            }
        }
        // quick-settings drawer toggle (notifications / keep awake / toggles)
        Rectangle {
            id: quickBtn
            width: 28; height: 28; radius: st.radiusSharp
            color: quickHover.hovered ? Qt.alpha(st.textHi, 0.08) : st.cardColor
            border.width: 0
            Behavior on color { ColorAnimation { duration: 150 } }
            HoverHandler { id: quickHover }
            TapHandler { onTapped: root.openSettings() }
            BloomIcon {
                anchors.centerIn: parent
                text: "tune"
                color: st.textMid
                font.pixelSize: 15
            }
        }
        // pin toggle (keeps the detail panel open)
        Item { width: 10 }
        Rectangle {
            id: pinBtn
            width: 28; height: 28; radius: st.radiusSharp
            color: root.pinned ? st.pinkSoft : (pinHover.hovered ? Qt.alpha(st.textHi, 0.08) : st.cardColor)
            border.width: root.pinned ? 1 : 0; border.color: st.pink
            Behavior on color { ColorAnimation { duration: 150 } }
            HoverHandler { id: pinHover }
            TapHandler { onTapped: root.togglePin() }
            BloomIcon {
                anchors.centerIn: parent
                text: "push_pin"
                color: root.pinned ? st.pink : st.textLow
                font.pixelSize: 15
                rotation: root.pinned ? 45 : 0
                Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    } // /RowLayout

    BloomAppLauncher {
        id: launcher
        open: root.launcherOpen
        // btnLaunch lives inside the RowLayout (not a parent/sibling), so
        // anchor via a mapped position instead of anchors.
        x: btnLaunch.mapToItem(root, 0, 0).x
        y: btnLaunch.mapToItem(root, 0, btnLaunch.height).y + 4
        z: 50
    }
} // /root


