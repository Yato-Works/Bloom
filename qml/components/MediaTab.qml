import QtQuick
import QtQuick.Layouts
import Bloom

RowLayout {
    spacing: 24
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true

    Rectangle {
        implicitWidth: 72
        implicitHeight: 72
        radius: 20
        color: Qt.rgba(0.05, 0.06, 0.1, 0.7)
        border.width: 1.5
        border.color: (musicControl && musicControl.isPlaying) ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)

        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: 24
            color: Theme.accent
            opacity: (musicControl && musicControl.isPlaying) ? 0.25 : 0.0
            z: -1
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Item {
            anchors.centerIn: parent
            width: 44
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: 22
                color: "#11111b"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.2)

                Rectangle {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: 8
                    color: Theme.accent
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u{1F3B5}"
                    font.pixelSize: 16
                }

                RotationAnimation on rotation {
                    running: (musicControl && musicControl.isPlaying) ? true : false
                    from: 0
                    to: 360
                    duration: 6000
                    loops: Animation.Infinite
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: (musicControl && musicControl.trackTitle) ? musicControl.trackTitle : "No media playing"
                    color: "#ffffff"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: (musicControl && musicControl.artistName && musicControl.artistName !== "")
                        ? musicControl.artistName
                        : (musicControl && musicControl.sourceApp ? musicControl.sourceApp : "Bloom Media Player")
                    color: Qt.rgba(1, 1, 1, 0.6)
                    font.pixelSize: 11
                }
            }

            Rectangle {
                implicitWidth: cavaRow.implicitWidth + 16
                implicitHeight: 38
                radius: 12
                color: Qt.rgba(0.04, 0.05, 0.09, 0.6)
                border.width: 1
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)

                Row {
                    id: cavaRow
                    anchors.centerIn: parent
                    spacing: 3.5
                    height: 28

                    Repeater {
                        model: 20

                        Rectangle {
                            width: 3.5
                            height: {
                                if (cavaService && cavaService.bars && cavaService.bars.length > index) {
                                    var val = cavaService.bars[index]
                                    return Math.max(4, val * 28)
                                }
                                return 4
                            }
                            radius: 1.8
                            anchors.bottom: parent.bottom
                            color: Qt.hsva(0.56 + (index * 0.018), 0.75, 0.95, 0.95)
                            Behavior on height { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: {
                    if (musicControl && musicControl.position > 0) {
                        var m = Math.floor(musicControl.position / 60)
                        var s = musicControl.position % 60
                        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
                    }
                    return "00:00"
                }
                color: Qt.rgba(1, 1, 1, 0.5)
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Rectangle {
                id: progressTrack
                Layout.fillWidth: true
                height: progressMouse.containsMouse ? 6 : 4
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.12)

                Behavior on height { NumberAnimation { duration: 120 } }

                Rectangle {
                    width: parent.width * (musicControl && musicControl.duration > 0 ? (musicControl.position / musicControl.duration) : 0)
                    height: parent.height
                    radius: parent.radius
                    color: Theme.accent

                    Behavior on width { NumberAnimation { duration: 200 } }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: progressMouse.containsMouse ? 12 : 0
                        height: width
                        radius: width / 2
                        color: "#ffffff"
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    id: progressMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Text {
                text: {
                    if (musicControl && musicControl.duration > 0) {
                        var m = Math.floor(musicControl.duration / 60)
                        var s = musicControl.duration % 60
                        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
                    }
                    return "00:00"
                }
                color: Qt.rgba(1, 1, 1, 0.5)
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }
    }

    RowLayout {
        spacing: 8

        Rectangle {
            width: 34
            height: 34
            radius: 17
            color: prevBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: prevBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

            Text { anchors.centerIn: parent; text: "\u23EE"; color: "#ffffff"; font.pixelSize: 12 }
            MouseArea {
                id: prevBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: musicControl.previous()
            }
        }

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: playBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.9) : Theme.accent

            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: 25
                color: Theme.accent
                opacity: playBtnMouse.containsMouse ? 0.4 : 0.15
                z: -1
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            Text {
                anchors.centerIn: parent
                text: (musicControl && musicControl.isPlaying) ? "\u23F8" : "\u25B6"
                color: "#11111b"
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            MouseArea {
                id: playBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: musicControl.playPause()
            }
        }

        Rectangle {
            width: 34
            height: 34
            radius: 17
            color: nextBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: nextBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

            Text { anchors.centerIn: parent; text: "\u23ED"; color: "#ffffff"; font.pixelSize: 12 }
            MouseArea {
                id: nextBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: musicControl.next()
            }
        }
    }
}
