#pragma once

#include <QObject>
#include <QStringList>

class ConfigService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString accentColor READ accentColor NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal overlayOpacity READ overlayOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QString backgroundPath READ backgroundPath NOTIFY appearanceChanged FINAL)

public:
    explicit ConfigService(QObject *parent = nullptr);
    [[nodiscard]] QString accentColor() const;
    [[nodiscard]] qreal overlayOpacity() const noexcept;
    [[nodiscard]] QString backgroundPath() const;

    Q_INVOKABLE void setAccentColor(const QString &color);
    Q_INVOKABLE void setOverlayOpacity(qreal opacity);
    Q_INVOKABLE void setBackgroundPath(const QString &path);

signals:
    void appearanceChanged();

private:
    void load();
    void save() const;

    QString m_accentColor {QStringLiteral("#ffad6d")};
    qreal m_overlayOpacity {0.96};
    QString m_backgroundPath;
};

