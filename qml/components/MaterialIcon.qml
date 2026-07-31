import QtQuick
import Bloom

Text {
    id: root
    property string name: ""
    property color iconColor: Theme.textPrimary
    property int iconSize: 18

    font.pixelSize: iconSize
    color: iconColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    // アイコン名に応じたUnicodeまたは絵文字/シンボルのマッピング
    text: {
        switch (name) {
            case "bot": return "🤖"
            case "sparkles": return "✨"
            case "send": return "➔"
            case "trash": return "🗑"
            case "notion": return "📝"
            case "check": return "✓"
            case "plus": return "+"
            case "close": return "✕"
            case "settings": return "⚙"
            case "user": return "👤"
            default: return name !== "" ? name : "★"
        }
    }
}
