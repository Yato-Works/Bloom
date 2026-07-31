#include "ServiceManager.h"

#ifdef Q_OS_WIN
#include <windows.h>
#endif

ServiceManager::ServiceManager(QObject *parent)
    : QObject(parent)
    , m_weatherService(this)
    , m_overlayController(this)
    , m_shellController(this)
    , m_globalShortcuts(&m_overlayController, this)
    , m_systemInfoService(this)
    , m_configService(this)
    , m_wallpaperService(this)
    , m_workspaceService(this)
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

#ifdef Q_OS_WIN
    m_globalShortcuts.setProfile(m_configService.shortcutProfile());
    connect(&m_configService, &ConfigService::shortcutProfileChanged, this, [this](const QString &profile) {
        m_globalShortcuts.setProfile(profile);
    });
#endif
}

WeatherService *ServiceManager::weatherService() noexcept { return &m_weatherService; }
OverlayController *ServiceManager::overlayController() noexcept { return &m_overlayController; }
ShellController *ServiceManager::shellController() noexcept { return &m_shellController; }
SystemInfoService *ServiceManager::systemInfoService() noexcept { return &m_systemInfoService; }
WallpaperService *ServiceManager::wallpaperService() noexcept { return &m_wallpaperService; }

MusicControlService *ServiceManager::musicControlService() noexcept { return &m_musicControlService; }
ConfigService *ServiceManager::configService() noexcept { return &m_configService; }
GlobalShortcutService *ServiceManager::globalShortcutService() noexcept { return &m_globalShortcuts; }
WorkspaceService *ServiceManager::workspaceService() noexcept { return &m_workspaceService; }
AIService *ServiceManager::aiService() noexcept { return &m_aiService; }
NotionService *ServiceManager::notionService() noexcept { return &m_notionService; }

