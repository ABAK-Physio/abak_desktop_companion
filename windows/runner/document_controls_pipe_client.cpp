#include "document_controls_pipe_client.h"

namespace document_controls::windows_ipc {

Error Exchange(const Request& request, Frame* response) {
  if (response) *response = {};
  if (!response) return {"INVALID_ARGUMENTS", "Missing response output."};
  if (auto error = ValidateRequest(request)) return error;
  // Do not connect, authenticate, upload, or invoke a server in W1. In
  // particular, never reuse the experimental DocumentControlsProbe service.
  return {kIsolationUnavailable,
          "Windows document isolation is not integrated and qualified."};
}

}  // namespace document_controls::windows_ipc
