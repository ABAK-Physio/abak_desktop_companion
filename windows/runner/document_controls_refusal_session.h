#ifndef RUNNER_DOCUMENT_CONTROLS_REFUSAL_SESSION_H_
#define RUNNER_DOCUMENT_CONTROLS_REFUSAL_SESSION_H_

#include "document_controls_service_core.h"

namespace document_controls::windows_ipc {

// Workflow boundary. Production uses only the private Win32 adapter; a model
// implemented in a TEST translation unit does not qualify native identity.
class RefusalSessionChannel {
 public:
  virtual ~RefusalSessionChannel() = default;
  virtual Error AuthenticateAndPin() = 0;
  virtual Error RecheckPeer() = 0;
  virtual Error ReadRequest(Frame* request) = 0;
  virtual Error WriteRefusal(const Frame& refusal) = 0;
  virtual Error WaitForClientClose() = 0;
};

// Exactly one request/refusal. Success means protocol completion, NEVER validator
// execution. No executor callback or caller-supplied response is accepted.
Error ProcessOneRefusalSession(RefusalSessionChannel& channel);

}  // namespace document_controls::windows_ipc
#endif  // RUNNER_DOCUMENT_CONTROLS_REFUSAL_SESSION_H_
