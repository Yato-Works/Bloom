import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 30
            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.6)
            border.width: 1.5
            border.color: searchInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

            RowLayout { anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 12
                Text { text: searchInput.text.startsWith(">") ? "⚡" : "🔍"; font.pixelSize: 20 }
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search apps, type > for commands, or calculate..."
                    color: Theme.text
                    font.pixelSize: 16
                }
            }
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 160
            cellHeight: 110
            property var apps: appLauncherService.searchApps(searchInput.text)
            model: searchInput.text.startsWith(">") ? [] : apps

            delegate: AppGridItem { app: modelData }
        }
    }
}