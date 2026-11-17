#include "cps_pkcs11_windows.h"
#include "cps_signature.h"
#include <windows.h>
#include <cstring>
#include <iterator>
#include <string>
#include <utility>

namespace cps_windows {
namespace {
template<class Function> Function Resolve(HMODULE module, const char* name) {
  const FARPROC address = GetProcAddress(module, name);
  static_assert(sizeof(address) == sizeof(Function), "Windows function pointer size.");
  Function function = nullptr;
  std::memcpy(&function, &address, sizeof(function));
  return function;
}
}
Reply ReadInstalledCryptolib(Request request) {
  auto& pin = request.pin;
  static_assert(sizeof(void*) == 8, "Cryptolib CPS x64 reader required.");
  Reply reply;
  if (!ValidRequest(request)) { Erase(&pin); reply.step = "REQUEST_FORMAT"; return reply; }
  wchar_t system[32768]{};
  const UINT size = GetSystemDirectoryW(system, static_cast<UINT>(std::size(system)));
  if (!size || size >= std::size(system)) {
    reply.step = "LoadLibrary"; reply.windows_error = GetLastError();
    Erase(&pin); return reply;
  }
  const std::wstring path = std::wstring(system) + L"\\cps3_pkcs11_w64.dll";
  HMODULE module = LoadLibraryExW(path.c_str(), nullptr,
      LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
  if (!module) {
    reply.step = "LoadLibrary"; reply.windows_error = GetLastError();
    Erase(&pin); return reply;
  }
  Api api;
  // No key export, PIN change or write functions. Sign only for explicit sign/test.
#define CPS_LOAD(member, name) \
  api.member = Resolve<decltype(api.member)>(module, name)
  CPS_LOAD(initialize, "C_Initialize"); CPS_LOAD(finalize, "C_Finalize");
  CPS_LOAD(slots, "C_GetSlotList"); CPS_LOAD(open, "C_OpenSession");
  CPS_LOAD(login, "C_Login"); CPS_LOAD(logout, "C_Logout");
  CPS_LOAD(close, "C_CloseSession"); CPS_LOAD(find_init, "C_FindObjectsInit");
  CPS_LOAD(find, "C_FindObjects"); CPS_LOAD(find_final, "C_FindObjectsFinal");
  CPS_LOAD(attribute, "C_GetAttributeValue");
  if (request.operation == Operation::Sign || request.operation == Operation::Test) {
    CPS_LOAD(sign_init, "C_SignInit"); CPS_LOAD(sign, "C_Sign");
  }
#undef CPS_LOAD
  if (!api.complete()) {
    reply.step = "GetProcAddress"; reply.windows_error = GetLastError();
    Erase(&pin);
  } else {
    const auto crypto = WindowsPublicCrypto();
    SessionAction action;
    if (request.operation != Operation::Read)
      action = [&](Ulong session, Reply* output) { return SignSession(api, session, request, crypto, output); };
    reply = ReadProfile(api, std::move(pin), action);
  }
  if (!FreeLibrary(module) && reply.success) {
    reply.success = false; ClearMaterial(&reply);
    reply.step = "FreeLibrary"; reply.windows_error = GetLastError();
  }
  return reply;
}
}  // namespace cps_windows
