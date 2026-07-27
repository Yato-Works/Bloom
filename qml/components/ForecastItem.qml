import QtQuick

Item {
    id: root
    property string hour: "12:00"
    property string symbol: "☀"
    property string temperature: "23°"
    implicitWidth: 52
    implicitHeight: 106

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMedium
        color: mouse.containsMouse
            ? Qt.rgba(1, 1, 1, 0.06)
            : Qt.rgba(1, 1, 1, 0.02)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.04)
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        Column {
            anchors.centerIn: parent
            spacing: 6
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.hour
                color: Theme.textMuted
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 28; height: 28
                radius: 14
                color: Qt.rgba(1, 0.85, 0.42, 0.10)
                Text {
                    anchors.centerIn: parent
                    text: root.symbol
                    color: "#ffd86c"
                    font.pixelSize: 16
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.temperature
                color: Theme.text
                font.pixelSize: 13
                font.bold: true
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
