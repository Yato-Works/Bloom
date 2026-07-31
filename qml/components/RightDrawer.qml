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
    property bool bluetoothListExpanded: false

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
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    GlassPanel {
        anchors.fill: parent
        anchors.rightMargin: 20
        tint: Qt.rgba(0.08, 0.08, 0.12, 0.92)
        elevated: true
        radius: 24

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

                // Header Badge
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        implicitWidth: 34
                        implicitHeight: 34
                        radius: 17
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)

                        MaterialIcon {
                            anchors.centerIn: parent
                            name: "⚙"
                            iconSize: 18
                            iconColor: Theme.primary
                        }
                    }

                    Text {
                        text: "Control Center"
                        color: "#ffffff"
                        font.pixelSize: Theme.fontLG
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Caelestia"
                        color: Qt.rgba(1, 1, 1, 0.4)
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // ============================================================
                // 1. Pure Volume & Brightness Section (音量と光だけ！本家スタイル)
                // ============================================================
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Pure Volume Slider Bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 10

                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
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
                            }

                            Text {
                                text: root.isMuted ? "0%" : root.volumeLevel + "%"
                                color: Theme.primary
                                font.pixelSize: Theme.fontSM
                                font.weight: Font.Bold
                                Layout.preferredWidth: 32
                            }
                        }
                    }

                    // Pure Brightness Slider Bar
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 10

                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
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
                            }

                            Text {
                                text: root.brightnessLevel + "%"
                                color: "#cba6f7"
                                font.pixelSize: Theme.fontSM
                                font.weight: Font.Bold
                                Layout.preferredWidth: 32
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
                // 2. Separate Quick Toggles & Accordion Dropdowns
                // ============================================================

                // Audio Output Selection Dropdown Card
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 42
                        radius: 14
                        color: audioBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
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

                // Wi-Fi Connection Dropdown Card
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 42
                        radius: 14
                        color: wifiBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
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
                                        { ssid: "Caelestia_Guest", signal: "80%" },
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

                // 2x2 Quick Toggles Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 10
                    rowSpacing: 10

                    // Night Light
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 14
                        color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text { text: "🌙"; font.pixelSize: 14 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Night Light"; color: "#ffffff"; font.pixelSize: 11; font.weight: Font.Bold }
                                Text { text: root.nightLightEnabled ? "Active" : "Off"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nightLightEnabled = !root.nightLightEnabled
                        }
                    }

                    // Power Saver
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 46
                        radius: 14
                        color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.2) : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.4) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text { text: "🔋"; font.pixelSize: 14 }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Power Saver"; color: "#ffffff"; font.pixelSize: 11; font.weight: Font.Bold }
                                Text { text: root.powerSaverEnabled ? "Saving" : "Normal"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.powerSaverEnabled = !root.powerSaverEnabled
                        }
                    }
                }
            }
        }
    }
}
