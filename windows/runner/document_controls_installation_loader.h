#ifndef RUNNER_DOCUMENT_CONTROLS_INSTALLATION_LOADER_H_
#define RUNNER_DOCUMENT_CONTROLS_INSTALLATION_LOADER_H_

#include "document_controls_installation_manifest.h"
#include "document_controls_installation_security.h"
#include <array>

namespace document_controls::windows_ipc {

struct InstallationFileLease {
  OwnedHandle file;
  std::vector<OwnedHandle> directories;
  std::wstring path;
};

// Move-only capability: no public setter or constructor accepts parsed data,
// a path, an expected hash or a trust flag. Empty/moved-from objects refuse.
class InstalledControls {
 public:
  InstalledControls() = default;
  InstalledControls(const InstalledControls&) = delete;
  InstalledControls& operator=(const InstalledControls&) = delete;
  InstalledControls(InstalledControls&&) noexcept = default;
  InstalledControls& operator=(InstalledControls&&) noexcept = default;

  Error Recheck() const;
  Error ServicePolicy(PeerPolicy* policy) const;
  // Exact accounts from the protected manifest, for process/token QUERY grants.
  Error InspectionUsers(std::vector<std::string>* users) const;
  // Server side only: SID and session are collected from the connected client
  // process via Windows. W2 must still authenticate the actual connection token.
  Error CompanionPolicyForPipe(HANDLE server_pipe, PeerPolicy* policy) const;
 private:
  friend Error LoadInstalledControls(InstalledControls* installation);
  std::array<InstallationFileLease, 3> files_;  // manifest, Companion, service
  InstallationManifest manifest_;
  std::string service_sid_;
};

// Anchored exclusively to the current process image and fixed adjacent names.
// Read-only, never creates an install/service, never opens a pipe or executes.
Error LoadInstalledControls(InstalledControls* installation);

}  // namespace document_controls::windows_ipc
#endif  // RUNNER_DOCUMENT_CONTROLS_INSTALLATION_LOADER_H_
