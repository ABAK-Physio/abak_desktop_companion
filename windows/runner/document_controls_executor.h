
#ifndef RUNNER_DOCUMENT_CONTROLS_EXECUTOR_H_
#define RUNNER_DOCUMENT_CONTROLS_EXECUTOR_H_

#include <string>

namespace document_controls {

    struct ExecutionRequest {
        std::string operation;
        std::wstring java_path;
        std::wstring job_path;
        std::wstring jar_path;
    };

    struct ExecutionResult {
        bool executed = false;
        int exit_code = -1;
        std::string error_code;
        std::string message;
    };

// Native execution remains disabled until Windows isolation
// and output capture are implemented and verified.
    ExecutionResult ExecuteSecurely(const ExecutionRequest& request);

}  // namespace document_controls

#endif  // RUNNER_DOCUMENT_CONTROLS_EXECUTOR_H_
