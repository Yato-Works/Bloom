import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property int currentTab: 0

    readonly property int cardWidth: 1000
    readonly property int cardHeight: 720
    readonly property int tabBarHeight: 56

    width: root.cardWidth
    height: root.cardHeight
    anchors.centerIn: parent
    z: 100
    opacity: open ? 1 : 0
    scale: open ? 1.0 : 0.94

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
    Behavior on scale { NumberAnimation { duration: 280; easing.type: Easing.OutExpo } }

    GlassPanel {
        id: dashboardGlass
        anchors.fill: parent
        radius: 28
        tint: Qt.rgba(0.04, 0.05, 0.08, 0.96)
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── TAB BAR ──
            Rectangle {
                Layout.fillWidth: true
                height: root.tabBarHeight
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 4

                    Repeater {
                        model: [
                            { id: "weather", icon: "☁", label: "Weather" },
                            { id: "system", icon: "🖥", label: "System" },
                            { id: "media", icon: "🎵", label: "Media" },
                            { id: "launcher", icon: "🚀", label: "Launcher" },
                            { id: "calendar", icon: "📅", label: "Calendar" }
                        ]

                        Item {
                            id: tabBtn
                            implicitWidth: tabRow.implicitWidth + 28
                            implicitHeight: 40
                            property bool isActive: root.currentTab === index

                            Rectangle {
                                id: tabBg
                                anchors.fill: parent
                                radius: 14
                                color: tabBtn.isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : "transparent"
                                border.width: tabBtn.isActive ? 1 : 0
                                border.color: Theme.primary
                                Behavior on color { ColorAnimation { duration: 180 } }
                            }

                            RowLayout {
                                id: tabRow
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: modelData.icon; font.pixelSize: 16 }
                                Text {
                                    text: modelData.label
                                    color: tabBtn.isActive ? Theme.primary : Theme.textMuted
                                    font.pixelSize: 13
                                    font.weight: tabBtn.isActive ? Font.Bold : Font.Normal
                                }
                            }

                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.currentTab = index }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 12
                        color: closeHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                        Text { anchors.centerIn: parent; text: "✕"; color: Theme.textMuted; font.pixelSize: 14 }

                        MouseArea {
                            id: closeHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.open = false
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // ── TAB CONTENT ──
            StackLayout {
                currentIndex: root.currentTab
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Tab 0: Weather + System Info (Left-Right Split)
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 20

                        WeatherCard { Layout.fillWidth: true; Layout.fillHeight: true; Layout.preferredWidth: 460 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 460
                            spacing: 16

                            SystemInfoCard { Layout.fillWidth: true; Layout.fillHeight: true; Layout.maximumHeight: 320 }
                            CalendarSpectrumCard { Layout.fillWidth: true; Layout.fillHeight: true }
                        }
                    }
                }

                // Tab 1: System Resources
                SystemResourcesTab { }

                // Tab 2: Media Player
                MediaPlayerTab { }

                // Tab 3: App Launcher
                LauncherTab { }

                // Tab 4: Calendar Detail
                CalendarDetailTab { }
            }
        }
    }
}