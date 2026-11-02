// ABAK Desktop Companion - Windows document controls executor.
// Experimental Java version probe is deliberately NOT exposed to Flutter.

#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <userenv.h>
#include <sddl.h>

#include "document_controls_executor.h"

#include <algorithm>
#include <map>
#include <cwchar>
#include <array>
#include <string>
#include <vector>
#include <utility>
#include <thread>

#pragma comment(lib, "userenv.lib")
#pragma comment(lib, "advapi32.lib")

namespace document_controls {
    namespace {

        constexpr DWORD kProbeTimeoutMs = 10000;
        constexpr size_t kMaxCapturedBytes = 64 * 1024;

        struct Handle {
            HANDLE value = nullptr;
            ~Handle() { if (value && value != INVALID_HANDLE_VALUE) CloseHandle(value); }
            Handle() = default;
            Handle(const Handle&) = delete;
            Handle& operator=(const Handle&) = delete;
            HANDLE* put() { return &value; }
        };

        std::string ErrorText(const char* action, unsigned long code) {
            return std::string(action) + " failed (" + std::to_string(code) + ")";
        }

        struct CaseInsensitiveLess {
            bool operator()(const std::wstring& a, const std::wstring& b) const {
                return _wcsicmp(a.c_str(), b.c_str()) < 0;
            }
        };

        // Build a private environment block without inheriting a different JDK.
        // Other inherited variables are retained for Windows and AppContainer compatibility.
        std::vector<wchar_t> JavaEnvironment(const std::wstring& javaPath) {
            std::map<std::wstring, std::wstring, CaseInsensitiveLess> values;
            LPWCH inherited = GetEnvironmentStringsW();
            if (!inherited) return {};
            for (const wchar_t* item = inherited; *item; item += wcslen(item) + 1) {
                const std::wstring entry(item);
                // Preserve Windows' special drive-current-directory entries (=C:=...).
                const size_t equals = entry.find(L'=', entry[0] == L'=' ? 1 : 0);
                if (equals != std::wstring::npos) {
                    values[entry.substr(0, equals)] = entry.substr(equals + 1);
                }
            }
            FreeEnvironmentStringsW(inherited);

            const size_t slash = javaPath.find_last_of(L"\\/");
            if (slash == std::wstring::npos) return {};
            const std::wstring bin = javaPath.substr(0, slash);
            const size_t homeSlash = bin.find_last_of(L"\\/");
            if (homeSlash == std::wstring::npos) return {};
            const std::wstring home = bin.substr(0, homeSlash);

            // Avoid Java options or classpaths inherited from the developer machine.
            for (const auto* name : {L"JDK_JAVA_OPTIONS", L"JAVA_TOOL_OPTIONS",
                                     L"_JAVA_OPTIONS", L"CLASSPATH", L"JRE_HOME"}) {
                values.erase(name);
            }
            values[L"JAVA_HOME"] = home;
            const auto previousPath = values.find(L"PATH");
            const std::wstring oldPath = previousPath == values.end() ? L"" : previousPath->second;
            values[L"PATH"] = bin + (oldPath.empty() ? L"" : L";" + oldPath);

            std::vector<wchar_t> block;
            for (const auto& [name, value] : values) {
                const std::wstring entry = name + L"=" + value;
                block.insert(block.end(), entry.begin(), entry.end());
                block.push_back(L'\0');
            }
            block.push_back(L'\0');
            if (block.size() == 1) block.push_back(L'\0');
            return block;
        }

// Prototype-only function. This is not a proof of network or filesystem isolation.
// It is not called from ExecuteSecurely or the Flutter method channel.
        ExecutionResult ProbeJavaVersionInAppContainer(const std::wstring& javaPath) {
            ExecutionResult result;
            result.error_code = "PROBE_FAILED";
            if (javaPath.empty() || GetFileAttributesW(javaPath.c_str()) == INVALID_FILE_ATTRIBUTES) {
                result.message = "Java executable unavailable";
                return result;
            }

            // A unique profile avoids collision with other experiments and existing profiles.
            const std::wstring profile = L"ABAK.DocumentControls.Probe." +
                                         std::to_wstring(GetCurrentProcessId()) + L"." +
                                         std::to_wstring(GetTickCount64());
            PSID sid = nullptr;
            HRESULT hr = CreateAppContainerProfile(profile.c_str(), L"ABAK probe",
                                                   L"Temporary Java version probe", nullptr, 0, &sid);
            if (FAILED(hr)) {
                result.message = ErrorText("CreateAppContainerProfile", static_cast<unsigned long>(hr));
                return result;
            }

            // Scope ensures all handles and the profile are released on every return path.
            {
                struct ProfileGuard {
                    const std::wstring& name;
                    PSID sid;
                    ~ProfileGuard() {
                        if (sid) FreeSid(sid);
                        DeleteAppContainerProfile(name.c_str());
                    }
                } guard{profile, sid};

                SECURITY_CAPABILITIES caps{};
                caps.AppContainerSid = sid;
                SIZE_T attributeBytes = 0;
                InitializeProcThreadAttributeList(nullptr, 2, 0, &attributeBytes);
                if (!attributeBytes) {
                    result.message = "Attribute list sizing failed";
                    return result;
                }
                std::vector<unsigned char> attributeMemory(attributeBytes);
                auto* attributes = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(attributeMemory.data());
                if (!InitializeProcThreadAttributeList(attributes, 2, 0, &attributeBytes)) {
                    result.message = ErrorText("InitializeProcThreadAttributeList", GetLastError());
                    return result;
                }
                struct AttributeGuard {
                    LPPROC_THREAD_ATTRIBUTE_LIST list;
                    ~AttributeGuard() { DeleteProcThreadAttributeList(list); }
                } attributeGuard{attributes};

                if (!UpdateProcThreadAttribute(attributes, 0,
                                               PROC_THREAD_ATTRIBUTE_SECURITY_CAPABILITIES, &caps, sizeof(caps),
                                               nullptr, nullptr)) {
                    result.message = ErrorText("Security capabilities", GetLastError());
                    return result;
                }

                // Anonymous pipe: drain concurrently to prevent Java blocking on a full pipe.
                SECURITY_ATTRIBUTES pipeSecurity{};
                pipeSecurity.nLength = sizeof(pipeSecurity);
                pipeSecurity.bInheritHandle = TRUE;
                Handle pipeRead, pipeWrite;
                if (!CreatePipe(pipeRead.put(), pipeWrite.put(), &pipeSecurity, 0) ||
                    !SetHandleInformation(pipeRead.value, HANDLE_FLAG_INHERIT, 0)) {
                    result.message = ErrorText("CreatePipe", GetLastError());
                    return result;
                }

                // Restrict handle inheritance to the one output handle.
                HANDLE inherited[] = {pipeWrite.value};
                if (!UpdateProcThreadAttribute(attributes, 0,
                                               PROC_THREAD_ATTRIBUTE_HANDLE_LIST, inherited, sizeof(inherited),
                                               nullptr, nullptr)) {
                    result.message = ErrorText("Handle list", GetLastError());
                    return result;
                }

                Handle job;
                job.value = CreateJobObjectW(nullptr, nullptr);
                if (!job.value) {
                    result.message = ErrorText("CreateJobObject", GetLastError());
                    return result;
                }
                JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
                limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
                if (!SetInformationJobObject(job.value, JobObjectExtendedLimitInformation,
                                             &limits, sizeof(limits))) {
                    result.message = ErrorText("SetInformationJobObject", GetLastError());
                    return result;
                }

                STARTUPINFOEXW startup{};
                startup.StartupInfo.cb = sizeof(startup);
                startup.lpAttributeList = attributes;
                startup.StartupInfo.dwFlags = STARTF_USESTDHANDLES;
                startup.StartupInfo.hStdOutput = pipeWrite.value;
                startup.StartupInfo.hStdError = pipeWrite.value;
                startup.StartupInfo.hStdInput = nullptr;
                std::wstring command =
                        L"\"" + javaPath + L"\" -version";
                const std::wstring javaDirectory =
                        javaPath.substr(0, javaPath.find_last_of(L"\\/"));
                const auto environment = JavaEnvironment(javaPath);
                if (environment.empty()) {
                    result.message = "Cannot build Java process environment";
                    return result;
                }
                PROCESS_INFORMATION rawProcess{};
                if (!CreateProcessW(javaPath.c_str(), &command[0], nullptr, nullptr, TRUE,
                                    EXTENDED_STARTUPINFO_PRESENT | CREATE_SUSPENDED |
                                    CREATE_NO_WINDOW | CREATE_UNICODE_ENVIRONMENT,
                                    const_cast<wchar_t*>(environment.data()), javaDirectory.c_str(),
                                    &startup.StartupInfo, &rawProcess)) {
                    result.message = ErrorText("CreateProcessW", GetLastError());
                    return result;
                }
                Handle process, thread;
                process.value = rawProcess.hProcess;
                thread.value = rawProcess.hThread;
                if (!AssignProcessToJobObject(job.value, process.value)) {
                    result.message = ErrorText("AssignProcessToJobObject", GetLastError());
                    TerminateProcess(process.value, 1);
                    return result;
                }
                // The parent must not keep the write end open, or EOF will never arrive.
                CloseHandle(pipeWrite.value);
                pipeWrite.value = nullptr;

                // Read while the child is running. Keep at most 64 KiB, but
                // continue draining excess output so the child cannot block.
                std::thread reader([&]() {
                    std::array<char, 4096> buffer{};
                    DWORD count = 0;
                    while (ReadFile(pipeRead.value, buffer.data(),
                                    static_cast<DWORD>(buffer.size()),
                                    &count, nullptr) && count != 0) {
                        if (result.standard_error.size() < kMaxCapturedBytes) {
                            const size_t remaining = kMaxCapturedBytes - result.standard_error.size();
                            result.standard_error.append(buffer.data(),
                                                         std::min<size_t>(remaining, count));
                        }
                    }
                });

                if (ResumeThread(thread.value) == static_cast<DWORD>(-1)) {
                    result.message = ErrorText("ResumeThread", GetLastError());
                    TerminateProcess(process.value, 1);
                } else {
                    // These flags reflect requested launch mechanisms, not an
                    // independent security verification.
                    result.appcontainer_active = true;
                    result.job_object_active = true;
                    const DWORD waited = WaitForSingleObject(process.value, kProbeTimeoutMs);
                    if (waited == WAIT_OBJECT_0) {
                        DWORD code = 0;
                        if (GetExitCodeProcess(process.value, &code)) {
                            result.exit_code = static_cast<int>(code);
                            result.executed = true;
                            result.error_code = code == 0 ? "" : "JAVA_PROBE_FAILED";
                            result.message = code == 0 ? "Java version probe completed"
                                                       : "Java version probe failed";
                        } else {
                            result.message = ErrorText("GetExitCodeProcess", GetLastError());
                        }
                    } else {
                        result.message = waited == WAIT_TIMEOUT ? "Java probe timed out"
                                                                : ErrorText("WaitForSingleObject", GetLastError());
                    }
                }

                // Kill any remaining job processes and close inherited pipe
                // writers before waiting for the reader to reach EOF.
                CloseHandle(job.value);
                job.value = nullptr;
                reader.join();
                // No network or filesystem guarantees have been verified by this probe.
                return result;
            }
        }

    }  // namespace

    ExecutionResult ExecuteSecurely(const ExecutionRequest& request) {
        if (request.operation != "pdfa" && request.operation != "version" &&
            request.operation != "cda") {
            return {false, -1, "", "", "INVALID_OPERATION",
                    "Operation documentaire non autorisee."};
        }
        // Deliberately fail closed: probe cannot be invoked through this entry point.
        return {false, -1, "", "", "WINDOWS_ISOLATION_UNAVAILABLE",
                "L'isolation native des controles documentaires Windows "
                "n'est pas encore qualifiee."};
    }

}  // namespace document_controls
