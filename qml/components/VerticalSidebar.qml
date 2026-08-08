import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool expanded: false
    property int currentWorkspace: 1
    property string activeApp: "Bloom Shell"
    property string language: "ja"

    width: expanded ? 280 : 72
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.leftMargin: 12
    anchors.topMargin: 12
    anchors.bottomMargin: 12

    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutExpo } }

    GlassPanel {
        id: sidebarGlass
        anchors.fill: parent
        radius: 24
        tint: Qt.rgba(0.05, 0.06, 0.09, 0.95)
        elevated: true

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: width
            contentHeight: contentColumn.implicitHeight + 48
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 16
                Layout.fillWidth: true

                // ── TOP: Workspace & Dashboard Toggle ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: expanded ? 120 : 56
                        radius: 16
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.expanded = !root.expanded
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: expanded ? 12 : 0

                            RowLayout {
                                id: wsRow
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 6

                                Repeater {
                                    model: 4
                                    Rectangle {
                                        implicitWidth: modelData === root.currentWorkspace ? (expanded ? 24 : 10) : (expanded ? 10 : 6)
                                        implicitHeight: expanded ? 10 : 6
                                        radius: 5
                                        color: modelData === root.currentWorkspace ? Theme.primary : Qt.rgba(1, 1, 1, 0.3)
                                        Behavior on implicitWidth { NumberAnimation { duration: 200 } }
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        MouseArea { anchors.fill: parent; onClicked: root.currentWorkspace = modelData }
                                    }
                                }
                            }

                            ColumnLayout {
                                visible: expanded
                                spacing: 6
                                Repeater {
                                    model: [
                                        { name: "Dashboard", icon: "🏠" },
                                        { name: "Development", icon: "💻" },
                                        { name: "Communication", icon: "💬" },
                                        { name: "Media", icon: "🎵" }
                                    ]
                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 36
                                        radius: 10
                                        color: index === root.currentWorkspace - 1 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : "transparent"
                                        border.width: index === root.currentWorkspace - 1 ? 1 : 0
                                        border.color: Theme.primary

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 10
                                            Text { text: modelData.icon; font.pixelSize: 14 }
                                            Text {
                                                text: modelData.name
                                                color: index === root.currentWorkspace - 1 ? Theme.primary : Theme.textMuted
                                                font.pixelSize: 13
                                                font.weight: index === root.currentWorkspace - 1 ? Font.Bold : Font.Normal
                                            }
                                        }
                                        MouseArea { anchors.fill: parent; onClicked: root.currentWorkspace = index + 1 }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: expanded ? 12 : 0

                            Text { text: "📊"; font.pixelSize: 20 }
                            Text {
                                text: "Dashboard"
                                color: Theme.text
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                visible: expanded
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: shellController.armPermanent(true)
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                    visible: expanded
                }

                // ── CENTER: Active App Info ──
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    visible: expanded

                    Text { text: "ACTIVE APP"; color: Theme.textMuted; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.5 }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 80
                        radius: 14
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
                        border.width: 1
                        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            RowLayout {
                                spacing: 10
                                Text { text: "🌸"; font.pixelSize: 24 }
                                ColumnLayout {
                                    Text { text: root.activeApp; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }
                                    Text { text: "Bloom Custom Shell"; color: Theme.textMuted; font.pixelSize: 11 }
                                }
                            }
                        }
                    }
                }

                Item {
                    visible: !expanded
                    implicitWidth: 72
                    implicitHeight: 120

                    Text {
                        anchors.centerIn: parent
                        text: root.activeApp.split("").join("\n")
                        color: Theme.textMuted
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        lineHeight: 1.2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: expanded ? 40 : 32
                    radius: expanded ? 12 : 8
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, expanded ? 0.15 : 0.25)
                    border.width: 1
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: expanded ? 8 : 0

                        Text { text: "🌐"; font.pixelSize: expanded ? 14 : 10; visible: expanded }
                        Text {
                            text: root.language.toUpperCase()
                            color: Theme.accent
                            font.pixelSize: expanded ? 12 : 10
                            font.weight: Font.Bold
                            font.family: "Monospace"
                        }
                    }
                    MouseArea { anchors.fill: parent; onClicked: root.language = root.language === "ja" ? "en" : "ja" }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: systemInfo.formattedTime !== "" ? systemInfo.formattedTime.replace(":", "\n") : "03\n30\nPM"
                        color: Theme.text
                        font.pixelSize: expanded ? 20 : 12
                        font.weight: Font.Bold
                        font.family: "Monospace"
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.1
                    }

                    Text {
                        text: expanded ? "PM" : ""
                        color: Theme.accent
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        visible: expanded
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: expanded ? 10 : 6
                    visible: expanded

                    RowLayout { Layout.fillWidth: true; spacing: 8
                        QuickSettingIcon { icon: "📶"; label: "WiFi"; active: true; onClicked: {} }
                        QuickSettingIcon { icon: "🌐"; label: "BT"; active: true; onClicked: {} }
                    }
                    RowLayout { Layout.fillWidth: true; spacing: 8
                        QuickSettingIcon { icon: "🔋"; label: "Power"; active: false; onClicked: {} }
                        QuickSettingIcon { icon: "⚙"; label: "Settings"; active: false; onClicked: shellController.toggleLock() }
                    }
                }

                ColumnLayout {
                    visible: !expanded
                    spacing: 14
                    anchors.horizontalCenter: parent.horizontalCenter

                    QuickSettingIcon { icon: "📶"; label: ""; active: true; onClicked: {} }
                    QuickSettingIcon { icon: "🌐"; label: ""; active: true; onClicked: {} }
                    QuickSettingIcon { icon: "🔋"; label: ""; active: false; onClicked: {} }
                    QuickSettingIcon { icon: "⚙"; label: ""; active: false; onClicked: shellController.toggleLock() }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -16
        hoverEnabled: true
        onEntered: root.expanded = true
        onExited: root.expanded = false
    }
}