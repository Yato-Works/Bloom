// BloomMonthGrid — compact September-style month view used by the control panel.
// Computes a 6x7 cell matrix (42 cells) from a JS Date so it works for any
// month/year; the today cell is highlighted with the accent color.
import QtQuick
import QtQuick.Controls

Item {
    id: root
    property int year: new Date().getFullYear()
    property int month: new Date().getMonth()   // 0-11
    readonly property int today: new Date().getDate()
    readonly property bool isCurrentMonth: root.year === new Date().getFullYear() && root.month === new Date().getMonth()

    property color accent: "#edb3d1"
    property color todayColor: "#edb3d1"   // set by BloomTopBar / BloomControlPanel
    property color textHi: "#eceef4"
    property color textDim: "#8a8d9e"
    property string fontMono: "Cascadia Code"

    property int cell: 25
    readonly property int gutter: 4
    readonly property int cols: 7

    implicitWidth: cols * cell + (cols - 1) * gutter
    implicitHeight: 7 * cell + 6 * gutter

    // ---- data ----
    property var cells: []

    function recompute() {
        const first = new Date(root.year, root.month, 1);
        const start = first.getDay();                       // 0=Sun
        const dim = new Date(root.year, root.month + 1, 0).getDate();
        const cy = new Date().getFullYear(), cm = new Date().getMonth(), cd = new Date().getDate();
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = i - start + 1;
            out.push({
                day: d,
                inMonth: d >= 1 && d <= dim,
                isToday: d === cd && root.month === cm && root.year === cy
            });
        }
        root.cells = out;
    }
    onYearChanged: recompute()
    onMonthChanged: recompute()
    Component.onCompleted: recompute()

    function monthName(m) {
        const n = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        return n[m] || "";
    }

    // ---- layout ----
    Column {
        anchors.fill: parent
        spacing: root.gutter

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.gutter
            Text {
                text: root.monthName(root.month)
                font.family: root.fontMono
                font.pixelSize: 11
                color: root.textHi
                font.weight: Font.DemiBold
            }
            Text {
                text: String(root.year)
                font.family: root.fontMono
                font.pixelSize: 11
                color: root.textDim
            }
        }

        Grid {
            columns: root.cols
            rows: 6
            spacing: root.gutter
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: root.cells
                delegate: Item {
                    required property var modelData
                    width: root.cell
                    height: root.cell
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 4
                        color: modelData.isToday ? root.todayColor : "transparent"
                        visible: modelData.isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.inMonth ? modelData.day : ""
                        font.family: root.fontMono
                        font.pixelSize: 10
                        color: modelData.isToday ? "#2b0e1b" : (modelData.inMonth ? root.textHi : root.textDim)
                        opacity: modelData.inMonth ? 1 : 0.28
                    }
                }
            }
        }
    }
}
