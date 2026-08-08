import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    property var app: null

    width: 150; height: 100
    radius: 16
    color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    border.color: mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(1, 1, 1, 0.06)

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        Text { text: app && app.icon ? app.icon : "🚀"; font.pixelSize: 32 }
        Text {
            text: app && app.name ? app.name : "App"
            color: Theme.text
            font.pixelSize: 13
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
    MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true; onClicked: appLauncherService.launchApp(app.exec) }
}