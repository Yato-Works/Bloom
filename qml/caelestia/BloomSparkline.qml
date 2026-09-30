// BloomSparkline — a compact Canvas area+line sparkline for the top bar.
//
// Pulls a live numeric binding (liveValue) on its own cadence so the bar can
// show a moving CPU / RAM / network graph without any external history buffer.
// The panel version feeds it historical values via push() instead.
import QtQuick

Item {
    id: root

    // Public API ----------------------------------------------------------
    property color lineColor: "#edb3d1"
    property color fillColor: Qt.rgba(0.933, 0.70, 0.82, 0.16)
    property int maxPoints: 36
    property real minValue: 0
    property real maxValue: 100
    property real liveValue: 0            // bind to e.g. systemInfo.cpuUsage
    property int intervalMs: 1000         // sampling cadence
    property bool sampling: true         // stop the timer when the bar is hidden

    // Public imperative API ------------------------------------------------
    function push(v) {
        const n = Number(v);
        if (!isFinite(n))
            return;
        root.values = root.values.concat([n]);
        if (root.values.length > root.maxPoints)
            root.values = root.values.slice(root.values.length - root.maxPoints);
        canvas.requestPaint();
    }
    function clear() {
        root.values = [];
        canvas.requestPaint();
    }

    // Internal state -------------------------------------------------------
    property var values: []

    Timer {
        id: sampler
        interval: root.intervalMs
        repeat: true
        running: root.sampling
        onTriggered: root.push(root.liveValue)
    }
    Component.onCompleted: {
        sampler.start();
        canvas.requestPaint();
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            ctx.clearRect(0, 0, w, h);

            const vals = root.values;
            if (vals.length < 2) {
                // subtle baseline so the chip never looks empty
                ctx.strokeStyle = root.lineColor;
                ctx.globalAlpha = 0.25;
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(3, h - 2);
                ctx.lineTo(w - 3, h - 2);
                ctx.stroke();
                ctx.globalAlpha = 1;
                return;
            }
            const span = Math.max(1e-6, root.maxValue - root.minValue);
            const stepX = w / (root.maxPoints - 1);
            const pts = [];
            for (let i = 0; i < vals.length; i++) {
                const v = Math.max(root.minValue, Math.min(root.maxValue, vals[i]));
                const x = i * stepX;              // oldest at left, newest at right
                const y = Math.max(0, Math.min(h, h - (v - root.minValue) / span * h));
                pts.push([x, y]);
            }
            // filled area under the line
            ctx.fillStyle = root.fillColor;
            ctx.beginPath();
            ctx.moveTo(pts[0][0], h);
            for (let i = 0; i < pts.length; i++)
                ctx.lineTo(pts[i][0], pts[i][1]);
            ctx.lineTo(pts[pts.length - 1][0], h);
            ctx.closePath();
            ctx.fill();
            // strokes + rounded caps
            ctx.strokeStyle = root.lineColor;
            ctx.lineWidth = 1.5;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.moveTo(pts[0][0], pts[0][1]);
            for (let i = 1; i < pts.length; i++)
                ctx.lineTo(pts[i][0], pts[i][1]);
            ctx.stroke();
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    onSamplingChanged: {
        if (!root.sampling)
            sampler.stop();
        else
            sampler.start();
    }
}
