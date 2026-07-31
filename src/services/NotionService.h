#ifndef NOTIONSERVICE_H
#define NOTIONSERVICE_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>

class NotionService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList tasks READ tasks NOTIFY tasksChanged)
    Q_PROPERTY(int activeTaskCount READ activeTaskCount NOTIFY tasksChanged)

public:
    explicit NotionService(QObject *parent = nullptr);

    QVariantList tasks() const { return m_tasks; }
    int activeTaskCount() const;

    Q_INVOKABLE void addTask(const QString &title, const QString &category = QStringLiteral("General"));
    Q_INVOKABLE void toggleTask(int index);
    Q_INVOKABLE void removeTask(int index);

signals:
    void tasksChanged();

private:
    QVariantList m_tasks;
};

#endif // NOTIONSERVICE_H
