import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelHeight: 240
    height: panelHeight
    opacity: open ? 1 : 0

    transform: Translate {
        y: root.open ? 0 : root.panelHeight + 24
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
        anchors.margins: -40
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
        tint: Qt.rgba(0,0,0,0)
        showShadow: false
        showHighlight: false
        border.width: 0
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingXS

            RowLayout {
                spacing: Theme.spacingXS

                TabBar {
                    id: tabBar
                    currentIndex: root.currentTab
                    spacing: 4

                    background: Rectangle { color: "transparent" }

                    TabButton {
                        text: qsTr("Background")
                        checked: tabBar.currentIndex === 0
                        onClicked: root.currentTab = 0
                    }
                    TabButton {
                        text: qsTr("Workspaces")
                        checked: tabBar.currentIndex === 1
                        onClicked: root.currentTab = 1
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.currentTab === 0 ? (wallpaperService.wallpaperNames.length + " items")
                                             : (workspaceService.workspaceNames.length + " workspaces")
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
                        anchors.margins: 10
                        contentWidth: bgRow.implicitWidth
                        contentHeight: bgRow.implicitHeight
                        clip: true
                        ScrollBar.horizontal: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            visible: false
                        }
                        RowLayout {
                            id: bgRow
                            spacing: Theme.spacingLG
                            Repeater {
                                model: wallpaperService.wallpaperNames
                                Rectangle {
                                    Layout.alignment: Qt.AlignVCenter
                                    width: wallpaperCard.width
                                    height: wallpaperCard.height
                                    radius: Theme.radiusLarge
                                    color: Theme.surfaceContainerLow
                                    border.width: wallpaperService.currentIndex === index ? 2 : 0
                                    border.color: Theme.primary

                                    property real hoverScale: 1.0
                                    property real pressScale: 1.0
                                    Behavior on hoverScale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    Behavior on pressScale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                                    scale: hoverScale * pressScale
                                    Behavior on border.width { NumberAnimation { duration: 120 } }

                                    Image {
                                        id: wallpaperCard
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: "file:///" + wallpaperService.wallpaperPaths[index]
                                        cache: true
                                        asynchronous: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: parent.pressScale = 0.97
                                        onReleased: parent.pressScale = 1.0
                                        onEntered: parent.hoverScale = 1.04
                                        onExited: parent.hoverScale = 1.0
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
                        text: "Put images into\nC:\\Users\\<user>\\AppData\\Roaming\\Bloom\\wallpapers"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSM
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Theme.spacingMD
                        RowLayout {
                            spacing: Theme.spacingMD
                            ComboBox {
                                id: workspaceCombo
                                Layout.fillWidth: true
                                model: workspaceService.workspaceNames
                                editable: true
                                flat: true
                                background: Rectangle {
                                    radius: Theme.radiusFull
                                    color: Qt.rgba(1, 1, 1, 0.05)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.08)
                                }
                                contentItem: Text {
                                    text: workspaceCombo.displayText
                                    color: Theme.text
                                    font.pixelSize: Theme.fontSM
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Button {
                                id: saveButton
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
                                    implicitWidth: 64
                                    implicitHeight: 30
                                    radius: Theme.radiusFull
                                    color: saveButton.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                }
                                onClicked: workspaceService.saveWorkspace(workspaceCombo.displayText.trim())
                            }
                            Button {
                                id: restoreButton
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
                                    implicitWidth: 72
                                    implicitHeight: 30
                                    radius: Theme.radiusFull
                                    color: restoreButton.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                }
                                onClicked: workspaceService.restoreWorkspace(workspaceCombo.currentText)
                            }
                            Button {
                                id: deleteButton
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
                                    implicitWidth: 64
                                    implicitHeight: 30
                                    radius: Theme.radiusFull
                                    color: deleteButton.hovered ? "#ff6b6b" : Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.12)
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