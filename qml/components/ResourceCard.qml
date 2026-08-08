import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string title: ""
    property string icon: ""
    property string value: ""
    property string subtitle: ""
    property color color: Theme.primary

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.9)
        border.width: 1
        border.color: Qt.rgba(color.r, color.g, color.b, 0.2)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 12

            RowLayout { spacing: 10
                Text { text: icon; font.pixelSize: 24 }
                Text { text: title; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
            }

            Text { text: value; color: color; font.pixelSize: 36; font.weight: Font.Bold; font.family: "Monospace" }
            Text { text: subtitle; color: Theme.textMuted; font.pixelSize: 12 }

            Rectangle {
                Layout.fillWidth: true
                height: 8
                radius: 4
                color: Qt.rgba(1, 1, 1, 0.1)
                Rectangle {
                    height: 8; radius: 4
                    color: color
                    width: parent.width * 0.5
                }
            }
        }
    }
}
