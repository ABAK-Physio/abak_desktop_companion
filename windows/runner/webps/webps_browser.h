#pragma once
#include <windows.h>
#include <atomic>
#include <filesystem>
#include <string>

namespace abak_webps {
struct State { bool active = false; std::string browser; };
class Browser {
 public:
  ~Browser();
  static std::wstring Find(const std::string& browser);
  State Status();
  State Open(const std::string& browser, const std::string& url, const std::atomic<bool>& cancelled);
  State Close();
 private:
  HANDLE job_ = nullptr;
  HANDLE lock_ = INVALID_HANDLE_VALUE;
  std::filesystem::path session_;
  std::string browser_;
  DWORD Processes();
  void Cleanup();
};
std::string Utf8(const std::wstring& value);
}
