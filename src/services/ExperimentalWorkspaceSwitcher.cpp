#include "ExperimentalWorkspaceSwitcher.h"

#include <QDebug>

#ifdef Q_OS_WIN
#  include <combaseapi.h>
#endif

ExperimentalWorkspaceSwitcher::ExperimentalWorkspaceSwitcher(QObject *parent)
    : QObject(parent)
{
}

ExperimentalWorkspaceSwitcher::~ExperimentalWorkspaceSwitcher()
{
    shutdown();
}

#ifdef Q_OS_WIN

static constexpr GUID IID_IObjectArray = {0x92CA9DCD,0x5622,0x4BBA,{0xA8,0x05,0x5E,0x9F,0x5B,0x7A,0x0C,0x0D}};

struct IObjectArrayVtbl {
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(void *, REFIID, void **);
    ULONG   (STDMETHODCALLTYPE *AddRef)(void *);
    ULONG   (STDMETHODCALLTYPE *Release)(void *);
    HRESULT (STDMETHODCALLTYPE *GetCount)(void *, UINT *);
    HRESULT (STDMETHODCALLTYPE *GetAt)(void *, UINT, REFIID, void **);
};

struct IVirtualDesktopInternalVtbl {
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(void *, REFIID, void **);
    ULONG   (STDMETHODCALLTYPE *AddRef)(void *);
    ULONG   (STDMETHODCALLTYPE *Release)(void *);
    HRESULT (STDMETHODCALLTYPE *GetDesktopCount)(void *, UINT *);
    HRESULT (STDMETHODCALLTYPE *GetDesktops)(void *, void **); // IObjectArray **
    HRESULT (STDMETHODCALLTYPE *GetCurrentDesktop)(void *, void **); // IVirtualDesktop **
    HRESULT (STDMETHODCALLTYPE *SwitchDesktop)(void *, void *); // IVirtualDesktop *
};

struct IVirtualDesktopVtbl {
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(void *, REFIID, void **);
    ULONG   (STDMETHODCALLTYPE *AddRef)(void *);
    ULONG   (STDMETHODCALLTYPE *Release)(void *);
    HRESULT (STDMETHODCALLTYPE *GetID)(void *, GUID *);
};

static inline IVirtualDesktopInternalVtbl *desktopMgrVtbl(void *p) {
    return reinterpret_cast<IVirtualDesktopInternalVtbl *>(p);
}
static inline IObjectArrayVtbl *objectArrayVtbl(void *p) {
    return reinterpret_cast<IObjectArrayVtbl *>(p);
}
static inline IVirtualDesktopVtbl *virtualDesktopVtbl(void *p) {
    return reinterpret_cast<IVirtualDesktopVtbl *>(p);
}

bool ExperimentalWorkspaceSwitcher::ensureInitialized()
{
    if (m_available) {
        return true;
    }

    HRESULT hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (hr != S_OK && hr != S_FALSE) {
        qWarning() << "ExperimentalWorkspaceSwitcher: CoInitializeEx failed" << Qt::hex << hr;
        return false;
    }

    void *punk = nullptr;
    hr = CoCreateInstance(CLSID_VirtualDesktopManagerInternal, nullptr, CLSCTX_ALL,
                          IID_IVirtualDesktopManagerInternal, &punk);
    if (FAILED(hr) || !punk) {
        qWarning() << "ExperimentalWorkspaceSwitcher: CoCreateInstance failed" << Qt::hex << hr;
        CoUninitialize();
        return false;
    }
    m_managerInternal.punk = static_cast<IUnknown*>(punk);

    m_available = fetchDesktops();
    if (m_available) {
        qDebug() << "ExperimentalWorkspaceSwitcher: initialized, desktops =" << m_desktops.size();
        emit availabilityChanged(true);
    }
    return m_available;
}

bool ExperimentalWorkspaceSwitcher::fetchDesktops()
{
    void *desktopsArray = nullptr;
    HRESULT hr = desktopMgrVtbl(m_managerInternal.punk)->GetDesktops(m_managerInternal.punk, &desktopsArray);
    if (FAILED(hr) || !desktopsArray) {
        qWarning() << "ExperimentalWorkspaceSwitcher: GetDesktops failed" << Qt::hex << hr;
        return false;
    }

    UINT count = 0;
    objectArrayVtbl(desktopsArray)->GetCount(desktopsArray, &count);

    void *currentDesktop = nullptr;
    desktopMgrVtbl(m_managerInternal.punk)->GetCurrentDesktop(m_managerInternal.punk, &currentDesktop);
    GUID currentId = {0};
    if (currentDesktop) {
        virtualDesktopVtbl(currentDesktop)->GetID(currentDesktop, &currentId);
    }

    m_desktops.clear();
    m_currentDesktopId = QUuid(currentId);

    for (UINT i = 0; i < count; ++i) {
        void *desk = nullptr;
        if (SUCCEEDED(objectArrayVtbl(desktopsArray)->GetAt(desktopsArray, i, IID_IVirtualDesktop, &desk)) && desk) {
            GUID id = {0};
            virtualDesktopVtbl(desk)->GetID(desk, &id);
            m_desktops.append(DesktopInfo{QUuid(id), QStringLiteral("WS %1").arg(i + 1)});
            virtualDesktopVtbl(desk)->Release(desk);
        }
    }

    objectArrayVtbl(desktopsArray)->Release(desktopsArray);
    if (currentDesktop) {
        virtualDesktopVtbl(currentDesktop)->Release(currentDesktop);
    }

    return !m_desktops.isEmpty();
}

QUuid ExperimentalWorkspaceSwitcher::desktopIdForIndex(int index) const
{
    const int i = index - 1;
    if (i < 0 || i >= m_desktops.size()) {
        return QUuid();
    }
    return m_desktops.at(i).id;
}

int ExperimentalWorkspaceSwitcher::indexForDesktopId(const QUuid &id) const
{
    for (int i = 0; i < m_desktops.size(); ++i) {
        if (m_desktops.at(i).id == id) {
            return i + 1;
        }
    }
    return -1;
}

#else

bool ExperimentalWorkspaceSwitcher::ensureInitialized() { return false; }
bool ExperimentalWorkspaceSwitcher::fetchDesktops() { return false; }
QUuid ExperimentalWorkspaceSwitcher::desktopIdForIndex(int) const { return QUuid(); }
int ExperimentalWorkspaceSwitcher::indexForDesktopId(const QUuid &) const { return -1; }

#endif

bool ExperimentalWorkspaceSwitcher::initialize()
{
#ifdef Q_OS_WIN
    return ensureInitialized();
#else
    return false;
#endif
}

SwitchResult ExperimentalWorkspaceSwitcher::switchTo(int currentWorkspace, int targetWorkspace)
{
    Q_UNUSED(currentWorkspace)
    SwitchResult result;
    result.accepted = false;
    result.completed = false;

#ifdef Q_OS_WIN
    if (!m_available && !ensureInitialized()) {
        result.errorCode = QStringLiteral("SWITCHER_NOT_AVAILABLE");
        return result;
    }

    const QUuid targetId = desktopIdForIndex(targetWorkspace);
    if (targetId.isNull()) {
        result.errorCode = QStringLiteral("TARGET_WORKSPACE_NOT_FOUND");
        return result;
    }

    // Re-fetch current desktop ID because it may have changed.
    void *currentDesktop = nullptr;
    HRESULT hr = desktopMgrVtbl(m_managerInternal.punk)->GetCurrentDesktop(m_managerInternal.punk, &currentDesktop);
    if (FAILED(hr) || !currentDesktop) {
        result.errorCode = QStringLiteral("COM_GET_CURRENT_FAILED");
        return result;
    }
    GUID currentId = {0};
    virtualDesktopVtbl(currentDesktop)->GetID(currentDesktop, &currentId);
    virtualDesktopVtbl(currentDesktop)->Release(currentDesktop);

    if (QUuid(currentId) == targetId) {
        result.accepted = true;
        result.completed = true;
        return result;
    }

    // Find the target desktop object.
    void *desktopsArray = nullptr;
    hr = desktopMgrVtbl(m_managerInternal.punk)->GetDesktops(m_managerInternal.punk, &desktopsArray);
    if (FAILED(hr) || !desktopsArray) {
        result.errorCode = QStringLiteral("COM_GET_DESKTOPS_FAILED");
        return result;
    }

    void *targetDesktop = nullptr;
    UINT count = 0;
    objectArrayVtbl(desktopsArray)->GetCount(desktopsArray, &count);
    for (UINT i = 0; i < count; ++i) {
        void *desk = nullptr;
        if (SUCCEEDED(objectArrayVtbl(desktopsArray)->GetAt(desktopsArray, i, IID_IVirtualDesktop, &desk)) && desk) {
            GUID id = {0};
            virtualDesktopVtbl(desk)->GetID(desk, &id);
            if (QUuid(id) == targetId) {
                targetDesktop = desk;
                break;
            }
            virtualDesktopVtbl(desk)->Release(desk);
        }
    }
    objectArrayVtbl(desktopsArray)->Release(desktopsArray);

    if (!targetDesktop) {
        result.errorCode = QStringLiteral("TARGET_DESKTOP_NOT_FOUND");
        return result;
    }

    hr = desktopMgrVtbl(m_managerInternal.punk)->SwitchDesktop(m_managerInternal.punk, targetDesktop);
    virtualDesktopVtbl(targetDesktop)->Release(targetDesktop);

    if (SUCCEEDED(hr)) {
        result.accepted = true;
        result.completed = true;
        m_currentDesktopId = targetId;
        qDebug() << "ExperimentalWorkspaceSwitcher: switched to desktop" << targetWorkspace;
    } else {
        result.errorCode = QStringLiteral("SWITCH_FAILED");
        qWarning() << "ExperimentalWorkspaceSwitcher: SwitchDesktop failed" << Qt::hex << hr;
    }
#else
    Q_UNUSED(targetWorkspace)
#endif

    return result;
}

void ExperimentalWorkspaceSwitcher::shutdown()
{
    if (m_available) {
        m_available = false;
        emit availabilityChanged(false);
    }
#ifdef Q_OS_WIN
    m_desktops.clear();
    m_currentDesktopId = QUuid();
    if (m_managerInternal.punk) {
        m_managerInternal.punk->Release();
        m_managerInternal.punk = nullptr;
    }
    if (m_viewCollection.punk) {
        m_viewCollection.punk->Release();
        m_viewCollection.punk = nullptr;
    }
    CoUninitialize();
#endif
}

int ExperimentalWorkspaceSwitcher::workspaceCount() const
{
    return m_desktops.size();
}

QList<DesktopInfo> ExperimentalWorkspaceSwitcher::desktops() const
{
    return m_desktops;
}
