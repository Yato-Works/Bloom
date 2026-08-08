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
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Text { text: "☁"; font.pixelSize: 28 }
                Text { text: "Weather"; color: Theme.text; font.pixelSize: 18; font.weight: Font.Bold }
                Item { Layout.fillWidth: true }
                Text { text: "📍 Tokyo, JP"; color: Theme.textMuted; font.pixelSize: 12 }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 160
                radius: 20
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 30

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "🌧"; font.pixelSize: 72 }
                        Text { text: "Drizzle"; color: Theme.text; font.pixelSize: 18; font.weight: Font.DemiBold }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "24°C"; color: Theme.text; font.pixelSize: 56; font.weight: Font.Bold; font.family: "Monospace" }
                        RowLayout { spacing: 12
                            Text { text: "Feels 23°C"; color: Theme.textMuted; font.pixelSize: 13 }
                            Text { text: "Humidity 85%"; color: Theme.textMuted; font.pixelSize: 13 }
                            Text { text: "Wind 12 km/h"; color: Theme.textMuted; font.pixelSize: 13 }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Repeater {
                    model: [
                        { day: "Today", icon: "🌧", high: "24°", low: "19°" },
                        { day: "Tomorrow", icon: "⛈", high: "22°", low: "18°" },
                        { day: "Fri", icon: "☀", high: "27°", low: "20°" },
                        { day: "Sat", icon: "🌤", high: "26°", low: "19°" },
                        { day: "Sun", icon: "🌧", high: "23°", low: "17°" }
                    ]
                    ForecastDayItem { day: modelData.day; icon: modelData.icon; high: modelData.high; low: modelData.low }
                }
            }
        }
    }
}
