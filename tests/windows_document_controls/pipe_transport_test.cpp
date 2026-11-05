#include "document_controls_peer_identity.h"

#include <sddl.h>
#include <algorithm>
#include <array>
#include <cstdlib>
#include <iostream>
#include <thread>

namespace ipc = document_controls::windows_ipc;
namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << " (Win32 " << GetLastError() << ")\n"; std::exit(1); }
}
void Okay(const ipc::Error& error, const char* message) {
  if (error) std::cerr << error.code << ": " << error.message << '\n';
  Check(!error, message);
}

ipc::PeerPolicy TestClientPolicy() {
  HANDLE raw = nullptr;
  Check(OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &raw) != FALSE, "test token");
  ipc::OwnedHandle token(raw);
  ipc::PeerPolicy policy;
  policy.role = ipc::PeerRole::kCompanion;
  policy.trusted_installation = true;  // Synthetic pin only: TEMP is not a trusted installation.
  DWORD session = 0;
  Okay(ipc::ReadTokenIdentity(token.get(), &policy.account_sid, &session), "current token identity");
  policy.session_id = session;
  wchar_t path[32768]{};
  Check(GetModuleFileNameW(nullptr, path, 32768) != 0, "test executable path");
  policy.image_path = path;
  ipc::OwnedHandle image(CreateFileW(path, GENERIC_READ, FILE_SHARE_READ,
      nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr));
  Check(static_cast<bool>(image), "open test executable");
  Okay(ipc::HashOpenImage(image.get(), &policy.image_sha256), "pin test executable hash");
  const DWORD length = GetFinalPathNameByHandleW(image.get(), path, 32768,
      FILE_NAME_NORMALIZED | VOLUME_NAME_DOS);
  Check(length > 0 && length < 32768, "canonical test executable path");
  policy.image_path.assign(path, length);
  if (policy.image_path.compare(0, 4, L"\\\\?\\") == 0) policy.image_path.erase(0, 4);
  return policy;
}

struct Pair {
  ipc::OwnedHandle server;
  ipc::OwnedHandle client;
  std::wstring name;
  Pair() {
    static unsigned int number = 0;
    name = L"\\\\.\\pipe\\ABAK.DocumentControls.W2.Test." +
        std::to_wstring(GetCurrentProcessId()) + L"." +
        std::to_wstring(GetTickCount64()) + L"." + std::to_wstring(++number);
    const auto policy = TestClientPolicy();
    // This descriptor belongs only to this ephemeral, same-process test pipe.
    // It is not a production service ACL and grants no new filesystem rights.
    const std::string sddl = "D:P(A;;GA;;;SY)(A;;GRGW;;;" + policy.account_sid + ")";
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    Check(ConvertStringSecurityDescriptorToSecurityDescriptorA(sddl.c_str(),
        SDDL_REVISION_1, &descriptor, nullptr) != FALSE, "test pipe descriptor");
    SECURITY_ATTRIBUTES security{};
    security.nLength = sizeof(security);
    security.lpSecurityDescriptor = descriptor;
    server.reset(CreateNamedPipeW(name.c_str(), PIPE_ACCESS_DUPLEX |
        FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT | PIPE_REJECT_REMOTE_CLIENTS,
        1, 4096, 4096, 2000, &security));
    LocalFree(descriptor);
    Check(static_cast<bool>(server), "create local test pipe");
    Okay(ipc::OpenLocalPipe(name, &client), "connect local test client");
    ipc::IoBudget budget(GetTickCount64(), 5000, 1000);
    Okay(ipc::AcceptPipe(server.get(), &budget), "accept existing client race");
    ULONG pid = 0;
    Check(GetNamedPipeServerProcessId(client.get(), &pid) && pid == GetCurrentProcessId(),
          "server PID comes from Windows");
    Check(GetNamedPipeClientProcessId(server.get(), &pid) && pid == GetCurrentProcessId(),
          "client PID comes from Windows");
  }
};

ipc::Request Version() {
  ipc::Request request;
  request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  return request;
}

void RoundTrip() {
  Pair pair;
  std::string request, refusal;
  Okay(ipc::RequestMetadata(Version(), &request), "request metadata");
  Okay(ipc::UnavailableMetadata(Version(), &refusal), "refusal metadata");
  ipc::IoBudget client_budget(GetTickCount64(), 5000, 1000);
  ipc::IoBudget server_budget(GetTickCount64(), 5000, 1000);
  Okay(ipc::WritePipeFrame(pair.client.get(), {request, {}}, ipc::Direction::kRequest,
                           &client_budget), "write request");
  ipc::Frame received;
  Okay(ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kRequest,
                          &server_budget, &received), "read request");
  Check(received.metadata == request && received.payload.empty(), "request is unchanged");
  // This ordinary test process only returns the W1 refusal. It executes nothing.
  Okay(ipc::WritePipeFrame(pair.server.get(), {refusal, {}}, ipc::Direction::kResponse,
                           &server_budget), "write refusal");
  Okay(ipc::ReadPipeFrame(pair.client.get(), ipc::Direction::kResponse,
                          &client_budget, &received), "read refusal");
  Check(received.metadata == refusal && received.payload.empty(), "refusal is unchanged");
}

void Fragmentation() {
  Pair pair;
  ipc::Frame sent{"{\"transportTest\":true}", std::vector<std::uint8_t>(32768)};
  for (std::size_t i = 0; i < sent.payload.size(); ++i) sent.payload[i] = static_cast<std::uint8_t>(i);
  std::vector<std::uint8_t> bytes;
  Okay(ipc::EncodeFrame(sent, ipc::Direction::kRequest, &bytes), "fragmented frame encoding");
  ipc::Error writer_error;
  std::thread writer([&]() {
    ipc::IoBudget budget(GetTickCount64(), 10000, 2000);
    for (std::size_t offset = 0; offset < bytes.size();) {
      const auto count = (std::min)(std::size_t{37}, bytes.size() - offset);
      writer_error = ipc::PipeWriteExact(pair.client.get(), bytes.data() + offset, count, &budget);
      if (writer_error) return;
      offset += count;
    }
  });
  ipc::Frame received;
  ipc::IoBudget budget(GetTickCount64(), 10000, 2000);
  const auto error = ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kRequest, &budget, &received);
  writer.join();
  Okay(writer_error, "fragment writer");
  Okay(error, "fragment reader");
  Check(received.metadata == sent.metadata && received.payload == sent.payload,
        "partial reads preserve all bytes including NUL");
}

void TimeoutsAndDisconnect() {
  Pair pair;
  ipc::Frame received{"stale", {1}};
  const auto start = GetTickCount64();
  ipc::IoBudget short_budget(start, 1000, 100);
  Check(ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kResponse,
      &short_budget, &received).code == "PIPE_TIMEOUT", "silent peer times out");
  Check(received.metadata.empty() && received.payload.empty(), "timeout exposes no partial frame");
  Check(GetTickCount64() - start < 5000, "cancellation returns promptly");
  // Reuse after cancellation: the canceled read must not consume this new frame.
  ipc::IoBudget budget(GetTickCount64(), 5000, 1000);
  Okay(ipc::WritePipeFrame(pair.client.get(), {"{}", {}}, ipc::Direction::kResponse,
                           &budget), "write after cancellation");
  Okay(ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kResponse,
                          &budget, &received), "read after cancellation");
  Check(received.metadata == "{}", "canceled I/O was fully completed");
  pair.client.reset();
  Check(ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kResponse,
      &budget, &received).code == "PIPE_DISCONNECTED", "closed peer is reported");
}

void HostileFrame() {
  Pair pair;
  std::array<std::uint8_t, 12> prefix{};
  prefix[0] = 1;
  const std::uint64_t too_big = ipc::kMaxOutputBytes + 1;
  for (std::size_t i = 0; i < 8; ++i) prefix[4 + i] = static_cast<std::uint8_t>(too_big >> (8 * i));
  ipc::IoBudget budget(GetTickCount64(), 5000, 1000);
  Okay(ipc::PipeWriteExact(pair.client.get(), prefix.data(), prefix.size(), &budget), "hostile prefix");
  ipc::Frame frame{"stale", {1}};
  Check(ipc::ReadPipeFrame(pair.server.get(), ipc::Direction::kResponse, &budget,
      &frame).code == "PAYLOAD_LIMIT_EXCEEDED", "huge body refused before allocation");
  Check(frame.metadata.empty() && frame.payload.empty(), "hostile frame has no partial result");
}

void IdentityRefusals() {
  ipc::PeerLease lease;
  ipc::IoBudget budget(GetTickCount64(), 10000, 10000);
  Check(ipc::AuthenticatePipePeer(INVALID_HANDLE_VALUE, ipc::PipePeer::kServer,
      {}, &budget, &lease).code == "PEER_POLICY_UNCONFIGURED", "no release policy means no IPC");
  Pair pair;
  auto policy = TestClientPolicy();
  // The hello is only an identity-handshake preamble, not an operation.
  const std::array<std::uint8_t, 8> hello = {'A','B','A','K','I','P','C','1'};
  Okay(ipc::PipeWriteExact(pair.client.get(), hello.data(), hello.size(), &budget), "test hello");
  const auto error = ipc::AuthenticatePipePeer(pair.server.get(), ipc::PipePeer::kClient,
                                             policy, &budget, &lease);
  if (error.code != "PEER_INSTALLATION_REJECTED") std::cerr << error.code << ": " << error.message << '\n';
  Check(error.code == "PEER_INSTALLATION_REJECTED" && !lease.process && !lease.image &&
        lease.directories.empty(),
        "test binary in TEMP refuses despite an exact hash and matching account");
  std::array<std::uint8_t, 8> acknowledgement{};
  ipc::IoBudget no_ack_budget(GetTickCount64(), 1000, 100);
  Check(ipc::PipeReadExact(pair.client.get(), acknowledgement.data(), acknowledgement.size(),
      &no_ack_budget).code == "PIPE_TIMEOUT", "rejected peer receives no authorization acknowledgement");
  HANDLE token = nullptr;
  const BOOL impersonated = OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, TRUE, &token);
  const auto last = GetLastError();
  if (token) CloseHandle(token);
  Check(!impersonated && last == ERROR_NO_TOKEN, "thread identity was restored after rejection");

  Pair wrong;
  const std::array<std::uint8_t, 8> invalid{};
  Okay(ipc::PipeWriteExact(wrong.client.get(), invalid.data(), invalid.size(), &budget), "invalid hello");
  Check(ipc::AuthenticatePipePeer(wrong.server.get(), ipc::PipePeer::kClient,
      policy, &budget, &lease).code == "PEER_HANDSHAKE_FAILED", "invalid preamble refuses");
}

void LocalNamesAndInstances() {
  ipc::OwnedHandle handle;
  Check(ipc::OpenLocalPipe(L"\\\\remote\\pipe\\ABAK.DocumentControls.v1", &handle).code ==
        "INVALID_PIPE_NAME", "UNC remote pipe refused before opening");
  Check(ipc::OpenLocalPipe(L"\\\\.\\pipe\\unrelated", &handle).code ==
        "INVALID_PIPE_NAME", "unrelated pipe refused");
  Pair pair;
  ipc::OwnedHandle duplicate(CreateNamedPipeW(pair.name.c_str(), PIPE_ACCESS_DUPLEX |
      FILE_FLAG_FIRST_PIPE_INSTANCE | FILE_FLAG_OVERLAPPED,
      PIPE_TYPE_BYTE | PIPE_REJECT_REMOTE_CLIENTS, 1, 4096, 4096, 0, nullptr));
  Check(!duplicate && GetLastError() == ERROR_ACCESS_DENIED, "first instance collision refuses");
  Check(ipc::OpenLocalPipe(pair.name, &handle).code == "PIPE_BUSY", "busy pipe has a bounded wait");
}

void Handles() {
  DWORD before = 0, after = 0;
  Check(GetProcessHandleCount(GetCurrentProcess(), &before) != FALSE, "handle count before");
  for (int i = 0; i < 20; ++i) { Pair pair; }
  Check(GetProcessHandleCount(GetCurrentProcess(), &after) != FALSE, "handle count after");
  // Allow a small one-off runtime fluctuation, but not a handle per connection.
  Check(after <= before + 2, "no per-connection handle growth");
}
}

int main() {
  RoundTrip();
  Fragmentation();
  TimeoutsAndDisconnect();
  HostileFrame();
  IdentityRefusals();
  LocalNamesAndInstances();
  Handles();
  std::cout << checks << " W2 Windows pipe checks passed.\n";
  std::cout << "No service, Java process, patient document, or WFP rule used.\n";
}
