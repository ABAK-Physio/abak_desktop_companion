#include "document_controls_refusal_pipe_session.h"
#include "document_controls_refusal_session.h"
#include "document_controls_installation_loader.h"
#include "document_controls_peer_identity.h"

namespace document_controls::windows_ipc {
namespace {
Error CheckServerEnd(HANDLE pipe) {
  DWORD flags = 0;
  ULONG pid = 0;
  if (!GetNamedPipeInfo(pipe, &flags, nullptr, nullptr, nullptr) ||
      !(flags & PIPE_SERVER_END) || (flags & PIPE_TYPE_MESSAGE) ||
      !GetNamedPipeServerProcessId(pipe, &pid) || pid != GetCurrentProcessId()) {
    return {"SESSION_INVALID_PIPE", "An owned byte-mode server pipe is required."};
  }
  return {};
}

class WindowsRefusalChannel final : public RefusalSessionChannel {
 public:
  WindowsRefusalChannel(HANDLE pipe, const InstalledControls& installation, IoBudget* budget)
      : pipe_(pipe), installation_(installation), budget_(budget) {}

  Error AuthenticateAndPin() override {
    if (auto error = Deadline()) return error;
    if (auto error = installation_.CompanionPolicyForPipe(pipe_, &policy_)) return error;
    return AuthenticatePipePeer(pipe_, PipePeer::kClient, policy_, budget_, &peer_);
  }
  Error RecheckPeer() override {
    if (auto error = Deadline()) return error;
    if (auto error = installation_.Recheck()) return error;
    return RecheckPipePeer(pipe_, PipePeer::kClient, policy_, peer_);
  }
  Error ReadRequest(Frame* request) override {
    return ReadPipeFrame(pipe_, Direction::kRequest, budget_, request);
  }
  Error WriteRefusal(const Frame& refusal) override {
    return WritePipeFrame(pipe_, refusal, Direction::kResponse, budget_);
  }
  Error WaitForClientClose() override { return WaitForRefusalClientClose(pipe_, budget_); }
 private:
  Error Deadline() const {
    return budget_->Remaining(GetTickCount64()) ? Error{} :
        Error{"PIPE_TIMEOUT", "Refusal session deadline expired."};
  }
  HANDLE pipe_;
  const InstalledControls& installation_;
  IoBudget* budget_;
  PeerPolicy policy_;
  PeerLease peer_;
};
}  // namespace

Error WaitForRefusalClientClose(HANDLE server_pipe, IoBudget* budget) {
  std::uint8_t extra = 0;
  const auto error = PipeReadExact(server_pipe, &extra, 1, budget);
  if (error.code == "PIPE_DISCONNECTED") return {};
  if (error) return error;
  return {"SESSION_TRAILING_DATA", "Only one request is allowed before client closure."};
}

Error ServeInstalledRefusalSession(OwnedHandle server_pipe) {
  IoBudget budget(GetTickCount64(), kRefusalSessionTotalMs, kIdleTimeoutMs);
  if (auto error = CheckServerEnd(server_pipe.get())) return error;
  InstalledControls installation;
  if (auto error = LoadInstalledControls(&installation)) return error;
  WindowsRefusalChannel channel(server_pipe.get(), installation, &budget);
  return ProcessOneRefusalSession(channel);
}

}  // namespace document_controls::windows_ipc
