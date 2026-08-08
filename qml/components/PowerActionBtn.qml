import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: pwrBtn
    property string icon: ""
    property string label: ""
    property color color: Theme.text
    property var onClicked: () => {}

    Layout.fillWidth: true
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(pwrBtn.color.r, pwrBtn.color.g, pwrBtn.color.b, 0.12)
        border.width: 1
        border.color: Qt.rgba(pwrBtn.color.r, pwrBtn.color.g, pwrBtn.color.b, 0.3)

        RowLayout { anchors.centerIn: parent; spacing: 8
            Text { text: icon; font.pixelSize: 16 }
            Text { text: label; color: pwrBtn.color; font.pixelSize: 12; font.weight: Font.DemiBold }
        }
        MouseArea { anchors.fill: parent; onClicked: onClicked() }
    }
}