import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: recBtn
    property string label: ""
    property string icon: ""
    property color color: Theme.primary
    property var onClicked: () => {}

    Layout.fillWidth: true
    implicitHeight: 36

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Qt.rgba(recBtn.color.r, recBtn.color.g, recBtn.color.b, 0.12)
        border.width: 1
        border.color: Qt.rgba(recBtn.color.r, recBtn.color.g, recBtn.color.b, 0.3)

        RowLayout { anchors.centerIn: parent; spacing: 6
            Text { text: icon; font.pixelSize: 13 }
            Text { text: label; color: recBtn.color; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        MouseArea { anchors.fill: parent; onClicked: onClicked() }
    }
}