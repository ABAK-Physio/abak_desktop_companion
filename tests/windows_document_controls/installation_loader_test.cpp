#include "document_controls_installation_loader.h"

#include <cstdlib>
#include <iostream>
#include <type_traits>
#include <utility>

namespace ipc = document_controls::windows_ipc;
static_assert(!std::is_copy_constructible<ipc::InstalledControls>::value);
static_assert(!std::is_aggregate<ipc::InstalledControls>::value);
static_assert(!std::is_constructible<ipc::InstalledControls, ipc::InstallationManifest>::value);

namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << " (Win32 " << GetLastError() << ")\n"; std::exit(1); }
}
void EmptyPolicies(const ipc::InstalledControls& installation) {
  ipc::PeerPolicy policy;
  policy.trusted_installation = true;
  policy.account_sid = "pretend-authorized";
  Check(installation.ServicePolicy(&policy).code == "INSTALLATION_NOT_LOADED" &&
        !policy.trusted_installation && policy.account_sid.empty(), "empty installation clears service policy");
  policy.trusted_installation = true;
  Check(installation.CompanionPolicyForPipe(INVALID_HANDLE_VALUE, &policy).code == "INSTALLATION_NOT_LOADED" &&
        !policy.trusted_installation, "empty installation cannot authorize even a client policy");
}
}  // namespace

int main() {
  ipc::InstalledControls installation;
  Check(installation.Recheck().code == "INSTALLATION_NOT_LOADED", "default installation is not approved");
  EmptyPolicies(installation);
  Check(installation.ServicePolicy(nullptr).code == "INVALID_ARGUMENTS", "missing service policy output refuses");
  Check(installation.CompanionPolicyForPipe(INVALID_HANDLE_VALUE, nullptr).code == "INVALID_ARGUMENTS", "missing client policy output refuses");
  Check(ipc::LoadInstalledControls(nullptr).code == "INVALID_ARGUMENTS", "missing installation output refuses");
  ipc::InstalledControls moved(std::move(installation));
  EmptyPolicies(installation);
  EmptyPolicies(moved);

  // Script compiles THIS TEST under the approved Companion basename in its
  // private TEMP directory. It is not the Flutter application or service host.
  // A correctly named executable in a user-writable folder must still refuse.
  auto error = ipc::LoadInstalledControls(&installation);
  if (error.code != "PEER_INSTALLATION_REJECTED") std::cerr << error.code << ": " << error.message << '\n';
  Check(error.code == "PEER_INSTALLATION_REJECTED", "approved basename in TEMP does not establish trust");
  EmptyPolicies(installation);
  DWORD before = 0, after = 0;
  Check(GetProcessHandleCount(GetCurrentProcess(), &before) != FALSE, "handle count before repeated failures");
  for (int i = 0; i < 10; ++i) {
    Check(ipc::LoadInstalledControls(&installation).code == "PEER_INSTALLATION_REJECTED", "unprotected source consistently refuses");
    EmptyPolicies(installation);
  }
  Check(GetProcessHandleCount(GetCurrentProcess(), &after) != FALSE && after <= before + 2,
        "failed loading releases file and directory handles");
  std::cout << checks << " W4 Windows loader checks passed (unprotected TEMP installation refused).\n";
  std::cout << "No installation, service, validator, patient document or ACL change used.\n";
}
