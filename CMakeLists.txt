cmake_minimum_required(VERSION 3.21)
project(Bloom VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

if (MSVC)
    add_compile_options(/Zc:__cplusplus /utf-8)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickLayouts QuickDialogs2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(Bloom
    src/main.cpp
    src/services/GlobalShortcutService.cpp
    src/services/ConfigService.cpp
    src/services/MusicControlService.cpp
    src/services/OverlayController.cpp
    src/services/ShellController.cpp
    src/services/ServiceManager.cpp
    src/services/SystemInfoService.cpp
    src/services/WeatherService.cpp
    src/services/ThemeBridge.cpp
    src/services/WallpaperService.cpp
)

qt_add_qml_module(Bloom
    URI Bloom
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/GlassPanel.qml
        qml/components/SidebarItem.qml
        qml/components/WallpaperSelector.qml
        qml/components/TopShellPanel.qml
        qml/components/BottomShellPanel.qml
        qml/components/MetricRing.qml
        qml/components/ForecastItem.qml
)

target_include_directories(Bloom PRIVATE src)
target_link_libraries(Bloom PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts Qt6::QuickDialogs2)

if (WIN32)
    target_link_libraries(Bloom PRIVATE user32)
endif()

set_target_properties(Bloom PROPERTIES WIN32_EXECUTABLE TRUE)
