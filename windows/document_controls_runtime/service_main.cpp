#include "runtime.h"
#include "policy.h"
#include <stdexcept>
namespace {
SERVICE_STATUS_HANDLE status_handle=nullptr;
HANDLE stop_event=nullptr;
void Report(DWORD state,DWORD error=0) {
 SERVICE_STATUS status{};status.dwServiceType=SERVICE_WIN32_OWN_PROCESS;
 status.dwCurrentState=state;status.dwWin32ExitCode=error;
 status.dwControlsAccepted=state==SERVICE_RUNNING?SERVICE_ACCEPT_STOP:0;
 if(state==SERVICE_START_PENDING || state==SERVICE_STOP_PENDING) {status.dwWaitHint=10000;status.dwCheckPoint=1;}
 SetServiceStatus(status_handle,&status);
}
DWORD WINAPI Control(DWORD control,DWORD,LPVOID,LPVOID) {
 if(control==SERVICE_CONTROL_STOP) {Report(SERVICE_STOP_PENDING);SetEvent(stop_event);return NO_ERROR;}
 return control==SERVICE_CONTROL_INTERROGATE?NO_ERROR:ERROR_CALL_NOT_IMPLEMENTED;
}
void Ready(){Report(SERVICE_RUNNING);}
void LogFailure(const std::string& error) {
 const auto work=document_controls_runtime::WorkDirectory();
 if(work.empty()) return;
 HANDLE file=CreateFileW((work+L"\\startup-error.txt").c_str(),GENERIC_WRITE,FILE_SHARE_READ,
     nullptr,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,nullptr);
 if(file==INVALID_HANDLE_VALUE) return;
 const auto text=error.substr(0,8192);DWORD written=0;
 WriteFile(file,text.data(),static_cast<DWORD>(text.size()),&written,nullptr);CloseHandle(file);
}
void WINAPI Main(DWORD,LPWSTR*) {
 status_handle=RegisterServiceCtrlHandlerExW(L"ABAKDocumentControls",Control,nullptr);
 if(!status_handle) return;
 Report(SERVICE_START_PENDING);
 stop_event=CreateEventW(nullptr,TRUE,FALSE,nullptr);
 DWORD error=ERROR_SUCCESS;
 if(!stop_event) error=GetLastError();
 else {
  try {document_controls_runtime::Serve(stop_event,Ready);}
  catch(const std::exception& failure){LogFailure(failure.what());error=ERROR_SERVICE_SPECIFIC_ERROR;}
  catch(...){LogFailure("Initialisation du service interrompue.");error=ERROR_SERVICE_SPECIFIC_ERROR;}
  CloseHandle(stop_event);stop_event=nullptr;
 }
 Report(SERVICE_STOPPED,error);
}
}
int wmain(int argc,wchar_t**) {
 if(argc!=1) return ERROR_INVALID_PARAMETER;
 wchar_t name[]=L"ABAKDocumentControls";
 SERVICE_TABLE_ENTRYW services[]={{name,Main},{nullptr,nullptr}};
 return StartServiceCtrlDispatcherW(services)?0:static_cast<int>(GetLastError());
}
