cmake_minimum_required(VERSION 3.17.0 FATAL_ERROR)

project(CppcheckCMakeIntegration
        VERSION 1.0.0
        DESCRIPTION "Project checking cppcheck integration in a Cmake project"
        LANGUAGES CXX
)

include(${CMAKE_CURRENT_LIST_DIR}/.cmake/cppcheck.cmake)

set(SOURCE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)

add_executable(test_error ${SOURCE_DIRECTORY}/error/test.cpp)

add_executable(test_success ${SOURCE_DIRECTORY}/success/test.cpp)

if(WIN32 AND RUN_CPPCHECK)
    add_custom_target(cppcheck_test_error ALL
        COMMAND ${CMAKE_CXX_CPPCHECK}
        DEPENDS test_error
        WORKING_DIRECTORY ${SOURCE_DIRECTORY}/error
        COMMENT "Run Cppcheck on the source code with error"
        )
    add_custom_target(cppcheck_test_success ALL
        COMMAND ${CMAKE_CXX_CPPCHECK}
        DEPENDS test_success
        WORKING_DIRECTORY ${SOURCE_DIRECTORY}/success
        COMMENT "Run Cppcheck on the source code without error"
        )
endif()