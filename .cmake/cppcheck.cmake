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

  list(
    APPEND
    CMAKE_CXX_CPPCHECK
    "--enable=warning,style,performance,portability"
    "--inconclusive"
    "--error-exitcode=1"
    "--std=c++17"
    "--force"
    "--inline-suppr"
    "."
)
endif()