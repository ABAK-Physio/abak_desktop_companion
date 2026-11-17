#include "document_controls_installation_security.h"

#include <sddl.h>
#include <array>
#include <cstdlib>
#include <iostream>

namespace ipc = document_controls::windows_ipc;
namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << '\n'; std::exit(1); }
}
void Descriptor(const wchar_t* sddl, bool root, bool expected, const char* message) {
  PSECURITY_DESCRIPTOR descriptor = nullptr;
  Check(ConvertStringSecurityDescriptorToSecurityDescriptorW(sddl,
      SDDL_REVISION_1, &descriptor, nullptr) != FALSE, "parse in-memory descriptor");
  const auto error = ipc::CheckInstallationDescriptor(descriptor, root);
  LocalFree(descriptor);
  if ((!error) != expected) std::cerr << error.code << ": " << error.message << '\n';
  Check((!error) == expected, message);
}
}  // namespace

int main() {
  // These descriptors are never applied to any file, directory or system object.
  Descriptor(L"O:BAG:BAD:(A;;FA;;;SY)(A;;FA;;;BA)(A;;GRGX;;;BU)", false, true,
             "standard protected installation accepts");
  Descriptor(L"O:SYG:SYD:(A;;FA;;;SY)(A;;GRGX;;;BU)", false, true,
             "SYSTEM-owned installation accepts");
  Descriptor(L"O:BAG:BAD:(A;;FA;;;SY)(A;;GRGX;;;WD)", false, true,
             "read access alone is not a modification grant");
  Descriptor(L"O:BAG:BAD:(A;;FA;;;SY)(A;;GW;;;BU)", false, false,
             "generic write for users refuses");
  Descriptor(L"O:BAG:BAD:(A;;FA;;;WD)", false, false,
             "everyone full control refuses");
  Descriptor(L"O:BAG:BAD:(A;;WD;;;BU)", false, false,
             "user DACL modification refuses");
  Descriptor(L"O:BAG:BAD:(A;;WO;;;BU)", false, false,
             "user ownership modification refuses");
  Descriptor(L"O:BAG:BAD:(A;;SD;;;BU)", false, false,
             "user deletion refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x00000040;;;BU)", true, false,
             "delete-child on volume ancestor refuses");
  // Reproduce the ASUS C:\ DACL: SYSTEM/Administrators full control, Users
  // read/execute, Authenticated Users Modify (0x1301bf), with OI/CI inheritance.
  // Only in-memory descriptors are used; no real ACL is changed.
  Descriptor(L"O:BAG:BAD:(A;OICI;FA;;;BA)(A;OICI;FA;;;SY)"
             L"(A;OICI;GRGX;;;BU)(A;OICI;0x001301bf;;;AU)", true, true,
             "ASUS root Modify grant accepts without delete-child or ACL changes");
  Descriptor(L"O:BAG:BAD:(A;OICI;FA;;;BA)(A;OICI;FA;;;SY)"
             L"(A;OICI;GRGX;;;BU)(A;OICI;0x001301bf;;;AU)", false, false,
             "the same Modify grant on an installation object still refuses");
  Descriptor(L"O:BAG:BAD:(A;;SD;;;AU)", true, true,
             "DELETE on the volume root itself is distinct from delete-child");
  Descriptor(L"O:BAG:BAD:(A;;0x001301ff;;;AU)", true, false,
             "root Modify plus delete-child still refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x001701bf;;;AU)", true, false,
             "root Modify plus DACL modification still refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x001b01bf;;;AU)", true, false,
             "root Modify plus ownership modification still refuses");
  Descriptor(L"O:BAG:BAD:(A;;GA;;;AU)", true, false,
             "generic full control at the root still refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x00000002;;;BU)", false, false,
             "file creation in installation directory refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x00000004;;;BU)", false, false,
             "subdirectory creation in installation directory refuses");
  Descriptor(L"O:BAG:BAD:(A;;0x00000004;;;BU)", true, true,
             "creating siblings at drive root does not replace existing children");
  Descriptor(L"O:BAG:BAD:(A;OICIIO;FA;;;CO)(A;;GRGX;;;BU)", false, true,
             "inherit-only creator-owner does not grant rights on inspected object");
  Descriptor(L"O:BAG:BAD:(D;;GW;;;BU)(A;;GW;;;BU)", false, false,
             "conservative checker does not use deny entries to forgive write grants");
  Descriptor(L"O:BAG:BAD:(A;;GW;;;LS)", false, false,
             "LocalService cannot modify installed binaries or policy");
  Descriptor(L"O:BUG:BUD:(A;;GRGX;;;BU)", false, false,
             "untrusted owner refuses despite read-only DACL");
  Descriptor(L"O:BAG:BAD:NO_ACCESS_CONTROL", false, false,
             "null DACL refuses");
  Descriptor(L"O:BAG:BA", false, false, "absent DACL refuses");
  Descriptor(L"O:S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464"
             L"G:SYD:(A;;FA;;;S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464)"
             L"(A;;GRGX;;;BU)", false, true, "Windows servicing identity accepts");
  Check(ipc::CheckInstallationDescriptor(nullptr, false).code == "PEER_INSTALLATION_REJECTED",
        "null descriptor refuses");
  std::vector<ipc::OwnedHandle> directories;
  Check(ipc::VerifyProtectedFile(INVALID_HANDLE_VALUE, L"relative.exe", &directories).code ==
        "PEER_INSTALLATION_REJECTED" && directories.empty(), "relative path refuses");
  Check(ipc::VerifyProtectedFile(INVALID_HANDLE_VALUE, L"\\\\server\\share\\app.exe", &directories).code ==
        "PEER_INSTALLATION_REJECTED", "remote path refuses");
  Check(ipc::RecheckProtectedFile(INVALID_HANDLE_VALUE, directories).code ==
        "PEER_INSTALLATION_REJECTED", "missing ancestor lease refuses");
  // Exercise real, read-only traversal on an existing Windows system file.
  // No DLL is loaded or executed here and no permissions are changed.
  std::array<wchar_t, 32768> path{};
  const UINT length = GetSystemDirectoryW(path.data(), static_cast<UINT>(path.size()));
  Check(length > 0 && length < path.size(), "locate existing system directory");
  const std::wstring system_file = std::wstring(path.data(), length) + L"\\kernel32.dll";
  ipc::OwnedHandle image(CreateFileW(system_file.c_str(), GENERIC_READ,
      FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
  Check(static_cast<bool>(image), "open existing system file read-only");
  const DWORD final_length = GetFinalPathNameByHandleW(image.get(), path.data(),
      static_cast<DWORD>(path.size()), FILE_NAME_NORMALIZED | VOLUME_NAME_DOS);
  Check(final_length > 0 && final_length < path.size(), "system file final path");
  std::wstring final_path(path.data(), final_length);
  if (final_path.compare(0, 4, L"\\\\?\\") == 0) final_path.erase(0, 4);
  auto error = ipc::VerifyProtectedFile(image.get(), final_path, &directories);
  if (error) std::cerr << error.code << ": " << error.message << '\n';
  Check(!error && !directories.empty(), "inspect existing protected system file and ancestors");
  Check(!ipc::RecheckProtectedFile(image.get(), directories), "recheck retained protected objects");
  std::cout << checks << " W2 installation checks passed (in-memory ACLs, no ACL changes).\n";
}
