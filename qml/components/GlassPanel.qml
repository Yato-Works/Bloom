import QtQuick
import Bloom

Rectangle {
    id: panel
    property color tint: Qt.rgba(0.07, 0.08, 0.12, 0.90)
    property bool showShadow: true
    property bool showHighlight: true
    property bool elevated: false
    property color accentBorder: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, elevated ? 0.28 : 0.14)
    default property alias content: content.data

    radius: Theme.radiusLG
    color: Qt.rgba(tint.r, tint.g, tint.b, elevated ? 0.94 : 0.88)
    border.width: 1
    border.color: accentBorder

    // Secondary inner highlight border for premium glass feel
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, parent.radius - 1)
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.04)
        z: 2
    }

    // Outer Glow / Ambient Drop Shadow
    Rectangle {
        anchors.fill: parent
        anchors.margins: elevated ? -2 : -1
        radius: parent.radius + 2
        color: Qt.rgba(0, 0, 0, showShadow ? (elevated ? 0.45 : 0.30) : 0)
        z: -10
        Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    }

    // Top edge specular reflection
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: parent.radius / 2
        anchors.rightMargin: parent.radius / 2
        height: 1.5
        radius: 1
        color: Qt.rgba(1, 1, 1, elevated ? 0.18 : 0.12)
        visible: showHighlight
        z: 3
    }

    // Dynamic Glass Inner Surface Gradient
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        z: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, elevated ? 0.07 : 0.04) }
            GradientStop { position: 0.4; color: Qt.rgba(1, 1, 1, 0.01) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, elevated ? 0.12 : 0.06) }
        }
    }

    Item {
        id: content
        anchors.fill: parent
        z: 5
    }

    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    Behavior on radius { NumberAnimation { duration: Theme.durationFast } }
}
