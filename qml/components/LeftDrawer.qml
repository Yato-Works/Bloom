import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelWidth: 360

    width: panelWidth
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.topMargin: 36
    anchors.bottomMargin: 36

    opacity: open ? 1 : 0

    transform: Translate {
        x: root.open ? 0 : -(root.panelWidth + 40)
        Behavior on x {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutExpo
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -30
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    GlassPanel {
        anchors.fill: parent
        anchors.leftMargin: 20
        tint: Qt.rgba(0.08, 0.08, 0.12, 0.92)
        elevated: true
        radius: 24

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header Badge
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 17
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)

                    MaterialIcon {
                        anchors.centerIn: parent
                        name: "bot"
                        iconSize: 18
                        iconColor: Theme.primary
                    }
                }

                Text {
                    text: "Bloom AI Assistant"
                    color: "#ffffff"
                    font.pixelSize: Theme.fontLG
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 15
                    color: trashMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    MaterialIcon {
                        anchors.centerIn: parent
                        name: "trash"
                        iconSize: 14
                        iconColor: Qt.rgba(1, 1, 1, 0.5)
                    }

                    MouseArea {
                        id: trashMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: aiService.clearHistory()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Quick Prompt Chips
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: ["天気は？", "Bloomとは？", "タスク一覧"]

                    Rectangle {
                        implicitWidth: chipText.implicitWidth + 16
                        implicitHeight: 26
                        radius: 13
                        color: chipMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                                                        : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData
                            color: Qt.rgba(1, 1, 1, 0.8)
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: chipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: aiService.sendMessage(modelData)
                        }
                    }
                }
            }

            // Messages ListView
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                model: aiService.messages

                delegate: RowLayout {
                    width: listView.width
                    spacing: 8

                    readonly property bool isUser: modelData.sender === "user"
                    Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft

                    Rectangle {
                        Layout.maximumWidth: listView.width * 0.82
                        implicitWidth: msgCol.implicitWidth + 24
                        implicitHeight: msgCol.implicitHeight + 16
                        radius: 16
                        color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
                                      : Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        border.color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
                                             : Qt.rgba(1, 1, 1, 0.09)

                        ColumnLayout {
                            id: msgCol
                            anchors.centerIn: parent
                            width: parent.width - 24
                            spacing: 4

                            Text {
                                text: modelData.text
                                color: "#ffffff"
                                font.pixelSize: Theme.fontSM
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.time
                                color: Qt.rgba(1, 1, 1, 0.4)
                                font.pixelSize: 9
                                Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft
                            }
                        }
                    }
                }

                onCountChanged: listView.positionViewAtEnd()
            }

            // Generating indicator
            RowLayout {
                Layout.fillWidth: true
                visible: aiService.isGenerating
                spacing: 8

                Text {
                    text: "AIが応答を生成中..."
                    color: Theme.primary
                    font.pixelSize: Theme.fontXS
                    font.italic: true
                }
            }

            // Input Area
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: 19
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.width: 1
                    border.color: promptInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                    TextInput {
                        id: promptInput
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#ffffff"
                        font.pixelSize: Theme.fontSM
                        clip: true

                        Text {
                            text: "AIにメッセージを送信..."
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: Theme.fontSM
                            visible: !promptInput.text && !promptInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onAccepted: {
                            if (promptInput.text.length > 0) {
                                aiService.sendMessage(promptInput.text)
                                promptInput.text = ""
                            }
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 38
                    implicitHeight: 38
                    radius: 19
                    color: sendMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.75)

                    MaterialIcon {
                        anchors.centerIn: parent
                        name: "send"
                        iconSize: 14
                        iconColor: "#ffffff"
                    }

                    MouseArea {
                        id: sendMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (promptInput.text.length > 0) {
                                aiService.sendMessage(promptInput.text)
                                promptInput.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
