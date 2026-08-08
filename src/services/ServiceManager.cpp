#include "ServiceManager.h"

#ifdef Q_OS_WIN
#include <windows.h>
#endif

ServiceManager::ServiceManager(QObject *parent)
    : QObject(parent)
    , m_weatherService(this)
    , m_overlayController(this)
    , m_shellController(this)
    , m_systemInfoService(this)
    , m_configService(this)
    , m_wallpaperService(this)
    , m_workspaceService(this)
    , m_cavaService(this)
    , m_hotkeyService(this)
    , m_workspaceController(this)
    , m_shortcutSwitcher(this)
    , m_experimentalSwitcher(this)
{
}

ServiceManager::~ServiceManager()
{
    m_shellController.stop();
    m_weatherService.shutdown();
}

void ServiceManager::initialize()
{
    m_weatherService.initialize();
    m_systemInfoService.start();
    m_shellController.start();
    m_musicControlService.start();
    m_cavaService.start();

    m_hotkeyService.start();
    m_shortcutSwitcher.setHotkeyService(&m_hotkeyService);
    m_shortcutSwitcher.initialize();
    m_experimentalSwitcher.initialize();
    m_workspaceController.setHotkeyService(&m_hotkeyService);
    m_workspaceController.setWorkspaceService(&m_workspaceService);
    m_workspaceController.setShortcutSwitcher(&m_shortcutSwitcher);
    m_workspaceController.setExperimentalSwitcher(&m_experimentalSwitcher);
    m_workspaceController.setSwitchingMode(QStringLiteral("standard"));
    QObject::connect(&m_hotkeyService, &GlobalHotkeyService::switchPrevRequested, &m_workspaceController, &WorkspaceController::switchPrevious);
    QObject::connect(&m_hotkeyService, &GlobalHotkeyService::switchNextRequested, &m_workspaceController, &WorkspaceController::switchNext);
    QObject::connect(&m_hotkeyService, &GlobalHotkeyService::jumpRequested, &m_workspaceController, [this](int idx){ if (idx >= 1 && idx <= 9) m_workspaceController.switchTo(idx); });
    m_workspaceService.startTracking();
}

WeatherService *ServiceManager::weatherService() noexcept { return &m_weatherService; }
OverlayController *ServiceManager::overlayController() noexcept { return &m_overlayController; }
ShellController *ServiceManager::shellController() noexcept { return &m_shellController; }
SystemInfoService *ServiceManager::systemInfoService() noexcept { return &m_systemInfoService; }
WallpaperService *ServiceManager::wallpaperService() noexcept { return &m_wallpaperService; }

MusicControlService *ServiceManager::musicControlService() noexcept { return &m_musicControlService; }
ConfigService *ServiceManager::configService() noexcept { return &m_configService; }
WorkspaceService *ServiceManager::workspaceService() noexcept { return &m_workspaceService; }
WorkspaceController *ServiceManager::workspaceController() noexcept { return &m_workspaceController; }
AIService *ServiceManager::aiService() noexcept { return &m_aiService; }
NotionService *ServiceManager::notionService() noexcept { return &m_notionService; }
AppLauncherService *ServiceManager::appLauncherService() noexcept { return &m_appLauncherService; }
CavaService *ServiceManager::cavaService() noexcept { return &m_cavaService; }
GlobalHotkeyService *ServiceManager::hotkeyService() noexcept { return &m_hotkeyService; }
ExperimentalWorkspaceSwitcher *ServiceManager::experimentalSwitcher() noexcept { return &m_experimentalSwitcher; }

