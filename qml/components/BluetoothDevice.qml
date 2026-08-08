import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string name: ""
    property bool connected: false
    property string battery: ""

    Layout.fillWidth: true
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: connected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Qt.rgba(1, 1, 1, 0.03)
        border.width: 1
        border.color: connected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(1, 1, 1, 0.06)

        RowLayout { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
            Text { text: "🎧"; font.pixelSize: 14 }
            Text { text: name; color: Theme.text; font.pixelSize: 12; Layout.fillWidth: true }
            Text { text: battery; color: connected ? Theme.primary : Theme.textMuted; font.pixelSize: 10; font.weight: Font.DemiBold }
            Rectangle { implicitWidth: 8; implicitHeight: 8; radius: 4; color: connected ? Theme.success : Qt.rgba(1, 1, 1, 0.2) }
        }
    }
}