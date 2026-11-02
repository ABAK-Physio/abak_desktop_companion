
#include "document_controls_launcher.h"

namespace document_controls {

    bool ParseOperation(
            const std::string& name,
            Operation* operation) {
        if (operation == nullptr) {
            return false;
        }

        if (name == "pdfa") {
            *operation = Operation::kPdfa;
            return true;
        }

        if (name == "version") {
            *operation = Operation::kVersion;
            return true;
        }

        if (name == "cda") {
            *operation = Operation::kCda;
            return true;
        }

        return false;
    }

    LaunchResult Launch(Operation operation) {
        switch (operation) {
            case Operation::kPdfa:
            case Operation::kVersion:
            case Operation::kCda:
                return {
                        LaunchStatus::kUnavailable,
                        "WINDOWS_LAUNCHER_UNAVAILABLE",
                        "Le lanceur documentaire securise Windows "
                        "n'est pas encore disponible."
                };
        }

        return {
                LaunchStatus::kInvalidOperation,
                "INVALID_OPERATION",
                "Operation documentaire non autorisee."
        };
    }

}  // namespace document_controls
