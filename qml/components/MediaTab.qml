import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    // State
    property bool expanded: false
    property bool isDashboardOpen: false
    readonly property bool isPlaying: musicControl && musicControl.isPlaying
    readonly property bool hasTrack: musicControl && musicControl.trackTitle && musicControl.trackTitle.length > 0

    // Deterministic color for track (fallback when no art)
    readonly property int trackHash: {
        const title = musicControl ? musicControl.trackTitle : ""
        let h = 0
        for (let i = 0; i < title.length; i++) h = (h * 31 + title.charCodeAt(i)) | 0
        return Math.abs(h)
    }
    readonly property color artColor1: Qt.hsla((root.trackHash % 360) / 360, 0.7, 0.55, 1)
    readonly property color artColor2: Qt.hsla(((root.trackHash * 7 + 120) % 360) / 360, 0.6, 0.45, 1)

    // Animations
    NumberAnimation on rotation {
        running: root.isPlaying
        from: 0; to: 360
        duration: 20000
        loops: Animation.Infinite
        easing.type: Easing.Linear
    }

    Behavior on expanded { NumberAnimation { duration: 200; easing.type: Easing.OutExpo } }

    // Main layout switches between compact and expanded
    RowLayout {
        id: mainRow
        anchors.fill: parent
        anchors.leftMargin: expanded ? 8 : 6
        anchors.rightMargin: expanded ? 8 : 6
        anchors.topMargin: expanded ? 8 : 0
        anchors.bottomMargin: expanded ? 8 : 0
        spacing: expanded ? 16 : 8

        // ── LEFT: Album Art / Pulse Icon ──
        Rectangle {
            id: albumArt

            Layout.preferredWidth: expanded ? 160 : 40
            Layout.preferredHeight: expanded ? 160 : 40
            Layout.maximumWidth: expanded ? 160 : 40
            Layout.maximumHeight: expanded ? 160 : 40
            radius: expanded ? 20 : 20

            // Album art gradient
            gradient: Gradient {
                GradientStop { position: 0; color: root.artColor1 }
                GradientStop { position: 1; color: root.artColor2 }
            }
            Behavior on radius { NumberAnimation { duration: 200 } }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * (root.isPlaying ? 0.85 : 0.6)
                height: parent.height * (root.isPlaying ? 0.85 : 0.6)
                radius: width / 2
                color: Qt.rgba(0, 0, 0, 0.35)

                Text {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: parent.width * 0.35
                    opacity: 0.9
                }
            }

            RotationAnimation on rotation {
                running: root.isPlaying
                from: 0; to: 360
                duration: 25000
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }
        }

        // ── CENTER: Track Info + Progress ──
        ColumnLayout {
            id: centerColumn
            Layout.fillWidth: true
            spacing: expanded ? 6 : 2

            Text {
                id: titleText
                Layout.fillWidth: true
                text: root.hasTrack ? musicControl.trackTitle : qsTr("No media")
                color: Theme.text
                font.pixelSize: expanded ? 16 : 13
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: expanded ? 2 : 1
            }

            Text {
                id: artistText
                Layout.fillWidth: true
                text: {
                    if (musicControl && musicControl.artistName && musicControl.artistName !== "")
                        return musicControl.artistName
                    if (musicControl && musicControl.sourceApp)
                        return musicControl.sourceApp
                    return qsTr("Bloom Media Player")
                }
                color: Qt.rgba(1, 1, 1, 0.6)
                font.pixelSize: expanded ? 13 : 11
                elide: Text.ElideRight
                visible: root.hasTrack
            }

            // Progress bar
            Item {
                id: progressRow
                Layout.fillWidth: true
                visible: root.hasTrack
                height: expanded ? 20 : 14

                // Background track
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: expanded ? 7 : 4
                    height: expanded ? 4 : 3
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.1)

                    Behavior on height { NumberAnimation { duration: 120 } }
                }

                // Filled progress
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: expanded ? 7 : 4
                    height: expanded ? 4 : 3
                    radius: height / 2
                    color: Theme.accent
                    width: {
                        if (!musicControl || !musicControl.duration) return 0
                        return parent.width * (musicControl.position / musicControl.duration)
                    }

                    Behavior on width { NumberAnimation { duration: 150 } }

                    // Thumb
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: expanded ? 10 : 8
                        height: width
                        radius: width / 2
                        color: "#ffffff"
                        opacity: root.isPlaying ? 0.9 : 0.5
                        visible: expanded

                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                // Seek handle
                Rectangle {
                    id: seekHandle
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 0
                    height: expanded ? 16 : 12
                    radius: 8
                    color: "transparent"

                    Behavior on width { NumberAnimation { duration: 120 } }
                    Behavior on x { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: {
                        if (!musicControl || !musicControl.duration) return
                        const ratio = mouse.x / width
                        // For demo, just advance position
                        musicControl.position = Math.round(ratio * musicControl.duration)
                    }
                }
            }

            // Time labels (expanded only)
            RowLayout {
                id: timeRow
                visible: expanded
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: {
                        if (!musicControl || musicControl.position <= 0) return "0:00"
                        const m = Math.floor(musicControl.position / 60)
                        const s = musicControl.position % 60
                        return m + ":" + (s < 10 ? "0" : "") + s
                    }
                    color: Qt.rgba(1, 1, 1, 0.5)
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: {
                        if (!musicControl || musicControl.duration <= 0) return "0:00"
                        const m = Math.floor(musicControl.duration / 60)
                        const s = musicControl.duration % 60
                        return m + ":" + (s < 10 ? "0" : "") + s
                    }
                    color: Qt.rgba(1, 1, 1, 0.5)
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        // ── RIGHT: Controls + Mini CAVA ──
        RowLayout {
            id: controlsRow
            spacing: 4
            visible: !expanded

            Rectangle {
                id: miniCava

                implicitWidth: cavaRow.implicitWidth + 10
                implicitHeight: 28
                radius: 10
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                border.width: 1
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)

                Row {
                    id: cavaRow
                    anchors.centerIn: parent
                    spacing: 2.5
                    height: 20

                    Repeater {
                        model: 6

                        Rectangle {
                            width: 2.5
                            height: {
                                if (cavaService && cavaService.bars && cavaService.bars.length > index * 3) {
                                    return Math.max(3, cavaService.bars[index * 3] * 18)
                                }
                                return 3
                            }
                            radius: 1.2
                            anchors.bottom: parent.bottom
                            color: Theme.accent
                            opacity: 0.8

                            Behavior on height { NumberAnimation { duration: 60; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }
        }

        RowLayout {
            id: expandedControls
            visible: expanded
            spacing: 6
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.07)
                border.width: 1
                border.color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.28) : "transparent"

                Text { anchors.centerIn: parent; text: "⏮"; color: "#ffffff"; font.pixelSize: 13 }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: musicControl.previous()
                }
            }

            Rectangle {
                implicitWidth: 52
                implicitHeight: 52
                radius: 26
                color: playMouse.containsMouse ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.9)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    radius: 30
                    color: Theme.accent
                    opacity: playMouse.containsMouse ? 0.35 : 0.15
                    z: -1
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "⏸" : "▶"
                    color: "#11111b"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: musicControl.playPause()
                }
            }

            Rectangle {
                implicitWidth: 36
                implicitHeight: 36
                radius: 18
                color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.07)
                border.width: 1
                border.color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.28) : "transparent"

                Text { anchors.centerIn: parent; text: "⏭"; color: "#ffffff"; font.pixelSize: 13 }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: musicControl.next()
                }
            }
        }
    }

    // Expanded glow
    Rectangle {
        anchors.fill: albumArt
        radius: albumArt.radius + 4
        color: "transparent"
        border.width: expanded ? 2 : 0
        border.color: Qt.rgba(root.artColor1.r, root.artColor1.g, root.artColor1.b, 0.3)
        visible: expanded
        Behavior on border.width { NumberAnimation { duration: 200 } }
    }
}
