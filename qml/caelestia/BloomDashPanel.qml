// BloomDashPanel — the Caelestia-style tabbed tile dashboard that drops below
// the top bar. Tabs (Dashboard / Media / Performance / Weather) switch the
// whole content, one view at a time - the aesthetics of subtraction. Tiles are
// separate rounded surfaces with breathing room, exactly like the reference
// screenshots.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root

    property bool open: false
    property string wallSrc: ""   // kept for chrome API compatibility
    readonly property bool hovered: panelHover.hovered

    property int activeTab: 0   // 0 dashboard, 1 media, 2 performance, 3 weather

    function fmtTime(sec) {
        if (!sec || sec <= 0) return "0:00";
        const m = Math.floor(sec / 60);
        const s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function glyphToIcon(g, cond) {
        const s = ((g || "") + " " + (cond || "")).toLowerCase();
        if (s.indexOf("☀️") !== -1 || s.indexOf("clear") !== -1 || s.indexOf("sunny") !== -1 || s.indexOf("晴") !== -1) return "sunny";
        if (s.indexOf("⛅") !== -1 || s.indexOf("partly") !== -1 || s.indexOf("時々") !== -1) return "partly_cloudy_day";
        if (s.indexOf("☁️") !== -1 || s.indexOf("overcast") !== -1 || s.indexOf("cloud") !== -1 || s.indexOf("くもり") !== -1 || s.indexOf("曇") !== -1) return "cloud";
        if (s.indexOf("🌫️") !== -1 || s.indexOf("fog") !== -1 || s.indexOf("霧") !== -1) return "foggy";
        if (s.indexOf("🌦️") !== -1 || s.indexOf("drizzle") !== -1) return "rainy";
        if (s.indexOf("🌧️") !== -1 || s.indexOf("rain") !== -1 || s.indexOf("雨") !== -1) return "rainy";
        if (s.indexOf("❄️") !== -1 || s.indexOf("snow") !== -1 || s.indexOf("雪") !== -1) return "ac_unit";
        if (s.indexOf("⛈️") !== -1 || s.indexOf("thunder") !== -1 || s.indexOf("雷") !== -1) return "thunderstorm";
        return "partly_cloudy_day";
    }

    width: 960
    height: 460

    BloomShellStyle { id: st }

    opacity: root.open ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { BloomAnim { type: root.open ? BloomAnim.DefaultEffects : BloomAnim.FastEffects } }

    HoverHandler { id: panelHover }

    // ---- floating panel surface ----
    Rectangle {
        id: panelBg
        anchors.fill: parent
        radius: 28
        color: Qt.alpha(Colours.m3surfaceContainerLowest, 0.94)
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        clip: true

        // Specular top highlight (refraction edge)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1.5
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.16)
        }
    }
    MultiEffect {
        anchors.fill: panelBg
        source: panelBg
        shadowEnabled: true
        shadowBlur: 0.75
        shadowColor: Qt.rgba(0, 0, 0, 0.55)
        shadowVerticalOffset: 8
        z: -1
    }

    // Reusable tile surface
    component Tile: Rectangle {
        id: tile
        default property alias content: tileData.data
        color: Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
        radius: 22
        border.width: 1
        border.color: tileHover.hovered ? Qt.alpha(Colours.m3primary, 0.45) : Qt.alpha(Colours.m3outlineVariant, 0.28)
        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Specular top highlight for glass feel
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.10)
        }

        HoverHandler { id: tileHover }

        Item {
            id: tileData
            anchors.fill: parent
            anchors.margins: 14
        }
    }

    // ============================================================ tab row
    Row {
        id: tabBar
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Repeater {
            model: [
                { icon: "dashboard",    label: "Dashboard" },
                { icon: "music_note",   label: "Media" },
                { icon: "speed",        label: "Performance" },
                { icon: "partly_cloudy_day", label: "Weather" }
            ]
            delegate: Item {
                id: tab
                required property var modelData
                required property int index
                readonly property bool active: root.activeTab === index

                width: tabRow.implicitWidth + 28
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: tab.active ? Qt.alpha(Colours.m3secondaryContainer, 0.9)
                        : (tabHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.12) : "transparent")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
                // active underline
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: tab.active ? 26 : 0
                    height: 3
                    radius: 1.5
                    color: tab.active ? Colours.m3primary : "transparent"
                    Behavior on width { BloomAnim { type: BloomAnim.FastEffects } }
                }
                HoverHandler { id: tabHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: root.activeTab = tab.index }

                Row {
                    id: tabRow
                    anchors.centerIn: parent
                    spacing: 7
                    BloomIcon {
                        text: tab.modelData.icon
                        color: tab.active ? Colours.m3onSecondaryContainer : Colours.m3onSurfaceVariant
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: tab.modelData.label
                        color: tab.active ? Colours.m3onSecondaryContainer : Colours.m3onSurfaceVariant
                        font.family: "Rubik"
                        font.pixelSize: 12
                        font.weight: tab.active ? Font.DemiBold : Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }
            }
        }
    }

    // ============================================================ content
    Item {
        anchors.top: tabBar.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        clip: true

        // ------------------------------------------------ Dashboard tiles
        Item {
            visible: opacity > 0.01
            opacity: root.activeTab === 0 ? 1 : 0
            Behavior on opacity { BloomAnim { type: BloomAnim.FastEffects } }
            enabled: root.activeTab === 0
            anchors.fill: parent

            RowLayout {
                anchors.fill: parent
                spacing: 12

                // ==== Column 1: Weather + Clock & Uptime ====
                ColumnLayout {
                    Layout.preferredWidth: 270
                    Layout.fillHeight: true
                    spacing: 12

                    // Weather Tile
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    width: 24; height: 24; radius: 12
                                    color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                                    BloomIcon { anchors.centerIn: parent; text: "partly_cloudy_day"; color: Colours.m3primary; font.pixelSize: 13 }
                                }
                                Text { text: "Weather"; color: Colours.m3primary; font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.DemiBold }
                                Item { Layout.fillWidth: true }
                                Text { text: weatherService.city; color: Colours.m3onSurfaceVariant; font.family: "Rubik"; font.pixelSize: 11; elide: Text.ElideRight; Layout.maximumWidth: 120 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 14

                                BloomIcon {
                                    text: root.glyphToIcon(weatherService.condition, weatherService.condition)
                                    font.pixelSize: 42
                                    color: Colours.m3secondary
                                    SequentialAnimation on y {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: -3; duration: 2000; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 3; duration: 2000; easing.type: Easing.InOutSine }
                                    }
                                }

                                ColumnLayout {
                                    spacing: 1
                                    Row {
                                        spacing: 2
                                        Text {
                                            id: tempBig
                                            text: (weatherService.temperature + "").replace(/[^0-9\-]/g, "")
                                            color: Colours.m3onSurface
                                            font.family: "Rubik"
                                            font.pixelSize: 34
                                            font.weight: Font.Thin
                                        }
                                        Text {
                                            text: "°C"
                                            color: Colours.m3onSurface
                                            font.family: "Rubik"
                                            font.pixelSize: 16
                                            font.weight: Font.Thin
                                            anchors.baseline: tempBig.baseline
                                        }
                                    }
                                    Text {
                                        text: weatherService.condition
                                        color: Colours.m3onSurface
                                        font.family: "Rubik"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 150
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                BloomIcon { text: "thermostat"; color: Colours.m3secondary; font.pixelSize: 13 }
                                Text { text: "Feels like " + weatherService.feelsLike + " · Hum " + weatherService.humidity; color: Colours.m3onSurfaceVariant; font.family: "Rubik"; font.pixelSize: 10 }
                            }
                        }
                    }

                    // Clock & System Status Tile
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    width: 24; height: 24; radius: 12
                                    color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                                    BloomIcon { anchors.centerIn: parent; text: "schedule"; color: Colours.m3primary; font.pixelSize: 13 }
                                }
                                Text { text: "System Time"; color: Colours.m3primary; font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.DemiBold }
                            }

                            Text {
                                text: systemInfo.formattedTime
                                color: Colours.m3onSurface
                                font.family: "Cascadia Code"
                                font.pixelSize: 34
                                font.weight: Font.Thin
                                font.letterSpacing: 2
                            }

                            Text {
                                text: systemInfo.formattedDate
                                color: Colours.m3primary
                                font.family: "Rubik"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            RowLayout {
                                spacing: 6
                                BloomIcon { text: "timelapse"; color: Colours.m3onSurfaceVariant; font.pixelSize: 13 }
                                Text {
                                    text: "up " + systemInfo.uptime
                                    color: Qt.alpha(Colours.m3onSurfaceVariant, 0.75)
                                    font.family: "Cascadia Code"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                // ==== Column 2: System Architecture + Calendar & Events ====
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // System Architecture Tile
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Rectangle {
                                    width: 46; height: 46; radius: 16
                                    color: Qt.alpha(Colours.m3primaryContainer, 0.45)
                                    border.width: 1
                                    border.color: Qt.alpha(Colours.m3primary, 0.25)
                                    clip: true

                                    // Breathing aura
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 34; height: 34; radius: 17
                                        color: Qt.alpha(Colours.m3primary, 0.20)
                                        SequentialAnimation on scale {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 1.15; duration: 2000; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 0.90; duration: 2000; easing.type: Easing.InOutSine }
                                        }
                                    }

                                    BloomIcon {
                                        anchors.centerIn: parent
                                        text: "desktop_windows"
                                        font.pixelSize: 24
                                        color: Colours.m3primary
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: systemInfo.hostName
                                        color: Colours.m3onSurface
                                        font.family: "Rubik"; font.pixelSize: 14; font.weight: Font.DemiBold
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "Windows 11 · " + systemInfo.memorySummary
                                        color: Colours.m3onSurfaceVariant
                                        font.family: "Rubik"; font.pixelSize: 11
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                }
                            }

                            // Dual Mini Progress Tracks
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                // CPU Bar
                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon { text: "memory"; color: Colours.m3primary; font.pixelSize: 13 }
                                    Text { text: "CPU Load"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 10 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: systemInfo.cpuUsage + "%"; color: Colours.m3primary; font.family: "Cascadia Code"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 6; radius: 3
                                    color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.1)
                                    clip: true
                                    Rectangle {
                                        height: parent.height
                                        width: Math.max(0, parent.width * systemInfo.cpuUsage / 100)
                                        radius: 3
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0; color: systemInfo.cpuUsage > 85 ? Colours.m3error : Colours.m3primary }
                                            GradientStop { position: 1; color: systemInfo.cpuUsage > 85 ? Qt.lighter(Colours.m3error, 1.15) : Qt.lighter(Colours.m3primary, 1.2) }
                                        }
                                        Behavior on width { NumberAnimation { duration: 140 } }
                                    }
                                }

                                // RAM Bar
                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon { text: "sd_storage"; color: Colours.m3secondary; font.pixelSize: 13 }
                                    Text { text: "Memory"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 10 }
                                    Item { Layout.fillWidth: true }
                                    Text { text: systemInfo.memoryUsage + "%"; color: Colours.m3secondary; font.family: "Cascadia Code"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 6; radius: 3
                                    color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.1)
                                    clip: true
                                    Rectangle {
                                        height: parent.height
                                        width: Math.max(0, parent.width * systemInfo.memoryUsage / 100)
                                        radius: 3
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0; color: Colours.m3secondary }
                                            GradientStop { position: 1; color: Qt.lighter(Colours.m3secondary, 1.2) }
                                        }
                                        Behavior on width { NumberAnimation { duration: 140 } }
                                    }
                                }
                            }
                        }
                    }

                    // Calendar & Focus Tile
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.fill: parent
                            spacing: 16

                            BloomMonthGrid {
                                Layout.alignment: Qt.AlignVCenter
                                width: implicitWidth; height: implicitHeight
                                cell: 16
                                todayColor: Colours.m3primary
                                textHi: Colours.m3onSurface
                                textDim: Qt.alpha(Colours.m3onSurfaceVariant, 0.45)
                                fontMono: "Cascadia Code"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                Text {
                                    text: "Today"
                                    color: Colours.m3onSurface
                                    font.family: "Rubik"; font.pixelSize: 14; font.weight: Font.DemiBold
                                }
                                Text {
                                    text: Qt.formatDate(new Date(), "MMMM d, yyyy")
                                    color: Colours.m3primary
                                    font.family: "Rubik"; font.pixelSize: 11; font.weight: Font.Medium
                                }

                                // Status pill badge
                                Rectangle {
                                    height: 22; radius: 11
                                    width: focusPillTxt.implicitWidth + 18
                                    color: Qt.alpha(Colours.m3primaryContainer, 0.45)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3primary, 0.25)

                                    Row {
                                        anchors.centerIn: parent; spacing: 4
                                        Rectangle {
                                            width: 6; height: 6; radius: 3
                                            color: Colours.m3primary
                                            anchors.verticalCenter: parent.verticalCenter
                                            SequentialAnimation on opacity {
                                                loops: Animation.Infinite
                                                NumberAnimation { to: 0.3; duration: 1400; easing.type: Easing.InOutSine }
                                                NumberAnimation { to: 1.0; duration: 1400; easing.type: Easing.InOutSine }
                                            }
                                        }
                                        Text {
                                            id: focusPillTxt
                                            text: "Focus armed · Optimal"
                                            color: Colours.m3primary
                                            font.family: "Rubik"; font.pixelSize: 9; font.weight: Font.Medium
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ==== Column 3: Complete Media Player Hero Tile ====
                Tile {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        // Top header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Rectangle {
                                width: 24; height: 24; radius: 12
                                color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                                BloomIcon { anchors.centerIn: parent; text: "music_note"; color: Colours.m3primary; font.pixelSize: 13 }
                            }
                            Text { text: "Now Playing"; color: Colours.m3primary; font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            // Status pill
                            Rectangle {
                                height: 20; radius: 10
                                width: mpStatusTxt.implicitWidth + 16
                                color: musicControl.isPlaying ? Qt.alpha(Colours.m3primaryContainer, 0.5) : Qt.alpha(Colours.m3surfaceContainerHighest, 0.5)
                                border.width: 1; border.color: musicControl.isPlaying ? Qt.alpha(Colours.m3primary, 0.25) : Qt.alpha(Colours.m3outlineVariant, 0.2)
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Row {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle {
                                        width: 5; height: 5; radius: 2.5
                                        color: musicControl.isPlaying ? Colours.m3primary : Colours.m3outline
                                        anchors.verticalCenter: parent.verticalCenter
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite; running: musicControl.isPlaying
                                            NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                                        }
                                    }
                                    Text {
                                        id: mpStatusTxt
                                        text: musicControl.isPlaying ? "Playing" : "Paused"
                                        color: musicControl.isPlaying ? Colours.m3primary : Colours.m3onSurfaceVariant
                                        font.family: "Rubik"; font.pixelSize: 9; font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        // Hero Cover Art with Ambient Aura + Circular Progress
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 104; height: 104

                            // Ambient Album Aura
                            Rectangle {
                                anchors.centerIn: parent
                                width: 114; height: 114; radius: 57
                                color: Qt.alpha(Colours.m3primary, 0.22)
                                opacity: musicControl.isPlaying ? 0.9 : 0.2
                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    running: musicControl.isPlaying
                                    NumberAnimation { to: 1.12; duration: 1800; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.98; duration: 1800; easing.type: Easing.InOutSine }
                                }
                            }

                            CircularProgress {
                                anchors.fill: parent
                                strokeWidth: 4
                                fgColour: Colours.m3primary
                                bgColour: Colours.m3surfaceContainerHighest
                                value: musicControl.progress
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 84; height: 84; radius: 42
                                color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.9)
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/qt/qml/Bloom/assets/bongocat.gif"
                                    fillMode: Image.PreserveAspectCrop
                                    visible: tileCover.status !== Image.Ready
                                }
                                Image {
                                    id: tileCover
                                    anchors.fill: parent
                                    source: musicControl.thumbnailSource
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    visible: status === Image.Ready
                                    layer.enabled: visible
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: tileCoverMask
                                    }
                                }
                                Item {
                                    id: tileCoverMask
                                    anchors.fill: parent
                                    visible: false
                                    layer.enabled: true
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: width / 2
                                        color: "black"
                                    }
                                }
                            }
                        }

                        // Track title & artist
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: musicControl.trackTitle === "" ? "No active media" : musicControl.trackTitle
                                color: musicControl.trackTitle === "" ? Colours.m3onSurfaceVariant : Colours.m3onSurface
                                font.family: "Rubik"; font.pixelSize: 13; font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: musicControl.artistName === "" ? (musicControl.sourceApp || "Bloom Media") : musicControl.artistName
                                color: Colours.m3onSurfaceVariant
                                font.family: "Rubik"; font.pixelSize: 10
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        // Progress bar track
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Rectangle {
                                id: tileProgTrack
                                Layout.fillWidth: true
                                height: 6; radius: 3
                                color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.1)
                                clip: true

                                Rectangle {
                                    width: Math.max(0, parent.width * musicControl.progress)
                                    height: parent.height
                                    radius: 3
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0; color: Colours.m3primary }
                                        GradientStop { position: 1; color: Qt.lighter(Colours.m3primary, 1.15) }
                                    }
                                    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: root.fmtTime(musicControl.position); color: Colours.m3onSurfaceVariant; font.family: "Cascadia Code"; font.pixelSize: 9 }
                                Item { Layout.fillWidth: true }
                                Text { text: root.fmtTime(musicControl.length); color: Colours.m3onSurfaceVariant; font.family: "Cascadia Code"; font.pixelSize: 9 }
                            }
                        }

                        // Playback buttons
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: musicControl.shuffle ? Qt.alpha(Colours.m3primary, 0.25) : (tShufH.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.1) : "transparent")
                                border.width: musicControl.shuffle ? 1 : 0; border.color: Qt.alpha(Colours.m3primary, 0.25)
                                Behavior on color { ColorAnimation { duration: 150 } }
                                scale: tShufH.hovered ? 1.1 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }
                                HoverHandler { id: tShufH; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: musicControl.shuffle = !musicControl.shuffle }
                                BloomIcon { anchors.centerIn: parent; text: "shuffle"; color: musicControl.shuffle ? Colours.m3primary : Colours.m3onSurfaceVariant; font.pixelSize: 15 }
                            }

                            Rectangle {
                                width: 34; height: 34; radius: 17
                                color: tPrevH.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                                HoverHandler { id: tPrevH; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: musicControl.previous() }
                                BloomIcon { anchors.centerIn: parent; text: "skip_previous"; color: Colours.m3onSurface; font.pixelSize: 18 }
                            }

                            // Hero Pill Play/Pause Button
                            Rectangle {
                                Layout.preferredWidth: 64
                                Layout.preferredHeight: 34
                                radius: 17
                                color: Colours.m3primary
                                HoverHandler { id: tPlayH; cursorShape: Qt.PointingHandCursor }
                                scale: tPlayH.hovered ? 1.06 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }
                                TapHandler { onTapped: musicControl.togglePlayPause() }

                                // Specular top highlight
                                Rectangle {
                                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                    anchors.margins: 1; height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.25)
                                }

                                BloomIcon {
                                    anchors.centerIn: parent
                                    text: musicControl.isPlaying ? "pause" : "play_arrow"
                                    color: Colours.m3onPrimary
                                    font.pixelSize: 19
                                }
                            }

                            Rectangle {
                                width: 34; height: 34; radius: 17
                                color: tNextH.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                                HoverHandler { id: tNextH; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: musicControl.next() }
                                BloomIcon { anchors.centerIn: parent; text: "skip_next"; color: Colours.m3onSurface; font.pixelSize: 18 }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: musicControl.loopState > 0 ? Qt.alpha(Colours.m3primary, 0.25) : (tRepH.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.1) : "transparent")
                                border.width: musicControl.loopState > 0 ? 1 : 0; border.color: Qt.alpha(Colours.m3primary, 0.25)
                                Behavior on color { ColorAnimation { duration: 150 } }
                                scale: tRepH.hovered ? 1.1 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }
                                HoverHandler { id: tRepH; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: musicControl.loopState = (musicControl.loopState + 1) % 3 }
                                BloomIcon { anchors.centerIn: parent; text: musicControl.loopState === 1 ? "repeat_one" : "repeat"; color: musicControl.loopState > 0 ? Colours.m3primary : Colours.m3onSurfaceVariant; font.pixelSize: 15 }
                            }
                        }
                    }
                }
            }
        }

        // ------------------------------------------------ Media view
        Item {
            visible: opacity > 0.01
            opacity: root.activeTab === 1 ? 1 : 0
            Behavior on opacity { BloomAnim { type: BloomAnim.FastEffects } }
            enabled: root.activeTab === 1
            anchors.fill: parent

            CaelestiaMediaTab {
                anchors.fill: parent
            }
        }

        // ------------------------------------------------ Performance view
        Item {
            visible: opacity > 0.01
            opacity: root.activeTab === 2 ? 1 : 0
            Behavior on opacity { BloomAnim { type: BloomAnim.FastEffects } }
            enabled: root.activeTab === 2
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                // Tier 1: Two Spacious Hero Cards
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 165
                    spacing: 12

                    // CPU Hero Card
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Subtle ambient gradient wash
                        Rectangle {
                            anchors.fill: parent; radius: 20; z: -1
                            gradient: Gradient {
                                GradientStop { position: 0; color: Qt.alpha(Colours.m3primary, 0.04) }
                                GradientStop { position: 1; color: "transparent" }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 18

                            // CPU Gauge with Living Breath
                            Item {
                                Layout.alignment: Qt.AlignVCenter
                                width: 100; height: 100

                                // Breathing ambient halo
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 108; height: 108; radius: 54
                                    color: Qt.alpha(Colours.m3primary, 0.12)
                                    SequentialAnimation on scale {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.08; duration: 2400; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 0.94; duration: 2400; easing.type: Easing.InOutSine }
                                    }
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.7; duration: 2400; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 0.25; duration: 2400; easing.type: Easing.InOutSine }
                                    }
                                }

                                CircularProgress {
                                    anchors.centerIn: parent
                                    width: 96; height: 96
                                    strokeWidth: 7
                                    value: systemInfo.cpuUsage / 100
                                    fgColour: Colours.m3primary

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 0
                                        BloomIcon {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: "memory"
                                            color: Colours.m3primary
                                            font.pixelSize: 18
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: systemInfo.cpuUsage + "%"
                                            color: Colours.m3onSurface
                                            font.family: "Cascadia Code"
                                            font.pixelSize: 16
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon { text: "memory_alt"; color: Colours.m3primary; font.pixelSize: 16 }
                                    Text { text: "CPU (Processor)"; color: Colours.m3primary; font.family: "Rubik"; font.pixelSize: 15; font.weight: Font.DemiBold }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        height: 24; radius: 12
                                        width: cpuTierTxt.implicitWidth + 18
                                        color: Qt.alpha(Colours.m3primaryContainer, 0.55)
                                        border.width: 1; border.color: Qt.alpha(Colours.m3primary, 0.3)

                                        // Specular on pill
                                        Rectangle {
                                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                            anchors.margins: 1; height: 1; radius: parent.radius
                                            color: Qt.rgba(1, 1, 1, 0.12)
                                        }

                                        Text {
                                            id: cpuTierTxt
                                            anchors.centerIn: parent
                                            text: systemInfo.cpuUsage < 30 ? "Optimal Load" : (systemInfo.cpuUsage < 75 ? "Moderate Load" : "High Utilization")
                                            color: Colours.m3primary
                                            font.family: "Rubik"; font.pixelSize: 10; font.weight: Font.Medium
                                        }
                                    }
                                }

                                Text {
                                    text: "11th Gen Intel(R) Core(TM) i7-11700 (16 Threads) · x86_64"
                                    color: Colours.m3onSurfaceVariant
                                    font.family: "Rubik"; font.pixelSize: 12
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }

                                // Temperature-style micro sparkline
                                RowLayout {
                                    spacing: 6
                                    BloomIcon { text: "schedule"; color: Colours.m3secondary; font.pixelSize: 13 }
                                    Text {
                                        text: "System Uptime: " + systemInfo.uptime
                                        color: Colours.m3onSurfaceVariant
                                        font.family: "Cascadia Code"; font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }

                    // System Host & Power Hero Card
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Ambient gradient
                        Rectangle {
                            anchors.fill: parent; radius: 20; z: -1
                            gradient: Gradient {
                                GradientStop { position: 0; color: Qt.alpha(Colours.m3secondaryContainer, 0.06) }
                                GradientStop { position: 1; color: "transparent" }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 18

                            // Squircle badge with double-ring aura
                            Item {
                                Layout.alignment: Qt.AlignVCenter
                                width: 96; height: 96

                                // Outer breathing ring
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 100; height: 100; radius: 28
                                    color: "transparent"
                                    border.width: 1.5
                                    border.color: Qt.alpha(Colours.m3secondary, 0.2)
                                    SequentialAnimation on scale {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.06; duration: 2800; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 0.96; duration: 2800; easing.type: Easing.InOutSine }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 92; height: 92; radius: 26
                                    color: Qt.alpha(Colours.m3secondaryContainer, 0.45)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3secondary, 0.3)
                                    clip: true

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 60; height: 60; radius: 30
                                        color: Qt.alpha(Colours.m3secondary, 0.18)
                                        SequentialAnimation on scale {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 1.18; duration: 2200; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 0.92; duration: 2200; easing.type: Easing.InOutSine }
                                        }
                                    }

                                    BloomIcon {
                                        anchors.centerIn: parent
                                        text: "desktop_windows"
                                        font.pixelSize: 38
                                        color: Colours.m3secondary
                                    }

                                    // Specular highlight on badge
                                    Rectangle {
                                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                                        anchors.margins: 1; height: 1; radius: parent.radius
                                        color: Qt.rgba(1, 1, 1, 0.12)
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon { text: "dns"; color: Colours.m3secondary; font.pixelSize: 16 }
                                    Text { text: systemInfo.hostName; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 15; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                                }

                                Text {
                                    text: "Microsoft Windows 11 Home (64-bit Architecture)"
                                    color: Colours.m3onSurfaceVariant
                                    font.family: "Rubik"; font.pixelSize: 12
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }

                                RowLayout {
                                    spacing: 8
                                    BloomIcon {
                                        text: systemInfo.hasBattery ? (systemInfo.batteryCharging ? "battery_charging_full" : "battery_5_bar") : "power"
                                        color: systemInfo.batteryCharging ? Colours.m3primary : Colours.m3success
                                        font.pixelSize: 15
                                    }
                                    Text {
                                        text: systemInfo.hasBattery ? (systemInfo.batteryPercent + "%" + (systemInfo.batteryCharging ? " Charging" : " Battery")) : "AC Power Connected (Optimal)"
                                        color: Colours.m3onSurfaceVariant
                                        font.family: "Rubik"; font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }

                // Tier 2: Three Specialized Cards
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // Memory (RAM) Card
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    width: 26; height: 26; radius: 13
                                    color: Qt.alpha(Colours.m3secondaryContainer, 0.5)
                                    BloomIcon { anchors.centerIn: parent; text: "sd_storage"; color: Colours.m3secondary; font.pixelSize: 14 }
                                }
                                Text { text: "Memory (RAM)"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 13; font.weight: Font.DemiBold }
                                Item { Layout.fillWidth: true }
                                Text { text: systemInfo.memoryUsage + "%"; color: Colours.m3secondary; font.family: "Cascadia Code"; font.pixelSize: 13; font.weight: Font.DemiBold }
                            }

                            // Gradient Progress Bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 8; radius: 4
                                color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.12)
                                clip: true

                                Rectangle {
                                    height: parent.height
                                    width: Math.max(0, parent.width * systemInfo.memoryUsage / 100)
                                    radius: 4
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0; color: Colours.m3secondary }
                                        GradientStop { position: 1; color: Qt.lighter(Colours.m3secondary, 1.2) }
                                    }
                                    Behavior on width { NumberAnimation { duration: 160 } }
                                }
                            }

                            Text {
                                text: systemInfo.memorySummary
                                color: Colours.m3onSurfaceVariant
                                font.family: "Cascadia Code"; font.pixelSize: 11
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }

                            Text {
                                text: "16 GB DDR4 Dual-Channel · Optimal headroom"
                                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                                font.family: "Rubik"; font.pixelSize: 10
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                        }
                    }

                    // Sound & Display Quick Controls Card
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    width: 26; height: 26; radius: 13
                                    color: Qt.alpha(Colours.m3tertiaryContainer, 0.5)
                                    BloomIcon { anchors.centerIn: parent; text: "tune"; color: Colours.m3tertiary; font.pixelSize: 14 }
                                }
                                Text { text: "Controls"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 13; font.weight: Font.DemiBold }
                                Item { Layout.fillWidth: true }
                                // Pill badge
                                Rectangle {
                                    height: 22; radius: 11
                                    width: qaText.implicitWidth + 14
                                    color: Qt.alpha(Colours.m3tertiaryContainer, 0.4)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3tertiary, 0.2)
                                    Text {
                                        id: qaText; anchors.centerIn: parent
                                        text: "Quick Adjust"; color: Colours.m3tertiary
                                        font.family: "Rubik"; font.pixelSize: 9; font.weight: Font.Medium
                                    }
                                }
                            }

                            // Volume Row
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon {
                                        text: systemInfo.volumeMuted ? "volume_off" : (systemInfo.volumeLevel > 50 ? "volume_up" : "volume_down")
                                        color: systemInfo.volumeMuted ? Colours.m3outline : Colours.m3primary
                                        font.pixelSize: 14
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: systemInfo.toggleMute() }
                                    }
                                    Text { text: "Volume"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 10; font.weight: Font.Medium }
                                    Item { Layout.fillWidth: true }
                                    Text { text: systemInfo.volumeMuted ? "Muted" : (systemInfo.volumeLevel + "%"); color: Colours.m3onSurfaceVariant; font.family: "Cascadia Code"; font.pixelSize: 10 }
                                }

                                Rectangle {
                                    id: volBar
                                    Layout.fillWidth: true
                                    height: 12; radius: 6
                                    color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.12)
                                    clip: true

                                    Rectangle {
                                        x: 1; y: 1
                                        width: Math.max(0, (parent.width - 2) * systemInfo.volumeLevel / 100)
                                        height: parent.height - 2; radius: 5
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0; color: systemInfo.volumeMuted ? Colours.m3outline : Colours.m3primary }
                                            GradientStop { position: 1; color: systemInfo.volumeMuted ? Colours.m3outline : Qt.lighter(Colours.m3primary, 1.15) }
                                        }
                                        Behavior on width { NumberAnimation { duration: 90 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: mouse => systemInfo.setVolume(Math.max(0, Math.min(100, Math.round(mouse.x / parent.width * 100))))
                                        onPositionChanged: mouse => { if (pressed) systemInfo.setVolume(Math.max(0, Math.min(100, Math.round(mouse.x / parent.width * 100)))); }
                                    }
                                }
                            }

                            // Brightness Row
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    BloomIcon { text: "brightness_6"; color: Colours.m3secondary; font.pixelSize: 14 }
                                    Text { text: "Brightness"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 10; font.weight: Font.Medium }
                                    Item { Layout.fillWidth: true }
                                    Text { text: systemInfo.brightnessLevel + "%"; color: Colours.m3onSurfaceVariant; font.family: "Cascadia Code"; font.pixelSize: 10 }
                                }

                                Rectangle {
                                    id: briBar
                                    Layout.fillWidth: true
                                    height: 12; radius: 6
                                    color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                                    border.width: 1; border.color: Qt.alpha(Colours.m3outlineVariant, 0.12)
                                    clip: true

                                    Rectangle {
                                        x: 1; y: 1
                                        width: Math.max(0, (parent.width - 2) * systemInfo.brightnessLevel / 100)
                                        height: parent.height - 2; radius: 5
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0; color: Colours.m3secondary }
                                            GradientStop { position: 1; color: Qt.lighter(Colours.m3secondary, 1.15) }
                                        }
                                        Behavior on width { NumberAnimation { duration: 90 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: mouse => systemInfo.setBrightness(Math.max(0, Math.min(100, Math.round(mouse.x / parent.width * 100))))
                                        onPositionChanged: mouse => { if (pressed) systemInfo.setBrightness(Math.max(0, Math.min(100, Math.round(mouse.x / parent.width * 100)))); }
                                    }
                                }
                            }
                        }
                    }

                    // Network & Connectivity Card
                    Tile {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    width: 26; height: 26; radius: 13
                                    color: Qt.alpha(Colours.m3success, 0.15)
                                    BloomIcon { anchors.centerIn: parent; text: "lan"; color: Colours.m3success; font.pixelSize: 14 }
                                }
                                Text { text: "Network"; color: Colours.m3onSurface; font.family: "Rubik"; font.pixelSize: 13; font.weight: Font.DemiBold }
                                Item { Layout.fillWidth: true }

                                // Living pulse online indicator
                                Row {
                                    spacing: 5
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: Colours.m3success
                                        anchors.verticalCenter: parent.verticalCenter
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.35; duration: 1200; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                                        }
                                    }
                                    Text { text: "Online"; color: Colours.m3success; font.family: "Rubik"; font.pixelSize: 10; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }

                            Text {
                                text: "Ethernet LAN Interface"
                                color: Colours.m3onSurface
                                font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.Medium
                            }

                            Text {
                                text: "Host: " + systemInfo.hostName
                                color: Colours.m3onSurfaceVariant
                                font.family: "Cascadia Code"; font.pixelSize: 11
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }

                            // Status badge with soft glow
                            Rectangle {
                                Layout.fillWidth: true
                                height: 22; radius: 11
                                color: Qt.alpha(Colours.m3success, 0.08)
                                border.width: 1; border.color: Qt.alpha(Colours.m3success, 0.2)

                                Row {
                                    anchors.centerIn: parent; spacing: 5
                                    BloomIcon { text: "check_circle"; color: Colours.m3success; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text: "Optimal throughput · Active link"
                                        color: Qt.alpha(Colours.m3success, 0.85)
                                        font.family: "Rubik"; font.pixelSize: 10; font.weight: Font.Medium
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ------------------------------------------------ Weather view (Zenith of Caelestia aesthetics)
        Item {
            visible: opacity > 0.01
            opacity: root.activeTab === 3 ? 1 : 0
            Behavior on opacity { BloomAnim { type: BloomAnim.FastEffects } }
            enabled: root.activeTab === 3
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Header: City + Date + Twilight stats + Refresh
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Text {
                            text: weatherService.city === "" ? "Tokyo, Japan" : weatherService.city
                            color: Colours.m3onSurface
                            font.family: "Rubik"; font.pixelSize: 20; font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "· " + Qt.formatDate(new Date(), "dddd, MMMM d")
                            color: Colours.m3onSurfaceVariant
                            font.family: "Rubik"; font.pixelSize: 12
                            anchors.baseline: parent.children[0].baseline
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Twilight metrics & reload
                    RowLayout {
                        spacing: 14
                        Layout.alignment: Qt.AlignVCenter

                        Row {
                            spacing: 4
                            BloomIcon { text: "wb_twilight"; color: Colours.m3tertiary; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Sunrise 05:38"; color: Colours.m3tertiary; font.family: "Cascadia Code"; font.pixelSize: 11; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                        }

                        Row {
                            spacing: 4
                            BloomIcon { text: "bedtime"; color: Colours.m3tertiary; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Sunset 17:42"; color: Colours.m3tertiary; font.family: "Cascadia Code"; font.pixelSize: 11; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: rHov.hovered ? Qt.alpha(Colours.m3primary, 0.22) : Qt.alpha(Colours.m3surfaceContainerHigh, 0.6)
                            border.width: 1
                            border.color: rHov.hovered ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.25)
                            scale: rHov.hovered ? 1.08 : 1.0
                            Behavior on scale { NumberAnimation { duration: 120 } }
                            Behavior on color { ColorAnimation { duration: 140 } }

                            HoverHandler { id: rHov; cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    weatherService.reload()
                                    reloadAnim.restart()
                                }
                            }

                            BloomIcon {
                                id: rIco
                                anchors.centerIn: parent
                                text: "refresh"
                                font.pixelSize: 15
                                color: Colours.m3primary

                                NumberAnimation on rotation {
                                    id: reloadAnim
                                    from: 0; to: 360
                                    duration: 650
                                    easing.type: Easing.OutCubic
                                    running: false
                                }
                            }
                        }
                    }
                }

                // Hero Weather Tile with Living Breath Pulsation
                Tile {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 96

                    // Ambient Breathing Halo behind Hero Tile
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.95
                        height: parent.height * 0.90
                        radius: 20
                        color: Qt.alpha(Colours.m3primary, 0.08)
                        z: -1
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.24; duration: 2400; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 0.06; duration: 2400; easing.type: Easing.InOutSine }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 20

                        // Squircle Vector Weather Icon with Living Breath Float
                        Rectangle {
                            Layout.preferredWidth: 72
                            Layout.preferredHeight: 72
                            radius: 20
                            color: Qt.alpha(Colours.m3secondaryContainer, 0.45)
                            border.width: 1; border.color: Qt.alpha(Colours.m3secondary, 0.3)
                            Layout.alignment: Qt.AlignVCenter

                            BloomIcon {
                                anchors.centerIn: parent
                                text: root.glyphToIcon(weatherService.condition, weatherService.condition)
                                font.pixelSize: 40
                                color: Colours.m3secondary

                                SequentialAnimation on y {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: -3; duration: 2200; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 3; duration: 2200; easing.type: Easing.InOutSine }
                                }
                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.05; duration: 2200; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.95; duration: 2200; easing.type: Easing.InOutSine }
                                }
                            }
                        }

                        // Temperature & Condition Badge
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            Row {
                                spacing: 4
                                Text {
                                    text: (weatherService.temperature + "").replace(/[^0-9\-]/g, "")
                                    color: Colours.m3primary
                                    font.family: "Rubik"
                                    font.pixelSize: 44
                                    font.weight: Font.Bold
                                    anchors.baseline: tempDeg.baseline
                                }
                                Text {
                                    id: tempDeg
                                    text: "°C"
                                    color: Colours.m3primary
                                    font.family: "Rubik"
                                    font.pixelSize: 22
                                    font.weight: Font.Medium
                                }
                            }

                            Rectangle {
                                height: 24; radius: 12
                                color: Qt.alpha(Colours.m3primaryContainer, 0.6)
                                border.width: 1; border.color: Qt.alpha(Colours.m3primary, 0.35)
                                implicitWidth: condRow.implicitWidth + 16

                                RowLayout {
                                    id: condRow
                                    anchors.centerIn: parent
                                    spacing: 5
                                    BloomIcon { text: "verified"; color: Colours.m3primary; font.pixelSize: 11 }
                                    Text {
                                        text: weatherService.condition === "" ? "Fair Weather" : weatherService.condition
                                        color: Colours.m3primary
                                        font.family: "Rubik"; font.pixelSize: 11; font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Quick Glance Metrics
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 6

                            RowLayout {
                                spacing: 6
                                BloomIcon { text: "thermostat"; color: Colours.m3primary; font.pixelSize: 14 }
                                Text {
                                    text: "Apparent Temp: " + weatherService.feelsLike
                                    color: Colours.m3onSurface
                                    font.family: "Cascadia Code"; font.pixelSize: 11; font.weight: Font.Medium
                                }
                            }

                            RowLayout {
                                spacing: 6
                                BloomIcon { text: "schedule"; color: Colours.m3secondary; font.pixelSize: 14 }
                                Text {
                                    text: "Updated: " + weatherService.updatedAt
                                    color: Colours.m3onSurfaceVariant
                                    font.family: "Cascadia Code"; font.pixelSize: 10
                                }
                            }
                        }
                    }
                }

                // 4 Metric Glass Tiles Row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    spacing: 10

                    component WeatherMetricTile: Tile {
                        id: wmt
                        property string label: ""
                        property string value: ""
                        property string icon: ""
                        property color accentColor: Colours.m3primary

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        scale: wmtHov.hovered ? 1.03 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: wmtHov }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 10

                            Rectangle {
                                width: 34; height: 34; radius: 17
                                color: Qt.alpha(wmt.accentColor, 0.18)
                                Layout.alignment: Qt.AlignVCenter

                                BloomIcon {
                                    anchors.centerIn: parent
                                    text: wmt.icon
                                    color: wmt.accentColor
                                    font.pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 1

                                Text {
                                    text: wmt.label
                                    color: Colours.m3onSurfaceVariant
                                    font.family: "Rubik"; font.pixelSize: 10
                                }
                                Text {
                                    text: wmt.value
                                    color: Colours.m3onSurface
                                    font.family: "Cascadia Code"; font.pixelSize: 13; font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    WeatherMetricTile { label: "Humidity"; value: weatherService.humidity; icon: "water_drop"; accentColor: Colours.m3secondary }
                    WeatherMetricTile { label: "Feels Like"; value: weatherService.feelsLike; icon: "thermostat"; accentColor: Colours.m3primary }
                    WeatherMetricTile { label: "Wind Speed"; value: weatherService.wind; icon: "air"; accentColor: Colours.m3tertiary }
                    WeatherMetricTile { label: "Pressure"; value: weatherService.pressure; icon: "speed"; accentColor: Colours.m3secondary }
                }

                // 7-Day Forecast Section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        BloomIcon { text: "calendar_month"; color: Colours.m3primary; font.pixelSize: 14 }
                        Text {
                            text: "7-Day Meteorological Forecast"
                            color: Colours.m3onSurface
                            font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        Repeater {
                            model: weatherService.forecast
                            delegate: Tile {
                                id: fcastTile
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 104

                                scale: fcastHov.hovered ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 140 } }
                                border.color: fcastHov.hovered ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.28)
                                HoverHandler { id: fcastHov; cursorShape: Qt.PointingHandCursor }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 3
                                    Layout.alignment: Qt.AlignHCenter

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: fcastTile.modelData.day
                                        color: fcastTile.index === 0 ? Colours.m3primary : Colours.m3onSurface
                                        font.family: "Rubik"; font.pixelSize: 12; font.weight: Font.Bold
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: fcastTile.modelData.date
                                        color: Colours.m3onSurfaceVariant
                                        font.family: "Rubik"; font.pixelSize: 9
                                    }

                                    BloomIcon {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: root.glyphToIcon(fcastTile.modelData.glyph, "")
                                        color: Colours.m3secondary
                                        font.pixelSize: 24
                                        scale: fcastHov.hovered ? 1.15 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 140 } }
                                    }

                                    Row {
                                        Layout.alignment: Qt.AlignHCenter
                                        spacing: 2
                                        Text {
                                            text: fcastTile.modelData.hi
                                            color: Colours.m3primary
                                            font.family: "Cascadia Code"; font.pixelSize: 11; font.weight: Font.Bold
                                        }
                                        Text {
                                            text: "/"
                                            color: Colours.m3onSurfaceVariant
                                            font.family: "Cascadia Code"; font.pixelSize: 10
                                        }
                                        Text {
                                            text: fcastTile.modelData.lo
                                            color: Colours.m3tertiary
                                            font.family: "Cascadia Code"; font.pixelSize: 11; font.weight: Font.Medium
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
