// BloomControlPanel — the detailed slide-down panel revealed beneath the top
// bar. Three modular cards (Weather / System graphs / Calendar) over a
// translucent "glass" backdrop that blurs the live wallpaper.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root
    property bool open: false
    property string wallSrc: ""
    readonly property bool hovered: panelHover.hovered
    readonly property int panelHeight: st.panelHeight

    BloomShellStyle { id: st }

    width: parent.width
    height: root.panelHeight
    opacity: root.open ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200 } }
    visible: opacity > 0.01 || root.open
    clip: true

    HoverHandler { id: panelHover }

    // ---- glass backdrop: blur the wallpaper behind the panel ----
    Image {
        id: bg
        anchors.fill: parent
        source: root.wallSrc
        fillMode: Image.PreserveAspectCrop
        cache: false
        visible: false
    }
    MultiEffect {
        anchors.fill: bg
        source: bg
        visible: bg.status === Image.Ready && root.open
        blurEnabled: true
        blur: 0.55
        blurMax: 28
        brightness: -0.08
        saturation: 0.95
    }
    Rectangle {
        anchors.fill: parent
        color: st.panelColor
        border.width: 1; border.color: st.lineSoft
    }

    // ---- demo 5-day forecast (WeatherService exposes current conditions only) ----
    readonly property var forecast: [
        { day: "SUN", glyph: "☀️", hi: "31" },
        { day: "MON", glyph: "🌤️", hi: "30" },
        { day: "TUE", glyph: "☁️", hi: "27" },
        { day: "WED", glyph: "🌧️", hi: "24" },
        { day: "THU", glyph: "🌦️", hi: "28" }
    ]

    // ---- system history for the panel monitor rows ----
    // (sparklines are fed here with sampling disabled so data flows only
    //  while the panel is open)
    property var cpuHist: []
    property var ramHist: []
    Timer {
        interval: 1100; repeat: true; running: root.open; triggeredOnStart: true
        onTriggered: {
            if (typeof cpuSpark !== "undefined") cpuSpark.push(systemInfo.cpuUsage)
            if (typeof ramSpark !== "undefined") ramSpark.push(systemInfo.memoryUsage)
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // Weather card
        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            Rectangle { anchors.fill: parent; radius: st.radiusCard;
                color: st.cardColor; border.width: 1; border.color: st.lineSoft }
            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 6
                Row {
                    spacing: 10
                    Text {
                        id: tempNum
                        text: weatherService.temperature === "" ? "23" :
                              (weatherService.temperature + "").replace(/[^0-9\-]/g, "")
                        color: st.pink; font.pixelSize: 38; font.weight: Font.Thin
                        font.family: st.fontUi
                    }
                    Text { text: "°"; color: st.pink; font.pixelSize: 30; font.weight: Font.Thin; font.family: st.fontUi
                           anchors.verticalCenter: tempNum.verticalCenter }
                    Column {
                        anchors.verticalCenter: tempNum.verticalCenter
                        Text { text: st.weatherGlyph(weatherService.condition); font.pixelSize: 15 }
                        Text {
                            text: weatherService.condition === "" ? "Partly cloudy" : weatherService.condition
                            color: st.textHi; font.family: st.fontUi; font.pixelSize: 11; font.weight: Font.DemiBold
                        }
                        Text {
                            text: weatherService.city === "" ? "Tokyo, Japan" : weatherService.city
                            color: st.textLow; font.family: st.fontUi; font.pixelSize: 10
                        }
                    }
                }
                Row { spacing: 20
                    Column { Text { text: weatherService.humidity === "" ? "68" : (weatherService.humidity + "").replace(/[^0-9]/g, ""); color: st.textHi; font.family: st.fontMono; font.pixelSize: 11; font.weight: Font.Bold } Text { text: "湿度"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 8 } }
                    Column { Text { text: weatherService.wind === "" ? "12" : (weatherService.wind + "").replace(/[^0-9]/g, ""); color: st.textHi; font.family: st.fontMono; font.pixelSize: 11; font.weight: Font.Bold } Text { text: "風"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 8 } }
                    Column { Text { text: weatherService.pressure === "" ? "1012" : (weatherService.pressure + "").replace(/[^0-9]/g, ""); color: st.textHi; font.family: st.fontMono; font.pixelSize: 11; font.weight: Font.Bold } Text { text: "気圧"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 8 } }
                }
                // 5-day forecast rows
                Row {
                    spacing: 14
                    Repeater {
                        model: root.forecast
                        delegate: Column {
                            required property var modelData
                            Item { height: 4 }
                            Text { text: modelData.day; color: st.textLow; font.family: st.fontUi; font.pixelSize: 9; opacity: 0.8 }
                            Text { text: modelData.glyph; font.pixelSize: 14 }
                            Text { text: modelData.hi + "°"; color: st.textMid; font.family: st.fontMono; font.pixelSize: 10 }
                        }
                    }
                }
            }
        }
// System monitor card
        Item {
            Layout.fillWidth: true; Layout.preferredWidth: 290; Layout.fillHeight: true
            Rectangle { anchors.fill: parent; radius: st.radiusCard; color: st.cardColor; border.width: 1; border.color: st.lineSoft }
            Column { anchors.fill: parent; anchors.margins: 10; spacing: 10
                Text { text: "System Monitor"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 10; opacity: 0.85 }

                Item { width: parent.width; height: 32
                    Row { anchors.fill: parent; anchors.margins: 4; spacing: 8
                        Text { text: "CPU"; color: st.textLow; font.family: st.fontMono; font.pixelSize: 9;
                               width: 28; anchors.verticalCenter: parent.verticalCenter }
                        BloomSparkline { id: cpuSpark; width: 120; height: 16; lineColor: st.pink; fillColor: st.pinkSoft; sampling: false }
                        Text { text: systemInfo.cpuUsage + "%"; color: systemInfo.cpuUsage > 85 ? st.bad : st.textHi;
                               font.family: st.fontMono; font.pixelSize: 11; width: 34; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Item { width: parent.width; height: 32
                    Row { anchors.fill: parent; anchors.margins: 4; spacing: 8
                        Text { text: "MEM"; color: st.textLow; font.family: st.fontMono; font.pixelSize: 9;
                               width: 28; anchors.verticalCenter: parent.verticalCenter }
                        BloomSparkline { id: ramSpark; width: 120; height: 16; lineColor: st.blue; fillColor: Qt.rgba(0.575, 0.70, 0.950, 0.12); sampling: false }
                        Text { text: systemInfo.memoryUsage + "%"; color: st.textHi;
                               font.family: st.fontMono; font.pixelSize: 11; width: 34; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Item { width: parent.width; height: 32
                    Row { anchors.fill: parent; anchors.margins: 4; spacing: 8
                        Text { text: "NET"; color: st.textLow; font.family: st.fontMono; font.pixelSize: 9;
                               width: 28; anchors.verticalCenter: parent.verticalCenter }
                        BloomSparkline { id: netSpark; width: 120; height: 16; lineColor: st.green; fillColor: Qt.rgba(0.337, 0.70, 0.43, 0.10); sampling: false }
                        Text { text: "LAN"; color: st.textHi;
                               font.family: st.fontMono; font.pixelSize: 11; width: 34; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Text { text: "Nice · calm · connected"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 9 }
            }
        }

        // Calendar card
        Item {
            Layout.fillWidth: true; Layout.preferredWidth: 230; Layout.fillHeight: true
            Rectangle { anchors.fill: parent; radius: st.radiusCard; color: st.cardColor; border.width: 1; border.color: st.lineSoft }
            Column { anchors.fill: parent; anchors.margins: 10; spacing: 6
                Row { spacing: 8
                    Text { text: st.monthName(new Date().getMonth()).toUpperCase();
                        color: st.textHi; font.family: st.fontUi; font.pixelSize: 11; font.weight: Font.DemiBold }
                    Text { text: String(new Date().getFullYear());
                        color: st.textLow; font.family: st.fontMono; font.pixelSize: 9 }
                }
                BloomMonthGrid {
                    width: implicitWidth; height: implicitHeight
                    year: new Date().getFullYear(); month: new Date().getMonth();
                    todayColor: st.pink; textHi: st.textHi; textDim: st.textLow;
                    fontMono: st.fontMono; cell: 22
                }
                Text { text: "Today · focus blocks 14:30 / 19:00"; color: st.textLow; font.family: st.fontUi; font.pixelSize: 8 }
            }
        }
    }
}
