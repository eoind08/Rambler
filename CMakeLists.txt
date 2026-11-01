cmake_minimum_required(VERSION 3.21)
project(Rambler VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appRambler src/main.cpp)

qt_add_qml_module(appRambler
    URI Rambler
    VERSION 1.0
    QML_FILES qml/Main.qml
)

target_link_libraries(appRambler PRIVATE Qt6::Quick)