#ifndef RUNNER_DOCUMENT_CONTROLS_PIPE_CLIENT_H_
#define RUNNER_DOCUMENT_CONTROLS_PIPE_CLIENT_H_

#include "document_controls_protocol.h"

namespace document_controls::windows_ipc {

// W1 has no runtime switch, installer setting, or server reply that enables IPC.
// This entry point rejects before opening a pipe or touching document bytes.
Error Exchange(const Request& request, Frame* response);

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_PIPE_CLIENT_H_
