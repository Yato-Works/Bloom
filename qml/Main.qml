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

    readonly property bool topOpen: shellController.armed
                                    && (topHit.containsMouse || topPanelHovered)
    readonly property bool bottomOpen: shellController.armed
                                       && (bottomHit.containsMouse || bottomPanelHovered)
    readonly property bool leftOpen: shellController.armed
                                     && (leftHit.containsMouse || leftPanelHovered)
    readonly property bool rightOpen: shellController.armed
                                      && (rightHit.containsMouse || rightPanelHovered)

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
