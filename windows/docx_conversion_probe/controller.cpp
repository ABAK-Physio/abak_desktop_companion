#include "policy.h"
#include "udp_evidence.h"
#include "../runner/document_controls_installation_security.h"
#include <fwpmu.h>
#include <sddl.h>
#include <bcrypt.h>
#include <algorithm>
#include <cstring>
#include <iostream>
#include <vector>
#include <cwchar>

namespace {
using document_controls::windows_ipc::OwnedHandle;
struct ScHandle {
 SC_HANDLE value=nullptr;
 ~ScHandle(){ if(value) CloseServiceHandle(value); }
};
struct Policy {
 HANDLE engine=nullptr;
 ~Policy(){ docx_probe::ClosePolicy(engine); }
};
bool Same(const wchar_t* a,const std::wstring& b) {
 return a && CompareStringOrdinal(a,-1,b.c_str(),-1,TRUE)==CSTR_EQUAL;
}
bool WaitStopped(SC_HANDLE service,DWORD timeout,SERVICE_STATUS_PROCESS* result) {
 const auto start=GetTickCount64();
 for(;;) {
  DWORD size=0;
  if(!QueryServiceStatusEx(service,SC_STATUS_PROCESS_INFO,reinterpret_cast<BYTE*>(result),
      sizeof(*result),&size)) return false;
  if(result->dwCurrentState==SERVICE_STOPPED) return true;
  if(GetTickCount64()-start>=timeout) return false;
  Sleep(250);
 }
}
std::uint64_t TimeValue(const FILETIME& value) {
 return (static_cast<std::uint64_t>(value.dwHighDateTime)<<32)|value.dwLowDateTime;
}
struct UdpProof {
 std::wstring nonce,path;
 OwnedHandle file;
 ~UdpProof() {
  file=OwnedHandle();
  if(!path.empty() && !DeleteFileW(path.c_str()))
   std::cerr<<"Temporary UDP evidence file retained: "<<GetLastError()<<'\n';
 }
 bool Initialize() {
  std::array<BYTE,16> random{};
  if(BCryptGenRandom(nullptr,random.data(),static_cast<ULONG>(random.size()),
      BCRYPT_USE_SYSTEM_PREFERRED_RNG)!=0) return false;
  constexpr wchar_t hex[]=L"0123456789abcdef";
  for(const auto value:random) {
   nonce.push_back(hex[value>>4]); nonce.push_back(hex[value&15]);
  }
  return true;
 }
 bool Publish() {
  std::wstring sid;
  if(!docx_probe::ServiceSid(&sid)) return false;
  // Only SYSTEM and administrators may write the acknowledgement. Service
  // has read access, independent of its writable work/evidence directory.
  const auto sddl=L"O:BAG:BAD:P(A;;FA;;;SY)(A;;FA;;;BA)(A;;FR;;;"+sid+L")";
  PSECURITY_DESCRIPTOR descriptor=nullptr;
  if(!ConvertStringSecurityDescriptorToSecurityDescriptorW(sddl.c_str(),SDDL_REVISION_1,
      &descriptor,nullptr)) return false;
  SECURITY_ATTRIBUTES security{sizeof(SECURITY_ATTRIBUTES),descriptor,FALSE};
  const auto candidate=std::wstring(docx_probe::Root)+L"\\network-proof-"+nonce+L".txt";
  const auto pending=candidate+L".pending";
  file=OwnedHandle(CreateFileW(pending.c_str(),GENERIC_WRITE,FILE_SHARE_READ,&security,
      CREATE_NEW,FILE_ATTRIBUTE_NORMAL,nullptr));
  LocalFree(descriptor);
  if(!file) return false;
  path=pending;
  const std::string text="UDP_WFP_IPV4_IPV6_CONFIRMED\r\n"+
      docx_probe::RunNonceAscii(nonce)+"\r\n";
  DWORD written=0;
  if(!WriteFile(file.get(),text.data(),static_cast<DWORD>(text.size()),&written,nullptr) ||
      written!=text.size() || !FlushFileBuffers(file.get())) return false;
  file=OwnedHandle();
  // Publish only a complete acknowledgement; do not expose a partly written
  // file or require readers to share a controller's write handle.
  if(!MoveFileExW(pending.c_str(),candidate.c_str(),MOVEFILE_WRITE_THROUGH)) return false;
  path=candidate;
  file=OwnedHandle(CreateFileW(path.c_str(),GENERIC_READ|READ_CONTROL,FILE_SHARE_READ,nullptr,
      OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
  return static_cast<bool>(file);
 }
};
bool CollectUdpDrops(HANDLE engine,const FILETIME& started,
    const std::array<std::uint64_t,2>& ids,std::array<bool,2>* seen,std::string* error) {
 const auto path=std::wstring(docx_probe::Root)+L"\\abak_docx_probe_service.exe";
 FWP_BYTE_BLOB* app=nullptr;
 DWORD code=FwpmGetAppIdFromFileName0(path.c_str(),&app);
 if(code!=ERROR_SUCCESS) { *error="Resolve probe app ID: "+std::to_string(code); return false; }
 struct BlobGuard {
  FWP_BYTE_BLOB* value;
  ~BlobGuard(){ FwpmFreeMemory0(reinterpret_cast<void**>(&value)); }
 } app_guard{app};
 std::array<FWPM_FILTER_CONDITION0,3> conditions{};
 conditions[0].fieldKey=FWPM_CONDITION_ALE_APP_ID;
 conditions[0].conditionValue.type=FWP_BYTE_BLOB_TYPE;
 conditions[0].conditionValue.byteBlob=app;
 conditions[1].fieldKey=FWPM_CONDITION_IP_PROTOCOL;
 conditions[1].conditionValue.type=FWP_UINT8;
 conditions[1].conditionValue.uint8=17;
 conditions[2].fieldKey=FWPM_CONDITION_IP_REMOTE_PORT;
 conditions[2].conditionValue.type=FWP_UINT16;
 conditions[2].conditionValue.uint16=9;
 for(auto& condition:conditions) condition.matchType=FWP_MATCH_EQUAL;
 FWPM_NET_EVENT_ENUM_TEMPLATE0 query{};
 query.startTime=started; GetSystemTimeAsFileTime(&query.endTime);
 query.numFilterConditions=static_cast<UINT32>(conditions.size());
 query.filterCondition=conditions.data();
 HANDLE enumeration=nullptr;
 code=FwpmNetEventCreateEnumHandle0(engine,&query,&enumeration);
 if(code!=ERROR_SUCCESS) { *error="Enumerate UDP evidence: "+std::to_string(code); return false; }
 struct EnumGuard {
  HANDLE engine,value;
  ~EnumGuard(){ FwpmNetEventDestroyEnumHandle0(engine,value); }
 } enumeration_guard{engine,enumeration};
 constexpr UINT32 flags=FWPM_NET_EVENT_FLAG_IP_PROTOCOL_SET|FWPM_NET_EVENT_FLAG_IP_VERSION_SET|
     FWPM_NET_EVENT_FLAG_REMOTE_ADDR_SET|FWPM_NET_EVENT_FLAG_REMOTE_PORT_SET|
     FWPM_NET_EVENT_FLAG_APP_ID_SET|FWPM_NET_EVENT_FLAG_USER_ID_SET;
 // Recreate the snapshot at each poll. Never accept earlier runs' events.
 for(unsigned page=0;page<64;++page) {
  FWPM_NET_EVENT0** events=nullptr; UINT32 count=0;
  code=FwpmNetEventEnum0(engine,enumeration,64,&events,&count);
  if(code!=ERROR_SUCCESS) {
   if(events) FwpmFreeMemory0(reinterpret_cast<void**>(&events));
   *error="Read UDP evidence: "+std::to_string(code); return false;
  }
  for(UINT32 index=0;index<count;++index) {
   const auto* event=events[index];
   if(!event) continue;
   const auto& h=event->header;
   docx_probe::UdpDropObservation observation;
   observation.required_fields_present=(h.flags&flags)==flags;
   observation.classify_drop=event->type==FWPM_NET_EVENT_TYPE_CLASSIFY_DROP && event->classifyDrop;
   observation.udp=h.ipProtocol==17;
   observation.application_matches=h.appId.data && h.appId.size==app->size &&
       std::memcmp(h.appId.data,app->data,app->size)==0;
   observation.local_service=h.userId && IsWellKnownSid(h.userId,WinLocalServiceSid);
   observation.remote_port=h.remotePort;
   observation.time=TimeValue(h.timeStamp);
   if(observation.classify_drop) observation.filter_id=event->classifyDrop->filterId;
   if(h.ipVersion==FWP_IP_VERSION_V4) {
    observation.family=0;
    observation.remote_loopback=h.remoteAddrV4==0x7f000001;
   } else if(h.ipVersion==FWP_IP_VERSION_V6) {
    observation.family=1;
    const auto& bytes=h.remoteAddrV6.byteArray16;
    observation.remote_loopback=std::all_of(bytes,bytes+15,[](UINT8 b){ return b==0; }) && bytes[15]==1;
   }
   if(docx_probe::IsMatchingUdpDrop(observation,ids,TimeValue(started))) {
    const auto family=static_cast<std::size_t>(observation.family);
    if(!(*seen)[family]) std::cout<<"UDP_WFP_DROP IPv"<<(family==0?4:6)
        <<" filterId="<<observation.filter_id<<" current_run=true\n";
    (*seen)[family]=true;
   }
  }
  if(events) FwpmFreeMemory0(reinterpret_cast<void**>(&events));
  if(count<64) return true;
 }
 *error="UDP evidence enumeration exceeded bounded size";
 return false;
}
bool AwaitUdpDrops(HANDLE engine,SC_HANDLE service,const FILETIME& started,
    const std::array<std::uint64_t,2>& ids,UdpProof* proof) {
 std::array<bool,2> seen{};
 const auto tick=GetTickCount64();
 while(GetTickCount64()-tick<60000) {
  std::string error;
  if(!CollectUdpDrops(engine,started,ids,&seen,&error)) {
   std::cerr<<error<<'\n'; return false;
  }
  if(seen[0] && seen[1]) {
   if(!docx_probe::VerifyPolicy(&error)) {
    std::cerr<<"Cannot authorize UDP gate: "<<error<<'\n'; return false;
   }
   if(!proof->Publish()) {
    std::cerr<<"Cannot publish protected UDP proof: "<<GetLastError()<<'\n'; return false;
   }
   std::cout<<"UDP_WFP_EVIDENCE=CONFIRMED_IPV4_IPV6_CURRENT_RUN\n";
   return true;
  }
  SERVICE_STATUS_PROCESS state{}; DWORD size=0;
  if(!QueryServiceStatusEx(service,SC_STATUS_PROCESS_INFO,reinterpret_cast<BYTE*>(&state),
      sizeof(state),&size) || state.dwCurrentState==SERVICE_STOPPED) return false;
  Sleep(100);
 }
 std::cerr<<"Current-run UDP drops not observed for both exact outbound filters.\n";
 return false;
}
}
int wmain(int argc,wchar_t* argv[]) {
 if(argc!=2 || wcscmp(argv[1],L"run")!=0) {
  std::cerr<<"Usage: abak_docx_probe_controller.exe run (administrator)\n";
  return 1;
 }
 ScHandle manager{OpenSCManagerW(nullptr,nullptr,SC_MANAGER_CONNECT)};
 ScHandle service{manager.value?OpenServiceW(manager.value,docx_probe::ServiceName,
    SERVICE_QUERY_CONFIG|SERVICE_QUERY_STATUS|SERVICE_START|SERVICE_STOP):nullptr};
 if(!service.value){ std::cerr<<"Dedicated service unavailable: "<<GetLastError()<<'\n'; return 2; }
 DWORD needed=0;
 QueryServiceConfigW(service.value,nullptr,0,&needed);
 if(!needed || needed>65536) return 3;
 std::vector<BYTE> storage(needed);
 auto* config=reinterpret_cast<QUERY_SERVICE_CONFIGW*>(storage.data());
 if(!QueryServiceConfigW(service.value,config,needed,&needed) ||
     config->dwServiceType!=SERVICE_WIN32_OWN_PROCESS ||
     !Same(config->lpBinaryPathName,std::wstring(L"\"")+docx_probe::Root+L"\\abak_docx_probe_service.exe\"") ||
     !Same(config->lpServiceStartName,L"NT AUTHORITY\\LocalService")) {
  std::cerr<<"Dedicated service configuration mismatch\n"; return 4;
 }
 SERVICE_SID_INFO sid{};
 if(!QueryServiceConfig2W(service.value,SERVICE_CONFIG_SERVICE_SID_INFO,
    reinterpret_cast<BYTE*>(&sid),sizeof(sid),&needed) || sid.dwServiceSidType!=SERVICE_SID_TYPE_UNRESTRICTED) {
  std::cerr<<"Preparation service must use LocalService with enabled service SID; workers are restricted explicitly.\n"; return 5;
 }
 const auto path=std::wstring(docx_probe::Root)+L"\\abak_docx_probe_service.exe";
 OwnedHandle image(CreateFileW(path.c_str(),GENERIC_READ|READ_CONTROL,FILE_SHARE_READ,nullptr,
     OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 std::vector<OwnedHandle> directories;
 const auto protection=document_controls::windows_ipc::VerifyProtectedFile(image.get(),path,&directories);
 if(!image || protection){ std::cerr<<"Probe service installation is not protected\n"; return 6; }
 SERVICE_STATUS_PROCESS state{}; DWORD size=0;
 if(!QueryServiceStatusEx(service.value,SC_STATUS_PROCESS_INFO,reinterpret_cast<BYTE*>(&state),
     sizeof(state),&size) || state.dwCurrentState!=SERVICE_STOPPED) {
  std::cerr<<"Dedicated service must be stopped before this test\n"; return 7;
 }
 std::string error;
 Policy policy{docx_probe::InstallTemporaryPolicy(&error)};
 if(!policy.engine || !docx_probe::VerifyPolicy(&error)) {
  std::cerr<<"Temporary WFP setup refused: "<<error<<'\n'; return 8;
 }
 std::cout<<"Temporary WFP filters installed for dedicated service SID only.\n";
 std::cout<<"PREPARATION_PROFILE=LOCALSERVICE_SERVICE_SID_ENABLED\n"
          <<"WORKERS=WRITE_RESTRICTED_SERVICE_PLUS_WORLD_PRIVILEGES_REMOVED\n";
 std::array<std::uint64_t,2> outbound_ids{};
 UdpProof proof;
 if(!docx_probe::OutboundFilterIds(policy.engine,&outbound_ids) || !proof.Initialize()) {
  std::cerr<<"Cannot prepare current-run UDP evidence gate.\n"; return 12;
 }
 FILETIME started{}; GetSystemTimeAsFileTime(&started);
 const wchar_t* arguments[]={proof.nonce.c_str()};
 if(!StartServiceW(service.value,1,arguments)) {
  std::cerr<<"StartService failed: "<<GetLastError()<<'\n'; return 9;
 }
 if(!AwaitUdpDrops(policy.engine,service.value,started,outbound_ids,&proof)) {
  SERVICE_STATUS stopped{};
  ControlService(service.value,SERVICE_CONTROL_STOP,&stopped);
  WaitStopped(service.value,10000,&state);
  std::cerr<<"UDP evidence gate refused; conversion not authorized.\n"; return 13;
 }
 // GUI/network probe (40 s), startup check (30 s), conversion (120 s)
 // plus preparation; the PowerShell controller deadline remains 300 s.
 if(!WaitStopped(service.value,240000,&state)) {
  SERVICE_STATUS stopped{};
  ControlService(service.value,SERVICE_CONTROL_STOP,&stopped);
  WaitStopped(service.value,10000,&state);
  std::cerr<<"Probe timed out; service stop requested.\n"; return 10;
 }
 if(state.dwWin32ExitCode!=ERROR_SUCCESS) {
  std::cerr<<"Service probe failed: "<<state.dwWin32ExitCode<<". Read private result.txt.\n";
  return 11;
 }
 std::cout<<"SYNTHETIC SERVICE CONVERSION PASSED. PDF/A validation still required.\n"
          <<"Temporary WFP rules are removed when this controller exits.\n";
 return 0;
}
