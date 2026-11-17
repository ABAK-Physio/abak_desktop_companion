#include "document_controls_docx_plan.h"

#include <cstdint>
#include <stdexcept>

namespace document_controls {
namespace {

bool DrivePath(const std::wstring& path) {
  if (path.size() < 4 || path.size() > 240 ||
      !((path[0] >= L'A' && path[0] <= L'Z') ||
        (path[0] >= L'a' && path[0] <= L'z')) ||
      path[1] != L':' || path[2] != L'\\') return false;
  std::size_t start = 3;
  for (std::size_t i = 3; i <= path.size(); ++i) {
    if (i != path.size() && path[i] != L'\\') {
      const auto c = path[i];
      if (c < 32 || c == L'/' || c == L':' || c == L'"' ||
          c == L'<' || c == L'>' || c == L'|' || c == L'?' || c == L'*')
        return false;
      continue;
    }
    const auto component = path.substr(start, i - start);
    if (component.empty() || component == L"." || component == L".." ||
        component.back() == L'.' || component.back() == L' ') return false;
    start = i + 1;
  }
  return true;
}

std::wstring LowerAscii(std::wstring value) {
  for (auto& c : value) if (c >= L'A' && c <= L'Z') c += L'a' - L'A';
  return value;
}

void Utf8(std::uint32_t code, std::string* bytes) {
  if (code <= 0x7f) bytes->push_back(static_cast<char>(code));
  else if (code <= 0x7ff) {
    bytes->push_back(static_cast<char>(0xc0 | (code >> 6)));
    bytes->push_back(static_cast<char>(0x80 | (code & 63)));
  } else if (code <= 0xffff) {
    bytes->push_back(static_cast<char>(0xe0 | (code >> 12)));
    bytes->push_back(static_cast<char>(0x80 | ((code >> 6) & 63)));
    bytes->push_back(static_cast<char>(0x80 | (code & 63)));
  } else {
    bytes->push_back(static_cast<char>(0xf0 | (code >> 18)));
    bytes->push_back(static_cast<char>(0x80 | ((code >> 12) & 63)));
    bytes->push_back(static_cast<char>(0x80 | ((code >> 6) & 63)));
    bytes->push_back(static_cast<char>(0x80 | (code & 63)));
  }
}

// Profile URLs must percent-encode UTF-8, not ANSI or individual UTF-16 units.
std::wstring FileUri(const std::wstring& path) {
  std::string bytes;
  for (std::size_t i = 0; i < path.size(); ++i) {
    auto code = static_cast<std::uint32_t>(path[i]);
    if (code >= 0xd800 && code <= 0xdbff) {
      if (++i == path.size()) throw std::invalid_argument("Invalid UTF-16");
      const auto low = static_cast<std::uint32_t>(path[i]);
      if (low < 0xdc00 || low > 0xdfff)
        throw std::invalid_argument("Invalid UTF-16");
      code = 0x10000 + ((code - 0xd800) << 10) + (low - 0xdc00);
    } else if ((code >= 0xdc00 && code <= 0xdfff) || code > 0x10ffff) {
      throw std::invalid_argument("Invalid Unicode");
    }
    Utf8(code == '\\' ? '/' : code, &bytes);
  }
  constexpr wchar_t hex[] = L"0123456789ABCDEF";
  std::wstring uri = L"file:///";
  for (unsigned char byte : bytes) {
    if ((byte >= 'a' && byte <= 'z') || (byte >= 'A' && byte <= 'Z') ||
        (byte >= '0' && byte <= '9') || byte == '-' || byte == '_' ||
        byte == '.' || byte == '~' || byte == '/' || byte == ':') {
      uri += static_cast<wchar_t>(byte);
    } else {
      uri += L'%'; uri += hex[byte >> 4]; uri += hex[byte & 15];
    }
  }
  return uri + L'/';
}
}  // namespace

std::wstring QuoteWindowsArgument(const std::wstring& argument) {
  if (argument.find(L'\0') != std::wstring::npos)
    throw std::invalid_argument("NUL in process argument");
  std::wstring result = L"\"";
  std::size_t slashes = 0;
  for (wchar_t c : argument) {
    if (c == L'\\') { ++slashes; continue; }
    if (c == L'"') {
      result.append(slashes * 2 + 1, L'\\'); result += c;
    } else {
      result.append(slashes, L'\\'); result += c;
    }
    slashes = 0;
  }
  result.append(slashes * 2, L'\\'); result += L'"';
  return result;
}

const std::wstring& DocxPdfaExportFilter() {
  static const std::wstring filter =
      LR"(pdf:writer_pdf_Export:{"SelectPdfVersion":{"type":"long","value":"1"},"UseTaggedPDF":{"type":"boolean","value":"true"},"ExportFormFields":{"type":"boolean","value":"false"},"ExportNotes":{"type":"boolean","value":"false"}})";
  return filter;
}

const std::string& DocxPrivateProfileXml() {
  static const std::string xml = R"(<?xml version="1.0" encoding="UTF-8"?>
<oor:items xmlns:oor="http://openoffice.org/2001/registry">
<item oor:path="/org.openoffice.Office.Common/Security/Scripting"><prop oor:name="DisableMacrosExecution" oor:op="fuse"><value>true</value></prop><prop oor:name="MacroSecurityLevel" oor:op="fuse"><value>3</value></prop></item>
<item oor:path="/org.openoffice.Office.Writer/Content/Update"><prop oor:name="Link" oor:op="fuse"><value>2</value></prop></item>
</oor:items>)";
  return xml;
}

bool BuildDocxConversionPlan(const std::wstring& office,
                             const std::wstring& job,
                             DocxConversionPlan* plan,
                             std::string* error) {
  if (error) error->clear();
  if (!plan) { if (error) *error = "INVALID_ARGUMENTS"; return false; }
  *plan = {};
  const auto normalized = LowerAscii(office);
  constexpr wchar_t suffix[] = L"\\program\\soffice.exe";
  if (!DrivePath(office) || !DrivePath(job) || job.size() > 180 ||
      normalized.size() < std::wstring(suffix).size() ||
      normalized.compare(normalized.size() - std::wstring(suffix).size(),
                         std::wstring(suffix).size(), suffix) != 0) {
    if (error) *error = "INVALID_LOCAL_CONVERSION_PATH";
    return false;
  }
  DocxConversionPlan candidate;
  candidate.executable = office;
  candidate.working_directory = job;
  candidate.source_path = job + L"\\source.docx";
  candidate.output_path = job + L"\\source.pdf";
  candidate.profile_path = job + L"\\office";
  candidate.profile_settings_path = candidate.profile_path +
      L"\\user\\registrymodifications.xcu";
  std::wstring profile_uri;
  try { profile_uri = FileUri(candidate.profile_path); }
  catch (const std::invalid_argument&) {
    if (error) *error = "INVALID_LOCAL_CONVERSION_PATH";
    return false;
  }
  candidate.arguments = {
      L"-env:UserInstallation=" + profile_uri,
      L"--headless", L"--nologo", L"--nodefault", L"--norestore",
      L"--nolockcheck", L"--convert-to", DocxPdfaExportFilter(),
      L"--outdir", job, candidate.source_path};
  *plan = candidate;
  return true;
}

std::wstring DocxCommandLine(const DocxConversionPlan& plan) {
  std::wstring command = QuoteWindowsArgument(plan.executable);
  for (const auto& argument : plan.arguments)
    command += L" " + QuoteWindowsArgument(argument);
  return command;
}
}  // namespace document_controls
