import QtQuick
import Bloom

// Material-style state layer: hover tint + press ripple, ported from
// caelestia-shell's StateLayer.qml with its Caelestia.Config / Tokens deps
// replaced by Bloom's Theme. Use as a child filling the clickable surface.
MouseArea {
    id: root

    property bool disabled: false
    property bool showHoverBackground: true
    property bool manualPressOverride: false
    property bool manualHoverOverride: false
    readonly property alias rect: base

    property color stateColor: "#ffffff"
    property real hoverOpacity: 0.08
    property real pressOpacity: 0.12

    property real pressX: width / 2
    property real pressY: height / 2
    property real circleRadius: 0

    property alias color: base.color
    property alias radius: base.radius
    property alias topLeftRadius: base.topLeftRadius
    property alias topRightRadius: base.topRightRadius
    property alias bottomLeftRadius: base.bottomLeftRadius
    property alias bottomRightRadius: base.bottomRightRadius

    readonly property real stateOpacity: (containsMouse || manualHoverOverride)
                                          && showHoverBackground ? hoverOpacity : 0

    readonly property real endRadius: {
        const dx = Math.max(pressX, width - pressX)
        const dy = Math.max(pressY, height - pressY)
        return Math.sqrt(dx * dx + dy * dy) * 1.25 + 8
    }

    function press(x, y) {
        pressX = x
        pressY = y
        fadeAnim.complete()
        circleRadius = 0
        ripple.opacity = pressOpacity
        rippleAnim.restart()
    }

    anchors.fill: parent
    enabled: !disabled
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    onPressed: e => press(e.x, e.y)

    onPressedChanged: {
        if (!pressed && !manualPressOverride && !rippleAnim.running && ripple.opacity > 0)
            fadeAnim.start()
    }

    NumberAnimation {
        id: rippleAnim
        target: root
        property: "circleRadius"
        to: root.endRadius
        duration: Theme.durationSlow
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: fadeAnim
        target: ripple
        property: "opacity"
        to: 0
        duration: Theme.durationSlow
        easing.type: Easing.OutCubic
    }

    Rectangle {
        id: base
        anchors.fill: parent
        opacity: root.stateOpacity
        color: root.stateColor
        radius: root.parent?.radius ?? 0
        topLeftRadius: root.parent?.topLeftRadius ?? radius ?? 0
        topRightRadius: root.parent?.topRightRadius ?? radius ?? 0
        bottomLeftRadius: root.parent?.bottomLeftRadius ?? radius ?? 0
        bottomRightRadius: root.parent?.bottomRightRadius ?? radius ?? 0

        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
    }

    Rectangle {
        id: ripple
        anchors.fill: parent
        radius: base.radius
        color: root.stateColor
        opacity: 0
        visible: opacity > 0.001
        layer.enabled: true

        Rectangle {
            anchors.centerIn: parent
            width: root.circleRadius * 2
            height: root.circleRadius * 2
            radius: width / 2
            color: root.stateColor
        }
    }
}
