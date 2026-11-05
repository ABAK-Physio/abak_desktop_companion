#include "document_controls_peer_policy.h"
#include "document_controls_pipe_client.h"

#include <cstdlib>
#include <iostream>
#include <limits>

namespace ipc = document_controls::windows_ipc;
namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << '\n'; std::exit(1); }
}
ipc::PeerPolicy Companion() {
  ipc::PeerPolicy policy;
  policy.role = ipc::PeerRole::kCompanion;
  policy.trusted_installation = true;  // Synthetic model only, not an installer attestation.
  policy.account_sid = "S-1-5-21-123-456-789-1001";
  policy.session_id = 3;
  policy.image_path = L"C:\\Program Files\\ABAK\\Companion.exe";
  policy.image_sha256 = std::string(64, 'a');
  policy.signer_certificate_sha256 = std::string(64, 'b');
  return policy;
}
ipc::PeerFacts Facts(const ipc::PeerPolicy& policy) {
  ipc::PeerFacts facts;
  facts.pid = 42;
  facts.account_sid = policy.account_sid;
  facts.session_id = policy.session_id;
  facts.image_path = policy.image_path;
  facts.image_sha256 = policy.image_sha256;
  facts.signer_certificate_sha256 = policy.signer_certificate_sha256;
  facts.process_alive = facts.signature_valid = facts.connection_identity_matches = true;
  return facts;
}
}

int main() {
  Check(static_cast<bool>(ipc::ValidatePeerPolicy({})), "default policy refuses");
  auto policy = Companion();
  Check(!ipc::ValidatePeerPolicy(policy), "complete model policy");
  auto facts = Facts(policy);
  Check(!ipc::AuthorizePeer(policy, facts), "matching synthetic identity");
  policy.trusted_installation = false;
  Check(ipc::AuthorizePeer(policy, facts).code == "PEER_POLICY_UNCONFIGURED", "unqualified installation refuses");
  policy = Companion();
  for (const auto* digest : {"", "abc", "../release", "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}) {
    policy.image_sha256 = digest;
    Check(static_cast<bool>(ipc::ValidatePeerPolicy(policy)), "malformed pin refuses");
  }
  policy = Companion();
  for (const auto* path : {L"relative.exe", L"\\\\server\\share\\app.exe", L"C:/Program Files/ABAK/app.exe",
                          L"1:\\app.exe", L"C:\\ABAK\\app.exe:alternate", L"C:\\ABAK\\..\\app.exe"}) {
    policy.image_path = path;
    Check(static_cast<bool>(ipc::ValidatePeerPolicy(policy)), "nonlocal image policy refuses");
  }
  policy = Companion();
  policy.account_sid = "S-1-5-";
  Check(static_cast<bool>(ipc::ValidatePeerPolicy(policy)), "malformed SID refuses");
  policy = Companion();
  facts = Facts(policy);
  facts.pid = 0;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "missing PID refuses");
  facts = Facts(policy); facts.process_alive = false;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "exited peer refuses");
  facts = Facts(policy); facts.connection_identity_matches = false;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "connection token mismatch refuses");
  facts = Facts(policy); facts.account_sid += "0";
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "another account refuses");
  facts = Facts(policy); ++facts.session_id;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "another session refuses");
  facts = Facts(policy); facts.image_path = L"C:\\Users\\User\\Companion.exe";
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "same account different executable refuses");
  facts = Facts(policy); facts.image_sha256[0] = 'f';
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "different release same publisher refuses");
  facts = Facts(policy); facts.signer_certificate_sha256[0] = 'f';
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "different signer refuses");
  facts = Facts(policy); facts.signature_valid = false;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "unsigned executable refuses");
  policy.role = ipc::PeerRole::kService;
  policy.account_sid = "S-1-5-19";
  policy.session_id = 0;
  policy.service_name = L"ABAKDocumentControls";
  policy.service_sid = "S-1-5-80-1-2-3-4-5";
  facts = Facts(policy);
  Check(ipc::AuthorizePeer(policy, facts).code == "PEER_SERVICE_REJECTED", "LocalService alone is insufficient");
  facts.service_sid_enabled = true;
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "service PID binding required");
  facts.service_binding_matches = true;
  Check(!ipc::AuthorizePeer(policy, facts), "matching synthetic service");
  policy.service_name = L"ABAKDocumentControlsProbe";
  Check(static_cast<bool>(ipc::AuthorizePeer(policy, facts)), "prototype service is never allowed");
  policy.service_name = L"ABAKDocumentControls";
  policy.account_sid = "S-1-5-18";
  Check(static_cast<bool>(ipc::ValidatePeerPolicy(policy)), "LocalSystem not silently substituted");

  ipc::IoBudget budget(1000, 1000, 100);
  Check(budget.Remaining(1000) == 100, "initial inactivity deadline");
  Check(budget.Remaining(1100) == 0, "inactivity expires");
  ipc::IoBudget trickle(0, 1000, 100);
  for (std::uint64_t time = 1; time < 1000; time += 10) {
    Check(trickle.Remaining(time) > 0, "progress before absolute limit");
    trickle.Progress(time);
    Check(trickle.Remaining(time) <= 1000 - time, "absolute deadline never extends");
  }
  Check(trickle.Remaining(1000) == 0, "slow peer cannot extend transaction");
  ipc::IoBudget zero(0, 0, 1000);
  Check(zero.Remaining(0) == 0, "zero total budget refuses");
  const auto maximum = (std::numeric_limits<std::uint64_t>::max)();
  ipc::IoBudget overflow(maximum - 10, 1000, 500);
  Check(overflow.Remaining(maximum - 5) == 5, "deadline arithmetic does not wrap");
  Check(overflow.Remaining(maximum) == 0, "saturated deadline expires");
  ipc::Request request;
  request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  ipc::Frame frame{"pretend success", {1}};
  Check(ipc::Exchange(request, &frame).code == ipc::kIsolationUnavailable &&
        frame.metadata.empty() && frame.payload.empty(), "W1 production gate still refuses");
  std::cout << checks << " W2 policy/deadline checks passed (synthetic policy facts).\n";
}
