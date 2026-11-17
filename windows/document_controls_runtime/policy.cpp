#include "policy.h"
#include <initguid.h>
#include <fwpmu.h>
#include <sddl.h>
#include <aclapi.h>
#include <array>
#include <cstring>
#include <cwchar>
#include <rpc.h>
#include <vector>
#include <shlobj.h>
#include <knownfolders.h>

namespace document_controls_runtime {
namespace {
const GUID Sub = {0x3ba2d7a1,0xea2f,0x4cd1,{0x88,0x19,0x7d,0xa2,0x76,0x61,0x2c,0x42}};
const GUID Keys[] = {
 {0x3ba2d7a2,0xea2f,0x4cd1,{0x88,0x19,0x7d,0xa2,0x76,0x61,0x2c,0x42}},
 {0x3ba2d7a3,0xea2f,0x4cd1,{0x88,0x19,0x7d,0xa2,0x76,0x61,0x2c,0x42}},
 {0x3ba2d7a4,0xea2f,0x4cd1,{0x88,0x19,0x7d,0xa2,0x76,0x61,0x2c,0x42}},
 {0x3ba2d7a5,0xea2f,0x4cd1,{0x88,0x19,0x7d,0xa2,0x76,0x61,0x2c,0x42}}};
const GUID* Layers[] = {&FWPM_LAYER_ALE_AUTH_CONNECT_V4,
 &FWPM_LAYER_ALE_AUTH_CONNECT_V6, &FWPM_LAYER_ALE_AUTH_RECV_ACCEPT_V4,
 &FWPM_LAYER_ALE_AUTH_RECV_ACCEPT_V6};
constexpr wchar_t Name[] = L"ABAK Companion local document controls";
struct Descriptor {
 PSECURITY_DESCRIPTOR value = nullptr;
 ~Descriptor() { if(value) LocalFree(value); }
};
bool SidDescriptor(Descriptor* descriptor) {
 std::wstring sid;
 if(!ServiceSid(&sid)) return false;
 const auto sddl = L"D:(A;;CC;;;" + sid + L")";
 return ConvertStringSecurityDescriptorToSecurityDescriptorW(sddl.c_str(),
     SDDL_REVISION_1, &descriptor->value, nullptr) != FALSE;
}
bool Failure(std::string* error, const char* where, DWORD code) {
 if(error) *error = std::string(where) + ": " + std::to_string(code);
 return false;
}
bool GrantsRead(HANDLE engine, const GUID& key, bool sub) {
 std::wstring text;
 PSID sid = nullptr;
 if(!ServiceSid(&text) || !ConvertStringSidToSidW(text.c_str(), &sid)) return false;
 PSECURITY_DESCRIPTOR old = nullptr; PACL acl = nullptr;
 DWORD code = sub ? FwpmSubLayerGetSecurityInfoByKey0(engine,&key,DACL_SECURITY_INFORMATION,
     nullptr,nullptr,&acl,nullptr,&old) : FwpmFilterGetSecurityInfoByKey0(engine,&key,
     DACL_SECURITY_INFORMATION,nullptr,nullptr,&acl,nullptr,&old);
 PACL updated = nullptr;
 if(code == ERROR_SUCCESS) {
  EXPLICIT_ACCESS_W grant{};
  grant.grfAccessPermissions = FWPM_ACTRL_READ;
  grant.grfAccessMode = GRANT_ACCESS;
  grant.Trustee.TrusteeForm = TRUSTEE_IS_SID;
  grant.Trustee.ptstrName = reinterpret_cast<LPWSTR>(sid);
  code = SetEntriesInAclW(1,&grant,acl,&updated);
  if(code == ERROR_SUCCESS) code = sub ? FwpmSubLayerSetSecurityInfoByKey0(engine,&key,
     DACL_SECURITY_INFORMATION,nullptr,nullptr,updated,nullptr) : FwpmFilterSetSecurityInfoByKey0(
     engine,&key,DACL_SECURITY_INFORMATION,nullptr,nullptr,updated,nullptr);
 }
 if(updated) LocalFree(updated);
 if(old) FwpmFreeMemory0(reinterpret_cast<void**>(&old));
 LocalFree(sid);
 return code == ERROR_SUCCESS;
}
bool GroupPresent(HANDLE token, TOKEN_INFORMATION_CLASS info, PSID sid) {
 DWORD bytes = 0;
 GetTokenInformation(token,info,nullptr,0,&bytes);
 if(!bytes || bytes > 65536) return false;
 std::vector<BYTE> storage(bytes);
 if(!GetTokenInformation(token,info,storage.data(),bytes,&bytes)) return false;
 const auto* groups = reinterpret_cast<const TOKEN_GROUPS*>(storage.data());
 for(DWORD i=0;i<groups->GroupCount;++i) {
  const auto& group = groups->Groups[i];
  if(EqualSid(group.Sid,sid) && (info == TokenRestrictedSids ||
     ((group.Attributes & SE_GROUP_ENABLED) && !(group.Attributes & SE_GROUP_USE_FOR_DENY_ONLY))))
   return true;
 }
 return false;
}
}

bool ServiceSid(std::wstring* text) {
 std::array<BYTE,SECURITY_MAX_SID_SIZE> buffer{};
 DWORD size = static_cast<DWORD>(buffer.size());
 std::array<wchar_t,256> domain{}; DWORD count=static_cast<DWORD>(domain.size());
 SID_NAME_USE use{};
 const auto name = std::wstring(L"NT SERVICE\\") + ServiceName;
 if(!LookupAccountNameW(nullptr,name.c_str(),buffer.data(),&size,domain.data(),&count,&use))
  return false;
 LPWSTR value=nullptr;
 if(!ConvertSidToStringSidW(buffer.data(),&value)) return false;
 text->assign(value); LocalFree(value);
 return text->compare(0,9,L"S-1-5-80-")==0;
}
bool CheckProcessToken(HANDLE process,bool restricted) {
 HANDLE token=nullptr;
 if(!OpenProcessToken(process,TOKEN_QUERY,&token)) return false;
 std::array<BYTE,256> storage{}; DWORD count=0;
 bool ok=GetTokenInformation(token,TokenUser,storage.data(),
     static_cast<DWORD>(storage.size()),&count) &&
     IsWellKnownSid(reinterpret_cast<TOKEN_USER*>(storage.data())->User.Sid,WinLocalServiceSid);
 std::wstring text; PSID sid=nullptr;
 ok=ok && ServiceSid(&text) && ConvertStringSidToSidW(text.c_str(),&sid);
 if(ok) ok=GroupPresent(token,TokenGroups,sid);
 if(ok && restricted) {
  ok=IsTokenRestricted(token) && GroupPresent(token,TokenRestrictedSids,sid);
  DWORD bytes=0;
  GetTokenInformation(token,TokenPrivileges,nullptr,0,&bytes);
  ok=ok && bytes>0 && bytes<=65536;
  std::vector<BYTE> privileges(ok?bytes:0);
  if(ok) ok=GetTokenInformation(token,TokenPrivileges,privileges.data(),bytes,&bytes)!=FALSE;
  LUID change_notify{};
  if(ok) ok=LookupPrivilegeValueW(nullptr,SE_CHANGE_NOTIFY_NAME,&change_notify)!=FALSE;
  if(ok) {
   const auto* values=reinterpret_cast<const TOKEN_PRIVILEGES*>(privileges.data());
   for(DWORD i=0;ok && i<values->PrivilegeCount;++i) {
    const auto& value=values->Privileges[i].Luid;
    ok=value.LowPart==change_notify.LowPart && value.HighPart==change_notify.HighPart;
   }
  }
 } else if(ok) ok=IsTokenRestricted(token)==FALSE;
 if(sid) LocalFree(sid);
 CloseHandle(token); return ok;
}
std::wstring WorkDirectory() {
 PWSTR raw=nullptr;
 if(FAILED(SHGetKnownFolderPath(FOLDERID_ProgramData,0,nullptr,&raw))) return {};
 const std::wstring value=std::wstring(raw)+L"\\ABAK\\DocumentControls\\work";
 CoTaskMemFree(raw); return value;
}
bool RemovePersistentPolicy(std::string* error) {
 HANDLE engine=nullptr;
 DWORD code=FwpmEngineOpen0(nullptr,RPC_C_AUTHN_WINNT,nullptr,nullptr,&engine);
 if(code!=ERROR_SUCCESS) return Failure(error,"Open WFP for removal",code);
 code=FwpmTransactionBegin0(engine,0);
 if(code==ERROR_SUCCESS) {
  for(const auto& key:Keys) {
   const DWORD removed=FwpmFilterDeleteByKey0(engine,&key);
   if(removed!=ERROR_SUCCESS && removed!=FWP_E_FILTER_NOT_FOUND) { code=removed; break; }
  }
  if(code==ERROR_SUCCESS) {
   const DWORD removed=FwpmSubLayerDeleteByKey0(engine,&Sub);
   if(removed!=ERROR_SUCCESS && removed!=FWP_E_SUBLAYER_NOT_FOUND) code=removed;
  }
  if(code==ERROR_SUCCESS) code=FwpmTransactionCommit0(engine);
  else FwpmTransactionAbort0(engine);
 }
 FwpmEngineClose0(engine);
 return code==ERROR_SUCCESS || Failure(error,"Remove installed WFP policy",code);
}
bool CheckBrokerToken(HANDLE process) { return CheckProcessToken(process,false); }
bool CheckServiceToken(HANDLE process) { return CheckProcessToken(process,true); }
bool InstallPersistentPolicy(std::string* error) {
 Descriptor descriptor;
 if(!SidDescriptor(&descriptor)) { Failure(error,"Service SID",GetLastError()); return false; }
 FWPM_SESSION0 session{}; session.flags=0;
 HANDLE engine=nullptr;
 DWORD code=FwpmEngineOpen0(nullptr,RPC_C_AUTHN_WINNT,nullptr,&session,&engine);
 if(code!=ERROR_SUCCESS) { Failure(error,"Open WFP",code); return false; }
 auto failed=[&](const char* where,DWORD status)->bool {
  Failure(error,where,status); FwpmEngineClose0(engine); return false;
 };
 code=FwpmTransactionBegin0(engine,0);
 if(code!=ERROR_SUCCESS) return failed("Begin WFP",code);
 FWPM_SUBLAYER0 sub{}; sub.subLayerKey=Sub;
 sub.displayData.name=const_cast<wchar_t*>(Name); sub.weight=0x100;
 sub.flags=FWPM_SUBLAYER_FLAG_PERSISTENT;
 code=FwpmSubLayerAdd0(engine,&sub,nullptr);
 FWP_BYTE_BLOB sd{};
 sd.size=GetSecurityDescriptorLength(descriptor.value);
 sd.data=static_cast<UINT8*>(descriptor.value);
 for(std::size_t i=0;code==ERROR_SUCCESS && i<4;++i) {
  FWPM_FILTER_CONDITION0 condition{};
  condition.fieldKey=FWPM_CONDITION_ALE_USER_ID; condition.matchType=FWP_MATCH_EQUAL;
  condition.conditionValue.type=FWP_SECURITY_DESCRIPTOR_TYPE; condition.conditionValue.sd=&sd;
  FWPM_FILTER0 filter{}; filter.filterKey=Keys[i];
  filter.displayData.name=const_cast<wchar_t*>(Name);
  filter.flags=FWPM_FILTER_FLAG_PERSISTENT;
  filter.layerKey=*Layers[i]; filter.subLayerKey=Sub;
  filter.action.type=FWP_ACTION_BLOCK; filter.weight.type=FWP_EMPTY;
  filter.numFilterConditions=1; filter.filterCondition=&condition;
  code=FwpmFilterAdd0(engine,&filter,nullptr,nullptr);
 }
 if(code!=ERROR_SUCCESS) {
  FwpmTransactionAbort0(engine); return failed("Add installed WFP objects",code);
 }
 code=FwpmTransactionCommit0(engine);
 if(code!=ERROR_SUCCESS) return failed("Commit installed WFP",code);
 if(!GrantsRead(engine,Sub,true)) return failed("Grant WFP sublayer read",GetLastError());
 for(const auto& key:Keys)
  if(!GrantsRead(engine,key,false)) return failed("Grant WFP filter read",GetLastError());
 FwpmEngineClose0(engine);
 return true;
}
bool VerifyPolicy(std::string* error) {
 Descriptor descriptor;
 if(!SidDescriptor(&descriptor)) return Failure(error,"Resolve service policy SID",GetLastError());
 HANDLE engine=nullptr;
 DWORD code=FwpmEngineOpen0(nullptr,RPC_C_AUTHN_WINNT,nullptr,nullptr,&engine);
 if(code!=ERROR_SUCCESS) return Failure(error,"Read WFP",code);
 bool ok=true;
 FWPM_SUBLAYER0* sub=nullptr;
 code=FwpmSubLayerGetByKey0(engine,&Sub,&sub);
 ok=code==ERROR_SUCCESS && sub && sub->providerKey==nullptr &&
    sub->flags==FWPM_SUBLAYER_FLAG_PERSISTENT && sub->displayData.name && wcscmp(sub->displayData.name,Name)==0;
 if(sub) FwpmFreeMemory0(reinterpret_cast<void**>(&sub));
 for(std::size_t i=0;ok && i<4;++i) {
  FWPM_FILTER0* filter=nullptr;
  code=FwpmFilterGetByKey0(engine,&Keys[i],&filter);
  ok=code==ERROR_SUCCESS && filter && filter->providerKey==nullptr &&
      filter->flags==FWPM_FILTER_FLAG_PERSISTENT && filter->action.type==FWP_ACTION_BLOCK &&
      IsEqualGUID(filter->layerKey,*Layers[i]) && IsEqualGUID(filter->subLayerKey,Sub) &&
      filter->numFilterConditions==1 && filter->filterCondition;
  if(ok) {
   const auto& c=filter->filterCondition[0];
   ok=IsEqualGUID(c.fieldKey,FWPM_CONDITION_ALE_USER_ID) && c.matchType==FWP_MATCH_EQUAL &&
      c.conditionValue.type==FWP_SECURITY_DESCRIPTOR_TYPE && c.conditionValue.sd &&
      c.conditionValue.sd->data &&
      c.conditionValue.sd->size==GetSecurityDescriptorLength(descriptor.value) &&
      std::memcmp(c.conditionValue.sd->data,descriptor.value,c.conditionValue.sd->size)==0;
  }
  if(filter) FwpmFreeMemory0(reinterpret_cast<void**>(&filter));
 }
 FwpmEngineClose0(engine);
 return ok || Failure(error,"Installed service-scoped WFP policy incomplete",code);
}
bool OutboundFilterIds(HANDLE engine,std::array<std::uint64_t,2>* ids) {
 for(std::size_t i=0;i<ids->size();++i) {
  FWPM_FILTER0* filter=nullptr;
  const auto code=FwpmFilterGetByKey0(engine,&Keys[i],&filter);
  const bool ok=code==ERROR_SUCCESS && filter && filter->filterId!=0;
  if(ok) (*ids)[i]=filter->filterId;
  if(filter) FwpmFreeMemory0(reinterpret_cast<void**>(&filter));
  if(!ok) return false;
 }
 return true;
}
void ClosePolicy(HANDLE engine) { if(engine) FwpmEngineClose0(engine); }
}
