#ifndef RUNNER_DOCUMENT_CONTROLS_REFUSAL_PIPE_SESSION_H_
#define RUNNER_DOCUMENT_CONTROLS_REFUSAL_PIPE_SESSION_H_

#include "document_controls_pipe_transport.h"

namespace document_controls::windows_ipc {

inline constexpr std::uint32_t kRefusalSessionTotalMs = 15000;

// Transport only, not authorization: wait for EOF after a refusal with the same
// finite I/O budget. An extra byte is a protocol error, never a second request.
Error WaitForRefusalClientClose(HANDLE server_pipe, IoBudget* budget);

// Consumes and closes an already-connected, overlapped byte-mode server handle
// owned by this process. Caller must have created a restricted LOCAL pipe.
// Loads W4 from the current image, authenticates W2, then runs the W3 refusal.
// No alternate installation/path/policy/authentication adapter is accepted.
// W1 and the SCM startup gate remain closed; no listener is created here.
Error ServeInstalledRefusalSession(OwnedHandle server_pipe);

}  // namespace document_controls::windows_ipc
#endif  // RUNNER_DOCUMENT_CONTROLS_REFUSAL_PIPE_SESSION_H_
