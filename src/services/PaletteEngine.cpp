#include "PaletteEngine.h"

#include <QImage>
#include <QImageReader>
#include <QtMath>

namespace {

constexpr int kSampleSize = 72;

qreal wrapHue(qreal degrees)
{
    qreal h = std::fmod(degrees, 360.0);
    return h < 0.0 ? h + 360.0 : h;
}

QColor tone(qreal hueDegrees, qreal sat, qreal light, qreal alpha = 1.0)
{
    QColor c;
    c.setHslF(wrapHue(hueDegrees) / 360.0,
              qBound(0.0, sat, 1.0),
              qBound(0.0, light, 1.0),
              alpha);
    return c;
}

} // namespace

namespace PaletteEngine {

M3Palette extract(const QString &imagePath, bool *ok)
{
    QImageReader reader(imagePath);
    const QSize native = reader.size();
    if (native.isValid() && native.width() > 0 && native.height() > 0)
        reader.setScaledSize(native.scaled(kSampleSize, kSampleSize, Qt::KeepAspectRatioByExpanding));
    QImage image = reader.read();
    if (image.isNull()) {
        if (ok) *ok = false;
        return fallback();
    }
    if (image.width() > kSampleSize || image.height() > kSampleSize)
        image = image.scaled(kSampleSize, kSampleSize, Qt::KeepAspectRatioByExpanding,
                             Qt::SmoothTransformation);

    // Circular-mean hue analysis: colourful mid-tones vote for the accent hue,
    // muted pixels vote for the neutral surface hue. This mirrors how the
    // reference theme keeps near-opaque surfaces that still carry a whisper of
    // the wallpaper's colour.
    qreal accentCos = 0.0, accentSin = 0.0, accentWeightSum = 0.0;
    qreal neutralCos = 0.0, neutralSin = 0.0, neutralWeightSum = 0.0;
    qreal saturationSum = 0.0;
    int sampled = 0;

    for (int y = 0; y < image.height(); ++y) {
        const QRgb *line = reinterpret_cast<const QRgb *>(image.constScanLine(y));
        for (int x = 0; x < image.width(); ++x) {
            QColor c(line[x]);
            float h = 0.0f, s = 0.0f, l = 0.0f, a = 1.0f;
            c.getHslF(&h, &s, &l, &a);
            if (a < 0.9)
                continue;
            ++sampled;
            saturationSum += s;
            const qreal rad = qDegreesToRadians(h * 360.0);
            const qreal accentWeight = s * s * qMax(0.0, 1.0 - qAbs(l - 0.55) * 1.4);
            if (accentWeight > 0.0) {
                accentCos += qCos(rad) * accentWeight;
                accentSin += qSin(rad) * accentWeight;
                accentWeightSum += accentWeight;
            }
            const qreal neutralWeight = 1.0 - s;
            neutralCos += qCos(rad) * neutralWeight;
            neutralSin += qSin(rad) * neutralWeight;
            neutralWeightSum += neutralWeight;
        }
    }

    if (sampled == 0) {
        if (ok) *ok = false;
        return fallback();
    }

    const qreal avgSaturation = saturationSum / sampled;

    // Warm neutral fallback for (near-)grayscale wallpapers.
    qreal accentHue = 25.0;
    qreal accentSaturation = 0.15;
    if (accentWeightSum > 0.0 && avgSaturation > 0.12) {
        accentHue = wrapHue(qRadiansToDegrees(
            qAtan2(accentSin / accentWeightSum, accentCos / accentWeightSum)));
        accentSaturation = qBound(0.25, avgSaturation * 1.7, 0.85);
    }

    const qreal neutralHue = neutralWeightSum > 0.0
        ? wrapHue(qRadiansToDegrees(
              qAtan2(neutralSin / neutralWeightSum, neutralCos / neutralWeightSum)))
        : 25.0;
    const qreal neutralSat = qBound(0.04, avgSaturation * 0.35, 0.14);

    // Material surfaces — near-opaque, neutral hue with a hint of the image.
    M3Palette p;
    p.background               = tone(neutralHue, neutralSat,        0.085);
    p.onBackground             = tone(neutralHue, neutralSat + 0.02, 0.910);
    p.surface                  = tone(neutralHue, neutralSat,        0.085);
    p.surfaceDim               = tone(neutralHue, neutralSat,        0.070);
    p.surfaceBright            = tone(neutralHue, neutralSat,        0.150);
    p.surfaceContainerLowest   = tone(neutralHue, neutralSat,        0.060);
    p.surfaceContainerLow      = tone(neutralHue, neutralSat,        0.090);
    p.surfaceContainer         = tone(neutralHue, neutralSat,        0.115);
    p.surfaceContainerHigh     = tone(neutralHue, neutralSat,        0.145);
    p.surfaceContainerHighest  = tone(neutralHue, neutralSat,        0.175);
    p.onSurface                = tone(neutralHue, neutralSat + 0.02, 0.910);
    p.surfaceVariant           = tone(neutralHue, neutralSat,        0.290);
    p.onSurfaceVariant         = tone(neutralHue, neutralSat,        0.790);
    p.inverseSurface           = tone(neutralHue, neutralSat + 0.02, 0.910);
    p.inverseOnSurface         = tone(neutralHue, neutralSat,        0.170);
    p.outline                  = tone(neutralHue, neutralSat * 0.6,  0.580);
    p.outlineVariant           = tone(neutralHue, neutralSat,        0.290);
    p.shadow                   = QColor(0, 0, 0);
    p.scrim                    = QColor(0, 0, 0);
    p.surfaceTint              = tone(accentHue, accentSaturation * 0.8, 0.80);

    // Primary / secondary follow the accent hue, tertiary is hue-shifted like
    // the reference Material You palettes.
    const qreal tertiaryHue = wrapHue(accentHue + 55.0);
    p.primary                  = tone(accentHue, accentSaturation * 0.85, 0.80);
    p.onPrimary                = tone(accentHue, accentSaturation * 0.70, 0.22);
    p.primaryContainer         = tone(accentHue, accentSaturation * 0.60, 0.36);
    p.onPrimaryContainer       = tone(accentHue, accentSaturation * 0.80, 0.90);
    p.inversePrimary           = tone(accentHue, accentSaturation * 0.50, 0.42);
    p.secondary                = tone(accentHue, accentSaturation * 0.32, 0.81);
    p.onSecondary              = tone(accentHue, accentSaturation * 0.25, 0.21);
    p.secondaryContainer       = tone(accentHue, accentSaturation * 0.22, 0.33);
    p.onSecondaryContainer     = tone(accentHue, accentSaturation * 0.35, 0.90);
    p.tertiary                 = tone(tertiaryHue, accentSaturation * 0.55, 0.80);
    p.onTertiary               = tone(tertiaryHue, accentSaturation * 0.60, 0.17);
    p.tertiaryContainer        = tone(tertiaryHue, accentSaturation * 0.40, 0.38);
    p.onTertiaryContainer      = tone(tertiaryHue, accentSaturation * 0.60, 0.92);
    p.primaryFixed             = tone(accentHue, accentSaturation * 0.70, 0.90);
    p.primaryFixedDim          = p.primary;
    p.onPrimaryFixed           = tone(accentHue, accentSaturation * 0.80, 0.16);
    p.onPrimaryFixedVariant    = p.primaryContainer;
    p.secondaryFixed           = p.onSecondaryContainer;
    p.secondaryFixedDim        = p.secondary;
    p.onSecondaryFixed         = tone(accentHue, accentSaturation * 0.30, 0.16);
    p.onSecondaryFixedVariant  = p.secondaryContainer;
    p.tertiaryFixed            = tone(tertiaryHue, accentSaturation * 0.50, 0.90);
    p.tertiaryFixedDim         = p.tertiary;
    p.onTertiaryFixed          = tone(tertiaryHue, accentSaturation * 0.60, 0.16);
    p.onTertiaryFixedVariant   = p.tertiaryContainer;

    // Error / success keep the canonical Material tones.
    p.error              = QColor(QStringLiteral("#ffb4ab"));
    p.onError            = QColor(QStringLiteral("#690005"));
    p.errorContainer     = QColor(QStringLiteral("#93000a"));
    p.onErrorContainer   = QColor(QStringLiteral("#ffdad6"));
    p.success            = QColor(QStringLiteral("#B5CCBA"));
    p.onSuccess          = QColor(QStringLiteral("#213528"));
    p.successContainer   = QColor(QStringLiteral("#374B3E"));
    p.onSuccessContainer = QColor(QStringLiteral("#D1E9D6"));

    if (ok) *ok = true;
    return p;
}

M3Palette fallback()
{
    // The original Caelestia pink dark theme, used when no wallpaper can be
    // analysed (startup before the desktop background is known, unreadable
    // images, ...).
    M3Palette p;
    p.background              = QColor(QStringLiteral("#1b1113"));
    p.onBackground            = QColor(QStringLiteral("#efdfe2"));
    p.surface                 = QColor(QStringLiteral("#1b1113"));
    p.surfaceDim              = QColor(QStringLiteral("#22191c"));
    p.surfaceBright           = QColor(QStringLiteral("#3c3235"));
    p.surfaceContainerLowest  = QColor(QStringLiteral("#150d10"));
    p.surfaceContainerLow     = QColor(QStringLiteral("#22191c"));
    p.surfaceContainer        = QColor(QStringLiteral("#261d20"));
    p.surfaceContainerHigh    = QColor(QStringLiteral("#31282a"));
    p.surfaceContainerHighest = QColor(QStringLiteral("#3c3235"));
    p.onSurface               = QColor(QStringLiteral("#efdfe2"));
    p.surfaceVariant          = QColor(QStringLiteral("#514347"));
    p.onSurfaceVariant        = QColor(QStringLiteral("#d5c2c6"));
    p.inverseSurface          = QColor(QStringLiteral("#efdfe2"));
    p.inverseOnSurface        = QColor(QStringLiteral("#372e30"));
    p.outline                 = QColor(QStringLiteral("#9e8c91"));
    p.outlineVariant          = QColor(QStringLiteral("#514347"));
    p.shadow                  = QColor(QStringLiteral("#000000"));
    p.scrim                   = QColor(QStringLiteral("#000000"));
    p.surfaceTint             = QColor(QStringLiteral("#ffb0ca"));
    p.primary                 = QColor(QStringLiteral("#ffb0ca"));
    p.onPrimary               = QColor(QStringLiteral("#541d34"));
    p.primaryContainer        = QColor(QStringLiteral("#6f334a"));
    p.onPrimaryContainer      = QColor(QStringLiteral("#ffd9e3"));
    p.inversePrimary          = QColor(QStringLiteral("#8b4a62"));
    p.secondary               = QColor(QStringLiteral("#e2bdc7"));
    p.onSecondary             = QColor(QStringLiteral("#422932"));
    p.secondaryContainer      = QColor(QStringLiteral("#5a3f48"));
    p.onSecondaryContainer    = QColor(QStringLiteral("#ffd9e3"));
    p.tertiary                = QColor(QStringLiteral("#f0bc95"));
    p.onTertiary              = QColor(QStringLiteral("#48290c"));
    p.tertiaryContainer       = QColor(QStringLiteral("#b58763"));
    p.onTertiaryContainer     = QColor(QStringLiteral("#000000"));
    p.error                   = QColor(QStringLiteral("#ffb4ab"));
    p.onError                 = QColor(QStringLiteral("#690005"));
    p.errorContainer          = QColor(QStringLiteral("#93000a"));
    p.onErrorContainer        = QColor(QStringLiteral("#ffdad6"));
    p.success                 = QColor(QStringLiteral("#B5CCBA"));
    p.onSuccess               = QColor(QStringLiteral("#213528"));
    p.successContainer        = QColor(QStringLiteral("#374B3E"));
    p.onSuccessContainer      = QColor(QStringLiteral("#D1E9D6"));
    p.primaryFixed            = QColor(QStringLiteral("#ffd9e3"));
    p.primaryFixedDim         = QColor(QStringLiteral("#ffb0ca"));
    p.onPrimaryFixed          = QColor(QStringLiteral("#39071f"));
    p.onPrimaryFixedVariant   = QColor(QStringLiteral("#6f334a"));
    p.secondaryFixed          = QColor(QStringLiteral("#ffd9e3"));
    p.secondaryFixedDim       = QColor(QStringLiteral("#e2bdc7"));
    p.onSecondaryFixed        = QColor(QStringLiteral("#2b151d"));
    p.onSecondaryFixedVariant = QColor(QStringLiteral("#5a3f48"));
    p.tertiaryFixed           = QColor(QStringLiteral("#ffdcc3"));
    p.tertiaryFixedDim        = QColor(QStringLiteral("#f0bc95"));
    p.onTertiaryFixed         = QColor(QStringLiteral("#2f1500"));
    p.onTertiaryFixedVariant  = QColor(QStringLiteral("#623f21"));
    return p;
}

} // namespace PaletteEngine