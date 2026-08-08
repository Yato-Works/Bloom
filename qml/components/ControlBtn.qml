import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string icon: ""
    property color color: Theme.text
    property int size: 44
    property var onClicked: () => {}

    implicitWidth: size
    implicitHeight: size
    radius: size / 2

    Rectangle {
        anchors.fill: parent
        radius: size / 2
        color: Qt.rgba(color.r, color.g, color.b, 0.15)
        border.width: 1
        border.color: Qt.rgba(color.r, color.g, color.b, 0.3)

        Text { anchors.centerIn: parent; text: icon; color: color; font.pixelSize: size * 0.45 }
        MouseArea { anchors.fill: parent; onClicked: onClicked() }
    }
}