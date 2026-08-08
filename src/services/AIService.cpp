#include "AIService.h"
#include <QDateTime>
#include <QTimer>

AIService::AIService(QObject *parent)
    : QObject(parent)
{
    // 初期メッセージのセットアップ
    QVariantMap welcomeMsg;
    welcomeMsg["sender"] = "assistant";
    welcomeMsg["text"] = "こんにちは！Bloom AI アシスタントです。何かお手伝いできることはありますか？";
    welcomeMsg["time"] = QDateTime::currentDateTime().toString("hh:mm");
    m_messages.append(welcomeMsg);
}

void AIService::sendMessage(const QString &text)
{
    if (text.trimmed().isEmpty() || m_isGenerating)
        return;

    QVariantMap userMsg;
    userMsg["sender"] = "user";
    userMsg["text"] = text.trimmed();
    userMsg["time"] = QDateTime::currentDateTime().toString("hh:mm");
    m_messages.append(userMsg);
    emit messagesChanged();

    m_isGenerating = true;
    emit isGeneratingChanged();

    simulateAIResponse(text.trimmed());
}

void AIService::clearHistory()
{
    m_messages.clear();
    QVariantMap welcomeMsg;
    welcomeMsg["sender"] = "assistant";
    welcomeMsg["text"] = "会話履歴をクリアしました。新しい質問をどうぞ！";
    welcomeMsg["time"] = QDateTime::currentDateTime().toString("hh:mm");
    m_messages.append(welcomeMsg);
    emit messagesChanged();
}

void AIService::simulateAIResponse(const QString &userPrompt)
{
    QTimer::singleShot(800, this, [this, userPrompt]() {
        QString reply;
        if (userPrompt.contains("天気", Qt::CaseInsensitive)) {
            reply = "本日の天気は概ね晴れ、快適な気候となっております。";
        } else if (userPrompt.contains("タスク", Qt::CaseInsensitive) || userPrompt.contains("todo", Qt::CaseInsensitive)) {
            reply = "右側のドロワーで Notion タスクを確認・追加できます！";
        } else if (userPrompt.contains("bloom", Qt::CaseInsensitive) || userPrompt.contains("機能", Qt::CaseInsensitive)) {
            reply = "Bloom は次世代のデスクトップオーバーレイです。Ctrl+Win でアクセスできます！";
        } else {
            reply = QString("「%1」について承知いたしました。お手伝いできることがあればいつでもお知らせください！").arg(userPrompt);
        }

        QVariantMap aiMsg;
        aiMsg["sender"] = "assistant";
        aiMsg["text"] = reply;
        aiMsg["time"] = QDateTime::currentDateTime().toString("hh:mm");
        m_messages.append(aiMsg);

        m_isGenerating = false;
        emit messagesChanged();
        emit isGeneratingChanged();
        emit responseReceived(reply);
    });
}
