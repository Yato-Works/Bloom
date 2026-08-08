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
        spacing: 20

        Text { text: "Media Player"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 420
                radius: 28
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                border.width: 1
                border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.2)

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    Rectangle {
                        id: albumArt
                        implicitWidth: 280
                        implicitHeight: 280
                        radius: 140
                        color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15)
                        border.width: 3
                        border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.4)

                        Rectangle {
                            anchors.centerIn: parent
                            width: 200; height: 200; radius: 100
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.2)
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 40; height: 40; radius: 20
                            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.9)
                        }

                        Text { anchors.centerIn: parent; text: "🎹🐱"; font.pixelSize: 48 }

                        RotationAnimation {
                            target: albumArt
                            running: musicControl && musicControl.isPlaying
                            from: 0; to: 360; duration: 20000; loops: Animation.Infinite
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text { text: musicControl && musicControl.trackTitle ? musicControl.trackTitle : "Chain Boom"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter }
                        Text { text: musicControl && musicControl.artistName ? musicControl.artistName : "Bloom Audio"; color: Theme.textMuted; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter }
                    }

                    Canvas {
                        id: progressCanvas
                        width: 320; height: 320
                        property real progress: 0.45

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var centerX = width / 2
                            var centerY = height / 2
                            var radius = 140

                            ctx.lineWidth = 6
                            ctx.strokeStyle = Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15)
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
                            ctx.stroke()

                            ctx.lineWidth = 6
                            ctx.lineCap = "round"
                            ctx.strokeStyle = Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 1.0)
                            ctx.beginPath()
                            var startAngle = -Math.PI / 2
                            var endAngle = startAngle + (Math.PI * 2 * progress)
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                            ctx.stroke()
                        }
                    }

                    RowLayout { spacing: 20
                        ControlBtn { icon: "⏮"; onClicked: musicControl.previous() }
                        ControlBtn { icon: musicControl && musicControl.isPlaying ? "⏸" : "▶"; color: Theme.tertiary; size: 56; onClicked: musicControl.playPause() }
                        ControlBtn { icon: "⏭"; onClicked: musicControl.next() }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 280
                    radius: 20
                    color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text { text: "CAVA VISUALIZER"; color: Theme.tertiary; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1 }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 3
                                Layout.alignment: Qt.AlignBottom

                                Repeater {
                                    model: 32
                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: cavaService && cavaService.bars && cavaService.bars.length > index
                                            ? Math.max(4, cavaService.bars[index] * 220)
                                            : Math.max(4, Math.random() * 180 + 30)
                                        radius: 2.5
                                        color: Qt.hsla(0.55 + (index * 0.015), 0.85, 0.65, 0.95)
                                        anchors.bottom: parent.bottom
                                        Behavior on height { NumberAnimation { duration: 50 } }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    radius: 20
                    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text { text: "Up Next"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            model: 5
                            delegate: Rectangle {
                                width: parent.width
                                height: 48
                                radius: 10
                                color: index === 0 ? Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15) : "transparent"

                                RowLayout { anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                                    Text { text: "🎵"; font.pixelSize: 18 }
                                    ColumnLayout { spacing: 1
                                        Text { text: index === 0 ? "Chain Boom" : "Track " + (index+1); color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold }
                                        Text { text: "Artist " + (index+1); color: Theme.textMuted; font.pixelSize: 11 }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text { text: index === 0 ? "▶" : ""; color: Theme.tertiary; font.pixelSize: 14 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}