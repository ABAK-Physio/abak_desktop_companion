#include "cda_reports.h"
#include <algorithm>
#include <array>
#include <stdexcept>

namespace document_controls_runtime {
namespace {
constexpr std::array<std::uint8_t, 8> Magic{'A','B','A','K','C','D','R','1'};
void Check(bool value, const char* text) {
 if (!value) throw std::runtime_error(text);
}
void Put(std::vector<std::uint8_t>* bytes, std::uint32_t value) {
 for (unsigned i = 0; i < 4; ++i) bytes->push_back(static_cast<std::uint8_t>(value >> (8 * i)));
}
std::uint32_t Take(const std::vector<std::uint8_t>& bytes, std::size_t* position) {
 Check(*position <= bytes.size() && bytes.size() - *position >= 4, "Rapport CDA tronque.");
 std::uint32_t value = 0;
 for (unsigned i = 0; i < 4; ++i) value |= static_cast<std::uint32_t>(bytes[(*position)++]) << (8 * i);
 return value;
}
void Validate(const CdaReportFiles& files) {
 Check(files.size() == 7 || files.size() == 8, "Rapports CDA incomplets.");
 for (const auto& name : CdaReportNames())
  if (name != "xsd-error.txt") Check(files.count(name) == 1, "Rapport CDA obligatoire absent.");
 for (const auto& entry : files) {
  Check(std::find(CdaReportNames().begin(), CdaReportNames().end(), entry.first) != CdaReportNames().end(),
      "Nom de rapport CDA interdit.");
  Check(!entry.second.empty() && entry.second.size() <= MaxCdaReports, "Rapport CDA vide ou trop volumineux.");
 }
 const std::string marker(files.at("completed.txt").begin(), files.at("completed.txt").end());
 Check(marker == "ABAK-CDA-1", "Controle CDA non termine.");
}
}
const std::vector<std::string>& CdaReportNames() {
 static const std::vector<std::string> names{"completed.txt", "xsd.xml", "xsd-error.txt",
     "profile-0.xml", "profile-1.xml", "profile-2.xml", "profile-3.xml", "profile-4.xml"};
 return names;
}
bool ValidCdaReferencePath(const std::string& path) {
 if (path.empty() || path.size() >= 1024 || path.front() == '/' || path.back() == '/') return false;
 for (const unsigned char c : path)
  if (c < 32 || c == 127 || c == '\\' || c == ':' || c == '*' || c == '?' || c == '"' ||
      c == '<' || c == '>' || c == '|') return false;
 std::size_t start = 0;
 for (;;) {
  const auto end = path.find('/', start);
  const auto part = path.substr(start, end == std::string::npos ? end : end - start);
  if (part.empty() || part == "." || part == ".." || part.back() == '.' || part.back() == ' ') return false;
  if (end == std::string::npos) return true;
  start = end + 1;
 }
}
bool IncludedCdaReference(const std::string& path) {
 const auto slash=path.find_last_of('/');
 const auto name=path.substr(slash==std::string::npos?0:slash+1);
 return path.find(".bench-")==std::string::npos && name.rfind("abak-",0)!=0 &&
     path!="unified-configuration.json";
}
std::string CdaReferenceFingerprintInput(const std::map<std::string, std::string>& files) {
 Check(!files.empty() && files.size() <= 18000, "Referentiel CDA vide ou trop volumineux.");
 std::string text;
 for (const auto& entry : files) {
  Check(ValidCdaReferencePath(entry.first) && entry.first != "manifest.json" &&
      entry.second.size() == 64 && entry.second.find_first_not_of("0123456789abcdef") == std::string::npos,
      "Empreinte de reference CDA invalide.");
  // Match LocalDocumentControlRunner.tree: generated bench products are never references.
  if(!IncludedCdaReference(entry.first)) continue;
  text += entry.first;
  text.push_back('\0');
  text += entry.second;
  text.push_back('\n');
 }
 Check(!text.empty(),"Referentiel CDA sans references utilisables.");
 return text;
}
std::vector<std::uint8_t> PackCdaReports(const CdaReportFiles& files) {
 Validate(files);
 std::vector<std::uint8_t> bytes(Magic.begin(), Magic.end());
 Put(&bytes, static_cast<std::uint32_t>(files.size()));
 for (const auto& entry : files) {
  Check(bytes.size() + 8 + entry.first.size() + entry.second.size() <= MaxCdaReports,
      "Ensemble des rapports CDA trop volumineux.");
  Put(&bytes, static_cast<std::uint32_t>(entry.first.size()));
  Put(&bytes, static_cast<std::uint32_t>(entry.second.size()));
  bytes.insert(bytes.end(), entry.first.begin(), entry.first.end());
  bytes.insert(bytes.end(), entry.second.begin(), entry.second.end());
 }
 return bytes;
}
CdaReportFiles UnpackCdaReports(const std::vector<std::uint8_t>& bytes) {
 Check(bytes.size() >= 12 && bytes.size() <= MaxCdaReports &&
     std::equal(Magic.begin(), Magic.end(), bytes.begin()), "Format de rapports CDA inconnu.");
 std::size_t position = 8;
 const auto count = Take(bytes, &position);
 Check(count == 7 || count == 8, "Nombre de rapports CDA invalide.");
 CdaReportFiles files;
 for (std::uint32_t i = 0; i < count; ++i) {
  const auto name_size = Take(bytes, &position), size = Take(bytes, &position);
  Check(name_size > 0 && name_size <= 64 && size > 0 && size <= MaxCdaReports &&
      name_size <= bytes.size() - position && size <= bytes.size() - position - name_size,
      "Rapport CDA incomplet ou trop volumineux.");
  const std::string name(bytes.begin() + position, bytes.begin() + position + name_size);
  position += name_size;
  Check(files.count(name) == 0, "Rapport CDA duplique.");
  files.emplace(name, std::vector<std::uint8_t>(bytes.begin() + position, bytes.begin() + position + size));
  position += size;
 }
 Check(position == bytes.size(), "Donnees supplementaires dans les rapports CDA.");
 Validate(files);
 return files;
}
}
