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

    // Slide from above (transform avoids fighting anchors)
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

    // β: keep open while pointer is over the panel
    MouseArea {
        id: panelMouse
        anchors.fill: parent
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

            // Clock
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
                    text: Qt.formatDate(new Date(), "dddd · MMM d")
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
                        dateText.text = Qt.formatDate(now, "dddd · MMM d")
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

            // Weather
            ColumnLayout {
                spacing: Theme.spacingXS
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.spacingSM
                    Text {
                        text: "☁"
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
                        text: "· " + weatherService.city
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
                            text: weatherService.wind + "  ·  " + weatherService.humidity
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

            // System glance
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
