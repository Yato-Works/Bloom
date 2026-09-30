// Design tokens for the Bloom top bar & control panel.
//
// Chrome colours are driven by the dynamic wallpaper palette (Colours.m3*),
// exactly like the upstream Caelestia shell: near-opaque surfaces carrying a
// whisper of the wallpaper's hue, one dynamic accent, soft hairlines instead
// of hard borders, and the M3 rounding scale (8/12/16/20/28).
//
// Not a singleton - each consumer instantiates it (a pure value object).
import QtQuick
import Bloom

QtObject {
    // ---- typography (Inter is preferred; Segoe UI is the system fallback) ----
    readonly property string fontUi:   "Inter"
    readonly property string fontMono: "Cascadia Code"

    // ---- surfaces: layered M3 surfaces tinted by the wallpaper palette ----
    readonly property color barColor:   Qt.alpha(Colours.m3surfaceContainerLow, 0.90)
    readonly property color panelColor: Qt.alpha(Colours.m3surfaceContainerLowest, 0.74) // glass
    readonly property color cardColor:  Qt.alpha(Colours.m3surfaceContainerLow, 0.58)
    readonly property color inputColor: Qt.alpha(Colours.m3surfaceContainerHigh, 0.92)

    readonly property color lineSoft:   Qt.alpha(Colours.m3outlineVariant, 0.28)
    readonly property color lineStrong: Qt.alpha(Colours.m3outlineVariant, 0.45)

    // ---- typography / text ----
    readonly property color textHi:   Colours.m3onSurface
    readonly property color textMid:  Colours.m3onSurfaceVariant
    readonly property color textLow:  Qt.alpha(Colours.m3onSurfaceVariant, 0.72)
    readonly property color textOff:  Qt.alpha(Colours.m3onSurfaceVariant, 0.45)

    // ---- accents: the dynamic wallpaper accent + semantic tones ----
    readonly property color pink:     Colours.m3primary       // kept name: primary accent
    readonly property color pinkSoft: Qt.alpha(Colours.m3primary, 0.15)
    readonly property color blue:     Colours.m3secondary
    readonly property color green:    Colours.m3success
    readonly property color warn:     Colours.m3tertiary
    readonly property color bad:      Colours.m3error

    // ---- metrics: M3 rounding scale, compact 8px-based grid ----
    readonly property int barHeight:    46
    readonly property int panelHeight:  264
    readonly property int iconBtnSize:  30
    readonly property int radiusSharp:  8   // rounding.small
    readonly property int radiusCard:   16  // rounding.large
    readonly property int iconSize:     14
    readonly property int chipHeight:   30

    // ---- weather glyph helper (shared by bar + panel) ----
    function weatherGlyph(name) {
        const c = (name || "").toLowerCase()
        if (c.indexOf("clear")   !== -1 || c.indexOf("sunny") !== -1) return "☀️"
        if (c.indexOf("partly") !== -1 || c.indexOf("曇")    !== -1)  return "⛅"
        if (c.indexOf("cloud")   !== -1 || c.indexOf("くもり") !== -1)  return "☁️"
        if (c.indexOf("fog")    !== -1 || c.indexOf("霧")   !== -1)    return "🌫️"
        if (c.indexOf("drizzle") !== -1)                               return "🌦️"
        if (c.indexOf("rain")   !== -1 || c.indexOf("雨")   !== -1)    return "🌧️"
        if (c.indexOf("snow")   !== -1 || c.indexOf("雪")   !== -1)    return "❄️"
        if (c.indexOf("thunder") !== -1)                              return "⛈️"
        return "🌤️"
    }

    // ---- compact date helpers ----
    function shortDate(d) {
        const w = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.getDay()]
        return w + " " + ["Jan","Feb","Mar","Apr","May","Jun",
                          "Jul","Aug","Sep","Oct","Nov","Dec"][d.getMonth()] + " " + d.getDate()
    }
    function monthName(m) {
        return ["January","February","March","April","May","June",
                "July","August","September","October","November","December"][m] || ""
    }
}
