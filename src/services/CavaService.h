#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>
#include <QProcess>

class CavaService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList bars READ bars NOTIFY barsChanged FINAL)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)

public:
    explicit CavaService(QObject *parent = nullptr);
    ~CavaService() override;

    [[nodiscard]] QVariantList bars() const noexcept { return m_bars; }
    [[nodiscard]] bool active() const noexcept { return m_active; }

    void start();

signals:
    void barsChanged();
    void activeChanged();

private:
    void refresh();
    void startCava();
    void readCavaOutput();
    void simulateBars();

    QProcess *m_process {nullptr};
    QTimer m_timer;
    QVariantList m_bars;
    bool m_active {false};
    qreal m_simPhase {0.0};
};
