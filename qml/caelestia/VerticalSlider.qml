import QtQuick
import QtQuick.Controls
import Bloom

Item {
    id: root

    property int value: 50           // 0 to 100
    property string icon: "🔊"
    property color activeColor: Colours.m3primary
    property bool muted: false

    signal valueModified(int newVal)
    signal iconClicked()

    readonly property string fontDisplay: "Rubik, 'Segoe UI Variable Display', 'Segoe UI', sans-serif"

    width: 44
    height: 156

    Rectangle {
        id: track
        anchors.fill: parent
        radius: width / 2
        color: Colours.m3surfaceContainerHighest
        border.width: 1
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)
        clip: true

        // Vertical fill from bottom up
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(0, parent.height * (root.muted ? 0 : root.value) / 100.0)
            radius: track.radius
            color: root.muted ? Colours.m3outline : root.activeColor
            Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
        }

        // Circular knob with embedded icon riding the fill level (matching screenshot)
        Rectangle {
            id: knob
            width: 34
            height: 34
            radius: 17
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colours.m3surfaceContainerLowest
            border.width: 1
            y: {
                const fill = track.height * (root.muted ? 0 : root.value) / 100.0;
                const targetY = track.height - fill - height / 2;
                return Math.max(5, Math.min(track.height - height - 5, targetY));
            }
            Behavior on y { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

            // Specular top highlight on knob
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: 1
                radius: parent.radius
                color: Qt.rgba(1, 1, 1, 0.20)
            }

            BloomIcon {
                anchors.centerIn: parent
                text: root.icon
                color: root.muted ? Colours.m3outline : root.activeColor
                font.pixelSize: 16
            }

            TapHandler {
                onTapped: root.iconClicked()
            }
        }

        // Value tooltip / percentage text (appears on hover or dragging)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 8
            width: 32
            height: 16
            radius: 8
            color: Qt.alpha(Colours.m3surfaceContainerLowest, 0.85)
            visible: dragArea.containsMouse || dragArea.pressed

            Text {
                anchors.centerIn: parent
                text: root.muted ? "MUT" : (root.value + "%")
                color: Colours.m3onSurface
                font.family: root.fontDisplay
                font.pixelSize: 9
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function updateFromMouse(mouseY) {
                const fraction = 1.0 - (mouseY / track.height);
                const clamped = Math.max(0, Math.min(100, Math.round(fraction * 100)));
                root.valueModified(clamped);
            }

            onPressed: mouse => updateFromMouse(mouse.y)
            onPositionChanged: mouse => {
                if (pressed) updateFromMouse(mouse.y)
            }
            onWheel: wheel => {
                const step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.valueModified(Math.max(0, Math.min(100, root.value + step)));
            }
        }
    }
}
