#ifndef RUNNER_DOCUMENT_CONTROLS_PROTOCOL_H_
#define RUNNER_DOCUMENT_CONTROLS_PROTOCOL_H_

#include "document_controls_launcher.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace document_controls::windows_ipc {

inline constexpr std::uint32_t kProtocol = 1;
inline constexpr char kContract[] = "ABAK-WINDOWS-CONTROLS-1";
inline constexpr wchar_t kPipeName[] = L"\\\\.\\pipe\\ABAK.DocumentControls.v1";
inline constexpr std::size_t kPrefixBytes = 12;
inline constexpr std::uint32_t kMaxMetadataBytes = 64 * 1024;
inline constexpr std::uint64_t kMaxInputBytes = 64 * 1024 * 1024;
inline constexpr std::uint64_t kMaxOutputBytes = 12 * 1024 * 1024;
inline constexpr std::uint32_t kConnectTimeoutMs = 2000;
inline constexpr std::uint32_t kIdleTimeoutMs = 5000;
inline constexpr char kIsolationUnavailable[] = "WINDOWS_ISOLATION_UNAVAILABLE";

struct Error {
  std::string code;
  std::string message;
  explicit operator bool() const { return !code.empty(); }
};

struct InputDescriptor {
  std::uint64_t size = 0;
  std::string sha256;
};

// No executable path, arguments, environment, output path, or security override.
struct Request {
  std::uint32_t protocol = kProtocol;
  Operation operation = Operation::kVersion;
  std::string request_id;
  std::uint32_t timeout_ms = 10000;
  InputDescriptor input;
};

enum class Direction { kRequest, kResponse };

struct FrameSizes {
  std::uint32_t metadata = 0;
  std::uint64_t payload = 0;
};

struct Frame {
  std::string metadata;
  std::vector<std::uint8_t> payload;
};

const char* OperationName(Operation operation);
std::uint32_t MaxExecutionMs(Operation operation);
Error ValidateRequest(const Request& request);
Error RequestMetadata(const Request& request, std::string* metadata);
Error UnavailableMetadata(const Request& request, std::string* metadata);
Error DecodePrefix(const std::uint8_t* bytes, std::size_t size,
                   Direction direction, FrameSizes* sizes);
Error EncodeFrame(const Frame& frame, Direction direction,
                  std::vector<std::uint8_t>* bytes);
Error DecodeFrame(const std::vector<std::uint8_t>& bytes, Direction direction,
                  Frame* frame);
bool ValidUtf8(const std::string& value);

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_PROTOCOL_H_
