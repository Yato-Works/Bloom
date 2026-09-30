import QtQuick
import Bloom.Services.Players
QtObject {
    readonly property var instance: Players
    property string trackTitle: Players.trackTitle
    property string artistName: Players.artistName
    property bool isPlaying: Players.isPlaying
    property int position: Players.position
    property int duration: Players.duration
    property string sourceApp: Players.sourceApp
}
