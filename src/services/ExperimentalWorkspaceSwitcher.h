#pragma once

#include "IWorkspaceSwitcher.h"
#include <QObject>
#include <QString>
#include <QUuid>
#include <QList>

#ifdef Q_OS_WIN
#  include <qt_windows.h>
#  include <unknwn.h>
#endif

// {AA509086-5CA9-4A25-8F9A-B075B3D6D8D5}
static const GUID CLSID_VirtualDesktopManagerInternal = {0xAA509086,0x5CA9,0x4A25,{0x8F,0x9A,0xB0,0x75,0xB3,0xD6,0xD8,0xD5}};
// {C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}
static const GUID IID_IVirtualDesktopManagerInternal = {0xC5E0CDCA,0x7B6E,0x41B2,{0x9F,0xC4,0xD9,0x39,0x75,0xCC,0x46,0x7B}};
// {B2F92B53-3D65-4A75-8B9C-8E2D3F1C6B3A}
static const GUID IID_IApplicationViewCollection = {0xB2F92B53,0x3D65,0x4A75,{0x8B,0x9C,0x8E,0x2D,0x3F,0x1C,0x6B,0x3A}};
// {FF72FFDD-5157-40F8-8E0C-14C6D6F7E8B9}
static const GUID IID_IVirtualDesktop = {0xFF72FFDD,0x5157,0x40F8,{0x8E,0x0C,0x14,0xC6,0xD6,0xF7,0xE8,0xB9}};

struct DesktopInfo {
    QUuid id;
    QString name;
};

class ExperimentalWorkspaceSwitcher final : public QObject, public IWorkspaceSwitcher
{
    Q_OBJECT
public:
    explicit ExperimentalWorkspaceSwitcher(QObject *parent = nullptr);
    ~ExperimentalWorkspaceSwitcher() override;

    bool initialize() override;
    bool isAvailable() const override { return m_available; }
    SwitchResult switchTo(int currentWorkspace, int targetWorkspace) override;
    void shutdown() override;

    Q_INVOKABLE int workspaceCount() const;
    Q_INVOKABLE QList<DesktopInfo> desktops() const;

signals:
    void availabilityChanged(bool available);

private:
    bool m_available = false;
    QUuid m_currentDesktopId;
    QList<DesktopInfo> m_desktops;

    bool ensureInitialized();
    bool fetchDesktops();
    QUuid desktopIdForIndex(int index) const;
    int indexForDesktopId(const QUuid &id) const;

#ifdef Q_OS_WIN
    struct ComInterface {
        IUnknown *punk = nullptr;
        ~ComInterface() { if (punk) punk->Release(); }
    };

    ComInterface m_managerInternal;
    ComInterface m_viewCollection;
#endif
};
