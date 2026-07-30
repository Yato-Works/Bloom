import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelHeight: 260

    height: panelHeight
    opacity: open ? 1 : 0

    transform: [
        Translate {
            y: root.open ? 0 : root.panelHeight + 24
            Behavior on y {
                NumberAnimation {
                    duration: Theme.durationDefault
                    easing.type: Easing.OutCubic
                }
            }
        },
        Scale {
            origin.y: 0
            xScale: root.open ? 1.0 : 0.97
            yScale: root.open ? 1.0 : 0.97
            Behavior on xScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutCubic }
            }
            Behavior on yScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutCubic }
            }
        }
    ]
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
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.bottomMargin: 16
        anchors.topMargin: 0
        tint: Theme.surface
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingSM

            // Tab Bar
            RowLayout {
                spacing: Theme.spacingXS

                Repeater {
                    model: [
                        { icon: "🖼", label: "Background" },
                        { icon: "💻", label: "Workspaces" }
                    ]

                    Item {
                        id: tabItem
                        implicitWidth: tabContent.implicitWidth + 24
                        implicitHeight: 36

                        property bool isActive: root.currentTab === index

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusFull
                            color: isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                            : (tabMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")
                            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
                        }

                        RowLayout {
                            id: tabContent
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.icon
                                font.pixelSize: 14
                                color: tabItem.isActive ? Theme.primary : Theme.textMuted
                            }
                            Text {
                                text: modelData.label
                                color: tabItem.isActive ? Theme.text : Theme.textMuted
                                font.pixelSize: Theme.fontSM
                                font.weight: tabItem.isActive ? Font.DemiBold : Font.Normal
                            }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -4
                            width: isActive ? 20 : 0
                            height: 3
                            radius: 1.5
                            color: Theme.primary
                            opacity: isActive ? 1 : 0
                            Behavior on width { NumberAnimation { duration: Theme.durationFast } }
                            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
                        }

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.currentTab === 0 ? (wallpaperService.wallpaperNames.length + " items")
                                             : (workspaceService.workspaceNames.length + " workspaces")
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontXS
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Tab Content
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.currentTab

                // Background Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: Theme.spacingSM

                        // Wallpaper cards
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: bgRow.implicitWidth
                            contentHeight: bgRow.implicitHeight
                            clip: true
                            ScrollBar.horizontal: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                visible: false
                            }

                            RowLayout {
                                id: bgRow
                                spacing: Theme.spacingSM

                                Repeater {
                                    model: wallpaperService.wallpaperNames

                                    Rectangle {
                                        implicitWidth: 140
                                        implicitHeight: 100
                                        radius: Theme.radiusMedium
                                        color: Qt.rgba(1, 1, 1, 0.03)
                                        border.width: wallpaperService.currentWallpaper === modelData ? 2 : 1
                                        border.color: wallpaperService.currentWallpaper === modelData
                                                       ? Theme.primary : Qt.rgba(1, 1, 1, 0.06)

                                        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: Theme.spacingXS

                                            Text {
                                                text: "🖼"
                                                font.pixelSize: 28
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: modelData
                                                color: wallpaperService.currentWallpaper === modelData ? Theme.text : Theme.textMuted
                                                font.pixelSize: Theme.fontXS
                                                font.weight: wallpaperService.currentWallpaper === modelData ? Font.DemiBold : Font.Normal
                                                elide: Text.ElideRight
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.maximumWidth: 120
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: wallpaperService.setWallpaper(modelData)
                                            onEntered: parent.scale = 1.03
                                            onExited: parent.scale = 1.0
                                            Behavior on scale { NumberAnimation { duration: Theme.durationFast } }
                                        }
                                    }
                                }
                            }
                        }

                        // Wallpaper path input
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 44
                            color: Qt.rgba(1, 1, 1, 0.03)
                            border.color: Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1
                            radius: Theme.radiusMedium

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: Theme.spacingSM

                                TextField {
                                    id: pathField
                                    Layout.fillWidth: true
                                    placeholderText: "Wallpaper path..."
                                    background: Rectangle { color: "transparent" }
                                    font.pixelSize: Theme.fontSM
                                    color: Theme.text
                                    onAccepted: wallpaperService.setWallpaper(text)
                                }

                                Button {
                                    text: "Apply"
                                    flat: true
                                    implicitHeight: 32
                                    implicitWidth: 64
                                    contentItem: Text {
                                        text: "Apply"
                                        color: Theme.onPrimary
                                        font.pixelSize: Theme.fontSM
                                        font.weight: Font.DemiBold
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        radius: Theme.radiusFull
                                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                                    }
                                    onClicked: wallpaperService.setWallpaper(pathField.text)
                                }
                            }
                        }
                    }
                }

                // Workspaces Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: Theme.spacingSM

                        // Workspace cards area
                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: wsRow.implicitWidth
                            contentHeight: wsRow.implicitHeight
                            clip: true
                            ScrollBar.horizontal: ScrollBar {
                                policy: ScrollBar.AsNeeded
                                visible: false
                            }

                            RowLayout {
                                id: wsRow
                                spacing: Theme.spacingSM

                                Repeater {
                                    model: workspaceService.workspaceNames

                                    Rectangle {
                                        implicitWidth: 130
                                        implicitHeight: 80
                                        radius: Theme.radiusMedium
                                        color: Qt.rgba(1, 1, 1, 0.03)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.06)

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: Theme.spacingXS

                                            Text {
                                                text: "💻"
                                                font.pixelSize: 24
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: modelData
                                                color: Theme.text
                                                font.pixelSize: Theme.fontSM
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                                Layout.alignment: Qt.AlignHCenter
                                                Layout.maximumWidth: 110
                                            }
                                        }

                                        // Restore overlay
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: Theme.radiusMedium
                                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                            opacity: wsMouse.containsMouse ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Restore"
                                                color: Theme.primary
                                                font.pixelSize: Theme.fontSM
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        MouseArea {
                                            id: wsMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: workspaceService.restoreWorkspace(modelData)
                                            onEntered: parent.scale = 1.03
                                            onExited: parent.scale = 1.0
                                            Behavior on scale { NumberAnimation { duration: Theme.durationFast } }
                                        }
                                    }
                                }

                                // Add new workspace card
                                Rectangle {
                                    implicitWidth: 130
                                    implicitHeight: 80
                                    radius: Theme.radiusMedium
                                    color: Qt.rgba(1, 1, 1, 0.02)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.06)

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: Theme.spacingXS

                                        Text {
                                            text: "+"
                                            color: Theme.textMuted
                                            font.pixelSize: 28
                                            font.weight: Font.Light
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        Text {
                                            text: "New"
                                            color: Theme.textMuted
                                            font.pixelSize: Theme.fontXS
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    TextField {
                                        id: newWsField
                                        anchors.fill: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        placeholderText: "Name..."
                                        color: Theme.text
                                        font.pixelSize: Theme.fontSM
                                        background: Rectangle { color: "transparent"; radius: Theme.radiusMedium }
                                        visible: false
                                        onAccepted: {
                                            workspaceService.saveWorkspace(text.trim())
                                            text = ""
                                            visible = false
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            newWsField.visible = true
                                            newWsField.forceActiveFocus()
                                        }
                                        onEntered: parent.scale = 1.03
                                        onExited: parent.scale = 1.0
                                        Behavior on scale { NumberAnimation { duration: Theme.durationFast } }
                                    }
                                }
                            }
                        }

                        // Status and controls
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingSM

                            Text {
                                Layout.fillWidth: true
                                text: workspaceService.statusText
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontXS
                                wrapMode: Text.WordWrap
                                Layout.maximumHeight: 32
                                elide: Text.ElideRight
                            }

                            Button {
                                text: "Save Current"
                                implicitHeight: 30
                                implicitWidth: 96
                                contentItem: Text {
                                    text: "Save Current"
                                    color: Theme.onPrimary
                                    font.pixelSize: Theme.fontXS
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    radius: Theme.radiusFull
                                    color: parent.hovered ? Qt.lighter(Theme.primary, 1.1) : Theme.primary
                                }
                                onClicked: {
                                    var name = workspaceService.workspaceNames.length > 0
                                        ? "Workspace " + (workspaceService.workspaceNames.length + 1)
                                        : "Workspace 1"
                                    workspaceService.saveWorkspace(name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
