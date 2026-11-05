#include "document_controls_installation_security.h"

#include <aclapi.h>
#include <sddl.h>
#include <array>
#include <cstddef>
#include <utility>

#pragma comment(lib, "advapi32.lib")

namespace document_controls::windows_ipc {
namespace {
Error Rejected(const char* reason) {
  return {"PEER_INSTALLATION_REJECTED", reason};
}

bool TrustedOwner(PSID sid) {
  if (!sid || !IsValidSid(sid)) return false;
  if (IsWellKnownSid(sid, WinLocalSystemSid) ||
      IsWellKnownSid(sid, WinBuiltinAdministratorsSid)) return true;
  // This is Windows' built-in servicing identity, not an application signer.
  PSID installer = nullptr;
  if (!ConvertStringSidToSidW(
      L"S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464",
      &installer)) return false;
  const bool equal = EqualSid(sid, installer) != FALSE;
  LocalFree(installer);
  return equal;
}

Error InspectObject(HANDLE object, bool directory, bool volume_root) {
  BY_HANDLE_FILE_INFORMATION info{};
  if (!GetFileInformationByHandle(object, &info) ||
      (info.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT) ||
      ((info.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0) != directory) {
    return Rejected("Installation object is inaccessible, redirected or of the wrong type.");
  }
  PSECURITY_DESCRIPTOR descriptor = nullptr;
  const DWORD status = GetSecurityInfo(object, SE_FILE_OBJECT,
      OWNER_SECURITY_INFORMATION | DACL_SECURITY_INFORMATION,
      nullptr, nullptr, nullptr, nullptr, &descriptor);
  if (status != ERROR_SUCCESS || !descriptor) {
    if (descriptor) LocalFree(descriptor);
    return Rejected("Cannot read installation owner and permissions.");
  }
  const auto error = CheckInstallationDescriptor(descriptor, volume_root);
  LocalFree(descriptor);
  return error;
}

bool SameFinalPath(HANDLE object, const std::wstring& expected) {
  std::array<wchar_t, 32768> buffer{};
  const DWORD size = GetFinalPathNameByHandleW(object, buffer.data(),
      static_cast<DWORD>(buffer.size()), FILE_NAME_NORMALIZED | VOLUME_NAME_DOS);
  if (!size || size >= buffer.size()) return false;
  std::wstring actual(buffer.data(), size);
  if (actual.compare(0, 4, L"\\\\?\\") == 0) actual.erase(0, 4);
  return CompareStringOrdinal(actual.c_str(), -1, expected.c_str(), -1, TRUE) == CSTR_EQUAL;
}
}  // namespace

Error CheckInstallationDescriptor(PSECURITY_DESCRIPTOR descriptor,
                                  bool volume_root) {
  if (!descriptor || !IsValidSecurityDescriptor(descriptor)) {
    return Rejected("Invalid installation security descriptor.");
  }
  PSID owner = nullptr;
  BOOL defaulted = FALSE;
  if (!GetSecurityDescriptorOwner(descriptor, &owner, &defaulted) || !TrustedOwner(owner)) {
    return Rejected("Installation owner is not a trusted system or administrator identity.");
  }
  PACL acl = nullptr;
  BOOL present = FALSE;
  if (!GetSecurityDescriptorDacl(descriptor, &present, &acl, &defaulted) ||
      !present || !acl || !IsValidAcl(acl)) {
    return Rejected("Missing or invalid installation DACL.");
  }
  // Creating siblings at the volume root does not permit replacing an existing
  // protected child. For installation directories, adding files is also unsafe
  // (e.g. DLL planting), so all write rights are disallowed to ordinary users.
  const DWORD forbidden = volume_root ? DELETE | FILE_DELETE_CHILD | WRITE_DAC | WRITE_OWNER :
      DELETE | FILE_DELETE_CHILD | WRITE_DAC | WRITE_OWNER | FILE_WRITE_DATA |
      FILE_APPEND_DATA | FILE_WRITE_EA | FILE_WRITE_ATTRIBUTES;
  GENERIC_MAPPING mapping{FILE_GENERIC_READ, FILE_GENERIC_WRITE,
                          FILE_GENERIC_EXECUTE, FILE_ALL_ACCESS};
  for (DWORD index = 0; index < acl->AceCount; ++index) {
    void* raw = nullptr;
    if (!GetAce(acl, index, &raw)) return Rejected("Cannot inspect installation ACE.");
    const auto* header = static_cast<const ACE_HEADER*>(raw);
    if (header->AceFlags & INHERIT_ONLY_ACE) continue;
    if (header->AceType == ACCESS_DENIED_ACE_TYPE) continue;
    if (header->AceType != ACCESS_ALLOWED_ACE_TYPE ||
        header->AceSize < offsetof(ACCESS_ALLOWED_ACE, SidStart) + 8) {
      return Rejected("Unsupported effective installation ACE.");
    }
    auto* ace = static_cast<ACCESS_ALLOWED_ACE*>(raw);
    PSID sid = &ace->SidStart;
    const auto* sid_header = static_cast<const SID*>(sid);
    if (sid_header->SubAuthorityCount > SID_MAX_SUB_AUTHORITIES ||
        offsetof(ACCESS_ALLOWED_ACE, SidStart) +
            GetSidLengthRequired(sid_header->SubAuthorityCount) > header->AceSize ||
        !IsValidSid(sid)) return Rejected("Invalid installation ACE SID.");
    DWORD rights = ace->Mask;
    MapGenericMask(&rights, &mapping);
    if ((rights & forbidden) && !TrustedOwner(sid)) {
      return Rejected("Installation grants modification rights to a non-administrator identity.");
    }
  }
  return {};
}

Error VerifyProtectedFile(HANDLE file, const std::wstring& canonical_path,
                          std::vector<OwnedHandle>* directories) {
  if (!directories) return {"INVALID_ARGUMENTS", "Missing installation lease output."};
  directories->clear();
  if (canonical_path.size() < 4 || canonical_path.size() > 32760 ||
      !((canonical_path[0] >= L'A' && canonical_path[0] <= L'Z') ||
        (canonical_path[0] >= L'a' && canonical_path[0] <= L'z')) ||
      canonical_path[1] != L':' || canonical_path[2] != L'\\' ||
      canonical_path.back() == L'\\' || canonical_path.find(L'/', 0) != std::wstring::npos ||
      canonical_path.find(L':', 2) != std::wstring::npos ||
      canonical_path.find(L'\0') != std::wstring::npos || !SameFinalPath(file, canonical_path)) {
    return Rejected("Installation file must have its exact canonical local path.");
  }
  const auto root = canonical_path.substr(0, 3);
  if (GetDriveTypeW(root.c_str()) != DRIVE_FIXED) return Rejected("Installation must use a fixed local drive.");
  std::vector<OwnedHandle> held;
  // First the volume root, then every component up to the immediate parent.
  std::size_t end = 2;
  for (;;) {
    const auto path = end == 2 ? root : canonical_path.substr(0, end);
    if (held.size() >= 64) return Rejected("Installation path has too many ancestors.");
    OwnedHandle directory(CreateFileW(path.c_str(), READ_CONTROL | FILE_READ_ATTRIBUTES,
        FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr, OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
    if (!directory) return Rejected("Cannot open installation ancestor.");
    if (auto error = InspectObject(directory.get(), true, end == 2)) return error;
    if (!SameFinalPath(directory.get(), path)) return Rejected("Installation ancestor was redirected.");
    held.push_back(std::move(directory));
    end = canonical_path.find(L'\\', end + 1);
    if (end == std::wstring::npos) break;
  }
  if (auto error = InspectObject(file, false, false)) return error;
  if (!SameFinalPath(file, canonical_path)) return Rejected("Installation file path changed.");
  *directories = std::move(held);
  return {};
}

Error RecheckProtectedFile(HANDLE file,
                           const std::vector<OwnedHandle>& directories) {
  if (directories.empty()) return Rejected("Missing protected installation ancestors.");
  if (auto error = InspectObject(file, false, false)) return error;
  for (std::size_t index = 0; index < directories.size(); ++index) {
    if (auto error = InspectObject(directories[index].get(), true, index == 0)) return error;
  }
  return {};
}
}  // namespace document_controls::windows_ipc
