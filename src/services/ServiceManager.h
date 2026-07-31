#pragma once

#include <QObject>

#include "WeatherService.h"
#include "ConfigService.h"
#include "MusicControlService.h"
#include "OverlayController.h"
#include "ShellController.h"
#include "SystemInfoService.h"
#include "WallpaperService.h"
#include "GlobalShortcutService.h"
#include "WorkspaceService.h"
#include "AIService.h"
#include "NotionService.h"


class ServiceManager final : public QObject
{
    Q_OBJECT
public:
    explicit ServiceManager(QObject *parent = nullptr);
    ~ServiceManager() override;

    ServiceManager(const ServiceManager &) = delete;
    ServiceManager &operator=(const ServiceManager &) = delete;

    void initialize();
    [[nodiscard]] WeatherService *weatherService() noexcept;
    [[nodiscard]] OverlayController *overlayController() noexcept;
    [[nodiscard]] ShellController *shellController() noexcept;
    [[nodiscard]] WallpaperService *wallpaperService() noexcept;

    [[nodiscard]] SystemInfoService *systemInfoService() noexcept;
    [[nodiscard]] MusicControlService *musicControlService() noexcept;
    [[nodiscard]] ConfigService *configService() noexcept;
    [[nodiscard]] GlobalShortcutService *globalShortcutService() noexcept;
    [[nodiscard]] WorkspaceService *workspaceService() noexcept;
    [[nodiscard]] AIService *aiService() noexcept;
    [[nodiscard]] NotionService *notionService() noexcept;


private:
    WeatherService m_weatherService;
    WallpaperService m_wallpaperService;

    OverlayController m_overlayController;
    ShellController m_shellController;
    GlobalShortcutService m_globalShortcuts;
    SystemInfoService m_systemInfoService;
    MusicControlService m_musicControlService;
    ConfigService m_configService;
    WorkspaceService m_workspaceService;
    AIService m_aiService;
    NotionService m_notionService;
};
