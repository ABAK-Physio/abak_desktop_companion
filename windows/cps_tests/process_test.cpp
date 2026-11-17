#include "cps_windows_client.h"
#include <windows.h>
#include <shlobj.h>
#include <knownfolders.h>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <iterator>
#include <thread>

using namespace cps_windows;
namespace {
int checks=0;
void Check(bool condition,const char* name){if(!condition){std::cerr<<name<<'\n';std::exit(1);}++checks;}
}
int main(){
  std::atomic<bool> cancel{false};
  const auto original=std::filesystem::current_path();
  wchar_t system[32768]{};
  Check(GetSystemDirectoryW(system,static_cast<UINT>(std::size(system)))!=0,"system directory");
  std::filesystem::current_path(system);
  PWSTR base=nullptr;
  Check(SUCCEEDED(SHGetKnownFolderPath(FOLDERID_RoamingAppData,KF_FLAG_DEFAULT,nullptr,&base))&&base,"profile directory");
  const auto expected=(std::filesystem::path(base)/L"ABAK Metrics"/L"ABAK_CPS"/L"work").wstring();
  CoTaskMemFree(base);
  SetEnvironmentVariableW(L"ABAK_CPS_TEST_DIRECTORY",expected.c_str());
  for(const auto* mode:{L"success",L"workdir",L"pin-error",L"bad-reply",L"exit",L"hang"}){
    SetEnvironmentVariableW(L"ABAK_CPS_TEST",mode);
    const auto reply=RunReader({'1','2','3','4'},&cancel,1500);
    const std::wstring action(mode);
    if(action==L"success" || action==L"workdir"){
      Check(reply.success&&reply.objects.size()==3&&reply.transport_error.empty(),"fake profile returned");
    }else if(action==L"pin-error"){
      Check(!reply.success&&reply.step=="C_Login"&&reply.code==0xa0&&reply.objects.empty(),"PIN failure contained");
    }else{
      Check(!reply.success&&!reply.transport_error.empty()&&reply.objects.empty(),"process failure contained");
      if(action==L"exit")Check(reply.transport_error.find("0x00000025")!=std::string::npos,"exit code preserved");
      if(action==L"hang")Check(reply.transport_error.find("Delai")!=std::string::npos,"timeout reported");
    }
  }
  cancel.store(true);
  Check(RunReader({'1','2','3','4'},&cancel).transport_error.find("annulee")!=std::string::npos,"pre-launch cancellation");
  cancel.store(false);
  std::thread stop([&cancel]{Sleep(100);cancel.store(true);});
  const auto interrupted=RunReader({'1','2','3','4'},&cancel);
  stop.join();
  Check(interrupted.transport_error.find("annulee")!=std::string::npos,"active cancellation");
  Check(std::filesystem::current_path()==std::filesystem::path(system),"parent directory unchanged");
  Check(RunReader({'x'},nullptr).transport_error.find("PIN CPS")!=std::string::npos,"invalid PIN format rejected");
  SetEnvironmentVariableW(L"ABAK_CPS_TEST",nullptr);
  SetEnvironmentVariableW(L"ABAK_CPS_TEST_DIRECTORY",nullptr);
  std::filesystem::current_path(original);
  std::cout<<checks<<" CPS process checks passed; fake reader only.\n";
}
