set(RUN_CPPCHECK
    OFF
    CACHE
      BOOL
      "Sets to ON if you want to run cppcheck during your project compilation. OFF by default"
)

function(get_cppcheck_program output)
  find_program(
    CPPCHECK_EXE
    NAMES cppcheck cppcheck.exe
    HINTS
    "C:\\Program Files\\Cppcheck" # chocolatey default path
    DOC "Cppcheck program"
    REQUIRED
    )

  if(NOT CPPCHECK_EXE)
    message(
      FATAL_ERROR
        "Cppcheck not found.
        You can install it using Homebrew on Apple or Chocolatey on Windows.")
    return()
  endif()

  set(${output} ${CPPCHECK_EXE} PARENT_SCOPE)
endfunction()

function(cppcheck_version output)
  find_program(
    CMAKE_CXX_CPPCHECK
    NAMES cppcheck cppcheck.exe
    HINTS
    "C:\\Program Files\\Cppcheck" # chocolatey default path
    DOC "Cppcheck program"
    REQUIRED
    )

  if(NOT CMAKE_CXX_CPPCHECK)
    message(
      FATAL_ERROR
        "Cppcheck not found.
        You can install it using Homebrew on Apple or Chocolatey on Windows.")
  endif()

  execute_process(COMMAND ${CMAKE_CXX_CPPCHECK} --version
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    RESULT_VARIABLE CPPCHECK_VERSION_COMMAND_RESULT
    OUTPUT_VARIABLE CPPCHECK_VERSION_OUTPUT
  )

  if(NOT ${CPPCHECK_VERSION_COMMAND_RESULT} EQUAL 0)
    message(FATAL_ERROR "Failed to run '${CMAKE_CXX_CPPCHECK} --version'")
  endif()

  string(REPLACE "Cppcheck " "" CPPCHECK_VERSION_OUTPUT ${CPPCHECK_VERSION_OUTPUT})
  string(REPLACE "\n" "" CPPCHECK_VERSION_OUTPUT ${CPPCHECK_VERSION_OUTPUT})

  set(${output} ${CPPCHECK_VERSION_OUTPUT} PARENT_SCOPE)
endfunction()

#! cppcheck_minimum_required : Sets the minimum required version of cppcheck for a project.
#
# cppcheck_minimum_required(VERSION <min> [<max>] [FATAL_ERROR])
#
# This function is used to specify the versions of cppcheck allowed in your project.
#
# 'VERSION <min> [max]'
#   Specifies the range of version of cppcheck allowed in your project.
#   If the <max> is not specified, it only when that the version is at least greater than the one given as a parameter.
#
# 'FATAL_ERROR'
#   Flag that you can specify if you want the function to display an error when the version of cppcheck doesn't match the requirements.
#
function(cppcheck_minimum_required)
  cmake_parse_arguments(CPPCHECK_MINIMUM_REQUIRED "FATAL_ERROR" "" "VERSION" ${ARGN})

  cppcheck_version(CPPCHECK_ACTUAL_VERSION)

  if(NOT DEFINED CPPCHECK_MINIMUM_REQUIRED_VERSION)
    message(FATAL_ERROR "cppcheck_minimum_required VERSION argument is mandatory.")
  endif()

  list(LENGTH CPPCHECK_MINIMUM_REQUIRED_VERSION CPPCHECK_MINIMUM_REQUIRED_VERSION_SIZE)
  if(${CPPCHECK_MINIMUM_REQUIRED_VERSION_SIZE} EQUAL 0 OR ${CPPCHECK_MINIMUM_REQUIRED_VERSION_SIZE} GREATER 2)
    message(FATAL_ERROR "cppcheck_minimum_required takes only two versions, the expected minimum and maximum version of cppcheck.")
  endif()

  list(GET CPPCHECK_MINIMUM_REQUIRED_VERSION 0 CPPCHECK_EXPECTED_MINIMUM_VERSION)

  if(${CPPCHECK_ACTUAL_VERSION} VERSION_LESS_EQUAL ${CPPCHECK_EXPECTED_MINIMUM_VERSION})
    set(CPPCHECK_ERROR_MESSAGE "Error - cppcheck version too old:\n"
      "The version of cppcheck on this machine is ${CPPCHECK_ACTUAL_VERSION}, but the minimum version specified is ${CPPCHECK_EXPECTED_MINIMUM_VERSION}")
    if(DEFINED CPPCHECK_MINIMUM_REQUIRED_FATAL_ERROR)
      message(FATAL_ERROR "${CPPCHECK_ERROR_MESSAGE}")
    else()
      message(WARNING "${CPPCHECK_ERROR_MESSAGE}")
    endif()
  endif()

  if(${CPPCHECK_MINIMUM_REQUIRED_VERSION_SIZE} EQUAL 2)
    list(GET CPPCHECK_MINIMUM_REQUIRED_VERSION 1 CPPCHECK_EXPECTED_MAXIMUM_VERSION)

    if(${CPPCHECK_EXPECTED_MINIMUM_VERSION} VERSION_GREATER_EQUAL ${CPPCHECK_EXPECTED_MAXIMUM_VERSION})
      message(FATAL_ERROR "The two versions passed to cppcheck_minimum_required are reversed.\n"
        "The minimum should be passed before the maximum")
    endif()

    if(${CPPCHECK_ACTUAL_VERSION} VERSION_GREATER_EQUAL ${CPPCHECK_EXPECTED_MAXIMUM_VERSION})
      set(CPPCHECK_ERROR_MESSAGE "Error - cppcheck version too recent:\nThe version of cppcheck on this machine is ${CPPCHECK_ACTUAL_VERSION}, but the maximum version specified is ${CPPCHECK_EXPECTED_MAXIMUM_VERSION}")
      if(DEFINED CPPCHECK_MINIMUM_REQUIRED_FATAL_ERROR)
        message(FATAL_ERROR "${CPPCHECK_ERROR_MESSAGE}")
      else()
        message(WARNING "${CPPCHECK_ERROR_MESSAGE}")
      endif()
    endif()
  endif()
endfunction()

if(NOT RUN_CPPCHECK)
  message(STATUS "Cppcheck deactivated during compilation.")
else()
  message(STATUS "Cppcheck activated during compilation.")

  get_cppcheck_program(CMAKE_CXX_CPPCHECK)

  cppcheck_version(CPPCHECK_VERSION_OUTPUT)

  if(${CPPCHECK_VERSION_OUTPUT} VERSION_GREATER_EQUAL "1.88")
    set(CPPCHECK_STD_FLAG "--std=c++17")
  endif()

  cppcheck_minimum_required(VERSION 1.72 FATAL_ERROR)

  list(
    APPEND
    CMAKE_CXX_CPPCHECK
    "--enable=warning,style,performance,portability"
    "--inconclusive"
    "--error-exitcode=1"
    "${CPPCHECK_STD_FLAG}"
    "--force"
    "--inline-suppr"
    "."
)
endif()
