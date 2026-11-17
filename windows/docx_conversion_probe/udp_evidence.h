#pragma once
#include <array>
#include <cstddef>
#include <cstdint>
#include <stdexcept>
#include <string>

namespace docx_probe {
inline std::string RunNonceAscii(const std::wstring& nonce) {
 if(nonce.size()!=32 || nonce.find_first_not_of(L"0123456789abcdef")!=std::wstring::npos)
  throw std::invalid_argument("Invalid hexadecimal run identity");
 std::string ascii;
 ascii.reserve(nonce.size());
 for(const wchar_t value:nonce) ascii.push_back(static_cast<char>(value));
 return ascii;
}
// Independent of Windows types so the acceptance rule can be tested directly.
struct UdpDropObservation {
 bool required_fields_present=false;
 bool classify_drop=false;
 bool udp=false;
 bool application_matches=false;
 bool local_service=false;
 bool remote_loopback=false;
 int family=-1; // 0 = IPv4, 1 = IPv6
 std::uint16_t remote_port=0;
 std::uint64_t filter_id=0;
 std::uint64_t time=0;
};
inline bool IsMatchingUdpDrop(const UdpDropObservation& event,
    const std::array<std::uint64_t,2>& outbound_filters,std::uint64_t started) {
 return event.required_fields_present && event.classify_drop && event.udp &&
     event.application_matches && event.local_service && event.remote_loopback &&
     event.remote_port==9 && event.family>=0 && event.family<2 &&
     outbound_filters[static_cast<std::size_t>(event.family)]!=0 &&
     event.filter_id==outbound_filters[static_cast<std::size_t>(event.family)] &&
     event.time>=started;
}
}
