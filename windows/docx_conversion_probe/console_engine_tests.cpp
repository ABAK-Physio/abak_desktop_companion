#include "office_console_engine.h"
#include <cstdlib>
#include <iostream>
#include <utility>

namespace {
void Check(bool condition, const char* message) {
  if (!condition) { std::cerr << "FAIL: " << message << '\n'; std::exit(1); }
}
bool Digest(const std::string& value) {
  if (value.size() != 64) return false;
  for (char c : value)
    if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'))) return false;
  return true;
}
}  // namespace

int wmain() {
  using namespace docx_probe::office_cli;
  VerifiedConsoleOfficeEngine engine;
  Check(static_cast<bool>(engine.Recheck()), "Empty engine accepted");
  Check(LoadVerifiedConsoleOfficeEngine(L"", nullptr).code == "INVALID_ARGUMENTS",
        "Null output accepted");
  const auto error = LoadVerifiedConsoleOfficeEngine(
      LR"(C:\Program Files\LibreOffice\program\soffice.com)", &engine);
  if (error) {
    std::cerr << "LOAD FAILED: " << error.code << " : " << error.message << '\n';
    return 1;
  }
  Check(!engine.Recheck(), "Loaded engine cannot be rechecked");
  const auto evidence = engine.evidence();
  Check(!evidence.version.empty(), "Missing version");
  Check(Digest(evidence.sha256[0]) && Digest(evidence.sha256[1]), "Missing hashes");
  std::wcout << L"Publisher: The Document Foundation (verified for both files)\n"
             << L"Version: " << evidence.version << L"\n"
             << L"Executable: " << evidence.executable_path << L"\n"
             << L"Binary: " << evidence.binary_path << L"\n";
  std::cout << "soffice.com SHA256: " << evidence.sha256[0] << '\n'
            << "soffice.bin SHA256: " << evidence.sha256[1] << '\n';
  VerifiedConsoleOfficeEngine moved(std::move(engine));
  Check(static_cast<bool>(engine.Recheck()), "Moved-from engine accepted");
  Check(!moved.Recheck(), "Moved engine lost its leases");
  Check(LoadVerifiedConsoleOfficeEngine(LR"(C:\Program Files\LibreOffice\program\soffice.exe)", &moved).code ==
        "OFFICE_PATH_REJECTED", "GUI launcher accepted by console-only verifier");
  Check(static_cast<bool>(moved.Recheck()), "Failed load retained old capability");
  Check(moved.evidence().executable_path.empty(), "Failed load retained old evidence");
  for (const auto& path : {L"program\\soffice.com",
                          L"C:\\ABAK-nonexistent-office-test\\program\\soffice.com",
                          L"\\\\server\\share\\program\\soffice.com"}) {
    Check(static_cast<bool>(LoadVerifiedConsoleOfficeEngine(path, &moved)),
          "Invalid/missing/nonlocal engine accepted");
    Check(static_cast<bool>(moved.Recheck()), "Invalid load left a usable engine");
  }
  std::cout << "PASS: console launcher signature, publisher, hashes, protected paths and leases.\n"
            << "No Office or Java process was executed. No ACL/WFP/service was changed.\n";
}
