// Installed console verifier, based on the existing .exe verifier.
// The production verifier and its accepted paths remain unchanged.
#include "office_console_engine.h"

#include <wincrypt.h>
#include <wintrust.h>
#include <softpub.h>
#include <winver.h>
#include <cstring>
#include <cstdint>
#include <utility>

namespace document_controls_runtime::office_cli {
using document_controls::windows_ipc::VerifyProtectedFile;
using document_controls::windows_ipc::RecheckProtectedFile;
namespace {
Error Reject(const char* code, const char* message) { return {code, message}; }

bool LocalEnginePath(const std::wstring& path) {
  // Reject remote/device/relative/ADS paths before any file open (even a read).
  if (path.size() < 4 || path.size() > 32760 ||
      !((path[0] >= L'A' && path[0] <= L'Z') ||
        (path[0] >= L'a' && path[0] <= L'z')) ||
      path[1] != L':' || path[2] != L'\\' ||
      path.find(L'/', 0) != std::wstring::npos ||
      path.find(L':', 2) != std::wstring::npos ||
      path.find(L'\0') != std::wstring::npos) return false;
  std::size_t start = 3;
  for (std::size_t i = 3; i <= path.size(); ++i) {
    if (i < path.size() && path[i] != L'\\') {
      const auto c = path[i];
      if (c < 32 || c == L'"' || c == L'<' || c == L'>' ||
          c == L'|' || c == L'?' || c == L'*') return false;
      continue;
    }
    const auto component = path.substr(start, i - start);
    if (component.empty() || component == L"." || component == L".." ||
        component.back() == L'.' || component.back() == L' ') return false;
    start = i + 1;
  }
  return GetDriveTypeW(path.substr(0, 3).c_str()) == DRIVE_FIXED;
}

std::wstring CertificateAttribute(PCCERT_CONTEXT certificate, const char* oid) {
  const DWORD size = CertGetNameStringW(certificate, CERT_NAME_ATTR_TYPE, 0,
      const_cast<char*>(oid), nullptr, 0);
  if (size < 2 || size > 1024) return {};
  std::wstring result(size, L'\0');
  if (CertGetNameStringW(certificate, CERT_NAME_ATTR_TYPE, 0,
          const_cast<char*>(oid), result.data(), size) != size) return {};
  result.pop_back();
  return result;
}

struct TrustLibrary {
  HMODULE module = LoadLibraryExW(L"wintrust.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32);
  ~TrustLibrary() { if (module) FreeLibrary(module); }
  TrustLibrary() = default;
  TrustLibrary(const TrustLibrary&) = delete;
  TrustLibrary& operator=(const TrustLibrary&) = delete;
  template <typename T> T Function(const char* name) const {
    T result = nullptr;
    const auto address = module ? GetProcAddress(module, name) : nullptr;
    static_assert(sizeof(result) == sizeof(address), "Function pointer width");
    std::memcpy(&result, &address, sizeof(result));
    return result;
  }
};

Error VerifyPublisher(HANDLE file, const std::wstring& path) {
  TrustLibrary library;
  using ProviderFn = CRYPT_PROVIDER_DATA* (WINAPI*)(HANDLE);
  using SignerFn = CRYPT_PROVIDER_SGNR* (WINAPI*)(CRYPT_PROVIDER_DATA*, DWORD, BOOL, DWORD);
  const auto providerFn = library.Function<ProviderFn>("WTHelperProvDataFromStateData");
  const auto signerFn = library.Function<SignerFn>("WTHelperGetProvSignerFromChain");
  if (!providerFn || !signerFn)
    return Reject("OFFICE_TRUST_UNAVAILABLE", "Windows signature inspection is unavailable.");
  WINTRUST_FILE_INFO info{};
  info.cbStruct = sizeof(info);
  info.pcwszFilePath = path.c_str();
  info.hFile = file;
  WINTRUST_DATA trust{};
  trust.cbStruct = sizeof(trust);
  trust.dwUIChoice = WTD_UI_NONE;
  trust.fdwRevocationChecks = WTD_REVOKE_NONE;
  trust.dwUnionChoice = WTD_CHOICE_FILE;
  trust.pFile = &info;
  trust.dwStateAction = WTD_STATEACTION_VERIFY;
  trust.dwProvFlags = WTD_CACHE_ONLY_URL_RETRIEVAL |
                     WTD_REVOCATION_CHECK_NONE | WTD_DISABLE_MD2_MD4;
  GUID action = WINTRUST_ACTION_GENERIC_VERIFY_V2;
  struct CloseState {
    GUID* action;
    WINTRUST_DATA* trust;
    ~CloseState() {
      trust->dwStateAction = WTD_STATEACTION_CLOSE;
      WinVerifyTrust(nullptr, action, trust);
    }
  } close{&action, &trust};
  const LONG status = WinVerifyTrust(nullptr, &action, &trust);
  if (status != ERROR_SUCCESS)
    return Reject("OFFICE_SIGNATURE_REJECTED", "LibreOffice signature was not trusted using cached Windows material.");
  auto* provider = providerFn(trust.hWVTStateData);
  auto* signer = provider ? signerFn(provider, 0, FALSE, 0) : nullptr;
  if (!signer || !signer->csCertChain || !signer->pasCertChain ||
      !signer->pasCertChain[0].pCert)
    return Reject("OFFICE_SIGNER_UNAVAILABLE", "Verified publisher certificate is unavailable.");
  const auto certificate = signer->pasCertChain[0].pCert;
  if (CertificateAttribute(certificate, szOID_COMMON_NAME) != L"The Document Foundation" ||
      CertificateAttribute(certificate, szOID_ORGANIZATION_NAME) != L"The Document Foundation" ||
      CertificateAttribute(certificate, szOID_COUNTRY_NAME) != L"DE")
    return Reject("OFFICE_PUBLISHER_REJECTED", "LibreOffice publisher is not The Document Foundation.");
  return {};
}

Error HashFile(HANDLE file, std::string* digest) {
  digest->clear();
  LARGE_INTEGER size{}, start{};
  if (!GetFileSizeEx(file, &size) || size.QuadPart <= 0 ||
      size.QuadPart > 256LL * 1024 * 1024 ||
      !SetFilePointerEx(file, start, nullptr, FILE_BEGIN))
    return Reject("OFFICE_HASH_FAILED", "Invalid engine file size or position.");
  struct Crypto {
    HCRYPTPROV provider = 0;
    HCRYPTHASH hash = 0;
    ~Crypto() {
      if (hash) CryptDestroyHash(hash);
      if (provider) CryptReleaseContext(provider, 0);
    }
  } crypto;
  if (!CryptAcquireContextW(&crypto.provider, nullptr, nullptr, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) ||
      !CryptCreateHash(crypto.provider, CALG_SHA_256, 0, 0, &crypto.hash))
    return Reject("OFFICE_HASH_FAILED", "Cannot initialize engine SHA-256.");
  std::array<BYTE, 65536> buffer{};
  std::uint64_t total = 0;
  for (;;) {
    DWORD read = 0;
    if (!ReadFile(file, buffer.data(), static_cast<DWORD>(buffer.size()), &read, nullptr))
      return Reject("OFFICE_HASH_FAILED", "Cannot read the engine file.");
    if (!read) break;
    total += read;
    if (total > static_cast<std::uint64_t>(size.QuadPart) ||
        !CryptHashData(crypto.hash, buffer.data(), read, 0))
      return Reject("OFFICE_HASH_FAILED", "Cannot hash the complete engine file.");
  }
  std::array<BYTE, 32> bytes{};
  DWORD length = static_cast<DWORD>(bytes.size());
  if (total != static_cast<std::uint64_t>(size.QuadPart) ||
      !CryptGetHashParam(crypto.hash, HP_HASHVAL, bytes.data(), &length, 0) ||
      length != bytes.size() || !SetFilePointerEx(file, start, nullptr, FILE_BEGIN))
    return Reject("OFFICE_HASH_FAILED", "Incomplete engine hash.");
  constexpr char hex[] = "0123456789abcdef";
  for (BYTE byte : bytes) {
    digest->push_back(hex[byte >> 4]); digest->push_back(hex[byte & 15]);
  }
  return {};
}

Error ReadVersion(const std::wstring& path, std::wstring* version) {
  const DWORD size = GetFileVersionInfoSizeW(path.c_str(), nullptr);
  if (!size || size > 4 * 1024 * 1024)
    return Reject("OFFICE_VERSION_REJECTED", "Engine version resource is unavailable.");
  std::vector<BYTE> bytes(size);
  if (!GetFileVersionInfoW(path.c_str(), 0, size, bytes.data()))
    return Reject("OFFICE_VERSION_REJECTED", "Cannot read engine version.");
  VS_FIXEDFILEINFO* info = nullptr;
  UINT length = 0;
  if (!VerQueryValueW(bytes.data(), L"\\", reinterpret_cast<void**>(&info), &length) ||
      !info || length < sizeof(*info) || info->dwSignature != 0xFEEF04BD)
    return Reject("OFFICE_VERSION_REJECTED", "Invalid engine version resource.");
  *version = std::to_wstring(HIWORD(info->dwProductVersionMS)) + L"." +
      std::to_wstring(LOWORD(info->dwProductVersionMS)) + L"." +
      std::to_wstring(HIWORD(info->dwProductVersionLS)) + L"." +
      std::to_wstring(LOWORD(info->dwProductVersionLS));
  return {};
}
}  // namespace

Error LoadVerifiedConsoleOfficeEngine(const std::wstring& requested_executable,
                              VerifiedConsoleOfficeEngine* engine) {
  if (!engine) return Reject("INVALID_ARGUMENTS", "Missing verified engine output.");
  const std::wstring executable = requested_executable;
  *engine = VerifiedConsoleOfficeEngine{};
  const std::wstring suffix = L"\\program\\soffice.com";
  if (!LocalEnginePath(executable) || executable.size() <= suffix.size() ||
      CompareStringOrdinal(executable.c_str() + executable.size() - suffix.size(),
          -1, suffix.c_str(), -1, TRUE) != CSTR_EQUAL)
    return Reject("OFFICE_PATH_REJECTED", "Select the installed program/soffice.com.");
  VerifiedConsoleOfficeEngine loaded;
  loaded.evidence_.executable_path = executable;
  loaded.evidence_.binary_path = executable.substr(0, executable.size() - 3) + L"bin";
  const std::array<std::wstring, 2> paths{executable, loaded.evidence_.binary_path};
  for (std::size_t i = 0; i < paths.size(); ++i) {
    auto& lease = loaded.files_[i];
    lease.file.reset(CreateFileW(paths[i].c_str(), GENERIC_READ | READ_CONTROL,
        FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
    if (!lease.file)
      return Reject("OFFICE_FILE_UNAVAILABLE", "Cannot pin a LibreOffice engine file read-only.");
    if (auto error = VerifyProtectedFile(lease.file.get(), paths[i], &lease.directories)) return error;
    if (auto error = VerifyPublisher(lease.file.get(), paths[i])) return error;
    if (auto error = HashFile(lease.file.get(), &loaded.evidence_.sha256[i])) return error;
    std::wstring version;
    if (auto error = ReadVersion(paths[i], &version)) return error;
    if (i == 0) loaded.evidence_.version = version;
    else if (version != loaded.evidence_.version)
      return Reject("OFFICE_VERSION_MISMATCH", "LibreOffice launcher and engine versions differ.");
  }
  if (auto error = loaded.Recheck()) return error;
  *engine = std::move(loaded);
  return {};
}

Error VerifiedConsoleOfficeEngine::Recheck() const {
  for (const auto& lease : files_) {
    if (!lease.file || lease.directories.empty())
      return Reject("OFFICE_NOT_VERIFIED", "No verified LibreOffice engine is held.");
    if (auto error = RecheckProtectedFile(lease.file.get(), lease.directories)) return error;
  }
  return {};
}
}  // namespace document_controls_runtime::office_cli
