#include "cps_signature.h"
#include <array>
#include <utility>

namespace cps_windows {
namespace {
bool Fail(Reply* reply, const char* step, const char* error, Ulong code = 0) {
  reply->step = step; reply->error = error; reply->code = code; return false;
}
bool Unique(const Api& api, Ulong session, Ulong cls, const std::string& label,
            Ulong* handle) {
  std::vector<Byte> name(label.begin(), label.end());
  std::array<Attribute, 2> attrs{{{0, &cls, 4},
      {3, name.data(), static_cast<Ulong>(name.size())}}};
  if (api.find_init(session, attrs.data(), 2)) return false;
  Ulong handles[2]{}, count = 0;
  const auto found = api.find(session, handles, 2, &count);
  const auto finished = api.find_final(session);
  if (found || finished || count != 1) return false;
  *handle = handles[0]; return true;
}
bool AttributeBytes(const Api& api, Ulong session, Ulong handle, Ulong type,
                    std::vector<Byte>* bytes) {
  Attribute attr{type, nullptr, 0};
  if (api.attribute(session, handle, &attr, 1) || !attr.length || attr.length > 65536)
    return false;
  bytes->resize(attr.length); attr.value = bytes->data();
  if (api.attribute(session, handle, &attr, 1) || !attr.length || attr.length > bytes->size())
    return false;
  bytes->resize(attr.length); return true;
}
}
std::string Base64(const std::vector<Byte>& bytes) {
  static const char alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  std::string out; out.reserve((bytes.size() + 2) / 3 * 4);
  for (std::size_t i = 0; i < bytes.size(); i += 3) {
    const auto a = bytes[i];
    const unsigned int b = i + 1 < bytes.size() ? bytes[i + 1] : 0U;
    const unsigned int c = i + 2 < bytes.size() ? bytes[i + 2] : 0U;
    out += alphabet[a >> 2]; out += alphabet[((a & 3) << 4) | (b >> 4)];
    out += i + 1 < bytes.size() ? alphabet[((b & 15) << 2) | (c >> 6)] : '=';
    out += i + 2 < bytes.size() ? alphabet[c & 63] : '=';
  }
  return out;
}
bool SignSession(const Api& api, Ulong session, const Request& request,
                 const PublicCrypto& crypto, Reply* reply) {
  reply->operation = request.operation;
  if (!crypto.inspect || !crypto.verify || !crypto.challenge)
    return Fail(reply, "certificates", "Verification des certificats indisponible.");
  std::vector<Byte> signing_id;
  for (const auto& pair : {std::make_pair("signature", "Certificat de Signature CPS"),
       std::make_pair("authentification", "Certificat d'Authentification CPS")}) {
    Ulong handle = 0; Certificate certificate; certificate.role = pair.first;
    if (!Unique(api, session, 1, pair.second, &handle) ||
        !AttributeBytes(api, session, handle, 0x11, &certificate.der) ||
        !crypto.inspect(&certificate))
      return Fail(reply, "certificates", "Certificat CPS absent, ambigu, invalide ou hors periode de validite.");
    if (certificate.national_id != request.expected_id)
      return Fail(reply, "identity", "Le certificat ne correspond pas au redacteur. Relisez la CPS.");
    if (certificate.role == "signature" &&
        !AttributeBytes(api, session, handle, 0x102, &signing_id))
      return Fail(reply, "keyBinding", "Identifiant du certificat de signature illisible.");
    reply->certificates.push_back(std::move(certificate));
  }
  if (reply->certificates[0].der == reply->certificates[1].der)
    return Fail(reply, "certificates", "Les certificats de signature et d'authentification doivent etre distincts.");
  reply->national_id = request.expected_id;
  if (request.operation == Operation::Prepare) return true; // No private key lookup, no C_Sign.
  const auto& der = reply->certificates[0].der;
  if (request.operation == Operation::Sign && Base64(der) != request.expected_certificate)
    return Fail(reply, "identity", "Le certificat a change depuis la preparation du lot.");
  Ulong key = 0; std::vector<Byte> key_id;
  // Never request CKA_VALUE from a private key. Only CKA_ID binds it to the certificate.
  if (!Unique(api, session, 3, "CPS_PRIV_SIG", &key) ||
      !AttributeBytes(api, session, key, 0x102, &key_id) || key_id != signing_id)
    return Fail(reply, "keyBinding", "Impossible d'associer la cle au certificat CPS.");
  if (!api.sign_init || !api.sign)
    return Fail(reply, "GetProcAddress", "Fonctions de signature CPS absentes.");
  const bool sha256 = request.operation == Operation::Test;
  reply->message = sha256 ? crypto.challenge() : request.signed_info;
  if (reply->message.empty() || reply->message.size() > 32768)
    return Fail(reply, "verification", "Message de signature invalide.");
  // Same mechanisms as macOS. SHA-1 only for the existing SEL-MP-037 A6-2 local lot.
  Mechanism mechanism{sha256 ? 0x40U : 0x06U, nullptr, 0};
  auto code = api.sign_init(session, &mechanism, key);
  if (code) return Fail(reply, "C_SignInit", "Initialisation de signature refusee.", code);
  std::vector<Byte> message(reply->message.begin(), reply->message.end());
  Ulong size = 0;
  code = api.sign(session, message.data(), static_cast<Ulong>(message.size()), nullptr, &size);
  if (code || !size || size > 16384)
    return Fail(reply, "C_Sign(size)", "Taille de signature invalide.", code);
  reply->signature.resize(size);
  code = api.sign(session, message.data(), static_cast<Ulong>(message.size()), reply->signature.data(), &size);
  if (code || !size || size > reply->signature.size())
    return Fail(reply, "C_Sign", "Signature refusee.", code);
  reply->signature.resize(size);
  if (!crypto.verify(der, reply->message, reply->signature, sha256) ||
      crypto.verify(der, reply->message + " altered", reply->signature, sha256))
    return Fail(reply, "verification", "La verification locale de la signature a echoue.");
  reply->verified = true; reply->tampered_rejected = true;
  reply->algorithm = sha256 ? "RSA-SHA256 / PKCS#1 v1.5" : "RSA-SHA1 / PKCS#1 v1.5 (lot local)";
  return true;
}
}
