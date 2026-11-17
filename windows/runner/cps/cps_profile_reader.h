#pragma once

#include <cstddef>
#include <cstdint>
#include <map>
#include <functional>
#include <string>
#include <vector>

// Windows PKCS#11 uses 32-bit CK_ULONG even in a 64-bit process. CK_ATTRIBUTE
// is packed on one byte by the Windows Cryptoki headers (ANS programming kit).
namespace cps_windows {
using Ulong = std::uint32_t;
using Byte = std::uint8_t;
using Notify = Ulong (*)(Ulong, Ulong, void*);
#pragma pack(push, 1)
struct Attribute {
  Ulong type;
  void* value;
  Ulong length;
};
#pragma pack(pop)
static_assert(sizeof(Ulong) == 4, "Windows CK_ULONG must be 32 bit.");
static_assert(offsetof(Attribute, value) == 4, "Windows CK_ATTRIBUTE packing.");
static_assert(sizeof(Attribute) == sizeof(void*) + 8, "Windows CK_ATTRIBUTE size.");

#pragma pack(push, 1)
struct Mechanism { Ulong type; void* parameter; Ulong length; };
#pragma pack(pop)
static_assert(sizeof(Mechanism) == sizeof(void*) + 8, "Windows CK_MECHANISM size.");
static_assert(offsetof(Mechanism, parameter) == 4, "Windows CK_MECHANISM packing.");
enum class Operation : Ulong { Read = 0, Prepare = 1, Sign = 2, Test = 3 };
struct Request {
  Operation operation = Operation::Read;
  std::vector<Byte> pin;
  std::string expected_id, signed_info, expected_certificate;
  Request() = default;
  Request(Request&&) = default;
  Request& operator=(Request&& other) noexcept;
  Request(const Request&) = delete;
  ~Request();
};
struct Certificate {
  std::vector<Byte> der;
  std::string role, national_id, sha256, valid_from, valid_until;
};
struct Api {
  Ulong (*initialize)(void*) = nullptr;
  Ulong (*finalize)(void*) = nullptr;
  Ulong (*slots)(Byte, Ulong*, Ulong*) = nullptr;
  Ulong (*open)(Ulong, Ulong, void*, Notify, Ulong*) = nullptr;
  Ulong (*login)(Ulong, Ulong, Byte*, Ulong) = nullptr;
  Ulong (*logout)(Ulong) = nullptr;
  Ulong (*close)(Ulong) = nullptr;
  Ulong (*find_init)(Ulong, Attribute*, Ulong) = nullptr;
  Ulong (*find)(Ulong, Ulong*, Ulong, Ulong*) = nullptr;
  Ulong (*find_final)(Ulong) = nullptr;
  Ulong (*attribute)(Ulong, Ulong, Attribute*, Ulong) = nullptr;
  Ulong (*sign_init)(Ulong, Mechanism*, Ulong) = nullptr;
  Ulong (*sign)(Ulong, Byte*, Ulong, Byte*, Ulong*) = nullptr;
  bool complete() const;
};

struct Reply {
  bool success = false;
  Operation operation = Operation::Read;
  std::vector<Certificate> certificates;
  std::string national_id, error, message, algorithm;
  std::vector<Byte> signature;
  bool verified = false, tampered_rejected = false;
  Ulong code = 0;
  Ulong windows_error = 0;
  Ulong slot_count = 0;
  std::string step;
  std::string object_label;
  std::map<std::string, std::vector<Byte>> objects;
  // Set only by the parent for transport, timeout or process failures.
  std::string transport_error;
};

void Erase(std::vector<Byte>* bytes);
bool ValidPin(const std::vector<Byte>& pin);
std::vector<std::string> ProfileLabels();
// One login attempt, read-only serial session, whitelisted business data.
// Optional explicit signing action runs in that same session before cleanup.
using SessionAction = std::function<bool(Ulong, Reply*)>;
Reply ReadProfile(const Api& api, std::vector<Byte> pin,
                  const SessionAction& action = {});
void ClearMaterial(Reply* reply);
bool ValidRequest(const Request& request);
}  // namespace cps_windows
