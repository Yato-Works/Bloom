import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

// Full-screen settings modal: pick a color theme — panel surfaces follow the
// wallpaper palette automatically.
Item {
    id: root
    visible: false
    anchors.fill: parent
    z: 1500

    signal closed()

    property int selectedThemeIndex: 0


    readonly property var colorThemes: [
        { name: "Bloom Dark", accent: "#80D8FF" },
        { name: "Bloom Light", accent: "#009688" },
        { name: "Cyberpunk Mint", accent: "#A7F3D0" },
        { name: "Tokyo Night", accent: "#BB9AF7" },
        { name: "Mocha", accent: "#CBA6F7" },
        { name: "Macchiato", accent: "#F5BDE6" },
        { name: "Frappé", accent: "#CA9EE6" },
        { name: "Rose Pine", accent: "#C4A7E7" },
        { name: "Nord Frost", accent: "#B48EAD" },
        { name: "Emerald Aurora", accent: "#FF79C6" },
        { name: "Latte", accent: "#8839EF" }
    ]

    function open() {
        root.visible = true
        root.forceActiveFocus()
        selectedThemeIndex = themeIndexForCurrent()
    }

    function close() {
        root.visible = false
        root.closed()
    }

    function themeIndexForCurrent() {
        var t = (Theme.themeName || "").toLowerCase()
        for (var i = 0; i < colorThemes.length; i++)
            if (colorThemes[i].name.toLowerCase() === t) return i
        return 0
    }

    function applyTheme(index) {
        if (index >= 0 && index < colorThemes.length) {
            Theme.setThemeByName(colorThemes[index].name)
            selectedThemeIndex = index
        }
    }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    // Floating Settings Card
    GlassPanel {
        id: card
        width: 740
        height: Math.min(700, contentCol.implicitHeight + 48)
        anchors.centerIn: parent
        scale: root.visible ? 1.0 : 0.92
        opacity: root.visible ? 1.0 : 0.0
        radius: 28
        elevated: true

        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    implicitWidth: 44
                    implicitHeight: 44
                    radius: 14
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                    Text { anchors.centerIn: parent; text: "⚙️"; font.pixelSize: 20 }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "Settings / 設定"; color: Theme.text; font.pixelSize: 20; font.weight: Font.Bold }
                    Text { text: "2つのシェル デザイン（プロフィール）と配色を切り替えられます"; color: Theme.textMuted; font.pixelSize: 11 }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: closeLabel.implicitWidth + 26
                    implicitHeight: 32
                    radius: 16
                    color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)
                    Text { id: closeLabel; anchors.centerIn: parent; text: "✕ Close"; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
                    MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                }
            }


            // Section: Color Theme
            Text {
                text: "COLOR THEME ── 配色"
                color: Theme.primary
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.2
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: colorThemes
                    Rectangle {
                        width: chipText.implicitWidth + 24
                        height: 30
                        radius: 15
                        color: index === root.selectedThemeIndex
                               ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                               : Qt.rgba(1, 1, 1, 0.06)
                        border.width: index === root.selectedThemeIndex ? 1.5 : 1
                        border.color: index === root.selectedThemeIndex ? Theme.primary : Qt.rgba(1, 1, 1, 0.12)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: colorThemes[index].accent
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.3)
                            }
                            Text {
                                id: chipText
                                text: colorThemes[index].name
                                color: index === root.selectedThemeIndex ? Theme.text : Theme.textMuted
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyTheme(index)
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Footer hints
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    text: "💡 ランチャー / コマンド バーで \">settings\" と入力しても開けます"
                    color: Theme.textMuted
                    font.pixelSize: 10
                    font.italic: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "ESC = 閉じる"
                    color: Theme.textMuted
                    font.pixelSize: 10
                }
            }
        }
    }

    // Keyboard navigation
    Keys.onPressed: function(event) {
        if (!root.visible) return
        if (event.key === Qt.Key_Escape) {
            root.close()
            event.accepted = true
        }
    }
}
