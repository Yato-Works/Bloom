pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root

    property bool open: false
    readonly property string fontDisplay: "Rubik, 'Segoe UI Variable Display', 'Segoe UI', sans-serif"

    signal closed()
    signal wallpaperRequested()
    signal themeRequested()
    signal calculatorRequested()

    // Schemes data matching sample15.png
    readonly property var schemeData: [
        { name: "catppuccin", flavour: "mocha",     surface: "#1e1e2e", primary: "#cba6f7", bg: "#181825" },
        { name: "catppuccin", flavour: "macchiato", surface: "#24273a", primary: "#f5bde6", bg: "#1e2030" },
        { name: "catppuccin", flavour: "frappe",    surface: "#303446", primary: "#ca9ee6", bg: "#292c3c" },
        { name: "catppuccin", flavour: "latte",     surface: "#eff1f5", primary: "#8839ef", bg: "#e6e9ef" },
        { name: "darkgreen",  flavour: "hard",      surface: "#111a14", primary: "#a6e3a1", bg: "#0b120d" },
        { name: "darkgreen",  flavour: "medium",    surface: "#18261e", primary: "#94e2d5", bg: "#101b15" },
        { name: "dracula",    flavour: "medium",    surface: "#282a36", primary: "#bd93f9", bg: "#1e1f29" },
        { name: "nord",       flavour: "frost",     surface: "#2e3440", primary: "#88c0d0", bg: "#242933" },
        { name: "tokyonight", flavour: "night",     surface: "#1a1b26", primary: "#7aa2f7", bg: "#16161e" }
    ]

    // Actions data matching sample13.png + Bloom Memo
    readonly property var actionsData: [
        { name: "Calculator", desc: "Do simple maths equations (powered by Qalc)", icon: "calculate", action: "autocomplete", arg: "calc " },
        { name: "Scheme",     desc: "Change the current colour scheme",           icon: "palette", action: "autocomplete", arg: "scheme " },
        { name: "Wallpaper",  desc: "Change the current wallpaper",               icon: "wallpaper", action: "autocomplete", arg: "wallpaper " },
        { name: "Memo",       desc: "Quickly take or review desk notes",          icon: "edit_note", action: "autocomplete", arg: "memo " },
        { name: "Variant",    desc: "Change the current scheme variant",          icon: "brush", action: "autocomplete", arg: "variant " },
        { name: "Random",     desc: "Switch to a random wallpaper",               icon: "shuffle", action: "random" },
        { name: "Light",      desc: "Change the scheme to light mode",            icon: "light_mode", action: "setMode", arg: "light" },
        { name: "Dark",       desc: "Change the scheme to dark mode",             icon: "dark_mode", action: "setMode", arg: "dark" }
    ]

    property int selectedIndex: 0
    property var memoNotes: [
        { text: "Welcome to Bloom! 🌸 Press > for actions", time: "Just now" }
    ]

    // View mode determination
    readonly property string searchText: searchInput.text.trim()
    readonly property bool isWallpaperMode: searchText.toLowerCase().startsWith(">wallpaper")
                                            || searchText.toLowerCase() === "wallpaper"
                                            || searchText.toLowerCase().startsWith("wallpaper ")
    readonly property bool isSchemeMode: searchText.toLowerCase().startsWith(">scheme")
                                         || searchText.toLowerCase() === "scheme"
                                         || searchText.toLowerCase().startsWith("scheme ")
    readonly property bool isMemoMode: searchText.toLowerCase().startsWith(">memo")
                                       || searchText.toLowerCase() === "memo"
                                       || searchText.toLowerCase().startsWith("memo ")
    readonly property bool isCalcMode: searchText.toLowerCase().startsWith(">calc")
                                       || searchText.toLowerCase().startsWith("calc ")
                                       || (mathResult && mathResult.valid)
    readonly property bool isActionMode: (searchText.startsWith(">") && !isWallpaperMode && !isSchemeMode && !isMemoMode)
                                         || searchText.toLowerCase() === "action"
                                         || searchText.toLowerCase() === "actions"
    property var mathResult: ({ valid: false })

    function showLauncher(initialQuery) {
        root.open = true
        shellController.armPermanent(true)
        if (initialQuery !== undefined) {
            searchInput.text = initialQuery
        }
        searchInput.forceActiveFocus()
        root.selectedIndex = 0
        if (typeof wallpaperService !== "undefined" && wallpaperService && wallpaperService.wallpapers.length === 0) {
            wallpaperService.refreshWallpapers()
        }
    }

    function hideLauncher() {
        root.open = false
        shellController.armPermanent(false)
        searchInput.text = ""
        root.closed()
    }

    function toggleLauncher() {
        if (root.open) hideLauncher()
        else showLauncher()
    }

    // Modal click-off scrim
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        acceptedButtons: Qt.AllButtons
        onClicked: root.hideLauncher()
    }

    // -----------------------------------------------------------------
    // Launcher Window Card (Centered near bottom above taskbar/cava)
    // -----------------------------------------------------------------
    Item {
        id: panelContainer
        width: isWallpaperMode ? Math.min(parent.width - 48, 860) : Math.min(parent.width - 48, 620)
        height: cardSurface.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24

        // Bloom Petal Spring Dynamics: transforms from center-bottom like a blossoming flower
        transformOrigin: Item.Bottom
        scale: root.open ? 1.0 : 0.88
        opacity: root.open ? 1.0 : 0.0

        Behavior on width {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: root.open ? 0 : 36
            Behavior on y {
                NumberAnimation {
                    duration: root.open ? 220 : 160
                    easing.type: root.open ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.10
                }
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: root.open ? 220 : 160
                easing.type: root.open ? Easing.OutBack : Easing.InQuad
                easing.overshoot: 1.10
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? 180 : 140
                easing.type: Easing.OutCubic
            }
        }

        // Bloom Ambient Glow: soft atmospheric backlight radiating the active theme color
        Rectangle {
            id: ambientGlow
            anchors.fill: cardSurface
            anchors.margins: -8
            radius: cardSurface.radius + 8
            color: "transparent"
            border.width: 3.5
            border.color: Qt.alpha(Colours.m3primary, 0.28)
            opacity: root.open ? 1.0 : 0.0
            scale: root.open ? 1.0 : 0.94
            transformOrigin: Item.Bottom
            z: -2

            Behavior on border.color {
                ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 220 }
            }
        }

        // Static shadow background item (avoids re-blurring live text & input on every frame)
        Rectangle {
            id: shadowBase
            anchors.fill: cardSurface
            radius: cardSurface.radius
            color: Qt.rgba(0, 0, 0, 0.40)
            visible: false
            z: -1
        }

        // Deep drop shadow behind panel (rendered from static shadowBase)
        MultiEffect {
            anchors.fill: shadowBase
            source: shadowBase
            shadowEnabled: true
            shadowBlur: 0.45
            shadowColor: Qt.rgba(0, 0, 0, 0.60)
            shadowVerticalOffset: 8
            z: -1
        }

        // Glass surface (Frosted Obsidian & Mica Hybrid)
        Rectangle {
            id: cardSurface
            width: parent.width
            implicitHeight: contentColumn.implicitHeight + 24
            radius: 26
            color: Qt.alpha(Colours.m3surfaceContainer, 0.88)
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.40)

            Behavior on color {
                ColorAnimation { duration: 320; easing.type: Easing.OutCubic }
            }
            Behavior on border.color {
                ColorAnimation { duration: 320; easing.type: Easing.OutCubic }
            }

            // 1px Specular Optical Reflection Border (Mica Glass effect)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: 1.2
                radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.22)
                z: 2
            }

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 10

                // =============================================================
                // 1. Wallpaper List (sample14.png) - Horizontal Carousel
                // =============================================================
                Item {
                    id: wallpaperSection
                    Layout.fillWidth: true
                    height: 180
                    visible: root.isWallpaperMode

                    readonly property var wallList: (typeof wallpaperService !== "undefined" && wallpaperService)
                                                    ? wallpaperService.wallpapers : []

                    PathView {
                        id: wallpaperPathView
                        anchors.fill: parent
                        clip: true
                        model: wallpaperSection.wallList

                        pathItemCount: 5
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightRangeMode: PathView.StrictlyEnforceRange
                        snapMode: PathView.SnapToItem

                        delegate: Item {
                            id: wallItem
                            width: 220
                            height: 170

                            required property var modelData
                            required property int index

                            scale: PathView.isCurrentItem ? 1.0 : 0.82
                            opacity: PathView.isCurrentItem ? 1.0 : 0.70
                            z: PathView.isCurrentItem ? 10 : 1

                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                            Behavior on opacity { NumberAnimation { duration: 180 } }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Rectangle {
                                    id: imgRect
                                    width: 200
                                    height: 112
                                    radius: 14
                                    color: Colours.m3surfaceContainerHighest
                                    border.width: PathView.isCurrentItem ? 2 : 1
                                    border.color: PathView.isCurrentItem ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.3)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: modelData.path || ("file:///" + modelData.localPath)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        sourceSize.width: 240
                                        sourceSize.height: 135
                                    }

                                    // Checkmark badge if currently active wallpaper
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 6
                                        width: 22
                                        height: 22
                                        radius: 11
                                        color: Colours.m3primary
                                        visible: {
                                            if (typeof wallpaperService === "undefined" || !wallpaperService) return false
                                            var cur = wallpaperService.currentWallpaperPath()
                                            return cur && cur.length > 0 && (modelData.localPath === cur || modelData.path === cur)
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            color: Colours.m3onPrimary
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Text {
                                    Layout.maximumWidth: 190
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.name || modelData.fileName || "Wallpaper"
                                    color: PathView.isCurrentItem ? Colours.m3onSurface : Colours.m3onSurfaceVariant
                                    font.family: root.fontDisplay
                                    font.pixelSize: 11
                                    font.weight: PathView.isCurrentItem ? Font.Bold : Font.Normal
                                    elide: Text.ElideMiddle
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wallpaperPathView.currentIndex = index
                                    if (typeof wallpaperService !== "undefined" && wallpaperService) {
                                        wallpaperService.setWallpaper(modelData.localPath || modelData.path)
                                        if (typeof Colours !== "undefined" && Colours.applyWallpaperPalette) {
                                            Colours.applyWallpaperPalette(modelData.localPath || modelData.path)
                                        }
                                    }
                                }
                                onDoubleClicked: {
                                    root.hideLauncher()
                                }
                            }
                        }

                        path: Path {
                            startX: 0
                            startY: wallpaperPathView.height / 2
                            PathLine { x: wallpaperPathView.width; y: wallpaperPathView.height / 2 }
                        }

                        Keys.onLeftPressed: wallpaperPathView.decrementCurrentIndex()
                        Keys.onRightPressed: wallpaperPathView.incrementCurrentIndex()
                    }
                }

                // =============================================================
                // 2. Scheme List (sample15.png) - Split-tone swatch list
                // =============================================================
                Item {
                    id: schemeSection
                    Layout.fillWidth: true
                    height: Math.min(320, schemeList.count * 48)
                    visible: root.isSchemeMode

                    ListView {
                        id: schemeList
                        anchors.fill: parent
                        clip: true
                        spacing: 4

                        model: {
                            var raw = root.searchText
                            if (raw.startsWith(">")) raw = raw.slice(1)
                            if (raw.toLowerCase().startsWith("scheme")) raw = raw.slice(6)
                            var q = raw.trim().toLowerCase()
                            if (q.length === 0) return root.schemeData
                            return root.schemeData.filter(s => s.name.includes(q) || s.flavour.includes(q))
                        }

                        delegate: Rectangle {
                            id: schemeRow
                            width: schemeList.width
                            height: 44
                            radius: 12

                            required property var modelData
                            required property int index
                            color: index === root.selectedIndex ? Qt.alpha(Colours.m3primary, 0.18)
                                 : (rowMouse.containsMouse ? Qt.alpha(Colours.m3surfaceContainerHigh, 0.7) : "transparent")
                            border.width: 1
                            border.color: index === root.selectedIndex ? Colours.m3primary : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 14
                                spacing: 14

                                // Two-tone circular preview swatch (sample15.png exact design)
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: modelData.surface
                                    border.width: 1
                                    border.color: Qt.alpha(modelData.primary, 0.5)
                                    clip: true

                                    // Right half primary color
                                    Item {
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        width: 14
                                        clip: true

                                        Rectangle {
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            anchors.right: parent.right
                                            width: 28
                                            radius: 14
                                            color: modelData.primary
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.flavour
                                        color: Colours.m3onSurface
                                        font.family: root.fontDisplay
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                    Text {
                                        text: modelData.name
                                        color: Colours.m3onSurfaceVariant
                                        font.family: root.fontDisplay
                                        font.pixelSize: 10
                                    }
                                }

                                // Checkmark if active scheme
                                Text {
                                    text: "✓"
                                    color: Colours.m3primary
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    visible: (typeof Colours !== "undefined")
                                             && Colours.currentScheme === modelData.name
                                             && Colours.currentFlavour === modelData.flavour
                                }
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedIndex = index
                                    applyScheme(modelData)
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // 3. Actions List (sample13.png) - Command Suggestions
                // =============================================================
                Item {
                    id: actionSection
                    Layout.fillWidth: true
                    height: Math.min(320, actionList.count * 48)
                    visible: root.isActionMode

                    ListView {
                        id: actionList
                        anchors.fill: parent
                        clip: true
                        spacing: 4

                        model: {
                            var raw = root.searchText
                            if (raw.startsWith(">")) raw = raw.slice(1)
                            if (raw.toLowerCase().startsWith("action")) raw = raw.slice(6)
                            var q = raw.trim().toLowerCase()
                            if (q.length === 0) return root.actionsData
                            return root.actionsData.filter(a => a.name.toLowerCase().includes(q) || a.desc.toLowerCase().includes(q))
                        }

                        delegate: Rectangle {
                            id: actionRow
                            width: actionList.width
                            height: 44
                            radius: 12

                            required property var modelData
                            required property int index
                            color: index === root.selectedIndex ? Qt.alpha(Colours.m3primary, 0.18)
                                 : (actMouse.containsMouse ? Qt.alpha(Colours.m3surfaceContainerHigh, 0.7) : "transparent")
                            border.width: 1
                            border.color: index === root.selectedIndex ? Colours.m3primary : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 14
                                spacing: 14

                                BloomIcon {
                                    text: modelData.icon
                                    color: Colours.m3primary
                                    font.pixelSize: 20
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1

                                    Text {
                                        text: modelData.name
                                        color: Colours.m3onSurface
                                        font.family: root.fontDisplay
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: modelData.desc
                                        color: Colours.m3onSurfaceVariant
                                        font.family: root.fontDisplay
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: "↵ Run"
                                    color: Colours.m3primary
                                    font.family: root.fontDisplay
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    visible: index === root.selectedIndex
                                }
                            }

                            MouseArea {
                                id: actMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedIndex = index
                                    runAction(modelData)
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // 3.5. Quick Desk Memo Section (>memo ...)
                // =============================================================
                Item {
                    id: memoSection
                    Layout.fillWidth: true
                    height: Math.min(260, Math.max(120, memoList.count * 52 + 50))
                    visible: root.isMemoMode

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "📝 Bloom Desk Memos"
                                color: Colours.m3primary
                                font.family: root.fontDisplay
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Type memo & press Enter to save"
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay
                                font.pixelSize: 11
                            }
                        }

                        ListView {
                            id: memoList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 6
                            model: root.memoNotes

                            delegate: Rectangle {
                                width: memoList.width
                                height: 46
                                radius: 12
                                required property var modelData
                                required property int index
                                color: Qt.alpha(Colours.m3surfaceContainerHigh, 0.65)
                                border.width: 1
                                border.color: Qt.alpha(Colours.m3outlineVariant, 0.25)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        text: "📌"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.text
                                        color: Colours.m3onSurface
                                        font.family: root.fontDisplay
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.time
                                        color: Colours.m3onSurfaceVariant
                                        font.family: root.fontDisplay
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // 4. Default App Grid (sample4.png)
                // =============================================================
                Item {
                    id: defaultAppSection
                    Layout.fillWidth: true
                    height: 170
                    visible: !root.isWallpaperMode && !root.isSchemeMode && !root.isActionMode && !root.isMemoMode

                    GridLayout {
                        anchors.fill: parent
                        columns: 5
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: {
                                if (typeof appLauncherService === "undefined" || !appLauncherService) return []
                                var q = root.searchText
                                var apps = appLauncherService.searchApps(q)
                                return apps.slice(0, 10)
                            }

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 74
                                radius: 16

                                required property var modelData
                                required property int index

                                scale: appMouse.containsMouse ? 1.05 : 1.0
                                Behavior on scale {
                                    NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
                                }

                                color: appMouse.containsMouse ? Qt.alpha(Colours.m3surfaceContainerHigh, 0.9) : "transparent"
                                border.width: 1
                                border.color: appMouse.containsMouse ? Qt.alpha(Colours.m3primary, 0.5) : Qt.rgba(1, 1, 1, 0.05)

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Rectangle {
                                        Layout.alignment: Qt.AlignHCenter
                                        width: 36
                                        height: 36
                                        radius: 10
                                        color: modelData.iconBg || Qt.alpha(Colours.m3primary, 0.18)

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.icon || "🚀"
                                            font.pixelSize: 18
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.maximumWidth: parent.width - 6
                                        text: modelData.name
                                        color: Colours.m3onSurface
                                        font.family: root.fontDisplay
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (typeof appLauncherService !== "undefined" && appLauncherService) {
                                            appLauncherService.launchApp(modelData.exec)
                                        }
                                        root.hideLauncher()
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // 5. Search Bar (Bottom pill-bar matching sample13, 14, 15)
                // =============================================================
                Rectangle {
                    id: searchBar
                    Layout.fillWidth: true
                    height: 48
                    radius: 24
                    color: Colours.m3surfaceContainerLowest
                    border.width: 1.5
                    border.color: searchInput.activeFocus ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.3)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 14
                        spacing: 10

                        Text {
                            text: root.searchText.startsWith(">") ? "⚡" : "🔍"
                            font.pixelSize: 16
                            color: root.searchText.startsWith(">") ? Colours.m3primary : Colours.m3onSurfaceVariant
                        }

                        TextField {
                            id: searchInput
                            Layout.fillWidth: true
                            placeholderText: "Type \">\" for commands"
                            placeholderTextColor: Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 14
                            background: null
                            selectByMouse: true

                            onTextChanged: {
                                root.selectedIndex = 0
                                if (typeof appLauncherService !== "undefined" && appLauncherService) {
                                    root.mathResult = appLauncherService.evaluateMath(text)
                                }
                            }

                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Escape) {
                                    root.hideLauncher()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                    if (root.isWallpaperMode) {
                                        wallpaperPathView.incrementCurrentIndex()
                                    } else {
                                        var max = root.isSchemeMode ? schemeList.count - 1 : (root.isActionMode ? actionList.count - 1 : 0)
                                        if (root.selectedIndex < max) root.selectedIndex++
                                    }
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    if (root.isWallpaperMode) {
                                        wallpaperPathView.decrementCurrentIndex()
                                    } else {
                                        if (root.selectedIndex > 0) root.selectedIndex--
                                    }
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Left && root.isWallpaperMode) {
                                    wallpaperPathView.decrementCurrentIndex()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Right && root.isWallpaperMode) {
                                    wallpaperPathView.incrementCurrentIndex()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    executeCurrentSelection()
                                    event.accepted = true
                                }
                            }
                        }

                        // Clear button (✕)
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 11
                            color: clearMouse.containsMouse ? Qt.alpha(Colours.m3onSurfaceVariant, 0.2) : "transparent"
                            visible: searchInput.text.length > 0

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: Colours.m3onSurfaceVariant
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    searchInput.text = ""
                                    searchInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function executeCurrentSelection() {
        if (root.isWallpaperMode) {
            var item = wallpaperPathView.currentItem
            if (item && item.modelData) {
                var p = item.modelData.localPath || item.modelData.path
                if (typeof wallpaperService !== "undefined" && wallpaperService) {
                    wallpaperService.setWallpaper(p)
                    if (typeof Colours !== "undefined" && Colours.applyWallpaperPalette) {
                        Colours.applyWallpaperPalette(p)
                    }
                }
                root.hideLauncher()
            }
        } else if (root.isSchemeMode) {
            var schemes = schemeList.model
            if (schemes && root.selectedIndex >= 0 && root.selectedIndex < schemes.length) {
                applyScheme(schemes[root.selectedIndex])
                root.hideLauncher()
            }
        } else if (root.isMemoMode) {
            var rawQuery = searchInput.text.trim()
            var memoBody = rawQuery.length > 5 ? rawQuery.slice(5).trim() : ""
            if (memoBody.length > 0) {
                var now = new Date()
                var timeStr = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2)
                var newNotes = [{ text: memoBody, time: timeStr }].concat(root.memoNotes)
                root.memoNotes = newNotes
                searchInput.text = ""
                root.hideLauncher()
            }
        } else if (root.isActionMode) {
            var acts = actionList.model
            if (acts && root.selectedIndex >= 0 && root.selectedIndex < acts.length) {
                runAction(acts[root.selectedIndex])
            }
        } else {
            // Normal launch or math
            if (root.mathResult && root.mathResult.valid) {
                root.calculatorRequested()
                root.hideLauncher()
            } else {
                if (typeof appLauncherService !== "undefined" && appLauncherService) {
                    var apps = appLauncherService.searchApps(searchInput.text)
                    if (apps && apps.length > 0) {
                        appLauncherService.launchApp(apps[0].exec)
                        root.hideLauncher()
                    }
                }
            }
        }
    }

    function runAction(action) {
        if (action.action === "autocomplete") {
            searchInput.text = ">" + action.arg
            searchInput.cursorPosition = searchInput.text.length
            searchInput.forceActiveFocus()
        } else if (action.action === "random") {
            if (typeof wallpaperService !== "undefined" && wallpaperService) {
                wallpaperService.setRandomWallpaper()
                if (typeof Colours !== "undefined" && Colours.applyWallpaperPalette) {
                    Colours.applyWallpaperPalette(wallpaperService.currentWallpaperPath())
                }
            }
            root.hideLauncher()
        } else if (action.action === "setMode") {
            if (typeof Colours !== "undefined" && Colours.setMode) {
                Colours.setMode(action.arg)
            }
            root.hideLauncher()
        }
    }

    function applyScheme(scheme) {
        if (typeof Colours !== "undefined" && Colours.applyScheme) {
            Colours.applyScheme(scheme.name, scheme.flavour, scheme.primary, scheme.surface, scheme.bg)
        }
    }
}
