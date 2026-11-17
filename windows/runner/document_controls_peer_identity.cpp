#include "document_controls_peer_identity.h"
#include "document_controls_installation_security.h"

#include <bcrypt.h>
#include <sddl.h>
#include <winsvc.h>

#include <array>
#include <utility>
#include <vector>

#pragma comment(lib, "advapi32.lib")
#pragma comment(lib, "bcrypt.lib")

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

Error ServiceBinding(const PeerPolicy& policy, DWORD pid) {
  SC_HANDLE manager = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
  if (!manager) return Failure("OpenSCManagerW(peer service)");
  SC_HANDLE service = OpenServiceW(manager, policy.service_name.c_str(), SERVICE_QUERY_STATUS);
  if (!service) {
    const auto error = Failure("OpenServiceW(peer service)");
    CloseServiceHandle(manager);
    return error;
  }
  SERVICE_STATUS_PROCESS status{};
  DWORD received = 0;
  const BOOL queried = QueryServiceStatusEx(service, SC_STATUS_PROCESS_INFO,
      reinterpret_cast<LPBYTE>(&status), sizeof(status), &received);
  const auto query_error = queried ? Error{} : Failure("QueryServiceStatusEx(peer service)");
  CloseServiceHandle(service);
  CloseServiceHandle(manager);
  if (query_error) return query_error;
  if (status.dwCurrentState != SERVICE_RUNNING || status.dwProcessId != pid ||
      status.dwServiceType != SERVICE_WIN32_OWN_PROCESS) {
    return {"PEER_SERVICE_REJECTED", "SCM binding mismatch: pipePid=" + std::to_string(pid) +
        " servicePid=" + std::to_string(status.dwProcessId) +
        " state=" + std::to_string(status.dwCurrentState) +
        " type=" + std::to_string(status.dwServiceType)};
  }
  return {};
}

bool PeerPid(HANDLE pipe, PipePeer peer, DWORD* pid) {
  ULONG value = 0;
  const BOOL okay = peer == PipePeer::kServer ? GetNamedPipeServerProcessId(pipe, &value)
                                           : GetNamedPipeClientProcessId(pipe, &value);
  *pid = value;
  return okay && value != 0;
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
  if (auto error = VerifyProtectedFile(lease->image.get(), lease->facts.image_path,
                                        &lease->directories)) return error;
  lease->facts.installation_protected = true;
  if (policy.role == PeerRole::kService) {
    lease->facts.service_sid_enabled = EnabledSid(token.get(), policy.service_sid);
    if (auto error = ServiceBinding(policy, pid)) return error;
    lease->facts.service_binding_matches = true;
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
  if (!lease.process || !lease.image) {
    return {"PEER_IDENTITY_REJECTED", "Peer process or image handle missing."};
  }
  if (!PeerPid(pipe, peer, &pid)) return Failure("Recheck GetNamedPipeProcessId");
  if (pid != lease.facts.pid) {
    return {"PEER_IDENTITY_REJECTED", "Pipe process changed: expectedPid=" +
        std::to_string(lease.facts.pid) + " currentPid=" + std::to_string(pid)};
  }
  const DWORD waited = WaitForSingleObject(lease.process.get(), 0);
  if (waited == WAIT_FAILED) return Failure("WaitForSingleObject(peer process)");
  if (waited != WAIT_TIMEOUT) {
    return {"PEER_IDENTITY_REJECTED", "Peer process ended: pid=" + std::to_string(pid) +
        " wait=" + std::to_string(waited)};
  }
  if (policy.role == PeerRole::kService) {
    if (auto error = ServiceBinding(policy, pid)) return error;
  }
  if (auto error = RecheckProtectedFile(lease.image.get(), lease.directories)) return error;
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
