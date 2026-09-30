import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    readonly property string fontDisplay: "Rubik"
    signal requestClose()

    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth() // 0-11
    property int currentDay: new Date().getDate()

    property string searchQuery: ""

    function getDaysInMonth(year: int, month: int): int {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfWeek(year: int, month: int): int {
        return new Date(year, month, 1).getDay(); // 0 is Sunday
    }

    function monthName(m: int): string {
        const names = [
            qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"),
            qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"),
            qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")
        ];
        return names[m] || "";
    }

    function weatherGlyph(name: string): string {
        const c = name.toLowerCase();
        if (c.includes("clear") || c.includes("sunny") || c.includes("晴")) return "☀️";
        if (c.includes("partly") || c.includes("時々")) return "⛅";
        if (c.includes("overcast") || c.includes("cloud") || c.includes("くもり")) return "☁️";
        if (c.includes("fog") || c.includes("mist")) return "🌫️";
        if (c.includes("drizzle")) return "🌦️";
        if (c.includes("rain") || c.includes("雨")) return "🌧️";
        if (c.includes("snow") || c.includes("雪")) return "❄️";
        if (c.includes("thunder")) return "⛈️";
        return "🌤️";
    }

    implicitWidth: 880
    implicitHeight: 560

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        // Top Grid of Cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            // Left column (Weather + DateTime + Calendar)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 14

                // Top sub-row (Weather + User Card)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    // 1. Small Weather Card
                    Rectangle {
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 120
                        radius: 26
                        color: Colours.m3surfaceContainerLow
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            Text {
                                text: root.weatherGlyph(weatherService.condition)
                                font.pixelSize: 46
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    text: weatherService.temperature === "" ? "23°C" : weatherService.temperature
                                    color: Colours.m3onSurface
                                    font.family: root.fontDisplay
                                    font.pixelSize: 30
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: weatherService.condition === "" ? "Partly cloudy" : weatherService.condition
                                    color: Colours.m3onSurfaceVariant
                                    font.family: root.fontDisplay
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: weatherService.city === "" ? "Tokyo" : weatherService.city
                                    color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                                    font.family: root.fontDisplay
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    // 2. User & System Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        radius: 26
                        color: Colours.m3surfaceContainerLow
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            // User Avatar
                            Rectangle {
                                width: 56
                                height: 56
                                radius: 18
                                color: Qt.alpha(Colours.m3primaryContainer, 0.8)
                                border.width: 1
                                border.color: Qt.alpha(Colours.m3primary, 0.4)
                                clip: true

                                Text {
                                    anchors.centerIn: parent
                                    text: "👤"
                                    font.pixelSize: 28
                                }
                            }

                            ColumnLayout {
                                spacing: 4
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter

                                RowLayout {
                                    spacing: 6
                                    Text {
                                        text: "✦"
                                        color: Colours.m3primary
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: "Windows 11  ·  " + systemInfo.hostName
                                        color: Colours.m3onSurface
                                        font.family: root.fontDisplay
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Text {
                                        text: "❐"
                                        color: Colours.m3secondary
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: "Bloom Desktop Shell"
                                        color: Colours.m3onSurfaceVariant
                                        font.family: root.fontDisplay
                                        font.pixelSize: 12
                                    }
                                }

                                RowLayout {
                                    spacing: 6
                                    Text {
                                        text: "⏱"
                                        color: Colours.m3tertiary
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        text: "up " + (systemInfo.uptime === "" ? "1 hour" : systemInfo.uptime)
                                        color: Qt.alpha(Colours.m3onSurfaceVariant, 0.8)
                                        font.family: root.fontDisplay
                                        font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }

                // Bottom sub-row (DateTime + Calendar & 3-bar resources)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    // 3. DateTime Card
                    Rectangle {
                        Layout.preferredWidth: 96
                        Layout.preferredHeight: 160
                        radius: 24
                        color: Colours.m3surfaceContainerLow
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 1

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    const d = new Date();
                                    const h = d.getHours() % 12 || 12;
                                    return String(h).padStart(2, "0");
                                }
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay
                                font.pixelSize: 26
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "•••"
                                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.40)
                                font.pixelSize: 12
                                font.letterSpacing: 2
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: {
                                    const m = new Date().getMinutes();
                                    return String(m).padStart(2, "0");
                                }
                                color: Qt.alpha(Colours.m3onSurface, 0.82)
                                font.family: root.fontDisplay
                                font.pixelSize: 26
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 2
                                text: new Date().getHours() >= 12 ? "PM" : "AM"
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // 4. Calendar & Resource Spectrum Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        radius: 24
                        color: Colours.m3surfaceContainerLow
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 14

                            // Calendar part
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4

                                // Month Header
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: root.monthName(root.currentMonth) + " " + root.currentYear
                                        color: Colours.m3primary
                                        font.family: root.fontDisplay
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                    Item { Layout.fillWidth: true }
                                }

                                // Day of week headers
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Repeater {
                                        model: ["S", "M", "T", "W", "T", "F", "S"]
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData
                                            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                                            font.family: root.fontDisplay
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                // Mini grid of days
                                GridLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    columns: 7
                                    rowSpacing: 2
                                    columnSpacing: 0

                                    Repeater {
                                        model: 35
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            readonly property int firstDay: root.getFirstDayOfWeek(root.currentYear, root.currentMonth)
                                            readonly property int daysInMonth: root.getDaysInMonth(root.currentYear, root.currentMonth)
                                            readonly property int dayNum: index - firstDay + 1
                                            readonly property bool isCurrentMonth: dayNum >= 1 && dayNum <= daysInMonth
                                            readonly property bool isToday: isCurrentMonth && dayNum === root.currentDay

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 18
                                                height: 18
                                                radius: 9
                                                color: isToday ? Colours.m3primary : "transparent"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: isCurrentMonth ? String(dayNum) : ""
                                                    color: isToday ? Colours.m3onPrimary
                                                        : (isCurrentMonth ? Colours.m3onSurface : "transparent")
                                                    font.family: root.fontDisplay
                                                    font.pixelSize: 10
                                                    font.weight: isToday ? Font.Bold : Font.Normal
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Divider
                            Rectangle {
                                width: 1
                                Layout.fillHeight: true
                                color: Qt.alpha(Colours.m3outlineVariant, 0.35)
                            }

                            // 3 Vertical Resource Bars (CPU, RAM, Disk)
                            RowLayout {
                                spacing: 10
                                Layout.fillHeight: true
                                Layout.rightMargin: 4

                                // CPU Bar
                                ColumnLayout {
                                    spacing: 4
                                    Layout.fillHeight: true
                                    Rectangle {
                                        Layout.preferredWidth: 10
                                        Layout.fillHeight: true
                                        radius: 5
                                        color: Colours.m3surfaceContainerHighest
                                        clip: true

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: parent.height * Math.min(1.0, systemInfo.cpuUsage / 100.0)
                                            radius: 5
                                            color: Colours.m3primary
                                            Behavior on height { NumberAnimation { duration: 300 } }
                                        }
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "⚙"
                                        font.pixelSize: 10
                                        color: Colours.m3onSurfaceVariant
                                    }
                                }

                                // RAM Bar
                                ColumnLayout {
                                    spacing: 4
                                    Layout.fillHeight: true
                                    Rectangle {
                                        Layout.preferredWidth: 10
                                        Layout.fillHeight: true
                                        radius: 5
                                        color: Colours.m3surfaceContainerHighest
                                        clip: true

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: parent.height * Math.min(1.0, systemInfo.memoryUsage / 100.0)
                                            radius: 5
                                            color: Colours.m3tertiary
                                            Behavior on height { NumberAnimation { duration: 300 } }
                                        }
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "▦"
                                        font.pixelSize: 10
                                        color: Colours.m3onSurfaceVariant
                                    }
                                }

                                // Battery / Disk Bar
                                ColumnLayout {
                                    spacing: 4
                                    Layout.fillHeight: true
                                    Rectangle {
                                        Layout.preferredWidth: 10
                                        Layout.fillHeight: true
                                        radius: 5
                                        color: Colours.m3surfaceContainerHighest
                                        clip: true

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: parent.height * Math.min(1.0, (systemInfo.hasBattery ? systemInfo.batteryPercent : 45) / 100.0)
                                            radius: 5
                                            color: Colours.m3secondary
                                            Behavior on height { NumberAnimation { duration: 300 } }
                                        }
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: systemInfo.hasBattery ? "⚡" : "💾"
                                        font.pixelSize: 10
                                        color: Colours.m3onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Right column: Media Card with Circular Progress & Bongo Cat!
            Rectangle {
                Layout.preferredWidth: 260
                Layout.preferredHeight: 294
                radius: 28
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    // Circular Cover Art & Progress Ring
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        width: 104
                        height: 104

                        CircularProgress {
                            anchors.fill: parent
                            strokeWidth: 4
                            fgColour: Colours.m3primary
                            bgColour: Colours.m3surfaceContainerHighest
                            value: musicControl.progress
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 86
                            height: 86
                            radius: 43
                            color: Qt.alpha(Colours.m3primaryContainer, 0.6)
                            border.width: 1
                            border.color: Qt.alpha(Colours.m3primary, 0.3)
                            clip: true

                            Text {
                                anchors.centerIn: parent
                                text: "🎵"
                                font.pixelSize: 34
                            }
                        }
                    }

                    // Track title & Artist
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            Layout.fillWidth: true
                            text: musicControl.trackTitle === "" ? qsTr("Nothing playing") : musicControl.trackTitle
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: musicControl.artistName === "" ? qsTr("Idle") : musicControl.artistName
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }

                    // Playback Controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: prevHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                            HoverHandler { id: prevHover }
                            TapHandler { onTapped: musicControl.previous() }
                            Text { anchors.centerIn: parent; text: "⏮"; color: Colours.m3onSurface; font.pixelSize: 13 }
                        }

                        Rectangle {
                            width: 40; height: 40; radius: 20
                            color: Colours.m3primary
                            HoverHandler { id: playHover }
                            scale: playHover.hovered ? 1.06 : 1.0
                            Behavior on scale { NumberAnimation { duration: 120 } }
                            TapHandler { onTapped: musicControl.playPause() }
                            Text {
                                anchors.centerIn: parent
                                text: musicControl.isPlaying ? "⏸" : "▶"
                                color: Colours.m3onPrimary
                                font.pixelSize: 15
                            }
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: nextHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.15) : "transparent"
                            HoverHandler { id: nextHover }
                            TapHandler { onTapped: musicControl.next() }
                            Text { anchors.centerIn: parent; text: "⏭"; color: Colours.m3onSurface; font.pixelSize: 13 }
                        }
                    }

                    // Bongo Cat Animated GIF
                    AnimatedImage {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 38
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/qt/qml/Bloom/assets/bongocat.gif"
                        playing: musicControl.isPlaying
                        paused: !musicControl.isPlaying
                    }
                }
            }
        }

        // Bottom Area: App Launcher & Search Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 26
            color: Colours.m3surfaceContainerLow
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // Search Bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 21
                    color: Colours.m3surfaceContainerHighest
                    border.width: 1
                    border.color: searchInput.activeFocus ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.4)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 8

                        Text {
                            text: "🔍"
                            font.pixelSize: 14
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            text: root.searchQuery
                            onTextChanged: root.searchQuery = text
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 13
                            clip: true

                            Text {
                                text: qsTr("Type \">\" for commands or search applications...")
                                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.5)
                                font.family: root.fontDisplay
                                font.pixelSize: 13
                                visible: searchInput.text === ""
                            }
                        }

                        Text {
                            text: "✕"
                            color: Colours.m3onSurfaceVariant
                            font.pixelSize: 12
                            visible: searchInput.text !== ""
                            TapHandler {
                                onTapped: {
                                    searchInput.text = "";
                                    root.searchQuery = "";
                                }
                            }
                        }
                    }
                }

                // App Grid / List
                ListView {
                    id: appList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.searchQuery === "" ? appLauncherService.apps : appLauncherService.searchApps(root.searchQuery)

                    delegate: Rectangle {
                        id: appItem
                        required property var modelData
                        required property int index

                        width: appList.width
                        height: 46
                        radius: 14
                        color: itemHover.hovered ? Colours.m3surfaceContainerHighest : "transparent"

                        HoverHandler { id: itemHover }
                        TapHandler {
                            onTapped: {
                                if (modelData && modelData.exec) {
                                    appLauncherService.launchApp(modelData.exec);
                                    root.requestClose();
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Text {
                                text: (modelData && modelData.icon) ? modelData.icon : "🚀"
                                font.pixelSize: 22
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: (modelData && modelData.name) ? modelData.name : ""
                                    color: Colours.m3onSurface
                                    font.family: root.fontDisplay
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: (modelData && modelData.description) ? modelData.description : ""
                                    color: Colours.m3onSurfaceVariant
                                    font.family: root.fontDisplay
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: (modelData && modelData.category) ? modelData.category : ""
                                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                                font.family: root.fontDisplay
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
