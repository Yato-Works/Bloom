import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Rectangle {
    property bool checked: false
    property var onToggled: () => {}

    implicitWidth: 48
    implicitHeight: 28
    radius: 14
    color: checked ? Theme.primary : Qt.rgba(1, 1, 1, 0.15)
    border.width: 1
    border.color: checked ? Theme.primary : Qt.rgba(1, 1, 1, 0.2)

    Rectangle {
        x: checked ? 24 : 4
        width: 20; height: 20; radius: 10
        color: "#fff"
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutExpo } }
    }
    MouseArea { anchors.fill: parent; onClicked: { checked = !checked; onToggled(checked) } }
}