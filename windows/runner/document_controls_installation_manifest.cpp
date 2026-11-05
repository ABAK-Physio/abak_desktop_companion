#include "document_controls_installation_manifest.h"

#include <algorithm>
#include <limits>
#include <utility>

namespace document_controls::windows_ipc {
namespace {
Error Invalid(const char* message) { return {"INSTALLATION_MANIFEST_INVALID", message}; }
bool Digest(const std::string& value) {
  return value.size() == 64 && std::all_of(value.begin(), value.end(), [](char c) {
    return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f');
  });
}
bool AccountSid(const std::string& sid) {
  // Local/domain accounts and Microsoft Entra account SID forms. No builtin,
  // service, Everyone or Authenticated Users group SID can be listed here.
  std::size_t at = 0;
  if (sid.compare(0, 9, "S-1-5-21-") == 0) at = 9;
  else if (sid.compare(0, 9, "S-1-12-1-") == 0) at = 9;
  else return false;
  for (int component = 0; component < 4; ++component) {
    const auto begin = at;
    std::uint64_t value = 0;
    while (at < sid.size() && sid[at] >= '0' && sid[at] <= '9') {
      value = value * 10 + static_cast<unsigned int>(sid[at++] - '0');
      if (value > (std::numeric_limits<std::uint32_t>::max)()) return false;
    }
    if (at == begin || (at - begin > 1 && sid[begin] == '0')) return false;
    if (component != 3) {
      if (at == sid.size() || sid[at++] != '-') return false;
    }
  }
  return at == sid.size();
}

class Reader {
 public:
  explicit Reader(const std::string& text) : text_(text) {}
  bool Read(InstallationManifest* value) {
    if (!Take('{')) return false;
    unsigned int fields = 0;
    for (;;) {
      std::string key;
      if (!String(&key) || !Take(':')) return false;
      unsigned int bit = 0;
      if (key == "manifestVersion") { bit = 1; if (!Number(&value->manifest_version)) return false; }
      else if (key == "protocol") { bit = 2; if (!Number(&value->protocol)) return false; }
      else if (key == "contract") { bit = 4; if (!String(&value->contract)) return false; }
      else if (key == "companionSha256") { bit = 8; if (!String(&value->companion_sha256)) return false; }
      else if (key == "serviceSha256") { bit = 16; if (!String(&value->service_sha256)) return false; }
      else if (key == "allowedUsers") { bit = 32; if (!Users(&value->allowed_users)) return false; }
      else return false;
      if (fields & bit) return false;
      fields |= bit;
      if (Take('}')) break;
      if (!Take(',')) return false;
    }
    Space();
    return fields == 63 && at_ == text_.size();
  }
 private:
  void Space() {
    while (at_ < text_.size() && (text_[at_] == ' ' || text_[at_] == '\t' ||
           text_[at_] == '\r' || text_[at_] == '\n')) ++at_;
  }
  bool Take(char c) {
    Space();
    if (at_ == text_.size() || text_[at_] != c) return false;
    ++at_; return true;
  }
  bool String(std::string* value) {
    if (!Take('"')) return false;
    const auto begin = at_;
    while (at_ < text_.size() && text_[at_] != '"') {
      const auto byte = static_cast<unsigned char>(text_[at_]);
      if (byte < 0x20 || byte >= 0x7f || byte == '\\' || at_ - begin >= 184) return false;
      ++at_;
    }
    if (at_ == text_.size()) return false;
    value->assign(text_, begin, at_++ - begin);
    return true;
  }
  bool Number(std::uint32_t* value) {
    Space();
    const auto begin = at_;
    std::uint64_t number = 0;
    while (at_ < text_.size() && text_[at_] >= '0' && text_[at_] <= '9') {
      number = number * 10 + static_cast<unsigned int>(text_[at_++] - '0');
      if (number > (std::numeric_limits<std::uint32_t>::max)()) return false;
    }
    if (at_ == begin || (at_ - begin > 1 && text_[begin] == '0')) return false;
    *value = static_cast<std::uint32_t>(number); return true;
  }
  bool Users(std::vector<std::string>* users) {
    if (!Take('[')) return false;
    users->clear();
    if (Take(']')) return true;
    for (;;) {
      std::string user;
      if (users->size() >= kMaxInstallationUsers || !String(&user)) return false;
      users->push_back(std::move(user));
      if (Take(']')) return true;
      if (!Take(',')) return false;
    }
  }
  const std::string& text_;
  std::size_t at_ = 0;
};
}  // namespace

Error ValidateInstallationManifest(const InstallationManifest& manifest) {
  if (manifest.manifest_version != 1 || manifest.protocol != kProtocol || manifest.contract != kContract) {
    return {"INSTALLATION_MANIFEST_VERSION", "Unsupported installation manifest or protocol."};
  }
  if (!Digest(manifest.companion_sha256) || !Digest(manifest.service_sha256) ||
      manifest.allowed_users.empty() || manifest.allowed_users.size() > kMaxInstallationUsers) {
    return Invalid("Two exact image hashes and a bounded account list are required.");
  }
  std::vector<std::string> seen;
  for (const auto& user : manifest.allowed_users) {
    if (!AccountSid(user) || std::find(seen.begin(), seen.end(), user) != seen.end()) {
      return Invalid("Allowed account SID is invalid or duplicated.");
    }
    seen.push_back(user);
  }
  return {};
}

Error ParseInstallationManifest(const std::string& text, InstallationManifest* manifest) {
  if (!manifest) return {"INVALID_ARGUMENTS", "Missing manifest output."};
  *manifest = {};
  if (text.empty() || text.size() > kMaxInstallationManifestBytes) return Invalid("Manifest size is invalid.");
  InstallationManifest parsed;
  Reader reader(text);
  if (!reader.Read(&parsed)) return Invalid("Manifest does not match the closed JSON schema.");
  if (auto error = ValidateInstallationManifest(parsed)) return error;
  *manifest = std::move(parsed);
  return {};
}

bool ManifestListsUser(const InstallationManifest& manifest, const std::string& sid) {
  return AccountSid(sid) && std::find(manifest.allowed_users.begin(),
      manifest.allowed_users.end(), sid) != manifest.allowed_users.end();
}
}  // namespace document_controls::windows_ipc
