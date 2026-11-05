#include "document_controls_peer_policy.h"

#include <algorithm>
#include <cwctype>
#include <limits>

namespace document_controls::windows_ipc {
namespace {
bool Digest(const std::string& value) {
  return value.size() == 64 && std::all_of(value.begin(), value.end(), [](char c) {
    return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f');
  });
}
bool Sid(const std::string& value) {
  return value.size() > 6 && value.size() < 185 && value.substr(0, 4) == "S-1-" &&
      value.back() != '-' && value.find("--") == std::string::npos &&
      std::all_of(value.begin() + 4, value.end(), [](char c) {
        return c == '-' || (c >= '0' && c <= '9');
      });
}
bool SamePath(const std::wstring& left, const std::wstring& right) {
  return left.size() == right.size() &&
      std::equal(left.begin(), left.end(), right.begin(), [](wchar_t a, wchar_t b) {
        return std::towlower(a) == std::towlower(b);
      });
}
std::uint64_t Add(std::uint64_t now, std::uint32_t delay) {
  const auto maximum = (std::numeric_limits<std::uint64_t>::max)();
  return maximum - now < delay ? maximum : now + delay;
}
}  // namespace

Error ValidatePeerPolicy(const PeerPolicy& policy) {
  if (!policy.trusted_installation || !Sid(policy.account_sid) ||
      !Digest(policy.image_sha256) || !Digest(policy.signer_certificate_sha256) ||
      policy.image_path.size() < 4 || policy.image_path.size() > 32760 ||
      !((policy.image_path[0] >= L'A' && policy.image_path[0] <= L'Z') ||
        (policy.image_path[0] >= L'a' && policy.image_path[0] <= L'z')) ||
      policy.image_path[1] != L':' || policy.image_path[2] != L'\\' ||
      policy.image_path.find(L':', 2) != std::wstring::npos ||
      policy.image_path.find(L"\\..\\") != std::wstring::npos ||
      policy.image_path.find(L'\0') != std::wstring::npos ||
      policy.image_path.find(L'/', 0) != std::wstring::npos) {
    return {"PEER_POLICY_UNCONFIGURED", "A trusted installed release is required."};
  }
  if (policy.role == PeerRole::kService) {
    if (policy.account_sid != "S-1-5-19" || policy.session_id != 0 ||
        policy.service_name != L"ABAKDocumentControls" ||
        policy.service_sid.substr(0, 9) != "S-1-5-80-" || !Sid(policy.service_sid)) {
      return {"PEER_POLICY_UNCONFIGURED", "Invalid dedicated LocalService policy."};
    }
  } else if (policy.role != PeerRole::kCompanion ||
             !policy.service_name.empty() || !policy.service_sid.empty() ||
             policy.session_id == 0) {
    return {"PEER_POLICY_UNCONFIGURED", "Invalid Companion session policy."};
  }
  return {};
}

Error AuthorizePeer(const PeerPolicy& policy, const PeerFacts& facts) {
  if (auto error = ValidatePeerPolicy(policy)) return error;
  if (!facts.process_alive || facts.pid == 0 ||
      !facts.connection_identity_matches || facts.account_sid != policy.account_sid ||
      facts.session_id != policy.session_id) {
    return {"PEER_IDENTITY_REJECTED", "Peer process, account, or session mismatch."};
  }
  if (!SamePath(facts.image_path, policy.image_path) ||
      facts.image_sha256 != policy.image_sha256 || !facts.signature_valid ||
      facts.signer_certificate_sha256 != policy.signer_certificate_sha256) {
    return {"PEER_IMAGE_REJECTED", "Peer is not the pinned signed release."};
  }
  if (policy.role == PeerRole::kService &&
      (!facts.service_binding_matches || !facts.service_sid_enabled)) {
    return {"PEER_SERVICE_REJECTED", "Peer is not the dedicated running service."};
  }
  return {};
}

IoBudget::IoBudget(std::uint64_t now_ms, std::uint32_t total_ms,
                   std::uint32_t idle_ms)
    : absolute_(Add(now_ms, total_ms)), idle_(Add(now_ms, idle_ms)),
      idle_ms_(idle_ms) {}

std::uint32_t IoBudget::Remaining(std::uint64_t now_ms) const {
  const auto end = (std::min)(absolute_, idle_);
  if (now_ms >= end) return 0;
  return static_cast<std::uint32_t>((std::min)(end - now_ms,
      static_cast<std::uint64_t>((std::numeric_limits<std::uint32_t>::max)())));
}

void IoBudget::Progress(std::uint64_t now_ms) { idle_ = Add(now_ms, idle_ms_); }

}  // namespace document_controls::windows_ipc
