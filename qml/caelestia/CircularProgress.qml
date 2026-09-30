import QtQuick
import Bloom

Item {
    id: root

    property real value: 0.0          // 0.0 to 1.0
    property real strokeWidth: 5
    property color fgColour: Colours.m3primary
    property color bgColour: Colours.m3surfaceContainerHighest
    property real startAngle: -90     // in degrees (-90 = 12 o'clock)
    property real sweepAngle: 360     // in degrees (360 = full circle)
    property string lineCap: "round"
    property bool wavy: false
    property bool wavePaused: false

    implicitWidth: 64
    implicitHeight: 64

    property real animValue: 0.0
    Behavior on animValue {
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    onValueChanged: animValue = Math.max(0.0, Math.min(1.0, root.value))
    Component.onCompleted: animValue = Math.max(0.0, Math.min(1.0, root.value))

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Threaded

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const cx = width / 2;
            const cy = height / 2;
            const radius = Math.min(cx, cy) - root.strokeWidth / 2 - 1;
            if (radius <= 0) return;

            const startRad = (root.startAngle * Math.PI) / 180.0;
            const totalSweepRad = (root.sweepAngle * Math.PI) / 180.0;

            // Background track
            if (root.bgColour.a > 0.01) {
                ctx.beginPath();
                ctx.lineWidth = root.strokeWidth;
                ctx.lineCap = root.lineCap;
                ctx.strokeStyle = root.bgColour.toString();
                ctx.arc(cx, cy, radius, startRad, startRad + totalSweepRad, false);
                ctx.stroke();
            }

            // Foreground progress arc
            const progressSweepRad = totalSweepRad * Math.max(0.001, Math.min(1.0, root.animValue));
            if (progressSweepRad > 0.005) {
                ctx.beginPath();
                ctx.lineWidth = root.strokeWidth;
                ctx.lineCap = root.lineCap;
                ctx.strokeStyle = root.fgColour.toString();
                ctx.arc(cx, cy, radius, startRad, startRad + progressSweepRad, false);
                ctx.stroke();
            }
        }
    }

    onAnimValueChanged: canvas.requestPaint()
    onFgColourChanged: canvas.requestPaint()
    onBgColourChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
}
