import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

// Caelestia-style left rail — quick toggles (Bluetooth / Wi-Fi / Mic /
// Night light), live workspaces, lock. Bluetooth opens a small popover
// with Enabled / Discovering switches, exactly like the reference shell.
Item {
    id: root

    property int activeWorkspace: 1
    readonly property string fontDisplay: "Rubik"

    // Quick-toggle state (local stand-ins for Windows radios)
    property bool bluetoothEnabled: true
    property bool bluetoothDiscovering: false
    property bool wifiEnabled: true
    property bool micMuted: false
    property bool nightLightEnabled: false
    property bool btPopoverOpen: false

    signal requestOpenDashboard()
    signal requestToggleLock()
    signal requestOpenSettings()

    width: 54
    height: 404
    anchors.left: parent.left
    anchors.leftMargin: 14
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        id: railBg
        anchors.fill: parent
        radius: 27
        color: Qt.alpha(Colours.m3surfaceContainerLowest, 0.90)
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.24)

        // Specular top highlight (refraction edge)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1.2
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.16)
        }
    }

    // Bloom living breath subtle ambient aura
    Rectangle {
        anchors.centerIn: railBg
        width: railBg.width + 12
        height: railBg.height + 12
        radius: railBg.radius + 6
        color: Qt.alpha(Colours.m3primary, 0.06)
        z: -2
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.16; duration: 3000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.04; duration: 3000; easing.type: Easing.InOutSine }
        }
    }

    // Floating-rail elevation shadow, matching the reference shell's panels.
    MultiEffect {
        anchors.fill: railBg
        source: railBg
        shadowEnabled: true
        shadowBlur: 0.6
        shadowColor: Qt.rgba(0, 0, 0, 0.5)
        shadowVerticalOffset: 5
        z: -1
    }

    // Reusable toggle icon button (Material Symbols glyphs via ligature name)
    component RailButton: Rectangle {
        id: railBtn
        property string glyph: ""
        property bool active: false
        property bool danger: false
        signal activated()

        Layout.alignment: Qt.AlignHCenter
        width: 38
        height: 38
        radius: 19
        color: active ? Colours.m3secondaryContainer
            : (hover.hovered ? Qt.alpha(Colours.m3primary, 0.14) : "transparent")
        Behavior on color { ColorAnimation { duration: 150 } }
        scale: hover.hovered ? 1.08 : 1
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: railBtn.activated() }

        BloomIcon {
            anchors.centerIn: parent
            text: railBtn.glyph
            color: railBtn.danger && hover.hovered ? Colours.m3error
                 : railBtn.active ? Colours.m3onSecondaryContainer
                 : Colours.m3onSurfaceVariant
            font.pixelSize: 18
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 11
        anchors.bottomMargin: 11
        spacing: 6

        // Dashboard button
        RailButton {
            glyph: "dashboard"
            active: true
            onActivated: root.requestOpenDashboard()
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            width: 22
            height: 1
            color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        }

        // Bluetooth — opens the popover with Enabled / Discovering switches
        RailButton {
            id: btBtn
            glyph: "bluetooth"
            active: root.bluetoothEnabled || root.btPopoverOpen
            onActivated: {
                root.btPopoverOpen = !root.btPopoverOpen;
                if (root.btPopoverOpen && root.bluetoothEnabled)
                    root.bluetoothDiscovering = true;
            }
        }

        // Wi-Fi
        RailButton {
            glyph: "wifi"
            active: root.wifiEnabled
            onActivated: root.wifiEnabled = !root.wifiEnabled
        }

        // Mic
        RailButton {
            glyph: root.micMuted ? "mic_off" : "mic"
            active: !root.micMuted
            onActivated: root.micMuted = !root.micMuted
        }

        // Night light
        RailButton {
            glyph: "dark_mode"
            active: root.nightLightEnabled
            onActivated: root.nightLightEnabled = !root.nightLightEnabled
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 2
            width: 22
            height: 1
            color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        }

        // Workspace pills — live-bound to the virtual desktop state
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Repeater {
                model: 5
                Rectangle {
                    id: wsPill
                    required property int index
                    readonly property bool active: root.activeWorkspace === (index + 1)

                    width: 30
                    height: 30
                    radius: active ? 15 : 9
                    color: active ? Colours.m3secondaryContainer
                        : (wsHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent")

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on radius { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    scale: wsHover.hovered && !active ? 1.08 : 1
                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                    HoverHandler { id: wsHover }
                    TapHandler { onTapped: workspaceController.switchTo(wsPill.index + 1) }

                    Text {
                        anchors.centerIn: parent
                        text: wsPill.index + 1
                        color: wsPill.active ? Colours.m3onSecondaryContainer : Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                        font.weight: wsPill.active ? Font.Bold : Font.Normal
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Lock button
        RailButton {
            glyph: "power_settings_new"
            danger: true
            onActivated: root.requestToggleLock()
        }
    }

    // ------------------------------------------------------------ Bluetooth popover
    Rectangle {
        id: btPopover
        visible: opacity > 0
        opacity: root.btPopoverOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        x: parent.width + 12
        y: 46
        width: 250
        height: btColumn.implicitHeight + 32
        radius: 24
        color: Colours.m3surfaceContainerLowest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.30)

        // Specular top highlight
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 1; height: 1.2; radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.14)
        }

        // Ambient gradient
        Rectangle {
            anchors.fill: parent; radius: parent.radius; z: -1
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.alpha(Colours.m3primaryContainer, 0.04) }
                GradientStop { position: 1; color: "transparent" }
            }
        }

        // Slide-in from behind the rail — small popover gets the fast spatial
        // spring from the M3 expressive set.
        transform: Translate {
            x: root.btPopoverOpen ? 0 : -16
            Behavior on x {
                BloomAnim { type: BloomAnim.FastSpatial }
            }
        }

        ColumnLayout {
            id: btColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header with icon badge
            RowLayout {
                spacing: 8
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                    BloomIcon { anchors.centerIn: parent; text: "bluetooth"; color: Colours.m3primary; font.pixelSize: 15 }
                }
                Text {
                    text: "Bluetooth"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
            }

            // Enabled row
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Enabled"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                SwitchButton { checked: root.bluetoothEnabled; onToggled: (val) => root.bluetoothEnabled = val }
            }

            // Discovering row
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Discovering"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                SwitchButton {
                    checked: root.bluetoothDiscovering
                    enabled: root.bluetoothEnabled
                    onToggled: (val) => root.bluetoothDiscovering = val
                }
            }

            // Status text with icon
            RowLayout {
                spacing: 5
                BloomIcon {
                    text: root.bluetoothEnabled ? (root.bluetoothDiscovering ? "search" : "bluetooth_searching") : "bluetooth_disabled"
                    color: Colours.m3onSurfaceVariant; font.pixelSize: 13
                }
                Text {
                    text: root.bluetoothEnabled
                        ? (root.bluetoothDiscovering ? "Searching for devices…" : "0 devices available")
                        : "Bluetooth is off"
                    color: Colours.m3onSurfaceVariant
                    font.family: root.fontDisplay
                    font.pixelSize: 11
                }
            }

            // Open settings pill
            Rectangle {
                Layout.fillWidth: true
                height: 38
                radius: 19
                color: Colours.m3primary
                opacity: setHover.hovered ? 0.88 : 1
                Behavior on opacity { NumberAnimation { duration: 140 } }
                scale: setHover.hovered ? 1.02 : 1.0
                Behavior on scale { NumberAnimation { duration: 120 } }

                // Specular top highlight
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 1; height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

                HoverHandler { id: setHover; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        root.btPopoverOpen = false;
                        root.requestOpenSettings();
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    BloomIcon {
                        text: "settings"
                        color: Colours.m3onPrimary
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Open settings"
                        color: Colours.m3onPrimary
                        font.family: root.fontDisplay
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}

