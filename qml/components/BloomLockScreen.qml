import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// ============================================================================
//  BloomLockScreen — full-screen lock overlay (Bloom lock style)
//  Driven by the `locked` property (bound to shellController.locked in Main.qml).
//  Dismiss by pressing any key once, or clicking "Unlock".
// ============================================================================
Item {
    id: lockRoot
    anchors.fill: parent
    z: 2000
    visible: opacity > 0.01

    // Show/hide state (bind to shellController.locked from Main.qml)
    property bool locked: false
    opacity: 0
    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    focus: lockRoot.locked

    signal dashboardRequested()

    onLockedChanged: {
        if (lockRoot.locked) {
            lockRoot.opacity = 1
        } else {
            lockRoot.opacity = 0
            unlockHint.fade = false
        }
    }

    // ---- full backdrop ----
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.03, 0.04, 0.07, 0.70)
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.55) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.15) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.55) }
        }
    }

    // ---- center content ----
    Item {
        anchors.fill: parent

        Column {
            id: lockCol
            anchors.centerIn: parent
            spacing: 22

            // lock icon in a glass badge
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 76; height: 76
                radius: 38
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.10)
                Text {
                    anchors.centerIn: parent
                    text: "🔒"
                    font.pixelSize: 34
                }
            }

            // big clock
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.formattedTime
                color: Theme.text
                font.pixelSize: 84
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
            }

            // date
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.formattedDate
                color: Theme.textMuted
                font.pixelSize: Theme.fontXL
                horizontalAlignment: Text.AlignHCenter
            }

            // host
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.hostName
                color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.55)
                font.pixelSize: Theme.fontSM
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // unlock hint pill (bottom center)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 56
            width: hintRow.implicitWidth + 36
            height: 40
            radius: 20
            color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            opacity: lockRoot.locked ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            RowLayout {
                id: hintRow
                anchors.centerIn: parent
                spacing: 8
                Text {
                    text: "Click to unlock"
                    color: Theme.text
                    font.pixelSize: Theme.fontSM
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "·"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSM
                }
                Text {
                    text: "Esc / Space"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontSM
                }
            }
        }
    }

    // click anywhere to unlock
    MouseArea {
        anchors.fill: parent
        onClicked: unlock()
    }

    // any key to unlock
    Keys.onPressed: unlock()

    // top-right dashboard access (above the fullscreen unlock MouseArea)
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 24
        anchors.rightMargin: 24
        width: 52; height: 52
        radius: 26
        color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        opacity: lockRoot.locked ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        z: 10
        Text {
            anchors.centerIn: parent
            text: "⌂"
            color: Theme.text
            font.pixelSize: 22
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: lockRoot.dashboardRequested()
        }
    }

    function unlock() {
        unlockHint.fade = true
        shellController.locked = false
        shellController.armPermanent(false)
    }

    Item {
        id: unlockHint
        property bool fade: false
    }
}
