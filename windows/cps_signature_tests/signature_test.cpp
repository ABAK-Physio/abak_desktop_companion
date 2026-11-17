#include "cps_signature.h"
#include "cps_wire.h"
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <stdexcept>
using namespace cps_windows;
namespace {
int checks = 0;
void Check(bool ok, const char* name) { ++checks; if (!ok) { std::cerr << name << '\n'; std::exit(1); } }
struct State {
  int logins = 0, logouts = 0, closes = 0, finalized = 0, finds = 0, finals = 0, signs = 0, inits = 0;
  Ulong cls = 0; std::string label, fail, message; bool sha256 = false;
  Byte* pin = nullptr;
} state;
Ulong Initialize(void*) { return 0; }
Ulong Finalize(void*) { ++state.finalized; return state.fail == "finalize" ? 0x30U : 0U; }
Ulong Slots(Byte, Ulong* slots, Ulong* count) { *count = 1; if (slots) *slots = 1; return 0; }
Ulong Open(Ulong, Ulong flags, void*, Notify, Ulong* session) { Check(flags == 4, "readonly session"); *session = 1; return 0; }
Ulong Login(Ulong, Ulong, Byte* pin, Ulong size) { ++state.logins; Check(size == 4, "PIN bound"); state.pin = pin; return state.fail == "pin" ? 0xa0U : 0U; }
Ulong Logout(Ulong) { ++state.logouts; return state.fail == "logout" ? 0x30U : 0U; }
Ulong Close(Ulong) { ++state.closes; return state.fail == "close" ? 0x30U : 0U; }
Ulong FindInit(Ulong, Attribute* attrs, Ulong count) {
  ++state.finds;
  Check(std::all_of(state.pin, state.pin + 4, [](Byte b) { return b == 0; }), "PIN wiped before access");
  Check((count == 4 || count == 2) && attrs[0].type == 0 && attrs[count - 1].type == 3, "bounded exact search");
  state.cls = *static_cast<Ulong*>(attrs[0].value);
  state.label.assign(static_cast<char*>(attrs[count - 1].value), attrs[count - 1].length);
  Check(state.cls == 0 || (state.cls == 1 && (state.label == "Certificat de Signature CPS" ||
      state.label == "Certificat d'Authentification CPS")) || (state.cls == 3 && state.label == "CPS_PRIV_SIG"), "allowed objects only");
  return 0;
}
Ulong Find(Ulong, Ulong* handles, Ulong capacity, Ulong* count) {
  Check(capacity == 2, "duplicate detection");
  *count = (state.cls || state.label == "CPS_NAME_PS" || state.label == "CPS_INFO_PS" || state.label == "CPS_ACTIVITY_01_PS") ? 1U : 0U;
  if (state.cls == 1 && state.fail == "duplicate-cert") *count = 2;
  if (state.cls == 3 && state.fail == "missing-key") *count = 0;
  if (state.cls == 1 && state.fail == "missing-cert") *count = 0;
  handles[0] = state.cls == 3 ? 3U : state.cls == 1 ? (state.label == "Certificat de Signature CPS" ? 1U : 2U) : 0U;
  return state.fail == "cert-find" && state.cls == 1 ? 0x30U : 0U;
}
Ulong FindFinal(Ulong) { ++state.finals; return state.fail == "cert-final" && state.cls == 1 ? 0x30U : 0U; }
Ulong Attr(Ulong, Ulong object, Attribute* attr, Ulong count) {
  Check(count == 1 && (attr->type == 0x11 || attr->type == 0x102), "bounded attributes");
  Check(object != 3 || attr->type == 0x102, "NEVER private CKA_VALUE");
  std::vector<Byte> value = attr->type == 0x102 ? std::vector<Byte>{9} : std::vector<Byte>{static_cast<Byte>(object + 1)};
  if (object == 3 && state.fail == "wrong-key") value = {8};
  if (object == 2 && state.fail == "same-cert") value = {2};
  if (state.cls && state.fail == "huge-attr") { attr->length = 65537; return 0; }
  if (attr->value) {
    Check(attr->length >= value.size(), "attribute allocated");
    std::memcpy(attr->value, value.data(), value.size());
  }
  attr->length = static_cast<Ulong>(value.size()); return 0;
}
Ulong SignInit(Ulong, Mechanism* mechanism, Ulong key) {
  ++state.inits; Check(key == 3 && !mechanism->parameter && mechanism->length == 0, "key/mechanism binding");
  state.sha256 = mechanism->type == 0x40; Check(mechanism->type == 0x40 || mechanism->type == 6, "Mac mechanisms");
  return state.fail == "sign-init" ? 0x70U : 0U;
}
Ulong Sign(Ulong, Byte* message, Ulong length, Byte* signature, Ulong* size) {
  ++state.signs; state.message.assign(reinterpret_cast<char*>(message), length);
  if (!signature) { *size = state.fail == "huge-signature" ? 16385U : 8U; return state.fail == "size" ? 0x30U : 0U; }
  if (state.fail == "sign") return 0x30;
  if (state.fail == "signature-grew") { *size = 9; return 0; }
  if (state.fail == "signature-zero") { *size = 0; return 0; }
  std::fill(signature, signature + 8, Byte{42}); *size = 8; return 0;
}
Api Functions() {
  Api api; api.initialize = Initialize; api.finalize = Finalize; api.slots = Slots;
  api.open = Open; api.login = Login; api.logout = Logout; api.close = Close;
  api.find_init = FindInit; api.find = Find; api.find_final = FindFinal; api.attribute = Attr;
  api.sign_init = SignInit; api.sign = Sign; return api;
}
PublicCrypto Crypto() {
  return {[](Certificate* c) {
    if (state.fail == "crypto-throw") throw std::runtime_error("synthetic");
    if (state.fail == "expired" || state.fail == "bad-cert") return false;
    c->national_id = state.fail == "wrong-id" ? "123" : "899700870597";
    c->sha256 = std::string(64, 'A'); c->valid_from = "2020-01-01T00:00:00Z"; c->valid_until = "2099-01-01T00:00:00Z"; return true;
  }, [](const std::vector<Byte>& der, const std::string& msg, const std::vector<Byte>& sig, bool sha256) {
    Check(der == std::vector<Byte>{2} && sig == std::vector<Byte>(8, 42) && sha256 == state.sha256, "verify exact public material");
    return state.fail == "tampered-accepted" || (state.fail != "verify" && msg == state.message);
  }, [] { return state.fail == "challenge" ? "" : "ABAK CPS LOCAL SIGNATURE TEST | random"; }};
}
Request Command(Operation operation) {
  Request q; q.operation = operation; q.pin = {'1','2','3','4'};
  if (operation != Operation::Read) q.expected_id = "899700870597";
  if (operation == Operation::Sign) { q.signed_info = "<SignedInfo>synthetic</SignedInfo>"; q.expected_certificate = "Ag=="; }
  return q;
}
Reply Run(Operation operation, const std::string& fail = "") {
  state = {}; state.fail = fail; auto request = Command(operation); auto api = Functions();
  if (fail == "missing-function") api.sign = nullptr;
  auto crypto = Crypto();
  auto reply = ReadProfile(api, std::move(request.pin), [&](Ulong session, Reply* r) { return SignSession(api, session, request, crypto, r); });
  reply.operation = operation;
  Check(state.logins == 1 && state.finalized == 1 && state.closes == 1, "single login and full cleanup");
  Check(state.logouts == (fail == "pin" ? 0 : 1), "logout only owned login");
  Check(state.finds == state.finals, "all searches finalized");
  if (!reply.success) Check(reply.objects.empty() && reply.certificates.empty() && reply.signature.empty() && reply.message.empty(), "failed result has no material");
  std::vector<Byte> bytes; Reply decoded;
  Check(Encode(reply, &bytes) && Decode(bytes, &decoded) && decoded.operation == operation && decoded.success == reply.success, "reply wire roundtrip");
  return reply;
}
}
int main() {
  auto prepared = Run(Operation::Prepare);
  Check(prepared.success && prepared.certificates.size() == 2 && state.inits == 0 && state.signs == 0 && state.cls == 1, "prepare NEVER finds key or signs");
  auto signed_lot = Run(Operation::Sign);
  Check(signed_lot.success && signed_lot.verified && signed_lot.tampered_rejected && !state.sha256 && state.inits == 1 && state.signs == 2, "local lot cycle");
  auto diagnostic = Run(Operation::Test);
  Check(diagnostic.success && state.sha256 && diagnostic.message.find("ABAK CPS LOCAL") == 0, "diagnostic retains SHA256");
  for (const auto* fail : {"pin", "duplicate-cert", "missing-cert", "missing-key", "wrong-key", "same-cert", "cert-find", "cert-final", "huge-attr", "wrong-id", "expired", "bad-cert", "crypto-throw", "missing-function", "sign-init", "size", "huge-signature", "sign", "signature-grew", "signature-zero", "verify", "tampered-accepted", "logout", "close", "finalize"}) {
    const auto result = Run(Operation::Sign, fail); Check(!result.success, fail);
    if (std::string(fail) == "wrong-id" || std::string(fail) == "wrong-key" || std::string(fail) == "same-cert") Check(state.inits == 0 && state.signs == 0, "reject before signing");
  }
  Check(!Run(Operation::Test, "challenge").success, "challenge creation failure");
  auto request = Command(Operation::Sign); request.expected_certificate = "changed"; state = {}; auto api = Functions(); auto crypto = Crypto();
  auto result = ReadProfile(api, std::move(request.pin), [&](Ulong session, Reply* reply) { return SignSession(api, session, request, crypto, reply); });
  Check(!result.success && result.step == "identity" && state.signs == 0, "changed prepared certificate rejected before sign");
  for (auto operation : {Operation::Read, Operation::Prepare, Operation::Sign, Operation::Test}) {
    auto q = Command(operation); std::vector<Byte> bytes; Request decoded;
    Check(EncodeRequest(q, &bytes) && DecodeRequest(bytes, &decoded) && decoded.operation == q.operation && decoded.pin == q.pin && decoded.signed_info == q.signed_info, "request roundtrip");
    for (std::size_t i = 0; i < bytes.size(); ++i) { std::vector<Byte> truncated(bytes.begin(), bytes.begin() + static_cast<std::ptrdiff_t>(i)); Request bad; Check(!DecodeRequest(truncated, &bad), "truncated request"); }
    bytes.push_back(0); Check(!DecodeRequest(bytes, &decoded), "request trailing bytes");
  }
  request = Command(Operation::Sign); request.signed_info.assign(32768, 'X'); request.expected_certificate.assign(87384, 'A'); std::vector<Byte> bytes;
  Check(EncodeRequest(request, &bytes), "maximum request bounded"); Request decoded; Check(DecodeRequest(bytes, &decoded), "maximum request decode");
  request.signed_info.push_back('X'); Check(!EncodeRequest(request, &bytes), "oversize signedInfo refused");
  request = Command(Operation::Prepare); request.signed_info = "unexpected"; Check(!EncodeRequest(request, &bytes), "prepare cannot carry payload to sign");
  request = Command(Operation::Sign); request.expected_id = "invalid id"; Check(!EncodeRequest(request, &bytes), "invalid identity rejected");
  Check(Base64({}) == "" && Base64({1}) == "AQ==" && Base64({1,2}) == "AQI=" && Base64({1,2,3}) == "AQID", "canonical base64");
  std::cout << checks << " signature/protocol checks passed; fake provider only, no card.\n";
}
