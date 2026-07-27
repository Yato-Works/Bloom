import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// Hold-shell host: dim + edge hitboxes + top/bottom panels.
// Armed by ShellController (default Ctrl+Win). Release closes everything (B1).
ApplicationWindow {
    id: shell
    title: "Bloom"
    color: "transparent"
    visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    // β panel hover state (survives leaving the thin hit zone)
    property bool topPanelHovered: false
    property bool bottomPanelHovered: false

    readonly property bool topOpen: shellController.armed
                                    && (topHit.containsMouse || topPanelHovered)
    readonly property bool bottomOpen: shellController.armed
                                       && (bottomHit.containsMouse || bottomPanelHovered)

    // Force-clear β hover when disarmed (B1)
    Connections {
        target: shellController
        function onArmedChanged() {
            if (!shellController.armed) {
                shell.topPanelHovered = false
                shell.bottomPanelHovered = false
            }
        }
    }

    // ===== Full-screen layer =====
    Item {
        anchors.fill: parent

        // Dim — absorbs all clicks (no pass-through to desktop)
        Rectangle {
            id: dim
            anchors.fill: parent
            color: "#000000"
            opacity: shellController.armed ? shellController.dimOpacity : 0
            Behavior on opacity {
                NumberAnimation { duration: Theme.durationFast }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                // Swallow clicks; do nothing else
                onPressed: function(mouse) { mouse.accepted = true }
                onClicked: function(mouse) { mouse.accepted = true }
                onWheel: function(wheel) { wheel.accepted = true }
            }
        }

        // Subtle edge hints while armed (not full bars — discoverability only)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 2
            opacity: shellController.armed ? 0.35 : 0
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.primary }
                GradientStop { position: 1.0; color: "transparent" }
            }
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            opacity: shellController.armed ? 0.35 : 0
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.accent }
                GradientStop { position: 1.0; color: "transparent" }
            }
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
        }

        // Center hold hint (only while armed and no panel open)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: hintRow.width + 28
            height: 36
            radius: Theme.radiusFull
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.72)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
            opacity: shellController.armed && !shell.topOpen && !shell.bottomOpen ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

            Row {
                id: hintRow
                anchors.centerIn: parent
                spacing: 10
                Text {
                    text: "✿"
                    color: Theme.primary
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: shellController.statusText
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSM
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ===== Top hitbox =====
        MouseArea {
            id: topHit
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: shellController.hitZoneSize
            hoverEnabled: true
            // Let dim below still exist; this sits above for hover
            z: 20
            // Don't steal clicks from panel when open — panel is higher
            enabled: shellController.armed
            acceptedButtons: Qt.NoButton
        }

        // ===== Bottom hitbox =====
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

        // ===== Top panel =====
        TopShellPanel {
            id: topPanel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            z: 30
            open: shell.topOpen
            onPanelHoveredChanged: shell.topPanelHovered = panelHovered
        }

        // ===== Bottom panel =====
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
