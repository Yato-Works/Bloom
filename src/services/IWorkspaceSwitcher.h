#pragma once

#include <QtGlobal>
#include <QString>

struct SwitchResult {
    bool accepted = false;
    bool completed = false;
    bool fallbackRecommended = false;
    QString errorCode;
};

class IWorkspaceSwitcher
{
public:
    virtual ~IWorkspaceSwitcher() = default;
    virtual bool initialize() = 0;
    virtual bool isAvailable() const = 0;
    virtual SwitchResult switchTo(int currentWorkspace, int targetWorkspace) = 0;
    virtual void shutdown() = 0;
};
