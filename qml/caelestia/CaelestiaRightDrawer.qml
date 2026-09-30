import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

Item {
    id: root

    property bool open: false
    readonly property string fontDisplay: "Rubik"
    readonly property string fontMono: "Cascadia Code"

    signal requestOpenSettings()

    property bool keepAwakeEnabled: false
    property bool wifiEnabled: true
    property bool bluetoothEnabled: true
    property bool micMuted: false
    property bool nightLightEnabled: false

    width: root.open ? 410 : 54
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    // ── Floating Vertical Sliders (peek from right edge) ──
    Item {
        id: sliderWrapper
        anchors.right: root.open ? drawerPanel.left : parent.right
        anchors.rightMargin: root.open ? 12 : 8
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: sliderCol.implicitHeight
        visible: true
        z: 50

        opacity: root.open ? 1.0 : (sliderHoverDetector.containsMouse ? 1.0 : 0.45)
        scale: (sliderHoverDetector.containsMouse || root.open) ? 1.0 : 0.94
        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on scale { NumberAnimation { duration: 180 } }

        MouseArea {
            id: sliderHoverDetector
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        ColumnLayout {
            id: sliderCol
            anchors.fill: parent
            spacing: 14

            VerticalSlider {
                value: systemInfo.volumeLevel
                icon: systemInfo.volumeMuted ? "volume_off" : (systemInfo.volumeLevel > 50 ? "volume_up" : "volume_down")
                muted: systemInfo.volumeMuted
                activeColor: Colours.m3primary
                onValueModified: newVal => systemInfo.setVolume(newVal)
                onIconClicked: systemInfo.toggleMute()
            }

            VerticalSlider {
                value: systemInfo.brightnessLevel
                icon: "brightness_6"
                activeColor: Colours.m3secondary
                onValueModified: newVal => systemInfo.setBrightness(newVal)
            }
        }
    }

    // ── Main Drawer Panel ──
    Rectangle {
        id: drawerPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        width: 360
        radius: 26
        color: Qt.alpha(Colours.m3surfaceContainerLowest, 0.95)
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.28)

        // Specular refraction edge
        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 1; height: 1.5; radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.14); z: 5
        }

        // Panel elevation shadow
        MultiEffect {
            anchors.fill: drawerPanel
            source: drawerPanel
            shadowEnabled: true
            shadowBlur: 0.75
            shadowColor: Qt.rgba(0, 0, 0, 0.55)
            shadowHorizontalOffset: -8
            shadowVerticalOffset: 4
            z: -1
        }

        // Slide Animation
        transform: Translate {
            x: root.open ? 0 : drawerPanel.width + 10
            Behavior on x {
                BloomAnim { type: root.open ? BloomAnim.DefaultSpatial : BloomAnim.Emphasized }
            }
        }
        opacity: root.open ? 1 : 0
        Behavior on opacity {
            BloomAnim { type: root.open ? BloomAnim.DefaultEffects : BloomAnim.FastEffects }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ═══════════════════════ 1. NOTIFICATIONS PANEL ═══════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 22
                color: Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

                // Specular top highlight
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 1; height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.10)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 28; height: 28; radius: 14
                            color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                            BloomIcon {
                                anchors.centerIn: parent; text: "notifications"
                                color: Colours.m3primary; font.pixelSize: 14
                            }
                        }

                        Text {
                            text: qsTr("Notifications")
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay; font.pixelSize: 14; font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }

                        // Clear pill button
                        Rectangle {
                            height: 26; radius: 13
                            width: clearRow.implicitWidth + 14
                            color: clearHov.hovered ? Qt.alpha(Colours.m3primary, 0.18) : Qt.alpha(Colours.m3surfaceContainerHigh, 0.5)
                            border.width: 1
                            border.color: clearHov.hovered ? Qt.alpha(Colours.m3primary, 0.3) : Qt.alpha(Colours.m3outlineVariant, 0.2)
                            Behavior on color { ColorAnimation { duration: 150 } }
                            HoverHandler { id: clearHov; cursorShape: Qt.PointingHandCursor }

                            Row {
                                id: clearRow
                                anchors.centerIn: parent; spacing: 4
                                BloomIcon {
                                    text: "clear_all"; font.pixelSize: 12
                                    color: clearHov.hovered ? Colours.m3primary : Colours.m3onSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: qsTr("Clear")
                                    color: clearHov.hovered ? Colours.m3primary : Colours.m3onSurfaceVariant
                                    font.family: root.fontDisplay; font.pixelSize: 10; font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Empty State with Dino + breathing aura
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 76; height: 76

                            // Bloom breathing aura behind dino
                            Rectangle {
                                anchors.centerIn: parent
                                width: 88; height: 88; radius: 44
                                color: Qt.alpha(Colours.m3primary, 0.10)
                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.12; duration: 2800; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.92; duration: 2800; easing.type: Easing.InOutSine }
                                }
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.6; duration: 2800; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 0.2; duration: 2800; easing.type: Easing.InOutSine }
                                }
                            }

                            Image {
                                anchors.centerIn: parent
                                width: 64; height: 64
                                fillMode: Image.PreserveAspectFit
                                source: "qrc:/qt/qml/Bloom/assets/dino.png"
                                opacity: 0.8
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("No Notifications")
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay; font.pixelSize: 13; font.weight: Font.Medium
                            font.letterSpacing: 0.3
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Bloom is quietly watching over you")
                            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                            font.family: root.fontDisplay; font.pixelSize: 10
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ═══════════════════════ 2. KEEP AWAKE CARD ═══════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                radius: 20
                color: Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
                border.width: 1
                border.color: awakeHov.hovered
                    ? Qt.alpha(Colours.m3primary, 0.35)
                    : Qt.alpha(Colours.m3outlineVariant, 0.3)
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Specular highlight
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 1; height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                HoverHandler { id: awakeHov }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Rectangle {
                        width: 38; height: 38; radius: 19
                        color: root.keepAwakeEnabled ? Qt.alpha(Colours.m3primary, 0.20) : Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                        border.width: 1
                        border.color: root.keepAwakeEnabled ? Qt.alpha(Colours.m3primary, 0.3) : "transparent"
                        Behavior on color { ColorAnimation { duration: 180 } }

                        BloomIcon {
                            anchors.centerIn: parent; text: "local_cafe"; font.pixelSize: 19
                            color: root.keepAwakeEnabled ? Colours.m3primary : Colours.m3onSurfaceVariant
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: qsTr("Keep Awake")
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay; font.pixelSize: 13; font.weight: Font.DemiBold
                        }
                        Text {
                            text: root.keepAwakeEnabled ? qsTr("Preventing sleep mode") : qsTr("Normal power management")
                            color: Colours.m3onSurfaceVariant
                            font.family: root.fontDisplay; font.pixelSize: 10
                        }
                    }

                    // Premium Switch Pill
                    Rectangle {
                        width: 44; height: 24; radius: 12
                        color: root.keepAwakeEnabled ? Colours.m3primary : Qt.alpha(Colours.m3surfaceContainerHighest, 0.8)
                        border.width: 1
                        border.color: root.keepAwakeEnabled ? Qt.alpha(Colours.m3primary, 0.8) : Qt.alpha(Colours.m3outline, 0.3)
                        Behavior on color { ColorAnimation { duration: 180 } }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.keepAwakeEnabled ? parent.width - width - 3 : 3
                            width: 18; height: 18; radius: 9
                            color: root.keepAwakeEnabled ? Colours.m3onPrimary : Colours.m3outline
                            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 180 } }

                            // Specular dot on knob
                            Rectangle {
                                anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 2; width: 6; height: 2; radius: 1
                                color: Qt.rgba(1, 1, 1, 0.35)
                            }
                        }

                        TapHandler { onTapped: root.keepAwakeEnabled = !root.keepAwakeEnabled }
                    }
                }
            }

            // ═══════════════════════ 3. SCREEN RECORDER CARD ═══════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                radius: 20
                color: Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
                border.width: 1
                border.color: recHov.hovered
                    ? Qt.alpha(Colours.m3secondary, 0.35)
                    : Qt.alpha(Colours.m3outlineVariant, 0.3)
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Specular highlight
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 1; height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                HoverHandler { id: recHov }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: Qt.alpha(Colours.m3secondaryContainer, 0.6)
                            border.width: 1
                            border.color: Qt.alpha(Colours.m3secondary, 0.2)

                            BloomIcon {
                                anchors.centerIn: parent; text: "videocam"; font.pixelSize: 16
                                color: Colours.m3onSecondaryContainer
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: qsTr("Screen Recorder")
                                color: Colours.m3onSurface
                                font.family: root.fontDisplay; font.pixelSize: 12; font.weight: Font.DemiBold
                            }
                            Text {
                                text: qsTr("Recording standby")
                                color: Colours.m3onSurfaceVariant
                                font.family: root.fontDisplay; font.pixelSize: 10
                            }
                        }

                        // Fullscreen pill badge
                        Rectangle {
                            height: 26; radius: 13
                            color: fsHov.hovered ? Colours.m3secondaryContainer : Qt.alpha(Colours.m3secondaryContainer, 0.55)
                            border.width: 1
                            border.color: Qt.alpha(Colours.m3secondary, 0.25)
                            implicitWidth: recBtnRow.implicitWidth + 16
                            scale: fsHov.hovered ? 1.04 : 1.0
                            Behavior on scale { NumberAnimation { duration: 120 } }
                            HoverHandler { id: fsHov; cursorShape: Qt.PointingHandCursor }

                            Row {
                                id: recBtnRow
                                anchors.centerIn: parent; spacing: 4
                                BloomIcon {
                                    text: "fullscreen"; font.pixelSize: 12
                                    color: Colours.m3onSecondaryContainer
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Fullscreen"
                                    color: Colours.m3onSecondaryContainer
                                    font.family: root.fontDisplay; font.pixelSize: 10; font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: 6
                        BloomIcon { text: "folder"; font.pixelSize: 12; color: Qt.alpha(Colours.m3onSurfaceVariant, 0.6) }
                        Text {
                            text: qsTr("No recordings found in gallery")
                            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                            font.family: root.fontDisplay; font.pixelSize: 9
                        }
                    }
                }
            }

            // ═══════════════════════ 4. QUICK TOGGLES ═══════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                radius: 22
                color: Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)

                // Specular edge
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 1; height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 5

                    // Reusable toggle component
                    component QuickToggle: Rectangle {
                        id: qt
                        property bool active: false
                        property string icon: ""
                        property color activeColor: Colours.m3secondaryContainer
                        property color activeIconColor: Colours.m3onSecondaryContainer
                        property color inactiveColor: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                        property color inactiveIconColor: Colours.m3onSurfaceVariant

                        signal toggled()

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16
                        color: qt.active ? qt.activeColor : qt.inactiveColor
                        border.width: qt.active ? 1 : 0
                        border.color: Qt.alpha(qt.activeIconColor, 0.25)
                        Behavior on color { ColorAnimation { duration: 160 } }
                        scale: qtHov.hovered ? 1.08 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        HoverHandler { id: qtHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: qt.toggled() }

                        BloomIcon {
                            anchors.centerIn: parent
                            text: qt.icon
                            color: qt.active ? qt.activeIconColor : qt.inactiveIconColor
                            font.pixelSize: 18
                            Behavior on color { ColorAnimation { duration: 160 } }
                        }
                    }

                    QuickToggle {
                        active: root.wifiEnabled; icon: "wifi"
                        onToggled: root.wifiEnabled = !root.wifiEnabled
                    }
                    QuickToggle {
                        active: root.bluetoothEnabled; icon: "bluetooth"
                        onToggled: root.bluetoothEnabled = !root.bluetoothEnabled
                    }
                    QuickToggle {
                        active: !root.micMuted; icon: root.micMuted ? "mic_off" : "mic"
                        onToggled: root.micMuted = !root.micMuted
                    }
                    QuickToggle {
                        active: false; icon: "settings"
                        inactiveColor: Qt.alpha(Colours.m3surfaceContainerHighest, 0.7)
                        onToggled: root.requestOpenSettings()
                    }
                    QuickToggle {
                        active: root.nightLightEnabled; icon: "dark_mode"
                        activeColor: Qt.alpha(Colours.m3tertiaryContainer, 0.8)
                        activeIconColor: Colours.m3onTertiaryContainer
                        onToggled: root.nightLightEnabled = !root.nightLightEnabled
                    }
                    QuickToggle {
                        active: systemInfo.volumeMuted
                        icon: systemInfo.volumeMuted ? "volume_off" : "volume_up"
                        activeColor: Qt.alpha(Colours.m3error, 0.25)
                        activeIconColor: Colours.m3error
                        onToggled: systemInfo.toggleMute()
                    }
                }
            }
        }
    }
}
