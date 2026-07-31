import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelWidth: 360

    // Internal System Control State
    property int volumeLevel: 72
    property bool isMuted: false
    property int brightnessLevel: 85

    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool nightLightEnabled: false
    property bool powerSaverEnabled: false

    width: panelWidth
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.topMargin: 36
    anchors.bottomMargin: 36

    opacity: open ? 1 : 0

    transform: Translate {
        x: root.open ? 0 : -(root.panelWidth + 40)
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
        anchors.leftMargin: 20
        tint: Qt.rgba(0.08, 0.08, 0.12, 0.92)
        elevated: true
        radius: 24

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
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

            // Volume Control Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 70
                radius: 16
                color: Qt.rgba(1, 1, 1, 0.04)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.07)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.isMuted ? "🔇  Volume (Muted)" : (root.volumeLevel > 50 ? "🔊  Volume" : "🔉  Volume")
                            color: "#ffffff"
                            font.pixelSize: Theme.fontSM
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.isMuted ? "0%" : root.volumeLevel + "%"
                            color: Theme.primary
                            font.pixelSize: Theme.fontSM
                            font.weight: Font.Bold
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Slider {
                            id: volSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: root.volumeLevel
                            onValueChanged: {
                                root.volumeLevel = Math.round(value)
                                if (root.volumeLevel > 0) root.isMuted = false
                            }
                        }

                        Rectangle {
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 13
                            color: root.isMuted ? Qt.rgba(1, 0.3, 0.3, 0.25) : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: root.isMuted ? "🔇" : "🔊"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.isMuted = !root.isMuted
                            }
                        }
                    }
                }
            }

            // Brightness Control Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 70
                radius: 16
                color: Qt.rgba(1, 1, 1, 0.04)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.07)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "☀️  Brightness"
                            color: "#ffffff"
                            font.pixelSize: Theme.fontSM
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.brightnessLevel + "%"
                            color: "#cba6f7"
                            font.pixelSize: Theme.fontSM
                            font.weight: Font.Bold
                        }
                    }

                    Slider {
                        id: brightSlider
                        Layout.fillWidth: true
                        from: 10
                        to: 100
                        value: root.brightnessLevel
                        onValueChanged: root.brightnessLevel = Math.round(value)
                    }
                }
            }

            // Caelestia Quick Toggles Grid (2x2)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                // Toggle 1: Wi-Fi
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    radius: 14
                    color: root.wifiEnabled ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                            : Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: root.wifiEnabled ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
                                                   : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

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

                // Toggle 2: Bluetooth
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    radius: 14
                    color: root.bluetoothEnabled ? Qt.rgba(0.5, 0.7, 1.0, 0.2)
                                                 : Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: root.bluetoothEnabled ? Qt.rgba(0.5, 0.7, 1.0, 0.4)
                                                        : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

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

                // Toggle 3: Night Light
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    radius: 14
                    color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.2)
                                                   : Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: root.nightLightEnabled ? Qt.rgba(1.0, 0.7, 0.3, 0.4)
                                                          : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

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

                // Toggle 4: Power Saver
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 50
                    radius: 14
                    color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.2)
                                                  : Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: root.powerSaverEnabled ? Qt.rgba(0.4, 0.9, 0.5, 0.4)
                                                         : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

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

            Item { Layout.fillHeight: true }
        }
    }
}
