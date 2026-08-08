import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property bool forceExpanded: false
    property int currentTab: 0

    readonly property bool isDashboardOpen: open || forceExpanded
    readonly property int compactBarHeight: 52
    readonly property int expandedPanelHeight: 310

    height: isDashboardOpen ? expandedPanelHeight : compactBarHeight
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    Behavior on height {
        NumberAnimation { duration: 280; easing.type: Easing.OutExpo }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -12
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: {
            root.panelHovered = containsMouse
            if (containsMouse) shellController.notifyCursorEnter(ShellController.Top)
            else shellController.notifyCursorLeave(ShellController.Top)
        }
    }

    // Main Floating Glass Bar Container
    GlassPanel {
        id: topGlass
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        width: Math.min(parent.width * 0.92, 1080)
        implicitHeight: root.isDashboardOpen ? 290 : 38
        radius: root.isDashboardOpen ? 26 : 19
        tint: Qt.rgba(0.07, 0.08, 0.12, 0.95)
        elevated: true

        Behavior on implicitHeight { NumberAnimation { duration: 280; easing.type: Easing.OutExpo } }
        Behavior on radius { NumberAnimation { duration: 280; easing.type: Easing.OutExpo } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.isDashboardOpen ? 16 : 4
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            // ── 1. COMPACT & EXPANDED HEADER BAR ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Left Island: Workspace Selector Pill
                Rectangle {
                    implicitWidth: wsRow.implicitWidth + 16
                    implicitHeight: 30
                    radius: 15
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "🌸 Bloom"
                            color: Theme.primary
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        Rectangle { implicitWidth: 1; implicitHeight: 12; color: Qt.rgba(1, 1, 1, 0.15) }

                        Repeater {
                            model: 9
                            Rectangle {
                                readonly property bool isActive: workspaceService.currentWorkspace === modelData
                                implicitWidth: isActive ? 18 : 8
                                implicitHeight: 8
                                radius: 4
                                color: isActive ? Theme.primary : Qt.rgba(1, 1, 1, 0.3)
                                Behavior on implicitWidth { NumberAnimation { duration: 180 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: workspaceController.switchTo(modelData)
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        hoverEnabled: true
                        onWheel: {
                            if (wheel.angleDelta.y > 0) workspaceController.switchPrevious();
                            else workspaceController.switchNext();
                        }
                    }
                }

                // Top Quick Action Launcher Pill Buttons
                RowLayout {
                    spacing: 6

                    Rectangle {
                        implicitWidth: 95
                        implicitHeight: 28
                        radius: 14
                        color: topLaunchMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: topLaunchMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🔍 Launcher"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.DemiBold }
                        }

                        MouseArea {
                            id: topLaunchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: shell.openLauncher("")
                        }
                    }

                    Rectangle {
                        implicitWidth: 76
                        implicitHeight: 28
                        radius: 14
                        color: topCalcMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: topCalcMouse.containsMouse ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "🧮 Calc"; color: "#ffffff"; font.pixelSize: 10; font.weight: Font.DemiBold }
                        }

                        MouseArea {
                            id: topCalcMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: shell.openCalculator()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Center Island: Dynamic Notch / Tab Selector Pill with Mini CAVA
                Rectangle {
                    implicitWidth: notchRow.implicitWidth + 24
                    implicitHeight: 32
                    radius: 16
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35)

                    RowLayout {
                        id: notchRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "🕐"
                            font.pixelSize: 12
                        }

                        Text {
                            text: systemInfo.formattedTime !== "" ? systemInfo.formattedTime : "17:38"
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        // Mini 6-Bar CAVA Visualizer in Notch (real CavaService data)
                        Row {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter
                            Repeater {
                                model: 6
                                Rectangle {
                                    width: 2.5
                                    height: {
                                        if (cavaService && cavaService.bars && cavaService.bars.length > index * 3) {
                                            return Math.max(3, cavaService.bars[index * 3] * 18)
                                        }
                                        return Math.max(3, 4)
                                    }
                                    radius: 1.2
                                    color: Qt.hsva(0.58 + (index * 0.04), 0.7, 0.95, 0.9)
                                    anchors.bottom: parent.bottom
                                    Behavior on height { NumberAnimation { duration: 70 } }
                                }
                            }
                        }

                        Text {
                            text: (musicControl && musicControl.trackTitle) ? musicControl.trackTitle : "Bloom Dynamic Island"
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.pixelSize: 11
                            elide: Text.ElideRight
                            Layout.maximumWidth: 160
                        }

                        Text {
                            text: root.isDashboardOpen ? "▲" : "▾"
                            color: Theme.primary
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.forceExpanded = !root.forceExpanded
                    }
                }

                Item { Layout.fillWidth: true }

                // Right Island: Quick Status Pills
                Rectangle {
                    implicitWidth: statusPillRow.implicitWidth + 16
                    implicitHeight: 30
                    radius: 15
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        id: statusPillRow
                        anchors.centerIn: parent
                        spacing: 8

                        Text { text: "📶"; font.pixelSize: 11 }
                        Text { text: systemInfo.volumeMuted ? "🔇" : "🔊"; font.pixelSize: 11 }
                        Text { text: systemInfo.volumeMuted ? "Muted" : (systemInfo.volumeLevel + "%"); color: Qt.rgba(1, 1, 1, 0.8); font.pixelSize: 11; font.weight: Font.DemiBold }
                        Text { text: "🔋 " + (systemInfo.hasBattery ? (systemInfo.batteryPercent + "%") : "AC"); color: systemInfo.batteryCharging ? Theme.success : (systemInfo.batteryPercent < 20 ? Theme.error : Theme.tertiary); font.pixelSize: 11; font.weight: Font.DemiBold }
                        
                        Rectangle { implicitWidth: 1; implicitHeight: 12; color: Qt.rgba(1, 1, 1, 0.15) }

                        Text {
                            text: "⚙"
                            font.pixelSize: 12
                            color: Theme.primary
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shellController.toggleLock()
                    }
                }
            }

            // ── 2. EXPANDED WIDGET DASHBOARD ──
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.isDashboardOpen
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                // Bloom Sliding Pill Tab Bar Header
                Item {
                    id: tabBarContainer
                    Layout.fillWidth: true
                    implicitHeight: 34

                    readonly property var tabs: [
                        { icon: "🕐", label: "Clock & Date" },
                        { icon: "☁", label: "Weather" },
                        { icon: "🎵", label: "Media & CAVA" },
                        { icon: "⚙", label: "System Health" },
                        { icon: "🗂", label: "Workspace" }
                    ]

                    RowLayout {
                        id: tabsRow
                        anchors.left: parent.left
                        spacing: 4

                        Repeater {
                            model: tabBarContainer.tabs

                            Item {
                                id: tabBtn
                                implicitWidth: tabRow.implicitWidth + 24
                                implicitHeight: 32

                                readonly property bool isActive: root.currentTab === index

                                RowLayout {
                                    id: tabRow
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text { text: modelData.icon; font.pixelSize: 12 }
                                    Text {
                                        text: modelData.label
                                        color: tabBtn.isActive ? "#ffffff" : Qt.rgba(1, 1, 1, 0.55)
                                        font.pixelSize: Theme.fontSM
                                        font.weight: tabBtn.isActive ? Font.Bold : Font.Normal
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.currentTab = index
                                }
                            }
                        }
                    }

                    // Sliding Pill Indicator
                    Rectangle {
                        id: pillIndicator
                        height: 32
                        radius: 16
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.55)
                        z: -1

                        property Item targetTabItem: tabsRow.children[root.currentTab] || null

                        x: targetTabItem ? targetTabItem.x : 0
                        width: targetTabItem ? targetTabItem.width : 0

                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
                    }

                    // Right Bloom Status Pill Badge
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: statusRow.implicitWidth + 16
                        implicitHeight: 26
                        radius: 13
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.3)

                        RowLayout {
                            id: statusRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                implicitWidth: 6
                                implicitHeight: 6
                                radius: 3
                                color: Theme.tertiary
                            }

                            Text {
                                text: "✨ Bloom Dashboard"
                                color: Qt.rgba(1, 1, 1, 0.85)
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }

                // ── 3. DASHBOARD TAB CONTENT STACK ──
                StackLayout {
                    currentIndex: root.currentTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Tab 0: Clock & Date Card
                    ClockTab {}

                    // Tab 1: Weather Card
                    WeatherTab {}

                    // Tab 2: Media & CAVA Visualizer
                    MediaTab {}

                    // Tab 3: System Health Card
                    SystemHealthTab {}

                    // Tab 4: Workspace Settings
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Workspace Switching"
                                color: "#ffffff"
                                font.pixelSize: Theme.fontMD
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.08)
                            }

                            // Switching Mode
                            Text {
                                text: "Switching Mode"
                                color: Qt.rgba(1, 1, 1, 0.75)
                                font.pixelSize: Theme.fontSM
                            }

                            RowLayout {
                                spacing: 8

                                Rectangle {
                                    id: standardModeBtn
                                    property bool active: workspaceController.switchingMode === "standard"
                                    implicitWidth: modeLabel.implicitWidth + 24
                                    implicitHeight: 32
                                    radius: 16
                                    color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28) : Qt.rgba(1, 1, 1, 0.06)
                                    border.width: 1
                                    border.color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.55) : Qt.rgba(1, 1, 1, 0.1)

                                    Text {
                                        id: modeLabel
                                        anchors.centerIn: parent
                                        text: "Standard (Win+Ctrl+←/→)"
                                        color: standardModeBtn.active ? "#ffffff" : Qt.rgba(1, 1, 1, 0.65)
                                        font.pixelSize: Theme.fontSM
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: workspaceController.setSwitchingMode("standard")
                                    }
                                }

                                Rectangle {
                                    id: experimentalModeBtn
                                    property bool active: workspaceController.switchingMode === "experimental"
                                    implicitWidth: modeLabel2.implicitWidth + 24
                                    implicitHeight: 32
                                    radius: 16
                                    color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28) : Qt.rgba(1, 1, 1, 0.06)
                                    border.width: 1
                                    border.color: active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.55) : Qt.rgba(1, 1, 1, 0.1)

                                    Text {
                                        id: modeLabel2
                                        anchors.centerIn: parent
                                        text: experimentalSwitcher && experimentalSwitcher.isAvailable ? "Experimental (Direct COM)" : "Experimental (Unavailable)"
                                        color: experimentalModeBtn.active && experimentalSwitcher && experimentalSwitcher.isAvailable ? "#ffffff" : Qt.rgba(1, 1, 1, 0.45)
                                        font.pixelSize: Theme.fontSM
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: experimentalSwitcher && experimentalSwitcher.isAvailable
                                        onClicked: workspaceController.setSwitchingMode("experimental")
                                    }
                                }
                            }

                            // Status
                            Text {
                                text: workspaceController.statusText || "Ready"
                                color: Qt.rgba(1, 1, 1, 0.65)
                                font.pixelSize: Theme.fontXS
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Qt.rgba(1, 1, 1, 0.08)
                            }

                            Text {
                                text: experimentalSwitcher ? ("Experimental API: " + (experimentalSwitcher.isAvailable ? "Available" : "Unavailable")) : "Experimental switcher not initialized"
                                color: experimentalSwitcher && experimentalSwitcher.isAvailable ? Theme.success : Theme.error
                                font.pixelSize: Theme.fontXS
                            }
                        }
                    }
                }
            }
        }
    }
}
