import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
        border.width: 1
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    implicitWidth: 56
                    implicitHeight: 56
                    radius: 16
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)

                    Image {
                        anchors.centerIn: parent
                        source: ""
                        fillMode: Image.PreserveAspectFit
                        width: 40; height: 40
                        Text { anchors.centerIn: parent; text: "👁"; font.pixelSize: 24 }
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Text { text: "Arch Linux • Hyprland"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                    Text { text: "Uptime: 26m • Kernel: 6.9.x"; color: Theme.textMuted; font.pixelSize: 12 }
                    Text { text: "Packages: 1420 • Shell: Fish"; color: Theme.textMuted; font.pixelSize: 12 }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MetricRing { label: "CPU"; value: 34; accent: Theme.primary; Layout.fillWidth: true }
                MetricRing { label: "RAM"; value: 62; accent: Theme.accent; Layout.fillWidth: true }
                MetricRing { label: "GPU"; value: 45; accent: Theme.tertiary; Layout.fillWidth: true }
                MetricRing { label: "DISK"; value: 28; accent: Theme.warning; Layout.fillWidth: true }
            }
        }
    }
}
