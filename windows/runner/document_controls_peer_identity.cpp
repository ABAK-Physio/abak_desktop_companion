#include "document_controls_peer_identity.h"

#include <bcrypt.h>
#include <sddl.h>
#include <wincrypt.h>
#include <wintrust.h>
#include <softpub.h>
#include <winsvc.h>

#include <array>
#include <cstring>
#include <utility>
#include <vector>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "bcrypt.lib")
#pragma comment(lib, "wintrust.lib")

namespace document_controls::windows_ipc {
namespace {
constexpr std::array<std::uint8_t, 8> kHello = {'A','B','A','K','I','P','C','1'};
constexpr std::uint64_t kMaxImageBytes = 64 * 1024 * 1024;

Error Failure(const char* action) {
  return {"PEER_INSPECTION_FAILED", std::string(action) + " (" +
          std::to_string(GetLastError()) + ")"};
}

std::string Hex(const std::array<std::uint8_t, 32>& bytes) {
  const char* digits = "0123456789abcdef";
  std::string result;
  for (auto byte : bytes) { result += digits[byte >> 4]; result += digits[byte & 15]; }
  return result;
}

class Sha256 {
 public:
  ~Sha256() {
    if (hash_) BCryptDestroyHash(hash_);
    if (algorithm_) BCryptCloseAlgorithmProvider(algorithm_, 0);
  }
  bool Start() {
    if (BCryptOpenAlgorithmProvider(&algorithm_, BCRYPT_SHA256_ALGORITHM, nullptr, 0) < 0) return false;
    DWORD size = 0, received = 0;
    if (BCryptGetProperty(algorithm_, BCRYPT_OBJECT_LENGTH,
        reinterpret_cast<PUCHAR>(&size), sizeof(size), &received, 0) < 0 || size > 1024 * 1024) return false;
    buffer_.resize(size);
    return BCryptCreateHash(algorithm_, &hash_, buffer_.data(), size, nullptr, 0, 0) >= 0;
  }
  bool Add(const std::uint8_t* bytes, ULONG size) {
    return BCryptHashData(hash_, const_cast<PUCHAR>(bytes), size, 0) >= 0;
  }
  bool Finish(std::string* digest) {
    std::array<std::uint8_t, 32> bytes{};
    if (BCryptFinishHash(hash_, bytes.data(), static_cast<ULONG>(bytes.size()), 0) < 0) return false;
    *digest = Hex(bytes);
    return true;
  }
 private:
  BCRYPT_ALG_HANDLE algorithm_ = nullptr;
  BCRYPT_HASH_HANDLE hash_ = nullptr;
  std::vector<std::uint8_t> buffer_;
};

bool TokenData(HANDLE token, TOKEN_INFORMATION_CLASS kind, std::vector<std::uint8_t>* bytes) {
  DWORD required = 0;
  GetTokenInformation(token, kind, nullptr, 0, &required);
  if (required == 0 || required > 1024 * 1024) return false;
  bytes->resize(required);
  return GetTokenInformation(token, kind, bytes->data(), required, &required) != FALSE;
}

bool EnabledSid(HANDLE token, const std::string& expected) {
  std::vector<std::uint8_t> bytes;
  if (!TokenData(token, TokenGroups, &bytes)) return false;
  PSID wanted = nullptr;
  if (!ConvertStringSidToSidA(expected.c_str(), &wanted)) return false;
  bool found = false;
  const auto* groups = reinterpret_cast<const TOKEN_GROUPS*>(bytes.data());
  for (DWORD i = 0; i < groups->GroupCount; ++i) {
    const auto& group = groups->Groups[i];
    if ((group.Attributes & SE_GROUP_ENABLED) &&
        !(group.Attributes & SE_GROUP_USE_FOR_DENY_ONLY) && EqualSid(wanted, group.Sid)) {
      found = true;
      break;
    }
  }
  LocalFree(wanted);
  return found;
}

bool ServiceBinding(const PeerPolicy& policy, DWORD pid) {
  SC_HANDLE manager = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
  if (!manager) return false;
  SC_HANDLE service = OpenServiceW(manager, policy.service_name.c_str(), SERVICE_QUERY_STATUS);
  bool matches = false;
  if (service) {
    SERVICE_STATUS_PROCESS status{};
    DWORD received = 0;
    matches = QueryServiceStatusEx(service, SC_STATUS_PROCESS_INFO,
        reinterpret_cast<LPBYTE>(&status), sizeof(status), &received) &&
        status.dwCurrentState == SERVICE_RUNNING && status.dwProcessId == pid &&
        status.dwServiceType == SERVICE_WIN32_OWN_PROCESS;
    CloseServiceHandle(service);
  }
  CloseServiceHandle(manager);
  return matches;
}

bool PeerPid(HANDLE pipe, PipePeer peer, DWORD* pid) {
  ULONG value = 0;
  const BOOL okay = peer == PipePeer::kServer ? GetNamedPipeServerProcessId(pipe, &value)
                                           : GetNamedPipeClientProcessId(pipe, &value);
  *pid = value;
  return okay && value != 0;
}

bool SignedImage(HANDLE image, const std::wstring& path, std::string* signer_digest) {
  signer_digest->clear();
  WINTRUST_FILE_INFO file{};
  file.cbStruct = sizeof(file);
  file.pcwszFilePath = path.c_str();
  file.hFile = image;
  WINTRUST_DATA trust{};
  trust.cbStruct = sizeof(trust);
  trust.dwUIChoice = WTD_UI_NONE;
  trust.fdwRevocationChecks = WTD_REVOKE_NONE;
  trust.dwUnionChoice = WTD_CHOICE_FILE;
  trust.pFile = &file;
  trust.dwStateAction = WTD_STATEACTION_VERIFY;
  // Offline checks only. This is not a claim of fresh online revocation status.
  trust.dwProvFlags = WTD_CACHE_ONLY_URL_RETRIEVAL | WTD_REVOCATION_CHECK_NONE;
  GUID action = WINTRUST_ACTION_GENERIC_VERIFY_V2;
  const auto verified = WinVerifyTrust(nullptr, &action, &trust);
  bool accepted = false;
  if (verified == ERROR_SUCCESS) {
    // These helpers are resolved dynamically as documented by Microsoft.
    const HMODULE module = GetModuleHandleW(L"wintrust.dll");
    using ProviderFn = decltype(&WTHelperProvDataFromStateData);
    using SignerFn = decltype(&WTHelperGetProvSignerFromChain);
    ProviderFn provider_fn = nullptr;
    SignerFn signer_fn = nullptr;
    const auto provider_address = module ? GetProcAddress(module, "WTHelperProvDataFromStateData") : nullptr;
    const auto signer_address = module ? GetProcAddress(module, "WTHelperGetProvSignerFromChain") : nullptr;
    static_assert(sizeof(provider_fn) == sizeof(provider_address));
    static_assert(sizeof(signer_fn) == sizeof(signer_address));
    std::memcpy(&provider_fn, &provider_address, sizeof(provider_fn));
    std::memcpy(&signer_fn, &signer_address, sizeof(signer_fn));
    auto* provider = provider_fn ? provider_fn(trust.hWVTStateData) : nullptr;
    auto* signer = provider && signer_fn ? signer_fn(provider, 0, FALSE, 0) : nullptr;
    if (signer && signer->csCertChain > 0 && signer->pasCertChain &&
        signer->pasCertChain[0].pCert) {
      const auto* certificate = signer->pasCertChain[0].pCert;
      Sha256 hash;
      accepted = hash.Start() && hash.Add(certificate->pbCertEncoded,
          certificate->cbCertEncoded) && hash.Finish(signer_digest);
    }
  }
  trust.dwStateAction = WTD_STATEACTION_CLOSE;
  const auto closed = WinVerifyTrust(nullptr, &action, &trust);
  return accepted && closed == ERROR_SUCCESS;
}

Error InspectPeer(HANDLE pipe, PipePeer peer, const PeerPolicy& policy, PeerLease* lease) {
  DWORD pid = 0;
  if (!PeerPid(pipe, peer, &pid)) return Failure("GetNamedPipeProcessId");
  lease->process.reset(OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION | SYNCHRONIZE,
                                  FALSE, pid));
  if (!lease->process) return Failure("OpenProcess");
  lease->facts.pid = pid;
  lease->facts.process_alive = WaitForSingleObject(lease->process.get(), 0) == WAIT_TIMEOUT;
  HANDLE raw_token = nullptr;
  if (!OpenProcessToken(lease->process.get(), TOKEN_QUERY, &raw_token)) return Failure("OpenProcessToken");
  OwnedHandle token(raw_token);
  DWORD session = 0;
  if (auto error = ReadTokenIdentity(token.get(), &lease->facts.account_sid, &session)) return error;
  lease->facts.session_id = session;
  lease->facts.connection_identity_matches = peer == PipePeer::kServer;
  if (peer == PipePeer::kClient) {
    // Called only after the fixed hello was read from this connection.
    if (!ImpersonateNamedPipeClient(pipe)) return Failure("ImpersonateNamedPipeClient");
    HANDLE raw_connection = nullptr;
    const BOOL opened = OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, TRUE, &raw_connection);
    OwnedHandle connection(raw_connection);
    std::string sid;
    DWORD connection_session = 0;
    Error identity_error;
    if (!opened) identity_error = Failure("OpenThreadToken");
    else identity_error = ReadTokenIdentity(connection.get(), &sid, &connection_session);
    // Continuing a broker thread under another identity is unsafe, even on an
    // error path. Fail fast if the OS cannot restore the original identity.
    if (!RevertToSelf()) RaiseFailFastException(nullptr, nullptr, 0);
    if (identity_error) return identity_error;
    lease->facts.connection_identity_matches = sid == lease->facts.account_sid &&
        connection_session == lease->facts.session_id;
  }
  std::array<wchar_t, 32768> image_path{};
  DWORD path_size = static_cast<DWORD>(image_path.size());
  if (!QueryFullProcessImageNameW(lease->process.get(), 0, image_path.data(), &path_size)) {
    return Failure("QueryFullProcessImageNameW");
  }
  lease->image.reset(CreateFileW(image_path.data(), GENERIC_READ, FILE_SHARE_READ,
      nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_OPEN_REPARSE_POINT, nullptr));
  if (!lease->image) return Failure("Open peer image");
  BY_HANDLE_FILE_INFORMATION info{};
  if (!GetFileInformationByHandle(lease->image.get(), &info) ||
      (info.dwFileAttributes & (FILE_ATTRIBUTE_DIRECTORY | FILE_ATTRIBUTE_REPARSE_POINT))) {
    return {"PEER_IMAGE_REJECTED", "Image is not a regular non-reparse file."};
  }
  path_size = GetFinalPathNameByHandleW(lease->image.get(), image_path.data(),
      static_cast<DWORD>(image_path.size()), FILE_NAME_NORMALIZED | VOLUME_NAME_DOS);
  if (path_size == 0 || path_size >= image_path.size()) return Failure("GetFinalPathNameByHandleW");
  lease->facts.image_path.assign(image_path.data(), path_size);
  if (lease->facts.image_path.compare(0, 4, L"\\\\?\\") == 0) {
    lease->facts.image_path.erase(0, 4);
  }
  if (auto error = HashOpenImage(lease->image.get(), &lease->facts.image_sha256)) return error;
  lease->facts.signature_valid = SignedImage(lease->image.get(),
      lease->facts.image_path, &lease->facts.signer_certificate_sha256);
  if (policy.role == PeerRole::kService) {
    lease->facts.service_sid_enabled = EnabledSid(token.get(), policy.service_sid);
    lease->facts.service_binding_matches = ServiceBinding(policy, pid);
  }
  return {};
}
}  // namespace

Error ReadTokenIdentity(HANDLE token, std::string* sid, DWORD* session) {
  if (!sid || !session) return {"INVALID_ARGUMENTS", "Missing token identity output."};
  sid->clear();
  *session = 0;
  std::vector<std::uint8_t> user;
  if (!TokenData(token, TokenUser, &user)) return Failure("GetTokenInformation(TokenUser)");
  LPSTR text = nullptr;
  if (!ConvertSidToStringSidA(reinterpret_cast<const TOKEN_USER*>(user.data())->User.Sid,
                             &text)) return Failure("ConvertSidToStringSidA");
  sid->assign(text);
  LocalFree(text);
  DWORD received = 0;
  if (!GetTokenInformation(token, TokenSessionId, session, sizeof(*session), &received)) {
    return Failure("GetTokenInformation(TokenSessionId)");
  }
  return {};
}

Error HashOpenImage(HANDLE file, std::string* digest) {
  if (!digest) return {"INVALID_ARGUMENTS", "Missing image digest output."};
  digest->clear();
  LARGE_INTEGER size{}, beginning{};
  if (!GetFileSizeEx(file, &size) || size.QuadPart <= 0 ||
      static_cast<std::uint64_t>(size.QuadPart) > kMaxImageBytes ||
      !SetFilePointerEx(file, beginning, nullptr, FILE_BEGIN)) {
    return {"PEER_IMAGE_REJECTED", "Image size or file position is invalid."};
  }
  Sha256 hash;
  if (!hash.Start()) return {"PEER_HASH_FAILED", "SHA-256 initialization failed."};
  std::array<std::uint8_t, 65536> buffer{};
  std::uint64_t total = 0;
  DWORD count = 0;
  for (;;) {
    if (!ReadFile(file, buffer.data(), static_cast<DWORD>(buffer.size()), &count, nullptr)) {
      return Failure("Read image");
    }
    if (!count) break;
    total += count;
    if (total > kMaxImageBytes || !hash.Add(buffer.data(), count)) {
      return {"PEER_HASH_FAILED", "Image hashing failed."};
    }
  }
  if (total != static_cast<std::uint64_t>(size.QuadPart) || !hash.Finish(digest)) {
    return {"PEER_HASH_FAILED", "Incomplete image hashing."};
  }
  if (!SetFilePointerEx(file, beginning, nullptr, FILE_BEGIN)) return Failure("Rewind image");
  return {};
}

Error RecheckPipePeer(HANDLE pipe, PipePeer peer, const PeerPolicy& policy,
                      const PeerLease& lease) {
  DWORD pid = 0;
  if (!lease.process || !lease.image || !PeerPid(pipe, peer, &pid) ||
      pid != lease.facts.pid || WaitForSingleObject(lease.process.get(), 0) != WAIT_TIMEOUT ||
      (policy.role == PeerRole::kService && !ServiceBinding(policy, pid))) {
    return {"PEER_IDENTITY_REJECTED", "Peer identity changed or process exited."};
  }
  return AuthorizePeer(policy, lease.facts);
}

Error AuthenticatePipePeer(HANDLE pipe, PipePeer peer, const PeerPolicy& policy,
                           IoBudget* budget, PeerLease* lease) {
  if (!lease || !budget) return {"INVALID_ARGUMENTS", "Missing authentication output."};
  *lease = PeerLease{};
  if (peer != PipePeer::kServer && peer != PipePeer::kClient) {
    return {"INVALID_ARGUMENTS", "Invalid pipe peer role."};
  }
  if (auto error = ValidatePeerPolicy(policy)) return error;
  if ((peer == PipePeer::kServer && policy.role != PeerRole::kService) ||
      (peer == PipePeer::kClient && policy.role != PeerRole::kCompanion)) {
    return {"PEER_POLICY_UNCONFIGURED", "Peer role does not match the pipe end."};
  }
  PeerLease observed;
  std::array<std::uint8_t, kHello.size()> hello{};
  if (peer == PipePeer::kClient) {
    if (auto error = PipeReadExact(pipe, hello.data(), hello.size(), budget)) return error;
    if (hello != kHello) return {"PEER_HANDSHAKE_FAILED", "Invalid client preamble."};
  }
  if (auto error = InspectPeer(pipe, peer, policy, &observed)) return error;
  if (auto error = RecheckPipePeer(pipe, peer, policy, observed)) return error;
  if (budget->Remaining(GetTickCount64()) == 0) return {"PIPE_TIMEOUT", "Authentication deadline expired."};
  if (auto error = PipeWriteExact(pipe, kHello.data(), kHello.size(), budget)) return error;
  if (peer == PipePeer::kServer) {
    if (auto error = PipeReadExact(pipe, hello.data(), hello.size(), budget)) return error;
    if (hello != kHello) return {"PEER_HANDSHAKE_FAILED", "Invalid service acknowledgement."};
  }
  if (auto error = RecheckPipePeer(pipe, peer, policy, observed)) return error;
  *lease = std::move(observed);
  return {};
}

}  // namespace document_controls::windows_ipc
