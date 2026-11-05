#include "document_controls_service_core.h"
#include "document_controls_pipe_client.h"

#include <algorithm>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <random>

namespace ipc = document_controls::windows_ipc;
using document_controls::Operation;

namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << '\n'; std::exit(1); }
}
void Okay(const ipc::Error& error, const char* message) {
  if (error) std::cerr << error.code << ": " << error.message << '\n';
  Check(!error, message);
}
ipc::Request Request(Operation operation = Operation::kVersion) {
  ipc::Request result;
  result.operation = operation;
  result.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
  if (operation != Operation::kVersion) {
    result.timeout_ms = 240000;
    // Synthetic bytes only. W3 never checks the document or claims this digest.
    result.input = {3, std::string(64, 'a')};
  }
  return result;
}
std::string Metadata(Operation operation = Operation::kVersion) {
  std::string result;
  Okay(ipc::RequestMetadata(Request(operation), &result), "serialize W1 request");
  return result;
}
std::string Replace(std::string source, const std::string& old_text,
                    const std::string& new_text) {
  const auto position = source.find(old_text);
  Check(position != std::string::npos, "mutation target exists");
  source.replace(position, old_text.size(), new_text);
  return source;
}
void Reject(const std::string& text, const char* expected = nullptr) {
  auto result = Request(Operation::kPdfa);
  const auto error = ipc::ParseRequestMetadata(text, &result);
  Check(static_cast<bool>(error), "invalid metadata rejected");
  if (expected) Check(error.code == expected, "specific request error");
  Check(result.request_id.empty() && result.input.size == 0 && result.input.sha256.empty(),
        "invalid metadata leaves no partly parsed request");
  ipc::Frame reply{"stale-success", {1}};
  Check(static_cast<bool>(ipc::BuildRefusalReply({text, {}}, &reply)), "invalid request cannot produce reply");
  Check(reply.metadata.empty() && reply.payload.empty(), "invalid request clears old reply");
}

void ValidRequests() {
  for (auto operation : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) {
    const auto text = Metadata(operation);
    ipc::Request parsed;
    Okay(ipc::ParseRequestMetadata(text, &parsed), "parse metadata from unchanged W1 serializer");
    const auto expected = Request(operation);
    Check(parsed.protocol == expected.protocol && parsed.operation == expected.operation &&
          parsed.request_id == expected.request_id && parsed.timeout_ms == expected.timeout_ms &&
          parsed.input.size == expected.input.size && parsed.input.sha256 == expected.input.sha256,
          "parsed request preserves operation, correlation, input and deadline");
    ipc::Frame request{text, std::vector<std::uint8_t>(static_cast<std::size_t>(parsed.input.size), 0xff)};
    std::vector<std::uint8_t> bytes;
    Okay(ipc::EncodeFrame(request, ipc::Direction::kRequest, &bytes), "encode incoming frame");
    ipc::Frame received;
    Okay(ipc::DecodeFrame(bytes, ipc::Direction::kRequest, &received), "decode incoming frame");
    ipc::Frame reply;
    Okay(ipc::BuildRefusalReply(received, &reply), "valid request produces refusal");
    std::string refusal;
    Okay(ipc::UnavailableMetadata(parsed, &refusal), "expected unchanged W1 refusal");
    Check(reply.metadata == refusal && reply.payload.empty(), "service refusal is exactly the W1 contract");
    for (const auto* field : {"\"executed\":false", "\"pid\":0", "\"exitCode\":-1",
                              "\"stdoutLength\":0", "\"stderrLength\":0", "\"files\":[]",
                              "\"qualified\":false", "\"serviceIdentityVerified\":false",
                              "\"processIsolationVerified\":false", "\"networkDeniedVerified\":false",
                              "\"filesystemRestrictedVerified\":false", "WINDOWS_ISOLATION_UNAVAILABLE"}) {
      Check(reply.metadata.find(field) != std::string::npos, "refusal never claims execution or isolation");
    }
    Okay(ipc::EncodeFrame(reply, ipc::Direction::kResponse, &bytes), "encode service refusal");
    Okay(ipc::DecodeFrame(bytes, ipc::Direction::kResponse, &received), "decode service refusal");
    Check(received.metadata == refusal && received.payload.empty(), "refusal survives framed round trip");
    ipc::Frame forbidden{"stale-success", {1}};
    Check(ipc::Exchange(parsed, &forbidden).code == ipc::kIsolationUnavailable &&
          forbidden.metadata.empty() && forbidden.payload.empty(), "production client remains closed for each operation");
  }
  const auto reordered = std::string("{\"input\":null,\"timeoutMs\":10000,\"requestId\":") +
      "\"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee\",\"operation\":\"version\","
      "\"contract\":\"ABAK-WINDOWS-CONTROLS-1\",\"protocol\":1}";
  ipc::Request result;
  Okay(ipc::ParseRequestMetadata(reordered, &result), "property order is not an authority signal");
  auto pdf = Metadata(Operation::kPdfa);
  const auto input_order = Replace(pdf,
      "\"name\":\"document.pdf\",\"size\":3,\"sha256\":\"" + std::string(64, 'a') + "\"",
      "\"sha256\":\"" + std::string(64, 'a') + "\",\"size\":3,\"name\":\"document.pdf\"");
  Okay(ipc::ParseRequestMetadata(input_order, &result), "input property order may vary");
}

void InvalidRequests() {
  const auto version = Metadata();
  const auto pdf = Metadata(Operation::kPdfa);
  for (const auto* text : {"", "{}", "[]", "null", "true", "{", "{\"protocol\":1,}",
                          "{\"protocol\":1}", "{\"protocol\":{}}"}) Reject(text);
  Reject(" " + version);
  Reject(version + "\n");
  Reject(version + version);
  Reject(Replace(version, "\"protocol\":1", "\"protocol\":2"), "PROTOCOL_MISMATCH");
  Reject(Replace(version, "ABAK-WINDOWS-CONTROLS-1", "ABAK-MACOS-CONTROLS-1"), "PROTOCOL_MISMATCH");
  for (const auto* member : {"\"protocol\":1", "\"contract\":\"ABAK-WINDOWS-CONTROLS-1\"",
                             "\"operation\":\"version\"", "\"requestId\":\"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee\"",
                             "\"timeoutMs\":10000", "\"input\":null"}) {
    Reject(Replace(version, "{", std::string("{") + member + ","));
    const auto with_comma = std::string(member) + ",";
    if (version.find(with_comma) != std::string::npos) Reject(Replace(version, with_comma, ""));
    else Reject(Replace(version, std::string(",") + member, ""));
  }
  for (const auto* extra : {"\"executed\":true", "\"qualified\":true", "\"trusted_installation\":true",
                            "\"javaPath\":\"java.exe\"", "\"command\":\"cmd.exe\"", "\"outputPath\":\"C:\\\\out\""}) {
    Reject(Replace(version, "{", std::string("{") + extra + ","));
  }
  for (const auto* operation : {"cmd", "PDFa", "pdfa --help", "", "powershell.exe"}) {
    Reject(Replace(version, "\"version\"", std::string("\"") + operation + "\""));
  }
  for (const auto* value : {"-1", "+1", "1.0", "1e3", "01", "4294967296", "\"1000\"", "null", "true", "[]", "{}"}) {
    Reject(Replace(version, "10000", value));
  }
  Reject(Replace(version, "10000", "0"), "INVALID_TIMEOUT");
  Reject(Replace(version, "10000", "10001"), "INVALID_TIMEOUT");
  Reject(Replace(pdf, "240000", "240001"), "INVALID_TIMEOUT");
  Reject(Replace(version, "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", "AAAAAAAA-bbbb-cccc-dddd-eeeeeeeeeeee"), "INVALID_REQUEST_ID");
  Reject(Replace(version, "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", "../document"), "INVALID_REQUEST_ID");
  Reject(Replace(version, "null", "{}"));
  Reject(Replace(version, "null", "{\"name\":\"document.pdf\",\"size\":0,\"sha256\":\"\"}"), "INVALID_INPUT");
  Reject(Replace(pdf, "{\"name\":\"document.pdf\",\"size\":3,\"sha256\":\"" + std::string(64, 'a') + "\"}", "null"), "INVALID_INPUT");
  for (const auto* name : {"document.xml", "../document.pdf", "C:/document.pdf", "java.exe", ""}) {
    Reject(Replace(pdf, "document.pdf", name), "INVALID_INPUT");
  }
  for (const auto* value : {"0", "67108865", "18446744073709551615"}) {
    Reject(Replace(pdf, "\"size\":3", std::string("\"size\":") + value), "INVALID_INPUT");
  }
  Reject(Replace(pdf, "\"size\":3", "\"size\":18446744073709551616"));
  Reject(Replace(pdf, std::string(64, 'a'), std::string(63, 'a')), "INVALID_INPUT");
  Reject(Replace(pdf, std::string(64, 'a'), std::string(64, 'A')), "INVALID_INPUT");
  Reject(Replace(pdf, "\"name\":", "\"name\":\"document.pdf\",\"name\":"));
  Reject(Replace(pdf, "\"size\":3", "\"size\":3,\"size\":3"));
  Reject(Replace(pdf, "\"sha256\":", "\"sha256\":\"" + std::string(64, 'a') + "\",\"sha256\":"));
  Reject(Replace(pdf, "\"name\":", "\"free\":{},\"name\":"));
  Reject(Replace(version, "version", "vers\\u0069on"));
  Reject(Replace(version, "version", std::string("vers\0ion", 8)));
  Reject(std::string("\xef\xbb\xbf") + version);
  Reject(Replace(version, "version", std::string("\xc0\xaf", 2)));
  Reject(std::string(ipc::kMaxMetadataBytes + 1, 'x'), "INVALID_REQUEST_METADATA");
  ipc::Request maximum;
  Okay(ipc::ParseRequestMetadata(Replace(pdf, "\"size\":3", "\"size\":67108864"),
                                &maximum), "metadata accepts W1 maximum input size");
}

void FramesAndGate(const char* fixture_path) {
  ipc::Frame frame{Metadata(Operation::kPdfa), {1, 2}};
  ipc::Frame reply{"stale-success", {1}};
  Check(ipc::BuildRefusalReply(frame, &reply).code == "INVALID_INPUT" &&
        reply.metadata.empty() && reply.payload.empty(), "document size mismatch clears reply");
  frame = {Metadata(), {1}};
  Check(ipc::BuildRefusalReply(frame, &reply).code == "INVALID_INPUT", "version body forbidden");
  frame = {Metadata(), {}};
  Check(ipc::BuildRefusalReply(frame, nullptr).code == "INVALID_ARGUMENTS", "missing reply output refuses");
  Check(ipc::ParseRequestMetadata(frame.metadata, nullptr).code == "INVALID_ARGUMENTS", "missing parse output refuses");
  Check(ipc::BuildRefusalReply(frame, &frame).code == "INVALID_ARGUMENTS" &&
        frame.metadata.empty() && frame.payload.empty(), "aliased frames refuse and clear output");
  {
    ipc::Frame oversized{Metadata(Operation::kPdfa),
        std::vector<std::uint8_t>(static_cast<std::size_t>(ipc::kMaxInputBytes + 1))};
    reply = {"stale-success", {1}};
    Check(ipc::BuildRefusalReply(oversized, &reply).code == "PAYLOAD_LIMIT_EXCEEDED" &&
          reply.metadata.empty() && reply.payload.empty(), "oversized input refuses without result");
  }
  for (int i = 0; i < 20; ++i) {
    Check(ipc::ServiceStartupGate().code == "SERVICE_INSTALLATION_UNQUALIFIED", "SCM startup gate always remains closed");
  }
  Okay(ipc::BuildRefusalReply({Metadata(), {}}, &reply), "golden refusal");
  std::vector<std::uint8_t> bytes;
  Okay(ipc::EncodeFrame(reply, ipc::Direction::kResponse, &bytes), "golden refusal encoding");
  std::ifstream input(fixture_path, std::ios::binary);
  Check(input.good(), "existing cross-language fixture readable");
  const std::vector<std::uint8_t> expected((std::istreambuf_iterator<char>(input)),
                                          std::istreambuf_iterator<char>());
  Check(bytes == expected, "service reply is byte-identical to existing Dart refusal fixture");
}

void HostileCorpus() {
  std::mt19937 random(7319);
  for (int i = 0; i < 10000; ++i) {
    std::string text(random() % 256, '\0');
    for (auto& byte : text) byte = static_cast<char>(random() & 0xff);
    Reject(text);
  }
  const auto good = Metadata();
  for (std::size_t i = 0; i < good.size(); ++i) {
    Reject(good.substr(0, i));
  }
}
}  // namespace

int main(int argc, char** argv) {
  Check(argc == 2, "pass the existing W1/Dart refusal fixture path");
  ValidRequests();
  InvalidRequests();
  FramesAndGate(argv[1]);
  HostileCorpus();
  std::cout << checks << " W3 service-core checks passed; every valid request is refused.\n";
  std::cout << "No service host, Java, validator or patient document executed.\n";
}
