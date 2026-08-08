import QtQuick
import QtQuick.Layouts
import Bloom

RowLayout {
    spacing: 24
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    Rectangle {
        implicitWidth: 64
        implicitHeight: 64
        radius: 20
        color: Qt.rgba(1.0, 0.7, 0.3, 0.15)
        border.width: 1
        border.color: Qt.rgba(1.0, 0.7, 0.3, 0.35)

        Text {
            anchors.centerIn: parent
            text: (weatherService && weatherService.weatherIcon) ? weatherService.weatherIcon : "🌤️"
            font.pixelSize: 36
        }
    }

    ColumnLayout {
        spacing: 4
        Text {
            text: (weatherService && weatherService.temperature) ? weatherService.temperature : "--°"
            color: "#ffffff"
            font.pixelSize: 32
            font.weight: Font.Bold
        }
        Text {
            text: ((weatherService && weatherService.conditionText) ? weatherService.conditionText : "—") + " · 湿度 " + ((weatherService && weatherService.humidity) ? weatherService.humidity : "—")
            color: Qt.rgba(1, 1, 1, 0.65)
            font.pixelSize: Theme.fontMD
        }
    }
}