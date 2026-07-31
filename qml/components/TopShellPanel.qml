import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelHeight: 205

    height: panelHeight
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    opacity: open ? 1 : 0

    transform: [
        Translate {
            y: root.open ? 0 : -(root.panelHeight + 24)
            Behavior on y {
                NumberAnimation {
                    duration: Theme.durationDefault
                    easing.type: Easing.OutExpo
                }
            }
        },
        Scale {
            origin.x: root.width / 2
            origin.y: 0
            xScale: root.open ? 1.0 : 0.96
            yScale: root.open ? 1.0 : 0.96
            Behavior on xScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
            Behavior on yScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
        }
    ]
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -24
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    // Floating Glass Panel Header Widget
    GlassPanel {
        id: topGlass
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        width: Math.min(parent.width * 0.75, 880)
        implicitHeight: 180
        radius: 24
        tint: Qt.rgba(0.08, 0.08, 0.12, 0.90)
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Caelestia Sliding Pill Tab Bar Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Item {
                    id: tabBarContainer
                    Layout.fillWidth: true
                    implicitHeight: 36

                    readonly property var tabs: [
                        { icon: "🕐", label: "Clock" },
                        { icon: "☁", label: "Weather" },
                        { icon: "🎵", label: "Media" },
                        { icon: "⚙", label: "System" }
                    ]

                    RowLayout {
                        id: tabsRow
                        anchors.left: parent.left
                        spacing: 4

                        Repeater {
                            model: tabBarContainer.tabs

                            Item {
                                id: tabBtn
                                implicitWidth: tabRow.implicitWidth + 24
                                implicitHeight: 34

                                property bool isActive: root.currentTab === index

                                RowLayout {
                                    id: tabRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 13
                                    }
                                    Text {
                                        text: modelData.label
                                        color: tabBtn.isActive ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                                        font.pixelSize: Theme.fontSM
                                        font.weight: tabBtn.isActive ? Font.DemiBold : Font.Normal
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = index
                                }
                            }
                        }
                    }

                    // Sliding Pill Indicator
                    Rectangle {
                        id: pillIndicator
                        height: 34
                        radius: 17
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
                        z: -1

                        property Item targetTabItem: tabsRow.children[root.currentTab] || null

                        x: targetTabItem ? targetTabItem.x : 0
                        width: targetTabItem ? targetTabItem.width : 0

                        Behavior on x {
                            NumberAnimation { duration: 220; easing.type: Easing.OutExpo }
                        }
                        Behavior on width {
                            NumberAnimation { duration: 220; easing.type: Easing.OutExpo }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Tab Content Stack
            StackLayout {
                currentIndex: root.currentTab
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Tab 0: Clock
                RowLayout {
                    spacing: 24
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: systemInfo.formattedTime
                            color: "#ffffff"
                            font.pixelSize: 42
                            font.weight: Font.Light
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: systemInfo.formattedDate
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: Theme.fontMD
                        }
                    }
                }

                // Tab 1: Weather
                RowLayout {
                    spacing: 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Text {
                        text: weatherService.weatherIcon
                        font.pixelSize: 44
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: weatherService.temperature
                            color: "#ffffff"
                            font.pixelSize: 28
                            font.weight: Font.Bold
                        }
                        Text {
                            text: weatherService.conditionText + " | 湿度 " + weatherService.humidity
                            color: Qt.rgba(1, 1, 1, 0.65)
                            font.pixelSize: Theme.fontSM
                        }
                    }
                }

                // Tab 2: Media
                RowLayout {
                    spacing: 16
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Rectangle {
                        implicitWidth: 54
                        implicitHeight: 54
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "🎵"
                            font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: musicControl.trackTitle !== "" ? musicControl.trackTitle : "再生中の曲はありません"
                            color: "#ffffff"
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                        Text {
                            text: musicControl.artistName !== "" ? musicControl.artistName : "Caelestia Audio Player"
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.pixelSize: Theme.fontSM
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Text { anchors.centerIn: parent; text: "⏮"; color: "#fff" }
                            MouseArea { anchors.fill: parent; onClicked: musicControl.previous() }
                        }
                        Rectangle {
                            implicitWidth: 42
                            implicitHeight: 42
                            radius: 21
                            color: Theme.primary
                            Text { anchors.centerIn: parent; text: musicControl.isPlaying ? "⏸" : "▶"; color: "#fff" }
                            MouseArea { anchors.fill: parent; onClicked: musicControl.playPause() }
                        }
                        Rectangle {
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Text { anchors.centerIn: parent; text: "⏭"; color: "#fff" }
                            MouseArea { anchors.fill: parent; onClicked: musicControl.next() }
                        }
                    }
                }

                // Tab 3: System Metrics
                RowLayout {
                    spacing: 32
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    RowLayout {
                        spacing: 12
                        MetricRing {
                            size: 54
                            value: systemInfo.cpuUsage / 100.0
                            color: Theme.primary
                        }
                        ColumnLayout {
                            Text { text: "CPU"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 11 }
                            Text { text: systemInfo.cpuUsage + "%"; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }

                    RowLayout {
                        spacing: 12
                        MetricRing {
                            size: 54
                            value: systemInfo.ramUsage / 100.0
                            color: "#cba6f7"
                        }
                        ColumnLayout {
                            Text { text: "RAM"; color: Qt.rgba(1, 1, 1, 0.5); font.pixelSize: 11 }
                            Text { text: systemInfo.ramUsage + "%"; color: "#ffffff"; font.pixelSize: 16; font.weight: Font.Bold }
                        }
                    }
                }
            }
        }
    }
}
