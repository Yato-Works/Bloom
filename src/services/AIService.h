#ifndef AISERVICE_H
#define AISERVICE_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QTimer>

class AIService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList messages READ messages NOTIFY messagesChanged)
    Q_PROPERTY(bool isGenerating READ isGenerating NOTIFY isGeneratingChanged)

public:
    explicit AIService(QObject *parent = nullptr);

    QVariantList messages() const { return m_messages; }
    bool isGenerating() const { return m_isGenerating; }

    Q_INVOKABLE void sendMessage(const QString &text);
    Q_INVOKABLE void clearHistory();

signals:
    void messagesChanged();
    void isGeneratingChanged();
    void responseReceived(const QString &response);

private:
    void simulateAIResponse(const QString &userPrompt);

    QVariantList m_messages;
    bool m_isGenerating{false};
};

#endif // AISERVICE_H
