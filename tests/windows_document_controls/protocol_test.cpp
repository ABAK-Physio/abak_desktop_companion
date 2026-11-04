#include "document_controls_protocol.h"
#include "document_controls_pipe_client.h"
#ifdef _WIN32
#include "document_controls_executor.h"
#endif

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <random>
#include <string>
#include <vector>

namespace ipc = document_controls::windows_ipc;
using document_controls::Operation;

namespace {
int checks = 0;
void Check(bool condition, const char* message) {
  ++checks;
  if (!condition) {
    std::cerr << "FAILED: " << message << '\n';
    std::exit(1);
  }
}
ipc::Request Version() {
  ipc::Request request;
  request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  return request;
}
void ExpectError(const ipc::Request& request, const std::string& expected) {
  Check(ipc::ValidateRequest(request).code == expected, "request rejection");
}
}  // namespace

int main(int argc, char** argv) {
  auto request = Version();
  Check(!ipc::ValidateRequest(request), "valid version request");
  request.protocol = 2;
  ExpectError(request, "PROTOCOL_MISMATCH");
  request = Version();
  request.operation = static_cast<Operation>(99);
  ExpectError(request, "INVALID_OPERATION");
  request = Version();
  for (const auto* id : {"", "../document", "AAAAAAAA-bbbb-cccc-dddd-eeeeeeeeeeee",
                         "aaaaaaaa_bbbb-cccc-dddd-eeeeeeeeeeee"}) {
    request.request_id = id;
    ExpectError(request, "INVALID_REQUEST_ID");
  }
  request = Version();
  for (auto timeout : {0u, 10001u, 0xffffffffu}) {
    request.timeout_ms = timeout;
    ExpectError(request, "INVALID_TIMEOUT");
  }
  request = Version();
  request.input.size = 1;
  ExpectError(request, "INVALID_INPUT");
  request = Version();
  request.input.sha256 = std::string(64, 'a');
  ExpectError(request, "INVALID_INPUT");
  for (auto operation : {Operation::kPdfa, Operation::kCda}) {
    request = Version();
    request.operation = operation;
    request.timeout_ms = 240000;
    ExpectError(request, "INVALID_INPUT");
    request.input = {1, std::string(64, 'a')};
    Check(!ipc::ValidateRequest(request), "valid document descriptor");
    request.input.size = ipc::kMaxInputBytes;
    Check(!ipc::ValidateRequest(request), "maximum document size");
    request.input.size++;
    ExpectError(request, "INVALID_INPUT");
    request.input = {1, std::string(64, 'A')};
    ExpectError(request, "INVALID_INPUT");
    request.input.sha256 = std::string(63, 'a');
    ExpectError(request, "INVALID_INPUT");
    request.input.sha256 = std::string(64, 'a');
    request.timeout_ms = 240001;
    ExpectError(request, "INVALID_TIMEOUT");
  }
  request = Version();
  std::string metadata;
  Check(!ipc::RequestMetadata(request, &metadata), "request serialization");
  Check(metadata ==
        "{\"protocol\":1,\"contract\":\"ABAK-WINDOWS-CONTROLS-1\","
        "\"operation\":\"version\",\"requestId\":\"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee\","
        "\"timeoutMs\":10000,\"input\":null}", "request golden JSON");
  Check(ipc::RequestMetadata(request, nullptr).code == "INVALID_ARGUMENTS",
        "null serialization output");
  ipc::Frame frame{metadata, {0, 1, 255, 0}};
  std::vector<std::uint8_t> bytes;
  Check(!ipc::EncodeFrame(frame, ipc::Direction::kRequest, &bytes), "encode");
  Check(bytes[0] == metadata.size() && bytes[4] == 4 && bytes[11] == 0,
        "little endian prefix");
  ipc::Frame decoded;
  Check(!ipc::DecodeFrame(bytes, ipc::Direction::kRequest, &decoded), "decode");
  Check(decoded.metadata == metadata && decoded.payload == frame.payload,
        "binary payload is preserved including NUL");
  for (std::size_t cut = 0; cut < bytes.size(); ++cut) {
    const std::vector<std::uint8_t> partial(bytes.begin(), bytes.begin() + cut);
    decoded = {"stale", {1}};
    Check(static_cast<bool>(ipc::DecodeFrame(partial, ipc::Direction::kResponse,
                                           &decoded)), "every truncation rejected");
    Check(decoded.metadata.empty() && decoded.payload.empty(), "no partial output");
  }
  bytes.push_back(1);
  Check(static_cast<bool>(ipc::DecodeFrame(bytes, ipc::Direction::kResponse,
                                         &decoded)), "trailing bytes rejected");
  std::vector<std::uint8_t> prefix(12, 255);
  ipc::FrameSizes sizes;
  Check(static_cast<bool>(ipc::DecodePrefix(prefix.data(), prefix.size(),
                                           ipc::Direction::kRequest, &sizes)),
        "oversized lengths rejected before allocation");
  prefix.assign(12, 0);
  Check(ipc::DecodePrefix(prefix.data(), 12, ipc::Direction::kResponse, &sizes).code
        == "INVALID_FRAME_SIZE", "empty metadata rejected");
  prefix[0] = 1;
  const auto oversized = ipc::kMaxOutputBytes + 1;
  for (std::size_t i = 0; i < 8; ++i) {
    prefix[4 + i] = static_cast<std::uint8_t>(oversized >> (8 * i));
  }
  Check(ipc::DecodePrefix(prefix.data(), 12, ipc::Direction::kResponse, &sizes).code
        == "PAYLOAD_LIMIT_EXCEEDED", "output limit");
  Check(!ipc::DecodePrefix(prefix.data(), 12, ipc::Direction::kRequest, &sizes),
        "input and output limits differ");
  for (const std::string& invalid : {
           std::string("a\0b", 3), std::string("\xc0\xaf", 2),
           std::string("\xed\xa0\x80", 3), std::string("\xf4\x90\x80\x80", 4),
           std::string("\xe2\x82", 2), std::string("\x80", 1)}) {
    Check(!ipc::ValidUtf8(invalid), "strict UTF-8 rejection");
    Check(static_cast<bool>(ipc::EncodeFrame({invalid, {}},
          ipc::Direction::kResponse, &bytes)), "invalid UTF-8 not serialized");
  }
  Check(ipc::ValidUtf8("R\xc3\xa9ponse \xf0\x9f\x93\x84"), "valid Unicode");
  frame = {std::string(ipc::kMaxMetadataBytes, 'x'), {}};
  Check(!ipc::EncodeFrame(frame, ipc::Direction::kResponse, &bytes), "header at limit");
  frame.metadata.push_back('x');
  Check(static_cast<bool>(ipc::EncodeFrame(frame, ipc::Direction::kResponse,
                                         &bytes)), "oversized metadata rejected");

  // A deterministic hostile-input corpus also runs under sanitizers on Linux.
  std::mt19937 random(1937);
  for (int n = 0; n < 10000; ++n) {
    bytes.resize(random() % 256);
    for (auto& byte : bytes) byte = static_cast<std::uint8_t>(random());
    const auto error = ipc::DecodeFrame(bytes, ipc::Direction::kResponse, &decoded);
    Check(static_cast<bool>(error), "hostile frame rejected");
    Check(decoded.metadata.empty() && decoded.payload.empty(), "hostile frame clears output");
  }

  // Public production client always refuses; no connector or opt-in exists.
  for (auto operation : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) {
    request = Version();
    request.operation = operation;
    if (operation != Operation::kVersion) request.input = {1, std::string(64, 'a')};
    decoded = {"pretend-success", {1}};
    Check(ipc::Exchange(request, &decoded).code == ipc::kIsolationUnavailable,
          "W1 client cannot execute");
    Check(decoded.metadata.empty() && decoded.payload.empty(), "no forged result");
  }
#ifdef _WIN32
  for (const auto* name : {"pdfa", "version", "cda"}) {
    document_controls::ExecutionRequest native;
    native.operation = name;
    const auto result = document_controls::ExecuteSecurely(native);
    Check(!result.executed && result.exit_code == -1 &&
          result.error_code == ipc::kIsolationUnavailable,
          "real native executor remains unavailable");
    Operation operation;
    Check(document_controls::ParseOperation(name, &operation), "existing operation parser");
    const auto launch = document_controls::Launch(operation);
    Check(launch.status == document_controls::LaunchStatus::kUnavailable &&
          launch.error_code == ipc::kIsolationUnavailable, "real launcher refuses");
  }
  document_controls::ExecutionRequest invalid;
  invalid.operation = "cmd";
  Check(document_controls::ExecuteSecurely(invalid).error_code == "INVALID_OPERATION",
        "executor denies arbitrary commands");
  Check(document_controls::Launch(static_cast<Operation>(99)).status ==
        document_controls::LaunchStatus::kInvalidOperation, "launcher denies invalid enum");
#endif
  request = Version();
  Check(!ipc::UnavailableMetadata(request, &metadata), "refusal serialization");
  Check(!ipc::EncodeFrame({metadata, {}}, ipc::Direction::kResponse, &bytes),
        "native refusal frame");
  if (argc == 2) {
    std::ofstream fixture(argv[1], std::ios::binary);
    fixture.write(reinterpret_cast<const char*>(bytes.data()),
                  static_cast<std::streamsize>(bytes.size()));
    Check(fixture.good(), "write cross-language fixture");
  }
  std::cout << checks << " native checks passed." << std::endl;
#ifndef _WIN32
  std::cout << "Windows executor/launcher checks require Windows and were not run."
            << std::endl;
#endif
}
