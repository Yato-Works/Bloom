import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    readonly property string fontDisplay: "Rubik"

    implicitWidth: 880
    implicitHeight: 560

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Top 3 Resource Ring Cards (CPU, RAM, Battery/Disk)
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // 1. CPU Hero Ring Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                radius: 28
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Text {
                        text: qsTr("Processor")
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 13
                        font.letterSpacing: 0.5
                    }

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 90
                        height: 90

                        CircularProgress {
                            anchors.fill: parent
                            strokeWidth: 6
                            fgColour: systemInfo.cpuUsage > 80 ? Colours.m3error : Colours.m3primary
                            bgColour: Colours.m3surfaceContainerHighest
                            value: systemInfo.cpuUsage / 100.0
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: systemInfo.cpuUsage + "%"
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "CPU"
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 10
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("System load active")
                        color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                    }
                }
            }

            // 2. Memory Hero Ring Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                radius: 28
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Text {
                        text: qsTr("Memory")
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 13
                        font.letterSpacing: 0.5
                    }

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 90
                        height: 90

                        CircularProgress {
                            anchors.fill: parent
                            strokeWidth: 6
                            fgColour: Colours.m3tertiary
                            bgColour: Colours.m3surfaceContainerHighest
                            value: systemInfo.memoryUsage / 100.0
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: systemInfo.memoryUsage + "%"
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "RAM"
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 10
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: systemInfo.memorySummary === "" ? "RAM Active" : systemInfo.memorySummary
                        color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }
            }

            // 3. Power / Battery Ring Card
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                radius: 28
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Text {
                        text: systemInfo.hasBattery ? qsTr("Power & Battery") : qsTr("Power & System")
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 13
                        font.letterSpacing: 0.5
                    }

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 90
                        height: 90

                        CircularProgress {
                            anchors.fill: parent
                            strokeWidth: 6
                            fgColour: Colours.m3secondary
                            bgColour: Colours.m3surfaceContainerHighest
                            value: (systemInfo.hasBattery ? systemInfo.batteryPercent : 100) / 100.0
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: systemInfo.hasBattery ? (systemInfo.batteryPercent + "%") : "AC"
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: systemInfo.hasBattery ? (systemInfo.batteryCharging ? "Charging" : "Battery") : "Plugged in"
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 10
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: systemInfo.hasBattery ? (systemInfo.batteryCharging ? "⚡ AC Connected" : "🔋 Discharging") : "⚡ Constant AC Power"
                        color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                    }
                }
            }
        }

        // Bottom Section: System Specifications & Diagnostics
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 28
            color: Colours.m3surfaceContainerLow
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

            GridLayout {
                anchors.fill: parent
                anchors.margins: 24
                columns: 2
                rowSpacing: 16
                columnSpacing: 24

                // Device Host
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: Qt.alpha(Colours.m3primary, 0.15)
                        Text { anchors.centerIn: parent; text: "💻"; font.pixelSize: 20 }
                    }
                    ColumnLayout {
                        spacing: 2
                        Text { text: qsTr("Hostname"); color: Colours.m3onSurfaceVariant; font.pixelSize: 11 }
                        Text { text: systemInfo.hostName; color: Colours.m3onSurface; font.family: root.fontDisplay; font.pixelSize: 14; font.weight: Font.Medium }
                    }
                }

                // Operating System
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: Qt.alpha(Colours.m3secondary, 0.15)
                        Text { anchors.centerIn: parent; text: "🪟"; font.pixelSize: 20 }
                    }
                    ColumnLayout {
                        spacing: 2
                        Text { text: qsTr("Operating System"); color: Colours.m3onSurfaceVariant; font.pixelSize: 11 }
                        Text { text: "Windows 11 (Bloom Caelestia Shell)"; color: Colours.m3onSurface; font.family: root.fontDisplay; font.pixelSize: 14; font.weight: Font.Medium }
                    }
                }

                // System Uptime
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: Qt.alpha(Colours.m3tertiary, 0.15)
                        Text { anchors.centerIn: parent; text: "⏱"; font.pixelSize: 20 }
                    }
                    ColumnLayout {
                        spacing: 2
                        Text { text: qsTr("Uptime"); color: Colours.m3onSurfaceVariant; font.pixelSize: 11 }
                        Text { text: systemInfo.uptime; color: Colours.m3onSurface; font.family: root.fontDisplay; font.pixelSize: 14; font.weight: Font.Medium }
                    }
                }

                // Audio Status
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: Qt.alpha(Colours.m3primary, 0.15)
                        Text { anchors.centerIn: parent; text: systemInfo.volumeMuted ? "🔇" : "🔊"; font.pixelSize: 20 }
                    }
                    ColumnLayout {
                        spacing: 2
                        Text { text: qsTr("Audio Endpoint"); color: Colours.m3onSurfaceVariant; font.pixelSize: 11 }
                        Text { text: (systemInfo.volumeMuted ? "Muted (" : "Active (") + systemInfo.volumeLevel + "%)"; color: Colours.m3onSurface; font.family: root.fontDisplay; font.pixelSize: 14; font.weight: Font.Medium }
                    }
                }
            }
        }
    }
}
