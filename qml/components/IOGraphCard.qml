import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string title: ""
    property color color: Theme.primary
    property string unit: ""

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
            anchors.margins: 20
            spacing: 12

            Text { text: title; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.04)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.06)

                Text { anchors.centerIn: parent; text: "📈 Real-time graph"; color: Theme.textMuted; font.pixelSize: 13 }
            }
        }
    }
}
