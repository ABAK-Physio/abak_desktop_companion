#pragma once
#include "../runner/document_controls_pipe_transport.h"
#include <atomic>
#include <mutex>
#include <string>
#include <vector>
#include <utility>
#include "cda_reports.h"

namespace document_controls_runtime {
using document_controls::windows_ipc::OwnedHandle;
inline constexpr wchar_t PipeName[]=L"\\\\.\\pipe\\ABAK.DocumentControls.Conversion.v1";
inline constexpr char Contract[]="ABAK-WINDOWS-CONVERSION-1";
inline constexpr std::size_t MaxDocument=20*1024*1024;
inline constexpr std::size_t MaxCdaDocument=40*1024*1024;
inline constexpr std::size_t MaxReply=32*1024*1024;
struct Request {
 std::string operation, id, office, input_hash;
 std::uint32_t timeout_ms=240000;
 std::vector<std::uint8_t> input;
};
struct Reply {
 std::string operation, id, error, output, diagnostic;
 std::string input_hash, pdf_hash, reported_path, office_version, office_launcher_hash, office_binary_hash;
 std::uint32_t pid=0;
 int exit_code=-1;
 bool executed=false, network_denied=false, write_restricted=false, job_object=false;
 bool private_profile=false, macros_disabled=false, engine_verified=false;
 std::vector<std::uint8_t> pdf;
 std::vector<std::uint8_t> cda_reports;
 std::string cda_reports_hash, cda_manifest_hash, cda_references_hash, cda_helper_hash;
};
struct ClientCancellation {
 std::atomic<bool> cancelled{false};
 std::mutex mutex;
 HANDLE pipe=INVALID_HANDLE_VALUE; // Borrowed while Exchange owns the handle.
 void Cancel();
};
std::string HashBytes(const std::vector<std::uint8_t>& data);
std::wstring Wide(const std::string& value);
std::string Utf8Text(const std::wstring& value);
std::wstring ApplicationRoot();
Reply Exchange(const Request& request, ClientCancellation* cancellation) noexcept;
void Serve(HANDLE stop,void(*ready)());
Reply RunWorker(const Request& request,HANDLE stop,HANDLE client_process);
struct ToolLease {
 OwnedHandle file;
 std::vector<OwnedHandle> ancestors;
};
struct VerifiedTools {
 std::wstring java, jar;
 std::vector<ToolLease> leases;
};
VerifiedTools LoadTools();
struct CdaResources {
 std::wstring helper, saxon;
 std::string manifest_hash, references_hash, helper_hash;
 std::vector<std::pair<std::wstring, std::string>> copies;
};
CdaResources PrepareCdaResources(const std::wstring& job);
void RecheckCdaResources(const CdaResources& resources);
}
