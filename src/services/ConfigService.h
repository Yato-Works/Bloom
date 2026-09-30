#pragma once

#include <QObject>
#include <QStringList>

class ConfigService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString accentColor READ accentColor NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal overlayOpacity READ overlayOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QString backgroundPath READ backgroundPath NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QString profile READ profile WRITE setProfile NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QString layoutName READ layoutName WRITE setLayoutName NOTIFY appearanceChanged FINAL)

public:
    explicit ConfigService(QObject *parent = nullptr);
    [[nodiscard]] QString accentColor() const;
    [[nodiscard]] qreal overlayOpacity() const noexcept;
    [[nodiscard]] QString backgroundPath() const;

    Q_INVOKABLE void setAccentColor(const QString &color);
    Q_INVOKABLE void setOverlayOpacity(qreal opacity);
    Q_INVOKABLE void setBackgroundPath(const QString &path);
    [[nodiscard]] QString profile() const;
    [[nodiscard]] QString themeName() const;
    [[nodiscard]] QString layoutName() const;
    Q_INVOKABLE void setProfile(const QString &profile);
    Q_INVOKABLE void setThemeName(const QString &name);
    Q_INVOKABLE void setLayoutName(const QString &layout);

signals:
    void appearanceChanged();
    void layoutChanged();

private:
    void load();
    void save() const;

    QString m_accentColor {QStringLiteral("#ffad6d")};
    qreal m_overlayOpacity {0.96};
    QString m_backgroundPath;
    QString m_profile {QStringLiteral("Caelestia")};
    QString m_themeName {QStringLiteral("Mocha")};
    QString m_layoutName {QStringLiteral("Caelestia")};
};
