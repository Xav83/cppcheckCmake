set(RUN_CPPCHECK
    OFF
    CACHE
      BOOL
      "Sets to ON if you want to run cppcheck during your project compilation. OFF by default"
)

if(NOT RUN_CPPCHECK)
  message(STATUS "Cppcheck deactivated during compilation.")
else()
  message(STATUS "Cppcheck activated during compilation.")
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

  if(${CPPCHECK_VERSION_OUTPUT} VERSION_GREATER_EQUAL "1.88")
    set(CPPCHECK_STD_FLAG "--std=c++17")
  endif()

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
