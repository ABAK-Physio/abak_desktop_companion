#pragma once
#include <cstdint>
#include <string>

namespace abak_webps {
inline bool SupportedBrowser(const std::string& browser) {
  return browser == "org.mozilla.firefox" || browser == "com.microsoft.edge";
}
inline bool ValidSessionName(const std::wstring& name) {
  if (name.size() != 46 || name.compare(0, 9, L"session-{") != 0 || name[45] != L'}') return false;
  for (std::size_t i = 9; i < 45; ++i) {
    if (i == 17 || i == 22 || i == 27 || i == 32) { if (name[i] != L'-') return false; }
    else if (!((name[i] >= L'0' && name[i] <= L'9') || (name[i] >= L'a' && name[i] <= L'f') ||
        (name[i] >= L'A' && name[i] <= L'F'))) return false;
  }
  return true;
}
inline bool ValidUrl(const std::string& url) {
  const std::string root = "https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/";
  if (url == root + "TableauDeBord") return true;
  const std::string prefix = root + "DossierPatient/";
  const std::string suffix = "/1.2.250.1.213.1.4.10";
  if (url.size() != prefix.size() + 15 + suffix.size() ||
      url.compare(0, prefix.size(), prefix) != 0 ||
      url.compare(prefix.size() + 15, suffix.size(), suffix) != 0) return false;
  const auto ins = url.substr(prefix.size(), 15);
  if (ins[0] != '1' && ins[0] != '2') return false;
  std::uint64_t number = 0;
  for (std::size_t i = 0; i < ins.size(); ++i) {
    if (ins[i] < '0' || ins[i] > '9') return false;
    if (i < 13) number = number * 10 + static_cast<unsigned>(ins[i] - '0');
  }
  return 97 - number % 97 == static_cast<unsigned>((ins[13] - '0') * 10 + ins[14] - '0');
}

/// Windows CreateProcess argument quoting, including trailing backslashes.
inline std::wstring Quote(const std::wstring& value) {
  std::wstring result = L"\"";
  std::size_t slashes = 0;
  for (const wchar_t c : value) {
    if (c == L'\\') { ++slashes; continue; }
    result.append(slashes * (c == L'\"' ? 2 : 1), L'\\');
    slashes = 0;
    if (c == L'\"') result += L'\\';
    result += c;
  }
  result.append(slashes * 2, L'\\');
  return result + L'\"';
}
inline std::wstring CommandLine(const std::string& browser, const std::wstring& executable,
    const std::wstring& profile, const std::wstring& address) {
  if (!SupportedBrowser(browser)) return {};
  if (browser == "com.microsoft.edge")
    return Quote(executable) + L" --no-first-run --no-default-browser-check --disable-background-mode --disable-sync --user-data-dir=" +
        Quote(profile) + L" --new-window " + Quote(address);
  return Quote(executable) + L" --no-remote --new-instance --profile " +
      Quote(profile) + L" --new-window " + Quote(address);
}
}
