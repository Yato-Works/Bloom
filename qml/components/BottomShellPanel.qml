import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Bloom

Item {
    id: root
    property bool open: false
    property bool panelHovered: false

    readonly property int panelHeight: 250

    height: panelHeight
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    opacity: open ? 1 : 0

    transform: [
        Translate {
            y: root.open ? 0 : (root.panelHeight + 30)
            Behavior on y {
                NumberAnimation {
                    duration: Theme.durationDefault
                    easing.type: Easing.OutExpo
                }
            }
        },
        Scale {
            origin.x: root.width / 2
            origin.y: root.panelHeight
            xScale: root.open ? 1.0 : 0.95
            yScale: root.open ? 1.0 : 0.95
            Behavior on xScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
            Behavior on yScale {
                NumberAnimation { duration: Theme.durationDefault; easing.type: Easing.OutExpo }
            }
        }
    ]
    Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
    }

    // Hover hit zone
    MouseArea {
        anchors.fill: parent
        anchors.margins: -30
        z: 999
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.panelHovered = containsMouse
    }

    // Main Central Floating Widget Container
    GlassPanel {
        id: widgetContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: Math.min(parent.width * 0.78, 880)
        implicitHeight: 230
        radius: 24
        tint: Qt.rgba(0.08, 0.07, 0.07, 0.92)
        elevated: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Smooth Sliding Wallpaper ListView Carousel
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: carouselView
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    spacing: 16
                    boundsBehavior: Flickable.StopAtBounds
                    snapMode: ListView.SnapToItem
                    highlightRangeMode: ListView.ApplyRange
                    preferredHighlightBegin: (width - 170) / 2
                    preferredHighlightEnd: (width + 170) / 2
                    highlightMoveDuration: 260

                    currentIndex: wallpaperService.selectedIndex

                    onCurrentIndexChanged: {
                        if (wallpaperService.selectedIndex !== currentIndex) {
                            wallpaperService.selectedIndex = currentIndex
                        }
                    }

                    model: wallpaperService.wallpapers

                    delegate: Item {
                        id: cardItem
                        readonly property bool isSelected: carouselView.currentIndex === index
                        property bool isHovered: cardMouse.containsMouse

                        width: isSelected ? 175 : 135
                        height: carouselView.height

                        z: isSelected ? 10 : (isHovered ? 5 : 1)

                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutExpo } }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 6

                            // Thumbnail Container
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 14
                                clip: true
                                color: modelData.colorStart
                                border.width: cardItem.isSelected ? 2 : (cardItem.isHovered ? 1 : 0)
                                border.color: cardItem.isSelected ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(1, 1, 1, 0.2)

                                // Gradient Background
                                Rectangle {
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: modelData.colorStart }
                                        GradientStop { position: 1.0; color: modelData.colorEnd }
                                    }
                                }

                                // Placeholder Visual Pattern
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    opacity: cardItem.isSelected ? 0.95 : 0.55

                                    MaterialIcon {
                                        name: "sparkles"
                                        iconSize: cardItem.isSelected ? 24 : 18
                                        iconColor: "#ffffff"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: cardItem.isSelected ? 11 : 9
                                        font.weight: Font.DemiBold
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Caption Label Under Card
                            Text {
                                text: modelData.fileName
                                color: cardItem.isSelected ? "#ffffff" : Qt.rgba(1, 1, 1, 0.45)
                                font.pixelSize: cardItem.isSelected ? 11 : 10
                                font.weight: cardItem.isSelected ? Font.Bold : Font.Normal
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                carouselView.currentIndex = index
                                wallpaperService.selectedIndex = index
                            }
                        }
                    }

                    // Mouse Wheel Support for smooth sliding
                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                                carouselView.incrementCurrentIndex()
                            } else {
                                carouselView.decrementCurrentIndex()
                            }
                        }
                    }
                }
            }

            // Bottom Minimal Command/Search Bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 19
                color: Qt.rgba(0, 0, 0, 0.45)
                border.width: 1
                border.color: cmdInput.activeFocus ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.08)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    MaterialIcon {
                        name: "🔍"
                        iconSize: 14
                        iconColor: Qt.rgba(1, 1, 1, 0.5)
                    }

                    Text {
                        text: ">wallpaper"
                        color: Qt.rgba(1, 1, 1, 0.85)
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    TextInput {
                        id: cmdInput
                        Layout.fillWidth: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#ffffff"
                        font.pixelSize: 12
                        clip: true

                        Text {
                            text: " 検索またはコマンドを入力... (Spaceで表示ロック)"
                            color: Qt.rgba(1, 1, 1, 0.3)
                            font.pixelSize: 12
                            visible: !cmdInput.text && !cmdInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        onTextChanged: {
                            var query = cmdInput.text.trimmed().toLowerCase()
                            if (query.length > 0) {
                                for (var i = 0; i < wallpaperService.wallpapers.length; i++) {
                                    var fn = wallpaperService.wallpapers[i].fileName.toLowerCase()
                                    if (fn.indexOf(query) !== -1) {
                                        carouselView.currentIndex = i
                                        break
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: clearMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                        visible: cmdInput.text.length > 0

                        MaterialIcon {
                            anchors.centerIn: parent
                            name: "close"
                            iconSize: 10
                            iconColor: Qt.rgba(1, 1, 1, 0.6)
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cmdInput.text = ""
                        }
                    }
                }
            }
        }
    }
}
