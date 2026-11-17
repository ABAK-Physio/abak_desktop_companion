cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
        "webps/webps_channel.cpp"
        "webps/webps_browser.cpp"
        "cps/cps_channel.cpp"
        "cps/cps_windows_client.cpp"
        "cps/cps_profile_reader.cpp"
        "cps/cps_wire.cpp"
        "cps/cps_signature.cpp"
        "document_controls_channel.cpp"
        "document_controls_executor.cpp"
        "document_controls_launcher.cpp"
        "document_controls_service_core.cpp"
        "document_controls_refusal_session.cpp"
        "document_controls_refusal_pipe_session.cpp"
        "document_controls_pipe_client.cpp"
        "flutter_window.cpp"
        "main.cpp"
        "smart_card/vitale_api.cpp"
        "utils.cpp"
        "win32_window.cpp"
        "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
        "Runner.rc"
        "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX" "_WIN32_WINNT=0x0A00")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app abak_document_controls_runtime)
add_dependencies(${BINARY_NAME} ABAKDocumentControls ABAKDocumentControlsPolicy)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Isolated CPS profile / explicitly requested local signature reader. Cryptolib stays installed in System32.
add_executable(ABAKCpsReader
        "cps/cps_worker_main.cpp"
        "cps/cps_pkcs11_windows.cpp"
        "cps/cps_crypto_windows.cpp"
        "cps/cps_profile_reader.cpp"
        "cps/cps_wire.cpp"
        "cps/cps_signature.cpp"
)
apply_standard_settings(ABAKCpsReader)
target_compile_definitions(ABAKCpsReader PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
target_link_libraries(ABAKCpsReader PRIVATE Wer Crypt32 Bcrypt)
target_link_libraries(${BINARY_NAME} PRIVATE Shell32 Ole32 Uuid)
add_dependencies(${BINARY_NAME} ABAKCpsReader)
