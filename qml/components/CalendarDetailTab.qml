import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text { text: "Calendar"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 24
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)

            Text { anchors.centerIn: parent; text: "📅 Full Calendar View"; color: Theme.textMuted; font.pixelSize: 16 }
        }
    }
}