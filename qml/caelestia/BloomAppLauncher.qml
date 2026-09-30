// BloomAppLauncher — the "App/Terminal" replacement: a search box + filtered
// list of installed apps. Anchored under the top-bar launcher button.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property int width_: 320
    readonly property int height_: 396

    width: root.width_; height: root.height_
    visible: root.open
    opacity: root.open ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true

    BloomShellStyle { id: st }

    // ---- filtered model ----
    property string query: ""
    readonly property var listModel:
        root.query === "" ? appLauncherService.apps : appLauncherService.searchApps(root.query)

    // ---- surface ----
    Rectangle {
        anchors.fill: parent
        radius: st.radiusCard
        color: st.inputColor
        border.width: 1; border.color: st.lineSoft
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // search field
        Item {
            Layout.preferredHeight: 34
            Layout.fillWidth: true
            TextField {
                id: tf
                anchors.fill: parent
                placeholderText: qsTr("アプリを検索…")
                font.family: st.fontUi
                font.pixelSize: 12
                color: st.textHi
                selectionColor: st.pinkSoft
                verticalAlignment: TextField.AlignVCenter
                background: Rectangle {
                    anchors.fill: parent
                    color: st.cardColor
                    border.width: 1
                    border.color: tf.activeFocus ? st.pink : st.lineSoft
                    radius: st.radiusSharp
                }
                onTextChanged: root.query = text
            }
            MouseArea {
                anchors.right: parent.right; anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 14; height: 14
                visible: tf.text.length > 0
                cursorShape: Qt.PointingHandCursor
                onClicked: { tf.text = ""; root.query = ""; tf.focus = true }
                Text { anchors.centerIn: parent; text: "✕"; color: st.textLow; font.pixelSize: 9 }
            }
// results list
        ListView {
            id: lv
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.listModel
            clip: true
            spacing: 2
            delegate: Item {
                required property var modelData
                width: lv.width; height: 38
                Rectangle {
                    anchors.fill: parent; anchors.margins: 1
                    radius: st.radiusSharp
                    color: "transparent"
                    Rectangle {
                        id: itemBg
                        anchors.fill: parent; anchors.margins: 1
                        radius: st.radiusSharp
                        color: itemArea.hovered ? st.pinkSoft : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        MouseArea {
                            id: itemArea
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData && modelData.exec) {
                                    appLauncherService.launchApp(modelData.exec)
                                    root.open = false; tf.text = ""; root.query = ""
                                }
                            }
                        }
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 7; spacing: 9
                            Item { Layout.preferredWidth: 22; Layout.preferredHeight: 22
                                Text { anchors.centerIn: parent
                                    text: modelData.icon ? modelData.icon : "🚀"; font.pixelSize: 13 } }
                            Column {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: modelData.name ? modelData.name : ""
                                    color: st.textHi; font.family: st.fontUi; font.pixelSize: 12
                                    elide: Text.ElideRight; width: parent.width }
                                Text { text: modelData.description ? modelData.description : ""
                                    color: st.textLow; font.family: st.fontUi; font.pixelSize: 9
                                    elide: Text.ElideRight; width: parent.width }
                            }
                            Text { text: modelData.category ? modelData.category : ""
                                color: st.textLow; font.family: st.fontUi; font.pixelSize: 9; opacity: 0.6 }
                        }
                    }
                }
            }
        }
    }

    // close on Escape while the launcher has focus
    Keys.forwardTo: [lv]
    Keys.onPressed: {
        if (event.key === Qt.Key_Escape && !event.modifiers)
            root.open = false
    }
}
        }