#include "webps_browser.h"
#include "webps_policy.h"
#include <shlobj.h>
#include <objbase.h>
#include <fstream>
#include <stdexcept>
#include <vector>

namespace abak_webps {
namespace fs = std::filesystem;
namespace {
fs::path Known(REFKNOWNFOLDERID id) {
  PWSTR value = nullptr;
  if (FAILED(SHGetKnownFolderPath(id, 0, nullptr, &value)))
    throw std::runtime_error("Dossier Windows du navigateur indisponible.");
  fs::path path(value); CoTaskMemFree(value); return path;
}
fs::path Root() {
  auto root = Known(FOLDERID_LocalAppData) / L"ABAK" / L"Companion" / L"WebPS-DV1";
  std::error_code error;
  fs::create_directories(root, error);
  if (error) throw std::runtime_error("Creation du dossier Web-PS impossible.");
  if (GetFileAttributesW(root.c_str()) & FILE_ATTRIBUTE_REPARSE_POINT)
    throw std::runtime_error("Dossier Web-PS redirige non pris en charge.");
  return root;
}
HANDLE Lock(const fs::path& root) {
  return CreateFileW((root / L"browser.lock").c_str(), GENERIC_READ | GENERIC_WRITE | DELETE,
      0, nullptr, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_DELETE_ON_CLOSE, nullptr);
}
void RemoveSession(const fs::path& path) {
  if (path.empty()) return;
  std::error_code error;
  const bool exists = fs::exists(path, error);
  if (error) throw std::runtime_error("Etat du profil DMP indisponible.");
  if (!exists) return;
  const auto attr = GetFileAttributesW(path.c_str());
  if (attr == INVALID_FILE_ATTRIBUTES || (attr & FILE_ATTRIBUTE_REPARSE_POINT))
    throw std::runtime_error("Nettoyage du profil DMP non confirme.");
  fs::remove_all(path, error);
  if (error) throw std::runtime_error("Nettoyage du profil DMP non confirme.");
}
BOOL CALLBACK CloseWindow(HWND window, LPARAM parameter) {
  DWORD pid = 0; GetWindowThreadProcessId(window, &pid);
  HANDLE process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  BOOL owned = FALSE;
  if (process) {
    if (IsProcessInJob(process, reinterpret_cast<HANDLE>(parameter), &owned) && owned)
      PostMessageW(window, WM_CLOSE, 0, 0);
    CloseHandle(process);
  }
  return TRUE;
}
}
std::string Utf8(const std::wstring& value) {
  const int n = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
  if (n <= 0) throw std::runtime_error("Chemin navigateur illisible.");
  std::string out(static_cast<std::size_t>(n), '\0');
  if (WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), out.data(), n, nullptr, nullptr) != n)
    throw std::runtime_error("Chemin navigateur illisible.");
  return out;
}
std::wstring Browser::Find(const std::string& browser) {
  if (!SupportedBrowser(browser)) throw std::runtime_error("Navigateur DMP non pris en charge.");
  for (const auto id : {FOLDERID_ProgramFiles, FOLDERID_ProgramFilesX86, FOLDERID_LocalAppData}) {
    try {
      const auto path = browser == "com.microsoft.edge"
          ? Known(id) / L"Microsoft" / L"Edge" / L"Application" / L"msedge.exe"
          : Known(id) / L"Mozilla Firefox" / L"firefox.exe";
      DWORD type = 0;
      if (GetBinaryTypeW(path.c_str(), &type) && (type == SCS_32BIT_BINARY || type == SCS_64BIT_BINARY))
        return path.wstring();
    } catch (...) { /* Try the next standard location; never start discovery. */ }
  }
  throw std::runtime_error("Navigateur choisi introuvable dans les emplacements Windows pris en charge.");
}
DWORD Browser::Processes() {
  JOBOBJECT_BASIC_ACCOUNTING_INFORMATION info{};
  if (!job_ || !QueryInformationJobObject(job_, JobObjectBasicAccountingInformation, &info, static_cast<DWORD>(sizeof(info)), nullptr))
    throw std::runtime_error("Etat de navigateur indisponible : fermeture non confirmee.");
  return info.ActiveProcesses;
}
void Browser::Cleanup() {
  if (job_) { CloseHandle(job_); job_ = nullptr; }
  RemoveSession(session_); session_.clear(); browser_.clear();
  if (lock_ != INVALID_HANDLE_VALUE) { CloseHandle(lock_); lock_ = INVALID_HANDLE_VALUE; }
}
State Browser::Status() {
  if (job_) {
    if (Processes() != 0) return {true, browser_};
    Cleanup();
  } else if (!session_.empty()) Cleanup();
  if (lock_ != INVALID_HANDLE_VALUE) return {true, browser_};
  const auto probe = Lock(Root());
  if (probe == INVALID_HANDLE_VALUE) return {true, {}};
  CloseHandle(probe);
  return {};
}
State Browser::Open(const std::string& browser, const std::string& url, const std::atomic<bool>& cancelled) {
  if (!ValidUrl(url)) throw std::runtime_error("Adresse Web-PS DV1 refusee.");
  if (Status().active) throw std::runtime_error("Fermez l'acces Web-PS deja ouvert avant de continuer.");
  const auto executable = Find(browser);
  const auto root = Root();
  lock_ = Lock(root);
  if (lock_ == INVALID_HANDLE_VALUE) throw std::runtime_error("Un autre acces Web-PS est en cours.");
  try {
    // Only our GUID-named profiles, after obtaining the exclusive process lock.
    // A previous crashed owner had a non-inheritable kill-on-close job handle.
    std::error_code error;
    auto entries = fs::directory_iterator(root, error);
    if (error) throw std::runtime_error("Lecture du dossier Web-PS impossible.");
    for (; entries != fs::directory_iterator(); entries.increment(error)) {
      if (error) throw std::runtime_error("Lecture du dossier Web-PS interrompue.");
      if (ValidSessionName(entries->path().filename().wstring())) RemoveSession(entries->path());
    }
    if (error) throw std::runtime_error("Lecture du dossier Web-PS interrompue.");
    GUID guid{}; wchar_t name[40]{};
    if (FAILED(CoCreateGuid(&guid)) || !StringFromGUID2(guid, name, 40))
      throw std::runtime_error("Profil navigateur reserve indisponible.");
    session_ = root / (std::wstring(L"session-") + name);
    const auto profile = session_ / L"profile";
    if (!fs::create_directory(session_, error) || error)
      throw std::runtime_error("Creation du profil DMP impossible.");
    if (!fs::create_directory(profile, error) || error)
      throw std::runtime_error("Creation du profil navigateur impossible.");
    if (browser == "org.mozilla.firefox") {
    std::ofstream prefs(profile / L"user.js", std::ios::binary);
    prefs << "user_pref(\"security.osclientcerts.autoload\", true);\n"
          << "user_pref(\"security.enterprise_roots.enabled\", true);\n"
          << "user_pref(\"security.default_personal_cert\", \"Ask Every Time\");\n"
          << "user_pref(\"browser.shell.checkDefaultBrowser\", false);\n"
          << "user_pref(\"browser.startup.page\", 0);\n"
          << "user_pref(\"browser.sessionstore.resume_from_crash\", false);\n"
          << "user_pref(\"signon.rememberSignons\", false);\n"
          << "user_pref(\"browser.aboutwelcome.enabled\", false);\n"
          << "user_pref(\"browser.startup.homepage_override.mstone\", \"ignore\");\n";
    prefs.close();
    if (!prefs) throw std::runtime_error("Preparation du profil navigateur impossible.");
    }
    if (cancelled.load()) { Cleanup(); return {}; }
    job_ = CreateJobObjectW(nullptr, nullptr);
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
    limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    if (!job_ || !SetInformationJobObject(job_, JobObjectExtendedLimitInformation, &limits, static_cast<DWORD>(sizeof(limits))))
      throw std::runtime_error("Isolation du navigateur indisponible.");
    // Atomically join the job at creation: no orphan suspended process on crash.
    SIZE_T size = 0;
    InitializeProcThreadAttributeList(nullptr, 1, 0, &size);
    std::vector<unsigned char> storage(size);
    STARTUPINFOEXW startup{}; startup.StartupInfo.cb = static_cast<DWORD>(sizeof(startup));
    startup.lpAttributeList = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(storage.data());
    if (!InitializeProcThreadAttributeList(startup.lpAttributeList, 1, 0, &size))
      throw std::runtime_error("Preparation du processus navigateur impossible.");
    const bool attributes = UpdateProcThreadAttribute(startup.lpAttributeList, 0,
        PROC_THREAD_ATTRIBUTE_JOB_LIST, &job_, sizeof(job_), nullptr, nullptr) != FALSE;
    std::wstring command = CommandLine(browser, executable, profile.wstring(), std::wstring(url.begin(), url.end()));
    PROCESS_INFORMATION process{};
    const bool started = attributes && CreateProcessW(executable.c_str(), command.data(), nullptr, nullptr,
        FALSE, EXTENDED_STARTUPINFO_PRESENT, nullptr, nullptr, &startup.StartupInfo, &process);
    DeleteProcThreadAttributeList(startup.lpAttributeList);
    if (!started) throw std::runtime_error("Le navigateur n'a pas pu demarrer dans son instance DMP.");
    CloseHandle(process.hThread); CloseHandle(process.hProcess);
    browser_ = Utf8(executable);
    // Let the launcher hand off to its browser children; account for the whole job.
    for (int i = 0; i < 10 && !cancelled.load(); ++i) Sleep(50);
    if (cancelled.load()) return Close();
    if (Processes() == 0) { Cleanup(); throw std::runtime_error("Le navigateur s'est ferme avant confirmation de son ouverture."); }
    return {true, browser_};
  } catch (...) {
    // Never release ownership if the process tree or profile closure is uncertain.
    try { Close(); } catch (...) {}
    throw;
  }
}
State Browser::Close() {
  if (!job_) {
    if (lock_ == INVALID_HANDLE_VALUE && Status().active)
      throw std::runtime_error("Cet acces Web-PS appartient a une autre instance de Companion.");
    Cleanup(); return {};
  }
  EnumWindows(CloseWindow, reinterpret_cast<LPARAM>(job_));
  for (int i = 0; i < 30 && Processes() != 0; ++i) Sleep(50);
  if (Processes() != 0 && !TerminateJobObject(job_, 0))
    throw std::runtime_error("Fermeture de l'instance navigateur DMP non confirmee.");
  for (int i = 0; i < 60 && Processes() != 0; ++i) Sleep(50);
  if (Processes() != 0) throw std::runtime_error("Processus navigateur DMP encore actif.");
  Cleanup(); return {};
}
Browser::~Browser() {
  try { Close(); } catch (...) {
    if (job_) CloseHandle(job_); // Kernel kills only our process tree.
    if (lock_ != INVALID_HANDLE_VALUE) CloseHandle(lock_);
  }
}
}
