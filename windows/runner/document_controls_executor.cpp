
#include "document_controls_executor.h"

namespace document_controls {

    ExecutionResult ExecuteSecurely(const ExecutionRequest& request) {
        // Only the three supported operations are recognized.
        if (request.operation != "pdfa" &&
            request.operation != "version" &&
            request.operation != "cda") {
            return {
                    false,
                    -1,
                    "INVALID_OPERATION",
                    "Operation documentaire non autorisee."
            };
        }

        // No execution until AppContainer, Job Object,
        // filesystem restrictions and output capture
        // have been implemented and verified.
        return {
                false,
                -1,
                "WINDOWS_ISOLATION_UNAVAILABLE",
                "L'isolation native des controles documentaires "
                "Windows n'est pas encore disponible."
        };
    }

}  // namespace document_controls
