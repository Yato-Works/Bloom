import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelHeight: 220

    height: panelHeight
    opacity: open ? 1 : 0

    // Slide from below (transform avoids fighting anchors)
    transform: Translate {
        y: root.open ? 0 : root.panelHeight + 28
        Behavior on y {
            NumberAnimation {
                duration: Theme.durationDefault
                easing.type: Easing.OutCubic
            }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // β: keep open while pointer is over the panel
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    GlassPanel {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.bottomMargin: 12
        anchors.topMargin: 0
        tint: Theme.surface
        showShadow: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.paddingLG
            spacing: Theme.spacingMD

            // Wallpaper card
            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                tint: Theme.surfaceContainer
                showShadow: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMD
                    spacing: Theme.spacingSM

                    RowLayout {
                        spacing: Theme.spacingXS
                        Text { text: "🖼"; color: Theme.primary; font.pixelSize: 16 }
                        Text {
                            text: "Wallpaper"
                            color: Theme.text
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                    }

                    TextField {
                        id: pathField
                        Layout.fillWidth: true
                        placeholderText: "壁紙のパス..."
                        color: Theme.text
                        font.pixelSize: Theme.fontSM
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.06)
                        }
                        onAccepted: wallpaperService.setWallpaper(text)
                    }

                    Button {
                        text: "適用"
                        Layout.alignment: Qt.AlignRight
                        flat: true
                        contentItem: Text {
                            text: "適 用"
                            color: Theme.onPrimary
                            font.pixelSize: Theme.fontSM
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            radius: Theme.radiusFull
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.85)
                            implicitWidth: 72
                            implicitHeight: 30
                        }
                        onClicked: wallpaperService.setWallpaper(pathField.text)
                    }

                    Text {
                        text: "適用でデスクトップ背景を変更"
                        color: Theme.onSurfaceMuted
                        font.pixelSize: Theme.fontXS
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // Music card
            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                tint: Theme.surfaceContainer
                showShadow: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMD
                    spacing: Theme.spacingSM

                    RowLayout {
                        spacing: Theme.spacingXS
                        Text { text: "♫"; color: Theme.accent; font.pixelSize: 16 }
                        Text {
                            text: "Music"
                            color: Theme.text
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                    }

                    Text {
                        text: "Night Drive"
                        color: Theme.text
                        font.pixelSize: Theme.fontLG
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "WavePoint"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSM
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Rectangle {
                            width: 36; height: 36; radius: 18
                            color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            Text { anchors.centerIn: parent; text: "⏮"; color: Theme.text; font.pixelSize: 14 }
                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: musicControl.previous()
                            }
                        }
                        Rectangle {
                            width: 44; height: 44; radius: 22
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                            border.width: 1
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                            Text { anchors.centerIn: parent; text: "▶"; color: Theme.accent; font.pixelSize: 16 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: musicControl.togglePlayPause()
                            }
                        }
                        Rectangle {
                            width: 36; height: 36; radius: 18
                            color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                            Text { anchors.centerIn: parent; text: "⏭"; color: Theme.text; font.pixelSize: 14 }
                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: musicControl.next()
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // Workspace placeholder (next integration)
            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                tint: Theme.surfaceContainer
                showShadow: false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.spacingMD
                    spacing: Theme.spacingSM

                    RowLayout {
                        spacing: Theme.spacingXS
                        Text { text: "🗂"; color: Theme.primary; font.pixelSize: 16 }
                        Text {
                            text: "Workspace"
                            color: Theme.text
                            font.pixelSize: Theme.fontMD
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            width: soonLabel.width + 12
                            height: 20
                            radius: Theme.radiusFull
                            color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                            Text {
                                id: soonLabel
                                anchors.centerIn: parent
                                text: "soon"
                                color: Theme.primary
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Save your workspace.\nRestore your flow."
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontSM
                        wrapMode: Text.WordWrap
                        lineHeight: 1.25
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "次のステップで Save / Restore をここに統合します。通知ウィジェットも上下の端から拡張予定。"
                        color: Theme.onSurfaceMuted
                        font.pixelSize: Theme.fontXS
                        wrapMode: Text.WordWrap
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
