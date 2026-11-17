#include <winsock2.h>
#include <sddl.h>
#include "runtime.h"
#include "policy.h"
#include "office_console_engine.h"
#include "../runner/document_controls_office_engine.h"
#include "../runner/document_controls_docx_plan.h"
#include <array>
#include <map>
#include <stdexcept>
#include <vector>
#include <cstring>
#include <thread>
#include <exception>
#include <cstddef>

namespace document_controls_runtime {
namespace {
using document_controls::windows_ipc::VerifyProtectedFile;
HANDLE stop_event=nullptr;
HANDLE client_process=nullptr;
struct Capture {std::uint32_t pid=0;int code=-1;std::string output,errors;};
std::string ReadCapture(HANDLE file,std::size_t limit) {
 LARGE_INTEGER size{},zero{};
 if(!GetFileSizeEx(file,&size) || size.QuadPart<0 || static_cast<std::uint64_t>(size.QuadPart)>limit ||
     !SetFilePointerEx(file,zero,nullptr,FILE_BEGIN)) throw std::runtime_error("Process output unavailable");
 std::string text(static_cast<std::size_t>(size.QuadPart),'\0');
 DWORD count=0;
 if(!text.empty() && (!ReadFile(file,text.data(),static_cast<DWORD>(text.size()),&count,nullptr) || count!=text.size()))
  throw std::runtime_error("Process output incomplete");
 if(!document_controls::windows_ipc::ValidUtf8(text)) throw std::runtime_error("Process output is not UTF-8");
 return text;
}
void Require(bool ok,const char* message) {
 if(!ok) throw std::runtime_error(message);
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
void WriteBytes(const std::wstring& path,const std::vector<BYTE>& data) {
 OwnedHandle file(CreateFileW(path.c_str(),GENERIC_WRITE,0,nullptr,CREATE_NEW,
     FILE_ATTRIBUTE_NORMAL,nullptr));
 DWORD written=0;
 Require(file && WriteFile(file.get(),data.data(),static_cast<DWORD>(data.size()),
     &written,nullptr) && written==data.size(),"Cannot copy synthetic DOCX");
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
  const auto journal=document_controls_runtime::WorkDirectory()+L"\\office-diagnostic.txt";
 std::string diagnostic="OFFICE_DIAGNOSTIC=WINDOWS_RUNTIME_1\r\n";
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
  Require(nonce.size()==32 && nonce.find_first_not_of(L"0123456789abcdef")==std::wstring::npos,"Invalid request identity");
  const auto name=L"ABAKControls_"+nonce;
  std::wstring sid;
  checked(document_controls_runtime::ServiceSid(&sid),"ResolvePrivateDesktopServiceSid");
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
 Require(document_controls_runtime::ServiceSid(&text) && ConvertStringSidToSidW(text.c_str(),&raw_sid),
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
Capture RunRestrictedProcess(const std::wstring& executable,std::wstring command,
    const std::wstring& working_directory,std::wstring desktop_path,HANDLE token,
    const wchar_t* capture_name,DWORD timeout,bool office,bool startup_check=false,
    const char* purpose=nullptr) {
 std::string policy_error;
 if(!document_controls_runtime::VerifyPolicy(&policy_error)) throw std::runtime_error(policy_error);
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
 OwnedHandle errors(CreateFileW((working_directory+L"\\"+capture_name+L".stderr").c_str(),
     GENERIC_READ|GENERIC_WRITE,FILE_SHARE_READ,&security,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,nullptr));
 OwnedHandle input(CreateFileW(L"NUL",GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,
     &security,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,nullptr));
 Require(output && errors && input,"Cannot create bounded process capture");
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
 HANDLE handles[]={output.get(),errors.get(),input.get()};
 Require(UpdateProcThreadAttribute(attributes,0,PROC_THREAD_ATTRIBUTE_HANDLE_LIST,
     handles,sizeof(handles),nullptr,nullptr)!=FALSE,"Cannot restrict inherited handles");
 STARTUPINFOEXW startup{};
 startup.StartupInfo.cb=sizeof(startup); startup.lpAttributeList=attributes;
 startup.StartupInfo.dwFlags=STARTF_USESTDHANDLES;
 startup.StartupInfo.hStdInput=input.get();
 startup.StartupInfo.hStdOutput=output.get(); startup.StartupInfo.hStdError=errors.get();
 startup.StartupInfo.lpDesktop=desktop_path.data();
 auto environment=Environment(working_directory,executable);
 const auto diagnostic_path=document_controls_runtime::WorkDirectory()+(office?
     (startup_check?L"\\office-startup-diagnostic.txt":L"\\office-diagnostic.txt"):
     L"\\restricted-launch-diagnostic.txt");
 std::string diagnostic="PROCESS_DIAGNOSTIC=WINDOWS_RUNTIME_1\r\n";
 diagnostic+=std::string("PURPOSE=")+(purpose?purpose:office?
     (startup_check?"LIBREOFFICE_VERSION_ONLY":"LIBREOFFICE_DOCX_CONVERSION"):
     "VERAPDF_VALIDATION")+"\r\n";
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
 Require(document_controls_runtime::CheckServiceToken(process.get()),"Child restricted token or removed privileges not confirmed");
 Require(document_controls_runtime::VerifyPolicy(&policy_error),"WFP disappeared before child resume");
 diagnostic+="CHILD_TOKEN=WRITE_RESTRICTED_LOCALSERVICE_PRIVILEGES_REMOVED\r\n";
 diagnostic+=RecheckChildSidSet(token,process.get());
 WriteText(diagnostic_path,diagnostic);
 Require(ResumeThread(thread.get())!=static_cast<DWORD>(-1),"Cannot resume restricted process");
 const ULONGLONG start=GetTickCount64();
 HANDLE waits[]={process.get(),stop_event,client_process};
 for(;;) {
  const auto state=WaitForMultipleObjects(3,waits,FALSE,250);
  Require(state==WAIT_TIMEOUT || state==WAIT_OBJECT_0,"Conversion stopped or wait failed");
  Require(document_controls_runtime::VerifyPolicy(&policy_error),"WFP protection lost; stopping process job");
  LARGE_INTEGER size{};
  Require(GetFileSizeEx(output.get(),&size) && size.QuadPart<=8*1024*1024,
      "Process output exceeds 8 MiB");
  LARGE_INTEGER error_size{};
  Require(GetFileSizeEx(errors.get(),&error_size) && error_size.QuadPart<=1024*1024,
      "Process error output exceeds 1 MiB");
  if(state==WAIT_OBJECT_0) break;
  Require(GetTickCount64()-start<timeout,"Restricted process timed out");
 }
 DWORD code=1;
 Require(GetExitCodeProcess(process.get(),&code)!=FALSE,"Cannot read restricted process exit code");
 diagnostic+=(office?"LIBREOFFICE_EXIT_CODE=":purpose?"CDA_EXIT_CODE=":"VERAPDF_EXIT_CODE=")+std::to_string(code)+"\r\n";
 diagnostic+="PROCESS_EXIT_HEX="+HexExitCode(code)+"\r\n";
 if(startup_check) diagnostic+="STARTUP_CHECK="+std::string(code==0?"PASS":"FAIL")+"\r\n";
 WriteText(diagnostic_path,diagnostic);
 if(office && code!=0) throw std::runtime_error(std::string(office?
     (startup_check?"LibreOffice startup (--version); conversion not started":"LibreOffice conversion"):
     "Restricted network/GUI probe")+" returned exit code "+std::to_string(code)+" ("+HexExitCode(code)+")");
 // The launcher may have descendants. End only this dedicated job and wait
 // for every member before inspecting files or deleting the private workspace.
 Require(TerminateJobObject(job.get(),0)!=FALSE,"Cannot end process job");
 const ULONGLONG end_start=GetTickCount64();
 for(;;) {
  JOBOBJECT_BASIC_ACCOUNTING_INFORMATION account{};
  Require(QueryInformationJobObject(job.get(),JobObjectBasicAccountingInformation,&account,sizeof(account),nullptr)!=FALSE,
      "Cannot inspect completed process job");
  if(account.ActiveProcesses==0) break;
  Require(GetTickCount64()-end_start<5000,"Process descendants did not stop");
  Sleep(10);
 }
 Capture captured;
 captured.pid=raw.dwProcessId;captured.code=static_cast<int>(code);
 captured.output=ReadCapture(output.get(),8*1024*1024);
 captured.errors=ReadCapture(errors.get(),1024*1024);
 return captured;
}

std::vector<std::uint8_t> ReadDocument(const std::wstring& path,std::size_t maximum=MaxDocument) {
 OwnedHandle file(CreateFileW(path.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,
     OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 BY_HANDLE_FILE_INFORMATION info{};LARGE_INTEGER size{};
 Require(file && GetFileInformationByHandle(file.get(),&info) &&
     !(info.dwFileAttributes & (FILE_ATTRIBUTE_REPARSE_POINT|FILE_ATTRIBUTE_DIRECTORY)) &&
     GetFileSizeEx(file.get(),&size) && size.QuadPart>0 && size.QuadPart<=static_cast<LONGLONG>(maximum),
     "Document temporaire absent ou invalide.");
 std::vector<std::uint8_t> bytes(static_cast<std::size_t>(size.QuadPart));
 DWORD read=0;
 Require(ReadFile(file.get(),bytes.data(),static_cast<DWORD>(bytes.size()),&read,nullptr) && read==bytes.size(),
     "Document temporaire incomplet.");
 return bytes;
}
bool CleanupFailure(const std::wstring& path,const char* action,DWORD error,std::string* diagnostic) {
 if(diagnostic && diagnostic->empty())
  *diagnostic=std::string(action)+" error="+std::to_string(error)+" path="+Utf8(path);
 return false;
}
bool RemoveJob(const std::wstring& path,unsigned depth=0,std::string* diagnostic=nullptr) {
 if(depth>64) return CleanupFailure(path,"Maximum cleanup depth",ERROR_DIRECTORY,diagnostic);
 const DWORD attributes=GetFileAttributesW(path.c_str());
 if(attributes==INVALID_FILE_ATTRIBUTES) {
  const DWORD error=GetLastError();
  return error==ERROR_FILE_NOT_FOUND || error==ERROR_PATH_NOT_FOUND ||
      CleanupFailure(path,"GetFileAttributesW",error,diagnostic);
 }
 // Only this request's private tree is passed here. Clear the read-only
 // attribute on real entries, never on a link or
 // its target, and leave all other attributes and every ACL unchanged.
 if((attributes&FILE_ATTRIBUTE_READONLY) && !(attributes&FILE_ATTRIBUTE_REPARSE_POINT)) {
  const DWORD writable=attributes&~static_cast<DWORD>(FILE_ATTRIBUTE_READONLY);
  if(!SetFileAttributesW(path.c_str(),writable?writable:FILE_ATTRIBUTE_NORMAL))
   return CleanupFailure(path,"SetFileAttributesW",GetLastError(),diagnostic);
 }
 if(!(attributes&FILE_ATTRIBUTE_DIRECTORY)) {
  if(DeleteFileW(path.c_str())) return true;
  return CleanupFailure(path,"DeleteFileW",GetLastError(),diagnostic);
 }
 if(attributes&FILE_ATTRIBUTE_REPARSE_POINT) {
  if(RemoveDirectoryW(path.c_str())) return true;
  return CleanupFailure(path,"RemoveDirectoryW(link)",GetLastError(),diagnostic);
 }
 WIN32_FIND_DATAW item{};
 HANDLE search=FindFirstFileW((path+L"\\*").c_str(),&item);
 bool ok=true;
 if(search!=INVALID_HANDLE_VALUE) {
  do {
   if(wcscmp(item.cFileName,L".")==0 || wcscmp(item.cFileName,L"..")==0) continue;
   if(!RemoveJob(path+L"\\"+item.cFileName,depth+1,diagnostic)) ok=false;
  } while(FindNextFileW(search,&item));
  const DWORD error=GetLastError();
  FindClose(search);
  if(error!=ERROR_NO_MORE_FILES) ok=CleanupFailure(path,"FindNextFileW",error,diagnostic);
 } else {
  const DWORD error=GetLastError();
  if(error!=ERROR_FILE_NOT_FOUND) ok=CleanupFailure(path,"FindFirstFileW",error,diagnostic);
 }
 if(!ok) return false;
 if(RemoveDirectoryW(path.c_str())) return true;
 return CleanupFailure(path,"RemoveDirectoryW",GetLastError(),diagnostic);
}
struct JobCleanup {
 std::wstring path;
 ~JobCleanup(){if(!path.empty()) (void)RemoveJob(path);}
};
void CommonDirectories(const std::wstring& job) {
 for(const auto* name:{L"office",L"office\\user",L"appdata",L"localdata"})
  Require(CreateDirectoryW((job+L"\\"+name).c_str(),nullptr)!=FALSE,"Dossier prive impossible a creer.");
}
} // namespace

Reply RunWorker(const Request& request,HANDLE stop,HANDLE peer) {
 Reply reply;reply.operation=request.operation;reply.id=request.id;reply.input_hash=request.input_hash;
 stop_event=stop;client_process=peer;
 std::string policy_error;
 Require(CheckBrokerToken(GetCurrentProcess()),"Contexte LocalService absent.");
 if(!VerifyPolicy(&policy_error)) throw std::runtime_error(policy_error);
 Require(request.id.size()==32 && request.id.find_first_not_of("0123456789abcdef")==std::string::npos,
     "Identifiant de travail invalide.");
 const auto work=WorkDirectory();
 Require(!work.empty(),"Dossier de service indisponible.");
 const auto job=work+L"\\job-"+Wide(request.id);
 Require(CreateDirectoryW(job.c_str(),nullptr)!=FALSE,"Un dossier de travail neuf est requis.");
 JobCleanup cleanup{job};
 CommonDirectories(job);
 Capture capture;
 if(request.operation=="docx") {
  document_controls::windows_ipc::VerifiedOfficeEngine engine;
  auto error=document_controls::windows_ipc::LoadVerifiedOfficeEngine(Wide(request.office),&engine);
  if(error) throw std::runtime_error(error.code+": "+error.message);
  const auto exe=engine.evidence().executable_path;
  const auto console_path=exe.substr(0,exe.find_last_of(L'\\'))+L"\\soffice.com";
  office_cli::VerifiedConsoleOfficeEngine console;
  error=office_cli::LoadVerifiedConsoleOfficeEngine(console_path,&console);
  if(error) throw std::runtime_error(error.code+": "+error.message);
  Require(console.evidence().binary_path==engine.evidence().binary_path &&
      console.evidence().version==engine.evidence().version,"Installation LibreOffice incoherente.");
  document_controls::DocxConversionPlan plan;
  std::string plan_error;
  if(!document_controls::BuildDocxConversionPlan(exe,job,&plan,&plan_error)) throw std::runtime_error(plan_error);
  plan.executable=console.evidence().executable_path;
  WriteBytes(plan.source_path,request.input);
  WriteText(plan.profile_settings_path,document_controls::DocxPrivateProfileXml());
  std::exception_ptr failure;
  std::thread worker([&]{
   try {
    PrivateDesktop desktop;desktop.Prepare(Wide(request.id));
    auto token=RestrictedWorkerToken();
    Require(!engine.Recheck() && !console.Recheck(),"LibreOffice modifie avant conversion.");
    const auto startup=document_controls::QuoteWindowsArgument(plan.executable)+L" "+
        document_controls::QuoteWindowsArgument(plan.arguments.front())+
        L" --headless --nologo --nodefault --norestore --nolockcheck --version";
    (void)RunRestrictedProcess(plan.executable,startup,job,desktop.path(),token.get(),
        L"office-startup.txt",30000,true,true);
    Require(!engine.Recheck() && !console.Recheck(),"LibreOffice modifie au demarrage.");
    capture=RunRestrictedProcess(plan.executable,document_controls::DocxCommandLine(plan),job,
        desktop.path(),token.get(),L"office-output.txt",120000,true);
    desktop.Restore();
   } catch(...) {failure=std::current_exception();}
  });
  worker.join();if(failure) std::rethrow_exception(failure);
  Require(!engine.Recheck() && !console.Recheck(),"LibreOffice modifie pendant la conversion.");
  Require(ReadDocument(plan.source_path)==request.input,"Le DOCX temporaire a ete modifie.");
  reply.pdf=ReadDocument(plan.output_path);
  Require(reply.pdf.size()>=5 && std::memcmp(reply.pdf.data(),"%PDF-",5)==0,"Le resultat ne contient pas de PDF.");
  reply.pdf_hash=HashBytes(reply.pdf);
  reply.engine_verified=true;reply.private_profile=true;reply.macros_disabled=true;
  reply.office_version=Utf8(engine.evidence().version);
  reply.office_launcher_hash=console.evidence().sha256[0];reply.office_binary_hash=console.evidence().sha256[1];
 } else if(request.operation=="cda") {
  auto tools=LoadTools();
  auto resources=PrepareCdaResources(job);
  reply.cda_manifest_hash=resources.manifest_hash;
  reply.cda_references_hash=resources.references_hash;
  reply.cda_helper_hash=resources.helper_hash;
  const auto input=job+L"\\document.xml";
  Require(!request.input.empty(),"Un document CDA est requis.");
  WriteBytes(input,request.input);
  const auto quote=document_controls::QuoteWindowsArgument;
  const auto command=quote(tools.java)+L" "+quote(L"-Duser.home="+job)+L" "+
      quote(L"-Djava.io.tmpdir="+job)+L" -Xms32m -Xmx512m -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 --class-path "+
      quote(resources.saxon)+L" "+quote(resources.helper)+L" "+quote(job+L"\\references")+L" "+quote(job);
  std::exception_ptr failure;
  std::thread worker([&]{
   try {
    PrivateDesktop desktop;desktop.Prepare(Wide(request.id));
    auto token=RestrictedWorkerToken();
    capture=RunRestrictedProcess(tools.java,command,job,desktop.path(),token.get(),
        L"cda-output.txt",request.timeout_ms,false,false,"CDA_VALIDATION");
    desktop.Restore();
   } catch(...) {failure=std::current_exception();}
  });
  worker.join();if(failure) std::rethrow_exception(failure);
  Require(capture.code==0 || capture.code==1,"Le controle CDA a ete interrompu.");
  Require(ReadDocument(input,MaxCdaDocument)==request.input,"CDA temporaire modifie pendant le controle.");
  RecheckCdaResources(resources);
  if(capture.code==0) {
   CdaReportFiles reports;
   for(const auto& name:CdaReportNames()) {
    const auto path=job+L"\\"+Wide(name);
    if(name=="xsd-error.txt" && GetFileAttributesW(path.c_str())==INVALID_FILE_ATTRIBUTES) {
     const auto error=GetLastError();
     Require(error==ERROR_FILE_NOT_FOUND || error==ERROR_PATH_NOT_FOUND,"Rapport XSD inaccessible.");
     continue;
    }
    reports.emplace(name,ReadDocument(path));
   }
   reply.cda_reports=PackCdaReports(reports);
  }
  reply.cda_reports_hash=HashBytes(reply.cda_reports);
 } else {
  Require(request.operation=="pdfa" || request.operation=="version","Operation documentaire non autorisee.");
  auto tools=LoadTools();
  const auto input=job+L"\\document.pdf";
  if(request.operation=="pdfa") {
   Require(request.input.size()>=5 && std::memcmp(request.input.data(),"%PDF-",5)==0,"Un PDF est requis.");
   WriteBytes(input,request.input);
   reply.reported_path=Utf8(input);
  }
  const auto quote=document_controls::QuoteWindowsArgument;
  std::wstring command=quote(tools.java)+L" "+quote(L"-Duser.home="+job)+L" "+
      quote(L"-Djava.io.tmpdir="+job)+L" -Xms32m -Xmx512m -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dsun.stderr.encoding=UTF-8 -cp "+
      quote(tools.jar)+L" org.verapdf.apps.GreenfieldCliWrapper ";
  command+=request.operation=="pdfa"?L"--format xml --flavour 1b "+quote(input):L"--version";
  std::exception_ptr failure;
  std::thread worker([&]{
   try {
    PrivateDesktop desktop;desktop.Prepare(Wide(request.id));
    auto token=RestrictedWorkerToken();
    capture=RunRestrictedProcess(tools.java,command,job,desktop.path(),token.get(),
        L"verapdf-output.txt",request.timeout_ms,false);
    desktop.Restore();
   } catch(...) {failure=std::current_exception();}
  });
  worker.join();if(failure) std::rethrow_exception(failure);
  Require(capture.code==0 || (request.operation=="pdfa" && capture.code==1),"veraPDF n a pas termine normalement.");
  if(request.operation=="pdfa") Require(ReadDocument(input)==request.input,"PDF temporaire modifie pendant le controle.");
 }
 if(!VerifyPolicy(&policy_error)) throw std::runtime_error(policy_error);
 reply.pid=capture.pid;reply.exit_code=capture.code;reply.output=capture.output;reply.diagnostic=capture.errors;
 reply.executed=true;reply.network_denied=true;reply.write_restricted=true;reply.job_object=true;
 std::string cleanup_error;
 if(!RemoveJob(job,0,&cleanup_error))
  throw std::runtime_error("Le nettoyage du travail temporaire a echoue. "+cleanup_error);
 cleanup.path.clear();
 return reply;
}
} // namespace document_controls_runtime
