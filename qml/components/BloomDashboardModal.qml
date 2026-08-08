import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// ============================================================================
//  BloomDashboardModal — central tabbed dashboard (Bloom dashboard style)
//  Follows the existing modal pattern used by SmartLauncherModal / Calculator.
//  Tabs: System · Weather · Media · Wallpaper
// ============================================================================
Item {
    id: dashRoot
    visible: false
    anchors.fill: parent
    z: 1600

    signal closed()

    property int currentTab: 0

    // ---- lifecycle ----
    function open() {
        shellController.armPermanent(true)
        dashRoot.visible = true
    }

    function close() {
        shellController.armPermanent(false)
        dashRoot.visible = false
        dashRoot.closed()
    }

    // ---- dim backdrop (click to dismiss) ----
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.42)
        opacity: dashRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }
        MouseArea {
            anchors.fill: parent
            onClicked: dashRoot.close()
        }
    }

    // ---- main card ----
    GlassPanel {
        id: dashCard
        width: 860
        height: Math.min(560, parent.height - 80)
        radius: Theme.radiusXL
        anchors.centerIn: parent
        scale: dashRoot.visible ? 1.0 : 0.92
        opacity: dashRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 180 } }
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // ---- header ----
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                spacing: 10

                Text {
                    text: "✦"
                    color: Theme.accent
                    font.pixelSize: Theme.fontLG
                }
                Text {
                    text: "Dashboard"
                    color: Theme.text
                    font.pixelSize: Theme.fontLG
                    font.weight: Font.Bold
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: systemInfo.formattedDate + " · " + systemInfo.formattedTime
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontXS
                    verticalAlignment: Text.AlignVCenter
                }
                Rectangle {
                    width: 30; height: 30; radius: Theme.radiusSmall
                    color: Qt.rgba(1, 1, 1, 0.06)
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: Theme.textMuted
                        font.pixelSize: 13
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dashRoot.close()
                    }
                }
            }

            // ---- tab bar ----
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusSmall
                color: Qt.rgba(0, 0, 0, 0.22)

                RowLayout {
                    anchors.fill: parent
                    spacing: 4
                    DashTab { tindex: 0; label: "System"; icon: "⚙" }
                    DashTab { tindex: 1; label: "Weather"; icon: "☁" }
                    DashTab { tindex: 2; label: "Media"; icon: "♪" }
                    DashTab { tindex: 3; label: "Wallpaper"; icon: "🖼" }
                }
            }

            // ---- content pages ----
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // -------- System --------
                Rectangle {
                    anchors.fill: parent
                    visible: dashRoot.currentTab === 0
                    color: "transparent"

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 40

                        MetricRing {
                            Layout.alignment: Qt.AlignVCenter
                            label: "CPU"
                            value: systemInfo.cpuUsage
                            accent: Theme.primary
                        }
                        MetricRing {
                            Layout.alignment: Qt.AlignVCenter
                            label: "Memory"
                            value: systemInfo.ramUsage
                            accent: Theme.accent
                        }
                        MetricRing {
                            Layout.alignment: Qt.AlignVCenter
                            label: "Disk"
                            value: 0
                            accent: Theme.tertiary
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 10

                            SystemStatRow { label: "Uptime"; value: systemInfo.uptime }
                            SystemStatRow { label: "Host"; value: systemInfo.hostName }
                            SystemStatRow { label: "Memory"; value: systemInfo.memorySummary }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // -------- Weather --------
                Rectangle {
                    anchors.fill: parent
                    visible: dashRoot.currentTab === 1
                    color: "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 16

                        RowLayout {
                            spacing: 12
                            Text {
                                text: weatherSymbol(weatherService.condition)
                                color: "#ffd86c"
                                font.pixelSize: Theme.font3XL
                            }
                            Text {
                                text: weatherService.temperature
                                color: Theme.text
                                font.pixelSize: Theme.font3XL
                                font.weight: Font.Bold
                            }
                            Text {
                                text: weatherService.city
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontLG
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: weatherService.condition
                            color: Theme.onSurfaceMuted
                            font.pixelSize: Theme.fontMD
                        }

                        RowLayout {
                            spacing: 12
                            WeatherCard { label: "Wind"; value: weatherService.wind }
                            WeatherCard { label: "Humidity"; value: weatherService.humidity }
                            WeatherCard { label: "Pressure"; value: weatherService.pressure }
                        }
                    }
                }

                // -------- Media --------
                Rectangle {
                    anchors.fill: parent
                    visible: dashRoot.currentTab === 2
                    color: "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 24

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "♪"
                            color: Theme.accent
                            font.pixelSize: Theme.font3XL
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Media Player"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSM
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 16
                            MediaButton { icon: "⏮"; onClicked: musicControl.previous() }
                            MediaButton { icon: "⏯"; big: true; accentColor: true; onClicked: musicControl.togglePlayPause() }
                            MediaButton { icon: "⏭"; onClicked: musicControl.next() }
                        }
                    }
                }

                // -------- Wallpaper --------
                Rectangle {
                    anchors.fill: parent
                    visible: dashRoot.currentTab === 3
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Wallpaper Carousel"
                            color: Theme.text
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.Bold
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.fillHeight: true
                                radius: Theme.radiusSmall
                                color: Qt.rgba(1, 1, 1, 0.05)
                                Text { anchors.centerIn: parent; text: "‹"; color: Theme.text; font.pixelSize: 22 }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: wallpaperService.setSelectedIndex(Math.max(0, wallpaperService.selectedIndex - 1))
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                Repeater {
                                    model: wallpaperService.wallpapers
                                    WallpaperCard {
                                        width: 200; height: 132
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: (parent.width - width) / 2 + (index - wallpaperService.selectedIndex) * 220
                                        source: modelData.path
                                        active: index === wallpaperService.selectedIndex
                                        onActivated: wallpaperService.setSelectedIndex(index)
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.fillHeight: true
                                radius: Theme.radiusSmall
                                color: Qt.rgba(1, 1, 1, 0.05)
                                Text { anchors.centerIn: parent; text: "›"; color: Theme.text; font.pixelSize: 22 }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: wallpaperService.setSelectedIndex(Math.min(wallpaperService.wallpapers.length - 1, wallpaperService.selectedIndex + 1))
                                }
                            }
                        }
                    }
                }
            }

        }
    }

    // ---- helper components ----
    function weatherSymbol(cond) {
        var c = (cond || "").toLowerCase()
        if (c.indexOf("rain") !== -1 || c.indexOf("drizzle") !== -1) return "🌧"
        if (c.indexOf("snow") !== -1) return "❄"
        if (c.indexOf("thunder") !== -1 || c.indexOf("storm") !== -1) return "⛈"
        if (c.indexOf("cloud") !== -1 || c.indexOf("overcast") !== -1) return "☁"
        if (c.indexOf("fog") !== -1 || c.indexOf("mist") !== -1) return "🌫"
        if (c.indexOf("clear") !== -1 || c.indexOf("sunny") !== -1) return "☀"
        return "☁"
    }

    component DashTab: Rectangle {
        id: tab
        property string label: ""
        property string icon: ""
        property int tindex: 0

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 3
        radius: Theme.radiusXS
        color: dashRoot.currentTab === tindex ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22) : Qt.rgba(1, 1, 1, 0.02)
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }

        RowLayout {
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: tab.icon
                color: dashRoot.currentTab === tindex ? Theme.accent : Theme.textMuted
                font.pixelSize: 14
            }
            Text {
                text: tab.label
                color: dashRoot.currentTab === tindex ? Theme.text : Theme.textMuted
                font.pixelSize: 12
                font.weight: dashRoot.currentTab === tindex ? Font.DemiBold : Font.Normal
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: dashRoot.currentTab = tindex
        }
    }

    component SystemStatRow: RowLayout {
        id: statRow
        property string label: ""
        property string value: ""
        spacing: 12
        Text {
            text: statRow.label
            color: Theme.textMuted
            font.pixelSize: Theme.fontSM
            Layout.preferredWidth: 70
        }
        Text {
            text: statRow.value
            color: Theme.text
            font.pixelSize: Theme.fontSM
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component WeatherCard: Column {
        id: wc
        property string label: ""
        property string value: ""
        spacing: 4
        Rectangle {
            width: 120; height: 70
            radius: Theme.radiusMedium
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)
            Column {
                anchors.centerIn: parent
                spacing: 3
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: wc.value
                    color: Theme.text
                    font.pixelSize: Theme.fontMD
                    font.weight: Font.Bold
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: wc.label
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontXS
                }
            }
        }
    }

    component MediaButton: Rectangle {
        id: mb
        property string icon: ""
        property bool big: false
        property bool accentColor: false
        signal clicked()
        width: big ? 64 : 52
        height: big ? 64 : 52
        radius: big ? 32 : 26
        color: mb.accentColor ? Theme.accent : Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)
        Text {
            anchors.centerIn: parent
            text: mb.icon
            color: mb.accentColor ? Theme.surface : Theme.text
            font.pixelSize: 20
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: mb.clicked()
        }
    }

    component WallpaperCard: Rectangle {
        id: wpCard
        property string source: ""
        property bool active: false
        signal activated()
        radius: Theme.radiusMedium
        border.width: wpCard.active ? 2 : 1
        border.color: wpCard.active ? Theme.accent : Qt.rgba(1, 1, 1, 0.08)
        scale: wpCard.active ? 1.0 : 0.9
        opacity: wpCard.active ? 1.0 : 0.55
        Behavior on scale { NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.durationDefault } }
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
        Image {
            anchors.fill: parent
            source: wpCard.source
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
        }
        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusMedium
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.55) }
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wpCard.activated()
        }
    }
}
