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
        x: root.open ? 0 : (root.panelWidth + 32)
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
        anchors.rightMargin: 16
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
                    name: "notion"
                    iconSize: 22
                }

                Text {
                    text: "Notion Workspace"
                    color: Theme.textPrimary
                    font.pixelSize: Theme.fontLG
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 20
                    radius: Theme.radiusFull
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)

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
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Task Add Input Form
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXS

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: Theme.radiusMedium
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1
                    border.color: taskTitleInput.activeFocus ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                    TextInput {
                        id: taskTitleInput
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.textPrimary
                        font.pixelSize: Theme.fontSM
                        clip: true

                        Text {
                            text: "新しいタスクを追加..."
                            color: Theme.textMuted
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
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: Theme.radiusMedium
                    color: addMouse.containsMouse ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.7)

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
                    implicitHeight: 46
                    radius: Theme.radiusMedium
                    color: modelData.completed ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        // Checkbox
                        Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 4
                            color: modelData.completed ? Theme.primary : "transparent"
                            border.width: 1.5
                            border.color: modelData.completed ? Theme.primary : Theme.textMuted

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
                                color: modelData.completed ? Theme.textMuted : Theme.textPrimary
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
                                }
                                Text {
                                    text: modelData.date
                                    color: Theme.textMuted
                                    font.pixelSize: 10
                                }
                            }
                        }

                        // Remove button
                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            radius: Theme.radiusFull
                            color: delMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.2) : "transparent"

                            MaterialIcon {
                                anchors.centerIn: parent
                                name: "close"
                                iconSize: 10
                                iconColor: delMouse.containsMouse ? "#ff5555" : Theme.textMuted
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
