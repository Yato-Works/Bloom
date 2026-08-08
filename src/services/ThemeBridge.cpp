#include "ThemeBridge.h"

ThemeBridge::ThemeBridge(QObject *parent)
    : QObject(parent)
{
}

void ThemeBridge::setThemeName(const QString &name)
{
    setThemeByName(name);
}

void ThemeBridge::setThemeByName(const QString &name)
{
    const QString n = name.trimmed();
    if (m_themeName.compare(n, Qt::CaseInsensitive) != 0) {
        m_themeName = n;
        emit themeChanged();
    }
}

void ThemeBridge::toggleTheme()
{
    const QStringList themes = availableThemes();
    int idx = 0;
    for (int i = 0; i < themes.size(); ++i) {
        if (themes.at(i).compare(m_themeName, Qt::CaseInsensitive) == 0) {
            idx = (i + 1) % themes.size();
            break;
        }
    }
    setThemeByName(themes.at(idx));
}

QStringList ThemeBridge::availableThemes() const
{
    return {
        QStringLiteral("Bloom Dark"),
        QStringLiteral("Bloom Light"),
        QStringLiteral("Cyberpunk Mint"),
        QStringLiteral("Tokyo Night"),
        QStringLiteral("Mocha"),
        QStringLiteral("Macchiato"),
        QStringLiteral("Frappé"),
        QStringLiteral("Rose Pine"),
        QStringLiteral("Nord Frost"),
        QStringLiteral("Emerald Aurora"),
        QStringLiteral("Latte")
    };
}

// ===== Color Implementation =====

// Your Arch setup palette:
// Base: 漆黒〜深みのあるダークグレー (transparent floating cards)
// Accent: 淡いミントブルー/シアン (#80D8FF 〜 #A7F3D0)

QColor ThemeBridge::background() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#F5F5F7");
    if (m_themeName.compare(QStringLiteral("Cyberpunk Mint"), Qt::CaseInsensitive) == 0) return QColor("#050A10");
    if (m_themeName.compare(QStringLiteral("Tokyo Night"), Qt::CaseInsensitive) == 0) return QColor("#16161E");
    if (m_themeName.compare(QStringLiteral("Mocha"), Qt::CaseInsensitive) == 0) return QColor("#0B0D14");
    if (m_themeName.compare(QStringLiteral("Macchiato"), Qt::CaseInsensitive) == 0) return QColor("#181926");
    if (m_themeName.compare(QStringLiteral("Frappé"), Qt::CaseInsensitive) == 0) return QColor("#292C3C");
    if (m_themeName.compare(QStringLiteral("Rose Pine"), Qt::CaseInsensitive) == 0) return QColor("#191724");
    if (m_themeName.compare(QStringLiteral("Nord Frost"), Qt::CaseInsensitive) == 0) return QColor("#2E3440");
    if (m_themeName.compare(QStringLiteral("Emerald Aurora"), Qt::CaseInsensitive) == 0) return QColor("#0D1B1E");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#E6E9EF");
    // Default: Bloom Dark - your Arch漆黒
    return QColor("#080A0E");
}

QColor ThemeBridge::surface() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#FFFFFF");
    if (m_themeName.compare(QStringLiteral("Cyberpunk Mint"), Qt::CaseInsensitive) == 0) return QColor("#0C141F");
    if (m_themeName.compare(QStringLiteral("Tokyo Night"), Qt::CaseInsensitive) == 0) return QColor("#1A1B26");
    if (m_themeName.compare(QStringLiteral("Mocha"), Qt::CaseInsensitive) == 0) return QColor("#11131C");
    if (m_themeName.compare(QStringLiteral("Macchiato"), Qt::CaseInsensitive) == 0) return QColor("#1E2030");
    if (m_themeName.compare(QStringLiteral("Frappé"), Qt::CaseInsensitive) == 0) return QColor("#303446");
    if (m_themeName.compare(QStringLiteral("Rose Pine"), Qt::CaseInsensitive) == 0) return QColor("#1F1D2E");
    if (m_themeName.compare(QStringLiteral("Nord Frost"), Qt::CaseInsensitive) == 0) return QColor("#3B4252");
    if (m_themeName.compare(QStringLiteral("Emerald Aurora"), Qt::CaseInsensitive) == 0) return QColor("#152A2D");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#EFF1F5");
    // Default: Bloom Dark - floating card surface
    return QColor("#0D1218");
}

QColor ThemeBridge::surfaceRaised() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#FFFFFF");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#FFFFFF");
    return QColor("#121A22"); // Slightly elevated
}

QColor ThemeBridge::surfaceContainer() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#E8E8ED");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#DCE0E8");
    return QColor("#151D26"); // Container level
}

QColor ThemeBridge::surfaceContainerHigh() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#DADAE0");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#CCD0DA");
    return QColor("#1A2430"); // Higher container
}

QColor ThemeBridge::border() const
{
    const QColor p = primary();
    return QColor(p.red(), p.green(), p.blue(), 55); // More visible accent border
}

QColor ThemeBridge::outline() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#70707A");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#70707A");
    return QColor("#2D3748");
}

QColor ThemeBridge::outlineVariant() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#C0C0C8");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#C0C0C8");
    return QColor("#1E2A38");
}

QColor ThemeBridge::text() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#1D1D1F");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#4C4F69");
    return QColor("#E8EAED"); // High contrast on dark
}

QColor ThemeBridge::textMuted() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#6E6E73");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#6C6F85");
    return QColor("#8B94A8"); // Muted but readable
}

QColor ThemeBridge::onSurfaceMuted() const
{
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#8E8E93");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#6C6F85");
    return QColor("#7A8498");
}

QColor ThemeBridge::primary() const
{
    // Your mint cyan accent: #80D8FF ~ #A7F3D0
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#007A8A");
    if (m_themeName.compare(QStringLiteral("Cyberpunk Mint"), Qt::CaseInsensitive) == 0) return QColor("#00F0FF");
    if (m_themeName.compare(QStringLiteral("Tokyo Night"), Qt::CaseInsensitive) == 0) return QColor("#7AA2F7");
    if (m_themeName.compare(QStringLiteral("Mocha"), Qt::CaseInsensitive) == 0) return QColor("#89B4FA");
    if (m_themeName.compare(QStringLiteral("Macchiato"), Qt::CaseInsensitive) == 0) return QColor("#8AADF4");
    if (m_themeName.compare(QStringLiteral("Frappé"), Qt::CaseInsensitive) == 0) return QColor("#85C1DC");
    if (m_themeName.compare(QStringLiteral("Rose Pine"), Qt::CaseInsensitive) == 0) return QColor("#EBBBBA");
    if (m_themeName.compare(QStringLiteral("Nord Frost"), Qt::CaseInsensitive) == 0) return QColor("#88C0D0");
    if (m_themeName.compare(QStringLiteral("Emerald Aurora"), Qt::CaseInsensitive) == 0) return QColor("#50FA7B");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#1E66F5");
    // Default: Bloom Dark - your mint cyan
    return QColor("#80D8FF");
}

QColor ThemeBridge::primaryContainer() const
{
    const QColor p = primary();
    return QColor(p.red(), p.green(), p.blue(), 45);
}

QColor ThemeBridge::accent() const
{
    // Secondary accent - slightly greener mint
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#009688");
    if (m_themeName.compare(QStringLiteral("Cyberpunk Mint"), Qt::CaseInsensitive) == 0) return QColor("#A7F3D0");
    if (m_themeName.compare(QStringLiteral("Tokyo Night"), Qt::CaseInsensitive) == 0) return QColor("#BB9AF7");
    if (m_themeName.compare(QStringLiteral("Mocha"), Qt::CaseInsensitive) == 0) return QColor("#CBA6F7");
    if (m_themeName.compare(QStringLiteral("Macchiato"), Qt::CaseInsensitive) == 0) return QColor("#F5BDE6");
    if (m_themeName.compare(QStringLiteral("Frappé"), Qt::CaseInsensitive) == 0) return QColor("#CA9EE6");
    if (m_themeName.compare(QStringLiteral("Rose Pine"), Qt::CaseInsensitive) == 0) return QColor("#C4A7E7");
    if (m_themeName.compare(QStringLiteral("Nord Frost"), Qt::CaseInsensitive) == 0) return QColor("#B48EAD");
    if (m_themeName.compare(QStringLiteral("Emerald Aurora"), Qt::CaseInsensitive) == 0) return QColor("#FF79C6");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#8839EF");
    // Default: Bloom Dark - mint green highlight
    return QColor("#A7F3D0");
}

QColor ThemeBridge::secondaryContainer() const
{
    const QColor a = accent();
    return QColor(a.red(), a.green(), a.blue(), 40);
}

QColor ThemeBridge::tertiary() const
{
    // Purple/media accent
    if (m_themeName.compare(QStringLiteral("Bloom Light"), Qt::CaseInsensitive) == 0) return QColor("#7C3AED");
    if (m_themeName.compare(QStringLiteral("Cyberpunk Mint"), Qt::CaseInsensitive) == 0) return QColor("#C084FC");
    if (m_themeName.compare(QStringLiteral("Tokyo Night"), Qt::CaseInsensitive) == 0) return QColor("#9ECE6A");
    if (m_themeName.compare(QStringLiteral("Mocha"), Qt::CaseInsensitive) == 0) return QColor("#A6E3A1");
    if (m_themeName.compare(QStringLiteral("Macchiato"), Qt::CaseInsensitive) == 0) return QColor("#A6DA95");
    if (m_themeName.compare(QStringLiteral("Frappé"), Qt::CaseInsensitive) == 0) return QColor("#A6D189");
    if (m_themeName.compare(QStringLiteral("Rose Pine"), Qt::CaseInsensitive) == 0) return QColor("#9CCFD8");
    if (m_themeName.compare(QStringLiteral("Nord Frost"), Qt::CaseInsensitive) == 0) return QColor("#A3BE8C");
    if (m_themeName.compare(QStringLiteral("Emerald Aurora"), Qt::CaseInsensitive) == 0) return QColor("#8BE9FD");
    if (m_themeName.compare(QStringLiteral("Latte"), Qt::CaseInsensitive) == 0) return QColor("#40A02B");
    // Default: Bloom Dark - warm green
    return QColor("#A6E3A1");
}

QColor ThemeBridge::tertiaryContainer() const
{
    const QColor t = tertiary();
    return QColor(t.red(), t.green(), t.blue(), 40);
}

QColor ThemeBridge::success() const { return tertiary(); }
QColor ThemeBridge::warning() const { return QColor("#F9E2AF"); }
QColor ThemeBridge::error() const { return QColor("#F38BA8"); }
QColor ThemeBridge::onPrimary() const { return background(); }