import QtQuick
QtObject {
    // AppLauncher service bridge
    property var apps: []
    property string currentApp: ""
    function launch(appId) { /* bridged to C++ */ }
}
