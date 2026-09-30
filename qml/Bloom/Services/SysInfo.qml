import QtQuick
QtObject {
    // SysInfo service bridge
    property double cpuUsage: 0.0
    property double memoryUsage: 0.0
    property double diskUsage: 0.0
    property string uptime: ""
    property string hostName: ""
    property string formattedTime: ""
    property string formattedDate: ""
    property int batteryPercent: -1
    property bool batteryCharging: false
    property bool hasBattery: false
}
