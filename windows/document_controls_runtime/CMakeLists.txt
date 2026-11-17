cmake_minimum_required(VERSION 3.14)
project(ABAKDocumentControlsRuntime LANGUAGES CXX)
if(NOT WIN32 OR NOT MSVC)
  message(FATAL_ERROR "Windows and Visual C++ are required.")
endif()
add_library(abak_document_controls_runtime STATIC
  ipc.cpp tools.cpp worker.cpp policy.cpp office_console_engine.cpp cda_reports.cpp
  ../runner/document_controls_protocol.cpp
  ../runner/document_controls_peer_policy.cpp
  ../runner/document_controls_pipe_transport.cpp
  ../runner/document_controls_peer_identity.cpp
  ../runner/document_controls_installation_security.cpp
  ../runner/document_controls_installation_manifest.cpp
  ../runner/document_controls_installation_loader.cpp
  ../runner/document_controls_office_engine.cpp
  ../runner/document_controls_docx_plan.cpp)
target_compile_features(abak_document_controls_runtime PUBLIC cxx_std_17)
target_compile_definitions(abak_document_controls_runtime PRIVATE
  UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00)
target_compile_options(abak_document_controls_runtime PRIVATE /W4 /WX /EHsc /utf-8)
target_link_libraries(abak_document_controls_runtime PUBLIC
  advapi32 wintrust crypt32 version fwpuclnt ws2_32 bcrypt user32 shell32 ole32 windowsapp)
add_executable(ABAKDocumentControls service_main.cpp)
add_executable(ABAKDocumentControlsPolicy policy_main.cpp)
foreach(target ABAKDocumentControls ABAKDocumentControlsPolicy)
  target_link_libraries(${target} PRIVATE abak_document_controls_runtime)
  target_compile_definitions(${target} PRIVATE
    UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00)
  target_compile_options(${target} PRIVATE /W4 /WX /EHsc /utf-8)
endforeach()
