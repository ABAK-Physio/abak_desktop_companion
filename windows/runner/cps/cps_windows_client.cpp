#include "cps_windows_client.h"
#include "cps_wire.h"
#include <windows.h>
#include <shlobj.h>
#include <knownfolders.h>
#include <algorithm>
#include <filesystem>
#include <iomanip>
#include <iterator>
#include <sstream>
#include <system_error>
#include <utility>

namespace cps_windows {
namespace {
class Handle {
 public:
  explicit Handle(HANDLE value = nullptr) : value_(value) {}
  ~Handle() { reset(); }
  Handle(const Handle&) = delete;
  Handle& operator=(const Handle&) = delete;
  HANDLE get() const { return value_; }
  void reset(HANDLE value = nullptr) {
    if (value_ && value_ != INVALID_HANDLE_VALUE) CloseHandle(value_);
    value_ = value;
  }
 private:
  HANDLE value_;
};
std::string Hex(DWORD code) {
  std::ostringstream out;
  out << "0x" << std::uppercase << std::hex << std::setfill('0') << std::setw(8) << code;
  return out.str();
}
struct PinCleanup {
  std::vector<Byte>* pin;
  ~PinCleanup() { Erase(pin); }
};
class Exchange {
 public:
  ~Exchange() {
    if (process_.get() && WaitForSingleObject(process_.get(), 0) == WAIT_TIMEOUT) {
      TerminateProcess(process_.get(), 6);
      WaitForSingleObject(process_.get(), 1000);
    }
  }
  Reply Run(Request command, const std::atomic<bool>* cancelled, DWORD timeout) {
    std::vector<Byte> payload; PinCleanup erase{&payload};
    cancel_ = cancelled;
    if (!EncodeRequest(command, &payload)) return Fail("Le PIN CPS doit contenir de 1 a 16 chiffres.");
    if (Cancelled()) return Fail("Lecture CPS annulee.");
    if (!Start()) return reply_;
    const auto request = MakeHeader(false, static_cast<std::uint32_t>(payload.size()));
    DWORD written = 0;
    if (!WriteFile(input_.get(), request.data(), static_cast<DWORD>(request.size()),
                   &written, nullptr) || written != request.size()) return WinFail("Envoi CPS");
    const BOOL sent = WriteFile(input_.get(), payload.data(), static_cast<DWORD>(payload.size()),
                                &written, nullptr);
    const bool complete = sent && written == payload.size();
    Erase(&payload); Erase(&command.pin); input_.reset();
    if (!complete) return WinFail("Envoi du PIN CPS");
    const ULONGLONG deadline = GetTickCount64() + timeout;
    Header header{};
    if (!ReadExact(header.data(), static_cast<DWORD>(header.size()), deadline)) return reply_;
    std::uint32_t size = 0;
    if (!ParseHeader(header, true, &size)) return Fail("Reponse du lecteur CPS invalide.");
    std::vector<Byte> bytes(size);
    if (!ReadExact(bytes.data(), size, deadline)) return reply_;
    Reply response;
    if (!Decode(bytes, &response) || response.operation != command.operation) return Fail("Contenu du lecteur CPS invalide.");
    // Native logout/close/finalize have completed before this reply is sent.
    if (WaitForSingleObject(process_.get(), 1000) != WAIT_OBJECT_0)
      return Fail("Le lecteur CPS ne s'est pas ferme apres la lecture.");
    DWORD exit_code = 0;
    if (!GetExitCodeProcess(process_.get(), &exit_code)) return WinFail("Fin du lecteur CPS");
    if (exit_code) return Ended(exit_code);
    return response;
  }
 private:
  Handle process_, job_, input_, output_;
  const std::atomic<bool>* cancel_ = nullptr;
  Reply reply_;
  bool Cancelled() const { return cancel_ && cancel_->load(); }
  Reply Fail(const std::string& message) {
    reply_.transport_error = message; return reply_;
  }
  Reply WinFail(const char* step) {
    return Fail(std::string(step) + " : erreur Windows " + Hex(GetLastError()));
  }
  Reply Ended(DWORD code) {
    return Fail("Le processus de lecture CPS s'est arrete (" + Hex(code) +
                "). Companion reste ouvert.");
  }
  bool Start() {
    wchar_t module[32768]{};
    const DWORD count = GetModuleFileNameW(nullptr, module, static_cast<DWORD>(std::size(module)));
    if (!count || count >= std::size(module)) { WinFail("Localisation du lecteur CPS"); return false; }
    const auto executable = (std::filesystem::path(module).parent_path() /
        L"ABAKCpsReader.exe").wstring();
    if (GetFileAttributesW(executable.c_str()) == INVALID_FILE_ATTRIBUTES) {
      Fail("ABAKCpsReader.exe absent. Reinstallez Companion apres compilation."); return false;
    }
    PWSTR base = nullptr;
    const HRESULT folder = SHGetKnownFolderPath(FOLDERID_RoamingAppData,
        KF_FLAG_DEFAULT, nullptr, &base);
    if (FAILED(folder) || !base) {
      if (base) CoTaskMemFree(base);
      Fail("Dossier utilisateur CPS introuvable."); return false;
    }
    const auto work = (std::filesystem::path(base) / L"ABAK Metrics" /
        L"ABAK_CPS" / L"work").wstring();
    CoTaskMemFree(base);
    std::error_code error;
    std::filesystem::create_directories(work, error);
    if (error) { Fail("Dossier de travail CPS inaccessible."); return false; }
    SECURITY_ATTRIBUTES security{sizeof(SECURITY_ATTRIBUTES), nullptr, TRUE};
    HANDLE read = nullptr, write = nullptr;
    if (!CreatePipe(&read, &write, &security, kMaximumRequest + 16)) { WinFail("Canal de requete CPS"); return false; }
    Handle child_input(read); input_.reset(write);
    if (!CreatePipe(&read, &write, &security, 0)) { WinFail("Canal de reponse CPS"); return false; }
    output_.reset(read); Handle child_output(write);
    if (!SetHandleInformation(input_.get(), HANDLE_FLAG_INHERIT, 0) ||
        !SetHandleInformation(output_.get(), HANDLE_FLAG_INHERIT, 0)) {
      WinFail("Heritage des canaux CPS"); return false;
    }
    Handle null_output(CreateFileW(L"NUL", GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE,
        &security, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr));
    if (null_output.get() == INVALID_HANDLE_VALUE) { WinFail("Sortie technique CPS"); return false; }
    SIZE_T attribute_bytes = 0;
    InitializeProcThreadAttributeList(nullptr, 1, 0, &attribute_bytes);
    if (!attribute_bytes) { WinFail("Taille de la liste de handles CPS"); return false; }
    std::vector<Byte> storage(attribute_bytes);
    auto* list = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(storage.data());
    if (!InitializeProcThreadAttributeList(list, 1, 0, &attribute_bytes)) {
      WinFail("Liste de handles CPS"); return false;
    }
    struct Cleanup {
      LPPROC_THREAD_ATTRIBUTE_LIST list;
      ~Cleanup() { DeleteProcThreadAttributeList(list); }
    } cleanup{list};
    std::array<HANDLE, 3> inherited{child_input.get(), child_output.get(), null_output.get()};
    if (!UpdateProcThreadAttribute(list, 0, PROC_THREAD_ATTRIBUTE_HANDLE_LIST,
        inherited.data(), sizeof(inherited), nullptr, nullptr)) {
      WinFail("Handles du lecteur CPS"); return false;
    }
    job_.reset(CreateJobObjectW(nullptr, nullptr));
    if (!job_.get()) { WinFail("Job CPS"); return false; }
    JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
    limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    if (!SetInformationJobObject(job_.get(), JobObjectExtendedLimitInformation,
        &limits, sizeof(limits))) { WinFail("Configuration du job CPS"); return false; }
    STARTUPINFOEXW startup{};
    startup.StartupInfo.cb = sizeof(startup);
    startup.StartupInfo.dwFlags = STARTF_USESTDHANDLES;
    startup.StartupInfo.hStdInput = child_input.get();
    startup.StartupInfo.hStdOutput = null_output.get();
    startup.StartupInfo.hStdError = null_output.get();
    startup.lpAttributeList = list;
    const auto number = [](HANDLE h) { return std::to_wstring(reinterpret_cast<std::uintptr_t>(h)); };
    std::wstring command = L"\"" + executable + L"\" " + number(child_input.get()) +
        L" " + number(child_output.get());
    PROCESS_INFORMATION process{};
    if (!CreateProcessW(executable.c_str(), command.data(), nullptr, nullptr, TRUE,
        CREATE_NO_WINDOW | CREATE_SUSPENDED | EXTENDED_STARTUPINFO_PRESENT,
        nullptr, work.c_str(), &startup.StartupInfo, &process)) {
      WinFail("Lancement du lecteur CPS"); return false;
    }
    process_.reset(process.hProcess); Handle thread(process.hThread);
    if (!AssignProcessToJobObject(job_.get(), process_.get())) {
      WinFail("Association du lecteur CPS au job"); return false;
    }
    if (ResumeThread(thread.get()) == static_cast<DWORD>(-1)) {
      WinFail("Demarrage du lecteur CPS"); return false;
    }
    return true;
  }
  bool ReadExact(void* destination, DWORD size, ULONGLONG deadline) {
    auto* bytes = static_cast<Byte*>(destination);
    while (size) {
      if (Cancelled()) { Fail("Lecture CPS annulee."); return false; }
      if (GetTickCount64() >= deadline) { Fail("Delai de lecture CPS depasse (45 secondes)."); return false; }
      DWORD available = 0;
      if (!PeekNamedPipe(output_.get(), nullptr, 0, nullptr, &available, nullptr)) {
        const DWORD pipe_error = GetLastError();
        if (WaitForSingleObject(process_.get(), 250) == WAIT_OBJECT_0) {
          DWORD code = 0;
          if (GetExitCodeProcess(process_.get(), &code)) { Ended(code); return false; }
        }
        SetLastError(pipe_error); WinFail("Canal du lecteur CPS"); return false;
      }
      if (available) {
        const DWORD wanted = (std::min)(size, available);
        DWORD received = 0;
        if (!ReadFile(output_.get(), bytes, wanted, &received, nullptr) || !received) {
          WinFail("Reception CPS"); return false;
        }
        size -= received; bytes += received;
      } else if (WaitForSingleObject(process_.get(), 10) == WAIT_OBJECT_0) {
        // Drain a complete last reply written immediately before process exit.
        if (PeekNamedPipe(output_.get(), nullptr, 0, nullptr, &available, nullptr) && available) continue;
        DWORD code = 0;
        if (GetExitCodeProcess(process_.get(), &code)) Ended(code);
        else WinFail("Etat du lecteur CPS");
        return false;
      }
    }
    return true;
  }
};
}  // namespace
Reply RunOperation(Request request, const std::atomic<bool>* cancelled, std::uint32_t timeout_ms) {
  Exchange exchange;
  return exchange.Run(std::move(request), cancelled, timeout_ms);
}
Reply RunReader(std::vector<Byte> pin, const std::atomic<bool>* cancelled, std::uint32_t timeout_ms) {
  Exchange exchange;
  Request request; request.pin = std::move(pin);
  return exchange.Run(std::move(request), cancelled, timeout_ms);
}
}  // namespace cps_windows
