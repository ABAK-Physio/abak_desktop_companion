#include "cps_profile_reader.h"

#include <array>
#include <utility>

namespace cps_windows {
namespace {
constexpr Ulong kMaximumObject = 65536;
constexpr Ulong kClass = 0, kToken = 1, kPrivate = 2, kLabel = 3, kValue = 0x11;
struct SecretCleanup {
  std::vector<Byte>* bytes;
  ~SecretCleanup() { Erase(bytes); }
};
bool Failure(Reply* reply, const char* step, Ulong code) {
  reply->success = false;
  reply->step = step;
  reply->code = code;
  return false;
}
bool ReadObject(const Api& api, Ulong session, const std::string& label,
                Reply* reply) {
  Ulong object_class = 0;  // CKO_DATA, never certificates or private keys.
  Byte token = 1;
  Byte private_object = label.rfind("CPS_ACTIVITY_", 0) == 0 ? 1 : 0;
  std::vector<Byte> label_bytes(label.begin(), label.end());
  std::array<Attribute, 4> attributes{{
      {kClass, &object_class, sizeof(object_class)},
      {kToken, &token, 1}, {kPrivate, &private_object, 1},
      {kLabel, label_bytes.data(), static_cast<Ulong>(label_bytes.size())}}};
  Ulong code = api.find_init(session, attributes.data(),
      static_cast<Ulong>(attributes.size()));
  if (code) return Failure(reply, "C_FindObjectsInit", code);
  std::array<Ulong, 2> handles{};
  Ulong count = 0;
  const Ulong found = api.find(session, handles.data(), 2, &count);
  const Ulong finished = api.find_final(session);
  if (found) return Failure(reply, "C_FindObjects", found);
  if (finished) return Failure(reply, "C_FindObjectsFinal", finished);
  if (count == 0) return true;  // Optional/unused activity slot.
  if (count != 1) return Failure(reply, "C_ReadObject", 0);
  Attribute value{kValue, nullptr, 0};
  code = api.attribute(session, handles[0], &value, 1);
  if (code || value.length == 0 || value.length > kMaximumObject)
    return Failure(reply, "C_GetAttributeValue(size)", code);
  std::vector<Byte> bytes(value.length);
  value.value = bytes.data();
  code = api.attribute(session, handles[0], &value, 1);
  if (code || value.length == 0 || value.length > bytes.size())
    return Failure(reply, "C_GetAttributeValue", code);
  bytes.resize(value.length);
  reply->objects.emplace(label, std::move(bytes));
  return true;
}
}  // namespace

Request::~Request() { Erase(&pin); }
Request& Request::operator=(Request&& other) noexcept {
  if (this != &other) {
    Erase(&pin); pin = std::move(other.pin); operation = other.operation;
    expected_id = std::move(other.expected_id); signed_info = std::move(other.signed_info);
    expected_certificate = std::move(other.expected_certificate);
  }
  return *this;
}
void ClearMaterial(Reply* reply) {
  reply->objects.clear(); reply->certificates.clear(); reply->signature.clear();
  reply->national_id.clear(); reply->message.clear(); reply->algorithm.clear();
  reply->verified = false; reply->tampered_rejected = false;
}
bool ValidRequest(const Request& request) {
  if (!ValidPin(request.pin)) return false;
  if (request.operation == Operation::Read)
    return request.expected_id.empty() && request.signed_info.empty() && request.expected_certificate.empty();
  if (request.operation != Operation::Prepare && request.operation != Operation::Sign &&
      request.operation != Operation::Test) return false;
  if (request.expected_id.empty() || request.expected_id.size() > 64) return false;
  for (auto ch : request.expected_id) if (ch < '0' || ch > '9') return false;
  if (request.operation != Operation::Sign)
    return request.signed_info.empty() && request.expected_certificate.empty();
  return !request.signed_info.empty() && request.signed_info.size() <= 32768 &&
      request.signed_info.find('\0') == std::string::npos &&
      !request.expected_certificate.empty() && request.expected_certificate.size() <= 87384;
}
bool Api::complete() const {
  return initialize && finalize && slots && open && login && logout && close &&
      find_init && find && find_final && attribute;
}
void Erase(std::vector<Byte>* bytes) {
  if (!bytes) return;
  volatile Byte* data = bytes->data();
  for (std::size_t index = 0; index < bytes->size(); ++index) data[index] = 0;
  bytes->clear();
}
bool ValidPin(const std::vector<Byte>& pin) {
  if (pin.empty() || pin.size() > 16) return false;
  for (const Byte digit : pin) if (digit < '0' || digit > '9') return false;
  return true;
}
std::vector<std::string> ProfileLabels() {
  std::vector<std::string> labels{"CPS_ID_CARD", "CPS_NAME_PS", "CPS_INFO_PS"};
  for (unsigned int number = 1; number <= 16; ++number) {
    const std::string suffix = number < 10 ? "0" + std::to_string(number) :
        std::to_string(number);
    labels.push_back("CPS_ACTIVITY_" + suffix + "_PS");
  }
  return labels;
}

Reply ReadProfile(const Api& api, std::vector<Byte> pin, const SessionAction& action) {
  SecretCleanup secret{&pin};
  Reply reply;
  if (!ValidPin(pin)) { reply.step = "PIN_FORMAT"; return reply; }
  if (!api.complete()) { reply.step = "GetProcAddress"; return reply; }
  const Ulong initialized = api.initialize(nullptr);
  if (initialized) {
    Failure(&reply, "C_Initialize", initialized);
    return reply;
  }
  Ulong session = 0;
  bool opened = false, logged_in = false;
  const auto read = [&]() {
    Ulong count = 0;
    Ulong code = api.slots(1, nullptr, &count);
    reply.slot_count = count;
    if (code || count != 1) return Failure(&reply, "C_GetSlotList", code);
    Ulong slot = 0;
    code = api.slots(1, &slot, &count);
    reply.slot_count = count;
    if (code || count != 1) return Failure(&reply, "C_GetSlotList(ids)", code);
    code = api.open(slot, 4, nullptr, nullptr, &session); // CKF_SERIAL_SESSION; no RW.
    if (code) return Failure(&reply, "C_OpenSession", code);
    opened = true;
    code = api.login(session, 1, pin.data(), static_cast<Ulong>(pin.size()));
    Erase(&pin);  // No retry, even on an incorrect PIN.
    if (code) return Failure(&reply, "C_Login", code);
    logged_in = true;
    bool activity = false;
    for (const auto& label : ProfileLabels()) {
      if (!ReadObject(api, session, label, &reply)) {
        reply.object_label = label;
        return false;
      }
      if (label.rfind("CPS_ACTIVITY_", 0) == 0 && reply.objects.count(label))
        activity = true;
    }
    for (const auto* required : {"CPS_NAME_PS", "CPS_INFO_PS"}) {
      if (!reply.objects.count(required)) {
        reply.object_label = required;
        return Failure(&reply, "C_ReadObject", 0);
      }
    }
    if (!activity) {
      reply.object_label = "CPS_ACTIVITY_01_PS";
      return Failure(&reply, "C_ReadObject", 0);
    }
    return !action || action(session, &reply);
  };
  try { reply.success = read(); }
  catch (...) {
    reply.success = false; reply.step = action ? "certificates" : "C_ReadObject";
    reply.error = "Operation CPS interrompue avant son terme.";
  }
  // Report cleanup failure on an otherwise successful read. Never mask a PIN
  // error with a later cleanup error, and always attempt all owned cleanup.
  const auto cleanup = [&](const char* step, Ulong code) {
    if (code && reply.success) Failure(&reply, step, code);
  };
  if (logged_in) cleanup("C_Logout", api.logout(session));
  if (opened) cleanup("C_CloseSession", api.close(session));
  cleanup("C_Finalize", api.finalize(nullptr));
  if (!reply.success) ClearMaterial(&reply);
  return reply;
}
}  // namespace cps_windows
