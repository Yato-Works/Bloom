import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 120

    ColumnLayout {
        spacing: 10

        RowLayout { Layout.fillWidth: true
            Text { text: "⚡ Power Profile"; color: Theme.text; font.pixelSize: 14; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Text { text: "No battery detected"; color: Theme.textMuted; font.pixelSize: 11 }
        }

        RowLayout { Layout.fillWidth: true; spacing: 8
            ProfileBtn { label: "Power Saver"; icon: "🍃"; active: false; color: Theme.success; onClicked: {} }
            ProfileBtn { label: "Balanced"; icon: "⚖"; active: true; color: Theme.primary; onClicked: {} }
            ProfileBtn { label: "Performance"; icon: "🚀"; active: false; color: Theme.warning; onClicked: {} }
        }
    }
}