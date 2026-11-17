#include "cps_signature.h"
#include "public_vectors.h"
#include <cstdlib>
#include <iostream>
using namespace cps_windows;
namespace {
int checks = 0;
void Check(bool ok, const char* label) { ++checks; if (!ok) { std::cerr << label << '\n'; std::exit(1); } }
}
int main() {
  auto crypto = WindowsPublicCrypto(); Certificate cert; cert.der = kCertificate;
  Check(crypto.inspect(&cert), "synthetic certificate parse");
  Check(cert.national_id == "899700870597" && cert.sha256 == "767D1ADCC479861245807B326B44FE781FFC8E8B67C26378D8AB9C0EBDEDC66C" &&
      cert.valid_from == "2020-01-01T00:00:00Z" && cert.valid_until == "2099-01-01T00:00:00Z", "CN, SHA256, validity UTC");
  const std::string message = "ABAK SYNTHETIC PUBLIC VERIFICATION VECTOR";
  for (bool sha256 : {false, true}) {
    const auto& signature = sha256 ? kSignatureSha256 : kSignatureSha1;
    Check(crypto.verify(kCertificate, message, signature, sha256), "known signature accepted");
    Check(!crypto.verify(kCertificate, message + " altered", signature, sha256), "modified message rejected");
    Check(!crypto.verify(kCertificate, message, signature, !sha256), "wrong digest rejected");
    auto changed = signature; changed[0] ^= 1;
    Check(!crypto.verify(kCertificate, message, changed, sha256), "modified signature rejected");
    Check(!crypto.verify(kCertificate, message, {}, sha256), "empty signature rejected");
  }
  cert.der = kExpired; Check(!crypto.inspect(&cert), "expired certificate refused");
  cert.der = kFuture; Check(!crypto.inspect(&cert), "future certificate refused");
  cert.der = {1,2,3}; Check(!crypto.inspect(&cert), "malformed DER refused");
  cert.der = kCertificate; cert.der.push_back(0); Check(!crypto.inspect(&cert), "trailing DER refused");
  const auto a = crypto.challenge(), b = crypto.challenge();
  Check(!a.empty() && a != b && a.find("ABAK CPS LOCAL SIGNATURE TEST | ") == 0, "fresh random challenge");
  std::cout << checks << " Windows public crypto checks passed; synthetic vectors, no card.\n";
}
