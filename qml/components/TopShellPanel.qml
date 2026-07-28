import QtQuick
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelHeight: 148

    height: panelHeight
    opacity: open ? 1 : 0

    transform: Translate {
        y: root.open ? 0 : -(root.panelHeight + 24)
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
        anchors.topMargin: 12
        anchors.bottomMargin: 0
        tint: Theme.surface
        showShadow: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingXL

            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: clockText
                    text: Qt.formatTime(new Date(), "hh:mm")
                    color: Theme.text
                    font.pixelSize: 42
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
                    running: root.open
                    repeat: true
                    onTriggered: {
                        const now = new Date()
                        clockText.text = Qt.formatTime(now, "hh:mm")
                        dateText.text = Qt.formatDate(now, "dddd - MMM d")
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            ColumnLayout {
                spacing: Theme.spacingXS
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.spacingSM
                    Text {
                        text: "cloud"
                        color: Theme.primary
                        font.pixelSize: 22
                    }
                    Text {
                        text: "Weather"
                        color: Theme.text
                        font.pixelSize: Theme.fontMD
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "- " + weatherService.city
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSM
                    }
                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    spacing: Theme.spacingLG
                    Text {
                        text: weatherService.temperature
                        color: Theme.text
                        font.pixelSize: 28
                        font.weight: Font.Light
                    }
                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: weatherService.condition
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSM
                        }
                        Text {
                            text: weatherService.wind + " - " + weatherService.humidity
                            color: Theme.onSurfaceMuted
                            font.pixelSize: Theme.fontXS
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            ColumnLayout {
                spacing: Theme.spacingXS
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.spacingXS
                    Text {
                        text: "music"
                        color: Theme.primary
                        font.pixelSize: 18
                    }
                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: musicControl.trackTitle ?? ""
                            color: Theme.text
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.preferredWidth: 132
                        }
                        Text {
                            text: musicControl.trackArtist ?? ""
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSM
                            elide: Text.ElideRight
                            Layout.preferredWidth: 132
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacingMD
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: prevMedia.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "prev"
                            color: Theme.text
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: prevMedia
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: musicControl.previous()
                        }
                    }
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: playMedia.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16)
                        border.width: 1
                        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                        Text {
                            anchors.centerIn: parent
                            text: musicControl.isPlaying ? "pause" : "play"
                            color: Theme.accent
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: playMedia
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: musicControl.togglePlayPause()
                        }
                    }
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: nextMedia.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "next"
                            color: Theme.text
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: nextMedia
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: musicControl.next()
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            ColumnLayout {
                spacing: Theme.spacingSM
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 220

                Text {
                    text: "System"
                    color: Theme.text
                    font.pixelSize: Theme.fontMD
                    font.weight: Font.DemiBold
                }

                RowLayout {
                    spacing: Theme.spacingMD
                    MetricRing {
                        label: "CPU"
                        value: systemInfo.cpuUsage
                        accent: Theme.primary
                        implicitWidth: 64
                        implicitHeight: 64
                    }
                    MetricRing {
                        label: "RAM"
                        value: systemInfo.memoryUsage
                        accent: Theme.accent
                        implicitWidth: 64
                        implicitHeight: 64
                    }
                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: systemInfo.hostName
                            color: Theme.text
                            font.pixelSize: Theme.fontXS
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.preferredWidth: 90
                        }
                        Text {
                            text: systemInfo.uptime
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontXS
                        }
                    }
                }
            }
        }
    }
}
