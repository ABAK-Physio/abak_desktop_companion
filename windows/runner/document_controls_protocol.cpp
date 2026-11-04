#include "document_controls_protocol.h"

#include <algorithm>
#include <utility>

namespace document_controls::windows_ipc {
namespace {

Error Invalid(const char* code, const char* message) { return {code, message}; }

bool LowerHex(const std::string& value, std::size_t length) {
  return value.size() == length &&
         std::all_of(value.begin(), value.end(), [](char c) {
           return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f');
         });
}

bool RequestId(const std::string& value) {
  if (value.size() != 36) return false;
  std::string hex;
  for (std::size_t i = 0; i < value.size(); ++i) {
    if (i == 8 || i == 13 || i == 18 || i == 23) {
      if (value[i] != '-') return false;
    } else {
      hex.push_back(value[i]);
    }
  }
  return LowerHex(hex, 32);
}

Error ValidateSizes(FrameSizes sizes, Direction direction) {
  if (sizes.metadata == 0 || sizes.metadata > kMaxMetadataBytes) {
    return Invalid("INVALID_FRAME_SIZE", "Invalid metadata length.");
  }
  const auto maximum = direction == Direction::kRequest ? kMaxInputBytes
                                                       : kMaxOutputBytes;
  if (sizes.payload > maximum) {
    return Invalid("PAYLOAD_LIMIT_EXCEEDED", "Payload exceeds the hard limit.");
  }
  return {};
}

std::string CommonMetadata(const Request& request) {
  // All inserted strings have been validated against closed ASCII alphabets.
  return "\"protocol\":1,\"contract\":\"" + std::string(kContract) +
         "\",\"operation\":\"" + OperationName(request.operation) +
         "\",\"requestId\":\"" + request.request_id + "\"";
}

}  // namespace

const char* OperationName(Operation operation) {
  switch (operation) {
    case Operation::kPdfa: return "pdfa";
    case Operation::kVersion: return "version";
    case Operation::kCda: return "cda";
  }
  return nullptr;
}

std::uint32_t MaxExecutionMs(Operation operation) {
  return operation == Operation::kVersion ? 10000 : 240000;
}

Error ValidateRequest(const Request& request) {
  if (request.protocol != kProtocol) {
    return Invalid("PROTOCOL_MISMATCH", "Unsupported Windows protocol.");
  }
  if (!OperationName(request.operation)) {
    return Invalid("INVALID_OPERATION", "Document operation is not allowed.");
  }
  if (!RequestId(request.request_id)) {
    return Invalid("INVALID_REQUEST_ID", "A lowercase UUID is required.");
  }
  if (request.timeout_ms == 0 ||
      request.timeout_ms > MaxExecutionMs(request.operation)) {
    return Invalid("INVALID_TIMEOUT", "Invalid execution deadline.");
  }
  if (request.operation == Operation::kVersion) {
    if (request.input.size != 0 || !request.input.sha256.empty()) {
      return Invalid("INVALID_INPUT", "Version does not accept a document.");
    }
  } else if (request.input.size == 0 || request.input.size > kMaxInputBytes ||
             !LowerHex(request.input.sha256, 64)) {
    return Invalid("INVALID_INPUT", "A bounded input and SHA-256 are required.");
  }
  return {};
}

Error RequestMetadata(const Request& request, std::string* metadata) {
  if (!metadata) return Invalid("INVALID_ARGUMENTS", "Missing metadata output.");
  metadata->clear();
  if (auto error = ValidateRequest(request)) return error;
  *metadata = "{" + CommonMetadata(request) + ",\"timeoutMs\":" +
              std::to_string(request.timeout_ms) + ",\"input\":";
  if (request.operation == Operation::kVersion) {
    *metadata += "null}";
  } else {
    *metadata += "{\"name\":\"" +
        std::string(request.operation == Operation::kPdfa ? "document.pdf"
                                                        : "document.xml") +
        "\",\"size\":" + std::to_string(request.input.size) +
        ",\"sha256\":\"" + request.input.sha256 + "\"}}";
  }
  return {};
}

Error UnavailableMetadata(const Request& request, std::string* metadata) {
  if (!metadata) return Invalid("INVALID_ARGUMENTS", "Missing metadata output.");
  metadata->clear();
  if (auto error = ValidateRequest(request)) return error;
  *metadata = "{" + CommonMetadata(request) +
      ",\"executed\":false,\"pid\":0,\"exitCode\":-1,"
      "\"stdoutLength\":0,\"stderrLength\":0,\"files\":[],\"input\":null,"
      "\"truncated\":false,\"error\":{\"code\":\"" + kIsolationUnavailable +
      "\",\"message\":\"Windows document isolation is not qualified.\"},"
      "\"isolation\":{\"platform\":\"windows\",\"qualified\":false,"
      "\"serviceIdentityVerified\":false,\"processIsolationVerified\":false,"
      "\"jobObjectVerified\":false,\"networkDeniedVerified\":false,"
      "\"filesystemRestrictedVerified\":false}}";
  return {};
}

bool ValidUtf8(const std::string& value) {
  std::size_t i = 0;
  while (i < value.size()) {
    const auto first = static_cast<unsigned char>(value[i++]);
    if (first == 0) return false;
    if (first < 0x80) continue;
    unsigned int code = 0;
    unsigned int minimum = 0;
    std::size_t extra = 0;
    if (first >= 0xc2 && first <= 0xdf) {
      code = first & 0x1f; minimum = 0x80; extra = 1;
    } else if (first >= 0xe0 && first <= 0xef) {
      code = first & 0x0f; minimum = 0x800; extra = 2;
    } else if (first >= 0xf0 && first <= 0xf4) {
      code = first & 0x07; minimum = 0x10000; extra = 3;
    } else {
      return false;
    }
    if (extra > value.size() - i) return false;
    for (std::size_t n = 0; n < extra; ++n) {
      const auto next = static_cast<unsigned char>(value[i++]);
      if ((next & 0xc0) != 0x80) return false;
      code = (code << 6) | (next & 0x3f);
    }
    if (code < minimum || code > 0x10ffff ||
        (code >= 0xd800 && code <= 0xdfff)) return false;
  }
  return true;
}

Error DecodePrefix(const std::uint8_t* bytes, std::size_t size,
                   Direction direction, FrameSizes* sizes) {
  if (sizes) *sizes = {};
  if (!bytes || !sizes || size != kPrefixBytes) {
    return Invalid("INVALID_FRAME", "Exactly twelve prefix bytes are required.");
  }
  FrameSizes decoded;
  for (std::size_t i = 0; i < 4; ++i) {
    decoded.metadata |= static_cast<std::uint32_t>(bytes[i]) << (8 * i);
  }
  for (std::size_t i = 0; i < 8; ++i) {
    decoded.payload |= static_cast<std::uint64_t>(bytes[4 + i]) << (8 * i);
  }
  if (auto error = ValidateSizes(decoded, direction)) return error;
  *sizes = decoded;
  return {};
}

Error EncodeFrame(const Frame& frame, Direction direction,
                  std::vector<std::uint8_t>* bytes) {
  if (!bytes) return Invalid("INVALID_ARGUMENTS", "Missing frame output.");
  bytes->clear();
  if (frame.metadata.size() > kMaxMetadataBytes ||
      !ValidUtf8(frame.metadata)) {
    return Invalid("INVALID_METADATA", "Invalid UTF-8 metadata or size.");
  }
  const FrameSizes sizes{static_cast<std::uint32_t>(frame.metadata.size()),
                         static_cast<std::uint64_t>(frame.payload.size())};
  if (auto error = ValidateSizes(sizes, direction)) return error;
  bytes->resize(kPrefixBytes);
  for (std::size_t i = 0; i < 4; ++i) {
    (*bytes)[i] = static_cast<std::uint8_t>(sizes.metadata >> (8 * i));
  }
  for (std::size_t i = 0; i < 8; ++i) {
    (*bytes)[4 + i] = static_cast<std::uint8_t>(sizes.payload >> (8 * i));
  }
  bytes->insert(bytes->end(), frame.metadata.begin(), frame.metadata.end());
  bytes->insert(bytes->end(), frame.payload.begin(), frame.payload.end());
  return {};
}

Error DecodeFrame(const std::vector<std::uint8_t>& bytes, Direction direction,
                  Frame* frame) {
  if (!frame) return Invalid("INVALID_ARGUMENTS", "Missing decoded frame.");
  *frame = {};
  if (bytes.size() < kPrefixBytes) {
    return Invalid("INVALID_FRAME", "Incomplete frame prefix.");
  }
  FrameSizes sizes;
  if (auto error = DecodePrefix(bytes.data(), kPrefixBytes, direction, &sizes)) {
    return error;
  }
  const std::uint64_t expected = kPrefixBytes +
      static_cast<std::uint64_t>(sizes.metadata) + sizes.payload;
  if (expected != bytes.size()) {
    return Invalid("INVALID_FRAME", "Incomplete frame or trailing bytes.");
  }
  const auto metadata_end = bytes.begin() + kPrefixBytes + sizes.metadata;
  std::string metadata(bytes.begin() + kPrefixBytes, metadata_end);
  if (!ValidUtf8(metadata)) {
    return Invalid("INVALID_METADATA", "Metadata is not strict UTF-8.");
  }
  frame->metadata = std::move(metadata);
  frame->payload.assign(metadata_end, bytes.end());
  return {};
}

}  // namespace document_controls::windows_ipc
