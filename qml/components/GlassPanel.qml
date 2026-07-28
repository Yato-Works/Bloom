import QtQuick

Rectangle {
    id: panel
    property color tint: Theme.surfaceRaised
    property bool showShadow: true
    property bool showHighlight: true
    property bool elevated: false
    default property alias content: content.data

    radius: Theme.radiusLG
    color: Qt.rgba(tint.r, tint.g, tint.b, elevated ? 0.88 : 0.82)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, elevated ? 0.14 : 0.10)

    // Multi-layer shadow for depth
    Rectangle {
        anchors.fill: parent
        anchors.margins: elevated ? 1 : 2
        radius: parent.radius - (elevated ? 1 : 2)
        color: Theme.background
        opacity: showShadow ? (elevated ? 0.35 : 0.26) : 0
        z: -10
        Behavior on opacity { NumberAnimation { duration: Theme.durationDefault } }
    }

    // Secondary softer shadow layer
    Rectangle {
        anchors.fill: parent
        anchors.margins: elevated ? 3 : 4
        radius: parent.radius - (elevated ? 3 : 4)
        color: Theme.background
        opacity: showShadow ? 0.12 : 0
        z: -11
        Behavior on opacity { NumberAnimation { duration: Theme.durationDefault } }
    }

    // Top edge highlight for glass effect
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Qt.rgba(1, 1, 1, 0.10)
        visible: showHighlight
    }

    // Bottom edge subtle reflection
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.rgba(0, 0, 0, 0.10)
        visible: showHighlight
    }

    // Inner gradient for depth
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0
                color: Qt.rgba(1, 1, 1, elevated ? 0.06 : 0.04) }
            GradientStop { position: 0.5
                color: "transparent" }
            GradientStop { position: 1
                color: Qt.rgba(0, 0, 0, elevated ? 0.08 : 0.05) }
        }
    }

    Item { id: content; anchors.fill: parent; anchors.margins: 2 }
    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
    Behavior on radius { NumberAnimation { duration: Theme.durationFast } }
}
