#include "policy.h"
#include "runtime.h"
#include <iostream>
namespace {
int StopService() {
 SC_HANDLE manager=OpenSCManagerW(nullptr,nullptr,SC_MANAGER_CONNECT);
 if(!manager) return static_cast<int>(GetLastError());
 SC_HANDLE service=OpenServiceW(manager,L"ABAKDocumentControls",SERVICE_STOP|SERVICE_QUERY_STATUS|SERVICE_QUERY_CONFIG);
 if(!service) {const DWORD error=GetLastError();CloseServiceHandle(manager);return error==ERROR_SERVICE_DOES_NOT_EXIST?0:static_cast<int>(error);}
 DWORD bytes=0;QueryServiceConfigW(service,nullptr,0,&bytes);
 std::vector<BYTE> storage(bytes);
 bool expected=bytes>0 && QueryServiceConfigW(service,reinterpret_cast<QUERY_SERVICE_CONFIGW*>(storage.data()),bytes,&bytes);
 if(expected) {
  const auto* config=reinterpret_cast<const QUERY_SERVICE_CONFIGW*>(storage.data());
  const auto binary=L"\""+document_controls_runtime::ApplicationRoot()+L"\\ABAKDocumentControls.exe\"";
  expected=config->lpBinaryPathName && _wcsicmp(config->lpBinaryPathName,binary.c_str())==0;
 }
 DWORD error=expected?ERROR_SUCCESS:ERROR_ACCESS_DENIED;
 SERVICE_STATUS status{};
 if(expected && !ControlService(service,SERVICE_CONTROL_STOP,&status)) {
  error=GetLastError();if(error==ERROR_SERVICE_NOT_ACTIVE) error=ERROR_SUCCESS;
 }
 const ULONGLONG start=GetTickCount64();
 while(error==ERROR_SUCCESS) {
  if(!QueryServiceStatus(service,&status)) {error=GetLastError();break;}
  if(status.dwCurrentState==SERVICE_STOPPED) break;
  if(GetTickCount64()-start>=20000) {error=ERROR_TIMEOUT;break;}
  Sleep(100);
 }
 CloseServiceHandle(service);CloseServiceHandle(manager);return static_cast<int>(error);
}
}
int wmain(int argc,wchar_t* argv[]) {
 if(argc!=2) return ERROR_INVALID_PARAMETER;
 if(wcscmp(argv[1],L"stop")==0) return StopService();
 std::string error;bool ok=false;
 if(wcscmp(argv[1],L"install")==0) ok=document_controls_runtime::InstallPersistentPolicy(&error);
 else if(wcscmp(argv[1],L"remove")==0) ok=document_controls_runtime::RemovePersistentPolicy(&error);
 else if(wcscmp(argv[1],L"verify")==0) ok=document_controls_runtime::VerifyPolicy(&error);
 else return ERROR_INVALID_PARAMETER;
 if(!ok) {std::cerr<<error<<std::endl;return 1;}
 std::cout<<"ABAK document controls policy: OK"<<std::endl;return 0;
}
