import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string day: ""
    property string icon: ""
    property string high: ""
    property string low: ""

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text { text: day; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { text: icon; font.pixelSize: 32 }
            RowLayout { spacing: 8
                Text { text: high; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }
                Text { text: low; color: Theme.textMuted; font.pixelSize: 14 }
            }
        }
    }
}
