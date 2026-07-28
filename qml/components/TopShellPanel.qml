import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelHeight: 200

    height: panelHeight
    opacity: open ? 1 : 0

    transform: [
        Translate {
            y: root.open ? 0 : -(root.panelHeight + 24)
            Behavior on y {
                NumberAnimation {
                    duration: Theme.durationDefault
                    easing.type: Easing.OutCubic
                }
            }
        },
        Scale {
            id: panelScale
            origin.y: root.panelHeight
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

    // Hit area for hover detection (extended beyond panel bounds)
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
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 16
        anchors.bottomMargin: 0
        tint: Theme.surface
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingSM

            // Tab Bar
            RowLayout {
                spacing: Theme.spacingXS
                Layout.fillWidth: true

                Repeater {
                    model: [
                        { icon: "🕐", label: "Clock" },
                        { icon: "☁", label: "Weather" },
                        { icon: "🎵", label: "Media" },
                        { icon: "⚙", label: "System" }
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

                        // Active indicator dot
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

                // Clock Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXL

                        ColumnLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                id: clockText
                                text: Qt.formatTime(new Date(), "hh:mm")
                                color: Theme.text
                                font.pixelSize: 52
                                font.weight: Font.Light
                                font.family: "Segoe UI"
                            }
                            Text {
                                id: dateText
                                text: Qt.formatDate(new Date(), "dddd - MMM d")
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontSM
                            }

                            Timer {
                                interval: 1000
                                running: root.open && root.currentTab === 0
                                repeat: true
                                onTriggered: {
                                    const now = new Date()
                                    clockText.text = Qt.formatTime(now, "hh:mm")
                                    dateText.text = Qt.formatDate(now, "dddd - MMM d")
                                }
                            }
                        }
                    }
                }

                // Weather Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing2XL

                        ColumnLayout {
                            spacing: Theme.spacingXS
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: Theme.spacingSM
                                Text {
                                    text: "☁"
                                    color: Theme.primary
                                    font.pixelSize: 32
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: weatherService.temperature
                                        color: Theme.text
                                        font.pixelSize: 36
                                        font.weight: Font.Light
                                    }
                                    Text {
                                        text: weatherService.condition
                                        color: Theme.textMuted
                                        font.pixelSize: Theme.fontSM
                                    }
                                }
                            }
                            Text {
                                text: weatherService.city
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontXS
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 64
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSM
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: Theme.spacingMD
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Wind"; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                    Text { text: weatherService.wind; color: Theme.text; font.pixelSize: Theme.fontSM; font.weight: Font.DemiBold }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Humidity"; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                    Text { text: weatherService.humidity; color: Theme.text; font.pixelSize: Theme.fontSM; font.weight: Font.DemiBold }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Pressure"; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                    Text { text: weatherService.pressure; color: Theme.text; font.pixelSize: Theme.fontSM; font.weight: Font.DemiBold }
                                }
                            }

                            Row {
                                spacing: Theme.spacingSM
                                Repeater {
                                    model: 5
                                    ForecastItem {
                                        hour: "0" + (index + 8) + ":00"
                                        symbol: ["☀", "⛅", "☁", "🌧", "☀"][index]
                                        temperature: [22, 24, 23, 20, 21][index] + "°"
                                        implicitWidth: 48
                                        implicitHeight: 90
                                    }
                                }
                            }
                        }
                    }
                }

                // Media Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXL

                        ColumnLayout {
                            spacing: Theme.spacingSM
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 300

                            Text {
                                text: musicControl.songTitle
                                color: Theme.text
                                font.pixelSize: Theme.fontLG
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: musicControl.artist
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontSM
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Progress bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: Qt.rgba(1, 1, 1, 0.08)
                                Rectangle {
                                    width: parent.width * 0.45
                                    height: parent.height
                                    radius: 2
                                    color: Theme.primary
                                }
                            }

                            RowLayout {
                                spacing: Theme.spacingSM
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: prevMedia.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                                    Text { anchors.centerIn: parent; text: "⏮"; color: Theme.text; font.pixelSize: 14 }
                                    MouseArea { id: prevMedia; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: musicControl.previous() }
                                }
                                Rectangle {
                                    width: 44; height: 44; radius: 22
                                    color: Theme.primary
                                    Text { anchors.centerIn: parent; text: musicControl.isPlaying ? "⏸" : "▶"; color: Theme.onPrimary; font.pixelSize: 16 }
                                    MouseArea { id: playMedia; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: musicControl.togglePlayPause() }
                                }
                                Rectangle {
                                    width: 36; height: 36; radius: 18
                                    color: nextMedia.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                                    Text { anchors.centerIn: parent; text: "⏭"; color: Theme.text; font.pixelSize: 14 }
                                    MouseArea { id: nextMedia; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: musicControl.next() }
                                }
                            }
                        }
                    }
                }

                // System Tab
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing2XL

                        MetricRing {
                            label: "CPU"
                            value: systemInfo.cpuUsage
                            accent: Theme.primary
                            implicitWidth: 80
                            implicitHeight: 90
                        }
                        MetricRing {
                            label: "RAM"
                            value: systemInfo.memoryUsage
                            accent: Theme.accent
                            implicitWidth: 80
                            implicitHeight: 90
                        }

                        Rectangle {
                            width: 1; height: 64
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        ColumnLayout {
                            spacing: Theme.spacingSM
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: Theme.spacingSM
                                Text { text: "💻"; font.pixelSize: 20 }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: systemInfo.hostName; color: Theme.text; font.pixelSize: Theme.fontMD; font.weight: Font.DemiBold }
                                    Text { text: "Uptime: " + systemInfo.uptime; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                }
                            }

                            RowLayout {
                                spacing: Theme.spacingMD
                                ColumnLayout { spacing: 2
                                    Text { text: "OS"; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                    Text { text: "Windows 11"; color: Theme.text; font.pixelSize: Theme.fontSM; font.weight: Font.DemiBold }
                                }
                                ColumnLayout { spacing: 2
                                    Text { text: "CPU Temp"; color: Theme.textMuted; font.pixelSize: Theme.fontXS }
                                    Text { text: "—"; color: Theme.text; font.pixelSize: Theme.fontSM; font.weight: Font.DemiBold }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
