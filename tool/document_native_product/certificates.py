"""Synthetic CA, CRLs, client and server keys. Test directory only; no network."""
import sys, json, hashlib
from pathlib import Path
from datetime import datetime, timezone, timedelta
from cryptography import x509
from cryptography.x509.oid import NameOID, ExtendedKeyUsageOID
from cryptography.hazmat.primitives import hashes, serialization as S
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
out=Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
now=datetime(2026,10,17,12,tzinfo=timezone.utc)
ca_key=rsa.generate_private_key(public_exponent=65537,key_size=2048)
name=x509.Name([x509.NameAttribute(NameOID.COMMON_NAME,'ABAK SYNTHETIC ROOT')])
ca=(x509.CertificateBuilder().subject_name(name).issuer_name(name).public_key(ca_key.public_key()).serial_number(1)
 .not_valid_before(now-timedelta(days=365)).not_valid_after(now+timedelta(days=3650))
 .add_extension(x509.BasicConstraints(ca=True,path_length=1),True)
 .add_extension(x509.KeyUsage(True,False,False,False,False,True,True,False,False),True)
 .add_extension(x509.SubjectKeyIdentifier.from_public_key(ca_key.public_key()),False).sign(ca_key,hashes.SHA256()))
certs={}; manifest={}
for serial,kind in enumerate(['auth','sign','server','wronghost','expired','future','revoked','wrong','no_usage','no_signature'],10):
 key=rsa.generate_private_key(public_exponent=65537,key_size=2048)
 server=kind in ['server','wronghost']
 cn='synthetic.invalid' if server else ('99999999999' if kind=='wrong' else '12345678901')
 b=(x509.CertificateBuilder().subject_name(x509.Name([x509.NameAttribute(NameOID.COMMON_NAME,cn)]))
  .issuer_name(name).public_key(key.public_key()).serial_number(serial)
  .not_valid_before(now+timedelta(days=1) if kind=='future' else now-timedelta(days=30))
  .not_valid_after(now-timedelta(days=1) if kind=='expired' else now+timedelta(days=365))
  .add_extension(x509.BasicConstraints(ca=False,path_length=None),True)
  .add_extension(x509.KeyUsage(kind not in ['sign','no_signature'],kind not in ['auth','server','wronghost','no_usage','no_signature'],server,False,False,False,False,False,False),True)
  .add_extension(x509.AuthorityKeyIdentifier.from_issuer_public_key(ca_key.public_key()),False))
 if server:b=b.add_extension(x509.SubjectAlternativeName([x509.DNSName('wrong.invalid' if kind=='wronghost' else 'synthetic.invalid')]),False).add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.SERVER_AUTH]),False)
 elif kind=='auth':b=b.add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.CLIENT_AUTH]),False)
 cert=b.sign(ca_key,hashes.SHA256());certs[kind]=cert
 (out/f'{kind}.der').write_bytes(cert.public_bytes(S.Encoding.DER))
 (out/f'{kind}.p12').write_bytes(pkcs12.serialize_key_and_certificates(kind.encode(),key,cert,[ca],S.BestAvailableEncryption(b'synthetic-only')))
 (out/f'{kind}-key.pem').write_bytes(key.private_bytes(S.Encoding.PEM,S.PrivateFormat.PKCS8,S.NoEncryption()))
 manifest[kind]=hashlib.sha256(cert.public_bytes(S.Encoding.DER)).hexdigest()
for kind in ['trust','stale','revoked_auth','bad_crl']:
 builder=x509.CertificateRevocationListBuilder().issuer_name(name).last_update(now-timedelta(days=2)).next_update(now-timedelta(days=1) if kind=='stale' else now+timedelta(days=7))
 for c in [certs['revoked']]+([certs['auth']] if kind=='revoked_auth' else []):
  builder=builder.add_revoked_certificate(x509.RevokedCertificateBuilder().serial_number(c.serial_number).revocation_date(now-timedelta(days=1)).build())
 key=ca_key if kind!='bad_crl' else rsa.generate_private_key(public_exponent=65537,key_size=2048)
 data=ca.public_bytes(S.Encoding.PEM)+builder.sign(key,hashes.SHA256()).public_bytes(S.Encoding.PEM)
 (out/f'{kind}.pem').write_bytes(data);manifest[kind]=hashlib.sha256(data).hexdigest()
(out/'manifest.json').write_text(json.dumps(manifest,indent=2))
