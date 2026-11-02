
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

        std::string standard_output;
        std::string standard_error;

        std::string error_code;
        std::string message;

        bool appcontainer_active = false;
        bool job_object_active = false;
        bool network_denied_verified = false;
        bool filesystem_restricted_verified = false;
    };


// Native execution remains disabled until Windows isolation
// and output capture are implemented and verified.
    ExecutionResult ExecuteSecurely(const ExecutionRequest& request);

}  // namespace document_controls

#endif  // RUNNER_DOCUMENT_CONTROLS_EXECUTOR_H_
