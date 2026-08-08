import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.8)
        border.width: 1
        border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.15)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text { text: "📅 Calendar & Audio"; color: Theme.text; font.pixelSize: 16; font.weight: Font.Bold }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 280
                    radius: 20
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text { text: "August 2026"; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }

                        GridLayout {
                            columns: 7
                            rowSpacing: 6
                            columnSpacing: 6

                            Repeater {
                                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                Text { text: modelData; color: Theme.textMuted; font.pixelSize: 10; font.weight: Font.DemiBold; Layout.alignment: Qt.AlignHCenter }
                            }

                            Repeater { model: 4; Text { text: ""; Layout.alignment: Qt.AlignHCenter } }

                            Repeater {
                                model: 31
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 32
                                    radius: 8
                                    color: index === 3 ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : "transparent"
                                    border.width: index === 3 ? 1 : 0
                                    border.color: Theme.primary

                                    Text {
                                        anchors.centerIn: parent
                                        text: index + 1
                                        color: index === 3 ? Theme.primary : Theme.text
                                        font.pixelSize: 12
                                        font.weight: index === 3 ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 140
                    radius: 20
                    color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(Theme.tertiary.r, Theme.tertiary.g, Theme.tertiary.b, 0.2)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 4

                        Text { text: "SPECTRUM"; color: Theme.tertiary; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1 }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent
                                spacing: 2
                                Layout.alignment: Qt.AlignBottom

                                Repeater {
                                    model: 16
                                    Rectangle {
                                        id: specBar
                                        Layout.fillWidth: true
                                        height: cavaService && cavaService.bars && cavaService.bars.length > index * 2
                                            ? Math.max(4, cavaService.bars[index * 2] * 180)
                                            : Math.max(4, (Math.random() * 100 + 20))
                                        radius: 2
                                        color: Qt.hsla(0.55 + (index * 0.02), 0.8, 0.6, 0.9)
                                        anchors.bottom: parent.bottom
                                        Behavior on height { NumberAnimation { duration: 60 } }
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
