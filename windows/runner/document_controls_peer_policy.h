#ifndef RUNNER_DOCUMENT_CONTROLS_PEER_POLICY_H_
#define RUNNER_DOCUMENT_CONTROLS_PEER_POLICY_H_

#include "document_controls_protocol.h"

namespace document_controls::windows_ipc {

enum class PeerRole { kService, kCompanion };

// Native, installer-owned policy. Never populate it from an IPC request, an
// environment variable, or an ordinary user-writable preference file.
struct PeerPolicy {
  PeerRole role = PeerRole::kService;
  // The future native loader must first verify the protected release manifest.
  // W2 does not provide that loader; never set this from an IPC request.
  bool trusted_installation = false;
  std::uint32_t session_id = 0;
  std::string account_sid;
  std::wstring image_path;
  std::string image_sha256;
  std::wstring service_name;
  std::string service_sid;
};

// Facts collected by Windows APIs, not fields accepted from a peer's JSON.
struct PeerFacts {
  std::uint32_t pid = 0;
  std::uint32_t session_id = 0;
  std::string account_sid;
  std::wstring image_path;
  std::string image_sha256;
  bool installation_protected = false;
  bool process_alive = false;
  bool connection_identity_matches = false;
  bool service_binding_matches = false;
  bool service_sid_enabled = false;
};

Error ValidatePeerPolicy(const PeerPolicy& policy);
Error AuthorizePeer(const PeerPolicy& policy, const PeerFacts& facts);

// One monotonic absolute deadline plus a shorter inactivity deadline. The
// absolute limit does not restart when a peer slowly sends additional bytes.
class IoBudget {
 public:
  IoBudget(std::uint64_t now_ms, std::uint32_t total_ms,
           std::uint32_t idle_ms);
  std::uint32_t Remaining(std::uint64_t now_ms) const;
  void Progress(std::uint64_t now_ms);
 private:
  std::uint64_t absolute_ = 0;
  std::uint64_t idle_ = 0;
  std::uint32_t idle_ms_ = 0;
};

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_PEER_POLICY_H_
