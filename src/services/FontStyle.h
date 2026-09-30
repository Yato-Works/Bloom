#pragma once

#include <QFont>
#include <QObject>
#include <QQmlEngine>

class FontStyle : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(QFont large READ large CONSTANT FINAL)
    Q_PROPERTY(QFont medium READ medium CONSTANT FINAL)
    Q_PROPERTY(QFont small READ small CONSTANT FINAL)

public:
    explicit FontStyle(const QFont& large, const QFont& medium, const QFont& small, QObject* parent = nullptr)
        : QObject(parent), m_large(large), m_medium(medium), m_small(small) {}

    [[nodiscard]] QFont large() const { return m_large; }
    [[nodiscard]] QFont medium() const { return m_medium; }
    [[nodiscard]] QFont small() const { return m_small; }

private:
    QFont m_large;
    QFont m_medium;
    QFont m_small;
};
