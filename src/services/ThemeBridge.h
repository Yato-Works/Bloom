#pragma once
#include <QObject>
#include <QtGui/QColor>
#include <QStringList>

class ThemeBridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeChanged)

    // Spacing & Layout
    Q_PROPERTY(int spacingXXS READ spacingXXS CONSTANT)
    Q_PROPERTY(int spacingXS READ spacingXS CONSTANT)
    Q_PROPERTY(int spacingSM READ spacingSM CONSTANT)
    Q_PROPERTY(int spacingMD READ spacingMD CONSTANT)
    Q_PROPERTY(int spacingLG READ spacingLG CONSTANT)
    Q_PROPERTY(int spacingXL READ spacingXL CONSTANT)
    Q_PROPERTY(int spacing2XL READ spacing2XL CONSTANT)
    Q_PROPERTY(int paddingMD READ paddingMD CONSTANT)
    Q_PROPERTY(int paddingLG READ paddingLG CONSTANT)
    Q_PROPERTY(int paddingXL READ paddingXL CONSTANT)

    // Border Radius (Material You M3 style)
    Q_PROPERTY(int radiusXS READ radiusXS CONSTANT)
    Q_PROPERTY(int radiusSM READ radiusSM CONSTANT)
    Q_PROPERTY(int radiusMD READ radiusMD CONSTANT)
    Q_PROPERTY(int radiusLG READ radiusLG CONSTANT)
    Q_PROPERTY(int radiusXL READ radiusXL CONSTANT)
    Q_PROPERTY(int radiusSmall READ radiusSmall CONSTANT)
    Q_PROPERTY(int radiusMedium READ radiusMedium CONSTANT)
    Q_PROPERTY(int radiusLarge READ radiusLarge CONSTANT)
    Q_PROPERTY(int radiusFull READ radiusFull CONSTANT)

    // Animation Duration
    Q_PROPERTY(int durationFast READ durationFast CONSTANT)
    Q_PROPERTY(int durationDefault READ durationDefault CONSTANT)
    Q_PROPERTY(int durationSlow READ durationSlow CONSTANT)

    // Typography
    Q_PROPERTY(int fontXS READ fontXS CONSTANT)
    Q_PROPERTY(int fontSM READ fontSM CONSTANT)
    Q_PROPERTY(int fontMD READ fontMD CONSTANT)
    Q_PROPERTY(int fontLG READ fontLG CONSTANT)
    Q_PROPERTY(int fontXL READ fontXL CONSTANT)
    Q_PROPERTY(int font2XL READ font2XL CONSTANT)
    Q_PROPERTY(int font3XL READ font3XL CONSTANT)

    // Elevation & Shadows (Material You inspired)
    Q_PROPERTY(qreal shadowOpacity READ shadowOpacity CONSTANT)
    Q_PROPERTY(int shadowRadius READ shadowRadius CONSTANT)
    Q_PROPERTY(int shadowOffsetY READ shadowOffsetY CONSTANT)
    Q_PROPERTY(qreal shadowLevel1 READ shadowLevel1 CONSTANT)
    Q_PROPERTY(int shadowRadiusLevel1 READ shadowRadiusLevel1 CONSTANT)
    Q_PROPERTY(qreal shadowLevel2 READ shadowLevel2 CONSTANT)
    Q_PROPERTY(int shadowRadiusLevel2 READ shadowRadiusLevel2 CONSTANT)
    Q_PROPERTY(qreal shadowLevel3 READ shadowLevel3 CONSTANT)
    Q_PROPERTY(int shadowRadiusLevel3 READ shadowRadiusLevel3 CONSTANT)

    // Layout constants
    Q_PROPERTY(int dashboardMargin READ dashboardMargin CONSTANT)
    Q_PROPERTY(qreal mediaTabWidth READ mediaTabWidth CONSTANT)
    Q_PROPERTY(qreal mediaTabHeight READ mediaTabHeight CONSTANT)
    Q_PROPERTY(qreal mediaSectionWidth READ mediaSectionWidth CONSTANT)
    Q_PROPERTY(qreal perfPlaceholderWidth READ perfPlaceholderWidth CONSTANT)

    // Color tokens
    Q_PROPERTY(QColor background READ background NOTIFY themeChanged)
    Q_PROPERTY(QColor surface READ surface NOTIFY themeChanged)
    Q_PROPERTY(QColor surfaceRaised READ surfaceRaised NOTIFY themeChanged)
    Q_PROPERTY(QColor surfaceContainer READ surfaceContainer NOTIFY themeChanged)
    Q_PROPERTY(QColor surfaceContainerHigh READ surfaceContainerHigh NOTIFY themeChanged)
    Q_PROPERTY(QColor border READ border NOTIFY themeChanged)
    Q_PROPERTY(QColor outline READ outline NOTIFY themeChanged)
    Q_PROPERTY(QColor outlineVariant READ outlineVariant NOTIFY themeChanged)
    Q_PROPERTY(QColor text READ text NOTIFY themeChanged)
    Q_PROPERTY(QColor textMuted READ textMuted NOTIFY themeChanged)
    Q_PROPERTY(QColor onSurfaceMuted READ onSurfaceMuted NOTIFY themeChanged)
    Q_PROPERTY(QColor primary READ primary NOTIFY themeChanged)
    Q_PROPERTY(QColor primaryContainer READ primaryContainer NOTIFY themeChanged)
    Q_PROPERTY(QColor accent READ accent NOTIFY themeChanged)
    Q_PROPERTY(QColor secondaryContainer READ secondaryContainer NOTIFY themeChanged)
    Q_PROPERTY(QColor tertiary READ tertiary NOTIFY themeChanged)
    Q_PROPERTY(QColor tertiaryContainer READ tertiaryContainer NOTIFY themeChanged)
    Q_PROPERTY(QColor success READ success NOTIFY themeChanged)
    Q_PROPERTY(QColor warning READ warning NOTIFY themeChanged)
    Q_PROPERTY(QColor error READ error NOTIFY themeChanged)
    Q_PROPERTY(QColor onPrimary READ onPrimary NOTIFY themeChanged)

public:
    explicit ThemeBridge(QObject *parent = nullptr);

    QString themeName() const { return m_themeName; }
    void setThemeName(const QString &name);

    Q_INVOKABLE void setThemeByName(const QString &name);
    Q_INVOKABLE void toggleTheme();
    Q_INVOKABLE QStringList availableThemes() const;

    // Spacing
    int spacingXXS() const { return 4; }
    int spacingXS() const { return 6; }
    int spacingSM() const { return 8; }
    int spacingMD() const { return 12; }
    int spacingLG() const { return 16; }
    int spacingXL() const { return 20; }
    int spacing2XL() const { return 24; }
    int paddingMD() const { return 16; }
    int paddingLG() const { return 20; }
    int paddingXL() const { return 24; }

    // Border Radius
    int radiusXS() const { return 12; }
    int radiusSM() const { return 14; }
    int radiusMD() const { return 20; }
    int radiusLG() const { return 24; }
    int radiusXL() const { return 28; }
    int radiusSmall() const { return 12; }
    int radiusMedium() const { return 20; }
    int radiusLarge() const { return 24; }
    int radiusFull() const { return 9999; }

    // Duration
    int durationFast() const { return 120; }
    int durationDefault() const { return 200; }
    int durationSlow() const { return 350; }

    // Fonts
    int fontXS() const { return 11; }
    int fontSM() const { return 12; }
    int fontMD() const { return 13; }
    int fontLG() const { return 15; }
    int fontXL() const { return 18; }
    int font2XL() const { return 22; }
    int font3XL() const { return 28; }

    // Shadows (material elevations: 1dp, 2dp, 3dp)
    qreal shadowOpacity() const { return 0.35; }
    int shadowRadius() const { return 18; }
    int shadowOffsetY() const { return 6; }
    qreal shadowLevel1() const { return 0.05; }
    int shadowRadiusLevel1() const { return 8; }
    qreal shadowLevel2() const { return 0.15; }
    int shadowRadiusLevel2() const { return 16; }
    qreal shadowLevel3() const { return 0.35; }
    int shadowRadiusLevel3() const { return 24; }

    // Layout
    int dashboardMargin() const { return 18; }
    qreal mediaTabWidth() const { return 720; }
    qreal mediaTabHeight() const { return 340; }
    qreal mediaSectionWidth() const { return 220; }
    qreal perfPlaceholderWidth() const { return 520; }

    // Colors
    QColor background() const;
    QColor surface() const;
    QColor surfaceRaised() const;
    QColor surfaceContainer() const;
    QColor surfaceContainerHigh() const;
    QColor border() const;
    QColor outline() const;
    QColor outlineVariant() const;
    QColor text() const;
    QColor textMuted() const;
    QColor onSurfaceMuted() const;
    QColor primary() const;
    QColor primaryContainer() const;
    QColor accent() const;
    QColor secondaryContainer() const;
    QColor tertiary() const;
    QColor tertiaryContainer() const;
    QColor success() const;
    QColor warning() const;
    QColor error() const;
    QColor onPrimary() const;

signals:
    void themeChanged();

private:
    QString m_themeName = QStringLiteral("Bloom Dark");
};
