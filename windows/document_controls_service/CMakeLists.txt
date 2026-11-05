# Standalone development build only. Not included by the Flutter project and
# not installed or packaged with Companion before qualification.
cmake_minimum_required(VERSION 3.14)
project(ABAKDocumentControls LANGUAGES CXX)
if(NOT WIN32)
  message(FATAL_ERROR "This service host requires the Windows SDK.")
endif()
if(NOT MSVC)
  message(FATAL_ERROR "Use the installed Visual C++ compiler for this development target.")
endif()
add_executable(ABAKDocumentControls
    service_main.cpp
    ../runner/document_controls_protocol.cpp
    ../runner/document_controls_service_core.cpp
)
target_compile_features(ABAKDocumentControls PRIVATE cxx_std_17)
target_compile_definitions(ABAKDocumentControls PRIVATE UNICODE _UNICODE NOMINMAX)
target_compile_options(ABAKDocumentControls PRIVATE /W4 /WX /EHsc)
target_include_directories(ABAKDocumentControls PRIVATE ../runner)
target_link_libraries(ABAKDocumentControls PRIVATE advapi32)
