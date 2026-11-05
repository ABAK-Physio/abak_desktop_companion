#ifndef RUNNER_DOCUMENT_CONTROLS_INSTALLATION_SECURITY_H_
#define RUNNER_DOCUMENT_CONTROLS_INSTALLATION_SECURITY_H_

#include "document_controls_pipe_transport.h"
#include <vector>

namespace document_controls::windows_ipc {

// Conservative ACL policy, also exercised with in-memory descriptors in tests.
// Only SYSTEM, Administrators and the Windows TrustedInstaller identity may
// own/write installation objects. Inherit-only entries do not grant access to
// the object itself. Unrecognized effective ACE types are refused.
Error CheckInstallationDescriptor(PSECURITY_DESCRIPTOR descriptor,
                                  bool volume_root);

// Read-only inspection of an already-open ordinary file and each ancestor on
// its fixed local drive. Retains non-delete-shared directory handles. Also usable
// by the future manifest loader BEFORE parsing a protected manifest.
// This does not authenticate the source of a download or inspect loaded DLLs.
Error VerifyProtectedFile(HANDLE file, const std::wstring& canonical_path,
                          std::vector<OwnedHandle>* directories);
Error RecheckProtectedFile(HANDLE file,
                           const std::vector<OwnedHandle>& directories);

}  // namespace document_controls::windows_ipc
#endif  // RUNNER_DOCUMENT_CONTROLS_INSTALLATION_SECURITY_H_
