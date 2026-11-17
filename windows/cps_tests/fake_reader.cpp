// Test target only. Never linked into the delivered reader; no Cryptolib load.
#include "cps_pkcs11_windows.h"
#include <windows.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iterator>

namespace cps_windows {
Reply ReadInstalledCryptolib(Request request) {
  Erase(&request.pin);
  wchar_t mode[80]{};
  GetEnvironmentVariableW(L"ABAK_CPS_TEST", mode, static_cast<DWORD>(std::size(mode)));
  const std::wstring action(mode);
  if (action == L"exit") ExitProcess(37);
  if (action == L"hang") Sleep(INFINITE);
  Reply reply;
  if (action == L"pin-error") { reply.step="C_Login";reply.code=0xa0;return reply; }
  if (action == L"bad-reply") { reply.success=true;return reply; }
  if (action == L"workdir") {
    wchar_t expected[32768]{};
    GetEnvironmentVariableW(L"ABAK_CPS_TEST_DIRECTORY", expected,
        static_cast<DWORD>(std::size(expected)));
    if (std::filesystem::current_path() != std::filesystem::path(expected)) {
      reply.step="LoadLibrary";reply.windows_error=5;return reply;
    }
    const auto file=std::filesystem::path(L"cps-test-"+std::to_wstring(GetCurrentProcessId())+L".tmp");
    bool written=false;
    {std::ofstream out(file);out<<"FAKE_PROVIDER_ONLY";out.flush();written=out.good();}
    std::error_code error;
    const bool removed=std::filesystem::remove(file,error);
    if (!written || !removed || error) {reply.step="LoadLibrary";reply.windows_error=5;return reply;}
  }
  // Unrelated native output must not be confused with protocol bytes.
  std::cout<<"FAKE_CPS_STDOUT"<<std::flush;
  std::cerr<<"FAKE_CPS_STDERR"<<std::flush;
  reply.success=true;reply.slot_count=1;
  reply.objects["CPS_NAME_PS"]={0xe4,5,0x84,3,'A','B','C'};
  reply.objects["CPS_INFO_PS"]={0xed,0};
  reply.objects["CPS_ACTIVITY_01_PS"]={0xee,0};
  return reply;
}
}
