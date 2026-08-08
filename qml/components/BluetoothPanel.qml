import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 140

    ColumnLayout {
        spacing: 12

        RowLayout { Layout.fillWidth: true; spacing: 10
            Rectangle {
                implicitWidth: 40; implicitHeight: 40; radius: 12
                color: Qt.rgba(0.3, 0.5, 1.0, 0.18)
                border.width: 1
                border.color: Qt.rgba(0.3, 0.5, 1.0, 0.4)
                Text { anchors.centerIn: parent; text: "🌐"; font.pixelSize: 16 }
            }
            ColumnLayout {
                Text { text: "Bluetooth"; color: Theme.text; font.pixelSize: 14; font.weight: Font.Bold }
                Text { text: "WH-1000XM4 • Connected"; color: Theme.textMuted; font.pixelSize: 11 }
            }
            Item { Layout.fillWidth: true }
            SwitchButton { checked: true; onToggled: {} }
        }

        RowLayout { Layout.fillWidth: true; spacing: 10
            Item { Layout.fillWidth: true }
            Text { text: "Discovering"; color: Theme.textMuted; font.pixelSize: 11 }
            SwitchButton { checked: false; onToggled: {} }
            Text { text: "Open Settings"; color: Theme.primary; font.pixelSize: 11; font.weight: Font.DemiBold }
        }

        RowLayout { Layout.fillWidth: true; spacing: 8
            Item { Layout.fillWidth: true }
            BluetoothDevice { name: "WH-1000XM4"; connected: true; battery: "85%" }
            BluetoothDevice { name: "iPhone 15 Pro"; connected: false; battery: "72%" }
            BluetoothDevice { name: "MX Master 3S"; connected: true; battery: "91%" }
        }
    }
}