import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Bloom

// ============================================================================
//  BloomLockScreen — full-screen passcode lock (shown by LockService after the
//  idle timeout). Unlocks only with the configured passcode via
//  lockService.tryUnlock().
// ============================================================================
Item {
    id: lockRoot
    anchors.fill: parent
    z: 2000
    visible: opacity > 0.01

    property bool locked: false
    property bool showError: false
    property string wallSrc: ""
    // Declarative so the overlay shows even when the service locked before
    // QML loaded (e.g. the app started while the session was already idle).
    opacity: locked ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    focus: lockRoot.locked

    signal unlocked()

    onLockedChanged: {
        if (lockRoot.locked) {
            passField.text = ""
            passField.forceActiveFocus()
        }
    }

    function trySubmit() {
        if (!lockRoot.locked || passField.text.length === 0)
            return
        if (lockService.tryUnlock(passField.text)) {
            passField.text = ""
            lockRoot.unlocked()
        } else {
            showError = true
            errorTimer.restart()
            shakeAnim.restart()
            passField.text = ""
            passField.forceActiveFocus()
        }
    }

    Timer {
        id: errorTimer
        interval: 900
        onTriggered: lockRoot.showError = false
    }

    SequentialAnimation {
        id: shakeAnim
        NumberAnimation { target: shakeTranslate; property: "x"; from: 0; to: -10; duration: 60; easing.type: Easing.OutCubic }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -10; to: 10; duration: 90; easing.type: Easing.InOutCubic }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 10; to: 0; duration: 70; easing.type: Easing.OutCubic }
    }

    // ---- backdrop: blurred wallpaper + deep scrim ----
    Image {
        id: lockWall
        anchors.fill: parent
        source: lockRoot.wallSrc
        fillMode: Image.PreserveAspectCrop
        cache: false
        visible: false
    }
    MultiEffect {
        anchors.fill: lockWall
        source: lockWall
        visible: lockWall.status === Image.Ready
        blurEnabled: true
        blur: 0.85
        blurMax: 48
        brightness: -0.22
        saturation: 0.8
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    // ---- center content ----
    Item {
        id: rootArea
        anchors.fill: parent

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.14
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.formattedTime
                color: Colours.m3onSurface
                font.family: "Rubik"
                font.pixelSize: 96
                font.weight: Font.Thin
                font.letterSpacing: 3
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.formattedDate
                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.85)
                font.family: "Rubik"
                font.pixelSize: 17
                font.letterSpacing: 4
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: systemInfo.hostName
                color: Qt.alpha(Colours.m3onSurfaceVariant, 0.55)
                font.family: "Rubik"
                font.pixelSize: 12
                font.letterSpacing: 2
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // passcode pill
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.18
            spacing: 14

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                transform: Translate { id: shakeTranslate; x: 0 }

                Rectangle {
                    width: 300
                    height: 54
                    radius: 27
                    color: Qt.alpha(Colours.m3surfaceContainerHigh, 0.85)
                    border.width: passField.activeFocus ? 1.5 : 1
                    border.color: lockRoot.showError ? Colours.m3error
                        : (passField.activeFocus ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.5))
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 10

                        BloomIcon {
                            text: "lock"
                            color: Qt.alpha(Colours.m3onSurfaceVariant, 0.8)
                            font.pixelSize: 17
                        }

                        TextField {
                            id: passField
                            Layout.fillWidth: true
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            placeholderText: "Passcode"
                            placeholderTextColor: Qt.alpha(Colours.m3onSurfaceVariant, 0.4)
                            color: Colours.m3onSurface
                            font.family: "Rubik"
                            font.pixelSize: 17
                            font.letterSpacing: 6
                            background: null
                            selectByMouse: false
                            enabled: lockRoot.locked
                            focus: lockRoot.locked
                            activeFocusOnTab: true

                            onAccepted: lockRoot.trySubmit()
                            Keys.onEscapePressed: event.accepted = true
                        }

                        Rectangle {
                            width: 34; height: 34; radius: 17
                            color: submitHover.hovered ? Qt.alpha(Colours.m3primary, 0.22) : "transparent"
                            HoverHandler { id: submitHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: lockRoot.trySubmit() }
                            BloomIcon {
                                anchors.centerIn: parent
                                text: "arrow_forward"
                                color: Colours.m3primary
                                font.pixelSize: 17
                            }
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: lockRoot.showError ? "Incorrect passcode" : "Enter passcode to unlock"
                color: lockRoot.showError ? Colours.m3error : Qt.alpha(Colours.m3onSurfaceVariant, 0.6)
                font.family: "Rubik"
                font.pixelSize: 12
                font.letterSpacing: 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
