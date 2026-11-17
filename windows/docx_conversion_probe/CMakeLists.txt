cmake_minimum_required(VERSION 3.14)
project(ABAKDocxServiceProbe LANGUAGES CXX)
if(NOT WIN32 OR NOT MSVC)
  message(FATAL_ERROR "Windows and Visual C++ required.")
endif()
add_library(docx_probe_common STATIC
  policy.cpp
  office_console_engine.cpp
  ../runner/document_controls_office_engine.cpp
  ../runner/document_controls_docx_plan.cpp
  ../runner/document_controls_installation_security.cpp
  ../runner/document_controls_pipe_transport.cpp
  ../runner/document_controls_peer_policy.cpp
  ../runner/document_controls_protocol.cpp)
target_compile_features(docx_probe_common PUBLIC cxx_std_17)
target_compile_definitions(docx_probe_common PUBLIC UNICODE _UNICODE NOMINMAX
  WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0602)
target_compile_options(docx_probe_common PRIVATE /W4 /WX /EHsc)
target_link_libraries(docx_probe_common PUBLIC
  advapi32 wintrust crypt32 version fwpuclnt ws2_32 bcrypt user32)
add_executable(abak_docx_probe_service service.cpp)
add_executable(abak_docx_probe_controller controller.cpp)
foreach(target abak_docx_probe_service abak_docx_probe_controller)
  target_link_libraries(${target} PRIVATE docx_probe_common)
  target_compile_options(${target} PRIVATE /W4 /WX /EHsc)
endforeach()
enable_testing()
add_executable(abak_udp_evidence_tests udp_evidence_tests.cpp)
target_compile_features(abak_udp_evidence_tests PRIVATE cxx_std_17)
target_compile_options(abak_udp_evidence_tests PRIVATE /W4 /WX /EHsc)
add_test(NAME udp_evidence_current_run COMMAND abak_udp_evidence_tests)
add_executable(abak_office_console_engine_tests console_engine_tests.cpp)
target_link_libraries(abak_office_console_engine_tests PRIVATE docx_probe_common)
target_compile_options(abak_office_console_engine_tests PRIVATE /W4 /WX /EHsc)
add_test(NAME office_console_engine_verification COMMAND abak_office_console_engine_tests)
