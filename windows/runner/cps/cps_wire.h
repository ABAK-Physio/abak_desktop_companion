#pragma once
#include "cps_profile_reader.h"
#include <array>

namespace cps_windows {
constexpr std::uint32_t kMaximumReply = 1536 * 1024;
constexpr std::uint32_t kMaximumRequest = 128 * 1024;
using Header = std::array<Byte, 16>;
void Put32(Byte* bytes, std::uint32_t value);
std::uint32_t Get32(const Byte* bytes);
Header MakeHeader(bool reply, std::uint32_t size);
bool ParseHeader(const Header& header, bool reply, std::uint32_t* size);
bool EncodeRequest(const Request& request, std::vector<Byte>* bytes);
bool DecodeRequest(const std::vector<Byte>& bytes, Request* request);
bool Encode(const Reply& reply, std::vector<Byte>* bytes);
bool Decode(const std::vector<Byte>& bytes, Reply* reply);
}  // namespace cps_windows
