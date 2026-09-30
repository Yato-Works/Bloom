#pragma once

#include <QColor>
#include <QString>

// Lightweight wallpaper colour extraction that generates a Material You (M3)
// style dark palette from the dominant hues of an image. This is Bloom's
// stand-in for Caelestia Shell's matugen-based dynamic colours: the panels
// stay opaque, but every surface and accent carries a whisper of the current
// wallpaper's hue, exactly like the reference screenshots.
namespace PaletteEngine {

struct M3Palette {
    QColor background;
    QColor onBackground;
    QColor surface;
    QColor surfaceDim;
    QColor surfaceBright;
    QColor surfaceContainerLowest;
    QColor surfaceContainerLow;
    QColor surfaceContainer;
    QColor surfaceContainerHigh;
    QColor surfaceContainerHighest;
    QColor onSurface;
    QColor surfaceVariant;
    QColor onSurfaceVariant;
    QColor inverseSurface;
    QColor inverseOnSurface;
    QColor outline;
    QColor outlineVariant;
    QColor shadow;
    QColor scrim;
    QColor surfaceTint;
    QColor primary;
    QColor onPrimary;
    QColor primaryContainer;
    QColor onPrimaryContainer;
    QColor inversePrimary;
    QColor secondary;
    QColor onSecondary;
    QColor secondaryContainer;
    QColor onSecondaryContainer;
    QColor tertiary;
    QColor onTertiary;
    QColor tertiaryContainer;
    QColor onTertiaryContainer;
    QColor error;
    QColor onError;
    QColor errorContainer;
    QColor onErrorContainer;
    QColor success;
    QColor onSuccess;
    QColor successContainer;
    QColor onSuccessContainer;
    QColor primaryFixed;
    QColor primaryFixedDim;
    QColor onPrimaryFixed;
    QColor onPrimaryFixedVariant;
    QColor secondaryFixed;
    QColor secondaryFixedDim;
    QColor onSecondaryFixed;
    QColor onSecondaryFixedVariant;
    QColor tertiaryFixed;
    QColor tertiaryFixedDim;
    QColor onTertiaryFixed;
    QColor onTertiaryFixedVariant;
};

// Extract a palette from the image at |imagePath|. On failure this returns
// fallback() and sets |ok| to false when provided.
M3Palette extract(const QString &imagePath, bool *ok = nullptr);

// The static Material You defaults (the original Caelestia pink dark theme).
M3Palette fallback();

} // namespace PaletteEngine