
#include "document_controls_launcher.h"
#include "document_controls_executor.h"

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
            case Operation::kCda: {
                const char* name =
                        operation == Operation::kPdfa ? "pdfa" :
                        operation == Operation::kVersion ? "version" : "cda";

                ExecutionRequest request{};
                request.operation = name;

                const ExecutionResult execution = ExecuteSecurely(request);

                return {
                        LaunchStatus::kUnavailable,
                        execution.error_code,
                        execution.message
                };
            }

        }

        return {
                LaunchStatus::kInvalidOperation,
                "INVALID_OPERATION",
                "Operation documentaire non autorisee."
        };
    }

}  // namespace document_controls
