#include "document_controls_installation_loader.h"
#include "document_controls_peer_identity.h"

#include <sddl.h>
#include <utility>

#pragma comment(lib, "advapi32.lib")

namespace document_controls::windows_ipc {
namespace {
Error Failure(const char* code, const char* message) { return {code, message}; }
Error NotLoaded() { return Failure("INSTALLATION_NOT_LOADED", "No protected installation has been loaded."); }

bool SamePath(const std::wstring& a, const std::wstring& b) {
  return CompareStringOrdinal(a.c_str(), -1, b.c_str(), -1, TRUE) == CSTR_EQUAL;
}
Error OpenProtected(const std::wstring& path, InstallationFileLease* lease) {
  lease->file.reset(CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ,
      nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
  if (!lease->file) return Failure("INSTALLATION_FILE_UNAVAILABLE", "Cannot open an expected installed file read-only.");
  lease->path = path;
  return VerifyProtectedFile(lease->file.get(), path, &lease->directories);
}
Error CurrentImage(InstallationFileLease* image) {
  std::array<wchar_t, 32768> buffer{};
  DWORD length = static_cast<DWORD>(buffer.size());
  if (!QueryFullProcessImageNameW(GetCurrentProcess(), 0, buffer.data(), &length)) {
    return Failure("INSTALLATION_ANCHOR_REJECTED", "Cannot obtain the current process image from Windows.");
  }
  image->file.reset(CreateFileW(buffer.data(), GENERIC_READ, FILE_SHARE_READ,
      nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
  if (!image->file) return Failure("INSTALLATION_ANCHOR_REJECTED", "Cannot open the current image read-only.");
  length = GetFinalPathNameByHandleW(image->file.get(), buffer.data(),
      static_cast<DWORD>(buffer.size()), FILE_NAME_NORMALIZED | VOLUME_NAME_DOS);
  if (!length || length >= buffer.size()) return Failure("INSTALLATION_ANCHOR_REJECTED", "Cannot resolve the current image.");
  image->path.assign(buffer.data(), length);
  if (image->path.compare(0, 4, L"\\\\?\\") == 0) image->path.erase(0, 4);
  const auto slash = image->path.find_last_of(L'\\');
  if (slash == std::wstring::npos) return Failure("INSTALLATION_ANCHOR_REJECTED", "Current image has no installation directory.");
  const auto name = image->path.substr(slash + 1);
  if (!SamePath(name, kInstalledCompanionName) && !SamePath(name, kInstalledServiceName)) {
    return Failure("INSTALLATION_ANCHOR_REJECTED", "Current executable is not Companion or its dedicated service.");
  }
  return VerifyProtectedFile(image->file.get(), image->path, &image->directories);
}
Error ReadManifest(HANDLE file, std::string* text) {
  LARGE_INTEGER size{}, start{};
  if (!GetFileSizeEx(file, &size) || size.QuadPart <= 0 ||
      static_cast<std::uint64_t>(size.QuadPart) > kMaxInstallationManifestBytes ||
      !SetFilePointerEx(file, start, nullptr, FILE_BEGIN)) {
    return Failure("INSTALLATION_MANIFEST_INVALID", "Installed manifest size is invalid.");
  }
  text->assign(static_cast<std::size_t>(size.QuadPart), '\0');
  std::size_t offset = 0;
  while (offset < text->size()) {
    DWORD read = 0;
    if (!ReadFile(file, text->data() + offset, static_cast<DWORD>(text->size() - offset), &read, nullptr) || !read) {
      text->clear();
      return Failure("INSTALLATION_MANIFEST_INVALID", "Cannot read the complete installed manifest.");
    }
    offset += read;
  }
  return {};
}
Error ServiceSid(std::string* sid) {
  std::array<DWORD, SECURITY_MAX_SID_SIZE / sizeof(DWORD)> buffer{};
  DWORD bytes = static_cast<DWORD>(sizeof(buffer));
  std::array<wchar_t, 256> domain{};
  DWORD characters = static_cast<DWORD>(domain.size());
  SID_NAME_USE kind{};
  // Fixed NT SERVICE authority, never a user-supplied account or server name.
  if (!LookupAccountNameW(nullptr, L"NT SERVICE\\ABAKDocumentControls", buffer.data(),
      &bytes, domain.data(), &characters, &kind) || !IsValidSid(buffer.data())) {
    return Failure("INSTALLATION_SERVICE_ID_UNAVAILABLE", "Windows cannot resolve the dedicated service SID.");
  }
  LPSTR value = nullptr;
  if (!ConvertSidToStringSidA(buffer.data(), &value)) {
    return Failure("INSTALLATION_SERVICE_ID_UNAVAILABLE", "Cannot encode the dedicated service SID.");
  }
  sid->assign(value);
  LocalFree(value);
  if (sid->compare(0, 9, "S-1-5-80-") != 0) return Failure("INSTALLATION_SERVICE_ID_UNAVAILABLE", "Unexpected service SID authority.");
  return {};
}
}  // namespace

Error LoadInstalledControls(InstalledControls* installation) {
  if (!installation) return Failure("INVALID_ARGUMENTS", "Missing installation output.");
  *installation = InstalledControls{};
  InstallationFileLease self;
  if (auto error = CurrentImage(&self)) return error;
  const auto root = self.path.substr(0, self.path.find_last_of(L'\\') + 1);
  InstalledControls loaded;
  if (auto error = OpenProtected(root + kInstallationManifestName, &loaded.files_[0])) return error;
  std::string text;
  if (auto error = ReadManifest(loaded.files_[0].file.get(), &text)) return error;
  // The manifest and ALL ancestors were inspected BEFORE reading/parsing bytes.
  if (auto error = ParseInstallationManifest(text, &loaded.manifest_)) return error;
  if (auto error = OpenProtected(root + kInstalledCompanionName, &loaded.files_[1])) return error;
  if (auto error = OpenProtected(root + kInstalledServiceName, &loaded.files_[2])) return error;
  for (std::size_t index = 1; index < loaded.files_.size(); ++index) {
    std::string digest;
    if (auto error = HashOpenImage(loaded.files_[index].file.get(), &digest)) return error;
    const auto& expected = index == 1 ? loaded.manifest_.companion_sha256 : loaded.manifest_.service_sha256;
    if (digest != expected) return Failure("INSTALLATION_IMAGE_MISMATCH", "Installed image differs from the protected manifest.");
  }
  const auto own_index = SamePath(self.path, loaded.files_[1].path) ? 1u : 2u;
  BY_HANDLE_FILE_INFORMATION original{}, pinned{};
  if (!GetFileInformationByHandle(self.file.get(), &original) ||
      !GetFileInformationByHandle(loaded.files_[own_index].file.get(), &pinned) ||
      original.dwVolumeSerialNumber != pinned.dwVolumeSerialNumber ||
      original.nFileIndexHigh != pinned.nFileIndexHigh || original.nFileIndexLow != pinned.nFileIndexLow) {
    return Failure("INSTALLATION_ANCHOR_REJECTED", "Current image changed during installation inspection.");
  }
  if (auto error = ServiceSid(&loaded.service_sid_)) return error;
  if (auto error = loaded.Recheck()) return error;
  *installation = std::move(loaded);
  return {};
}

Error InstalledControls::Recheck() const {
  if (service_sid_.empty()) return NotLoaded();
  for (const auto& object : files_) {
    if (!object.file || object.directories.empty()) return NotLoaded();
    if (auto error = RecheckProtectedFile(object.file.get(), object.directories)) return error;
  }
  return {};
}

Error InstalledControls::ServicePolicy(PeerPolicy* policy) const {
  if (!policy) return Failure("INVALID_ARGUMENTS", "Missing service policy output.");
  *policy = {};
  if (auto error = Recheck()) return error;
  PeerPolicy value;
  value.role = PeerRole::kService;
  value.trusted_installation = true;
  value.account_sid = "S-1-5-19";
  value.session_id = 0;
  value.image_path = files_[2].path;
  value.image_sha256 = manifest_.service_sha256;
  value.service_name = L"ABAKDocumentControls";
  value.service_sid = service_sid_;
  if (auto error = ValidatePeerPolicy(value)) return error;
  *policy = std::move(value);
  return {};
}

Error InstalledControls::InspectionUsers(std::vector<std::string>* users) const {
  if (!users) return Failure("INVALID_ARGUMENTS", "Missing inspection users output.");
  users->clear();
  if (auto error = Recheck()) return error;
  *users = manifest_.allowed_users;
  return {};
}

Error InstalledControls::CompanionPolicyForPipe(HANDLE server_pipe, PeerPolicy* policy) const {
  if (!policy) return Failure("INVALID_ARGUMENTS", "Missing Companion policy output.");
  *policy = {};
  if (auto error = Recheck()) return error;
  ULONG pid = 0;
  if (!GetNamedPipeClientProcessId(server_pipe, &pid) || !pid) {
    return Failure("PEER_IDENTITY_REJECTED", "Cannot identify the connected client process.");
  }
  OwnedHandle process(OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid));
  HANDLE raw = nullptr;
  if (!process || !OpenProcessToken(process.get(), TOKEN_QUERY, &raw)) {
    return Failure("PEER_IDENTITY_REJECTED", "Cannot inspect the connected client token.");
  }
  OwnedHandle token(raw);
  PeerPolicy value;
  value.role = PeerRole::kCompanion;
  DWORD session = 0;
  if (auto error = ReadTokenIdentity(token.get(), &value.account_sid, &session)) return error;
  if (!session || !ManifestListsUser(manifest_, value.account_sid)) {
    return Failure("INSTALLATION_USER_NOT_ALLOWED", "Connected account or session is not authorized by the installation.");
  }
  value.session_id = session;
  value.trusted_installation = true;
  value.image_path = files_[1].path;
  value.image_sha256 = manifest_.companion_sha256;
  if (auto error = ValidatePeerPolicy(value)) return error;
  *policy = std::move(value);
  return {};
}
}  // namespace document_controls::windows_ipc
