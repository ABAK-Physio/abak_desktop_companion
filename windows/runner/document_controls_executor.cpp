// ABAK Desktop Companion - Windows document controls executor.
// Experimental Java version probe is deliberately NOT exposed to Flutter.

#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <userenv.h>
#include <sddl.h>

#include "document_controls_executor.h"

#include <algorithm>
#include <array>
#include <string>
#include <vector>
#include <utility>

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

                // Anonymous pipe, child receives only the write end. Parent reads after exit.
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
                std::wstring command = L"\"" + javaPath + L"\" -version";
                const std::wstring javaDirectory =
                        javaPath.substr(0, javaPath.find_last_of(L"\\/"));
                PROCESS_INFORMATION rawProcess{};
                if (!CreateProcessW(javaPath.c_str(), &command[0], nullptr, nullptr, TRUE,
                                    EXTENDED_STARTUPINFO_PRESENT | CREATE_SUSPENDED | CREATE_NO_WINDOW,
                                    nullptr, javaDirectory.c_str(), &startup.StartupInfo, &rawProcess)) {
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
                if (ResumeThread(thread.value) == static_cast<DWORD>(-1)) {
                    result.message = ErrorText("ResumeThread", GetLastError());
                    TerminateProcess(process.value, 1);
                    return result;
                }
                result.appcontainer_active = true; // Creation used security capabilities; not an independent token test.
                result.job_object_active = true;
                DWORD waited = WaitForSingleObject(process.value, kProbeTimeoutMs);
                if (waited != WAIT_OBJECT_0) {
                    result.message = waited == WAIT_TIMEOUT ? "Java probe timed out" :
                                     ErrorText("WaitForSingleObject", GetLastError());
                    return result; // Job close terminates remaining children.
                }
                DWORD code = 0;
                if (!GetExitCodeProcess(process.value, &code)) {

                    result.message = ErrorText("GetExitCodeProcess", GetLastError());
                    return result;
                }
                result.exit_code = static_cast<int>(code);
                // Close the parent's write handle before draining the pipe.
                CloseHandle(pipeWrite.value);
                pipeWrite.value = nullptr;
                std::array<char, 4096> buffer{};
                DWORD count = 0;
                while (result.standard_error.size() < kMaxCapturedBytes &&
                       ReadFile(pipeRead.value, buffer.data(),
                                static_cast<DWORD>(std::min(buffer.size(),
                                                            kMaxCapturedBytes - result.standard_error.size())),
                                &count, nullptr) && count > 0) {
                    result.standard_error.append(buffer.data(), count);
                }
                result.executed = true;
                result.error_code = code == 0 ? "" : "JAVA_PROBE_FAILED";
                result.message = code == 0 ? "Java version probe completed" : "Java version probe failed";
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
