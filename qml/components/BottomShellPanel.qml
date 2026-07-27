import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelHeight: 220

    height: panelHeight
    opacity: open ? 1 : 0

    transform: Translate {
        y: root.open ? 0 : root.panelHeight + 28
        Behavior on y {
            NumberAnimation {
                duration: Theme.durationDefault
                easing.type: Easing.OutCubic
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -24
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    GlassPanel {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.bottomMargin: 12
        anchors.topMargin: 0
        tint: Theme.surface
        showShadow: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingSM

            RowLayout {
                spacing: Theme.spacingSM
                Button {
                    text: "Background"
                    checked: root.currentTab === 0
                    onClicked: root.currentTab = 0
                }
                Button {
                    text: "Workspaces"
                    checked: root.currentTab === 1
                    onClicked: root.currentTab = 1
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.currentTab === 0 ? (wallpaperService.wallpaperNames.length + " items") : (workspaceService.workspaceNames.length + " workspaces")
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontXS
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.currentTab

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 8
                        contentWidth: bgRow.implicitWidth
                        contentHeight: bgRow.implicitHeight
                        clip: true
                        ScrollBar.horizontal: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            visible: false
                        }
                        RowLayout {
                            id: bgRow
                            spacing: Theme.spacingMD
                            Repeater {
                                model: wallpaperService.wallpaperNames
                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter
                                    width: 140
                                    height: 110
                                    radius: Theme.radiusMedium
                                    color: Theme.surfaceContainer
                                    border.width: wallpaperService.currentIndex === index ? 2 : 0
                                    border.color: Theme.primary
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        source: "file:///" + wallpaperService.wallpaperPaths[index]
                                        fillMode: Image.PreserveAspectCrop
                                        cache: true
                                        asynchronous: true
                                    }
                                    Behavior on border.width {
                                        NumberAnimation { duration: 120 }
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: wallpaperService.setWallpaperByIndex(index)
                                    }
                                }
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible: wallpaperService.wallpaperNames.length === 0
                        text: "壁紙画像を\\nC:\\Users\\<user>\\AppData\\Roaming\\Bloom\\wallpapers に入れてください"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSM
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingSM
                        RowLayout {
                            spacing: Theme.spacingSM
                            ComboBox {
                                id: workspaceCombo
                                Layout.fillWidth: true
                                model: workspaceService.workspaceNames
                                editable: true
                                flat: true
                                background: Rectangle {
                                    radius: Theme.radiusSmall
                                    color: Qt.rgba(1, 1, 1, 0.04)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.06)
                                }
                                contentItem: Text {
                                    text: workspaceCombo.displayText
                                    color: Theme.text
                                    font.pixelSize: Theme.fontSM
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Button {
                                text: "Save"
                                flat: true
                                enabled: workspaceCombo.displayText.trim().length > 0
                                contentItem: Text {
                                    text: "Save"
                                    color: Theme.onPrimary
                                    font.pixelSize: Theme.fontSM
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    implicitWidth: 72
                                    implicitHeight: 32
                                    radius: Theme.radiusFull
                                    color: saveButton.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                }
                                onClicked: workspaceService.saveWorkspace(workspaceCombo.displayText.trim())
                            }
                            Button {
                                text: "Restore"
                                enabled: workspaceCombo.currentIndex >= 0
                                flat: true
                                contentItem: Text {
                                    text: "Restore"
                                    color: Theme.onPrimary
                                    font.pixelSize: Theme.fontSM
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    implicitWidth: 80
                                    implicitHeight: 32
                                    radius: Theme.radiusFull
                                    color: restoreButton.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                }
                                onClicked: workspaceService.restoreWorkspace(workspaceCombo.currentText)
                            }
                            Button {
                                text: "Delete"
                                enabled: workspaceCombo.currentIndex >= 0
                                flat: true
                                contentItem: Text {
                                    text: "Delete"
                                    color: Theme.onPrimary
                                    font.pixelSize: Theme.fontSM
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    implicitWidth: 72
                                    implicitHeight: 32
                                    radius: Theme.radiusFull
                                    color: deleteHover.containsMouse ? "#ff6b6b" : Qt.rgba(1, 1, 1, 0.08)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.12)
                                }
                                MouseArea {
                                    id: deleteHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                                onClicked: workspaceService.deleteWorkspace(workspaceCombo.currentText)
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: workspaceService.statusText
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontXS
                            wrapMode: Text.WordWrap
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}