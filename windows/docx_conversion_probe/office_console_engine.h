#ifndef ABAK_PROBE_OFFICE_CONSOLE_ENGINE_H_
#define ABAK_PROBE_OFFICE_CONSOLE_ENGINE_H_

#include "../runner/document_controls_installation_security.h"
#include <array>

namespace docx_probe::office_cli {
using document_controls::windows_ipc::Error;
using document_controls::windows_ipc::OwnedHandle;

struct ConsoleOfficeEngineEvidence {
  std::wstring executable_path;
  std::wstring binary_path;
  std::wstring version;
  std::array<std::string, 2> sha256;
  // Trust is checked with cached Windows material, without online revocation.
  // This does not qualify runtime DLLs, process isolation or a document result.
};

class VerifiedConsoleOfficeEngine {
 public:
  VerifiedConsoleOfficeEngine() = default;
  VerifiedConsoleOfficeEngine(const VerifiedConsoleOfficeEngine&) = delete;
  VerifiedConsoleOfficeEngine& operator=(const VerifiedConsoleOfficeEngine&) = delete;
  VerifiedConsoleOfficeEngine(VerifiedConsoleOfficeEngine&&) noexcept = default;
  VerifiedConsoleOfficeEngine& operator=(VerifiedConsoleOfficeEngine&&) noexcept = default;
  Error Recheck() const;
  const ConsoleOfficeEngineEvidence& evidence() const { return evidence_; }

 private:
  friend Error LoadVerifiedConsoleOfficeEngine(const std::wstring&, VerifiedConsoleOfficeEngine*);
  struct FileLease {
    OwnedHandle file;
    std::vector<OwnedHandle> directories;
  };
  std::array<FileLease, 2> files_;
  ConsoleOfficeEngineEvidence evidence_;
};

// Opens only program/soffice.com and its sibling soffice.bin. Holds both files
// against write/delete and leases protected ancestors until this object dies.
// Does NOT launch LibreOffice, add ACLs, install a service or change WFP.
Error LoadVerifiedConsoleOfficeEngine(const std::wstring& executable,
                              VerifiedConsoleOfficeEngine* engine);
}  // namespace docx_probe::office_cli
#endif
