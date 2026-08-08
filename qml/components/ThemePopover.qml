import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    visible: false
    anchors.fill: parent
    z: 1500

    signal closed()

    property int selectedThemeIndex: 0

    readonly property var themes: [
        { name: "Bloom Dark",      id: "bloom dark",      icon: "🌙", accent: "#A7F3D0", surface: "#0D1218", bg: "#080A0E" },
        { name: "Bloom Light",     id: "bloom light",     icon: "☀️", accent: "#009688", surface: "#FFFFFF", bg: "#F5F5F7" },
        { name: "Cyberpunk Mint",  id: "cyberpunk mint",  icon: "⚡", accent: "#A7F3D0", surface: "#0C141F", bg: "#050A10" },
        { name: "Tokyo Night",     id: "tokyo night",     icon: "🌃", accent: "#BB9AF7", surface: "#1A1B26", bg: "#16161E" },
        { name: "Mocha",           id: "mocha",           icon: "☕", accent: "#CBA6F7", surface: "#11131C", bg: "#0B0D14" },
        { name: "Macchiato",       id: "macchiato",       icon: "🧋", accent: "#F5BDE6", surface: "#1E2030", bg: "#181926" },
        { name: "Frappé",          id: "frappé",           icon: "🥤", accent: "#CA9EE6", surface: "#303446", bg: "#292C3C" },
        { name: "Rose Pine",       id: "rose pine",       icon: "🌹", accent: "#C4A7E7", surface: "#1F1D2E", bg: "#191724" },
        { name: "Nord Frost",      id: "nord frost",      icon: "❄️", accent: "#B48EAD", surface: "#3B4252", bg: "#2E3440" },
        { name: "Emerald Aurora",  id: "emerald aurora",  icon: "❇️", accent: "#FF79C6", surface: "#152A2D", bg: "#0D1B1E" },
        { name: "Latte",           id: "latte",           icon: "🥛", accent: "#8839EF", surface: "#EFF1F5", bg: "#E6E9EF" }
    ]

    function open() {
        root.visible = true
        // Find current theme index (match by id or name, case-insensitive)
        var current = (Theme.themeName || "").toLowerCase()
        selectedThemeIndex = 0
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].id === current || themes[i].name.toLowerCase() === current) {
                selectedThemeIndex = i
                break
            }
        }
        listView.currentIndex = selectedThemeIndex
        listView.positionViewAtIndex(selectedThemeIndex, ListView.Center)
    }

    function close() {
        root.visible = false
        root.closed()
    }

    function applyTheme(index) {
        if (index >= 0 && index < themes.length) {
            Theme.setThemeByName(themes[index].name)
            selectedThemeIndex = index
        }
    }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Floating Theme Selection Card
    GlassPanel {
        id: card
        width: 520
        height: Math.min(680, contentColumn.implicitHeight + 48)
        anchors.centerIn: parent
        scale: root.visible ? 1.0 : 0.92
        opacity: root.visible ? 1.0 : 0.0
        radius: 28
        elevated: true

        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35)

                    Text { anchors.centerIn: parent; text: "🎨"; font.pixelSize: 18 }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Theme Selector"
                        color: Theme.text
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    Text {
                        text: "Choose your Material You color palette"
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 16
                    color: closeHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Text { anchors.centerIn: parent; text: "✕"; color: Theme.textMuted; font.pixelSize: 14 }

                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.close()
                    }
                }
            }

            // Search / Filter
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 20
                color: Qt.rgba(0, 0, 0, 0.25)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    Text { text: "🔍"; font.pixelSize: 14; color: Theme.textMuted }
                    TextInput {
                        id: filterInput
                        Layout.fillWidth: true
                        placeholderText: "Filter themes..."
                        color: Theme.text
                        font.pixelSize: 13
                    }
                }
            }

            // Theme List
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    spacing: 8
                    model: themes
                    currentIndex: selectedThemeIndex

                    // Client-side filtering
                    property var filteredModel: themes

                    onCountChanged: {
                        // Apply filter
                        var filter = filterInput.text.toLowerCase()
                        if (filter === "") {
                            filteredModel = themes
                        } else {
                            filteredModel = []
                            for (var i = 0; i < themes.length; i++) {
                                var t = themes[i]
                                if (t.name.toLowerCase().includes(filter) || t.id.includes(filter)) {
                                    filteredModel.push(t)
                                }
                            }
                        }
                    }

                    delegate: Rectangle {
                        id: themeItem
                        width: listView.width
                        implicitHeight: 72
                        radius: 16
                        color: {
                            if (index === listView.currentIndex) return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.22)
                            if (mouseArea.containsMouse) return Qt.rgba(1, 1, 1, 0.06)
                            return Qt.rgba(1, 1, 1, 0.03)
                        }
                        border.width: index === listView.currentIndex ? 1.5 : (mouseArea.containsMouse ? 1 : 0)
                        border.color: index === listView.currentIndex ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 14

                            // Theme Preview Swatch
                            Rectangle {
                                id: swatch
                                implicitWidth: 48
                                implicitHeight: 48
                                radius: 12
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.12)

                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: modelData.bg }
                                    GradientStop { position: 0.5; color: modelData.surface }
                                    GradientStop { position: 1.0; color: modelData.accent }
                                }

                                // Accent indicator dot
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 4
                                    width: 12; height: 12; radius: 6
                                    color: modelData.accent
                                    border.width: 2
                                    border.color: modelData.bg
                                }
                            }

                            // Theme Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        text: modelData.name
                                        color: Theme.text
                                        font.pixelSize: 15
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: modelData.id
                                        color: Theme.textMuted
                                        font.pixelSize: 10
                                        font.family: "Monospace"
                                    }
                                }

                                RowLayout {
                                    spacing: 10
                                    // Color tokens preview
                                    RowLayout { spacing: 3
                                        Repeater {
                                            model: [modelData.bg, modelData.surface, modelData.accent]
                                            Rectangle {
                                                width: 18; height: 18; radius: 9
                                                color: modelData
                                                border.width: 1
                                                border.color: Qt.rgba(1, 1, 1, 0.1)
                                            }
                                        }
                                    }

                                    Text {
                                        text: index === listView.currentIndex ? "✓ Active" : "Click to apply"
                                        color: index === listView.currentIndex ? Theme.primary : Theme.textMuted
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            // Apply Button / Active Badge
                            Rectangle {
                                implicitWidth: applyBtnRow.implicitWidth + 16
                                implicitHeight: 28
                                radius: 14
                                color: index === listView.currentIndex
                                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.25)
                                    : (mouseArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18) : Qt.rgba(1, 1, 1, 0.05))
                                border.width: 1
                                border.color: index === listView.currentIndex ? Theme.primary : Qt.rgba(1, 1, 1, 0.1)

                                RowLayout {
                                    id: applyBtnRow
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: index === listView.currentIndex ? "✓" : "✦"
                                        color: index === listView.currentIndex ? Theme.primary : Theme.accent
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: index === listView.currentIndex ? "Active" : "Apply"
                                        color: index === listView.currentIndex ? Theme.primary : Theme.text
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                listView.currentIndex = index
                                root.applyTheme(index)
                            }
                            onEntered: listView.currentIndex = index
                        }
                    }
                }
            }

            // Footer Hint
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    text: "💡 Tip: Type in launcher \">theme cyberpunk\" to quick-switch"
                    color: Theme.textMuted
                    font.pixelSize: 10
                    font.italic: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Press ESC to close"
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
        } else if (event.key === Qt.Key_Down) {
            if (listView.currentIndex < listView.count - 1) {
                listView.currentIndex++
                listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            }
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            if (listView.currentIndex > 0) {
                listView.currentIndex--
                listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            }
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.applyTheme(listView.currentIndex)
            event.accepted = true
        }
    }
}