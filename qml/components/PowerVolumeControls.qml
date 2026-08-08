import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 180

    ColumnLayout {
        spacing: 14

        RowLayout { Layout.fillWidth: true
            Text { text: "🔊 Volume"; color: Theme.text; font.pixelSize: 14; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Text { text: "72%"; color: Theme.primary; font.pixelSize: 13; font.weight: Font.Bold }
        }

        Slider {
            id: volumeSlider
            Layout.fillWidth: true
            from: 0; to: 100; value: 72

            background: Rectangle { implicitHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                Rectangle { height: 6; radius: 3; color: Theme.primary; width: parent.width * volumeSlider.visualPosition }
            }
            handle: Rectangle { implicitWidth: 18; implicitHeight: 18; radius: 9; color: "#fff"; border.width: 2; border.color: Theme.primary }
        }

        RowLayout { Layout.fillWidth: true; spacing: 10
            Text { text: "💡 Brightness"; color: Theme.text; font.pixelSize: 14; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Text { text: "85%"; color: Theme.warning; font.pixelSize: 13; font.weight: Font.Bold }
        }

        Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            from: 10; to: 100; value: 85

            background: Rectangle { implicitHeight: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.1)
                Rectangle { height: 6; radius: 3; color: Theme.warning; width: parent.width * brightnessSlider.visualPosition }
            }
            handle: Rectangle { implicitWidth: 18; implicitHeight: 18; radius: 9; color: "#fff"; border.width: 2; border.color: Theme.warning }
        }

        RowLayout { Layout.fillWidth: true; spacing: 10
            PowerActionBtn { icon: "🔒"; label: "Lock"; color: Theme.text; onClicked: shellController.toggleLock() }
            PowerActionBtn { icon: "💤"; label: "Sleep"; color: Theme.warning; onClicked: {} }
            PowerActionBtn { icon: "🔄"; label: "Restart"; color: Theme.accent; onClicked: {} }
            PowerActionBtn { icon: "⏻"; label: "Shutdown"; color: Theme.error; onClicked: {} }
        }
    }
}