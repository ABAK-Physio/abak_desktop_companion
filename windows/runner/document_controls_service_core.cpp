#include "document_controls_service_core.h"

#include <limits>
#include <utility>

namespace document_controls::windows_ipc {
namespace {

// The schema contains only fixed ASCII identifiers, lowercase UUIDs/SHA-256,
// null, unsigned decimal integers and one flat input object. No recursion,
// arbitrary JSON values, escape sequences, numbers-as-strings or free paths.
class RequestReader {
 public:
  explicit RequestReader(const std::string& text) : text_(text) {}
  bool Parse(Request* result, std::string* contract, std::string* input_name,
             bool* has_input) {
    if (!Take('{')) return false;
    unsigned int fields = 0;
    for (;;) {
      std::string key;
      if (!String(&key) || !Take(':')) return false;
      unsigned int bit = 0;
      std::uint64_t number = 0;
      if (key == "protocol") {
        bit = 1;
        if (!Number((std::numeric_limits<std::uint32_t>::max)(), &number)) return false;
        result->protocol = static_cast<std::uint32_t>(number);
      } else if (key == "contract") {
        bit = 2;
        if (!String(contract)) return false;
      } else if (key == "operation") {
        bit = 4;
        std::string operation;
        if (!String(&operation)) return false;
        bool found = false;
        for (auto item : {Operation::kPdfa, Operation::kVersion, Operation::kCda}) {
          if (operation == OperationName(item)) { result->operation = item; found = true; }
        }
        if (!found) return false;
      } else if (key == "requestId") {
        bit = 8;
        if (!String(&result->request_id)) return false;
      } else if (key == "timeoutMs") {
        bit = 16;
        if (!Number((std::numeric_limits<std::uint32_t>::max)(), &number)) return false;
        result->timeout_ms = static_cast<std::uint32_t>(number);
      } else if (key == "input") {
        bit = 32;
        if (text_.compare(position_, 4, "null") == 0) {
          position_ += 4;
          *has_input = false;
        } else {
          *has_input = true;
          if (!Input(&result->input, input_name)) return false;
        }
      } else return false;
      if (fields & bit) return false;
      fields |= bit;
      if (Take('}')) break;
      if (!Take(',')) return false;
    }
    return fields == 63 && position_ == text_.size();
  }

 private:
  bool Take(char character) {
    if (position_ == text_.size() || text_[position_] != character) return false;
    ++position_;
    return true;
  }
  bool String(std::string* value) {
    if (!Take('"')) return false;
    const auto start = position_;
    while (position_ < text_.size() && text_[position_] != '"') {
      const auto byte = static_cast<unsigned char>(text_[position_]);
      if (byte < 0x20 || byte >= 0x7f || byte == '\\' || position_ - start >= 128) return false;
      ++position_;
    }
    if (!Take('"')) return false;
    value->assign(text_, start, position_ - start - 1);
    return true;
  }
  bool Number(std::uint64_t maximum, std::uint64_t* value) {
    if (position_ == text_.size() || text_[position_] < '0' || text_[position_] > '9') return false;
    const auto start = position_;
    std::uint64_t result = 0;
    do {
      const auto digit = static_cast<std::uint64_t>(text_[position_] - '0');
      if (result > (maximum - digit) / 10) return false;
      result = result * 10 + digit;
      ++position_;
    } while (position_ < text_.size() && text_[position_] >= '0' && text_[position_] <= '9');
    if (position_ - start > 1 && text_[start] == '0') return false;
    *value = result;
    return true;
  }
  bool Input(InputDescriptor* input, std::string* name) {
    if (!Take('{')) return false;
    unsigned int fields = 0;
    for (;;) {
      std::string key;
      if (!String(&key) || !Take(':')) return false;
      unsigned int bit = 0;
      if (key == "name") {
        bit = 1;
        if (!String(name)) return false;
      } else if (key == "size") {
        bit = 2;
        if (!Number((std::numeric_limits<std::uint64_t>::max)(), &input->size)) return false;
      } else if (key == "sha256") {
        bit = 4;
        if (!String(&input->sha256)) return false;
      } else return false;
      if (fields & bit) return false;
      fields |= bit;
      if (Take('}')) break;
      if (!Take(',')) return false;
    }
    return fields == 7;
  }
  const std::string& text_;
  std::size_t position_ = 0;
};

}  // namespace

Error ParseRequestMetadata(const std::string& metadata, Request* request) {
  if (!request) return {"INVALID_ARGUMENTS", "Missing request output."};
  *request = {};
  if (metadata.empty() || metadata.size() > kMaxMetadataBytes) {
    return {"INVALID_REQUEST_METADATA", "Request metadata length is invalid."};
  }
  Request parsed;
  std::string contract, input_name;
  bool has_input = false;
  RequestReader reader(metadata);
  if (!reader.Parse(&parsed, &contract, &input_name, &has_input)) {
    return {"INVALID_REQUEST_METADATA", "Request does not match the closed JSON schema."};
  }
  if (contract != kContract) return {"PROTOCOL_MISMATCH", "Invalid Windows contract."};
  if (auto error = ValidateRequest(parsed)) return error;
  if (parsed.operation == Operation::kVersion) {
    if (has_input) return {"INVALID_INPUT", "Version does not accept an input object."};
  } else if (!has_input || input_name !=
      (parsed.operation == Operation::kPdfa ? "document.pdf" : "document.xml")) {
    return {"INVALID_INPUT", "Input name does not match the operation."};
  }
  *request = std::move(parsed);
  return {};
}

Error BuildRefusalReply(const Frame& request_frame, Frame* reply) {
  if (!reply) return {"INVALID_ARGUMENTS", "Missing refusal output."};
  if (reply == &request_frame) {
    *reply = {};
    return {"INVALID_ARGUMENTS", "Request and reply must be distinct frames."};
  }
  *reply = {};
  if (request_frame.payload.size() > kMaxInputBytes) {
    return {"PAYLOAD_LIMIT_EXCEEDED", "Input payload exceeds its hard limit."};
  }
  Request request;
  if (auto error = ParseRequestMetadata(request_frame.metadata, &request)) return error;
  if (request.input.size != request_frame.payload.size()) {
    return {"INVALID_INPUT", "Input descriptor and frame length differ."};
  }
  // No hash or clinical validation is claimed: the request is always refused.
  // There is no executor callback, dynamic command, process launch or output file.
  Frame refusal;
  if (auto error = UnavailableMetadata(request, &refusal.metadata)) return error;
  *reply = std::move(refusal);
  return {};
}

Error ServiceStartupGate() {
  return {"SERVICE_INSTALLATION_UNQUALIFIED",
          "Protected installation, peer policies and service isolation are not qualified."};
}

}  // namespace document_controls::windows_ipc
