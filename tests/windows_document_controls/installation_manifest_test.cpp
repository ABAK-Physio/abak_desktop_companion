#include "document_controls_installation_manifest.h"
#include "document_controls_pipe_client.h"
#include "document_controls_service_core.h"

#include <cstdlib>
#include <iostream>
#include <random>
#include <utility>

namespace ipc = document_controls::windows_ipc;
namespace {
int checks = 0;
void Check(bool result, const char* message) {
  ++checks;
  if (!result) { std::cerr << "FAILED: " << message << '\n'; std::exit(1); }
}
std::string Users(int count) {
  std::string text = "[";
  for (int i = 0; i < count; ++i) {
    if (i) text += ',';
    text += "\"S-1-5-21-1-2-3-" + std::to_string(1001 + i) + "\"";
  }
  return text + "]";
}
std::vector<std::string> Members(int users = 1) {
  return {"\"manifestVersion\":1", "\"protocol\":1", "\"contract\":\"ABAK-WINDOWS-CONTROLS-1\"",
          "\"companionSha256\":\"" + std::string(64, 'a') + "\"",
          "\"serviceSha256\":\"" + std::string(64, 'b') + "\"", "\"allowedUsers\":" + Users(users)};
}
std::string Json(const std::vector<std::string>& members) {
  std::string text = "{";
  for (const auto& member : members) {
    if (text.size() > 1) text += ',';
    text += member;
  }
  return text + "}";
}
std::string Replace(std::string text, const std::string& old_text, const std::string& new_text) {
  const auto at = text.find(old_text);
  Check(at != std::string::npos, "mutation target exists");
  text.replace(at, old_text.size(), new_text);
  return text;
}
void Reject(const std::string& text, const char* code = nullptr) {
  ipc::InstallationManifest manifest;
  manifest.companion_sha256 = manifest.service_sha256 = std::string(64, 'f');
  manifest.allowed_users = {"S-1-5-21-9-9-9-1001"};
  const auto error = ipc::ParseInstallationManifest(text, &manifest);
  Check(static_cast<bool>(error), "invalid manifest refuses");
  if (code) Check(error.code == code, "specific manifest error");
  Check(manifest.companion_sha256.empty() && manifest.service_sha256.empty() &&
        manifest.allowed_users.empty(), "failed parse clears previous manifest data");
}
void Valid() {
  ipc::InstallationManifest manifest;
  const auto compact = Json(Members());
  Check(!ipc::ParseInstallationManifest(compact, &manifest), "closed manifest parses");
  Check(manifest.companion_sha256 == std::string(64, 'a') &&
        manifest.service_sha256 == std::string(64, 'b') && manifest.allowed_users.size() == 1,
        "two images and explicit user preserved");
  Check(ipc::ManifestListsUser(manifest, "S-1-5-21-1-2-3-1001"), "listed account matches literally");
  Check(!ipc::ManifestListsUser(manifest, "S-1-5-21-1-2-3-1002"), "another account is not listed");
  Check(!ipc::ManifestListsUser(manifest, "S-1-5-32-545"), "Users group is not an individual account");
  std::string pretty = " \r\n\t";
  for (char c : compact) { pretty += c; if (c == ',') pretty += "\r\n  "; }
  Check(!ipc::ParseInstallationManifest(pretty + " \n", &manifest), "JSON whitespace accepted outside strings");
  auto members = Members();
  std::swap(members.front(), members.back());
  Check(!ipc::ParseInstallationManifest(Json(members), &manifest), "member order may vary");
  Check(!ipc::ParseInstallationManifest(Json(Members(16)), &manifest) && manifest.allowed_users.size() == 16,
        "maximum account count accepted");
  const auto at_limit = compact + std::string(ipc::kMaxInstallationManifestBytes - compact.size(), ' ');
  Check(!ipc::ParseInstallationManifest(at_limit, &manifest), "file exactly at metadata limit accepted");
  Reject(at_limit + " ");
  const auto entra = Replace(compact, "S-1-5-21-1-2-3-1001", "S-1-12-1-4294967295-2-3-4");
  Check(!ipc::ParseInstallationManifest(entra, &manifest) &&
        ipc::ManifestListsUser(manifest, "S-1-12-1-4294967295-2-3-4"), "Entra account SID accepted");
  Check(static_cast<bool>(ipc::ValidateInstallationManifest({})), "default parsed data is not a usable manifest");
  Check(ipc::ParseInstallationManifest(compact, nullptr).code == "INVALID_ARGUMENTS", "null parse output refuses");
}
void Invalid() {
  const auto good = Json(Members());
  for (const auto* value : {"", "{}", "[]", "null", "true", "{", "{\"protocol\":1,}"}) Reject(value);
  const auto members = Members();
  for (std::size_t index = 0; index < members.size(); ++index) {
    auto changed = members;
    changed.push_back(members[index]);
    Reject(Json(changed));
    changed = members;
    changed.erase(changed.begin() + static_cast<std::ptrdiff_t>(index));
    Reject(Json(changed));
  }
  for (const auto* extra : {"\"trusted_installation\":true", "\"signatureRequired\":false",
                            "\"companionPath\":\"evil.exe\"", "\"serviceName\":\"Other\"",
                            "\"serviceSid\":\"S-1-5-18\"", "\"execute\":true", "\"javaPath\":\"java.exe\""}) {
    auto changed = members; changed.push_back(extra); Reject(Json(changed));
  }
  Reject(Replace(good, "manifestVersion\":1", "manifestVersion\":2"), "INSTALLATION_MANIFEST_VERSION");
  Reject(Replace(good, "protocol\":1", "protocol\":0"), "INSTALLATION_MANIFEST_VERSION");
  Reject(Replace(good, "ABAK-WINDOWS-CONTROLS-1", "ABAK-WINDOWS-CONTROLS-2"), "INSTALLATION_MANIFEST_VERSION");
  for (const auto* number : {"-1", "+1", "1.0", "1e0", "01", "4294967296", "true", "null", "\"1\"", "[]"}) {
    Reject(Replace(good, "manifestVersion\":1", std::string("manifestVersion\":") + number));
  }
  for (const auto& bad_hash : {std::string(), std::string(63, 'a'), std::string(65, 'a'),
                              std::string(64, 'A'), std::string(64, 'g')}) {
    Reject(Replace(good, std::string(64, 'a'), bad_hash));
    Reject(Replace(good, std::string(64, 'b'), bad_hash));
  }
  for (const auto* sid : {"", "S-1-1-0", "S-1-5-18", "S-1-5-19", "S-1-5-32-545", "S-1-5-80-1-2-3-4-5",
                         "S-1-5-21-1-2-3", "S-1-5-21-1-2-3-4-5", "S-1-5-21-1-02-3-4",
                         "S-1-5-21-1-2-3-4294967296", "S-1-5-21--1-2-3-4", "s-1-5-21-1-2-3-4",
                         "S-1-12-1-1-2-3-4294967296"}) Reject(Replace(good, "S-1-5-21-1-2-3-1001", sid));
  Reject(Json(Members(0)));
  Reject(Json(Members(17)));
  Reject(Replace(good, Users(1), "[\"S-1-5-21-1-2-3-1001\",\"S-1-5-21-1-2-3-1001\"]"));
  for (const auto* value : {"null", "{}", "true", "[1]", "[[]]", "\"S-1-5-21-1-2-3-1001\"", "[\"S-1-5-21-1-2-3-1001\",]"}) {
    Reject(Replace(good, Users(1), value));
  }
  Reject(good + good);
  Reject(std::string("\xef\xbb\xbf") + good);
  Reject(Replace(good, "S-1-5-21-1-2-3-1001", "S-1-5-21-1-2-3-100\\u0031"));
  Reject(Replace(good, "S-1-5-21-1-2-3-1001", std::string("bad\0sid", 7)));
  Reject(Replace(good, "S-1-5-21-1-2-3-1001", std::string("\xc0\xaf", 2)));
  for (std::size_t length = 0; length < good.size(); ++length) Reject(good.substr(0, length));
}
void GatesAndCorpus() {
  std::mt19937 random(4417);
  for (int i = 0; i < 10000; ++i) {
    std::string text(random() % 512, '\0');
    for (auto& c : text) c = static_cast<char>(random() & 0xff);
    Reject(text);
  }
  Check(ipc::ServiceStartupGate().code == "SERVICE_INSTALLATION_UNQUALIFIED", "W3 service gate remains closed");
  for (auto operation : {document_controls::Operation::kPdfa, document_controls::Operation::kVersion,
                        document_controls::Operation::kCda}) {
    ipc::Request request;
    request.operation = operation;
    request.request_id = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee";
    if (operation != document_controls::Operation::kVersion) request.input = {1, std::string(64, 'a')};
    ipc::Frame reply{"forged success", {1}};
    Check(ipc::Exchange(request, &reply).code == ipc::kIsolationUnavailable &&
          reply.metadata.empty() && reply.payload.empty(), "manifest parsing never activates production execution");
  }
}
}  // namespace

int main() {
  Valid(); Invalid(); GatesAndCorpus();
  std::cout << checks << " W4 manifest checks passed (parsed data is not authorization).\n";
}
