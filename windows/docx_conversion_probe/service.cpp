#include <winsock2.h>
#include <ws2tcpip.h>
#include <sddl.h>
#include "policy.h"
#include "udp_evidence.h"
#include "office_console_engine.h"
#include "file_access_probe.h"
#include "../runner/document_controls_office_engine.h"
#include "../runner/document_controls_docx_plan.h"
#include <array>
#include <fstream>
#include <map>
#include <stdexcept>
#include <vector>
#include <cstring>
#include <thread>
#include <exception>
#include <cstddef>

namespace {
using document_controls::windows_ipc::OwnedHandle;
using document_controls::windows_ipc::VerifyProtectedFile;
SERVICE_STATUS_HANDLE status_handle=nullptr;
HANDLE stop_event=nullptr;
SERVICE_STATUS status{};

void Require(bool ok,const char* message) {
 if(!ok) throw std::runtime_error(message);
}
void Report(DWORD state,DWORD code=ERROR_SUCCESS) {
 status.dwServiceType=SERVICE_WIN32_OWN_PROCESS;
 status.dwCurrentState=state;
 status.dwControlsAccepted=state==SERVICE_RUNNING?SERVICE_ACCEPT_STOP:0;
 status.dwWin32ExitCode=code;
 SetServiceStatus(status_handle,&status);
}
DWORD WINAPI Control(DWORD control,DWORD,LPVOID,LPVOID) {
 if(control==SERVICE_CONTROL_STOP) {
  if(stop_event) SetEvent(stop_event);
  return NO_ERROR;
 }
 return control==SERVICE_CONTROL_INTERROGATE?NO_ERROR:ERROR_CALL_NOT_IMPLEMENTED;
}
void WriteText(const std::wstring& path,const std::string& text) {
 OwnedHandle file(CreateFileW(path.c_str(),GENERIC_WRITE,FILE_SHARE_READ,nullptr,
     CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,nullptr));
 Require(static_cast<bool>(file),"Cannot create private evidence file");
 DWORD written=0;
 Require(text.size()<=1024*1024 && WriteFile(file.get(),text.data(),
     static_cast<DWORD>(text.size()),&written,nullptr) && written==text.size(),
     "Cannot write private evidence");
}
std::vector<BYTE> ReadInput(const std::wstring& path) {
 OwnedHandle file(CreateFileW(path.c_str(),GENERIC_READ|READ_CONTROL,FILE_SHARE_READ,
     nullptr,OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 Require(static_cast<bool>(file),"Synthetic input unavailable");
 std::vector<OwnedHandle> directories;
 const auto error=VerifyProtectedFile(file.get(),path,&directories);
 if(error) throw std::runtime_error(error.code+": "+error.message);
 LARGE_INTEGER size{};
 Require(GetFileSizeEx(file.get(),&size) && size.QuadPart>0 && size.QuadPart<=20*1024*1024,
     "Synthetic input size invalid");
 std::vector<BYTE> data(static_cast<std::size_t>(size.QuadPart));
 DWORD read=0;
 Require(ReadFile(file.get(),data.data(),static_cast<DWORD>(data.size()),&read,nullptr) &&
     read==data.size(),"Cannot read synthetic input");
 return data;
}
void WriteBytes(const std::wstring& path,const std::vector<BYTE>& data) {
 OwnedHandle file(CreateFileW(path.c_str(),GENERIC_WRITE,0,nullptr,CREATE_NEW,
     FILE_ATTRIBUTE_NORMAL,nullptr));
 DWORD written=0;
 Require(file && WriteFile(file.get(),data.data(),static_cast<DWORD>(data.size()),
     &written,nullptr) && written==data.size(),"Cannot copy synthetic DOCX");
}
struct NetworkProbeResult {
 bool synchronousDenied=false;
 bool submitted=false;
 std::string diagnostic;
};
NetworkProbeResult DeniedLoopback(int family,int type) {
 const std::string label=std::string(family==AF_INET?"IPv4":"IPv6")+
     (type==SOCK_STREAM?" TCP":" UDP");
 WSASetLastError(0);
 const SOCKET socket_handle=socket(family,type,0);
 if(socket_handle==INVALID_SOCKET) {
  return {false,false,label+" stage=socket result=INVALID_SOCKET error="+
      std::to_string(WSAGetLastError())+" synchronousDenied=false"};
 }
 WSASetLastError(0);
 int result=0;
 if(family==AF_INET) {
  sockaddr_in target{}; target.sin_family=AF_INET; target.sin_port=htons(9);
  target.sin_addr.s_addr=htonl(INADDR_LOOPBACK);
  result=type==SOCK_STREAM ? connect(socket_handle,reinterpret_cast<sockaddr*>(&target),static_cast<int>(sizeof(target))) :
      sendto(socket_handle,"ABAK synthetic probe",20,0,reinterpret_cast<sockaddr*>(&target),static_cast<int>(sizeof(target)));
 } else {
  sockaddr_in6 target{}; target.sin6_family=AF_INET6; target.sin6_port=htons(9);
  target.sin6_addr=in6addr_loopback;
  result=type==SOCK_STREAM ? connect(socket_handle,reinterpret_cast<sockaddr*>(&target),static_cast<int>(sizeof(target))) :
      sendto(socket_handle,"ABAK synthetic probe",20,0,reinterpret_cast<sockaddr*>(&target),static_cast<int>(sizeof(target)));
 }
 const int error=result==SOCKET_ERROR?WSAGetLastError():0;
 closesocket(socket_handle);
 const bool denied=result==SOCKET_ERROR && error==WSAEACCES;
 return {denied,denied || result==20,label+(type==SOCK_STREAM?" stage=connect":" stage=sendto")+
     " result="+std::to_string(result)+" error="+std::to_string(error)+
     " synchronousDenied="+(denied?"true":"false")};
}
void AwaitUdpProof(const std::wstring& nonce) {
 const auto path=std::wstring(docx_probe::Root)+L"\\network-proof-"+nonce+L".txt";
 const std::string expected="UDP_WFP_IPV4_IPV6_CONFIRMED\r\n"+
     docx_probe::RunNonceAscii(nonce)+"\r\n";
 const auto started=GetTickCount64();
 while(GetTickCount64()-started<25000) {
  Require(WaitForSingleObject(stop_event,0)==WAIT_TIMEOUT,"Stopped while awaiting UDP evidence");
  if(GetFileAttributesW(path.c_str())!=INVALID_FILE_ATTRIBUTES) {
   const auto proof=ReadInput(path);
   if(std::string(proof.begin(),proof.end())==expected) return;
  }
  Sleep(100);
 }
 throw std::runtime_error("Current-run WFP UDP drop evidence not confirmed; conversion not started");
}
void ProbeNetwork(const std::wstring& nonce) {
 const auto path=std::wstring(docx_probe::Work)+L"\\network-probes.txt";
 WSADATA data{};
 const int startup=WSAStartup(MAKEWORD(2,2),&data);
 std::string diagnostic="WSAStartup="+std::to_string(startup)+"\r\n";
 WriteText(path,diagnostic);
 Require(startup==0,"Winsock unavailable");
 bool ok=true;
 // TCP requires synchronous WSAEACCES. UDP sendto can succeed even though
 // WFP drops the datagram: require independently observed current-run drops
 // from both exact temporary outbound filters before allowing conversion.
 for(const auto& request:std::array<std::array<int,2>,4>{{
     {{AF_INET,SOCK_STREAM}},{{AF_INET6,SOCK_STREAM}},
     {{AF_INET,SOCK_DGRAM}},{{AF_INET6,SOCK_DGRAM}}}}) {
  const auto result=DeniedLoopback(request[0],request[1]);
  ok=(request[1]==SOCK_STREAM?result.synchronousDenied:result.submitted) && ok;
  diagnostic+=result.diagnostic+"\r\n";
  WriteText(path,diagnostic);
 }
 WSACleanup();
 Require(ok,"Network probe setup or TCP denial failed; conversion not started");
 diagnostic+="UDP_WFP_EVIDENCE=WAITING_FOR_CONTROLLER\r\n";
 WriteText(path,diagnostic);
 AwaitUdpProof(nonce);
 diagnostic+="UDP_WFP_EVIDENCE=CONFIRMED_IPV4_IPV6_CURRENT_RUN\r\n";
 WriteText(path,diagnostic);
}
std::vector<wchar_t> Environment(const std::wstring& job,const std::wstring& executable) {
 std::array<wchar_t,32768> windows{};
 const auto length=GetWindowsDirectoryW(windows.data(),static_cast<UINT>(windows.size()));
 Require(length>0 && length<windows.size(),"Windows directory unavailable");
 const std::wstring win(windows.data(),length);
 std::map<std::wstring,std::wstring> values{
   {L"APPDATA",job+L"\\appdata"},{L"LOCALAPPDATA",job+L"\\localdata"},
   {L"PATH",executable.substr(0,executable.find_last_of(L'\\'))+L";"+win+L"\\System32"},
   {L"PYTHONDONTWRITEBYTECODE",L"1"},{L"SystemRoot",win},
   {L"SAL_LOG",L"+WARN+INFO.vcl.plugadapt+INFO.sal.osl"},
   {L"TEMP",job},{L"TMP",job},{L"USERPROFILE",job},{L"windir",win}};
 std::vector<wchar_t> block;
 for(const auto& item:values) {
  const auto entry=item.first+L"="+item.second;
  block.insert(block.end(),entry.begin(),entry.end()); block.push_back(L'\0');
 }
 block.push_back(L'\0'); return block;
}
std::string Utf8(const std::wstring& value) {
 if(value.empty()) return {};
 Require(value.size()<32768,"Diagnostic text too long");
 const int length=static_cast<int>(value.size());
 const int bytes=WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,value.data(),length,
     nullptr,0,nullptr,nullptr);
 Require(bytes>0,"Cannot encode launch diagnostic");
 std::string result(static_cast<std::size_t>(bytes),'\0');
 Require(WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,value.data(),length,
     result.data(),bytes,nullptr,nullptr)==bytes,"Cannot encode launch diagnostic");
 return result;
}
std::string UserObjectName(HANDLE object) {
 if(!object) return "UNAVAILABLE error="+std::to_string(GetLastError());
 DWORD bytes=0;
 GetUserObjectInformationW(object,UOI_NAME,nullptr,0,&bytes);
 if(!bytes || bytes>65536) return "UNAVAILABLE error="+std::to_string(GetLastError());
 std::vector<wchar_t> name((bytes+sizeof(wchar_t)-1)/sizeof(wchar_t),L'\0');
 if(!GetUserObjectInformationW(object,UOI_NAME,name.data(),bytes,&bytes))
  return "UNAVAILABLE error="+std::to_string(GetLastError());
 return Utf8(name.data());
}
std::string SelfTokenAccessDiagnostic() {
 // Request handles only: no token duplication, impersonation, ACL change,
 // privilege adjustment or fallback identity. Failures remain observations.
 struct Request { const char* name; DWORD access; };
 const std::array<Request,5> requests{{
   {"QUERY",TOKEN_QUERY},
   {"READ_CONTROL",TOKEN_QUERY|READ_CONTROL},
   {"DUPLICATE",TOKEN_QUERY|TOKEN_DUPLICATE},
   {"IMPERSONATE",TOKEN_QUERY|TOKEN_IMPERSONATE},
   {"ADJUST_DEFAULT",TOKEN_QUERY|TOKEN_ADJUST_DEFAULT}}};
 std::string text="SELF_TOKEN_ACCESS=OBSERVATION_ONLY\r\n";
 for(const auto& request:requests) {
  HANDLE raw=nullptr;
  SetLastError(ERROR_SUCCESS);
  const BOOL opened=OpenProcessToken(GetCurrentProcess(),request.access,&raw);
  const DWORD error=opened?ERROR_SUCCESS:GetLastError();
  OwnedHandle token(raw);
  text+=std::string("SELF_TOKEN_")+request.name+"="+(opened?"OK":"FAIL")+
      " error="+std::to_string(error)+"\r\n";
 }
 return text;
}
std::string HexExitCode(DWORD code) {
 constexpr char digits[]="0123456789ABCDEF";
 std::string text="0x00000000";
 for(unsigned i=0;i<8;++i) text[9-i]=digits[(code>>(i*4))&15];
 return text;
}
std::string WindowDiagnostic(bool* created=nullptr) {
 if(created) *created=false;
 std::string text="WINDOWSTATION="+UserObjectName(GetProcessWindowStation())+"\r\n";
 text+="DESKTOP="+UserObjectName(GetThreadDesktop(GetCurrentThreadId()))+"\r\n";
 // Diagnostic only: a hidden tool window on the service's current desktop.
 // No visible window, input-desktop switch, or interactive service.
 constexpr wchar_t name[]=L"ABAKDocxProbeHiddenWindowCheck";
 WNDCLASSEXW window_class{}; window_class.cbSize=sizeof(window_class);
 window_class.style=CS_OWNDC; window_class.lpfnWndProc=DefWindowProcW;
 window_class.hInstance=GetModuleHandleW(nullptr); window_class.lpszClassName=name;
 SetLastError(ERROR_SUCCESS);
 const ATOM atom=RegisterClassExW(&window_class);
 const DWORD register_error=atom?ERROR_SUCCESS:GetLastError();
 text+="RegisterClassExW="+std::string(atom?"OK":"FAIL")+
     " error="+std::to_string(register_error)+"\r\n";
 if(!atom) return text;
 SetLastError(ERROR_SUCCESS);
 const HWND window=CreateWindowExW(WS_EX_TOOLWINDOW,name,L"",WS_POPUP,0,0,0,0,
     nullptr,nullptr,window_class.hInstance,nullptr);
 const DWORD create_error=window?ERROR_SUCCESS:GetLastError();
 text+="CreateWindowExW="+std::string(window?"OK":"FAIL")+
     " error="+std::to_string(create_error)+"\r\n";
 if(window) {
  const bool destroyed=DestroyWindow(window)!=FALSE;
  if(created) *created=destroyed;
 }
 UnregisterClassW(name,window_class.hInstance);
 return text;
}
class PrivateDesktop {
 public:
 PrivateDesktop()=default;
 PrivateDesktop(const PrivateDesktop&)=delete;
 PrivateDesktop& operator=(const PrivateDesktop&)=delete;
 ~PrivateDesktop() {
  if(desktop_) {
   if(previous_) SetThreadDesktop(previous_);
   CloseDesktop(desktop_);
  }
 }
 const std::wstring& path() const { return path_; }
 void Prepare(const std::wstring& nonce) {
  const auto journal=std::wstring(docx_probe::Work)+L"\\office-diagnostic.txt";
 std::string diagnostic="OFFICE_DIAGNOSTIC=v12\r\n";
  auto checked=[&](bool ok,const char* stage) {
   const DWORD error=ok?ERROR_SUCCESS:GetLastError();
   diagnostic+=std::string(stage)+"="+(ok?"OK":"FAIL")+
       " error="+std::to_string(error)+"\r\n";
   WriteText(journal,diagnostic);
   if(!ok) throw std::runtime_error(std::string(stage)+" failed: "+std::to_string(error));
  };
  // A named window station requires administrator rights. Retain the
  // service's NONINTERACTIVE station and create just one private desktop.
  const auto station=GetProcessWindowStation();
  USEROBJECTFLAGS flags{}; DWORD bytes=0;
  checked(station && GetUserObjectInformationW(station,UOI_FLAGS,&flags,sizeof(flags),&bytes),
      "ReadWindowStationFlags");
  Require((flags.dwFlags&WSF_VISIBLE)==0,"Interactive window station refused");
  previous_=GetThreadDesktop(GetCurrentThreadId());
  checked(previous_!=nullptr,"GetOriginalThreadDesktop");
  const auto station_name=UserObjectName(station);
  Require(station_name.find("UNAVAILABLE")==std::string::npos,"Cannot name service window station");
  // Station names formed by the service logon LUID are ASCII.
  Require(station_name.find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_$")==
      std::string::npos,"Unexpected service window station name");
  std::wstring wide_station;
  for(const unsigned char value:station_name) wide_station.push_back(static_cast<wchar_t>(value));
  (void)docx_probe::RunNonceAscii(nonce);
  const auto name=L"ABAKDocxProbe_"+nonce;
  std::wstring sid;
  checked(docx_probe::ServiceSid(&sid),"ResolvePrivateDesktopServiceSid");
  // The service receives GUI operations only on this new desktop. No
  // LocalService-wide grant, no inherited ACL, no change to Default.
  // Owner Rights removes the creator account's implicit WRITE_DAC grant.
  const auto sddl=L"D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;0x000200cf;;;"+sid+L")(A;;RC;;;OW)";
  PSECURITY_DESCRIPTOR raw_descriptor=nullptr;
  checked(ConvertStringSecurityDescriptorToSecurityDescriptorW(sddl.c_str(),SDDL_REVISION_1,
      &raw_descriptor,nullptr)!=FALSE,"CreatePrivateDesktopDescriptor");
  struct Descriptor {
   PSECURITY_DESCRIPTOR value;
   ~Descriptor(){ LocalFree(value); }
  } descriptor{raw_descriptor};
  SECURITY_ATTRIBUTES security{sizeof(SECURITY_ATTRIBUTES),descriptor.value,FALSE};
  constexpr DWORD access=READ_CONTROL|DESKTOP_CREATEWINDOW|DESKTOP_CREATEMENU|
      DESKTOP_READOBJECTS|DESKTOP_WRITEOBJECTS|DESKTOP_ENUMERATE|DESKTOP_HOOKCONTROL;
  static_assert(access==0x000200cf,"Private desktop mask must match its DACL");
  desktop_=CreateDesktopExW(name.c_str(),nullptr,nullptr,0,access,&security,4096,nullptr);
  checked(desktop_!=nullptr,"CreatePrivateDesktop");
  path_=wide_station+L"\\"+name;
  checked(SetThreadDesktop(desktop_)!=FALSE,"AssignPrivateThreadDesktop");
  Require(UserObjectName(GetThreadDesktop(GetCurrentThreadId()))==Utf8(name),
      "Unexpected conversion worker desktop");
  diagnostic+="PRIVATE_DESKTOP="+Utf8(path_)+"\r\nPRIVATE_DESKTOP_HEAP_KIB=4096\r\n";
  WriteText(journal,diagnostic);
 }
 void Restore() {
  if(desktop_) {
   Require(SetThreadDesktop(previous_)!=FALSE,"Cannot restore conversion worker desktop");
   Require(CloseDesktop(desktop_)!=FALSE,"Cannot close private conversion desktop");
   desktop_=nullptr;
  }
 }
 private:
 HDESK previous_=nullptr; // Borrowed, never closed.
 HDESK desktop_=nullptr;
 std::wstring path_;
};
std::vector<BYTE> TokenSidData(HANDLE token,TOKEN_INFORMATION_CLASS kind) {
 DWORD bytes=0;
 GetTokenInformation(token,kind,nullptr,0,&bytes);
 Require(bytes>=sizeof(TOKEN_GROUPS) && bytes<=65536,"Token SID information size unavailable");
 std::vector<BYTE> storage(bytes);
 Require(GetTokenInformation(token,kind,storage.data(),bytes,&bytes)!=FALSE,
     "Cannot read token SID information");
 const auto* groups=reinterpret_cast<const TOKEN_GROUPS*>(storage.data());
 const auto offset=offsetof(TOKEN_GROUPS,Groups);
 Require(groups->GroupCount>0 && groups->GroupCount<=64 && bytes>=offset &&
     groups->GroupCount<=(bytes-offset)/sizeof(SID_AND_ATTRIBUTES),"Invalid token SID list");
 for(DWORD i=0;i<groups->GroupCount;++i)
  Require(IsValidSid(groups->Groups[i].Sid)!=FALSE,"Invalid token SID");
 return storage;
}
void VerifyRestrictedSidSet(HANDLE token,const std::vector<SID_AND_ATTRIBUTES>& expected) {
 const auto storage=TokenSidData(token,TokenRestrictedSids);
 const auto* groups=reinterpret_cast<const TOKEN_GROUPS*>(storage.data());
 Require(groups->GroupCount==expected.size(),"Unexpected number of restricting SIDs");
 std::vector<bool> found(expected.size(),false);
 for(DWORD i=0;i<groups->GroupCount;++i) {
  bool matched=false;
  for(std::size_t j=0;j<expected.size();++j) {
   if(!found[j] && EqualSid(groups->Groups[i].Sid,expected[j].Sid)) {
    found[j]=true; matched=true; break;
   }
  }
  Require(matched,"Unexpected or duplicate restricting SID");
 }
}
std::string RecheckChildSidSet(HANDLE parent_token,HANDLE child_process) {
 const auto expected_storage=TokenSidData(parent_token,TokenRestrictedSids);
 const auto* groups=reinterpret_cast<const TOKEN_GROUPS*>(expected_storage.data());
 const std::vector<SID_AND_ATTRIBUTES> expected(groups->Groups,groups->Groups+groups->GroupCount);
 HANDLE raw=nullptr;
 Require(OpenProcessToken(child_process,TOKEN_QUERY,&raw)!=FALSE,"Cannot inspect child SID set");
 OwnedHandle child_token(raw);
 VerifyRestrictedSidSet(child_token.get(),expected);
 std::string text="RESTRICTING_SIDS=";
 for(std::size_t i=0;i<expected.size();++i) {
  LPWSTR sid_text=nullptr;
  Require(ConvertSidToStringSidW(expected[i].Sid,&sid_text)!=FALSE,"Cannot describe restricting SID");
  struct Text {LPWSTR value;~Text(){LocalFree(value);}} value{sid_text};
  if(i) text+=",";
  text+=Utf8(sid_text);
 }
 return text+"\r\n";
}
OwnedHandle RestrictedWorkerToken() {
 HANDLE raw_parent=nullptr;
 Require(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY|TOKEN_DUPLICATE|TOKEN_ASSIGN_PRIMARY|TOKEN_ADJUST_DEFAULT,
     &raw_parent)!=FALSE,"Cannot open preparation token for restriction");
 OwnedHandle parent(raw_parent);
 std::wstring text; PSID raw_sid=nullptr;
 Require(docx_probe::ServiceSid(&text) && ConvertStringSidToSidW(text.c_str(),&raw_sid),
     "Cannot resolve worker restricting SID");
 struct Sid {
  PSID value;
  ~Sid(){ LocalFree(value); }
 } sid{raw_sid};
 Sid world{nullptr};
 Require(ConvertStringSidToSidW(L"S-1-1-0",&world.value)!=FALSE,"Cannot resolve World compatibility SID");
 std::vector<SID_AND_ATTRIBUTES> restricting{{sid.value,0},{world.value,0}};
 HANDLE raw_worker=nullptr;
 const BOOL created=CreateRestrictedToken(parent.get(),DISABLE_MAX_PRIVILEGE|WRITE_RESTRICTED,
     0,nullptr,0,nullptr,static_cast<DWORD>(restricting.size()),restricting.data(),&raw_worker);
 const DWORD error=created?ERROR_SUCCESS:GetLastError();
 OwnedHandle worker(raw_worker);
 if(!created) throw std::runtime_error("CreateRestrictedToken failed: "+std::to_string(error));
 Require(IsTokenRestricted(worker.get())!=FALSE,"Worker token is not restricted");
 VerifyRestrictedSidSet(worker.get(),restricting);
 // Events, mutexes and descendants created by the worker must also grant
 // access to the restricting SID. Do not copy a LocalService-wide default.
 const auto sddl=L"D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GA;;;"+text+L")(A;;RC;;;OW)";
 PSECURITY_DESCRIPTOR raw_descriptor=nullptr;
 Require(ConvertStringSecurityDescriptorToSecurityDescriptorW(sddl.c_str(),SDDL_REVISION_1,
     &raw_descriptor,nullptr)!=FALSE,"Cannot prepare restricted worker default DACL");
 struct Descriptor {
  PSECURITY_DESCRIPTOR value;
  ~Descriptor(){ LocalFree(value); }
 } descriptor{raw_descriptor};
 BOOL present=FALSE,defaulted=FALSE; PACL acl=nullptr;
 Require(GetSecurityDescriptorDacl(descriptor.value,&present,&acl,&defaulted) && present && acl,
     "Restricted worker default DACL unavailable");
 TOKEN_DEFAULT_DACL defaults{acl};
 Require(SetTokenInformation(worker.get(),TokenDefaultDacl,&defaults,sizeof(defaults))!=FALSE,
     "Cannot set restricted worker default DACL");
 return worker;
}
void RunRestrictedProcess(const std::wstring& executable,std::wstring command,
    const std::wstring& working_directory,std::wstring desktop_path,HANDLE token,
    const wchar_t* capture_name,DWORD timeout,bool office,bool startup_check=false) {
 std::string policy_error;
 if(!docx_probe::VerifyPolicy(&policy_error)) throw std::runtime_error(policy_error);
 OwnedHandle job(CreateJobObjectW(nullptr,nullptr));
 JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
 limits.BasicLimitInformation.LimitFlags=JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE |
     JOB_OBJECT_LIMIT_ACTIVE_PROCESS | JOB_OBJECT_LIMIT_JOB_MEMORY;
 limits.BasicLimitInformation.ActiveProcessLimit=16;
 limits.JobMemoryLimit=1024ULL*1024*1024;
 Require(job && SetInformationJobObject(job.get(),JobObjectExtendedLimitInformation,&limits,
     sizeof(limits)),"Cannot restrict process job");
 SECURITY_ATTRIBUTES security{sizeof(SECURITY_ATTRIBUTES),nullptr,TRUE};
 OwnedHandle output(CreateFileW((working_directory+L"\\"+capture_name).c_str(),
     GENERIC_READ|GENERIC_WRITE,FILE_SHARE_READ,&security,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,nullptr));
 OwnedHandle input(CreateFileW(L"NUL",GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,
     &security,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr));
 Require(output && input,"Cannot create bounded process capture");
 SIZE_T bytes=0;
 InitializeProcThreadAttributeList(nullptr,1,0,&bytes);
 Require(bytes>0,"Process attribute size unavailable");
 std::vector<BYTE> memory(bytes);
 const auto attributes=reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(memory.data());
 Require(InitializeProcThreadAttributeList(attributes,1,0,&bytes)!=FALSE,
     "Process attributes unavailable");
 struct Attributes {
  LPPROC_THREAD_ATTRIBUTE_LIST value;
  ~Attributes(){ DeleteProcThreadAttributeList(value); }
 } guard{attributes};
 HANDLE handles[]={output.get(),input.get()};
 Require(UpdateProcThreadAttribute(attributes,0,PROC_THREAD_ATTRIBUTE_HANDLE_LIST,
     handles,sizeof(handles),nullptr,nullptr)!=FALSE,"Cannot restrict inherited handles");
 STARTUPINFOEXW startup{};
 startup.StartupInfo.cb=sizeof(startup); startup.lpAttributeList=attributes;
 startup.StartupInfo.dwFlags=STARTF_USESTDHANDLES;
 startup.StartupInfo.hStdInput=input.get();
 startup.StartupInfo.hStdOutput=output.get(); startup.StartupInfo.hStdError=output.get();
 startup.StartupInfo.lpDesktop=desktop_path.data();
 auto environment=Environment(working_directory,executable);
 const auto diagnostic_path=std::wstring(docx_probe::Work)+(office?
     (startup_check?L"\\office-startup-diagnostic.txt":L"\\office-diagnostic.txt"):
     L"\\restricted-launch-diagnostic.txt");
 std::string diagnostic="PROCESS_DIAGNOSTIC=v12\r\n";
 diagnostic+=std::string("PURPOSE=")+(office?
     (startup_check?"LIBREOFFICE_VERSION_ONLY":"LIBREOFFICE_SYNTHETIC_CONVERSION"):
     "RESTRICTED_NETWORK_GUI_PROBE")+"\r\n";
 diagnostic+="DEBUGGER=NOT_REQUESTED\r\nTOKEN_PROFILE=SERVICE_PLUS_WORLD\r\n";
 diagnostic+="PRIVATE_DESKTOP="+Utf8(desktop_path)+"\r\nPRIVATE_DESKTOP_HEAP_KIB=4096\r\n";
 diagnostic+="COMMAND="+Utf8(command)+"\r\n";
 diagnostic+="SAL_USE_VCLPLUGIN=UNSET\r\nSAL_LOG=+WARN+INFO.vcl.plugadapt+INFO.sal.osl\r\n";
 if(office) {
 const auto module=executable.substr(0,executable.find_last_of(L'\\'))+
     L"\\vclplug_winlo.dll";
 SetLastError(ERROR_SUCCESS);
 const auto module_attributes=GetFileAttributesW(module.c_str());
 const DWORD module_error=module_attributes==INVALID_FILE_ATTRIBUTES?GetLastError():ERROR_SUCCESS;
 diagnostic+="VCL_WINDOWS_MODULE="+Utf8(module)+"\r\n";
 diagnostic+="VCL_WINDOWS_MODULE_ATTRIBUTES="+std::to_string(module_attributes)+
     " error="+std::to_string(module_error)+"\r\n";
 }
 bool window_created=false;
 diagnostic+=WindowDiagnostic(&window_created);
 WriteText(diagnostic_path,diagnostic);
 Require(window_created,"Cannot create hidden window on private desktop; LibreOffice not started");
 PROCESS_INFORMATION raw{};
 const BOOL started=CreateProcessAsUserW(token,executable.c_str(),command.data(),nullptr,nullptr,TRUE,
     EXTENDED_STARTUPINFO_PRESENT|CREATE_SUSPENDED|CREATE_NO_WINDOW|CREATE_UNICODE_ENVIRONMENT,
     environment.data(),working_directory.c_str(),&startup.StartupInfo,&raw);
 if(!started) {
  const DWORD error=GetLastError();
  diagnostic+="CreateProcessAsUserW=FAIL error="+std::to_string(error)+"\r\n";
  WriteText(diagnostic_path,diagnostic);
  throw std::runtime_error("Cannot start suspended restricted process: "+std::to_string(error));
 }
 OwnedHandle process(raw.hProcess),thread(raw.hThread);
 if(!AssignProcessToJobObject(job.get(),process.get())) {
  TerminateProcess(process.get(),1);
  throw std::runtime_error("Cannot attach suspended restricted process to job");
 }
 Require(docx_probe::CheckServiceToken(process.get()),"Child restricted token or removed privileges not confirmed");
 Require(docx_probe::VerifyPolicy(&policy_error),"WFP disappeared before child resume");
 diagnostic+="CHILD_TOKEN=WRITE_RESTRICTED_LOCALSERVICE_PRIVILEGES_REMOVED\r\n";
 diagnostic+=RecheckChildSidSet(token,process.get());
 WriteText(diagnostic_path,diagnostic);
 Require(ResumeThread(thread.get())!=static_cast<DWORD>(-1),"Cannot resume restricted process");
 const ULONGLONG start=GetTickCount64();
 HANDLE waits[]={process.get(),stop_event};
 for(;;) {
  const auto state=WaitForMultipleObjects(2,waits,FALSE,250);
  Require(state==WAIT_TIMEOUT || state==WAIT_OBJECT_0,"Conversion stopped or wait failed");
  Require(docx_probe::VerifyPolicy(&policy_error),"WFP protection lost; stopping process job");
  LARGE_INTEGER size{};
  Require(GetFileSizeEx(output.get(),&size) && size.QuadPart<=1024*1024,
      "Restricted process output exceeds 1 MiB");
  if(state==WAIT_OBJECT_0) break;
  Require(GetTickCount64()-start<timeout,"Restricted process timed out");
 }
 DWORD code=1;
 Require(GetExitCodeProcess(process.get(),&code)!=FALSE,"Cannot read restricted process exit code");
 diagnostic+=(office?"LIBREOFFICE_EXIT_CODE=":"RESTRICTED_PROBE_EXIT_CODE=")+std::to_string(code)+"\r\n";
 diagnostic+="PROCESS_EXIT_HEX="+HexExitCode(code)+"\r\n";
 if(startup_check) diagnostic+="STARTUP_CHECK="+std::string(code==0?"PASS":"FAIL")+"\r\n";
 WriteText(diagnostic_path,diagnostic);
 if(code!=0) throw std::runtime_error(std::string(office?
     (startup_check?"LibreOffice startup (--version); conversion not started":"LibreOffice conversion"):
     "Restricted network/GUI probe")+" returned exit code "+std::to_string(code)+" ("+HexExitCode(code)+")");
 // Closing the job kills any surviving descendants before inspecting output.
}
void Execute(const std::wstring& nonce) {
 Require(docx_probe::CheckBrokerToken(GetCurrentProcess()),"LocalService preparation context not present");
 std::string error;
 Require(docx_probe::VerifyPolicy(&error),"Temporary service-scoped WFP rules missing");
 document_controls::windows_ipc::VerifiedOfficeEngine engine;
 const auto engine_error=document_controls::windows_ipc::LoadVerifiedOfficeEngine(
     LR"(C:\Program Files\LibreOffice\program\soffice.exe)",&engine);
 if(engine_error) throw std::runtime_error(engine_error.code+": "+engine_error.message);
 // A separate, probe-only verifier pins the CLI launcher and its engine.
 // The original .exe verifier and the shared conversion plan are unchanged.
 docx_probe::office_cli::VerifiedConsoleOfficeEngine console_engine;
 const auto console_error=docx_probe::office_cli::LoadVerifiedConsoleOfficeEngine(
     LR"(C:\Program Files\LibreOffice\program\soffice.com)",&console_engine);
 if(console_error) throw std::runtime_error(console_error.code+": "+console_error.message);
 Require(console_engine.evidence().binary_path==engine.evidence().binary_path &&
     console_engine.evidence().version==engine.evidence().version,
     "Console launcher does not match the verified GUI installation");
 WriteText(std::wstring(docx_probe::Work)+L"\\office-engine-diagnostic.txt",
     "OFFICE_ENGINE_DIAGNOSTIC=v12\r\n"
     "LAUNCHER=soffice.com\r\nSIGNATURE_PUBLISHER=THE_DOCUMENT_FOUNDATION_VERIFIED\r\n"
     "VERSION="+Utf8(console_engine.evidence().version)+"\r\n"
     "CONSOLE_SHA256="+console_engine.evidence().sha256[0]+"\r\n"
     "BINARY_SHA256="+console_engine.evidence().sha256[1]+"\r\n"
     "GUI_ENGINE_ANCHOR=PINNED_AND_VERIFIED\r\n");
 const std::wstring job=std::wstring(docx_probe::Work)+L"\\job-"+
     std::to_wstring(GetCurrentProcessId())+L"-"+std::to_wstring(GetTickCount64());
 Require(CreateDirectoryW(job.c_str(),nullptr)!=FALSE,"Cannot create exclusive private job");
 for(const auto* name:{L"office",L"office\\user",L"appdata",L"localdata"})
  Require(CreateDirectoryW((job+L"\\"+name).c_str(),nullptr)!=FALSE,"Cannot create private profile");
 const auto source=ReadInput(std::wstring(docx_probe::Root)+L"\\source.docx");
 document_controls::DocxConversionPlan plan;
 Require(document_controls::BuildDocxConversionPlan(engine.evidence().executable_path,job,&plan,&error),
     "Invalid private conversion paths");
 // The plan remains command data, not an execution capability. Replace only
 // its launcher with the independently verified sibling from the SAME pinned
 // installation. Private paths, source, profile, filter and argv stay fixed.
 plan.executable=console_engine.evidence().executable_path;
 WriteBytes(plan.source_path,source);
 WriteText(plan.profile_settings_path,document_controls::DocxPrivateProfileXml());
 // Preparation stays under LocalService. A fresh thread prepares the
 // private desktop, then separately launched children use a restricted token.
 std::exception_ptr conversion_error;
 std::thread conversion_worker([&] {
  try {
   PrivateDesktop desktop;
   desktop.Prepare(nonce);
   auto token=RestrictedWorkerToken();
   const auto probe=std::wstring(docx_probe::Root)+L"\\abak_docx_probe_service.exe";
   const auto probe_command=document_controls::QuoteWindowsArgument(probe)+
       L" --restricted-network-probe "+document_controls::QuoteWindowsArgument(nonce);
   const auto stage_path=std::wstring(docx_probe::Work)+L"\\execution-stage.txt";
   WriteText(stage_path,"STAGE=RESTRICTED_NETWORK_GUI_PROBE\r\n");
   RunRestrictedProcess(probe,probe_command,plan.working_directory,desktop.path(),token.get(),
       L"restricted-worker-output.txt",40000,false);
   // A restricted child of THIS binary has now passed GUI and network probes.
   // Ask the SAME verified executable for its version, before supplying a DOCX.
   // A zero exit is startup evidence only, never conversion/PDF/A evidence.
   Require(!plan.arguments.empty(),"Private profile argument missing");
   Require(!engine.Recheck() && !console_engine.Recheck(),
       "Engine installation changed before console startup check");
   const auto startup_command=document_controls::QuoteWindowsArgument(plan.executable)+L" "+
       document_controls::QuoteWindowsArgument(plan.arguments.front())+
       L" --headless --nologo --nodefault --norestore --nolockcheck --version";
   WriteText(stage_path,"STAGE=LIBREOFFICE_VERSION_ONLY\r\nCONVERSION_STARTED=false\r\n");
   RunRestrictedProcess(plan.executable,startup_command,plan.working_directory,
       desktop.path(),token.get(),L"office-startup-output.txt",30000,true,true);
   Require(!engine.Recheck() && !console_engine.Recheck(),
       "Engine installation changed after console startup check");
   WriteText(stage_path,"STAGE=LIBREOFFICE_SYNTHETIC_CONVERSION\r\nSTARTUP_CHECK=PASS\r\n");
   RunRestrictedProcess(plan.executable,document_controls::DocxCommandLine(plan),plan.working_directory,
       desktop.path(),token.get(),L"office-output.txt",120000,true);
   WriteText(stage_path,"STAGE=LIBREOFFICE_PROCESS_COMPLETED\r\nOUTPUT_VERIFICATION=pending\r\n");
   // Both jobs are closed (and surviving child processes killed).
   desktop.Restore();
  } catch(...) { conversion_error=std::current_exception(); }
 });
 conversion_worker.join();
 if(conversion_error) std::rethrow_exception(conversion_error);
 Require(!engine.Recheck() && !console_engine.Recheck(),
     "Engine installation changed during console conversion");
 // The original DOCX copy is checked byte-for-byte after Office exits.
 OwnedHandle input(CreateFileW(plan.source_path.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,
     OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 LARGE_INTEGER input_size{};
 Require(input && GetFileSizeEx(input.get(),&input_size) &&
     input_size.QuadPart==static_cast<LONGLONG>(source.size()),"DOCX changed during conversion");
 std::vector<BYTE> copied(source.size()); DWORD count=0;
 Require(ReadFile(input.get(),copied.data(),static_cast<DWORD>(copied.size()),&count,nullptr) &&
     count==copied.size() && copied==source,"DOCX copy changed during conversion");
 OwnedHandle pdf(CreateFileW(plan.output_path.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,
     OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 LARGE_INTEGER size{}; std::array<char,5> header{}; DWORD read=0;
 BY_HANDLE_FILE_INFORMATION pdf_info{};
 Require(pdf && GetFileInformationByHandle(pdf.get(),&pdf_info) &&
     !(pdf_info.dwFileAttributes & (FILE_ATTRIBUTE_DIRECTORY|FILE_ATTRIBUTE_REPARSE_POINT)) &&
     GetFileSizeEx(pdf.get(),&size) && size.QuadPart>5 && size.QuadPart<=20*1024*1024 &&
     ReadFile(pdf.get(),header.data(),5,&read,nullptr) && read==5 &&
     std::memcmp(header.data(),"%PDF-",5)==0,"PDF missing or invalid after conversion");
 WriteText(std::wstring(docx_probe::Work)+L"\\result.txt",
     "SYNTHETIC_SERVICE_CONVERSION=PASS\r\n"
     "BROKER_TOKEN=LOCALSERVICE_SERVICE_SID_ENABLED\r\n"
     "OFFICE_TOKEN=WRITE_RESTRICTED_LOCALSERVICE_PRIVILEGES_REMOVED\r\n"
     "OFFICE_RESTRICTING_SIDS=SERVICE_AND_WORLD\r\n"
     "FILE_ACCESS_MATRIX=EXPECTED_RESULTS\r\n"
     "NETWORK_PROBE_TOKEN_PROFILE=SERVICE_PLUS_WORLD\r\n"
     "RESTRICTED_WORKER_GUI_PROBE=PASS\r\n"
     "LIBREOFFICE_STARTUP_CHECK=PASS\r\n"
     "OFFICE_LAUNCHER=VERIFIED_SOFFICE_COM\r\n"
     "NETWORK_PROBES=RESTRICTED_CHILD_TCP_UDP_IPV4_IPV6_DENIED\r\n"
     "WFP_SCOPE=DEDICATED_SERVICE_SID\r\n"
     "PDFA=NOT_YET_VALIDATED\r\nAPPLICATION_INTEGRATED=false\r\nISOLATION_QUALIFIED=false\r\n");
}
void WINAPI ServiceMain(DWORD argc,LPWSTR* argv) {
 status_handle=RegisterServiceCtrlHandlerExW(docx_probe::ServiceName,Control,nullptr);
 if(!status_handle) return;
 Report(SERVICE_START_PENDING);
 stop_event=CreateEventW(nullptr,TRUE,FALSE,nullptr);
 if(!stop_event){ Report(SERVICE_STOPPED,GetLastError()); return; }
 Report(SERVICE_RUNNING);
 DWORD failure=ERROR_SUCCESS;
 try {
  Require(argc==2 && argv && argv[1],"Missing controller run identity");
  const std::wstring nonce=argv[1];
  Require(nonce.size()==32 && nonce.find_first_not_of(L"0123456789abcdef")==std::wstring::npos,
      "Invalid controller run identity");
  Execute(nonce);
 }
 catch(const std::exception& error) {
  failure=ERROR_GEN_FAILURE;
  try { WriteText(std::wstring(docx_probe::Work)+L"\\result.txt",
      std::string("SYNTHETIC_SERVICE_CONVERSION=FAIL\r\n")+error.what()+"\r\n"); }
  catch(...) {}
 }
 Report(SERVICE_STOPPED,failure);
 CloseHandle(stop_event); stop_event=nullptr;
}
}
int RestrictedProbeMain(const std::wstring& nonce) {
 std::string diagnostic="RESTRICTED_WORKER_DIAGNOSTIC=v12\r\n";
 const auto path=std::wstring(docx_probe::Work)+L"\\restricted-worker-diagnostic.txt";
 try {
  (void)docx_probe::RunNonceAscii(nonce);
  Require(docx_probe::CheckServiceToken(GetCurrentProcess()),"Restricted probe token verification failed");
  diagnostic+="WORKER_TOKEN=WRITE_RESTRICTED_LOCALSERVICE_PRIVILEGES_REMOVED\r\nTOKEN_PROFILE=SERVICE_PLUS_WORLD\r\n";
  diagnostic+=SelfTokenAccessDiagnostic();
  std::string policy_error;
  // Management access is not a worker permission. The preparation process
  // verifies all four filters before resume, polls them while the job runs,
  // and independently verifies them before the subsequent Office launch.
  // The administrator must still observe both current-run UDP drops; the
  // worker's real GUI/TCP/UDP tests remain mandatory.
  const bool local_query=docx_probe::VerifyPolicy(&policy_error);
  diagnostic+=std::string("WFP_MANAGEMENT_QUERY=")+(local_query?"AVAILABLE":"UNAVAILABLE")+"\r\n";
  if(!local_query) diagnostic+="WFP_MANAGEMENT_DETAIL="+policy_error+"\r\n";
  diagnostic+="WFP_MANAGEMENT_ROLE=DIAGNOSTIC_ONLY\r\n";
  diagnostic+="WFP_POLICY_AUTHORITY=PREPARATION_PROCESS_AND_ADMIN_CONTROLLER\r\n";
  WriteText(path,diagnostic);
  stop_event=CreateEventW(nullptr,TRUE,FALSE,nullptr);
  Require(stop_event!=nullptr,"Cannot create restricted probe stop event");
  bool window_created=false;
  diagnostic+=WindowDiagnostic(&window_created);
  WriteText(path,diagnostic);
  Require(window_created,"Restricted child hidden window creation failed");
  const auto access=docx_probe::ProbeSyntheticFileAccess(std::wstring(docx_probe::Root)+L"\\access-fixtures");
  WriteText(std::wstring(docx_probe::Work)+L"\\file-access-probe.txt",access.diagnostic);
  Require(access.expected,"Synthetic file access results differ from expected ACL matrix");
  ProbeNetwork(nonce);
  diagnostic+="RESTRICTED_CHILD_NETWORK=TCP_UDP_IPV4_IPV6_DENIED\r\n";
  WriteText(path,diagnostic);
  CloseHandle(stop_event); stop_event=nullptr;
  return 0;
 } catch(const std::exception& error) {
  diagnostic+="ERROR="+std::string(error.what())+"\r\n";
  try { WriteText(path,diagnostic); } catch(...) {}
  if(stop_event) { CloseHandle(stop_event); stop_event=nullptr; }
  return 1;
 }
}
int wmain(int argc,wchar_t* argv[]) {
 if(argc==3 && wcscmp(argv[1],L"--restricted-network-probe")==0)
  return RestrictedProbeMain(argv[2]);
 if(argc!=1) return ERROR_INVALID_PARAMETER;
 wchar_t name[]=L"ABAKDocxConversionProbe";
 SERVICE_TABLE_ENTRYW table[]={{name,ServiceMain},{nullptr,nullptr}};
 return StartServiceCtrlDispatcherW(table)?0:static_cast<int>(GetLastError());
}
