#include "cps_wire.h"
#include <algorithm>
#include <utility>

namespace cps_windows {
namespace {
constexpr std::array<Byte, 8> kRequest{'A','B','A','K','C','P','0','2'};
constexpr std::array<Byte, 8> kReply{'A','B','A','K','C','R','0','2'};
bool Metadata(const Reply& reply) {
  const auto labels = ProfileLabels();
  const auto operation = static_cast<Ulong>(reply.operation);
  if (operation > 3 || reply.error.size() > 512) return false;
  if (reply.success) {
    if (!reply.error.empty()) return false;
    if (reply.operation == Operation::Read) {
      if (!reply.certificates.empty() || !reply.national_id.empty() || !reply.message.empty() ||
          !reply.signature.empty() || !reply.algorithm.empty() || reply.verified || reply.tampered_rejected) return false;
    } else {
      if (reply.certificates.size() != 2 || reply.national_id.empty() || reply.national_id.size() > 64) return false;
      for (std::size_t i = 0; i < 2; ++i) {
        const auto& c = reply.certificates[i];
        if (c.role != (i == 0 ? "signature" : "authentification") || c.national_id != reply.national_id ||
            c.der.empty() || c.der.size() > 65536 || c.sha256.size() != 64 ||
            c.valid_from.size() != 20 || c.valid_until.size() != 20) return false;
      }
      if (reply.operation == Operation::Prepare) {
        if (!reply.message.empty() || !reply.signature.empty() || !reply.algorithm.empty() ||
            reply.verified || reply.tampered_rejected) return false;
      } else if (!reply.verified || !reply.tampered_rejected || reply.message.empty() ||
          reply.message.size() > 32768 || reply.signature.empty() || reply.signature.size() > 16384 ||
          reply.algorithm != (reply.operation == Operation::Test ? "RSA-SHA256 / PKCS#1 v1.5" :
          "RSA-SHA1 / PKCS#1 v1.5 (lot local)")) return false;
    }
  } else if (!reply.certificates.empty() || !reply.national_id.empty() || !reply.message.empty() ||
      !reply.signature.empty() || !reply.algorithm.empty() || reply.verified || reply.tampered_rejected) return false;
  if (!reply.object_label.empty() &&
      std::find(labels.begin(), labels.end(), reply.object_label) == labels.end()) return false;
  if (reply.success) {
    bool activity = false;
    for (const auto& object : reply.objects)
      if (object.first.rfind("CPS_ACTIVITY_", 0) == 0) activity = true;
    return reply.code == 0 && reply.windows_error == 0 && reply.slot_count == 1 &&
        reply.step.empty() && reply.object_label.empty() && activity &&
        reply.objects.count("CPS_NAME_PS") && reply.objects.count("CPS_INFO_PS");
  }
  static const std::vector<std::string> steps{
      "REQUEST_FORMAT", "identity", "certificates", "keyBinding", "C_SignInit", "C_Sign(size)", "C_Sign", "verification",
      "PIN_FORMAT", "LoadLibrary", "GetProcAddress", "FreeLibrary", "C_Initialize",
      "C_Finalize", "C_GetSlotList", "C_GetSlotList(ids)", "C_OpenSession", "C_Login",
      "C_Logout", "C_CloseSession", "C_FindObjectsInit", "C_FindObjects",
      "C_FindObjectsFinal", "C_ReadObject", "C_GetAttributeValue(size)", "C_GetAttributeValue"};
  return reply.objects.empty() && std::find(steps.begin(), steps.end(), reply.step) != steps.end();
}
void Number(std::vector<Byte>* bytes, std::uint32_t value) {
  const auto offset = bytes->size(); bytes->resize(offset + 4);
  Put32(bytes->data() + offset, value);
}
void Blob(std::vector<Byte>* bytes, const Byte* data, std::size_t size) {
  Number(bytes, static_cast<std::uint32_t>(size));
  if (size) bytes->insert(bytes->end(), data, data + size);
}
void Text(std::vector<Byte>* bytes, const std::string& text) {
  Blob(bytes, reinterpret_cast<const Byte*>(text.data()), text.size());
}
class Cursor {
 public:
  explicit Cursor(const std::vector<Byte>& bytes) : bytes_(bytes) {}
  bool Number(std::uint32_t* value) {
    if (bytes_.size() - offset_ < 4) return false;
    *value = Get32(bytes_.data() + offset_); offset_ += 4; return true;
  }
  bool Blob(std::vector<Byte>* value, std::uint32_t maximum) {
    std::uint32_t size = 0;
    if (!Number(&size) || size > maximum || size > bytes_.size() - offset_) return false;
    value->assign(bytes_.data() + offset_, bytes_.data() + offset_ + size);
    offset_ += size; return true;
  }
  bool Text(std::string* value, std::uint32_t maximum) {
    std::vector<Byte> data;
    if (!Blob(&data, maximum)) return false;
    for (const auto byte : data) if (byte < 32 || byte > 126) return false;
    value->assign(data.begin(), data.end()); return true;
  }
  bool RawText(std::string* value, std::uint32_t maximum) {
    std::vector<Byte> data;
    if (!Blob(&data, maximum)) return false;
    for (auto byte : data) if (byte == 0) return false;
    value->assign(data.begin(), data.end()); return true;
  }
  bool done() const { return offset_ == bytes_.size(); }
 private:
  const std::vector<Byte>& bytes_;
  std::size_t offset_ = 0;
};
}  // namespace
void Put32(Byte* bytes, std::uint32_t value) {
  for (unsigned int i = 0; i < 4; ++i) bytes[i] = static_cast<Byte>(value >> (8 * i));
}
std::uint32_t Get32(const Byte* bytes) {
  std::uint32_t value = 0;
  for (unsigned int i = 0; i < 4; ++i) value |= static_cast<std::uint32_t>(bytes[i]) << (8 * i);
  return value;
}
Header MakeHeader(bool reply, std::uint32_t size) {
  Header header{}; const auto& magic = reply ? kReply : kRequest;
  std::copy(magic.begin(), magic.end(), header.begin());
  Put32(header.data() + 8, 2); Put32(header.data() + 12, size); return header;
}
bool ParseHeader(const Header& header, bool reply, std::uint32_t* size) {
  const auto& magic = reply ? kReply : kRequest;
  if (!size || !std::equal(magic.begin(), magic.end(), header.begin()) ||
      Get32(header.data() + 8) != 2) return false;
  *size = Get32(header.data() + 12);
  return reply ? (*size >= 28 && *size <= kMaximumReply) : (*size >= 21 && *size <= kMaximumRequest);
}
bool EncodeRequest(const Request& request, std::vector<Byte>* bytes) {
  if (!bytes || !ValidRequest(request)) return false;
  bytes->clear(); Number(bytes, static_cast<Ulong>(request.operation));
  Blob(bytes, request.pin.data(), request.pin.size()); Text(bytes, request.expected_id);
  Text(bytes, request.signed_info); Text(bytes, request.expected_certificate);
  return bytes->size() <= kMaximumRequest;
}
bool DecodeRequest(const std::vector<Byte>& bytes, Request* request) {
  if (!request || bytes.size() > kMaximumRequest) return false;
  Cursor cursor(bytes); Request decoded; Ulong operation = 0;
  if (!cursor.Number(&operation) || operation > 3 || !cursor.Blob(&decoded.pin, 16) ||
      !cursor.Text(&decoded.expected_id, 64) || !cursor.RawText(&decoded.signed_info, 32768) ||
      !cursor.Text(&decoded.expected_certificate, 87384) || !cursor.done()) return false;
  decoded.operation = static_cast<Operation>(operation);
  if (!ValidRequest(decoded)) return false;
  *request = std::move(decoded); return true;
}
bool Encode(const Reply& reply, std::vector<Byte>* bytes) {
  if (!bytes || !Metadata(reply) || reply.objects.size() > 19 || reply.step.size() > 64 ||
      reply.object_label.size() > 64 || (!reply.success && !reply.objects.empty())) return false;
  const auto labels = ProfileLabels();
  for (const auto& entry : reply.objects) {
    if (std::find(labels.begin(), labels.end(), entry.first) == labels.end() ||
        entry.second.empty() || entry.second.size() > 65536) return false;
  }
  bytes->clear();
  Number(bytes, reply.success ? 1U : 0U); Number(bytes, reply.code);
  Number(bytes, reply.windows_error); Number(bytes, reply.slot_count);
  Text(bytes, reply.step); Text(bytes, reply.object_label);
  Number(bytes, static_cast<std::uint32_t>(reply.objects.size()));
  for (const auto& entry : reply.objects) {
    Text(bytes, entry.first); Blob(bytes, entry.second.data(), entry.second.size());
  }
  Number(bytes, static_cast<Ulong>(reply.operation)); Text(bytes, reply.error); Text(bytes, reply.national_id);
  Number(bytes, static_cast<Ulong>(reply.certificates.size()));
  for (const auto& c : reply.certificates) {
    Text(bytes, c.role); Text(bytes, c.national_id); Blob(bytes, c.der.data(), c.der.size());
    Text(bytes, c.sha256); Text(bytes, c.valid_from); Text(bytes, c.valid_until);
  }
  Text(bytes, reply.message); Text(bytes, reply.algorithm);
  Blob(bytes, reply.signature.data(), reply.signature.size());
  Number(bytes, reply.verified ? 1U : 0U); Number(bytes, reply.tampered_rejected ? 1U : 0U);
  return bytes->size() <= kMaximumReply;
}
bool Decode(const std::vector<Byte>& bytes, Reply* reply) {
  if (!reply || bytes.size() > kMaximumReply) return false;
  Cursor cursor(bytes); Reply decoded;
  std::uint32_t status = 0, count = 0;
  if (!cursor.Number(&status) || status > 1 || !cursor.Number(&decoded.code) ||
      !cursor.Number(&decoded.windows_error) || !cursor.Number(&decoded.slot_count) ||
      !cursor.Text(&decoded.step, 64) || !cursor.Text(&decoded.object_label, 64) ||
      !cursor.Number(&count) || count > 19 || (status == 0 && count != 0)) return false;
  const auto labels = ProfileLabels();
  for (std::uint32_t index = 0; index < count; ++index) {
    std::string name; std::vector<Byte> value;
    if (!cursor.Text(&name, 64) ||
        std::find(labels.begin(), labels.end(), name) == labels.end() ||
        !cursor.Blob(&value, 65536) || value.empty() ||
        !decoded.objects.emplace(name, std::move(value)).second) return false;
  }
  Ulong operation = 0, certificates = 0, verified = 0, tampered = 0;
  if (!cursor.Number(&operation) || operation > 3 || !cursor.Text(&decoded.error, 512) ||
      !cursor.Text(&decoded.national_id, 64) || !cursor.Number(&certificates) || certificates > 2) return false;
  decoded.operation = static_cast<Operation>(operation);
  for (Ulong i = 0; i < certificates; ++i) {
    Certificate c;
    if (!cursor.Text(&c.role, 32) || !cursor.Text(&c.national_id, 64) || !cursor.Blob(&c.der, 65536) ||
        !cursor.Text(&c.sha256, 64) || !cursor.Text(&c.valid_from, 20) || !cursor.Text(&c.valid_until, 20)) return false;
    decoded.certificates.push_back(std::move(c));
  }
  if (!cursor.RawText(&decoded.message, 32768) || !cursor.Text(&decoded.algorithm, 64) ||
      !cursor.Blob(&decoded.signature, 16384) || !cursor.Number(&verified) || verified > 1 ||
      !cursor.Number(&tampered) || tampered > 1 || !cursor.done()) return false;
  decoded.verified = verified == 1; decoded.tampered_rejected = tampered == 1;
  decoded.success = status == 1;
  if (!Metadata(decoded)) return false;
  *reply = std::move(decoded); return true;
}
}  // namespace cps_windows
