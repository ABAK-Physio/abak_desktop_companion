#ifndef RUNNER_DOCUMENT_CONTROLS_INSTALLATION_MANIFEST_H_
#define RUNNER_DOCUMENT_CONTROLS_INSTALLATION_MANIFEST_H_

#include "document_controls_protocol.h"

namespace document_controls::windows_ipc {

inline constexpr std::size_t kMaxInstallationManifestBytes = 8192;
inline constexpr std::size_t kMaxInstallationUsers = 16;
inline constexpr wchar_t kInstallationManifestName[] = L"document_controls_installation.json";
inline constexpr wchar_t kInstalledCompanionName[] = L"abak_desktop_companion.exe";
inline constexpr wchar_t kInstalledServiceName[] = L"ABAKDocumentControls.exe";

// Parsed data only, NEVER a proof of trust. Only the native protected-file loader
// may use it to create a PeerPolicy with trusted_installation=true.
struct InstallationManifest {
  std::uint32_t manifest_version = 1;
  std::uint32_t protocol = kProtocol;
  std::string contract = kContract;
  std::string companion_sha256;
  std::string service_sha256;
  std::vector<std::string> allowed_users;
};

Error ValidateInstallationManifest(const InstallationManifest& manifest);
Error ParseInstallationManifest(const std::string& text, InstallationManifest* manifest);
// Exact individual-account SID matching, not group membership or authorization.
bool ManifestListsUser(const InstallationManifest& manifest, const std::string& sid);

}  // namespace document_controls::windows_ipc
#endif  // RUNNER_DOCUMENT_CONTROLS_INSTALLATION_MANIFEST_H_
