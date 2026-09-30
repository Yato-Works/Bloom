import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Bloom

Item {
    id: root

    readonly property string fontDisplay: "Rubik"
    readonly property string fontMono: "Cascadia Code"

    // Reactive binding to CavaService spectrum bars
    readonly property var cavaBars: (cavaService && cavaService.bars) ? cavaService.bars : []
    readonly property int cavaBarsCount: cavaBars ? cavaBars.length : 0

    // Organic pulse for lively movement when playing
    property real animTick: 0
    NumberAnimation on animTick {
        from: 0; to: Math.PI * 2
        duration: 1600
        loops: Animation.Infinite
        running: musicControl.isPlaying
    }

    function getBarLevel(index: int, totalBars: int, tick: real): real {
        if (cavaBarsCount > 0) {
            const srcIdx = Math.floor(index * cavaBarsCount / Math.max(1, totalBars));
            const val = Number(cavaBars[Math.min(cavaBarsCount - 1, Math.max(0, srcIdx))]);
            if (!isNaN(val) && val > 0.008) {
                return Math.min(1.0, val);
            }
        }
        // Energetic organic equalizer animation whenever media is playing
        if (musicControl.isPlaying) {
            const p1 = tick * 2.5 + index * 0.35;
            const p2 = tick * 4.2 + index * 0.65;
            const p3 = tick * 1.6 - index * 0.22;
            const w1 = Math.abs(Math.sin(p1));
            const w2 = Math.abs(Math.cos(p2));
            const w3 = Math.abs(Math.sin(p3));
            const mixed = 0.16 + 0.36 * w1 + 0.26 * w2 + 0.16 * w3;
            const freqTaper = 1.0 - 0.22 * (index / Math.max(1, totalBars));
            return Math.max(0.08, Math.min(0.95, mixed * freqTaper));
        }
        return 0.0;
    }

    function fmtTime(sec: int): string {
        if (sec <= 0) return "0:00";
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return `${m}:${s.toString().padStart(2, "0")}`;
    }

    implicitWidth: 880
    implicitHeight: 380

    // ──────────────────────────── EMPTY STATE ────────────────────────────
    Item {
        anchors.fill: parent
        visible: musicControl.trackTitle === ""

        // Soft ambient gradient backdrop
        Rectangle {
            anchors.fill: parent
            radius: 24
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.alpha(Colours.m3primaryContainer, 0.15) }
                GradientStop { position: 0.5; color: Qt.alpha(Colours.m3secondaryContainer, 0.08) }
                GradientStop { position: 1.0; color: Qt.alpha(Colours.m3tertiaryContainer, 0.12) }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            // Bloom-breathing icon badge
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 100; height: 100

                // Living breath outer aura
                Rectangle {
                    anchors.centerIn: parent
                    width: 120; height: 120; radius: 60
                    color: Qt.alpha(Colours.m3primary, 0.18)
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.18; duration: 2600; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.88; duration: 2600; easing.type: Easing.InOutSine }
                    }
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.7; duration: 2600; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.25; duration: 2600; easing.type: Easing.InOutSine }
                    }
                }

                // Inner aura ring
                Rectangle {
                    anchors.centerIn: parent
                    width: 108; height: 108; radius: 54
                    color: "transparent"
                    border.width: 1.5
                    border.color: Qt.alpha(Colours.m3primary, 0.25)
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.1; duration: 3000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 0.95; duration: 3000; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: Colours.m3primaryContainer
                    border.width: 1
                    border.color: Qt.alpha(Colours.m3primary, 0.35)

                    // Specular highlight
                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        anchors.margins: 1; height: 1.5; radius: parent.radius
                        color: Qt.rgba(1, 1, 1, 0.22)
                    }

                    BloomIcon {
                        anchors.centerIn: parent
                        text: "queue_music"
                        color: Colours.m3onPrimaryContainer
                        font.pixelSize: 44
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Nothing Playing"
                    color: Colours.m3onSurface
                    font.family: root.fontDisplay
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.3
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Play audio on Spotify, YouTube, or Apple Music for it to blossom here"
                    color: Colours.m3onSurfaceVariant
                    font.family: root.fontDisplay
                    font.pixelSize: 12
                }
            }

            // Launch buttons row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 6
                spacing: 12

                Rectangle {
                    width: 140; height: 38; radius: 19
                    color: spotHover.hovered ? Colours.m3primary : Qt.alpha(Colours.m3surfaceContainerHigh, 0.7)
                    border.width: 1; border.color: spotHover.hovered ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.3)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    scale: spotHover.hovered ? 1.04 : 1.0
                    Behavior on scale { NumberAnimation { duration: 140 } }
                    HoverHandler { id: spotHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: Qt.openUrlExternally("spotify:") }

                    // Specular highlight
                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        anchors.margins: 1; height: 1; radius: parent.radius
                        color: Qt.rgba(1, 1, 1, spotHover.hovered ? 0.25 : 0.12)
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 7
                        BloomIcon {
                            text: "music_note"; font.pixelSize: 15
                            color: spotHover.hovered ? Colours.m3onPrimary : Colours.m3primary
                            Behavior on color { ColorAnimation { duration: 180 } }
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Open Spotify"
                            color: spotHover.hovered ? Colours.m3onPrimary : Colours.m3onSurface
                            Behavior on color { ColorAnimation { duration: 180 } }
                            font.family: root.fontDisplay; font.pixelSize: 12; font.weight: Font.Medium
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    // ──────────────────────────── ACTIVE PLAYBACK STATE ────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 16
        visible: musicControl.trackTitle !== ""

        // ═══════ LEFT PANEL: Radial Visualizer + Cover Art ═══════
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            radius: 24
            color: Qt.alpha(Colours.m3surfaceContainerLow, 0.65)
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)
            clip: true

            // Specular refraction edge
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                anchors.margins: 1; height: 1.5; radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.16); z: 5
            }

            // Ambient color wash from album
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.alpha(Colours.m3primary, musicControl.isPlaying ? 0.08 : 0.03) }
                    GradientStop { position: 1; color: "transparent" }
                }
                Behavior on color { ColorAnimation { duration: 400 } }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // ──── Radial CAVA Visualizer + Cover Art ────
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 160

                    // Outer breathing aura
                    Rectangle {
                        anchors.centerIn: parent
                        width: 172; height: 172; radius: 86
                        color: Qt.alpha(Colours.m3primary, 0.20)
                        opacity: musicControl.isPlaying ? 0.85 : 0.15
                        Behavior on opacity { NumberAnimation { duration: 350 } }
                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            running: musicControl.isPlaying
                            NumberAnimation { to: 1.12; duration: 1800; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 0.96; duration: 1800; easing.type: Easing.InOutSine }
                        }
                    }

                    // Radial CAVA bars around the cover art
                    Item {
                        id: radialCava
                        anchors.fill: parent

                        readonly property int barCount: 32
                        readonly property real cx: width / 2
                        readonly property real cy: height / 2
                        readonly property real innerRadius: 56
                        readonly property real maxBarLen: 22

                        Repeater {
                            model: radialCava.barCount
                            Rectangle {
                                id: cavaBar
                                required property int index
                                readonly property real angle: index * (2 * Math.PI / radialCava.barCount) - Math.PI / 2
                                readonly property real level: {
                                    const tick = root.animTick;
                                    return root.getBarLevel(index, radialCava.barCount, tick);
                                }
                                readonly property real barLen: Math.max(3.5, level * radialCava.maxBarLen)

                                x: radialCava.cx + radialCava.innerRadius * Math.cos(angle) - width / 2
                                y: radialCava.cy + radialCava.innerRadius * Math.sin(angle) - height / 2
                                width: 3.5
                                height: barLen
                                radius: 1.75
                                antialiasing: true
                                color: Qt.alpha(Colours.m3primary, 0.40 + level * 0.55)
                                rotation: (angle * 180 / Math.PI) + 90
                                transformOrigin: Item.Bottom

                                Behavior on height { NumberAnimation { duration: 60 } }
                            }
                        }
                    }

                    // Circular progress ring
                    CircularProgress {
                        anchors.centerIn: parent
                        width: 118; height: 118
                        strokeWidth: 4
                        fgColour: Colours.m3primary
                        bgColour: Qt.alpha(Colours.m3surfaceContainerHighest, 0.5)
                        value: musicControl.progress
                    }

                    // Cover art circle
                    Item {
                        anchors.centerIn: parent
                        width: 104; height: 104

                        // Fallback gradient
                        Rectangle {
                            anchors.fill: parent; radius: 52
                            visible: coverArt.status !== Image.Ready
                            gradient: Gradient {
                                GradientStop { position: 0; color: Colours.m3primaryContainer }
                                GradientStop { position: 1; color: Colours.m3tertiaryContainer }
                            }
                            border.width: 1
                            border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

                            Text {
                                anchors.centerIn: parent
                                text: "♫"; font.pixelSize: 40
                                color: Colours.m3onPrimaryContainer
                            }
                        }

                        Image {
                            id: coverArt
                            anchors.fill: parent
                            source: musicControl.thumbnailSource
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true; cache: false
                            visible: status === Image.Ready
                            layer.enabled: visible
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: coverMask
                            }
                        }

                        Item {
                            id: coverMask
                            anchors.fill: parent; visible: false; layer.enabled: true
                            Rectangle { anchors.fill: parent; radius: width / 2; color: "black" }
                        }
                    }
                }

                // ──── Track metadata ────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: musicControl.trackTitle || "No active media"
                        color: Colours.m3onSurface
                        font.family: root.fontDisplay; font.pixelSize: 15; font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: musicControl.artistName || "Unknown Artist"
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay; font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    Text {
                        visible: musicControl.sourceApp !== ""
                        Layout.fillWidth: true
                        text: "via " + musicControl.sourceApp
                        color: Colours.m3primary
                        font.family: root.fontDisplay; font.pixelSize: 11; font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item { Layout.fillHeight: true }

                // Bongo Cat
                AnimatedImage {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 40
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qt/qml/Bloom/assets/bongocat.gif"
                    playing: musicControl.isPlaying
                    paused: !musicControl.isPlaying
                }
            }
        }

        // ═══════ RIGHT PANEL: Controls + Visualizer + Volume ═══════
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 24
            color: Qt.alpha(Colours.m3surfaceContainerLow, 0.65)
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

            // Specular refraction edge
            Rectangle {
                anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                anchors.margins: 1; height: 1.5; radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.16)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // ──── Header Row ────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: Qt.alpha(Colours.m3primaryContainer, 0.55)
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3primary, 0.3)

                        // Lively animated equalizer bars when playing
                        Row {
                            anchors.centerIn: parent
                            spacing: 3
                            height: 16
                            visible: musicControl.isPlaying

                            Repeater {
                                model: 3
                                Rectangle {
                                    required property int index
                                    width: 3.5
                                    radius: 1.75
                                    color: Colours.m3primary
                                    anchors.bottom: parent.bottom
                                    height: {
                                        const p = (root.animTick * (1.3 + index * 0.5)) % (Math.PI * 2);
                                        return 4 + 10 * Math.abs(Math.sin(p));
                                    }
                                }
                            }
                        }

                        // Static icon when paused
                        BloomIcon {
                            anchors.centerIn: parent; text: "graphic_eq"
                            color: Colours.m3primary; font.pixelSize: 16
                            visible: !musicControl.isPlaying
                        }
                    }

                    Text {
                        text: "Now Playing"
                        color: Colours.m3primary
                        font.family: root.fontDisplay; font.pixelSize: 15; font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }

                    // Status pill badge
                    Rectangle {
                        height: 24; radius: 12
                        width: statusTxt.implicitWidth + 18
                        color: musicControl.isPlaying
                            ? Qt.alpha(Colours.m3primaryContainer, 0.5)
                            : Qt.alpha(Colours.m3surfaceContainerHighest, 0.6)
                        border.width: 1
                        border.color: musicControl.isPlaying
                            ? Qt.alpha(Colours.m3primary, 0.3)
                            : Qt.alpha(Colours.m3outlineVariant, 0.25)
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Row {
                            anchors.centerIn: parent; spacing: 4
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: musicControl.isPlaying ? Colours.m3primary : Colours.m3outline
                                anchors.verticalCenter: parent.verticalCenter
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: musicControl.isPlaying
                                    NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                                }
                            }
                            Text {
                                id: statusTxt
                                text: musicControl.isPlaying ? "Playing" : "Paused"
                                color: musicControl.isPlaying ? Colours.m3primary : Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay; font.pixelSize: 10; font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // ──── CAVA Linear Visualizer Bar ────
                Rectangle {
                    id: visualiser
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    radius: 16
                    color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.55)
                    border.width: 1
                    border.color: Qt.alpha(Colours.m3outlineVariant, 0.2)
                    clip: true

                    readonly property int barCount: 48
                    readonly property real inset: 10
                    readonly property real slotW: Math.max(2, (width - 2 * inset) / barCount)

                    function level(index: int): real {
                        return root.getBarLevel(index, visualiser.barCount);
                    }

                    // Ambient gradient wash
                    Rectangle {
                        anchors.fill: parent; radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Qt.alpha(Colours.m3primary, 0.06) }
                            GradientStop { position: 0.5; color: "transparent" }
                            GradientStop { position: 1; color: Qt.alpha(Colours.m3tertiary, 0.04) }
                        }
                    }

                    Repeater {
                        model: visualiser.barCount
                        Item {
                            id: vSlot
                            required property int index
                            readonly property real level: {
                                const tick = root.animTick;
                                return root.getBarLevel(index, visualiser.barCount, tick);
                            }

                            x: visualiser.inset + index * visualiser.slotW
                            y: visualiser.inset
                            width: visualiser.slotW - 2
                            height: visualiser.height - 2 * visualiser.inset

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(2, parent.width - 1)
                                height: Math.max(3.5, vSlot.level * vSlot.height)
                                radius: Math.min(3, width / 2)
                                antialiasing: true
                                color: Qt.alpha(Colours.m3primary, 0.40 + vSlot.level * 0.55)
                                Behavior on height { NumberAnimation { duration: 60 } }

                                // Glow tip on active bars
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width + 2; height: 3; radius: 1.5
                                    color: Qt.alpha(Colours.m3primary, vSlot.level * 0.7)
                                    visible: vSlot.level > 0.15
                                }
                            }
                        }
                    }
                }

                // ──── Seekable Progress Bar ────
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Rectangle {
                        id: progTrack
                        Layout.fillWidth: true
                        height: 8; radius: 4
                        color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.15)
                        clip: true

                        Rectangle {
                            width: Math.max(0, parent.width * musicControl.progress)
                            height: parent.height; radius: 4
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: Colours.m3primary }
                                GradientStop { position: 1; color: Qt.lighter(Colours.m3primary, 1.15) }
                            }
                            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                            // Glowing seek head
                            Rectangle {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                width: 12; height: 12; radius: 6
                                color: Colours.m3primary
                                visible: musicControl.progress > 0.01

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 4; height: 4; radius: 2
                                    color: Colours.m3onPrimary
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.fmtTime(musicControl.position)
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontMono; font.pixelSize: 11
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.fmtTime(musicControl.length)
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontMono; font.pixelSize: 11
                        }
                    }
                }

                // ──── Main Playback Controls ────
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    // Shuffle
                    Rectangle {
                        width: 42; height: 42; radius: 21
                        color: musicControl.shuffle ? Qt.alpha(Colours.m3primary, 0.22) : (shufHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.1) : "transparent")
                        border.width: musicControl.shuffle ? 1 : 0
                        border.color: Qt.alpha(Colours.m3primary, 0.3)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: shufHover.hovered ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: shufHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: musicControl.shuffle = !musicControl.shuffle }
                        BloomIcon {
                            anchors.centerIn: parent; text: "shuffle"
                            color: musicControl.shuffle ? Colours.m3primary : Colours.m3onSurfaceVariant
                            font.pixelSize: 19
                        }
                    }

                    // Previous
                    Rectangle {
                        width: 46; height: 46; radius: 23
                        color: prevBtnHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.12) : "transparent"
                        scale: prevBtnHover.hovered ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: prevBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: musicControl.previous() }
                        BloomIcon {
                            anchors.centerIn: parent; text: "skip_previous"
                            color: Colours.m3onSurface; font.pixelSize: 24
                        }
                    }

                    // Play/Pause Hero Pill
                    Rectangle {
                        Layout.preferredWidth: 88
                        Layout.preferredHeight: 46
                        radius: 23
                        color: Colours.m3primary
                        HoverHandler { id: playBtnHover; cursorShape: Qt.PointingHandCursor }
                        scale: playBtnHover.hovered ? 1.06 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        TapHandler { onTapped: musicControl.togglePlayPause() }

                        // Specular top highlight
                        Rectangle {
                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                            anchors.margins: 1; height: 1.5; radius: parent.radius
                            color: Qt.rgba(1, 1, 1, 0.28)
                        }

                        BloomIcon {
                            anchors.centerIn: parent
                            text: musicControl.isPlaying ? "pause" : "play_arrow"
                            color: Colours.m3onPrimary; font.pixelSize: 26
                        }
                    }

                    // Next
                    Rectangle {
                        width: 46; height: 46; radius: 23
                        color: nextBtnHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.12) : "transparent"
                        scale: nextBtnHover.hovered ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: nextBtnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: musicControl.next() }
                        BloomIcon {
                            anchors.centerIn: parent; text: "skip_next"
                            color: Colours.m3onSurface; font.pixelSize: 24
                        }
                    }

                    // Repeat
                    Rectangle {
                        width: 42; height: 42; radius: 21
                        color: musicControl.loopState > 0 ? Qt.alpha(Colours.m3primary, 0.22) : (repHover.hovered ? Qt.alpha(Colours.m3onSurfaceVariant, 0.1) : "transparent")
                        border.width: musicControl.loopState > 0 ? 1 : 0
                        border.color: Qt.alpha(Colours.m3primary, 0.3)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: repHover.hovered ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        HoverHandler { id: repHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: musicControl.loopState = (musicControl.loopState + 1) % 3 }
                        BloomIcon {
                            anchors.centerIn: parent
                            text: musicControl.loopState === 1 ? "repeat_one" : "repeat"
                            color: musicControl.loopState > 0 ? Colours.m3primary : Colours.m3onSurfaceVariant
                            font.pixelSize: 19
                        }
                    }
                }

                // ──── Volume Slider ────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: volIconHov.hovered ? Qt.alpha(Colours.m3primary, 0.15) : "transparent"
                        HoverHandler { id: volIconHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: systemInfo.toggleMute() }
                        BloomIcon {
                            anchors.centerIn: parent
                            text: systemInfo.volumeMuted ? "volume_off" : (systemInfo.volumeLevel > 50 ? "volume_up" : "volume_down")
                            color: systemInfo.volumeMuted ? Colours.m3outline : Colours.m3primary
                            font.pixelSize: 18
                        }
                    }

                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        height: 16; radius: 8
                        color: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                        border.width: 1
                        border.color: Qt.alpha(Colours.m3outlineVariant, 0.15)

                        Rectangle {
                            x: 2; y: 2
                            width: Math.max(0, (parent.width - 4) * systemInfo.volumeLevel / 100)
                            height: parent.height - 4; radius: 6
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: systemInfo.volumeMuted ? Colours.m3outline : Colours.m3primary }
                                GradientStop { position: 1; color: systemInfo.volumeMuted ? Colours.m3outline : Qt.lighter(Colours.m3primary, 1.1) }
                            }
                            Behavior on width { NumberAnimation { duration: 90 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => systemInfo.setVolume(Math.max(0, Math.min(100, mouse.x / parent.width * 100)))
                            onPositionChanged: mouse => {
                                if (pressed)
                                    systemInfo.setVolume(Math.max(0, Math.min(100, mouse.x / parent.width * 100)));
                            }
                        }
                    }

                    Text {
                        text: systemInfo.volumeLevel + "%"
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontMono; font.pixelSize: 11; font.weight: Font.Medium
                        Layout.preferredWidth: 32
                    }
                }
            }
        }
    }
}
