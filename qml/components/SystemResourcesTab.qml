import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text { text: "System Resources"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 16
            columnSpacing: 16

            ResourceCard { title: "CPU"; icon: "🖥"; value: "34%"; subtitle: "8 cores • 4.2 GHz"; color: Theme.primary }
            ResourceCard { title: "Memory"; icon: "🧠"; value: "12.4 / 32 GB"; subtitle: "62% used"; color: Theme.accent }
            ResourceCard { title: "GPU"; icon: "🎮"; value: "RTX 4080"; subtitle: "45% • 68°C"; color: Theme.tertiary }
            ResourceCard { title: "Storage"; icon: "💾"; value: "1.2 / 4 TB"; subtitle: "28% used"; color: Theme.warning }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            columns: 2
            rowSpacing: 16
            columnSpacing: 16

            IOGraphCard { title: "Network I/O"; color: Theme.primary; unit: "MB/s" }
            IOGraphCard { title: "Disk I/O"; color: Theme.accent; unit: "MB/s" }
        }
    }
}
