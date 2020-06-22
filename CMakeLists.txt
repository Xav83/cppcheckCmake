cmake_minimum_required(VERSION 3.17.2 FATAL_ERROR)
project(CppcheckCMakeIntegration
        VERSION 1.0.0
        DESCRIPTION "Project checking cppcheck integration in a Cmake project"
        LANGUAGES CXX
)

include(${CMAKE_CURRENT_LIST_DIR}/.cmake/cppcheck.cmake)

set(SOURCE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)

add_executable(test_error ${SOURCE_DIRECTORY}/test.cpp)
set_property(TARGET test_error PROPERTY CXX_STANDARD 17)

if(WIN32 AND RUN_CPPCHECK)
    add_custom_target(cppcheck ALL
        COMMAND ${CMAKE_CXX_CPPCHECK}
        DEPENDS test_error
        WORKING_DIRECTORY ${SOURCE_DIRECTORY}
        COMMENT "Run Cppcheck on the source code"
        )
endif()