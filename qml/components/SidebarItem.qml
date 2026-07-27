import QtQuick

Item {
    id: root
    property string icon: "○"
    property string label: "Item"
    property bool selected: false
    signal clicked()
    implicitHeight: 42
    Rectangle {
        anchors.fill: parent
 radius: Theme.radiusSmall
        color: root.selected ? Qt.rgba(0.38, 0.46, 0.86, 0.42) : (mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent")
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }
    Row { anchors.verticalCenter: parent.verticalCenter
 anchors.left: parent.left
 anchors.leftMargin: 13
 spacing: 12
        Text { text: root.icon
 color: root.selected ? "#dceaff" : Theme.textMuted
 font.pixelSize: 17 }
        Text { text: root.label
 color: root.selected ? Theme.text : Theme.textMuted
 font.pixelSize: 13 }
    }
    MouseArea { id: mouse
 anchors.fill: parent
 hoverEnabled: true
 onClicked: root.clicked() }
}
