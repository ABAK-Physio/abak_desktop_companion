"""Independent lxml / cryptography / email verification; no product validator reused."""
import sys,json,base64,hashlib,copy
from pathlib import Path
from email import policy
from email.parser import BytesParser
from lxml import etree as E
from cryptography import x509
from cryptography.hazmat.primitives import hashes,serialization
from cryptography.hazmat.primitives.asymmetric import padding
out,refs,repo=map(Path,sys.argv[1:4]);p=json.loads((out/'packet.json').read_text());w=p['wire'];snap=json.loads((out/'snapshot.json').read_text());auth=json.loads((out/'authentication.json').read_text());checks=[]
def check(ok,label):
 assert ok,label
 checks.append(label)
def sha(b):return hashlib.sha1(b).digest()
def b64(s):return base64.b64decode(s,validate=True)
def c14(e):return E.tostring(e,method='c14n',exclusive=False,with_comments=True)
parser=E.XMLParser(resolve_entities=False,no_network=True,load_dtd=False)
ns={'s':'http://www.w3.org/2003/05/soap-envelope','w':'http://www.w3.org/2005/08/addressing','d':'http://www.w3.org/2000/09/xmldsig#','xa':'http://uri.etsi.org/01903/v1.1.1#','a':'urn:oasis:names:tc:SAML:2.0:assertion','r':'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0','l':'urn:oasis:names:tc:ebxml-regrep:xsd:lcm:3.0','x':'urn:ihe:iti:xds-b:2007','xop':'http://www.w3.org/2004/08/xop/include','h':'urn:hl7-org:v3','wsse':'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'}
def one(e,path):
 rows=e.xpath(path,namespaces=ns);assert len(rows)==1,(path,len(rows));return rows[0]
raw=(out/'request.mime').read_bytes();headers=(out/'request.headers').read_bytes()
mail=BytesParser(policy=policy.default).parsebytes(headers+b'\r\n'+raw)
check(not mail.defects and mail.get_content_type()=='multipart/related','MIME multipart/related sans défaut')
parts=list(mail.iter_parts());check(len(parts)==3,'trois parties MIME exactement')
check(all(not part.defects for part in parts),'parties MIME sans défaut')
check(mail.get_param('type')=='application/xop+xml' and mail.get_param('start')==parts[0]['Content-ID'],'partie racine XOP désignée par start')
check('application/soap+xml' in mail.get_param('start-info') and 'ProvideAndRegisterDocumentSet-b' in mail.get_param('start-info'),'action MIME et start-info')
check(len(raw)==w['contentLength']==int(mail['Content-Length']) and hashlib.sha256(raw).hexdigest()==w['mimeSha256'],'taille et scellement SHA256 MIME')
content={part['Content-ID'][1:-1]:part.get_payload(decode=True) for part in parts}
check(len(content)==3 and all(part['Content-Transfer-Encoding']=='binary' for part in parts),'Content-ID uniques et encodage binaire')
soap=E.fromstring(parts[0].get_payload(decode=True),parser)
check(parts[0].get_payload(decode=True)==w['soap'].encode(),'SOAP inchangé après décodage MIME')
# Header policy is independent of the product's self-reconstruction validator.
mu='{'+ns['s']+'}mustUnderstand'
for name in ['w:To','w:Action']:
 check(one(soap,'s:Header/'+name).get(mu)=='true','mustUnderstand conservé sur '+name)
for name in ['w:ReplyTo','wsse:Security']:
 check(one(soap,'s:Header/'+name).get(mu) is None,'profil DV1 sans mustUnderstand sur '+name)
check(w['replay']['soapHeaderProfile']=='dv1-20261028','profil SOAP archivé explicitement')
cda=(out/'cda.xml').read_bytes();sig=(out/'signature.xml').read_bytes()
check(parts[1].get_payload(decode=True)==cda and parts[2].get_payload(decode=True)==sig,'CDA et XAdES octet pour octet')
body=one(soap,'s:Body/x:ProvideAndRegisterDocumentSetRequest');docs=body.findall('x:Document',ns)
check(len(docs)==2 and len({x.get('id') for x in docs})==2,'deux documents XDS distincts')
resolved={}
for doc in docs:
 include=one(doc,'xop:Include');href=include.get('href');check(href.startswith('cid:') and href[4:] in content,'référence XOP résolue');resolved[doc.get('id')]=content[href[4:]]
check(set(resolved.values())=={cda,sig},'aucune pièce supplémentaire ou absente')
# Validate the reconstructed XOP infoset against the archived official XDS schema.
reconstructed=copy.deepcopy(body)
for doc in reconstructed.findall('x:Document',ns):
 for child in list(doc):doc.remove(child)
 doc.text=base64.b64encode(resolved[doc.get('id')]).decode()
schema=E.XMLSchema(E.parse(str(refs/'IHE/XDS.b_DocumentRepository.xsd'),parser))
check(schema.validate(reconstructed),'schéma XDS officiel : '+str(schema.error_log))
c=E.fromstring(cda,parser);signature=E.fromstring(sig,parser);si=one(signature,'d:SignedInfo')
check(c14(si)==(out/'signed-info.xml').read_bytes(),'canonisation inclusive identique entre Dart et libxml2')
check(one(si,'d:CanonicalizationMethod').get('Algorithm')=='http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments','C14N avec commentaires explicite')
check(one(si,'d:SignatureMethod').get('Algorithm')==ns['d']+'rsa-sha1','algorithme de signature A6-2 explicite')
cert=x509.load_der_x509_certificate(b64(one(signature,'d:KeyInfo/d:X509Data/d:X509Certificate').text))
cert.public_key().verify(b64(one(signature,'d:SignatureValue').text),c14(si),padding.PKCS1v15(),hashes.SHA1())
check(True,'signature RSA vérifiée indépendamment par cryptography')
check(cert.fingerprint(hashes.SHA256()).hex()==w['signingCertificateHash']!=auth['certificateHash'],'signature liée au certificat de signature distinct')
references=si.findall('d:Reference',ns);check({r.get('URI') for r in references}=={'#IHEManifest','#S0-SignedProperties'} and len(references)==2,'deux références SignedInfo fermées')
for ref in references:
 target=one(signature,'//*[@Id="'+ref.get('URI')[1:]+'"]')
 check(b64(one(ref,'d:DigestValue').text)==sha(c14(target)),'digest '+ref.get('URI'))
manifest=one(signature,'.//d:Manifest');refs_m=manifest.findall('d:Reference',ns)
check(len(refs_m)==2 and b64(one(refs_m[0],'d:DigestValue').text)==b'\x00','référence du lot à hash null conforme au guide')
check(b64(one(refs_m[1],'d:DigestValue').text)==sha(c14(c)),'digest du CDA canonisé')
props=one(signature,'.//xa:SignedProperties');certdigest=one(props,'.//xa:CertDigest/xa:DigestValue')
check(b64(certdigest.text)==sha(cert.public_bytes(serialization.Encoding.DER)),'digest certificat en espace XAdES 1.1.1')
check(one(props,'.//d:X509IssuerName').text==cert.issuer.rfc4514_string() and one(props,'.//d:X509SerialNumber').text==str(cert.serial_number),'émetteur et numéro de série X509')
registry=one(body,'l:SubmitObjectsRequest/r:RegistryObjectList');entries=registry.findall('r:ExtrinsicObject',ns)
check(len(entries)==2,'CDA et signature référencés comme documents XDS')
ids=registry.xpath('.//@id');check(len(ids)==len(set(ids)) and not any(x.startswith('urn:uuid:') for x in ids),'identifiants ebXML locaux uniques non UUID (RG_2710)')
def slot(e,n):return one(e,'r:Slot[@name="'+n+'"]/r:ValueList/r:Value').text
def external(e,scheme):return one(e,'r:ExternalIdentifier[@identificationScheme="urn:uuid:'+scheme+'"]').get('value')
patient=snap['identity']['ins_number']+snap['identity']['ins_key']+'^^^&'+snap['identity']['ins_oid']+'&ISO^NH'
check(w['replay']['xdsPatientIdProfile']=='ins-nh-1','profil patientId XDS explicite')
for entry in entries:
 data=resolved[entry.get('id')]
 check(slot(entry,'hash')==hashlib.sha1(data).hexdigest() and int(slot(entry,'size'))==len(data),'hash et taille XDS de la pièce exacte')
 check(external(entry,'58a6f841-87b3-4a3e-92fd-a8ffeff98427')==patient,'patient XDS de la version approuvée')
 if data==cda:
  uid=external(entry,'2e82c1f6-a085-4c72-9da3-8640a32e42ab')
  check(uid==one(c,'h:id').get('root')==refs_m[1].get('URI')[8:],'identifiant OID commun CDA/XDS/manifest')
  check(one(entry,'r:Classification[@classificationScheme="urn:uuid:a09d5840-386c-46f2-b5ad-9c3699a4309d"]').get('nodeRepresentation')=='urn:ihe:iti:xds-sd:pdf:2008','format CDA non structuré PDF/A (ASS_A12 archivée)')
 else:
  check(external(entry,'2e82c1f6-a085-4c72-9da3-8640a32e42ab')==signature.get('Id'),'uniqueId XDS de la signature')
submission=one(registry,'r:RegistryPackage');subid=submission.get('id')
check(external(submission,'6b5aea1a-874d-4603-a4bc-96a0a7b38446')==patient,'patientId du lot avec CX.5 NH')
check(external(submission,'96fdda7c-d067-4183-912e-bf5ee74998a8')==refs_m[0].get('URI')[8:],'OID du lot et manifest')
check(len(registry.xpath('r:Association[@associationType="urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember"]',namespaces=ns))==2,'deux associations HasMember')
check(one(registry,'r:Association[@associationType="urn:ihe:iti:2007:AssociationType:signs"]').get('targetObject')==subid,'association signs vers le lot')
assertion=one(soap,'s:Header/wsse:Security/a:Assertion');authcert=x509.load_der_x509_certificate(b64(w['authenticationDer']))
check(one(assertion,'a:Issuer').text==authcert.subject.rfc4514_string(),'VIHF issu du sujet du certificat authentification')
check(one(assertion,'a:Subject/a:NameID').text==auth['professional'],'professionnel authentifié dans le VIHF')
check(one(assertion,'a:AuthnStatement').get('AuthnInstant')==auth['issuedAt'],'instant authentification de la session')
check(not assertion.xpath('.//d:Signature',namespaces=ns),'VIHF non signé séparément en mode DIRECTE')
attrs={e.get('Name'):e for e in assertion.findall('a:AttributeStatement/a:Attribute',ns)}
check(len(attrs)==12,'attributs VIHF complets et non dupliqués')
check(one(attrs['Authentification_Mode'],'a:AttributeValue').text=='DIRECTE','mode DIRECTE')
check(one(attrs['urn:oasis:names:tc:xacml:2.0:resource:resource-id'],'a:AttributeValue').text==patient,'patient VIHF concordant')
check(all(one(attrs[key],'a:AttributeValue').text for key in ['LPS_ID','LPS_Nom','LPS_Version','LPS_ID_HOMOLOGATION_DMP']),'identifiants LPS explicites')
check(one(attrs['urn:oasis:names:tc:xacml:2.0:subject:role'],'a:AttributeValue/h:Role').get('code')=='70','rôle kiné VIHF')
check(one(attrs['urn:oasis:names:tc:xspa:1.0:subject:purposeofuse'],'a:AttributeValue/h:PurposeOfUse').get('code')=='normal','but accès normal')
# Compare classification schemes and coding systems with the archived official example.
reference=E.parse(str(repo/'assets/dmp_local/registry-example.xml'),parser)
for entry in entries:
 for clas in entry.findall('r:Classification',ns):
  code=clas.get('nodeRepresentation');scheme=clas.get('classificationScheme')
  if code in ['http://www.w3.org/2000/09/xmldsig#','MASQUE_PS','INVISIBLE_PATIENT','E1762']:
   old=reference.xpath('//*[local-name()="Classification"][@classificationScheme=$s][@nodeRepresentation=$c]',s=scheme,c=code)[0]
   check(slot(clas,'codingScheme')==slot(old,'codingScheme'),'codage archivé : '+code)
# Full signature metadata contract, checked against an accepted transaction.
accepted=E.parse(str(repo/'assets/dmp_local/deposit_replay/accepted-request.xml'),parser)
check(w['replay']['xdsMetadataProfile']=='dv1-labels-signature-1','profil métadonnées XDS explicite')
expected_specialty=accepted.xpath('//r:Slot[@name="authorSpecialty"]/r:ValueList/r:Value/text()',namespaces=ns)[0]
for author_slot in registry.xpath('.//r:Slot[@name="authorSpecialty"]',namespaces=ns):
 check(one(author_slot,'r:ValueList/r:Value').text==expected_specialty,'libellé exact J56 authorSpecialty')
sig_entry=next(entry for entry in entries if resolved[entry.get('id')]==sig)
check(not sig_entry.xpath('r:Slot[@name="sourcePatientInfo"]',namespaces=ns),'aucun sourcePatientInfo sur la signature')
check(w['replay']['signatureTitleProfile']=='event-source-1','profil titre de signature explicite')
check(one(sig_entry,'r:Name/r:LocalizedString').get('value')==one(sig_entry,'r:Classification[@nodeRepresentation="1.2.840.10065.1.12.1.14"]/r:Name/r:LocalizedString').get('value')=='Source','titre égal au libellé événement Source')
check(slot(sig_entry,'serviceStartTime')==slot(sig_entry,'serviceStopTime')==slot(sig_entry,'creationTime'),'dates de service égales à la création de signature')
for code in ['MASQUE_PS','INVISIBLE_PATIENT','http://www.w3.org/2000/09/xmldsig#']:
 current=one(sig_entry,'r:Classification[@nodeRepresentation="'+code+'"]')
 ref=accepted.xpath('//r:Classification[@nodeRepresentation=$c]',namespaces=ns,c=code)[0]
 check(one(current,'r:Name/r:LocalizedString').get('value')==one(ref,'r:Name/r:LocalizedString').get('value'),'libellé exact accepté : '+code)
check(not any(v in json.dumps(p) for v in ['899700870597','187012425258307','207058575627097']),'aucune identité des lots archivés réutilisée')
(out/'independent.json').write_text(json.dumps({'count':len(checks),'checks':checks,'networkCalls':0,'cpsCalls':0},ensure_ascii=False,indent=2))
print(f'{len(checks)} contrôles indépendants réussis.')
