import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property string icon: ""
    property string label: ""
    property string subtitle: ""
    property bool checked: false
    property color color: Theme.primary

    Layout.fillWidth: true
    implicitHeight: 56

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: checked ? Qt.rgba(color.r, color.g, color.b, 0.15) : Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: checked ? Qt.rgba(color.r, color.g, color.b, 0.4) : Qt.rgba(1, 1, 1, 0.06)

        RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 14
            Text { text: icon; font.pixelSize: 20 }
            ColumnLayout { Layout.fillWidth: true; spacing: 2
                Text { text: label; color: Theme.text; font.pixelSize: 14; font.weight: Font.DemiBold }
                Text { text: subtitle; color: Theme.textMuted; font.pixelSize: 11 }
            }
            SwitchButton { checked: checked; onToggled: {} }
        }
        MouseArea { anchors.fill: parent; onClicked: checked = !checked }
    }
}