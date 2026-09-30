#pragma once

#include <QFont>
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>

class FontBuilder : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

public:
    explicit FontBuilder(const QFont& base, QObject* parent = nullptr)
        : QObject(parent), m_font(base) {}

    QFont build() const { return m_font; }

    FontBuilder* size(int pt) {
        m_font.setPointSize(pt);
        return this;
    }
    FontBuilder* weight(int w) {
        m_font.setWeight(static_cast<QFont::Weight>(w));
        return this;
    }
    FontBuilder* vaxes(const QVariantMap& axes) {
        for (auto it = axes.constBegin(); it != axes.constEnd(); ++it) {
            if (auto tag = QFont::Tag::fromString(it.key()))
                m_font.setVariableAxis(*tag, it.value().toFloat());
        }
        return this;
    }
    FontBuilder* fill(qreal fill) {
        if (auto tag = QFont::Tag::fromString(QStringLiteral("FILL")))
            m_font.setVariableAxis(tag, fill);
        return this;
    }
    FontBuilder* grade(int g) {
        if (auto tag = QFont::Tag::fromString(QStringLiteral("GRAD")))
            m_font.setVariableAxis(tag, static_cast<float>(g));
        return this;
    }

private:
    QFont m_font;
};
