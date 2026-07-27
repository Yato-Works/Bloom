#pragma once
#include <QObject>
#include <QtGui/QColor>

class ThemeBridge : public QObject {
    Q_OBJECT
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
    Q_PROPERTY(int radiusXS READ radiusXS CONSTANT)
    Q_PROPERTY(int radiusSM READ radiusSM CONSTANT)
    Q_PROPERTY(int radiusMD READ radiusMD CONSTANT)
    Q_PROPERTY(int radiusLG READ radiusLG CONSTANT)
    Q_PROPERTY(int radiusXL READ radiusXL CONSTANT)
    Q_PROPERTY(int radiusSmall READ radiusSmall CONSTANT)
    Q_PROPERTY(int radiusMedium READ radiusMedium CONSTANT)
    Q_PROPERTY(int radiusLarge READ radiusLarge CONSTANT)
    Q_PROPERTY(int radiusFull READ radiusFull CONSTANT)
    Q_PROPERTY(int durationFast READ durationFast CONSTANT)
    Q_PROPERTY(int durationDefault READ durationDefault CONSTANT)
    Q_PROPERTY(int durationSlow READ durationSlow CONSTANT)
    Q_PROPERTY(int fontXS READ fontXS CONSTANT)
    Q_PROPERTY(int fontSM READ fontSM CONSTANT)
    Q_PROPERTY(int fontMD READ fontMD CONSTANT)
    Q_PROPERTY(int fontLG READ fontLG CONSTANT)
    Q_PROPERTY(int fontXL READ fontXL CONSTANT)
    Q_PROPERTY(int font2XL READ font2XL CONSTANT)
    Q_PROPERTY(int font3XL READ font3XL CONSTANT)
    Q_PROPERTY(QColor background READ background CONSTANT)
    Q_PROPERTY(QColor surface READ surface CONSTANT)
    Q_PROPERTY(QColor surfaceRaised READ surfaceRaised CONSTANT)
    Q_PROPERTY(QColor surfaceContainer READ surfaceContainer CONSTANT)
    Q_PROPERTY(QColor surfaceContainerHigh READ surfaceContainerHigh CONSTANT)
    Q_PROPERTY(QColor border READ border CONSTANT)
    Q_PROPERTY(QColor outline READ outline CONSTANT)
    Q_PROPERTY(QColor outlineVariant READ outlineVariant CONSTANT)
    Q_PROPERTY(QColor text READ text CONSTANT)
    Q_PROPERTY(QColor textMuted READ textMuted CONSTANT)
    Q_PROPERTY(QColor onSurfaceMuted READ onSurfaceMuted CONSTANT)
    Q_PROPERTY(QColor primary READ primary CONSTANT)
    Q_PROPERTY(QColor primaryContainer READ primaryContainer CONSTANT)
    Q_PROPERTY(QColor accent READ accent CONSTANT)
    Q_PROPERTY(QColor secondaryContainer READ secondaryContainer CONSTANT)
    Q_PROPERTY(QColor tertiary READ tertiary CONSTANT)
    Q_PROPERTY(QColor tertiaryContainer READ tertiaryContainer CONSTANT)
    Q_PROPERTY(QColor success READ success CONSTANT)
    Q_PROPERTY(QColor warning READ warning CONSTANT)
    Q_PROPERTY(QColor error READ error CONSTANT)
    Q_PROPERTY(QColor onPrimary READ onPrimary CONSTANT)
    Q_PROPERTY(qreal shadowOpacity READ shadowOpacity CONSTANT)
    Q_PROPERTY(int shadowRadius READ shadowRadius CONSTANT)
    Q_PROPERTY(int shadowOffsetY READ shadowOffsetY CONSTANT)
    Q_PROPERTY(int dashboardMargin READ dashboardMargin CONSTANT)
    Q_PROPERTY(qreal mediaTabWidth READ mediaTabWidth CONSTANT)
    Q_PROPERTY(qreal mediaTabHeight READ mediaTabHeight CONSTANT)
    Q_PROPERTY(qreal mediaSectionWidth READ mediaSectionWidth CONSTANT)
    Q_PROPERTY(qreal perfPlaceholderWidth READ perfPlaceholderWidth CONSTANT)

public:
    explicit ThemeBridge(QObject *parent = nullptr) : QObject(parent) {}

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
    int radiusXS() const { return 10; }
    int radiusSM() const { return 12; }
    int radiusMD() const { return 16; }
    int radiusLG() const { return 22; }
    int radiusXL() const { return 28; }
    int radiusSmall() const { return 12; }
    int radiusMedium() const { return 16; }
    int radiusLarge() const { return 22; }
    int radiusFull() const { return 9999; }
    int durationFast() const { return 120; }
    int durationDefault() const { return 200; }
    int durationSlow() const { return 350; }
    int fontXS() const { return 11; }
    int fontSM() const { return 12; }
    int fontMD() const { return 13; }
    int fontLG() const { return 16; }
    int fontXL() const { return 20; }
    int font2XL() const { return 24; }
    int font3XL() const { return 36; }

    QColor background() const { return QColor("#0B0C0F"); }
    QColor surface() const { return QColor("#141518"); }
    QColor surfaceRaised() const { return QColor("#1C1D22"); }
    QColor surfaceContainer() const { return QColor("#222328"); }
    QColor surfaceContainerHigh() const { return QColor("#2A2B31"); }
    QColor border() const { return QColor("#87665a"); }
    QColor outline() const { return QColor("#3A3B40"); }
    QColor outlineVariant() const { return QColor("#23242A"); }
    QColor text() const { return QColor("#f2e1d5"); }
    QColor textMuted() const { return QColor("#c0aaa0"); }
    QColor onSurfaceMuted() const { return QColor("#5F616B"); }
    QColor primary() const { return QColor("#ffad6d"); }
    QColor primaryContainer() const { return QColor("#FF75B722"); }
    QColor accent() const { return QColor("#ef8d71"); }
    QColor secondaryContainer() const { return QColor("#9AA3FF18"); }
    QColor tertiary() const { return QColor("#FFB280"); }
    QColor tertiaryContainer() const { return QColor("#FFB28018"); }
    QColor success() const { return QColor("#c3c66e"); }
    QColor warning() const { return QColor("#f5bf62"); }
    QColor error() const { return QColor("#FF9B9B"); }
    QColor onPrimary() const { return QColor("#0B0C0F"); }

    qreal shadowOpacity() const { return 0.35; }
    int shadowRadius() const { return 18; }
    int shadowOffsetY() const { return 6; }
    int dashboardMargin() const { return 18; }
    qreal mediaTabWidth() const { return 720; }
    qreal mediaTabHeight() const { return 340; }
    qreal mediaSectionWidth() const { return 220; }
    qreal perfPlaceholderWidth() const { return 520; }
};
