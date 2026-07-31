import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false
    property int currentTab: 0

    readonly property int panelWidth: 380

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

            // Header Tab Bar (Notion & AI)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { icon: "📝", label: "Notion" },
                        { icon: "🤖", label: "AI Assistant" }
                    ]

                    Item {
                        id: leftTabBtn
                        implicitWidth: (parent.width - 8) / 2
                        implicitHeight: 34

                        readonly property bool isActive: root.currentTab === index

                        Rectangle {
                            anchors.fill: parent
                            radius: 17
                            color: leftTabBtn.isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                                                       : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: leftTabBtn.isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
                                                              : Qt.rgba(1, 1, 1, 0.07)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            Text { text: modelData.icon; font.pixelSize: 13 }
                            Text {
                                text: modelData.label
                                color: leftTabBtn.isActive ? "#ffffff" : Qt.rgba(1, 1, 1, 0.5)
                                font.pixelSize: Theme.fontSM
                                font.weight: leftTabBtn.isActive ? Font.Bold : Font.Normal
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Tab Content Stack
            StackLayout {
                currentIndex: root.currentTab
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Tab 0: Notion Workspace
                ColumnLayout {
                    spacing: 10

                    // Task Add Form
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            radius: 18
                            color: Qt.rgba(0, 0, 0, 0.35)
                            border.width: 1
                            border.color: taskInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                            TextInput {
                                id: taskInput
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#ffffff"
                                font.pixelSize: Theme.fontSM
                                clip: true

                                Text {
                                    text: "新しいタスクを追加..."
                                    color: Qt.rgba(1, 1, 1, 0.35)
                                    font.pixelSize: Theme.fontSM
                                    visible: !taskInput.text && !taskInput.activeFocus
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                onAccepted: {
                                    if (taskInput.text.length > 0) {
                                        notionService.addTask(taskInput.text, "General")
                                        taskInput.text = ""
                                    }
                                }
                            }
                        }

                        Rectangle {
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: addBtnMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.75)

                            MaterialIcon {
                                anchors.centerIn: parent
                                name: "plus"
                                iconSize: 14
                                iconColor: "#ffffff"
                            }

                            MouseArea {
                                id: addBtnMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (taskInput.text.length > 0) {
                                        notionService.addTask(taskInput.text, "General")
                                        taskInput.text = ""
                                    }
                                }
                            }
                        }
                    }

                    // Task List
                    ListView {
                        id: taskListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: notionService.tasks

                        delegate: Rectangle {
                            width: taskListView.width
                            implicitHeight: 46
                            radius: 14
                            color: modelData.completed ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(1, 1, 1, 0.05)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.07)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle {
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    radius: 5
                                    color: modelData.completed ? Theme.primary : "transparent"
                                    border.width: 1.5
                                    border.color: modelData.completed ? Theme.primary : Qt.rgba(1, 1, 1, 0.3)

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "check"
                                        iconSize: 11
                                        iconColor: "#ffffff"
                                        visible: modelData.completed
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notionService.toggleTask(index)
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.title
                                        color: modelData.completed ? Qt.rgba(1, 1, 1, 0.4) : "#ffffff"
                                        font.pixelSize: Theme.fontSM
                                        font.strikeout: modelData.completed
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    RowLayout {
                                        spacing: 8
                                        Text { text: modelData.category; color: Theme.primary; font.pixelSize: 9; font.weight: Font.DemiBold }
                                        Text { text: modelData.date; color: Qt.rgba(1, 1, 1, 0.4); font.pixelSize: 9 }
                                    }
                                }

                                Rectangle {
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    radius: 11
                                    color: delTaskMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.2) : "transparent"

                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        name: "close"
                                        iconSize: 10
                                        iconColor: delTaskMouse.containsMouse ? "#ff5555" : Qt.rgba(1, 1, 1, 0.4)
                                    }

                                    MouseArea {
                                        id: delTaskMouse
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notionService.removeTask(index)
                                    }
                                }
                            }
                        }
                    }
                }

                // Tab 1: AI Assistant
                ColumnLayout {
                    spacing: 10

                    // Quick Chips
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: ["天気は？", "Bloomとは？", "タスク一覧"]

                            Rectangle {
                                implicitWidth: chipText.implicitWidth + 14
                                implicitHeight: 24
                                radius: 12
                                color: aiChipMouse.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                                                                 : Qt.rgba(1, 1, 1, 0.04)
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    id: chipText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: Qt.rgba(1, 1, 1, 0.8)
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    id: aiChipMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: aiService.sendMessage(modelData)
                                }
                            }
                        }
                    }

                    // Messages ListView
                    ListView {
                        id: aiListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: aiService.messages

                        delegate: RowLayout {
                            width: aiListView.width
                            spacing: 8
                            readonly property bool isUser: modelData.sender === "user"
                            Layout.alignment: isUser ? Qt.AlignRight : Qt.AlignLeft

                            Rectangle {
                                Layout.maximumWidth: aiListView.width * 0.82
                                implicitWidth: aiMsgCol.implicitWidth + 24
                                implicitHeight: aiMsgCol.implicitHeight + 16
                                radius: 14
                                color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
                                              : Qt.rgba(1, 1, 1, 0.06)
                                border.width: 1
                                border.color: isUser ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
                                                     : Qt.rgba(1, 1, 1, 0.09)

                                ColumnLayout {
                                    id: aiMsgCol
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

                        onCountChanged: aiListView.positionViewAtEnd()
                    }

                    // AI Generating Status
                    RowLayout {
                        Layout.fillWidth: true
                        visible: aiService.isGenerating
                        spacing: 8

                        Text {
                            text: "AIが思考中..."
                            color: Theme.primary
                            font.pixelSize: Theme.fontXS
                            font.italic: true
                        }
                    }

                    // AI Prompt Input Form
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 36
                            radius: 18
                            color: Qt.rgba(0, 0, 0, 0.35)
                            border.width: 1
                            border.color: promptInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                            TextInput {
                                id: promptInput
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#ffffff"
                                font.pixelSize: Theme.fontSM
                                clip: true

                                Text {
                                    text: "AIに質問・メッセージ..."
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
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 18
                            color: sendBtnMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.75)

                            MaterialIcon {
                                anchors.centerIn: parent
                                name: "send"
                                iconSize: 13
                                iconColor: "#ffffff"
                            }

                            MouseArea {
                                id: sendBtnMouse
                                anchors.fill: parent
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
    }
}
