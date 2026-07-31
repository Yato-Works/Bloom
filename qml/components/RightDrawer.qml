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
        x: root.open ? 0 : (root.panelWidth + 40)
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
        anchors.rightMargin: 20
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
                        name: "notion"
                        iconSize: 18
                        iconColor: Theme.primary
                    }
                }

                Text {
                    text: "Notion Workspace"
                    color: "#ffffff"
                    font.pixelSize: Theme.fontLG
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 26
                    implicitHeight: 22
                    radius: 11
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)

                    Text {
                        anchors.centerIn: parent
                        text: notionService.activeTaskCount.toString()
                        color: Theme.primary
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // Task Add Input Form
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 38
                    radius: 19
                    color: Qt.rgba(0, 0, 0, 0.35)
                    border.width: 1
                    border.color: taskTitleInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                    TextInput {
                        id: taskTitleInput
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#ffffff"
                        font.pixelSize: Theme.fontSM
                        clip: true

                        Text {
                            text: "新しいタスクを追加..."
                            color: Qt.rgba(1, 1, 1, 0.35)
                            font.pixelSize: Theme.fontSM
                            visible: !taskTitleInput.text && !taskTitleInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onAccepted: {
                            if (taskTitleInput.text.length > 0) {
                                notionService.addTask(taskTitleInput.text, "General")
                                taskTitleInput.text = ""
                            }
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 38
                    implicitHeight: 38
                    radius: 19
                    color: addMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.75)

                    MaterialIcon {
                        anchors.centerIn: parent
                        name: "plus"
                        iconSize: 16
                        iconColor: "#ffffff"
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (taskTitleInput.text.length > 0) {
                                notionService.addTask(taskTitleInput.text, "General")
                                taskTitleInput.text = ""
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
                    implicitHeight: 48
                    radius: 14
                    color: modelData.completed ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        // Custom Checkbox
                        Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 6
                            color: modelData.completed ? Theme.primary : "transparent"
                            border.width: 1.5
                            border.color: modelData.completed ? Theme.primary : Qt.rgba(1, 1, 1, 0.3)

                            MaterialIcon {
                                anchors.centerIn: parent
                                name: "check"
                                iconSize: 12
                                iconColor: "#ffffff"
                                visible: modelData.completed
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notionService.toggleTask(index)
                            }
                        }

                        // Title & Info
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
                                Text {
                                    text: modelData.category
                                    color: Theme.primary
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: modelData.date
                                    color: Qt.rgba(1, 1, 1, 0.4)
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // Remove button
                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: 12
                            color: delMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.2) : "transparent"

                            MaterialIcon {
                                anchors.centerIn: parent
                                name: "close"
                                iconSize: 10
                                iconColor: delMouse.containsMouse ? "#ff5555" : Qt.rgba(1, 1, 1, 0.4)
                            }

                            MouseArea {
                                id: delMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notionService.removeTask(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
