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

    readonly property bool topOpen: shellController.armed
                                    && (topHit.containsMouse || topPanelHovered)
    readonly property bool bottomOpen: shellController.armed
                                       && (bottomHit.containsMouse || bottomPanelHovered)

    Connections {
        target: shellController
        function onArmedChanged() {
            if (!shellController.armed) {
                shell.topPanelHovered = false
                shell.bottomPanelHovered = false
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
    }
}
