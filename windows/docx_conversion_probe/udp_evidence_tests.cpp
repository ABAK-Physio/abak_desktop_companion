#include "udp_evidence.h"
#include <iostream>
#include <stdexcept>
#include <string>

int main() {
 using docx_probe::IsMatchingUdpDrop;
 const std::array<std::uint64_t,2> ids{{245287,245288}};
 docx_probe::UdpDropObservation valid;
 valid.required_fields_present=true; valid.classify_drop=true;
 valid.udp=true; valid.application_matches=true; valid.local_service=true;
 valid.remote_loopback=true; valid.family=0; valid.remote_port=9;
 valid.filter_id=ids[0]; valid.time=200;
 unsigned checked=0;
 auto expect=[&](const docx_probe::UdpDropObservation& observation,bool accepted) {
  ++checked;
  if(IsMatchingUdpDrop(observation,ids,100)!=accepted)
   throw std::runtime_error("Incorrect UDP evidence acceptance: case "+std::to_string(checked));
 };
 expect(valid,true);
 auto event=valid; event.family=1; event.filter_id=ids[1]; expect(event,true);
 event=valid; event.time=99; expect(event,false); // previous run
 event=valid; event.filter_id=ids[0]-4; expect(event,false); // previous filters
 event=valid; event.family=1; expect(event,false); // wrong address family/filter
 event=valid; event.family=-1; expect(event,false);
 event=valid; event.family=2; expect(event,false);
 event=valid; event.filter_id=0; expect(event,false);
 event=valid; event.required_fields_present=false; expect(event,false);
 event=valid; event.classify_drop=false; expect(event,false); // a permit is not proof
 event=valid; event.udp=false; expect(event,false); // TCP cannot stand in for UDP
 event=valid; event.application_matches=false; expect(event,false);
 event=valid; event.local_service=false; expect(event,false);
 event=valid; event.remote_loopback=false; expect(event,false);
 event=valid; event.remote_port=10; expect(event,false);
 const std::array<std::uint64_t,2> absent{{0,0}};
 if(IsMatchingUdpDrop(valid,absent,100)) throw std::runtime_error("Missing filters accepted");
 ++checked;
 const std::wstring nonce=L"0123456789abcdef0123456789abcdef";
 if(docx_probe::RunNonceAscii(nonce)!="0123456789abcdef0123456789abcdef")
  throw std::runtime_error("Run identity ASCII conversion changed the bytes");
 ++checked;
 auto reject_nonce=[&](const std::wstring& candidate) {
  ++checked;
  try { docx_probe::RunNonceAscii(candidate); }
  catch(const std::invalid_argument&) { return; }
  throw std::runtime_error("Invalid run identity accepted");
 };
 reject_nonce(L"");
 reject_nonce(nonce.substr(0,31));
 reject_nonce(nonce+L"0");
 reject_nonce(std::wstring(32,L'g'));
 reject_nonce(std::wstring(32,L'\u00e9'));
 std::cout<<"UDP evidence and run identity tests passed: "<<checked<<" cases.\n";
}
