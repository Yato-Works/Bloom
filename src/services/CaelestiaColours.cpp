#include "CaelestiaColours.h"

CaelestiaColours *CaelestiaColours::s_instance = nullptr;

CaelestiaColours::CaelestiaColours(QObject *parent)
    : QObject(parent)
{
    s_instance = this;
    assign(PaletteEngine::fallback());
}

CaelestiaColours *CaelestiaColours::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine);
    if (!s_instance)
        s_instance = new CaelestiaColours();
    if (qmlEngine)
        qmlEngine->setObjectOwnership(s_instance, QQmlEngine::CppOwnership);
    return s_instance;
}

CaelestiaColours *CaelestiaColours::instance()
{
    if (!s_instance)
        s_instance = new CaelestiaColours();
    return s_instance;
}

void CaelestiaColours::applyWallpaperPalette(const QString &wallpaperPath)
{
    if (wallpaperPath.isEmpty()) {
        resetToDefault();
        return;
    }
    bool ok = false;
    const PaletteEngine::M3Palette extracted = PaletteEngine::extract(wallpaperPath, &ok);
    if (!ok)
        return; // keep the current palette on transient failures
    assign(extracted);
}

void CaelestiaColours::resetToDefault()
{
    assign(PaletteEngine::fallback());
}

void CaelestiaColours::assign(const PaletteEngine::M3Palette &p)
{
    bool changed = false;
    const auto set = [&changed](QColor &dst, const QColor &src) {
        if (dst != src) {
            dst = src;
            changed = true;
        }
    };
    set(m_background, p.background);
    set(m_onBackground, p.onBackground);
    set(m_surface, p.surface);
    set(m_surfaceDim, p.surfaceDim);
    set(m_surfaceBright, p.surfaceBright);
    set(m_surfaceContainerLowest, p.surfaceContainerLowest);
    set(m_surfaceContainerLow, p.surfaceContainerLow);
    set(m_surfaceContainer, p.surfaceContainer);
    set(m_surfaceContainerHigh, p.surfaceContainerHigh);
    set(m_surfaceContainerHighest, p.surfaceContainerHighest);
    set(m_onSurface, p.onSurface);
    set(m_surfaceVariant, p.surfaceVariant);
    set(m_onSurfaceVariant, p.onSurfaceVariant);
    set(m_inverseSurface, p.inverseSurface);
    set(m_inverseOnSurface, p.inverseOnSurface);
    set(m_outline, p.outline);
    set(m_outlineVariant, p.outlineVariant);
    set(m_shadow, p.shadow);
    set(m_scrim, p.scrim);
    set(m_surfaceTint, p.surfaceTint);
    set(m_primary, p.primary);
    set(m_onPrimary, p.onPrimary);
    set(m_primaryContainer, p.primaryContainer);
    set(m_onPrimaryContainer, p.onPrimaryContainer);
    set(m_inversePrimary, p.inversePrimary);
    set(m_secondary, p.secondary);
    set(m_onSecondary, p.onSecondary);
    set(m_secondaryContainer, p.secondaryContainer);
    set(m_onSecondaryContainer, p.onSecondaryContainer);
    set(m_tertiary, p.tertiary);
    set(m_onTertiary, p.onTertiary);
    set(m_tertiaryContainer, p.tertiaryContainer);
    set(m_onTertiaryContainer, p.onTertiaryContainer);
    set(m_error, p.error);
    set(m_onError, p.onError);
    set(m_errorContainer, p.errorContainer);
    set(m_onErrorContainer, p.onErrorContainer);
    set(m_success, p.success);
    set(m_onSuccess, p.onSuccess);
    set(m_successContainer, p.successContainer);
    set(m_onSuccessContainer, p.onSuccessContainer);
    set(m_primaryFixed, p.primaryFixed);
    set(m_primaryFixedDim, p.primaryFixedDim);
    set(m_onPrimaryFixed, p.onPrimaryFixed);
    set(m_onPrimaryFixedVariant, p.onPrimaryFixedVariant);
    set(m_secondaryFixed, p.secondaryFixed);
    set(m_secondaryFixedDim, p.secondaryFixedDim);
    set(m_onSecondaryFixed, p.onSecondaryFixed);
    set(m_onSecondaryFixedVariant, p.onSecondaryFixedVariant);
    set(m_tertiaryFixed, p.tertiaryFixed);
    set(m_tertiaryFixedDim, p.tertiaryFixedDim);
    set(m_onTertiaryFixed, p.onTertiaryFixed);
    set(m_onTertiaryFixedVariant, p.onTertiaryFixedVariant);

    if (changed)
        emit paletteChanged();
}

void CaelestiaColours::applyScheme(const QString &name, const QString &flavour, const QString &primaryHex, const QString &surfaceHex, const QString &bgHex)
{
    m_currentScheme = name.toLower();
    m_currentFlavour = flavour.toLower();

    QColor prim(primaryHex);
    QColor surf(surfaceHex);
    QColor bg(bgHex);

    // Built-in presets matching sample15.png
    if (!prim.isValid() || !surf.isValid()) {
        if (m_currentScheme == QStringLiteral("catppuccin")) {
            if (m_currentFlavour == QStringLiteral("latte")) {
                prim = QColor(QStringLiteral("#8839ef"));
                surf = QColor(QStringLiteral("#eff1f5"));
                bg = QColor(QStringLiteral("#e6e9ef"));
                m_isLight = true;
            } else if (m_currentFlavour == QStringLiteral("frappe")) {
                prim = QColor(QStringLiteral("#ca9ee6"));
                surf = QColor(QStringLiteral("#303446"));
                bg = QColor(QStringLiteral("#292c3c"));
                m_isLight = false;
            } else if (m_currentFlavour == QStringLiteral("macchiato")) {
                prim = QColor(QStringLiteral("#f5bde6"));
                surf = QColor(QStringLiteral("#24273a"));
                bg = QColor(QStringLiteral("#1e2030"));
                m_isLight = false;
            } else { // mocha
                prim = QColor(QStringLiteral("#cba6f7"));
                surf = QColor(QStringLiteral("#1e1e2e"));
                bg = QColor(QStringLiteral("#181825"));
                m_isLight = false;
            }
        } else if (m_currentScheme == QStringLiteral("darkgreen")) {
            if (m_currentFlavour == QStringLiteral("hard")) {
                prim = QColor(QStringLiteral("#a6e3a1"));
                surf = QColor(QStringLiteral("#111a14"));
                bg = QColor(QStringLiteral("#0b120d"));
            } else { // medium
                prim = QColor(QStringLiteral("#94e2d5"));
                surf = QColor(QStringLiteral("#18261e"));
                bg = QColor(QStringLiteral("#101b15"));
            }
            m_isLight = false;
        } else if (m_currentScheme == QStringLiteral("dracula")) {
            prim = QColor(QStringLiteral("#bd93f9"));
            surf = QColor(QStringLiteral("#282a36"));
            bg = QColor(QStringLiteral("#1e1f29"));
            m_isLight = false;
        } else if (m_currentScheme == QStringLiteral("nord")) {
            prim = QColor(QStringLiteral("#88c0d0"));
            surf = QColor(QStringLiteral("#2e3440"));
            bg = QColor(QStringLiteral("#242933"));
            m_isLight = false;
        } else if (m_currentScheme == QStringLiteral("tokyo night") || m_currentScheme == QStringLiteral("tokyonight")) {
            prim = QColor(QStringLiteral("#7aa2f7"));
            surf = QColor(QStringLiteral("#1a1b26"));
            bg = QColor(QStringLiteral("#16161e"));
            m_isLight = false;
        } else {
            prim = QColor(QStringLiteral("#cba6f7"));
            surf = QColor(QStringLiteral("#1e1e2e"));
            bg = QColor(QStringLiteral("#181825"));
            m_isLight = false;
        }
    }

    if (!bg.isValid()) bg = surf.darker(115);

    PaletteEngine::M3Palette p;
    p.primary = prim;
    p.onPrimary = m_isLight ? QColor(Qt::white) : QColor(Qt::black);
    p.primaryContainer = QColor::fromRgbF(prim.redF(), prim.greenF(), prim.blueF(), 0.25f);
    p.onPrimaryContainer = prim;

    p.background = bg;
    p.onBackground = m_isLight ? QColor(QStringLiteral("#1c1b1f")) : QColor(QStringLiteral("#e6e1e5"));

    p.surface = surf;
    p.surfaceDim = surf.darker(110);
    p.surfaceBright = surf.lighter(115);
    p.surfaceContainerLowest = bg;
    p.surfaceContainerLow = surf.darker(105);
    p.surfaceContainer = surf;
    p.surfaceContainerHigh = surf.lighter(110);
    p.surfaceContainerHighest = surf.lighter(120);

    p.onSurface = m_isLight ? QColor(QStringLiteral("#1c1b1f")) : QColor(QStringLiteral("#e6e1e5"));
    p.surfaceVariant = surf.lighter(112);
    p.onSurfaceVariant = m_isLight ? QColor(QStringLiteral("#49454f")) : QColor(QStringLiteral("#cac4d0"));

    p.outline = QColor::fromRgbF(prim.redF(), prim.greenF(), prim.blueF(), 0.35f);
    p.outlineVariant = QColor::fromRgbF(1.0f, 1.0f, 1.0f, 0.12f);
    p.secondary = prim.lighter(115);
    p.onSecondary = p.onPrimary;

    assign(p);
    emit schemeChanged();
}

void CaelestiaColours::setMode(const QString &mode)
{
    const bool light = mode.compare(QStringLiteral("light"), Qt::CaseInsensitive) == 0;
    if (m_isLight != light) {
        m_isLight = light;
        if (m_currentScheme == QStringLiteral("catppuccin")) {
            applyScheme(m_currentScheme, light ? QStringLiteral("latte") : QStringLiteral("mocha"));
        } else {
            applyScheme(m_currentScheme, m_currentFlavour);
        }
    }
}