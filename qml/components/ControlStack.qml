import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property int panelWidth: 380
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.rightMargin: 12
    anchors.topMargin: 12
    anchors.bottomMargin: 12
    width: panelWidth
    z: 80

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ── UPPER: Notifications & System Controls ──
        Item {
            id: notificationPanel
            Layout.fillWidth: true
            Layout.fillHeight: true

            GlassPanel {
                anchors.fill: parent
                radius: 24
                tint: Qt.rgba(0.05, 0.06, 0.09, 0.95)
                elevated: true

                Flickable {
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: contentColumn.implicitHeight + 32
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        spacing: 16
                        Layout.fillWidth: true

                        Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 10

                                Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 40
                                    radius: 14
                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

                                    Text { anchors.centerIn: parent; text: "🔔"; font.pixelSize: 18 }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Notifications & Controls"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        // Notification Content
                        ColumnLayout {
                            width: parent.width
                            spacing: 16

                            ListView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.preferredHeight: 280
                                spacing: 8
                                clip: true
                                model: 4

                                delegate: NotificationItem { }
                            }

                            PowerVolumeControls { Layout.fillWidth: true; Layout.preferredHeight: 180 }
                            BluetoothPanel { Layout.fillWidth: true; Layout.preferredHeight: 140 }
                            PowerProfileSelector { Layout.fillWidth: true; Layout.preferredHeight: 120 }
                        }
                    }
                }
            }
        }

        // ── LOWER: Quick Toggles & Utilities ──
        Item {
            id: quickTogglePanel
            Layout.fillWidth: true
            Layout.fillHeight: true

            GlassPanel {
                anchors.fill: parent
                radius: 24
                tint: Qt.rgba(0.05, 0.06, 0.09, 0.95)
                elevated: true

                Flickable {
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: contentColumn.implicitHeight + 32
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: contentColumn
                        width: parent.width
                        spacing: 16
                        Layout.fillWidth: true

                        Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            color: "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 10

                                Rectangle {
                                    implicitWidth: 40
                                    implicitHeight: 40
                                    radius: 14
                                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                    border.width: 1
                                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)

                                    Text { anchors.centerIn: parent; text: "⚡"; font.pixelSize: 18 }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Quick Toggles"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.06)
                        }

                        // Quick Toggle Content
                        ColumnLayout {
                            width: parent.width
                            spacing: 14

                            ToggleCard {
                                icon: "👁"; label: "Keep Awake"; subtitle: "Prevent system sleep";
                                checked: false; color: Theme.accent
                            }

                            ScreenRecorderCard { }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                columns: 4
                                rowSpacing: 10
                                columnSpacing: 10

                                QuickToggleBtn { icon: "📶"; label: "WiFi"; active: true; color: Theme.primary }
                                QuickToggleBtn { icon: "🌐"; label: "Bluetooth"; active: true; color: Theme.accent }
                                QuickToggleBtn { icon: "🎤"; label: "Mic"; active: false; color: Theme.warning }
                                QuickToggleBtn { icon: "⚙"; label: "Settings"; active: false; color: Theme.textMuted }
                                QuickToggleBtn { icon: "🔕"; label: "DND"; active: false; color: Theme.error }
                                QuickToggleBtn { icon: "🌙"; label: "Night"; active: false; color: Theme.tertiary }
                                QuickToggleBtn { icon: "🔋"; label: "Battery"; active: false; color: Theme.success }
                                QuickToggleBtn { icon: "✂"; label: "Snip"; active: false; color: Theme.primary }
                            }
                        }
                    }
                }
            }
        }
    }
}