#pragma once
#include "cps_profile_reader.h"
namespace cps_windows {
// Public certificate parsing and verification only. No key export or signing here.
struct PublicCrypto {
  std::function<bool(Certificate*)> inspect;
  std::function<bool(const std::vector<Byte>&, const std::string&,
                     const std::vector<Byte>&, bool)> verify;
  std::function<std::string()> challenge;
};
std::string Base64(const std::vector<Byte>& bytes);
bool SignSession(const Api& api, Ulong session, const Request& request,
                 const PublicCrypto& crypto, Reply* reply);
PublicCrypto WindowsPublicCrypto();
}
