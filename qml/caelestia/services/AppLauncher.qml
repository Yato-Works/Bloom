import QtQuick
import Bloom.Services.AppLauncher
QtObject {
    readonly property var instance: AppLauncher
    property var apps: AppLauncher.apps
    property var currentApp: AppLauncher.currentApp
    function launch(appId) { return AppLauncher.launch(appId) }
}
