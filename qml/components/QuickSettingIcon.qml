import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Rectangle {
    property string icon: ""
    property string label: ""
    property bool active: false
    property var onClicked: () => {}

    Layout.fillWidth: true
    implicitHeight: 40
    radius: 12
    color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    border.color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4) : Qt.rgba(1, 1, 1, 0.08)

    RowLayout {
        anchors.centerIn: parent
        spacing: 10
        Text { text: icon; font.pixelSize: 16 }
        Text {
            text: label
            color: active ? Theme.primary : Theme.textMuted
            font.pixelSize: 12
            font.weight: Font.DemiBold
            visible: label !== ""
        }
    }
    MouseArea { anchors.fill: parent; onClicked: onClicked() }
}
