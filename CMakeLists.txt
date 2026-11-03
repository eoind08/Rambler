cmake_minimum_required(VERSION 3.21)
project(Rambler VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS QUICK QuickControls2)
qt_standard_project_setup(REQUIRES 6.8)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
qt_add_executable(appRambler src/main.cpp app.rc)

qt_add_qml_module(appRambler
    URI Rambler
    VERSION 1.0
    QML_FILES 
        qml/Main.qml
        qml/Theme.qml
        qml/Sidebar.qml
        qml/EntryCard.qml
        qml/Composer.qml
        qml/ConfirmDialog.qml
        qml/PlusButton.qml
    SOURCES
        src/bookmodel.h
        src/bookmodel.cpp
        src/entrymodel.h 
        src/entrymodel.cpp
    RESOURCES
        assets/book-open.svg
        assets/link.svg
        assets/list.svg
        assets/arrow-down.svg
        assets/send-horizontal.svg
        assets/ramblerlogo.png
        assets/folder.svg
    )

target_include_directories(appRambler PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(appRambler PRIVATE Qt6::Quick Qt6::QuickControls2)