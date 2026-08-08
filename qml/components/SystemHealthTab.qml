import QtQuick
import QtQuick.Layouts
import Bloom

RowLayout {
    spacing: 40
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    MetricRing {
        label: "CPU Usage"
        value: systemInfo.cpuUsage
        accent: Theme.primary
    }

    MetricRing {
        label: "RAM Usage"
        value: systemInfo.memoryUsage
        accent: "#cba6f7"
    }
}
