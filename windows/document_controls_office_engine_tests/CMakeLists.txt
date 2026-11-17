cmake_minimum_required(VERSION 3.14)
project(ABAKOfficeEngineTests LANGUAGES CXX)
if(NOT WIN32 OR NOT MSVC)
  message(FATAL_ERROR "This test requires Windows and Visual C++.")
endif()
enable_testing()
add_executable(abak_office_engine_tests
    test.cpp
    ../runner/document_controls_office_engine.cpp
    ../runner/document_controls_installation_security.cpp
    ../runner/document_controls_pipe_transport.cpp
    ../runner/document_controls_peer_policy.cpp
    ../runner/document_controls_protocol.cpp)
target_compile_features(abak_office_engine_tests PRIVATE cxx_std_17)
target_compile_definitions(abak_office_engine_tests PRIVATE
    UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0602)
target_compile_options(abak_office_engine_tests PRIVATE /W4 /WX /EHsc)
target_link_libraries(abak_office_engine_tests PRIVATE
    wintrust crypt32 advapi32 version)
add_test(NAME office_installed_engine COMMAND abak_office_engine_tests)
set_tests_properties(office_installed_engine PROPERTIES TIMEOUT 120)
