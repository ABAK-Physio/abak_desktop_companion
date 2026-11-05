#ifndef RUNNER_DOCUMENT_CONTROLS_PEER_IDENTITY_H_
#define RUNNER_DOCUMENT_CONTROLS_PEER_IDENTITY_H_

#include "document_controls_pipe_transport.h"
#include <vector>

namespace document_controls::windows_ipc {

enum class PipePeer { kServer, kClient };

// Retains the process and read-only image handles until the exchange ends.
struct PeerLease {
  OwnedHandle process;
  OwnedHandle image;
  std::vector<OwnedHandle> directories;
  PeerFacts facts;
};

// The caller holds a connected, overlapped, local pipe. No request frame or
// document is sent before this handshake succeeds. Policy is native/trusted.
// A successful identity check does NOT qualify validator isolation.
Error AuthenticatePipePeer(HANDLE pipe, PipePeer peer, const PeerPolicy& policy,
                           IoBudget* budget, PeerLease* lease);
Error RecheckPipePeer(HANDLE pipe, PipePeer peer, const PeerPolicy& policy,
                      const PeerLease& lease);

// Read-only helpers. No certificate, trust store, or online service is used.
Error ReadTokenIdentity(HANDLE token, std::string* sid, DWORD* session);
Error HashOpenImage(HANDLE file, std::string* digest);

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_PEER_IDENTITY_H_
