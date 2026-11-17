#pragma once
#include <cstddef>
#include <cstdint>
#include <map>
#include <string>
#include <vector>

namespace document_controls_runtime {
using CdaReportFiles = std::map<std::string, std::vector<std::uint8_t>>;
inline constexpr std::size_t MaxCdaReports = 12 * 1024 * 1024;
const std::vector<std::string>& CdaReportNames();
bool ValidCdaReferencePath(const std::string& path);
bool IncludedCdaReference(const std::string& path);
std::string CdaReferenceFingerprintInput(const std::map<std::string, std::string>& files);
std::vector<std::uint8_t> PackCdaReports(const CdaReportFiles& files);
CdaReportFiles UnpackCdaReports(const std::vector<std::uint8_t>& bytes);
}
