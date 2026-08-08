import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelWidth: 380

    // System Control State
    property int volumeLevel: 72
    property bool isMuted: false
    property int brightnessLevel: 85

    property bool audioDevicesExpanded: false
    property bool wifiListExpanded: false

    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool nightLightEnabled: false
    property bool powerSaverEnabled: false

    property string currentAudioDevice: "Speakers (Realtek Audio)"

    width: panelWidth
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.topMargin: 36
    anchors.bottomMargin: 36

    opacity: open ? 1 : 0

    transform: Translate {
        x: root.open ? 0 : (root.panelWidth + 40)
        Behavior on x {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutExpo
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -30
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: {
            root.panelHovered = containsMouse
            if (containsMouse) shellController.notifyCursorEnter(ShellController.Right)
            else shellController.notifyCursorLeave(ShellController.Right)
        }
    }

    GlassPanel {
        anchors.fill: parent
        anchors.rightMargin: 20
        tint: Qt.rgba(0.07, 0.08, 0.11, 0.94)
        elevated: true
        radius: 28

        Flickable {
            anchors.fill: parent
            anchors.margins: 18
            contentWidth: width
            contentHeight: mainCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: mainCol
                width: parent.width
                spacing: 16

                // Bloom User Profile & Power Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        implicitWidth: 40
                        implicitHeight: 40
                        radius: 20
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                        border.width: 1.5
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)

                        Text {
                            anchors.centerIn: parent
                            text: "👤"
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.fillWidth: true

                        Text {
                            text: "Bloom User"
                            color: "#ffffff"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Text {
                            text: systemInfo.hostName !== "" ? systemInfo.hostName : "Desktop PC"
                            color: Qt.rgba(1, 1, 1, 0.45)
                            font.pixelSize: 11
                        }
                    }

                    // Power / Lock Quick Actions
                    RowLayout {
                        spacing: 6

                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 32
                            radius: 16
                            color: powerMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.3) : Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.1)

                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                color: powerMouse.containsMouse ? "#ff5555" : Qt.rgba(1, 1, 1, 0.7)
                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: powerMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // ============================================================
                // 🎨 Bloom 7-Theme Switcher Section
                // ============================================================
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "🎨 Color Palette Theme"
                            color: Theme.primary
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: Theme.themeName
                            color: Theme.accent
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: Theme.availableThemes()

                            Rectangle {
                                implicitWidth: themeBtnRow.implicitWidth + 16
                                implicitHeight: 28
                                radius: 14
                                color: Theme.themeName === modelData ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28) : Qt.rgba(1, 1, 1, 0.06)
                                border.width: 1
                                border.color: Theme.themeName === modelData ? Theme.primary : Qt.rgba(1, 1, 1, 0.12)

                                RowLayout {
                                    id: themeBtnRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        text: modelData === "Latte" ? "☀️" :
                                              modelData === "Cyberpunk Neon" ? "⚡" :
                                              modelData === "Tokyo Night" ? "🌌" :
                                              modelData === "Rose Pine" ? "🌹" :
                                              modelData === "Nord Frost" ? "❄️" :
                                              modelData === "Emerald Aurora" ? "❇️" :
                                              modelData === "Frappé" ? "🧋" : "☕"
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        text: modelData
                                        color: Theme.themeName === modelData ? "#ffffff" : Qt.rgba(1, 1, 1, 0.7)
                                        font.pixelSize: 11
                                        font.weight: Theme.themeName === modelData ? Font.Bold : Font.Normal
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Theme.setThemeByName(modelData)
                                }
                            }
                        }
                    }
                }

                // ============================================================
                // Pure Volume & Brightness Section (Bloom Authentic Style)
                // ============================================================
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Pure Volume Slider Bar (🔊 ───────────○── 72%)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 16
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 12

                            Rectangle {
                                implicitWidth: 30
                                implicitHeight: 30
                                radius: 15
                                color: root.isMuted ? Qt.rgba(1, 0.3, 0.3, 0.25) : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)

                                Text {
                                    anchors.centerIn: parent
                                    text: root.isMuted ? "🔇" : (root.volumeLevel > 50 ? "🔊" : "🔉")
                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.isMuted = !root.isMuted
                                }
                            }

                            Slider {
                                id: volumeSlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: root.volumeLevel
                                onValueChanged: {
                                    root.volumeLevel = Math.round(value)
                                    if (root.volumeLevel > 0) root.isMuted = false
                                }

                                background: Rectangle {
                                    x: volumeSlider.leftPadding
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 180
                                    implicitHeight: 8
                                    width: volumeSlider.availableWidth
                                    height: implicitHeight
                                    radius: 4
                                    color: Qt.rgba(1, 1, 1, 0.1)

                                    Rectangle {
                                        width: volumeSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: Theme.primary
                                        radius: 4
                                    }
                                }
                                handle: Rectangle {
                                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: "#ffffff"
                                    border.width: 2
                                    border.color: Theme.primary
                                }
                            }

                            Text {
                                text: root.isMuted ? "0%" : root.volumeLevel + "%"
                                color: Theme.primary
                                font.pixelSize: Theme.fontSM
                                font.weight: Font.Bold
                                Layout.preferredWidth: 36
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    // Pure Brightness Slider Bar (☀️ ───────────○── 85%)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 16
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 12

                            Rectangle {
                                implicitWidth: 30
                                implicitHeight: 30
                                radius: 15
                                color: Qt.rgba(1.0, 0.7, 0.3, 0.2)

                                Text {
                                    anchors.centerIn: parent
                                    text: "☀️"
                                    font.pixelSize: 13
                                }
                            }

                            Slider {
                                id: brightnessSlider
                                Layout.fillWidth: true
                                from: 10
                                to: 100
                                value: root.brightnessLevel
                                onValueChanged: root.brightnessLevel = Math.round(value)

                                background: Rectangle {
                                    x: brightnessSlider.leftPadding
                                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 180
                                    implicitHeight: 8
                                    width: brightnessSlider.availableWidth
                                    height: implicitHeight
                                    radius: 4
                                    color: Qt.rgba(1, 1, 1, 0.1)

                                    Rectangle {
                                        width: brightnessSlider.visualPosition * parent.width
                                        height: parent.height
                                        color: "#cba6f7"
                                        radius: 4
                                    }
                                }
                                handle: Rectangle {
                                    x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    color: "#ffffff"
                                    border.width: 2
                                    border.color: "#cba6f7"
                                }
                            }

                            Text {
                                text: root.brightnessLevel + "%"
                                color: "#cba6f7"
                                font.pixelSize: Theme.fontSM
                                font.weight: Font.Bold
                                Layout.preferredWidth: 36
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // ============================================================
                // Bloom 2x2 Large Quick Toggles Grid
                // ============================================================
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    // Wi-Fi Quick Tile
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 16
                        color: root.wifiEnabled ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.wifiEnabled ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "📶"; font.pixelSize: 16 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Wi-Fi"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                Text { text: root.wifiEnabled ? "Connected" : "Off"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 10 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.wifiEnabled = !root.wifiEnabled
                        }
                    }

                    // Bluetooth Quick Tile
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 16
                        color: root.bluetoothEnabled ? Qt.rgba(0.5, 0.7, 1.0, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.bluetoothEnabled ? Qt.rgba(0.5, 0.7, 1.0, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "🌐"; font.pixelSize: 16 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Bluetooth"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                Text { text: root.bluetoothEnabled ? "On" : "Off"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 10 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.bluetoothEnabled = !root.bluetoothEnabled
                        }
                    }

                    // Night Light Tile
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 16
                        color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "🌙"; font.pixelSize: 16 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Night Light"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                Text { text: root.nightLightEnabled ? "Active" : "Off"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 10 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nightLightEnabled = !root.nightLightEnabled
                        }
                    }

                    // Power Saver Tile
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 16
                        color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "🔋"; font.pixelSize: 16 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Power Saver"; color: "#ffffff"; font.pixelSize: 12; font.weight: Font.Bold }
                                Text { text: root.powerSaverEnabled ? "Saving" : "Normal"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 10 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.powerSaverEnabled = !root.powerSaverEnabled
                        }
                    }
                }

                // Media Control Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 76
                    radius: 16
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            implicitWidth: 46
                            implicitHeight: 46
                            radius: 10
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                            border.width: 1
                            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)

                            Text { anchors.centerIn: parent; text: "🎵"; font.pixelSize: 22 }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: (musicControl && musicControl.trackTitle) ? musicControl.trackTitle : "Bloom Audio Player"
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                text: (musicControl && musicControl.artistName) ? musicControl.artistName : "Now Playing"
                                color: Qt.rgba(1, 1, 1, 0.5)
                                font.pixelSize: 10
                            }

                            ProgressBar {
                                Layout.fillWidth: true
                                implicitHeight: 3
                                value: 0.45
                            }
                        }

                        RowLayout {
                            spacing: 6
                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
                                color: Qt.rgba(1, 1, 1, 0.08)
                                Text { anchors.centerIn: parent; text: "⏮"; color: "#fff"; font.pixelSize: 10 }
                                MouseArea { anchors.fill: parent; onClicked: musicControl.previous() }
                            }
                            Rectangle {
                                implicitWidth: 34
                                implicitHeight: 34
                                radius: 17
                                color: Theme.primary
                                Text { anchors.centerIn: parent; text: musicControl.isPlaying ? "⏸" : "▶"; color: "#fff"; font.pixelSize: 11 }
                                MouseArea { anchors.fill: parent; onClicked: musicControl.playPause() }
                            }
                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
                                color: Qt.rgba(1, 1, 1, 0.08)
                                Text { anchors.centerIn: parent; text: "⏭"; color: "#fff"; font.pixelSize: 10 }
                                MouseArea { anchors.fill: parent; onClicked: musicControl.next() }
                            }
                        }
                    }
                }

                // ============================================================
                // Separate Connections & Audio Devices Dropdown Cards
                // ============================================================

                // Audio Output Device Selection Card
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 14
                        color: audioBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "🎧"; font.pixelSize: 14 }
                            Text {
                                text: root.currentAudioDevice
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: root.audioDevicesExpanded ? "▲" : "▼"
                                color: Qt.rgba(1, 1, 1, 0.5)
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: audioBtnMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.audioDevicesExpanded = !root.audioDevicesExpanded
                        }
                    }

                    // Audio Devices Accordion List
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: root.audioDevicesExpanded ? audioListCol.implicitHeight + 10 : 0
                        clip: true
                        Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: Qt.rgba(0, 0, 0, 0.35)
                            border.width: 1
                            border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)

                            ColumnLayout {
                                id: audioListCol
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Repeater {
                                    model: [
                                        "Speakers (Realtek High Definition Audio)",
                                        "Headphones (WH-1000XM4 Bluetooth Audio)",
                                        "HDMI Monitor Audio (NVIDIA High Definition)"
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        radius: 8
                                        color: root.currentAudioDevice === modelData ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22) : "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: 6
                                            Text { text: modelData; color: "#ffffff"; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                                            Text { text: "✓"; color: Theme.primary; font.pixelSize: 11; visible: root.currentAudioDevice === modelData }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.currentAudioDevice = modelData
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Wi-Fi Connections Dropdown Card
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 14
                        color: wifiBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text { text: "📶"; font.pixelSize: 14 }
                            Text {
                                text: root.wifiEnabled ? "Wi-Fi: Home_5G_Network" : "Wi-Fi: Off"
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                            }
                            Text {
                                text: root.wifiListExpanded ? "▲" : "▼"
                                color: Qt.rgba(1, 1, 1, 0.5)
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: wifiBtnMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.wifiListExpanded = !root.wifiListExpanded
                        }
                    }

                    // Wi-Fi List Accordion
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: root.wifiListExpanded ? wifiListCol.implicitHeight + 10 : 0
                        clip: true
                        Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: Qt.rgba(0, 0, 0, 0.35)
                            border.width: 1
                            border.color: Qt.rgba(0.5, 0.7, 1.0, 0.25)

                            ColumnLayout {
                                id: wifiListCol
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Repeater {
                                    model: [
                                        { ssid: "Home_5G_Network", signal: "100%" },
                                        { ssid: "Bloom_Guest", signal: "80%" },
                                        { ssid: "Bloom_Studio_WiFi", signal: "65%" }
                                    ]

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        radius: 8
                                        color: index === 0 ? Qt.rgba(0.5, 0.7, 1.0, 0.2) : "transparent"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: 6
                                            Text { text: modelData.ssid; color: "#ffffff"; font.pixelSize: 11; Layout.fillWidth: true }
                                            Text { text: "📶 " + modelData.signal; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 10 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
