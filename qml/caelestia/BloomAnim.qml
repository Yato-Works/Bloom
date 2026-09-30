// BloomAnim — the authentic Caelestia/M3 motion system, ported 1:1 from the
// upstream tokens (plugin/src/Caelestia/Config/tokens.hpp). Every spatial and
// effect animation in the shell should use one of these types so the whole UI
// moves with the same expressive personality.
import QtQuick

NumberAnimation {
    enum Type {
        StandardSmall = 0,
        Standard,
        StandardLarge,
        StandardExtraLarge,
        EmphasizedSmall,
        Emphasized,
        EmphasizedLarge,
        EmphasizedExtraLarge,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    property int type: BloomAnim.DefaultSpatial

    // M3 expressive bezier splines (upstream AnimCurves defaults).
    readonly property var _curves: [
        [0.2, 0, 0, 1, 1, 1],                                       // standard
        [0.05, 0, 0.13333, 0.06, 0.16667, 0.4, 0.20833, 0.82, 0.25, 1, 1, 1], // emphasized
        [0.42, 1.67, 0.21, 0.9, 1, 1],                              // fastSpatial
        [0.38, 1.21, 0.22, 1, 1, 1],                                // defaultSpatial
        [0.39, 1.29, 0.35, 0.98, 1, 1],                             // slowSpatial
        [0.31, 0.94, 0.34, 1, 1, 1],                                // fastEffects
        [0.34, 0.8, 0.34, 1, 1, 1],                                 // defaultEffects
        [0.34, 0.88, 0.34, 1, 1, 1]                                 // slowEffects
    ]

    readonly property var _durations: [200, 400, 600, 1000, 350, 500, 650, 150, 200, 300]

    duration: {
        if (type === BloomAnim.FastSpatial)
            return _durations[4];
        if (type === BloomAnim.DefaultSpatial)
            return _durations[5];
        if (type === BloomAnim.SlowSpatial)
            return _durations[6];
        if (type === BloomAnim.FastEffects)
            return _durations[7];
        if (type === BloomAnim.DefaultEffects)
            return _durations[8];
        if (type === BloomAnim.SlowEffects)
            return _durations[9];
        return _durations[type % 4]; // 0-7: standard/emphasized × 4 sizes
    }
    easing.bezierCurve: {
        if (type === BloomAnim.FastSpatial)
            return _curves[2];
        if (type === BloomAnim.DefaultSpatial)
            return _curves[3];
        if (type === BloomAnim.SlowSpatial)
            return _curves[4];
        if (type === BloomAnim.FastEffects)
            return _curves[5];
        if (type === BloomAnim.DefaultEffects)
            return _curves[6];
        if (type === BloomAnim.SlowEffects)
            return _curves[7];
        if (type >= BloomAnim.EmphasizedSmall && type <= BloomAnim.EmphasizedExtraLarge)
            return _curves[1];
        return _curves[0];
    }
}
