import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

ApplicationWindow {
    id: shell
    title: "Bloom"
    color: "transparent"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    property bool topPanelHovered: false
    property bool bottomPanelHovered: false
    property bool leftPanelHovered: false
    property bool rightPanelHovered: false

    readonly property bool isLocked: shellController.locked

    readonly property bool topOpen: shellController.armed
                                    && (topHit.containsMouse || topPanelHovered || isLocked)
    readonly property bool bottomOpen: shellController.armed
                                       && (bottomHit.containsMouse || bottomPanelHovered || isLocked)
    readonly property bool leftOpen: shellController.armed
                                     && (leftHit.containsMouse || leftPanelHovered || isLocked)
    readonly property bool rightOpen: shellController.armed
                                      && (rightHit.containsMouse || rightPanelHovered || isLocked)

    // Space Key Shortcut for Locking / Unlocking
    Shortcut {
        sequence: "Space"
        enabled: shellController.armed
        onActivated: shellController.toggleLock()
    }

    Connections {
        target: shellController
        function onArmedChanged() {
            if (!shellController.armed) {
                shell.topPanelHovered = false
                shell.bottomPanelHovered = false
                shell.leftPanelHovered = false
                shell.rightPanelHovered = false
            }
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: dim
            anchors.fill: parent
            color: "transparent"
            opacity: shellController.armed ? shellController.dimOpacity : 0
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: function(mouse) { mouse.accepted = true }
                onClicked: function(mouse) { mouse.accepted = true }
                onWheel: function(wheel) { wheel.accepted = true }
            }
        }

        // Lock Status Badge Indicator
        Rectangle {
            id: lockBadge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            z: 100
            implicitWidth: lockRow.implicitWidth + 20
            implicitHeight: 26
            radius: 13
            color: shell.isLocked ? Qt.rgba(0.9, 0.3, 0.3, 0.85) : Qt.rgba(0, 0, 0, 0.4)
            border.width: 1
            border.color: shell.isLocked ? Qt.rgba(1, 0.5, 0.5, 0.6) : Qt.rgba(1, 1, 1, 0.1)
            opacity: shellController.armed ? 0.9 : 0

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                id: lockRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: shell.isLocked ? "🔒" : "🔓"
                    font.pixelSize: 11
                }
                Text {
                    text: shell.isLocked ? "LOCKED (Space to unlock)" : "Space to lock"
                    color: "#ffffff"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        // Hit Zones (Top, Bottom, Left, Right)
        MouseArea {
            id: topHit
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: shellController.hitZoneSize
            hoverEnabled: true
            z: 20
            enabled: shellController.armed
            acceptedButtons: Qt.NoButton
        }

        MouseArea {
            id: bottomHit
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: shellController.hitZoneSize
            hoverEnabled: true
            z: 20
            enabled: shellController.armed
            acceptedButtons: Qt.NoButton
        }

        MouseArea {
            id: leftHit
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: shellController.hitZoneSize
            hoverEnabled: true
            z: 20
            enabled: shellController.armed
            acceptedButtons: Qt.NoButton
        }

        MouseArea {
            id: rightHit
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: shellController.hitZoneSize
            hoverEnabled: true
            z: 20
            enabled: shellController.armed
            acceptedButtons: Qt.NoButton
        }

        // Panels & Drawers
        TopShellPanel {
            id: topPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            z: 30
            open: shell.topOpen
            onPanelHoveredChanged: shell.topPanelHovered = panelHovered
        }

        BottomShellPanel {
            id: bottomPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            z: 30
            open: shell.bottomOpen
            onPanelHoveredChanged: shell.bottomPanelHovered = panelHovered
        }

        LeftDrawer {
            id: leftDrawer
            anchors.left: parent.left
            z: 30
            open: shell.leftOpen
            onPanelHoveredChanged: shell.leftPanelHovered = panelHovered
        }

        RightDrawer {
            id: rightDrawer
            anchors.right: parent.right
            z: 30
            open: shell.rightOpen
            onPanelHoveredChanged: shell.rightPanelHovered = panelHovered
        }
    }
}
