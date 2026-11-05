#ifndef RUNNER_DOCUMENT_CONTROLS_SERVICE_CORE_H_
#define RUNNER_DOCUMENT_CONTROLS_SERVICE_CORE_H_

#include "document_controls_protocol.h"

namespace document_controls::windows_ipc {

inline constexpr wchar_t kDocumentServiceName[] = L"ABAKDocumentControls";

// Closed, compact JSON request schema only: not a general-purpose JSON parser.
// No document bytes, command paths, environment or execution flags are parsed.
Error ParseRequestMetadata(const std::string& metadata, Request* request);

// Success means a refusal was constructed, never that a validator executed.
// Invalid requests clear the reply and must cause the connection to be closed.
Error BuildRefusalReply(const Frame& request_frame, Frame* reply);

// No settings, environment variable, signature or IPC reply can open this gate
// in W3. The service host reports stopped before creating any pipe or worker.
Error ServiceStartupGate();

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_SERVICE_CORE_H_
