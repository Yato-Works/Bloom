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
    anchors.topMargin: 48
    anchors.bottomMargin: 48

    opacity: open ? 1 : 0

    transform: Translate {
        x: root.open ? 0 : -(root.panelWidth + 32)
        Behavior on x {
            NumberAnimation {
                duration: Theme.durationDefault
                easing.type: Easing.OutCubic
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -24
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    GlassPanel {
        anchors.fill: parent
        anchors.leftMargin: 16
        tint: Theme.surface
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingMD

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSM

                MaterialIcon {
                    name: "bot"
                    iconSize: 22
                }

                Text {
                    text: "Bloom AI Assistant"
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontLG
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Theme.radiusFull
                    color: trashMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                    MaterialIcon {
                        anchors.centerIn: parent
                        name: "trash"
                        iconSize: 14
                        iconColor: Theme.textMuted
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
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Quick Actions Chips
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: ["天気は？", "Bloomとは？", "タスク一覧"]

                    Rectangle {
                        implicitWidth: chipText.implicitWidth + 16
                        implicitHeight: 26
                        radius: Theme.radiusFull
                        color: chipMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                                                        : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData
                            color: Theme.textSecondary
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

            // Message History ListView
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Theme.spacingSM
                model: aiService.messages

                delegate: RowLayout {
                    width: listView.width
                    spacing: 8

                    readonly property bool isUser: modelData.sender === "user"

                    Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft

                    Rectangle {
                        Layout.maximumWidth: listView.width * 0.8
                        implicitWidth: msgCol.implicitWidth + 24
                        implicitHeight: msgCol.implicitHeight + 16
                        radius: Theme.radiusMedium
                        color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                                      : Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
                                             : Qt.rgba(1, 1, 1, 0.08)

                        ColumnLayout {
                            id: msgCol
                            anchors.centerIn: parent
                            width: parent.width - 24
                            spacing: 4

                            Text {
                                text: modelData.text
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontSM
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.time
                                color: Theme.textMuted
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
                spacing: Theme.spacingXS

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: Theme.radiusMedium
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: promptInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                    TextInput {
                        id: promptInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontSM
                        clip: true

                        Text {
                            text: "AIにメッセージを送信..."
                            color: Theme.textMuted
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
                    radius: Theme.radiusMedium
                    color: sendMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.7)

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
