#include "../runner/document_controls_docx_plan.h"
#include <cstdlib>
#include <iostream>
#include <stdexcept>
#include <vector>
#ifdef _WIN32
#include <windows.h>
#include <shellapi.h>
#pragma comment(lib, "shell32.lib")
#endif

void Check(bool value, const char* message) {
  if (!value) { std::cerr << message << '\n'; std::exit(1); }
}

int main() {
  using namespace document_controls;
  DocxConversionPlan plan;
  std::string error;
  const auto office = LR"(C:\Program Files\LibreOffice\program\soffice.exe)";
  Check(BuildDocxConversionPlan(office, LR"(C:\Private\job 1)", &plan, &error),
        "Valid paths refused");
  Check(error.empty(), "Stale error");
  Check(plan.arguments.size() == 11, "Argument count");
  Check(plan.arguments.front() ==
        L"-env:UserInstallation=file:///C:/Private/job%201/office/", "Profile URL");
  Check(plan.arguments[7] == DocxPdfaExportFilter(), "Export filter");
  Check(plan.arguments.back() == plan.source_path, "Source path");
  Check(plan.output_path == LR"(C:\Private\job 1\source.pdf)", "Output path");
  Check(BuildDocxConversionPlan(office, L"C:\\Priv\u00e9\\#100% &", &plan, &error),
        "Unicode path refused");
  Check(plan.arguments.front() ==
        L"-env:UserInstallation=file:///C:/Priv%C3%A9/%23100%25%20%26/office/",
        "UTF-8 URL encoding");
  for (const auto& invalid : std::vector<std::wstring>{
      L"", L"C:\\", L"C:relative", L"C:\\a\\..\\b", L"C:\\a\\.\\b",
      L"C:\\bad.\\job", L"C:\\bad \\job", L"C:\\a\\b:stream",
      L"\\\\server\\share\\job", L"\\\\?\\C:\\job", L"C:/job",
      std::wstring(L"C:\\a\0b", 6), std::wstring(L"C:\\") + wchar_t(0xd800)}) {
    Check(!BuildDocxConversionPlan(office, invalid, &plan, &error),
          "Unsafe/noncanonical path accepted");
    Check(plan.executable.empty() && plan.arguments.empty(), "Stale plan");
  }
  Check(!BuildDocxConversionPlan(LR"(C:\fake\cmd.exe)", LR"(C:\Private\job)",
                                &plan, &error), "Wrong executable accepted");
  Check(QuoteWindowsArgument(L"") == L"\"\"", "Empty argument");
  Check(QuoteWindowsArgument(L"C:\\space path\\") == L"\"C:\\space path\\\\\"",
        "Trailing backslash");
  Check(QuoteWindowsArgument(L"a\"b") == L"\"a\\\"b\"", "Embedded quote");
  bool threw = false;
  try { QuoteWindowsArgument(std::wstring(L"a\0b", 3)); }
  catch (const std::invalid_argument&) { threw = true; }
  Check(threw, "NUL argument accepted");
  Check(DocxPrivateProfileXml().find("DisableMacrosExecution") != std::string::npos,
        "Macro policy missing");
#ifdef _WIN32
  // Validate quoting with the actual Windows argument parser as well.
  Check(BuildDocxConversionPlan(office, LR"(C:\Private\job 1)", &plan, &error), "Plan");
  int argc = 0;
  auto argv = CommandLineToArgvW(DocxCommandLine(plan).c_str(), &argc);
  Check(argv != nullptr && argc == 12, "Windows argument parsing");
  Check(std::wstring(argv[0]) == office, "Windows executable parsing");
  for (int i = 1; i < argc; ++i)
    Check(std::wstring(argv[i]) == plan.arguments[static_cast<std::size_t>(i - 1)],
          "Windows argument changed");
  LocalFree(argv);
#endif
  std::cout << "DOCX command/profile tests passed. No process executed.\n";
}
