#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include <QColor>

#include "PaletteEngine.h"

// Caelestia colour singleton, exposed to QML as Colours.m3<...>.
// The palette is dynamic: it is regenerated from the active wallpaper by
// PaletteEngine whenever the desktop background changes, and falls back to the
// static Material You pink dark theme when no wallpaper is available.
class CaelestiaColours : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Colours)

    Q_PROPERTY(QColor m3background READ m3background NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onBackground READ m3onBackground NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surface READ m3surface NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceDim READ m3surfaceDim NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceBright READ m3surfaceBright NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceContainerLowest READ m3surfaceContainerLowest NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceContainerLow READ m3surfaceContainerLow NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceContainer READ m3surfaceContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceContainerHigh READ m3surfaceContainerHigh NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceContainerHighest READ m3surfaceContainerHighest NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSurface READ m3onSurface NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceVariant READ m3surfaceVariant NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSurfaceVariant READ m3onSurfaceVariant NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3inverseSurface READ m3inverseSurface NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3inverseOnSurface READ m3inverseOnSurface NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3outline READ m3outline NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3outlineVariant READ m3outlineVariant NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3shadow READ m3shadow NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3scrim READ m3scrim NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3surfaceTint READ m3surfaceTint NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3primary READ m3primary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onPrimary READ m3onPrimary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3primaryContainer READ m3primaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onPrimaryContainer READ m3onPrimaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3inversePrimary READ m3inversePrimary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3secondary READ m3secondary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSecondary READ m3onSecondary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3secondaryContainer READ m3secondaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSecondaryContainer READ m3onSecondaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3tertiary READ m3tertiary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onTertiary READ m3onTertiary NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3tertiaryContainer READ m3tertiaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onTertiaryContainer READ m3onTertiaryContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3error READ m3error NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onError READ m3onError NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3errorContainer READ m3errorContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onErrorContainer READ m3onErrorContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3success READ m3success NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSuccess READ m3onSuccess NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3successContainer READ m3successContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSuccessContainer READ m3onSuccessContainer NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3primaryFixed READ m3primaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3primaryFixedDim READ m3primaryFixedDim NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onPrimaryFixed READ m3onPrimaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onPrimaryFixedVariant READ m3onPrimaryFixedVariant NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3secondaryFixed READ m3secondaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3secondaryFixedDim READ m3secondaryFixedDim NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSecondaryFixed READ m3onSecondaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onSecondaryFixedVariant READ m3onSecondaryFixedVariant NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3tertiaryFixed READ m3tertiaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3tertiaryFixedDim READ m3tertiaryFixedDim NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onTertiaryFixed READ m3onTertiaryFixed NOTIFY paletteChanged)
    Q_PROPERTY(QColor m3onTertiaryFixedVariant READ m3onTertiaryFixedVariant NOTIFY paletteChanged)

public:
    [[nodiscard]] QColor m3background() const { return m_background; }
    [[nodiscard]] QColor m3onBackground() const { return m_onBackground; }
    [[nodiscard]] QColor m3surface() const { return m_surface; }
    [[nodiscard]] QColor m3surfaceDim() const { return m_surfaceDim; }
    [[nodiscard]] QColor m3surfaceBright() const { return m_surfaceBright; }
    [[nodiscard]] QColor m3surfaceContainerLowest() const { return m_surfaceContainerLowest; }
    [[nodiscard]] QColor m3surfaceContainerLow() const { return m_surfaceContainerLow; }
    [[nodiscard]] QColor m3surfaceContainer() const { return m_surfaceContainer; }
    [[nodiscard]] QColor m3surfaceContainerHigh() const { return m_surfaceContainerHigh; }
    [[nodiscard]] QColor m3surfaceContainerHighest() const { return m_surfaceContainerHighest; }
    [[nodiscard]] QColor m3onSurface() const { return m_onSurface; }
    [[nodiscard]] QColor m3surfaceVariant() const { return m_surfaceVariant; }
    [[nodiscard]] QColor m3onSurfaceVariant() const { return m_onSurfaceVariant; }
    [[nodiscard]] QColor m3inverseSurface() const { return m_inverseSurface; }
    [[nodiscard]] QColor m3inverseOnSurface() const { return m_inverseOnSurface; }
    [[nodiscard]] QColor m3outline() const { return m_outline; }
    [[nodiscard]] QColor m3outlineVariant() const { return m_outlineVariant; }
    [[nodiscard]] QColor m3shadow() const { return m_shadow; }
    [[nodiscard]] QColor m3scrim() const { return m_scrim; }
    [[nodiscard]] QColor m3surfaceTint() const { return m_surfaceTint; }
    [[nodiscard]] QColor m3primary() const { return m_primary; }
    [[nodiscard]] QColor m3onPrimary() const { return m_onPrimary; }
    [[nodiscard]] QColor m3primaryContainer() const { return m_primaryContainer; }
    [[nodiscard]] QColor m3onPrimaryContainer() const { return m_onPrimaryContainer; }
    [[nodiscard]] QColor m3inversePrimary() const { return m_inversePrimary; }
    [[nodiscard]] QColor m3secondary() const { return m_secondary; }
    [[nodiscard]] QColor m3onSecondary() const { return m_onSecondary; }
    [[nodiscard]] QColor m3secondaryContainer() const { return m_secondaryContainer; }
    [[nodiscard]] QColor m3onSecondaryContainer() const { return m_onSecondaryContainer; }
    [[nodiscard]] QColor m3tertiary() const { return m_tertiary; }
    [[nodiscard]] QColor m3onTertiary() const { return m_onTertiary; }
    [[nodiscard]] QColor m3tertiaryContainer() const { return m_tertiaryContainer; }
    [[nodiscard]] QColor m3onTertiaryContainer() const { return m_onTertiaryContainer; }
    [[nodiscard]] QColor m3error() const { return m_error; }
    [[nodiscard]] QColor m3onError() const { return m_onError; }
    [[nodiscard]] QColor m3errorContainer() const { return m_errorContainer; }
    [[nodiscard]] QColor m3onErrorContainer() const { return m_onErrorContainer; }
    [[nodiscard]] QColor m3success() const { return m_success; }
    [[nodiscard]] QColor m3onSuccess() const { return m_onSuccess; }
    [[nodiscard]] QColor m3successContainer() const { return m_successContainer; }
    [[nodiscard]] QColor m3onSuccessContainer() const { return m_onSuccessContainer; }
    [[nodiscard]] QColor m3primaryFixed() const { return m_primaryFixed; }
    [[nodiscard]] QColor m3primaryFixedDim() const { return m_primaryFixedDim; }
    [[nodiscard]] QColor m3onPrimaryFixed() const { return m_onPrimaryFixed; }
    [[nodiscard]] QColor m3onPrimaryFixedVariant() const { return m_onPrimaryFixedVariant; }
    [[nodiscard]] QColor m3secondaryFixed() const { return m_secondaryFixed; }
    [[nodiscard]] QColor m3secondaryFixedDim() const { return m_secondaryFixedDim; }
    [[nodiscard]] QColor m3onSecondaryFixed() const { return m_onSecondaryFixed; }
    [[nodiscard]] QColor m3onSecondaryFixedVariant() const { return m_onSecondaryFixedVariant; }
    [[nodiscard]] QColor m3tertiaryFixed() const { return m_tertiaryFixed; }
    [[nodiscard]] QColor m3tertiaryFixedDim() const { return m_tertiaryFixedDim; }
    [[nodiscard]] QColor m3onTertiaryFixed() const { return m_onTertiaryFixed; }
    [[nodiscard]] QColor m3onTertiaryFixedVariant() const { return m_onTertiaryFixedVariant; }

    Q_PROPERTY(QString currentScheme READ currentScheme NOTIFY schemeChanged)
    Q_PROPERTY(QString currentFlavour READ currentFlavour NOTIFY schemeChanged)
    Q_PROPERTY(bool isLight READ isLight NOTIFY schemeChanged)

    QString currentScheme() const { return m_currentScheme; }
    QString currentFlavour() const { return m_currentFlavour; }
    bool isLight() const { return m_isLight; }

    // QML_SINGLETON factory — always hands out the shared C++-owned instance.
    static CaelestiaColours *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    static CaelestiaColours *instance();

    // Rebuild every token from the wallpaper image at |wallpaperPath|.
    Q_INVOKABLE void applyWallpaperPalette(const QString &wallpaperPath);
    Q_INVOKABLE void resetToDefault();
    Q_INVOKABLE void applyScheme(const QString &name, const QString &flavour, const QString &primaryHex = QString(), const QString &surfaceHex = QString(), const QString &bgHex = QString());
    Q_INVOKABLE void setMode(const QString &mode);

signals:
    void paletteChanged();
    void schemeChanged();

private:
    explicit CaelestiaColours(QObject *parent = nullptr);
    void assign(const PaletteEngine::M3Palette &palette);

    static CaelestiaColours *s_instance;

    QColor m_background;
    QColor m_onBackground;
    QColor m_surface;
    QColor m_surfaceDim;
    QColor m_surfaceBright;
    QColor m_surfaceContainerLowest;
    QColor m_surfaceContainerLow;
    QColor m_surfaceContainer;
    QColor m_surfaceContainerHigh;
    QColor m_surfaceContainerHighest;
    QColor m_onSurface;
    QColor m_surfaceVariant;
    QColor m_onSurfaceVariant;
    QColor m_inverseSurface;
    QColor m_inverseOnSurface;
    QColor m_outline;
    QColor m_outlineVariant;
    QColor m_shadow;
    QColor m_scrim;
    QColor m_surfaceTint;
    QColor m_primary;
    QColor m_onPrimary;
    QColor m_primaryContainer;
    QColor m_onPrimaryContainer;
    QColor m_inversePrimary;
    QColor m_secondary;
    QColor m_onSecondary;
    QColor m_secondaryContainer;
    QColor m_onSecondaryContainer;
    QColor m_tertiary;
    QColor m_onTertiary;
    QColor m_tertiaryContainer;
    QColor m_onTertiaryContainer;
    QColor m_error;
    QColor m_onError;
    QColor m_errorContainer;
    QColor m_onErrorContainer;
    QColor m_success;
    QColor m_onSuccess;
    QColor m_successContainer;
    QColor m_onSuccessContainer;
    QColor m_primaryFixed;
    QColor m_primaryFixedDim;
    QColor m_onPrimaryFixed;
    QColor m_onPrimaryFixedVariant;
    QColor m_secondaryFixed;
    QColor m_secondaryFixedDim;
    QColor m_onSecondaryFixed;
    QColor m_onSecondaryFixedVariant;
    QColor m_tertiaryFixed;
    QColor m_tertiaryFixedDim;
    QColor m_onTertiaryFixed;
    QColor m_onTertiaryFixedVariant;

    QString m_currentScheme = QStringLiteral("catppuccin");
    QString m_currentFlavour = QStringLiteral("mocha");
    bool m_isLight = false;
};