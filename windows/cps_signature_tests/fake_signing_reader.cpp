// Test target only: no Cryptolib, card, real certificate or private key.
#include "cps_pkcs11_windows.h"
#include "cps_signature.h"
namespace cps_windows {
Reply ReadInstalledCryptolib(Request request) {
  Reply reply; reply.operation = request.operation;
  if (!ValidRequest(request)) { reply.step = "REQUEST_FORMAT"; return reply; }
  reply.success = true; reply.slot_count = 1;
  reply.objects["CPS_NAME_PS"] = {1}; reply.objects["CPS_INFO_PS"] = {2}; reply.objects["CPS_ACTIVITY_01_PS"] = {3};
  if (request.operation == Operation::Read) return reply;
  reply.national_id = request.expected_id;
  for (const char* role : {"signature", "authentification"}) {
    Certificate c; c.role = role; c.national_id = request.expected_id;
    c.der = c.role == "signature" ? std::vector<Byte>{2} : std::vector<Byte>{3};
    c.sha256.assign(64, 'A'); c.valid_from = "2020-01-01T00:00:00Z"; c.valid_until = "2099-01-01T00:00:00Z";
    reply.certificates.push_back(c);
  }
  if (request.operation == Operation::Prepare) return reply;
  if (request.operation == Operation::Sign && request.expected_certificate != Base64({2})) {
    reply.success = false; ClearMaterial(&reply); reply.step = "identity"; reply.error = "Synthetic changed certificate."; return reply;
  }
  reply.message = request.operation == Operation::Sign ? request.signed_info : "Synthetic diagnostic";
  reply.algorithm = request.operation == Operation::Sign ? "RSA-SHA1 / PKCS#1 v1.5 (lot local)" : "RSA-SHA256 / PKCS#1 v1.5";
  reply.signature.assign(256, 42); reply.verified = true; reply.tampered_rejected = true;
  return reply;
}
}
