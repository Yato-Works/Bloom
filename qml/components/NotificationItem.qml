import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    implicitHeight: 72

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 12
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                Text { anchors.centerIn: parent; text: "📱"; font.pixelSize: 18 }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Google Chrome"; color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                Text { text: "No notifications • Click to play dinosaur game"; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
            }

            Text { text: "03:30"; color: Theme.textMuted; font.pixelSize: 10; font.family: "Monospace" }
        }
    }
}