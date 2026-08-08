import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    implicitHeight: 100

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
            RowLayout { Layout.fillWidth: true; spacing: 12
                Rectangle {
                    implicitWidth: 44; implicitHeight: 44; radius: 14
                    color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15)
                    Text { anchors.centerIn: parent; text: "🎬"; font.pixelSize: 18 }
                }
                ColumnLayout { Layout.fillWidth: true; spacing: 2
                    Text { text: "Screen Recorder"; color: Theme.text; font.pixelSize: 14; font.weight: Font.DemiBold }
                    Text { text: "Ready to record • 1920x1080 @ 60fps"; color: Theme.textMuted; font.pixelSize: 11 }
                }
            }

            RowLayout { Layout.fillWidth: true; spacing: 10
                RecorderBtn { label: "Record Fullscreen"; icon: "🎥"; color: Theme.tertiary; onClicked: {} }
                RecorderBtn { label: "Record Region"; icon: "✂"; color: Theme.accent; onClicked: {} }
                RecorderBtn { label: "History"; icon: "📁"; color: Theme.textMuted; onClicked: {} }
            }
        }
    }
}