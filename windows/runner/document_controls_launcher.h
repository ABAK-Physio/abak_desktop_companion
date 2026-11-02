
#ifndef RUNNER_DOCUMENT_CONTROLS_LAUNCHER_H_
#define RUNNER_DOCUMENT_CONTROLS_LAUNCHER_H_

#include <string>

namespace document_controls {

    enum class Operation {
        kPdfa,
        kVersion,
        kCda,
    };

    enum class LaunchStatus {
        kUnavailable,
        kInvalidOperation,
    };

    struct LaunchResult {
        LaunchStatus status;
        std::string error_code;
        std::string message;
    };

// Accept only the three predefined document-control operations.
    bool ParseOperation(
            const std::string& name,
            Operation* operation);

// Fail closed until native isolation is implemented and verified.
    LaunchResult Launch(Operation operation);

}  // namespace document_controls

#endif  // RUNNER_DOCUMENT_CONTROLS_LAUNCHER_H_
