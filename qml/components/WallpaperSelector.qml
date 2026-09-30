import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    visible: false
    anchors.fill: parent
    z: 1600

    signal closed()

    function open() {
        if (typeof wallpaperService !== "undefined" && wallpaperService) {
            wallpaperService.refreshWallpapers();
        }
        root.visible = true;
    }

    function close() {
        root.visible = false;
        root.closed();
    }

    // Modal floating dim backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Modal Card
    GlassPanel {
        id: card
        width: Math.min(720, parent.width - 48)
        height: Math.min(560, parent.height - 48)
        anchors.centerIn: parent
        radius: 28
        tint: Colours.m3surfaceContainerLowest
        border.color: Qt.alpha(Colours.m3outlineVariant, 0.35)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    width: 40; height: 40; radius: 14
                    color: Qt.alpha(Colours.m3primaryContainer, 0.5)
                    border.width: 1
                    border.color: Qt.alpha(Colours.m3primary, 0.3)
                    BloomIcon {
                        anchors.centerIn: parent
                        text: "wallpaper"
                        color: Colours.m3primary
                        font.pixelSize: 22
                    }
                }
                Column {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "壁紙の変更 (Wallpaper Manager)"
                        color: Colours.m3onSurface
                        font.family: "Rubik, 'Segoe UI Variable Display', sans-serif"
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "壁紙を選ぶと、シェルカラーパレットも Material Design 3 にリアルタイム連動します"
                        color: Colours.m3onSurfaceVariant
                        font.family: "Rubik, 'Segoe UI Variable Display', sans-serif"
                        font.pixelSize: 11
                    }
                }

                // Open folder button
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: folderHover.hovered ? Qt.alpha(Colours.m3primary, 0.2) : Qt.alpha(Colours.m3surfaceContainerHigh, 0.6)
                    border.width: 1
                    border.color: folderHover.hovered ? Colours.m3primary : "transparent"
                    Behavior on color { ColorAnimation { duration: 140 } }
                    BloomIcon {
                        anchors.centerIn: parent
                        text: "folder_open"
                        color: Colours.m3onSurface
                        font.pixelSize: 16
                    }
                    ToolTip.visible: folderHover.hovered
                    ToolTip.text: "壁紙フォルダを開く"
                    HoverHandler { id: folderHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            if (typeof wallpaperService !== "undefined" && wallpaperService) {
                                wallpaperService.openFolder();
                            }
                        }
                    }
                }

                // Close button
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: closeHover.hovered ? Qt.alpha(Colours.m3error, 0.25) : Qt.alpha(Colours.m3surfaceContainerHigh, 0.6)
                    border.width: 1
                    border.color: closeHover.hovered ? Colours.m3error : "transparent"
                    Behavior on color { ColorAnimation { duration: 140 } }
                    BloomIcon {
                        anchors.centerIn: parent
                        text: "close"
                        color: Colours.m3onSurface
                        font.pixelSize: 16
                    }
                    HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: root.close() }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(Colours.m3outlineVariant, 0.2) }

            // Wallpapers Grid / List
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 214
                cellHeight: 140
                model: (typeof wallpaperService !== "undefined" && wallpaperService && wallpaperService.wallpapers) ? wallpaperService.wallpapers : []

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    readonly property string itemPath: (modelData && modelData.path) ? modelData.path : (typeof modelData === "string" ? modelData : "")
                    readonly property string itemName: (modelData && modelData.name) ? modelData.name : ("Wallpaper " + (index + 1))
                    readonly property bool isCurrent: {
                        if (typeof wallpaperService === "undefined" || !wallpaperService) return false;
                        var cur = wallpaperService.currentWallpaperPath();
                        return cur.length > 0 && itemPath.toLowerCase() === cur.toLowerCase();
                    }

                    width: 202
                    height: 128
                    radius: 16
                    color: Colours.m3surfaceContainerHigh
                    border.width: isCurrent ? 2 : (itemHover.hovered ? 1.5 : 1)
                    border.color: isCurrent ? Colours.m3primary : (itemHover.hovered ? Qt.alpha(Colours.m3primary, 0.6) : Qt.alpha(Colours.m3outlineVariant, 0.25))
                    clip: true
                    scale: itemHover.hovered ? 1.03 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    Image {
                        anchors.fill: parent
                        source: itemPath !== "" ? (itemPath.indexOf(":") === 1 ? "file:///" + itemPath : itemPath) : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        opacity: isCurrent ? 1.0 : (itemHover.hovered ? 0.96 : 0.84)
                        Behavior on opacity { NumberAnimation { duration: 140 } }
                    }

                    // Specular top highlight
                    Rectangle {
                        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                        anchors.margins: 1; height: 1; radius: parent.radius; color: Qt.rgba(1, 1, 1, 0.22)
                    }

                    // Bottom title scrim
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 28
                        color: Qt.rgba(0, 0, 0, 0.65)
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            Text {
                                text: itemName
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.weight: isCurrent ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            BloomIcon {
                                visible: isCurrent
                                text: "check_circle"
                                color: Colours.m3primary
                                font.pixelSize: 14
                            }
                        }
                    }

                    HoverHandler { id: itemHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            if (typeof wallpaperService !== "undefined" && wallpaperService) {
                                wallpaperService.setWallpaper(itemPath);
                            }
                        }
                    }
                }
            }

            // Path manual input row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 20
                    color: Qt.alpha(Colours.m3surfaceContainerLowest, 0.9)
                    border.width: 1
                    border.color: pathInput.activeFocus ? Colours.m3primary : Qt.alpha(Colours.m3outlineVariant, 0.3)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 8

                        BloomIcon { text: "link"; color: Colours.m3primary; font.pixelSize: 16 }
                        TextField {
                            id: pathInput
                            Layout.fillWidth: true
                            placeholderText: "任意の画像ファイルパスを入力して適用 (C:/path/to/image.jpg)..."
                            placeholderTextColor: Colours.m3onSurfaceVariant
                            color: Colours.m3onSurface
                            font.pixelSize: 12
                            background: null
                            selectByMouse: true
                            onAccepted: {
                                if (text.trim() !== "" && typeof wallpaperService !== "undefined" && wallpaperService) {
                                    wallpaperService.setWallpaper(text.trim());
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 76; height: 40; radius: 20
                    color: applyHover.hovered ? Colours.m3primary : Qt.alpha(Colours.m3primary, 0.85)
                    Text {
                        anchors.centerIn: parent
                        text: "適 用"
                        color: Colours.m3onPrimary
                        font.family: "Rubik, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }
                    HoverHandler { id: applyHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            if (pathInput.text.trim() !== "" && typeof wallpaperService !== "undefined" && wallpaperService) {
                                wallpaperService.setWallpaper(pathInput.text.trim());
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            root.close();
            event.accepted = true;
        }
    }
}