import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: launcherRoot
    visible: false
    anchors.fill: parent
    z: 1400

    signal closed()
    signal openCalculatorRequested()

    property var appList: []
    property var cliList: []
    property var mathResult: ({ valid: false })
    property int selectedIndex: 0

    function open(initialQuery) {
        shellController.armPermanent(true)
        launcherRoot.visible = true
        searchInput.text = initialQuery !== undefined ? initialQuery : ""
        searchInput.forceActiveFocus()
        updateSearch()
    }

    function close() {
        shellController.armPermanent(false)
        launcherRoot.visible = false
        searchInput.text = ""
        launcherRoot.closed()
    }

    function updateSearch() {
        var query = searchInput.text.trim()
        selectedIndex = 0

        // 1. Math evaluation test
        mathResult = appLauncherService.evaluateMath(query)

        // 2. CLI commands test (if starts with '>')
        if (query.startsWith(">")) {
            cliList = appLauncherService.searchCliCommands(query)
            appList = []
        } else {
            cliList = []
            appList = appLauncherService.searchApps(query)
        }
    }

    function executeSelected() {
        var query = searchInput.text.trim().toLowerCase()

        if (mathResult.valid) {
            launcherRoot.openCalculatorRequested()
            launcherRoot.close()
            return
        }

        // Fast shortcut for 'c', 'calc', 'calculator', '>c', '>calc', '>calculator'
        if (query === "c" || query === "calc" || query === "calculator" || query === ">c" || query === ">calc" || query === ">calculator") {
            launcherRoot.openCalculatorRequested()
            launcherRoot.close()
            return
        }

        if (searchInput.text.trim().startsWith(">")) {
            if (cliList.length > 0 && selectedIndex >= 0 && selectedIndex < cliList.length) {
                var cmd = cliList[selectedIndex]
                executeCmd(cmd.name)
            }
            return
        }

        if (appList.length > 0 && selectedIndex >= 0 && selectedIndex < appList.length) {
            var app = appList[selectedIndex]
            if (app.exec === "bloom-calculator" || app.name.toLowerCase().indexOf("calc") !== -1) {
                launcherRoot.openCalculatorRequested()
            } else {
                appLauncherService.launchApp(app.exec)
            }
            launcherRoot.close()
        }
    }

    function executeCmd(cmdName) {
        var c = cmdName.toLowerCase()
        if (c === ">calculator" || c === ">calc" || c === ">c") {
            launcherRoot.openCalculatorRequested()
        } else if (c === ">theme" || c === ">settings") {
            // Open the settings modal (profiles + color themes) via appLauncherService
            appLauncherService.requestSettings()
        } else if (c === ">lock") {
            shellController.toggleLock()
        } else if (c === ">wallpaper") {
            wallpaperService.nextWallpaper()
        } else if (c === ">folder") {
            wallpaperService.openFolder()
        } else if (c === ">snip") {
            appLauncherService.launchApp("snippingtool.exe")
        }
        launcherRoot.close()
    }

    // Modal Floating Dim Backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: launcherRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: launcherRoot.close()
        }
    }

    // Bloom-shell Floating Pill-Bar Launcher Window
    GlassPanel {
        id: launcherCard
        width: 640
        height: Math.min(540, launcherColumn.implicitHeight + 36)
        anchors.centerIn: parent
        scale: launcherRoot.visible ? 1.0 : 0.93
        opacity: launcherRoot.visible ? 1.0 : 0.0
        radius: 28

        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        ColumnLayout {
            id: launcherColumn
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Bloom Pill Search Bar Header
            Rectangle {
                Layout.fillWidth: true
                height: 54
                radius: 27
                color: Qt.rgba(0.06, 0.08, 0.14, 0.9)
                border.width: 1.5
                border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.12)

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    Text {
                        text: searchInput.text.startsWith(">") ? "⚡" : "🔍"
                        font.pixelSize: 18
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        placeholderText: "Search apps or type 'c' / '>calculator', or enter math (e.g. 12 * 45)..."
                        placeholderTextColor: "#6c7086"
                        color: "#cdd6f4"
                        font.pixelSize: 15
                        background: null
                        selectByMouse: true

                        onTextChanged: launcherRoot.updateSearch()

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape) {
                                launcherRoot.close()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                var maxIdx = searchInput.text.startsWith(">") ? cliList.length - 1 : appList.length - 1
                                if (selectedIndex < maxIdx) selectedIndex++
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                if (selectedIndex > 0) selectedIndex--
                                event.accepted = true
                            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                launcherRoot.executeSelected()
                                event.accepted = true
                            }
                        }
                    }

                    // Bloom Style Enter Hint Pill
                    Rectangle {
                        implicitWidth: enterHintRow.implicitWidth + 14
                        implicitHeight: 26
                        radius: 13
                        color: searchInput.text.trim() !== "" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: searchInput.text.trim() !== "" ? Theme.accent : Qt.rgba(1, 1, 1, 0.1)

                        RowLayout {
                            id: enterHintRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "↵"; color: "#ffffff"; font.pixelSize: 11; font.weight: Font.Bold }
                            Text { text: "Launch"; color: "#cdd6f4"; font.pixelSize: 10; font.weight: Font.DemiBold }
                        }
                    }

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#a6adc8"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: launcherRoot.close()
                        }
                    }
                }
            }

            // Real-time Math Evaluation Card (if valid)
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 14
                visible: mathResult.valid
                color: Qt.rgba(0.2, 0.45, 0.35, 0.35)
                border.width: 1
                border.color: Qt.rgba(0.4, 0.8, 0.6, 0.5)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "🧮"
                        font.pixelSize: 20
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Math Expression Evaluated"
                            color: "#a6e3a1"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: mathResult.expression + " = " + mathResult.result
                            color: "#ffffff"
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        height: 28
                        implicitWidth: 100
                        radius: 8
                        color: Qt.rgba(0.3, 0.7, 0.5, 0.4)

                        Text {
                            anchors.centerIn: parent
                            text: "Open Calc ↵"
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                launcherRoot.openCalculatorRequested()
                                launcherRoot.close()
                            }
                        }
                    }
                }
            }

            // Category & Header Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: catRow.implicitWidth + 14
                    implicitHeight: 22
                    radius: 11
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)

                    RowLayout {
                        id: catRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: searchInput.text.startsWith(">") ? "⚡ SYSTEM COMMANDS" : "🚀 APPLICATIONS"
                            color: Theme.accent
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Press ESC to dismiss"
                    color: "#6c7086"
                    font.pixelSize: 10
                }
            }

            // Results ListView (Apps or CLI Commands)
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: resultList
                    anchors.fill: parent
                    model: searchInput.text.startsWith(">") ? cliList : appList
                    spacing: 6
                    currentIndex: selectedIndex

                    delegate: Rectangle {
                        width: resultList.width
                        height: 50
                        radius: 12
                        color: {
                            if (index === selectedIndex) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.28)
                            if (itemMouse.containsMouse) return Qt.rgba(1, 1, 1, 0.08)
                            return Qt.rgba(0.1, 0.12, 0.18, 0.4)
                        }
                        border.width: index === selectedIndex ? 1.5 : 0
                        border.color: Theme.accent

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            Text {
                                text: modelData.icon ? modelData.icon : "🚀"
                                font.pixelSize: 22
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.name ? modelData.name : ""
                                    color: "#cdd6f4"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                }

                                Text {
                                    text: modelData.description ? modelData.description : (modelData.desc ? modelData.desc : "")
                                    color: "#a6adc8"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                height: 22
                                implicitWidth: tagText.implicitWidth + 12
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    id: tagText
                                    anchors.centerIn: parent
                                    text: modelData.category ? modelData.category : "App"
                                    color: "#89b4fa"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: selectedIndex = index
                            onClicked: {
                                selectedIndex = index
                                launcherRoot.executeSelected()
                            }
                        }
                    }
                }
            }
        }
    }
}
