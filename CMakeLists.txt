cmake_minimum_required(VERSION 3.16)
project(QuickApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(QuickApp
    main.cpp
    appcontroller.h
    appcontroller.cpp
    authservice.h
    authservice.cpp
)

# qt_add_qml_module 把 .qml 文件和 C++ 端用 QML_ELEMENT/QML_SINGLETON 标记的类型
# 编译进同一个 "QuickApp" 模块（URI 是下面的 URI 参数），打进资源系统。
# QML 里 `import QuickApp` 就是导入这个模块；main.cpp 里
# `engine.loadFromModule("QuickApp", "Main")` 加载的就是 qml/main.qml
# （resource alias "Main" 对应文件名 main.qml，去掉扩展名、首字母大写是默认规则）。
qt_add_qml_module(QuickApp
    URI QuickApp
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/LoginDialog.qml
        qml/MainWindow.qml
        # 只有大写开头的文件名才会被当成可导入的类型
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(QuickApp PROPERTIES
        #    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.QuickApp
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
        MACOSX_BUNDLE TRUE
        WIN32_EXECUTABLE TRUE
)

target_link_libraries(QuickApp PRIVATE Qt6::Quick)
target_link_libraries(QuickApp PRIVATE Qt6::Core)

include(GNUInstallDirs)
install(TARGETS QuickApp
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

#qt_generate_deploy_qml_app_script(
#    TARGET QuickApp
#    OUTPUT_SCRIPT deploy_script
#)
#install(SCRIPT ${deploy_script})
