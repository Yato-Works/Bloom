import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property bool isCliMode: cmdInput.text.startsWith(">")
    readonly property int panelHeight: isCliMode ? 260 : 310

    height: panelHeight
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    opacity: open ? 1 : 0

    Behavior on height {
        NumberAnimation { duration: 220; easing.type: Easing.OutExpo }
    }

    transform: [
        Translate {
            y: root.open ? 0 : (root.panelHeight + 20)
            Behavior on y {
                NumberAnimation {
                    duration: Theme.durationDefault
                    easing.type: Easing.OutExpo
                }
            }
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.panelHeight
            xScale: root.open ? 1.0 : 0.97
            yScale: root.open ? 1.0 : 0.97
            Behavior on xScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
            Behavior on yScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
        }
    ]
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -20
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: {
            root.panelHovered = containsMouse
            if (containsMouse) shellController.notifyCursorEnter(ShellController.Bottom)
            else shellController.notifyCursorLeave(ShellController.Bottom)
        }
    }

    // Bottom-Attached Dock Sheet Container (Attached flush to screen bottom)
    GlassPanel {
        id: widgetContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        width: Math.min(parent.width * 0.92, 1060)
        implicitHeight: root.isCliMode ? 240 : 290
        radius: 28
        tint: Qt.rgba(0.07, 0.07, 0.10, 0.95)
        elevated: true

        Behavior on implicitHeight { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 14
            anchors.bottomMargin: 12
            spacing: 10

            // ── DUAL LAUNCHER CONTENT STACK ──
            StackLayout {
                currentIndex: root.isCliMode ? 0 : 1
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ── MODE A: CLI COMMAND & SYSTEM ACTIONS MODE (Typing >) ──
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property int cliSubTab: (cmdInput.text.startsWith(">wall") || cmdInput.text.startsWith(">wallpaper")) ? 1 : 0

                    // Top Sub-Header & Mode Switcher
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        RowLayout {
                            spacing: 6
                            Text {
                                text: "⚡ System CLI Commands"
                                color: Theme.primary
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }
                            Rectangle {
                                implicitWidth: 1
                                implicitHeight: 12
                                color: Qt.rgba(1, 1, 1, 0.15)
                            }
                            Text {
                                text: "Type any command or press Enter / Click to execute"
                                color: Qt.rgba(1, 1, 1, 0.45)
                                font.pixelSize: 11
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Quick Action Buttons (Smart Launcher & Calc)
                        RowLayout {
                            spacing: 6

                            Rectangle {
                                implicitWidth: 105
                                implicitHeight: 24
                                radius: 12
                                color: launcherBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(1, 1, 1, 0.06)
                                border.width: 1
                                border.color: launcherBtnMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.1)

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text { text: "🔍 Launcher"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                }

                                MouseArea {
                                    id: launcherBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: shell.openLauncher("")
                                }
                            }

                            Rectangle {
                                implicitWidth: 80
                                implicitHeight: 24
                                radius: 12
                                color: calcBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(1, 1, 1, 0.06)
                                border.width: 1
                                border.color: calcBtnMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.1)

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text { text: "🧮 Calc"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.DemiBold }
                                }

                                MouseArea {
                                    id: calcBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: shell.openCalculator()
                                }
                            }
                        }

                        // Sub Tab Selector: Commands List vs Wallpaper Carousel
                        RowLayout {
                            spacing: 4

                            Rectangle {
                                implicitWidth: 100
                                implicitHeight: 24
                                radius: 12
                                color: parent.parent.cliSubTab === 0 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25) : Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1
                                border.color: parent.parent.cliSubTab === 0 ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    anchors.centerIn: parent
                                    text: "⚡ Commands"
                                    color: parent.parent.parent.cliSubTab === 0 ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.cliSubTab = 0
                                }
                            }

                            Rectangle {
                                implicitWidth: 100
                                implicitHeight: 24
                                radius: 12
                                color: parent.parent.cliSubTab === 1 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25) : Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1
                                border.color: parent.parent.cliSubTab === 1 ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    anchors.centerIn: parent
                                    text: "🖼️ Wallpapers"
                                    color: parent.parent.parent.cliSubTab === 1 ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.cliSubTab = 1
                                }
                            }
                        }
                    }

                    // Stack View for CLI Commands List (Index 0) vs Wallpapers (Index 1)
                    StackLayout {
                        currentIndex: parent.cliSubTab
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // ── SUB-VIEW 0: SYSTEM COMMANDS LIST ──
                        ListView {
                            id: cliCmdListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 6
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            property var filteredCmds: appLauncherService.searchCliCommands(cmdInput.text)
                            model: filteredCmds

                            delegate: Rectangle {
                                id: cmdItem
                                width: cliCmdListView.width
                                implicitHeight: 44
                                radius: 12
                                color: cmdMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: cmdMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45) : Qt.rgba(1, 1, 1, 0.06)

                                Behavior on color { ColorAnimation { duration: 140 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 14
                                    spacing: 12

                                    Rectangle {
                                        implicitWidth: 30
                                        implicitHeight: 30
                                        radius: 8
                                        color: cmdMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)

                                        Behavior on color { ColorAnimation { duration: 140 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.icon ? modelData.icon : "⚡"
                                            font.pixelSize: 14
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        RowLayout {
                                            spacing: 6
                                            Text {
                                                text: modelData.name
                                                color: Theme.primary
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                            }
                                            Text {
                                                text: modelData.syntax ? modelData.syntax : ""
                                                color: Qt.rgba(1, 1, 1, 0.35)
                                                font.pixelSize: 10
                                            }
                                        }

                                        Text {
                                            text: modelData.desc ? modelData.desc : ""
                                            color: Qt.rgba(1, 1, 1, 0.55)
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Action Exec Hint Badge
                                    Rectangle {
                                        implicitWidth: cmdHintRow.implicitWidth + 14
                                        implicitHeight: 22
                                        radius: 11
                                        color: cmdMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35) : Qt.rgba(1, 1, 1, 0.06)
                                        border.width: 1
                                        border.color: cmdMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                                        RowLayout {
                                            id: cmdHintRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "↵"
                                                color: cmdMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.6)
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }
                                            Text {
                                                text: "Run Action"
                                                color: cmdMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.6)
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: cmdMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var cmdName = modelData.name
                                        if (cmdName === ">wallpaper") {
                                            cmdInput.text = ">wallpaper"
                                        } else if (cmdName === ">lock") {
                                            shellController.toggleLock()
                                        } else if (cmdName === ">theme") {
                                            appLauncherService.requestSettings()
                                        } else if (cmdName === ">settings") {
                                            appLauncherService.requestSettings()
                                        } else if (cmdName === ">folder") {
                                            wallpaperService.openFolder()
                                        } else if (cmdName === ">reload") {
                                            wallpaperService.refreshWallpapers()
                                        } else if (cmdName === ">snip") {
                                            appLauncherService.launchApp("snippingtool.exe")
                                            shellController.disarm()
                                        } else if (cmdName === ">calc") {
                                            shell.openCalculator()
                                        }
                                    }
                                }
                            }
                        }

                        // ── SUB-VIEW 1: WALLPAPER SELECTION CAROUSEL ──
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ListView {
                                id: carouselView
                                anchors.fill: parent
                                orientation: ListView.Horizontal
                                spacing: 16
                                boundsBehavior: Flickable.StopAtBounds
                                snapMode: ListView.SnapToItem
                                highlightRangeMode: ListView.ApplyRange
                                preferredHighlightBegin: (width - 230) / 2
                                preferredHighlightEnd: (width + 230) / 2
                                highlightMoveDuration: 280

                                currentIndex: wallpaperService.selectedIndex

                                onCurrentIndexChanged: {
                                    if (wallpaperService.selectedIndex !== currentIndex) {
                                        wallpaperService.selectedIndex = currentIndex
                                    }
                                }

                                model: wallpaperService.wallpapers

                                delegate: Item {
                                    id: cardItem
                                    readonly property bool isSelected: carouselView.currentIndex === index
                                    property bool isHovered: cardMouse.containsMouse

                                    width: isSelected ? 230 : 180
                                    height: carouselView.height
                                    scale: isSelected ? 1.04 : (isHovered ? 1.02 : 0.97)

                                    z: isSelected ? 10 : (isHovered ? 5 : 1)

                                    Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
                                    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutExpo } }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 4

                                        // 16:9 Widescreen Thumbnail Container
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: Math.round(cardItem.width / 1.777)
                                            radius: 12
                                            clip: true
                                            color: modelData.colorStart ? modelData.colorStart : "#1e2233"
                                            border.width: cardItem.isSelected ? 2.5 : (cardItem.isHovered ? 1.5 : 1)
                                            border.color: cardItem.isSelected ? Theme.primary : (cardItem.isHovered ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(1, 1, 1, 0.12))

                                            // Gradient Background Fallback
                                            Rectangle {
                                                anchors.fill: parent
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: modelData.colorStart ? modelData.colorStart : "#1e2233" }
                                                    GradientStop { position: 1.0; color: modelData.colorEnd ? modelData.colorEnd : "#0b0d14" }
                                                }
                                            }

                                            // 16:9 Real Image Thumbnail
                                            Image {
                                                anchors.fill: parent
                                                source: modelData.path ? modelData.path : ""
                                                fillMode: Image.PreserveAspectCrop
                                                visible: status === Image.Ready
                                                smooth: true
                                                asynchronous: true
                                            }

                                            // Preset Pattern Overlay
                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: 4
                                                opacity: cardItem.isSelected ? 0.95 : 0.55
                                                visible: !modelData.path

                                                MaterialIcon {
                                                    name: "sparkles"
                                                    iconSize: cardItem.isSelected ? 24 : 18
                                                    iconColor: "#ffffff"
                                                    Layout.alignment: Qt.AlignHCenter
                                                }

                                                Text {
                                                    text: modelData.name
                                                    color: "#ffffff"
                                                    font.pixelSize: cardItem.isSelected ? 11 : 9
                                                    font.weight: Font.DemiBold
                                                    Layout.alignment: Qt.AlignHCenter
                                                }
                                            }
                                        }

                                        // Caption Label Under Card
                                        Text {
                                            text: modelData.name
                                            color: cardItem.isSelected ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                                            font.pixelSize: cardItem.isSelected ? 11 : 10
                                            font.weight: cardItem.isSelected ? Font.Bold : Font.Normal
                                            horizontalAlignment: Text.AlignHCenter
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: cardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            carouselView.currentIndex = index
                                            wallpaperService.selectedIndex = index
                                        }
                                    }
                                }

                                // Mouse Wheel Support for smooth sliding
                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    onWheel: function(wheel) {
                                        if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                                            carouselView.incrementCurrentIndex()
                                        } else {
                                            carouselView.decrementCurrentIndex()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── MODE B: APPLICATION LAUNCHER GRID (Normal Typing) ──
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "🚀 Windows Applications"
                            color: Theme.primary
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Press Enter or Click to Launch"
                            color: Qt.rgba(1, 1, 1, 0.4)
                            font.pixelSize: 11
                        }
                    }

                    // Live Inline Math Calculator Result Card
                    Rectangle {
                        id: calcCard
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 12
                        color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.2)
                        border.width: 1.5
                        border.color: Theme.tertiary

                        property var mathResult: appLauncherService.evaluateMath(cmdInput.text)
                        visible: mathResult && mathResult.valid

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 14
                            spacing: 12

                            Rectangle {
                                implicitWidth: 32
                                implicitHeight: 32
                                radius: 10
                                color: Theme.tertiary

                                Text {
                                    anchors.centerIn: parent
                                    text: "🧮"
                                    font.pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: (calcCard.mathResult && calcCard.mathResult.formatted) ? calcCard.mathResult.formatted : ""
                                    color: "#ffffff"
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: "Expression: " + (calcCard.mathResult && calcCard.mathResult.expression ? calcCard.mathResult.expression : "")
                                    color: Qt.rgba(1, 1, 1, 0.65)
                                    font.pixelSize: 10
                                }
                            }

                            Rectangle {
                                implicitWidth: 80
                                implicitHeight: 24
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.1)

                                Text {
                                    anchors.centerIn: parent
                                    text: "↵ Calculate"
                                    color: Theme.tertiary
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }

                    ListView {
                        id: appListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        property var searchResults: appLauncherService.searchApps(cmdInput.text)
                        model: searchResults

                        delegate: Rectangle {
                            id: appItem
                            width: appListView.width
                            implicitHeight: 46
                            radius: 12
                            color: appMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: appMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45) : Qt.rgba(1, 1, 1, 0.06)

                            Behavior on color { ColorAnimation { duration: 140 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 14
                                spacing: 12

                                Rectangle {
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 10
                                    color: appMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)

                                    Behavior on color { ColorAnimation { duration: 140 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon ? modelData.icon : "🚀"
                                        font.pixelSize: 16
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.category + (modelData.description ? " · " + modelData.description : "")
                                        color: Qt.rgba(1, 1, 1, 0.45)
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    implicitWidth: launchHintRow.implicitWidth + 14
                                    implicitHeight: 24
                                    radius: 12
                                    color: appMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : Qt.rgba(1, 1, 1, 0.06)
                                    border.width: 1
                                    border.color: appMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                                    RowLayout {
                                        id: launchHintRow
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: "↵"
                                            color: appMouse.containsMouse ? Theme.primary : Qt.rgba(1, 1, 1, 0.6)
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }

                                        Text {
                                            text: "Launch"
                                            color: appMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.6)
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: appMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appLauncherService.launchApp(modelData.exec)
                                    shellController.disarm()
                                }
                            }
                        }
                    }
                }
            }

            // ── BOTTOM DUAL LAUNCHER SEARCH BAR ──
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 19
                color: Qt.rgba(0, 0, 0, 0.45)
                border.width: 1
                border.color: cmdInput.activeFocus ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5) : Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 10
                    spacing: 8

                    MaterialIcon {
                        name: root.isCliMode ? "⚡" : "🔍"
                        iconSize: 14
                        iconColor: root.isCliMode ? Theme.primary : Qt.rgba(1, 1, 1, 0.5)
                    }

                    Text {
                        text: root.isCliMode ? ">" : "App"
                        color: root.isCliMode ? Theme.primary : Qt.rgba(1, 1, 1, 0.85)
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    TextInput {
                        id: cmdInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#ffffff"
                        font.pixelSize: 12
                        clip: true
                        focus: root.open

                        Text {
                            text: " アプリ名を入力... (例: chrome, code, notepad) / '>' でコマンドモード"
                            color: Qt.rgba(1, 1, 1, 0.3)
                            font.pixelSize: 12
                            visible: !cmdInput.text && !cmdInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onAccepted: {
                            var t = cmdInput.text.trim()
                            var mathRes = appLauncherService.evaluateMath(t)
                            if (mathRes && mathRes.valid) {
                                cmdInput.text = mathRes.result
                                return
                            }

                            if (t.startsWith(">")) {
                                if (t.indexOf(">lock") === 0) {
                                    shellController.toggleLock()
                                } else if (t.indexOf(">theme") === 0 || t.indexOf(">settings") === 0) {
                                    appLauncherService.requestSettings()
                                } else if (t.indexOf(">wallpaper") === 0 || t.indexOf(">wall") === 0) {
                                    cmdInput.text = ">wallpaper"
                                } else if (t.indexOf(">folder") === 0) {
                                    wallpaperService.openFolder()
                                } else if (t.indexOf(">reload") === 0) {
                                    wallpaperService.refreshWallpapers()
                                } else if (t.indexOf(">snip") === 0 || t.indexOf(">screenshot") === 0) {
                                    appLauncherService.launchApp("snippingtool.exe")
                                    shellController.disarm()
                                } else if (t.indexOf(">calc") === 0) {
                                    appLauncherService.launchApp("calc.exe")
                                    shellController.disarm()
                                } else {
                                    var cmds = appLauncherService.searchCliCommands(t)
                                    if (cmds.length > 0) {
                                        var cName = cmds[0].name
                                        if (cName === ">wallpaper") cmdInput.text = ">wallpaper"
                                        else if (cName === ">lock") shellController.toggleLock()
                                        else if (cName === ">theme") appLauncherService.requestSettings()
                                        else if (cName === ">settings") appLauncherService.requestSettings()
                                        else if (cName === ">folder") wallpaperService.openFolder()
                                        else if (cName === ">reload") wallpaperService.refreshWallpapers()
                                        else if (cName === ">snip") { appLauncherService.launchApp("snippingtool.exe"); shellController.disarm() }
                                        else if (cName === ">calc") { appLauncherService.launchApp("calc.exe"); shellController.disarm() }
                                    }
                                }
                            } else if (t.length > 0) {
                                var apps = appLauncherService.searchApps(t)
                                if (apps.length > 0) {
                                    appLauncherService.launchApp(apps[0].exec)
                                    shellController.disarm()
                                }
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: clearMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                        visible: cmdInput.text.length > 0

                        MaterialIcon {
                            anchors.centerIn: parent
                            name: "close"
                            iconSize: 10
                            iconColor: Qt.rgba(1, 1, 1, 0.6)
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cmdInput.text = ""
                        }
                    }

                    Rectangle { implicitWidth: 1; implicitHeight: 14; color: Qt.rgba(1, 1, 1, 0.12) }

                    // Open Folder Button (📂 Open Folder)
                    Rectangle {
                        implicitWidth: openFolderRow.implicitWidth + 16
                        implicitHeight: 28
                        radius: 14
                        color: openFolderMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)

                        RowLayout {
                            id: openFolderRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "📂"; font.pixelSize: 11 }
                            Text { text: "Wallpapers"; color: "#ffffff"; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }

                        MouseArea {
                            id: openFolderMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cmdInput.text = ">wallpaper"
                                wallpaperService.openFolder()
                            }
                        }
                    }

                    // Reload Button (🔄 Reload)
                    Rectangle {
                        implicitWidth: refreshRow.implicitWidth + 14
                        implicitHeight: 28
                        radius: 14
                        color: refreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.15)

                        RowLayout {
                            id: refreshRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🔄"; font.pixelSize: 10 }
                            Text { text: "Reload"; color: "#ffffff"; font.pixelSize: 11 }
                        }

                        MouseArea {
                            id: refreshMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wallpaperService.refreshWallpapers()
                        }
                    }
                }
            }
        }
    }
}
