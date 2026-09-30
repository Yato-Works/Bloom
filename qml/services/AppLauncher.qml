import QtQuick
QtObject {
    property var apps: []
    property string currentApp: ""
    function launch(id) { /* TODO: bridge to AppLauncherService */ }
}
