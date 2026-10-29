"""Independent integrated acceptance checks, synthetic database only, no network."""
import sys, json, sqlite3, base64, hashlib, runpy
from pathlib import Path
from lxml import etree as E
out, refs, repo = map(Path, sys.argv[1:4])
result=json.loads((out/'result.json').read_text())
db=sqlite3.connect('file:'+str(Path(result['root'])/'support/database/abak_desktop.db')+'?mode=ro',uri=True)
chain=db.execute("select chain_id from document_chain_steps where phase='package' and state='passed' order by rowid desc limit 1").fetchone()[0]
def phase(name): return json.loads(db.execute("select data_json from document_chain_steps where chain_id=? and phase=? and state='passed'",(chain,name)).fetchone()[0])
p=phase('package');a=phase('authentication');td=phase('td02');w=p['wire']
attempt=db.execute("select version_id from document_chain_steps where chain_id=? limit 1",(chain,)).fetchone()[0]
snapshot=json.loads(db.execute('select snapshot_json from document_medical_approvals where version_id=?',(attempt,)).fetchone()[0])
for name,data in [('packet',p),('authentication',a),('snapshot',snapshot)]: (out/f'{name}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2))
for name,data in [('request.mime',base64.b64decode(w['mime'])),('request.headers',('Content-Type: '+w['contentType']+'\r\nContent-Length: '+str(w['contentLength'])+'\r\n').encode()),('cda.xml',base64.b64decode(w['replay']['cda'])),('signature.xml',w['signatureXml'].encode()),('signed-info.xml',w['signedInfo'].encode()),('td02.xml',td['request'].encode())]: (out/name).write_bytes(data)
parser=E.XMLParser(no_network=True,resolve_entities=False,load_dtd=False)
schema=E.XMLSchema(E.parse(str(refs/'HL7V3/NE2009/multicacheschemas/PRPA_IN201307UV02.xsd'),parser))
request=E.fromstring(td['request'].encode(),parser);checks=[]
ns={'s':'http://www.w3.org/2003/05/soap-envelope','w':'http://www.w3.org/2005/08/addressing','h':'urn:hl7-org:v3','a':'urn:oasis:names:tc:SAML:2.0:assertion'}
def check(value,label): assert value,label;checks.append(label)
def one(xpath):
 rows=request.xpath(xpath,namespaces=ns);assert len(rows)==1,(xpath,len(rows));return rows[0]
check(schema.validate(one('s:Body/h:PRPA_IN201307UV02')),'TD0.2 conforme au schéma HL7 officiel archivé : '+str(schema.error_log))
check(one('s:Header/w:To').text==a['native']['tdEndpoint'],'cible TD0.2 identique au canal authentifié')
check(one('s:Header/w:Action').text=='urn:hl7-org:v3:PRPA_IN201307UV02','action TD0.2 exacte')
check(one('.//h:reasonCode').get('code')=='TEST_EXST','raison TEST_EXST')
check(one('.//h:processingModeCode').get('code')=='T','mode test explicite')
check(one('.//h:patientIdentifier/h:value').get('extension')==snapshot['identity']['ins_number']+snapshot['identity']['ins_key'],'INS de la version approuvée')
check(one('.//h:patientIdentifier/h:value').get('root')==snapshot['identity']['ins_oid'],'OID NIR identique')
check(one('.//a:AuthnStatement').get('AuthnInstant')==a['issuedAt'],'AuthnInstant issu de la session TLS native')
check(one('.//a:NameID').text==a['professional'],'professionnel identique au certificat et au contexte')
check(len(request.xpath('.//a:Attribute',namespaces=ns))==12,'VIHF complet réutilisant le constructeur du paquet')
check(not request.xpath('.//*[local-name()="Document" or local-name()="ClinicalDocument" or local-name()="Signature"]'),'précontrôle sans document ni signature XAdES')
check(a['native']['mutualTls']=='true' and a['native']['protocol']=='TLSv1.2','preuve de TLS mutuel avant précontrôle')
check(a['native']['tdChannel']!=a['native']['depositChannel'],'deux canaux identifiés séparément')
check(all(len(a['native'][k])==64 for k in ['tdPeer','depositPeer','trustHash']),'empreintes serveur et bundle conservées')
# Compare the byte stream received by the memory TLS server with the journal packet.
received=next(out.glob('native-*-deposit_uncorrelated.trace-mime.bin')).read_bytes()
check(received==base64.b64decode(w['mime']),'octets MIME reçus par le service TLS strictement identiques au journal')
(out/'td02-independent.json').write_text(json.dumps({'count':len(checks),'checks':checks,'networkCalls':0,'cpsCalls':0},ensure_ascii=False,indent=2))
sys.argv=[str(repo/'tool/document_wire_product/independent.py'),str(out),str(refs),str(repo)]
runpy.run_path(sys.argv[0],run_name='__main__')
from pypdf import PdfReader
import io
embedded=E.fromstring(base64.b64decode(w['replay']['cda']),parser).xpath('//*[local-name()="nonXMLBody"]/*[local-name()="text"]/text()')
assert len(embedded)==1
pdf=base64.b64decode(embedded[0]);text=''.join(page.extract_text() for page in PdfReader(io.BytesIO(pdf)).pages)
version=snapshot['version']; source=Path(result['root'])/'support/episode_document_versions'/version['relative_path']
content_checks=[]
def content_check(ok,label): assert ok,label;content_checks.append(label)
content_check(source.read_bytes()==pdf,'PDF encapsulé identique à la copie figée')
content_check(hashlib.sha256(pdf).hexdigest()==version['sha256'],'Empreinte identique à la version approuvée')
content_check('Patient SYNTHETIQUE' in text and '01/01/1980' in text,'Identité visible concordante avec le dossier synthétique')
content_check('Kine SYNTHETIQUE' in text and 'SYN-E' in text,'Auteur et épisode visibles concordants')
content_check('125 degrés' in text,'Contenu clinique modifié présent dans le PDF de la seconde pièce')
content_check(snapshot['identity']['birth_date']=='1980-01-01' and snapshot['identity']['birth_last_name']=='SYNTHETIQUE','Identité qualifiée figée concordante')
(out/'content-independent.json').write_text(json.dumps({'count':len(content_checks),'checks':content_checks},ensure_ascii=False,indent=2))
print(len(checks),'contrôles TD0.2 et',len(content_checks),'contrôles contenu indépendants réussis')
