#ifndef RUNNER_DOCUMENT_CONTROLS_OFFICE_ENGINE_H_
#define RUNNER_DOCUMENT_CONTROLS_OFFICE_ENGINE_H_

#include "document_controls_installation_security.h"
#include <array>

namespace document_controls::windows_ipc {

struct OfficeEngineEvidence {
  std::wstring executable_path;
  std::wstring binary_path;
  std::wstring version;
  std::array<std::string, 2> sha256;
  // Trust is checked with cached Windows material, without online revocation.
  // This does not qualify runtime DLLs, process isolation or a document result.
};

class VerifiedOfficeEngine {
 public:
  VerifiedOfficeEngine() = default;
  VerifiedOfficeEngine(const VerifiedOfficeEngine&) = delete;
  VerifiedOfficeEngine& operator=(const VerifiedOfficeEngine&) = delete;
  VerifiedOfficeEngine(VerifiedOfficeEngine&&) noexcept = default;
  VerifiedOfficeEngine& operator=(VerifiedOfficeEngine&&) noexcept = default;
  Error Recheck() const;
  const OfficeEngineEvidence& evidence() const { return evidence_; }

 private:
  friend Error LoadVerifiedOfficeEngine(const std::wstring&, VerifiedOfficeEngine*);
  struct FileLease {
    OwnedHandle file;
    std::vector<OwnedHandle> directories;
  };
  std::array<FileLease, 2> files_;
  OfficeEngineEvidence evidence_;
};

// Opens only program/soffice.exe and its sibling soffice.bin. Holds both files
// against write/delete and leases protected ancestors until this object dies.
// Does NOT launch LibreOffice, add ACLs, install a service or change WFP.
Error LoadVerifiedOfficeEngine(const std::wstring& executable,
                              VerifiedOfficeEngine* engine);
}  // namespace document_controls::windows_ipc
#endif
