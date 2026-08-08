import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: qtkBtn
    property string icon: ""
    property string label: ""
    property bool active: false
    property color color: Theme.primary

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: active ? Qt.rgba(qtkBtn.color.r, qtkBtn.color.g, qtkBtn.color.b, 0.18) : Qt.rgba(1, 1, 1, 0.04)
        border.width: 1
        border.color: active ? Qt.rgba(qtkBtn.color.r, qtkBtn.color.g, qtkBtn.color.b, 0.4) : Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout { anchors.centerIn: parent; spacing: 4
            Text { text: icon; font.pixelSize: 18 }
            Text { text: label; color: active ? qtkBtn.color : Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        MouseArea { anchors.fill: parent; onClicked: {} }
    }
}