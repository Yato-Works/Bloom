import QtQuick
QtObject {
    property string profile: "Caelestia"
    property string themeName: "rose"
    property bool useTwelveHourClock: true
    property bool useFahrenheit: false
    property string weatherLocation: ""
    property var services: QtObject {
        property bool useTwelveHourClock: true
        property bool useFahrenheit: false
        property string weatherLocation: ""
    }
}
