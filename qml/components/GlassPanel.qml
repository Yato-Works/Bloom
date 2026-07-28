import QtQuick

Rectangle {
    id: panel
    property color tint: Theme.surfaceRaised
    property bool showShadow: true
    property bool showHighlight: true
    default property alias content: content.data

    radius: Theme.radiusMedium
    color: Qt.rgba(tint.r, tint.g, tint.b, 0.84)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.10)

    // Subtle shadow using layered rectangles
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: parent.radius - 2
        color: Theme.background
        opacity: showShadow ? 0.28 : 0
        z: -10
        Behavior on opacity { NumberAnimation { duration: Theme.durationDefault } }
    }

    // Top edge highlight for glass effect
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Qt.rgba(1, 1, 1, 0.08)
        visible: showHighlight
    }

    // Bottom edge subtle reflection
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.rgba(0, 0, 0, 0.12)
        visible: showHighlight
    }

    // Inner gradient for depth
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0
                color: Qt.rgba(1, 1, 1, 0.04) }
            GradientStop { position: 0.4
                color: "transparent" }
            GradientStop { position: 1
                color: Qt.rgba(0, 0, 0, 0.06) }
        }
    }

    Item { id: content; anchors.fill: parent; anchors.margins: 1 }
    Behavior on color { ColorAnimation { duration: Theme.durationFast } }
}
