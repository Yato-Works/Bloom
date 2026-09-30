#include "CaelestiaTokens.h"
#include <QFontDatabase>

CaelestiaTokens::CaelestiaTokens(QObject* parent)
    : QObject(parent)
    , m_font(new FontBag(this))
{
    const QString sans = QStringLiteral("Segoe UI");
    const QString mono = QStringLiteral("Cascadia Code");
    // Must match the family name embedded in assets/fonts/MaterialSymbolsOutlined.ttf
    // (loaded at startup in main.cpp).
    const QString icons = QStringLiteral("Material Symbols Outlined");

    auto style = [&](const QString& family, int lsz, int msz, int ssz, QFont::Weight lw, QFont::Weight mw, QFont::Weight sw) -> StyleSet* {
        QFont fl(family, lsz); fl.setWeight(lw);
        QFont fm(family, msz); fm.setWeight(mw);
        QFont fs(family, ssz); fs.setWeight(sw);
        return new StyleSet(fl, fm, fs, m_font);
    };

    auto iconStyle = [&](const QString& family, int xlsz, int lsz, int msz, int ssz) -> IconStyleSet* {
        QFont fxl(family, xlsz);
        QFont fl(family, lsz);
        QFont fm(family, msz);
        QFont fs(family, ssz);
        return new IconStyleSet(fxl, fl, fm, fs, m_font);
    };

    m_font->headline_ = style(sans, 32, 28, 24, QFont::Medium, QFont::Medium, QFont::Medium);
    m_font->title_    = style(sans, 22, 16, 14, QFont::Medium, QFont::Medium, QFont::Normal);
    m_font->body_     = style(sans, 16, 14, 12, QFont::Normal, QFont::Normal, QFont::Normal);
    m_font->label_    = style(sans, 14, 12, 11, QFont::Medium, QFont::Medium, QFont::Normal);
    m_font->mono_     = style(mono,  16, 14, 12, QFont::Normal, QFont::Normal, QFont::Normal);
    m_font->icon_     = iconStyle(icons,
                                  static_cast<int>(48 / 1.33),
                                  static_cast<int>(32 / 1.33),
                                  static_cast<int>(24 / 1.33),
                                  static_cast<int>(20 / 1.33));
}
