"""Synthetic CA, two separate leaf keys and signed CRL. Never loads system keys."""
import sys,json,hashlib
from pathlib import Path
from datetime import datetime,timezone
from cryptography import x509
from cryptography.hazmat.primitives import hashes,serialization
from cryptography.hazmat.primitives.asymmetric import rsa,padding
from cryptography.x509.oid import NameOID,ExtendedKeyUsageOID
out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
now=datetime(2026,10,17,12,tzinfo=timezone.utc)
rootkey=rsa.generate_private_key(public_exponent=65537,key_size=2048)
rootname=x509.Name([x509.NameAttribute(NameOID.COUNTRY_NAME,'FR'),x509.NameAttribute(NameOID.ORGANIZATION_NAME,'ABAK SYNTHETIC ONLY'),x509.NameAttribute(NameOID.COMMON_NAME,'TEST CA NEVER TRUST IN SYSTEM')])
root=x509.CertificateBuilder().subject_name(rootname).issuer_name(rootname).public_key(rootkey.public_key()).serial_number(1).not_valid_before(datetime(2020,1,1,tzinfo=timezone.utc)).not_valid_after(datetime(2030,1,1,tzinfo=timezone.utc)).add_extension(x509.BasicConstraints(ca=True,path_length=0),True).sign(rootkey,hashes.SHA256())
(out/'ca.pem').write_bytes(root.public_bytes(serialization.Encoding.PEM))
entries={};serial=10
for name in ['auth','sign','wrong','expired','future','no_usage','revoked']:
 serial+=1;key=rsa.generate_private_key(public_exponent=65537,key_size=2048)
 subject=x509.Name([x509.NameAttribute(NameOID.COUNTRY_NAME,'FR'),x509.NameAttribute(NameOID.ORGANIZATION_NAME,'ABAK SYNTHETIC ONLY'),x509.NameAttribute(NameOID.COMMON_NAME,'99999999999' if name=='wrong' else '12345678901')])
 cert=x509.CertificateBuilder().subject_name(subject).issuer_name(rootname).public_key(key.public_key()).serial_number(serial).not_valid_before(datetime(2027 if name=='future' else 2020,1,1,tzinfo=timezone.utc)).not_valid_after(datetime(2025 if name=='expired' else 2029,1,1,tzinfo=timezone.utc)).add_extension(x509.BasicConstraints(ca=False,path_length=None),True).add_extension(x509.KeyUsage(digital_signature=name=='auth',content_commitment=name not in ['auth','no_usage'],key_encipherment=False,data_encipherment=False,key_agreement=False,key_cert_sign=False,crl_sign=False,encipher_only=False,decipher_only=False),True)
 if name=='auth':cert=cert.add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.CLIENT_AUTH]),False)
 cert=cert.sign(rootkey,hashes.SHA256());der=cert.public_bytes(serialization.Encoding.DER)
 (out/f'{name}.der').write_bytes(der);(out/f'{name}.pem').write_bytes(cert.public_bytes(serialization.Encoding.PEM));(out/f'{name}-key.pem').write_bytes(key.private_bytes(serialization.Encoding.PEM,serialization.PrivateFormat.TraditionalOpenSSL,serialization.NoEncryption()))
 entries[name]=cert
crl=x509.CertificateRevocationListBuilder().issuer_name(rootname).last_update(datetime(2026,10,17,11,tzinfo=timezone.utc)).next_update(datetime(2026,10,18,11,tzinfo=timezone.utc)).add_revoked_certificate(x509.RevokedCertificateBuilder().serial_number(entries['revoked'].serial_number).revocation_date(datetime(2026,10,17,10,tzinfo=timezone.utc)).build()).sign(rootkey,hashes.SHA256())
(out/'test.crl.der').write_bytes(crl.public_bytes(serialization.Encoding.DER))
root.public_key().verify(crl.signature,crl.tbs_certlist_bytes,padding.PKCS1v15(),crl.signature_hash_algorithm)
report={}
for name,cert in entries.items():
 root.public_key().verify(cert.signature,cert.tbs_certificate_bytes,padding.PKCS1v15(),cert.signature_hash_algorithm)
 valid=cert.not_valid_before_utc<=now<cert.not_valid_after_utc
 revoked=crl.get_revoked_certificate_by_serial_number(cert.serial_number) is not None
 report[name]={'sha256':cert.fingerprint(hashes.SHA256()).hex(),'chain':True,'valid':valid,'revoked':revoked,'subject':cert.subject.rfc4514_string(),'issuer':cert.issuer.rfc4514_string()}
assert report['auth']['valid'] and report['sign']['valid'] and report['auth']['sha256']!=report['sign']['sha256']
assert report['revoked']['revoked'] and not report['expired']['valid'] and not report['future']['valid']
(out/'assessment.json').write_text(json.dumps(report,indent=2))
print('CA, certificats et CRL synthétiques vérifiés hors réseau.')
