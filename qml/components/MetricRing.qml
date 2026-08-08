import QtQuick

Item {
    id: root
    property string label: "CPU"
    property int value: 23
    property color accent: Theme.primary
    property int ringWidth: 4
    implicitWidth: 72
    implicitHeight: 82

    // Background ring track
    Canvas {
        id: track
        anchors.centerIn: parent
        width: 56; height: 56
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.lineWidth = root.ringWidth
            ctx.strokeStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.15)
            ctx.beginPath()
            ctx.arc(28, 28, 24, 0, Math.PI * 2)
            ctx.stroke()
        }
    }

    // Foreground arc (animated)
    Canvas {
        id: ringCanvas
        anchors.centerIn: parent
        width: 56; height: 56
        property real progress: 0.0

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.lineWidth = root.ringWidth
            ctx.lineCap = "round"
            ctx.strokeStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b,
                                      0.75 + progress * 0.25)
            ctx.beginPath()
            var startAngle = -Math.PI / 2
            var endAngle = startAngle + (Math.PI * 2 * Math.min(progress, 1.0))
            ctx.arc(28, 28, 24, startAngle, endAngle)
            ctx.stroke()
        }
        onProgressChanged: requestPaint()

        Behavior on progress {
            NumberAnimation {
                duration: Theme.durationDefault
                easing.type: Easing.OutCubic
            }
        }

        Connections {
            target: root
            function onValueChanged() {
                ringCanvas.progress = root.value / 100.0
            }
            function onAccentChanged() { ringCanvas.requestPaint(); track.requestPaint(); }
        }
        Component.onCompleted: ringCanvas.progress = root.value / 100.0
    }

    // Inner glow dot
    Rectangle {
        anchors.centerIn: parent
        width: 16; height: 16
        radius: 8
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1)
    }

    Text {
        anchors.centerIn: parent
        text: root.value + "%"
        color: Theme.text
        font.pixelSize: 13
        font.bold: true
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 4
        text: root.label
        color: Theme.textMuted
        font.pixelSize: 10
        font.weight: Font.DemiBold
    }
}
