#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QFont>

class StyleSet : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Internal to CaelestiaTokens")

    Q_PROPERTY(QFont large READ large CONSTANT FINAL)
    Q_PROPERTY(QFont medium READ medium CONSTANT FINAL)
    Q_PROPERTY(QFont small READ small CONSTANT FINAL)

public:
    explicit StyleSet(const QFont& l, const QFont& m, const QFont& s, QObject* parent = nullptr)
        : QObject(parent), m_large(l), m_medium(m), m_small(s) {}

    [[nodiscard]] QFont large() const { return m_large; }
    [[nodiscard]] QFont medium() const { return m_medium; }
    [[nodiscard]] QFont small() const { return m_small; }

private:
    QFont m_large;
    QFont m_medium;
    QFont m_small;
};

class IconStyleSet : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Internal to CaelestiaTokens")

    Q_PROPERTY(QFont extraLarge READ extraLarge CONSTANT FINAL)
    Q_PROPERTY(QFont large READ large CONSTANT FINAL)
    Q_PROPERTY(QFont medium READ medium CONSTANT FINAL)
    Q_PROPERTY(QFont small READ small CONSTANT FINAL)

public:
    explicit IconStyleSet(const QFont& xl, const QFont& l, const QFont& m, const QFont& s, QObject* parent = nullptr)
        : QObject(parent), m_extraLarge(xl), m_large(l), m_medium(m), m_small(s) {}

    [[nodiscard]] QFont extraLarge() const { return m_extraLarge; }
    [[nodiscard]] QFont large() const { return m_large; }
    [[nodiscard]] QFont medium() const { return m_medium; }
    [[nodiscard]] QFont small() const { return m_small; }

private:
    QFont m_extraLarge;
    QFont m_large;
    QFont m_medium;
    QFont m_small;
};

class FontBag : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Internal to CaelestiaTokens")

    Q_PROPERTY(QObject* headline READ headline CONSTANT FINAL)
    Q_PROPERTY(QObject* title READ title CONSTANT FINAL)
    Q_PROPERTY(QObject* body READ body CONSTANT FINAL)
    Q_PROPERTY(QObject* label READ label CONSTANT FINAL)
    Q_PROPERTY(QObject* mono READ mono CONSTANT FINAL)
    Q_PROPERTY(QObject* icon READ icon CONSTANT FINAL)

public:
    StyleSet* headline_ = nullptr;
    StyleSet* title_ = nullptr;
    StyleSet* body_ = nullptr;
    StyleSet* label_ = nullptr;
    StyleSet* mono_ = nullptr;
    IconStyleSet* icon_ = nullptr;

    explicit FontBag(QObject* parent = nullptr) : QObject(parent) {}
    ~FontBag() override {
        qDeleteAll(children());
    }

    [[nodiscard]] QObject* headline() const { return headline_; }
    [[nodiscard]] QObject* title() const    { return title_; }
    [[nodiscard]] QObject* body() const     { return body_; }
    [[nodiscard]] QObject* label() const    { return label_; }
    [[nodiscard]] QObject* mono() const     { return mono_; }
    [[nodiscard]] QObject* icon() const     { return icon_; }
};

class CaelestiaTokens : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Tokens)

    Q_PROPERTY(int spacingExtraSmall READ spacingExtraSmall CONSTANT FINAL)
    Q_PROPERTY(int spacingSmall READ spacingSmall CONSTANT FINAL)
    Q_PROPERTY(int spacingMedium READ spacingMedium CONSTANT FINAL)
    Q_PROPERTY(int spacingLarge READ spacingLarge CONSTANT FINAL)
    Q_PROPERTY(int spacingLargeIncreased READ spacingLargeIncreased CONSTANT FINAL)
    Q_PROPERTY(int spacingExtraLarge READ spacingExtraLarge CONSTANT FINAL)
    Q_PROPERTY(int spacingExtraLargeIncreased READ spacingExtraLargeIncreased CONSTANT FINAL)

    Q_PROPERTY(int roundingExtraSmall READ roundingExtraSmall CONSTANT FINAL)
    Q_PROPERTY(int roundingSmall READ roundingSmall CONSTANT FINAL)
    Q_PROPERTY(int roundingMedium READ roundingMedium CONSTANT FINAL)
    Q_PROPERTY(int roundingLarge READ roundingLarge CONSTANT FINAL)
    Q_PROPERTY(int roundingLargeIncreased READ roundingLargeIncreased CONSTANT FINAL)
    Q_PROPERTY(int roundingExtraLarge READ roundingExtraLarge CONSTANT FINAL)
    Q_PROPERTY(int roundingExtraLargeIncreased READ roundingExtraLargeIncreased CONSTANT FINAL)

    Q_PROPERTY(int paddingExtraSmall READ paddingExtraSmall CONSTANT FINAL)
    Q_PROPERTY(int paddingSmall READ paddingSmall CONSTANT FINAL)
    Q_PROPERTY(int paddingMedium READ paddingMedium CONSTANT FINAL)
    Q_PROPERTY(int paddingLarge READ paddingLarge CONSTANT FINAL)
    Q_PROPERTY(int paddingLargeIncreased READ paddingLargeIncreased CONSTANT FINAL)
    Q_PROPERTY(int paddingExtraLarge READ paddingExtraLarge CONSTANT FINAL)
    Q_PROPERTY(int paddingExtraLargeIncreased READ paddingExtraLargeIncreased CONSTANT FINAL)

    Q_PROPERTY(QObject* font READ font CONSTANT FINAL)

    Q_PROPERTY(bool transparencyEnabled READ transparencyEnabled CONSTANT FINAL)
    Q_PROPERTY(qreal transparencyBase READ transparencyBase CONSTANT FINAL)
    Q_PROPERTY(qreal transparencyLayers READ transparencyLayers CONSTANT FINAL)

public:
    explicit CaelestiaTokens(QObject* parent = nullptr);
    ~CaelestiaTokens() override = default;

    [[nodiscard]] int spacingExtraSmall() const { return 4; }
    [[nodiscard]] int spacingSmall() const { return 8; }
    [[nodiscard]] int spacingMedium() const { return 12; }
    [[nodiscard]] int spacingLarge() const { return 16; }
    [[nodiscard]] int spacingLargeIncreased() const { return 20; }
    [[nodiscard]] int spacingExtraLarge() const { return 28; }
    [[nodiscard]] int spacingExtraLargeIncreased() const { return 32; }

    [[nodiscard]] int roundingExtraSmall() const { return 4; }
    [[nodiscard]] int roundingSmall() const { return 8; }
    [[nodiscard]] int roundingMedium() const { return 12; }
    [[nodiscard]] int roundingLarge() const { return 16; }
    [[nodiscard]] int roundingLargeIncreased() const { return 20; }
    [[nodiscard]] int roundingExtraLarge() const { return 28; }
    [[nodiscard]] int roundingExtraLargeIncreased() const { return 32; }

    [[nodiscard]] int paddingExtraSmall() const { return 4; }
    [[nodiscard]] int paddingSmall() const { return 8; }
    [[nodiscard]] int paddingMedium() const { return 12; }
    [[nodiscard]] int paddingLarge() const { return 16; }
    [[nodiscard]] int paddingLargeIncreased() const { return 20; }
    [[nodiscard]] int paddingExtraLarge() const { return 28; }
    [[nodiscard]] int paddingExtraLargeIncreased() const { return 32; }

    [[nodiscard]] bool transparencyEnabled() const { return false; }
    [[nodiscard]] qreal transparencyBase() const { return 0.85; }
    [[nodiscard]] qreal transparencyLayers() const { return 0.4; }

    [[nodiscard]] QObject* font() const { return m_font; }

private:
    FontBag* m_font = nullptr;
};
