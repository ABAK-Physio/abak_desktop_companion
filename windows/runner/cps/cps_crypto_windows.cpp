#include "cps_signature.h"
#include <windows.h>
#include <bcrypt.h>
#include <wincrypt.h>
#include <cstdio>
#include <cstring>
#include <memory>

namespace cps_windows {
namespace {
struct CertificateDeleter { void operator()(const CERT_CONTEXT* p) const { if (p) CertFreeCertificateContext(p); } };
using Cert = std::unique_ptr<const CERT_CONTEXT, CertificateDeleter>;
Cert Parse(const std::vector<Byte>& der) {
  if (der.size() < 2 || der.size() > 65536 || der[0] != 0x30) return Cert{};
  std::size_t content = der[1], prefix = 2;
  if (content & 0x80) {
    const auto length_bytes = content & 0x7f;
    if (!length_bytes || length_bytes > 4 || prefix + length_bytes > der.size() || der[2] == 0) return Cert{};
    content = 0;
    for (std::size_t i = 0; i < length_bytes; ++i) content = (content << 8) | der[prefix++];
    if (content < 128) return Cert{};
  }
  if (content != der.size() - prefix) return Cert{};
  Cert cert(CertCreateCertificateContext(X509_ASN_ENCODING, der.data(), static_cast<DWORD>(der.size())));
  // Reject trailing bytes; preserve the exact DER signed by the business cycle.
  if (cert && (cert->cbCertEncoded != der.size() ||
      std::memcmp(cert->pbCertEncoded, der.data(), der.size()))) return Cert{};
  return cert;
}
std::vector<Byte> Digest(const std::vector<Byte>& bytes, bool sha256) {
  BCRYPT_ALG_HANDLE alg = nullptr; BCRYPT_HASH_HANDLE hash = nullptr;
  std::vector<Byte> out(sha256 ? 32 : 20);
  if (BCryptOpenAlgorithmProvider(&alg, sha256 ? BCRYPT_SHA256_ALGORITHM : BCRYPT_SHA1_ALGORITHM,
      nullptr, 0) < 0) return {};
  const bool ok = BCryptCreateHash(alg, &hash, nullptr, 0, nullptr, 0, 0) >= 0 &&
      BCryptHashData(hash, const_cast<Byte*>(bytes.data()), static_cast<ULONG>(bytes.size()), 0) >= 0 &&
      BCryptFinishHash(hash, out.data(), static_cast<ULONG>(out.size()), 0) >= 0;
  if (hash) BCryptDestroyHash(hash);
  BCryptCloseAlgorithmProvider(alg, 0);
  return ok ? out : std::vector<Byte>{};
}
std::string Date(const FILETIME& time) {
  SYSTEMTIME utc{}; char text[32]{};
  if (!FileTimeToSystemTime(&time, &utc)) return {};
  std::snprintf(text, sizeof(text), "%04u-%02u-%02uT%02u:%02u:%02uZ",
      static_cast<unsigned int>(utc.wYear), static_cast<unsigned int>(utc.wMonth),
      static_cast<unsigned int>(utc.wDay), static_cast<unsigned int>(utc.wHour),
      static_cast<unsigned int>(utc.wMinute), static_cast<unsigned int>(utc.wSecond));
  return text;
}
bool Inspect(Certificate* value) {
  const auto cert = Parse(value->der);
  if (!cert || CertVerifyTimeValidity(nullptr, cert->pCertInfo) != 0 ||
      std::strcmp(cert->pCertInfo->SubjectPublicKeyInfo.Algorithm.pszObjId, szOID_RSA_RSA)) return false;
  char name[128]{};
  const DWORD count = CertGetNameStringA(cert.get(), CERT_NAME_ATTR_TYPE, 0,
      const_cast<char*>(szOID_COMMON_NAME), name, static_cast<DWORD>(sizeof(name)));
  if (count <= 1 || count > sizeof(name)) return false;
  value->national_id.assign(name, count - 1);
  value->valid_from = Date(cert->pCertInfo->NotBefore);
  value->valid_until = Date(cert->pCertInfo->NotAfter);
  const auto hash = Digest(value->der, true);
  if (hash.size() != 32 || value->valid_from.empty() || value->valid_until.empty()) return false;
  const char hex[] = "0123456789ABCDEF";
  value->sha256.clear();
  for (auto b : hash) { value->sha256 += hex[b >> 4]; value->sha256 += hex[b & 15]; }
  return true;
}
bool Verify(const std::vector<Byte>& der, const std::string& message,
            const std::vector<Byte>& signature, bool sha256) {
  const auto cert = Parse(der);
  if (!cert || signature.empty() || signature.size() > 16384) return false;
  BCRYPT_KEY_HANDLE key = nullptr;
  if (!CryptImportPublicKeyInfoEx2(X509_ASN_ENCODING, &cert->pCertInfo->SubjectPublicKeyInfo,
      0, nullptr, &key)) return false;
  const auto hash = Digest(std::vector<Byte>(message.begin(), message.end()), sha256);
  BCRYPT_PKCS1_PADDING_INFO padding{sha256 ? BCRYPT_SHA256_ALGORITHM : BCRYPT_SHA1_ALGORITHM};
  const bool ok = !hash.empty() && BCryptVerifySignature(key, &padding,
      const_cast<Byte*>(hash.data()), static_cast<ULONG>(hash.size()),
      const_cast<Byte*>(signature.data()), static_cast<ULONG>(signature.size()), BCRYPT_PAD_PKCS1) >= 0;
  BCryptDestroyKey(key); return ok;
}
std::string Challenge() {
  std::vector<Byte> random(32);
  if (BCryptGenRandom(nullptr, random.data(), static_cast<ULONG>(random.size()), BCRYPT_USE_SYSTEM_PREFERRED_RNG) < 0)
    return {};
  return "ABAK CPS LOCAL SIGNATURE TEST | " + Base64(random);
}
}
PublicCrypto WindowsPublicCrypto() { return PublicCrypto{Inspect, Verify, Challenge}; }
}
