#include "document_controls_refusal_pipe_session.h"
#include "document_controls_refusal_session.h"
#include "document_controls_peer_identity.h"

#include <sddl.h>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <utility>

namespace ipc = document_controls::windows_ipc;
using document_controls::Operation;
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
struct Pair {
  ipc::OwnedHandle server, client;
  Pair() {
    static unsigned int number = 0;
    const auto name = L"\\\\.\\pipe\\ABAK.DocumentControls.W5.Test." +
        std::to_wstring(GetCurrentProcessId()) + L"." + std::to_wstring(GetTickCount64()) + L"." + std::to_wstring(++number);
    HANDLE raw = nullptr;
    Check(OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &raw) != FALSE, "fixture process token");
    ipc::OwnedHandle token(raw);
    std::string sid;
    DWORD session = 0;
    Okay(ipc::ReadTokenIdentity(token.get(), &sid, &session), "fixture user SID");
    // Security descriptor belongs only to this test pipe, not the filesystem.
    const auto sddl = "D:P(A;;GA;;;SY)(A;;0x00120083;;;" + sid + ")";
    PSECURITY_DESCRIPTOR descriptor = nullptr;
    Check(ConvertStringSecurityDescriptorToSecurityDescriptorA(sddl.c_str(), SDDL_REVISION_1,
        &descriptor, nullptr) != FALSE, "fixture pipe descriptor");
    SECURITY_ATTRIBUTES security{};
    security.nLength = sizeof(security);
    security.lpSecurityDescriptor = descriptor;
    server.reset(CreateNamedPipeW(name.c_str(), PIPE_ACCESS_DUPLEX | FILE_FLAG_OVERLAPPED |
        FILE_FLAG_FIRST_PIPE_INSTANCE, PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT |
        PIPE_REJECT_REMOTE_CLIENTS, 1, 4096, 4096, 2000, &security));
    LocalFree(descriptor);
    Check(static_cast<bool>(server), "create ephemeral local byte pipe");
    Okay(ipc::OpenLocalPipe(name, &client), "connect fixture client");
    ipc::IoBudget budget(GetTickCount64(), 10000, 2000);
    Okay(ipc::AcceptPipe(server.get(), &budget), "accept fixture connection");
  }
};

// TEST ONLY: exercises real frame I/O and the workflow with modeled identity.
// Production ServeInstalledRefusalSession has no parameter selecting this adapter.
class TransportModel final : public ipc::RefusalSessionChannel {
 public:
  explicit TransportModel(HANDLE pipe) : pipe_(pipe), budget_(GetTickCount64(), 10000, 2000) {}
  ipc::Error AuthenticateAndPin() override { return {}; }
  ipc::Error RecheckPeer() override { return {}; }
  ipc::Error ReadRequest(ipc::Frame* frame) override {
    return ipc::ReadPipeFrame(pipe_, ipc::Direction::kRequest, &budget_, frame);
  }
  ipc::Error WriteRefusal(const ipc::Frame& reply) override {
    return ipc::WritePipeFrame(pipe_, reply, ipc::Direction::kResponse, &budget_);
  }
  ipc::Error WaitForClientClose() override { return ipc::WaitForRefusalClientClose(pipe_, &budget_); }
 private:
  HANDLE pipe_;
  ipc::IoBudget budget_;
};

void TransportRoundTrip(Operation operation) {
  Pair pair;
  ipc::Request request;
  request.operation = operation;
  request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  if (operation != Operation::kVersion) request.input = {3, std::string(64, 'a')};
  ipc::Frame frame;
  Okay(ipc::RequestMetadata(request, &frame.metadata), "synthetic request metadata");
  if (operation != Operation::kVersion) frame.payload = {0, 1, 255};
  ipc::Error server_error;
  std::thread server([&]() {
    auto pipe = std::move(pair.server);
    TransportModel channel(pipe.get());
    server_error = ipc::ProcessOneRefusalSession(channel);
  });
  ipc::IoBudget budget(GetTickCount64(), 10000, 2000);
  const auto write_error = ipc::WritePipeFrame(pair.client.get(), frame, ipc::Direction::kRequest, &budget);
  ipc::Frame reply;
  const auto read_error = write_error ? write_error :
      ipc::ReadPipeFrame(pair.client.get(), ipc::Direction::kResponse, &budget, &reply);
  // A conforming client reads one refusal then closes. Server never flushes
  // indefinitely or accepts another request on this connection.
  pair.client.reset();
  server.join();
  Okay(write_error, "write modeled session request");
  Okay(read_error, "read modeled session refusal");
  Okay(server_error, "modeled session ends at client EOF");
  std::string expected;
  Okay(ipc::UnavailableMetadata(request, &expected), "expected W1 refusal");
  Check(reply.metadata == expected && reply.payload.empty(), "actual transport preserves refusal exactly");
}

void ClosureRules() {
  Pair extra;
  ipc::IoBudget budget(GetTickCount64(), 10000, 2000);
  const std::uint8_t byte = 42;
  Okay(ipc::PipeWriteExact(extra.client.get(), &byte, 1, &budget), "extra request byte");
  Check(ipc::WaitForRefusalClientClose(extra.server.get(), &budget).code == "SESSION_TRAILING_DATA",
        "extra byte refuses instead of processing a second request");
  Pair silent;
  ipc::IoBudget short_budget(GetTickCount64(), 1000, 100);
  Check(ipc::WaitForRefusalClientClose(silent.server.get(), &short_budget).code == "PIPE_TIMEOUT",
        "client that keeps connection open has a finite wait");
  silent.client.reset();
  ipc::IoBudget after_cancel(GetTickCount64(), 10000, 2000);
  Okay(ipc::WaitForRefusalClientClose(silent.server.get(), &after_cancel), "EOF remains readable after cancellation");
  Check(ipc::WaitForRefusalClientClose(extra.server.get(), nullptr).code == "INVALID_ARGUMENTS",
        "missing I/O budget refuses");
}

void NativeRefusals() {
  Check(ipc::ServeInstalledRefusalSession(ipc::OwnedHandle{}).code == "SESSION_INVALID_PIPE",
        "invalid native server handle refuses");
  Pair wrong_end;
  const auto wrong_handle = wrong_end.client.get();
  Check(ipc::ServeInstalledRefusalSession(std::move(wrong_end.client)).code == "SESSION_INVALID_PIPE",
        "client pipe end cannot become a server session");
  DWORD flags = 0;
  Check(!GetHandleInformation(wrong_handle, &flags) && GetLastError() == ERROR_INVALID_HANDLE,
        "wrong-end refusal closes consumed handle");
  Pair unprotected;
  const auto server_handle = unprotected.server.get();
  const auto error = ipc::ServeInstalledRefusalSession(std::move(unprotected.server));
  if (error.code != "PEER_INSTALLATION_REJECTED") std::cerr << error.code << ": " << error.message << '\n';
  Check(error.code == "PEER_INSTALLATION_REJECTED", "native session rejects a correctly named test image in TEMP");
  Check(!GetHandleInformation(server_handle, &flags) && GetLastError() == ERROR_INVALID_HANDLE,
        "installation failure closes consumed server pipe");
  ipc::IoBudget budget(GetTickCount64(), 1000, 100);
  std::uint8_t acknowledgement = 0;
  Check(ipc::PipeReadExact(unprotected.client.get(), &acknowledgement, 1, &budget).code == "PIPE_DISCONNECTED",
        "failed installation sends neither identity acknowledgement nor reply");
}
}  // namespace

int main() {
  for (auto operation : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) TransportRoundTrip(operation);
  ClosureRules(); NativeRefusals();
  std::cout << checks << " W5 Windows checks passed (transport with modeled identity; native installation refused).\n";
  std::cout << "No service, validator, patient document, WFP or filesystem ACL change used.\n";
}
