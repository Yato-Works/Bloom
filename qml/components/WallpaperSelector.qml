import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

GlassPanel {
    id: root
    tint: Theme.surfaceContainer
    showShadow: false
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.paddingLG
        spacing: Theme.spacingLG
        
        Row {
            spacing: Theme.spacingXS
            Text { text: "🖼"; color: Theme.primary; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "デスクトップ背景の設定"
                color: Theme.text
                font.pixelSize: Theme.fontXL
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Text {
            text: "ローカルストレージから壁紙画像を選択します。"
            color: Theme.textMuted
            font.pixelSize: Theme.fontSM
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 54
            color: Qt.rgba(1, 1, 1, 0.03)
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            radius: Theme.radiusMedium
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingSM
                
                TextField {
                    id: pathField
                    Layout.fillWidth: true
                    placeholder: "壁紙のパス..."
                    background: Rectangle { color: "transparent" }
                    font.pixelSize: Theme.fontMD
                    color: Theme.text
                    onAccepted: wallpaperService.setWallpaper(text)
                }
                
                Button {
                    text: "適用"
                    flat: true
                    font.pixelSize: Theme.fontSM
                    font.weight: Font.DemiBold
                    contentItem: Text {
                        text: "適 用"
                        color: Theme.onPrimary
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: Theme.radiusFull
                        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                        implicitWidth: 72
                        implicitHeight: 32
                    }
                    onClicked: wallpaperService.setWallpaper(pathField.text)
                }
            }
        }
        
        Text {
            text: "適用するとWindowsの設定が即座に反映されます。"
            color: Theme.onSurfaceMuted
            font.pixelSize: Theme.fontXS
        }
        
        Item { Layout.fillHeight: true }
    }
}