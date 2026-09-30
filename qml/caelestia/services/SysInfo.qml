import QtQuick
import Bloom.Services.SysInfo
QtObject {
    readonly property var instance: SysInfo
    property double cpuUsage: SysInfo.cpuUsage
    property double memoryUsage: SysInfo.memoryUsage
    property double diskUsage: SysInfo.diskUsage
    property int uptime: SysInfo.uptime
    property string hostName: SysInfo.hostName
    property string formattedTime: SysInfo.formattedTime
    property string formattedDate: SysInfo.formattedDate
    property int batteryPercent: SysInfo.batteryPercent
    property bool batteryCharging: SysInfo.batteryCharging
    property bool hasBattery: SysInfo.hasBattery
}
