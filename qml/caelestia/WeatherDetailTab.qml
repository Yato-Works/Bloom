import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root

    readonly property string fontDisplay: "Rubik"

    function weatherGlyph(name: string): string {
        const c = name.toLowerCase();
        if (c.includes("clear") || c.includes("sunny") || c.includes("晴")) return "☀️";
        if (c.includes("partly") || c.includes("時々")) return "⛅";
        if (c.includes("overcast") || c.includes("cloud") || c.includes("くもり")) return "☁️";
        if (c.includes("fog") || c.includes("mist")) return "🌫️";
        if (c.includes("drizzle")) return "🌦️";
        if (c.includes("rain") || c.includes("雨")) return "🌧️";
        if (c.includes("snow") || c.includes("雪")) return "❄️";
        if (c.includes("thunder")) return "⛈️";
        return "🌤️";
    }

    implicitWidth: 880
    implicitHeight: 560

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Top Hero Weather Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            radius: 30
            color: Colours.m3surfaceContainerLow
            border.width: 1
            border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 24

                // Giant Weather Emoji / Icon
                Text {
                    text: root.weatherGlyph(weatherService.condition)
                    font.pixelSize: 84
                    Layout.alignment: Qt.AlignVCenter
                }

                // Temp & Condition
                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    RowLayout {
                        spacing: 12
                        Text {
                            text: weatherService.temperature === "" ? "23°" : weatherService.temperature
                            color: Colours.m3onSurface
                            font.family: root.fontDisplay
                            font.pixelSize: 52
                            font.weight: Font.DemiBold
                        }
                        Rectangle {
                            height: 28
                            radius: 14
                            color: Qt.alpha(Colours.m3primaryContainer, 0.8)
                            implicitWidth: condText.implicitWidth + 18

                            Text {
                                id: condText
                                anchors.centerIn: parent
                                text: weatherService.condition === "" ? "Partly cloudy" : weatherService.condition
                                color: Colours.m3onPrimaryContainer
                                font.family: root.fontDisplay
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Text {
                        text: "📍 " + (weatherService.city === "" ? "Current location" : weatherService.city)
                        color: Colours.m3onSurfaceVariant
                        font.family: root.fontDisplay
                        font.pixelSize: 15
                    }

                    Text {
                        text: qsTr("Live meteorological data updated at ") + (weatherService.updatedAt === "" ? "--:--" : weatherService.updatedAt)
                        color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7)
                        font.family: root.fontDisplay
                        font.pixelSize: 11
                    }
                }

                // Reload Button
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: reloadHover.hovered ? Qt.alpha(Colours.m3primary, 0.2) : Colours.m3surfaceContainerHighest
                    border.width: 1
                    border.color: Qt.alpha(Colours.m3outlineVariant, 0.3)
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight

                    HoverHandler { id: reloadHover }
                    TapHandler { onTapped: weatherService.reload() }

                    Text {
                        anchors.centerIn: parent
                        text: "🔄"
                        font.pixelSize: 16
                    }
                }
            }
        }

        // Detailed Metrics Grid (Wind, Humidity, Pressure, Air Quality)
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: 14
            columnSpacing: 14

            // 1. Wind
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 24
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text { text: "🌬"; font.pixelSize: 18 }
                        Text { text: qsTr("Wind Speed"); color: Colours.m3onSurfaceVariant; font.pixelSize: 12; font.weight: Font.Medium }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: weatherService.wind === "" ? "3.2 km/h" : weatherService.wind
                        color: Colours.m3onSurface
                        font.family: root.fontDisplay
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: qsTr("Gentle breeze"); color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7); font.pixelSize: 11
                    }
                }
            }

            // 2. Humidity
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 24
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text { text: "💧"; font.pixelSize: 18 }
                        Text { text: qsTr("Humidity"); color: Colours.m3onSurfaceVariant; font.pixelSize: 12; font.weight: Font.Medium }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: weatherService.humidity === "" ? "56%" : weatherService.humidity
                        color: Colours.m3onSurface
                        font.family: root.fontDisplay
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: qsTr("Comfortable range"); color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7); font.pixelSize: 11
                    }
                }
            }

            // 3. Pressure
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 24
                color: Colours.m3surfaceContainerLow
                border.width: 1
                border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        Text { text: "🌡"; font.pixelSize: 18 }
                        Text { text: qsTr("Pressure"); color: Colours.m3onSurfaceVariant; font.pixelSize: 12; font.weight: Font.Medium }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: weatherService.pressure === "" ? "1013 hPa" : weatherService.pressure
                        color: Colours.m3onSurface
                        font.family: root.fontDisplay
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: qsTr("Standard atmospheric pressure"); color: Qt.alpha(Colours.m3onSurfaceVariant, 0.7); font.pixelSize: 11
                    }
                }
            }
        }
    }
}
