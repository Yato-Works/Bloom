import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: profBtn
    property string label: ""
    property string icon: ""
    property bool active: false
    property color color: Theme.primary
    property var onClicked: () => {}

    Layout.fillWidth: true
    implicitHeight: 44

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: active ? Qt.rgba(profBtn.color.r, profBtn.color.g, profBtn.color.b, 0.2) : Qt.rgba(1, 1, 1, 0.04)
        border.width: active ? 2 : 1
        border.color: active ? profBtn.color : Qt.rgba(1, 1, 1, 0.08)

        RowLayout { anchors.centerIn: parent; spacing: 8
            Text { text: icon; font.pixelSize: 16 }
            Text { text: label; color: active ? profBtn.color : Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
            Rectangle { implicitWidth: 10; implicitHeight: 10; radius: 5; color: active ? profBtn.color : "transparent"; visible: active }
        }
        MouseArea { anchors.fill: parent; onClicked: onClicked() }
    }
}