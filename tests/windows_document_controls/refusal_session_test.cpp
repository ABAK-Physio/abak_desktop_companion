#include "document_controls_refusal_session.h"
#include "document_controls_pipe_client.h"

#include <cstdlib>
#include <iostream>

namespace ipc = document_controls::windows_ipc;
using document_controls::Operation;
namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << '\n'; std::exit(1); }
}
ipc::Frame Request(Operation operation) {
  ipc::Request descriptor;
  descriptor.operation = operation;
  descriptor.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  if (operation != Operation::kVersion) descriptor.input = {3, std::string(64, 'a')};
  ipc::Frame frame;
  Check(!ipc::RequestMetadata(descriptor, &frame.metadata), "synthetic request metadata");
  if (operation != Operation::kVersion) frame.payload = {0, 1, 255};
  return frame;
}
class ModelChannel final : public ipc::RefusalSessionChannel {
  using Error = ipc::Error;
 public:
  ipc::Frame request = Request(Operation::kVersion);
  ipc::Frame written;
  std::vector<std::string> events;
  std::string fail_at;
  std::string failure_code = "SYNTHETIC_FAILURE";
  Error AuthenticateAndPin() override { return Event("authenticate"); }
  Error RecheckPeer() override { return Event(++rechecks_ == 1 ? "before_read" : "before_write"); }
  Error ReadRequest(ipc::Frame* output) override {
    *output = request;  // A failed read may leave partial data in this test model.
    return Event("read");
  }
  Error WriteRefusal(const ipc::Frame& response) override {
    written = response;
    return Event("write");
  }
  Error WaitForClientClose() override { return Event("close"); }
 private:
  Error Event(const char* step) {
    events.emplace_back(step);
    return fail_at == step ? Error{failure_code, "Synthetic stage failure."} : Error{};
  }
  int rechecks_ = 0;
};

void SuccessfulModels() {
  for (auto operation : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) {
    ModelChannel channel;
    channel.request = Request(operation);
    Check(!ipc::ProcessOneRefusalSession(channel), "model completes a refusal, never an execution");
    Check(channel.events == std::vector<std::string>{"authenticate", "before_read", "read", "before_write", "write", "close"},
          "identity checks precede reading and replying");
    ipc::Frame expected;
    Check(!ipc::BuildRefusalReply(channel.request, &expected), "expected W3 refusal");
    Check(channel.written.metadata == expected.metadata && channel.written.payload.empty(),
          "only unchanged W1 refusal is written");
    for (const auto* field : {"WINDOWS_ISOLATION_UNAVAILABLE", "\"executed\":false", "\"qualified\":false",
                              "\"serviceIdentityVerified\":false", "\"pid\":0", "\"files\":[]"}) {
      Check(channel.written.metadata.find(field) != std::string::npos, "no positive execution or isolation claim");
    }
  }
}
void FailureOrdering() {
  const std::vector<std::string> order{"authenticate", "before_read", "read", "before_write", "write", "close"};
  for (std::size_t index = 0; index < order.size(); ++index) {
    ModelChannel channel;
    channel.fail_at = order[index];
    channel.failure_code = index == 2 || index == 5 ? "PIPE_TIMEOUT" : "PEER_IDENTITY_REJECTED";
    Check(ipc::ProcessOneRefusalSession(channel).code == channel.failure_code, "stage error is preserved");
    const std::vector<std::string> prefix(order.begin(), order.begin() + static_cast<std::ptrdiff_t>(index + 1));
    Check(channel.events == prefix, "no later stage runs after failure");
    if (index < 4) Check(channel.written.metadata.empty() && channel.written.payload.empty(),
                         "authentication, read or recheck failure sends no response");
  }
  for (const auto& bad : {ipc::Frame{"{}", {}}, ipc::Frame{"not-json", {}},
                         ipc::Frame{Request(Operation::kVersion).metadata, {1}},
                         ipc::Frame{Request(Operation::kPdfa).metadata, {1}}}) {
    ModelChannel channel;
    channel.request = bad;
    Check(static_cast<bool>(ipc::ProcessOneRefusalSession(channel)), "malformed request stops before response");
    Check(channel.events == std::vector<std::string>{"authenticate", "before_read", "read"},
          "invalid schema or length does not reach write or close wait");
    Check(channel.written.metadata.empty(), "no previous or fabricated response is sent");
  }
  Check(ipc::ServiceStartupGate().code == "SERVICE_INSTALLATION_UNQUALIFIED", "SCM gate stays closed");
  for (auto operation : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) {
    ipc::Request request;
    request.operation = operation;
    request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
    if (operation != Operation::kVersion) request.input = {1, std::string(64, 'a')};
    ipc::Frame reply{"forged", {1}};
    Check(ipc::Exchange(request, &reply).code == ipc::kIsolationUnavailable &&
          reply.metadata.empty() && reply.payload.empty(), "workflow does not open production execution");
  }
}
}  // namespace

int main() {
  SuccessfulModels(); FailureOrdering();
  std::cout << checks << " W5 session-order checks passed (synthetic authentication, no native trust claim).\n";
}
