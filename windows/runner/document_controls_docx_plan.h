#ifndef RUNNER_DOCUMENT_CONTROLS_DOCX_PLAN_H_
#define RUNNER_DOCUMENT_CONTROLS_DOCX_PLAN_H_

#include <string>
#include <vector>

namespace document_controls {

// Command data only. This object is NOT an execution capability or evidence.
// The service must verify the installed engine, private workspace, token, WFP,
// process job and source hash before starting anything described by this plan.
struct DocxConversionPlan {
  std::wstring executable;
  std::wstring working_directory;
  std::wstring source_path;
  std::wstring output_path;
  std::wstring profile_path;
  std::wstring profile_settings_path;
  std::vector<std::wstring> arguments;
};

std::wstring QuoteWindowsArgument(const std::wstring& argument);
std::wstring DocxCommandLine(const DocxConversionPlan& plan);
const std::string& DocxPrivateProfileXml();
const std::wstring& DocxPdfaExportFilter();

// job is a new private service-owned directory; source.docx must already have
// been checked and copied there. Paths are local drive paths, never UNC/device.
// Returns false and clears plan on failure. Does not touch the filesystem.
bool BuildDocxConversionPlan(const std::wstring& office_executable,
                             const std::wstring& job,
                             DocxConversionPlan* plan,
                             std::string* error);

}  // namespace document_controls
#endif
