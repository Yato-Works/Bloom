#include "NotionService.h"
#include <QDateTime>

NotionService::NotionService(QObject *parent)
    : QObject(parent)
{
    // 初期サンプルの Notion タスク
    QVariantMap task1;
    task1["title"] = "Bloom-shell UIの調整";
    task1["category"] = "Design";
    task1["completed"] = true;
    task1["date"] = QDateTime::currentDateTime().toString("MM/dd");
    m_tasks.append(task1);

    QVariantMap task2;
    task2["title"] = "Bloom 動作テストと最適化";
    task2["category"] = "Dev";
    task2["completed"] = false;
    task2["date"] = QDateTime::currentDateTime().toString("MM/dd");
    m_tasks.append(task2);

    QVariantMap task3;
    task3["title"] = "Notion データベース同期連携";
    task3["category"] = "Notion";
    task3["completed"] = false;
    task3["date"] = QDateTime::currentDateTime().toString("MM/dd");
    m_tasks.append(task3);
}

int NotionService::activeTaskCount() const
{
    int count = 0;
    for (const auto &item : m_tasks) {
        if (!item.toMap()["completed"].toBool()) {
            count++;
        }
    }
    return count;
}

void NotionService::addTask(const QString &title, const QString &category)
{
    if (title.trimmed().isEmpty())
        return;

    QVariantMap task;
    task["title"] = title.trimmed();
    task["category"] = category.trimmed().isEmpty() ? QStringLiteral("General") : category.trimmed();
    task["completed"] = false;
    task["date"] = QDateTime::currentDateTime().toString("MM/dd");

    m_tasks.append(task);
    emit tasksChanged();
}

void NotionService::toggleTask(int index)
{
    if (index < 0 || index >= m_tasks.size())
        return;

    QVariantMap task = m_tasks[index].toMap();
    task["completed"] = !task["completed"].toBool();
    m_tasks[index] = task;
    emit tasksChanged();
}

void NotionService::removeTask(int index)
{
    if (index < 0 || index >= m_tasks.size())
        return;

    m_tasks.removeAt(index);
    emit tasksChanged();
}
