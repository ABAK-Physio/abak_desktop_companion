#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winsvc.h>

#include "document_controls_service_core.h"

#pragma comment(lib, "advapi32.lib")

namespace {

DWORD WINAPI ControlHandler(DWORD control, DWORD, LPVOID, LPVOID) {
  if (control == SERVICE_CONTROL_INTERROGATE) return NO_ERROR;
  // Startup is deliberately refused before any work or accepted stop controls.
  return ERROR_CALL_NOT_IMPLEMENTED;
}

void WINAPI ServiceMain(DWORD, LPWSTR*) {
  const auto status_handle = RegisterServiceCtrlHandlerExW(
      document_controls::windows_ipc::kDocumentServiceName, ControlHandler, nullptr);
  if (!status_handle) return;
  SERVICE_STATUS status{};
  status.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
  status.dwCurrentState = SERVICE_START_PENDING;
  status.dwCheckPoint = 1;
  status.dwWaitHint = 2000;
  if (!SetServiceStatus(status_handle, &status)) return;

  const bool refused = static_cast<bool>(document_controls::windows_ipc::ServiceStartupGate());
  // Even a mistakenly changed gate cannot open a listener in this W3 host:
  // it has no pipe creation, worker, Java path, RUNNING state, or console server.
  status.dwCurrentState = SERVICE_STOPPED;
  status.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR;
  status.dwServiceSpecificExitCode = refused ? 1 : 2;
  status.dwCheckPoint = 0;
  status.dwWaitHint = 0;
  SetServiceStatus(status_handle, &status);
}

}  // namespace

int wmain(int argc, wchar_t**) {
  if (argc != 1) return ERROR_INVALID_PARAMETER;
  wchar_t name[] = L"ABAKDocumentControls";
  const SERVICE_TABLE_ENTRYW services[] = {
      {name, ServiceMain}, {nullptr, nullptr}};
  if (!StartServiceCtrlDispatcherW(services)) return static_cast<int>(GetLastError());
  return ERROR_SERVICE_SPECIFIC_ERROR;
}
