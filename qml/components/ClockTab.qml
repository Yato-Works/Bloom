import QtQuick
import QtQuick.Layouts
import Bloom

RowLayout {
    spacing: 32
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    ColumnLayout {
        spacing: 4
        Layout.alignment: Qt.AlignLeft

        Text {
            text: systemInfo.formattedTime !== "" ? systemInfo.formattedTime : "--:--"
            color: "#ffffff"
            font.pixelSize: 56
            font.weight: Font.Light
            font.family: "Segoe UI Light"
        }
        RowLayout {
            spacing: 10
            Rectangle {
                implicitWidth: dateTxt.implicitWidth + 16
                implicitHeight: 24
                radius: 12
                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)

                Text {
                    id: dateTxt
                    anchors.centerIn: parent
                    text: systemInfo.formattedDate !== "" ? systemInfo.formattedDate : "Loading..."
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }

            Text {
                text: "Welcome back to Bloom Desktop"
                color: Qt.rgba(1, 1, 1, 0.6)
                font.pixelSize: 12
            }
        }
    }
}
