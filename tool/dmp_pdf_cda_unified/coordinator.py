"""Synthetic-only local file protocol. Run under the OS network-denied launcher.
No transport, clinical database, CPS or INSi dependency. Hashes are integrity
checks, not signatures or evidence of professional identity.
"""
from pathlib import Path
from contextlib import contextmanager
import sys, json, re, os, base64, copy, fcntl, uuid, shutil
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'dmp_pdf_cda_isolated'))
from bench import (digest,write_json,parse_xml,cda_checks,NS,FMT,PROFILES,E,
                   validate_pdfa,interpret_verapdf,CdaValidator)

SCOPE='ABAK-UNIFIED-SYNTHETIC-1'
CDA_KEYS={'patient','author','structure','title','date','confidentiality','type','class','id','setId','version'}
PDF_KEYS={'patient','episode','document','author','type','visibility'}
VERSION_KEYS={'schema','pdfSha','pdfContext','cdaContext','sourceRevision'}
SNAP_KEYS=VERSION_KEYS|{'version','scope','clinical','review','allWhite','previews'}
class Blocked(ValueError): pass

def canonical(v):
    def check(x):
        if type(x) in (str,bool,int): return
        if isinstance(x,list):
            for item in x:check(item)
        elif isinstance(x,dict) and all(type(k)==str for k in x):
            for item in x.values():check(item)
        else:raise Blocked('Type de contrat interdit')
    check(v)
    return json.dumps(v,sort_keys=True,ensure_ascii=False,separators=(',',':')).encode()
def key(v):return digest(canonical(v))
def safe_tree(root, descendants=True):
    root=Path(root).absolute()
    for p in [root,*root.parents]:
        if p.is_symlink():raise Blocked('Lien interdit')
    if descendants and root.exists() and any(p.is_symlink() for p in root.rglob('*')):raise Blocked('Lien interdit')
    return root

def snapshot(path):
    path=safe_tree(path)
    if not path.name.startswith('snapshot-isole-'):raise Blocked('Capture synthétique requise')
    m=json.loads((path/'snapshot.json').read_text())
    if set(m)!=SNAP_KEYS or m['scope']!='ABAK-PDF-CDA-SNAPSHOT-1' or type(m['schema'])!=int or m['schema']!=1:raise Blocked('Schéma inconnu')
    for name,keys in [('pdfContext',PDF_KEYS),('cdaContext',CDA_KEYS)]:
        c=m[name]
        if not isinstance(c,dict) or set(c)!=keys or any(type(v)!=str or not v for v in c.values()):raise Blocked('Contexte invalide')
    for name,fields in [('pdfContext',['patient','episode','document','author']),('cdaContext',['patient','author','structure'])]:
        if any(not re.fullmatch(r'SIM-[A-Za-z0-9-]+',m[name][f]) for f in fields):raise Blocked('Identité synthétique requise')
    if any(m['pdfContext'][f]!=m['cdaContext'][f] for f in ['patient','author']):raise Blocked('Contexte non corrélé')
    if type(m['sourceRevision'])!=str or not m['sourceRevision'] or type(m['clinical'])!=bool or type(m['allWhite'])!=bool:raise Blocked('Types invalides')
    if m['version']!=key({k:m[k] for k in VERSION_KEYS}):raise Blocked('Version invalide')
    data=(path/'document.pdf').read_bytes()
    if not 0<len(data)<=20*1024*1024 or digest(data)!=m['pdfSha']:raise Blocked('Copie figée altérée')
    if not isinstance(m['previews'],dict) or not m['previews']:raise Blocked('Aperçus absents')
    for name,h in m['previews'].items():
        if not re.fullmatch(r'[A-Za-z0-9_.-]+\.png',name) or digest((path/name).read_bytes())!=h:raise Blocked('Aperçu altéré')
    if m['clinical']:
        r=m['review']
        if set(r)!={'version','pages','patient','contextConfirmed'} or r['version']!=m['version'] or r['patient']!=m['cdaContext']['patient'] or r['contextConfirmed'] is not True or r['pages']!=list(range(1,len(m['previews'])+1)) or m['allWhite']:raise Blocked('Revue invalide')
    elif m['review']!={}:raise Blocked('Revue incohérente')
    return m,data

class Coordinator:
    def __init__(self,root,configuration,resources):
        self.root=safe_tree(root);self.configuration=configuration;self.resources=Path(resources)
        self.schema=E.XMLSchema(E.parse(str(Path(resources)/"infrastructure/cda/CDA_extended.xsd"),E.XMLParser(no_network=True,resolve_entities=False)))
        if not self.root.name.startswith('unified-isole-') or (self.root/'scope').read_text()!=SCOPE:raise Blocked('Stockage isolé requis')
        self.read()
    @classmethod
    def create(cls,parent,configuration,resources):
        root=safe_tree(parent,False)/('unified-isole-'+uuid.uuid4().hex);root.mkdir()
        (root/'scope').write_text(SCOPE)
        for d in ['captures','jobs']: (root/d).mkdir()
        cls._write(root,{'generation':0,'current':{},'history':[],'held':True,'calls':0,'status':'non_verifie','job':{}})
        return cls(root,configuration,resources)
    @staticmethod
    def _write(root,state):write_json(root/'journal.json',{'state':state,'digest':key(state)})
    def read(self):
        safe_tree(self.root)
        j=json.loads((self.root/'journal.json').read_text());s=j['state']
        if key(s)!=j['digest'] or s['held'] is not True or s['calls']!=0 or type(s['generation'])!=int or s['generation']<0:raise Blocked('Journal altéré')
        if s['job'] and (not re.fullmatch(r'[a-f0-9]{32}',s['job'].get('id','')) or set(s['job'])!={'id','version','generation','configuration'}):raise Blocked('Référence de tâche invalide')
        return s
    @contextmanager
    def lock(self):
        safe_tree(self.root)
        with (self.root/'lock').open('a') as f:
            fcntl.flock(f,fcntl.LOCK_EX)
            try:yield
            finally:fcntl.flock(f,fcntl.LOCK_UN)
    def save(self,s):self._write(self.root,s)
    def capture(self,s):
        name=s['current'].get('capture','')
        if not re.fullmatch(r'snapshot-isole-[a-f0-9]{32}',name):raise Blocked('Capture absente')
        m,data=snapshot(self.root/'captures'/name)
        if key(m)!=s['current']['manifest'] or m['version']!=s['current']['version']:raise Blocked('Capture modifiée')
        return m,data
    def load(self,source):
        with self.lock():
            s=self.read();old=copy.deepcopy(s)
            s.update(generation=s['generation']+1,current={},job={},status='non_verifie');self.save(s)
            m,data=snapshot(source)
            name='snapshot-isole-'+uuid.uuid4().hex;dest=self.root/'captures'/name
            dest.mkdir();(dest/'document.pdf').write_bytes(data)
            for n in m['previews']:(dest/n).write_bytes((Path(source)/n).read_bytes())
            write_json(dest/'snapshot.json',m);snapshot(dest)
            s['current']={'capture':name,'manifest':key(m),'version':m['version']}
            # A changed full context must be explicitly reviewed anew by the exporter.
            s['clinical']=m['clinical']
            s['message']='Version validée cliniquement.' if m['clinical'] else 'Nouvelle validation clinique requise.'
            if old['current'].get('version')==m['version'] and old.get('job'):
                s['job']=old['job'];s['status']=old['status']
            self.save(s)
    def check_configuration(self):
        cfg=json.loads((self.resources/'unified-configuration.json').read_text())
        if key(cfg['binding'])!=self.configuration:raise Blocked('Configuration modifiée')
        for path,h in cfg['files'].items():
            p=Path(path)
            if p.is_symlink() or not p.is_file() or digest(p.read_bytes())!=h:raise Blocked('Outil ou référence modifié')
    def begin(self):
        with self.lock():
            s=self.read();m,_=self.capture(s)
            self.check_configuration()
            if s['status']=='en_cours':raise Blocked('Préparation déjà en cours')
            token={'id':uuid.uuid4().hex,'version':m['version'],'generation':s['generation'],'configuration':self.configuration}
            job=self.root/'jobs'/token['id'];job.mkdir()
            write_json(job/'token.json',token)
            s.update(status='en_cours',job=token);self.save(s)
            return token,m,job
    def finish(self,token):
        with self.lock():
            s=self.read()
            if s['job']!=token or s['generation']!=token['generation'] or token['configuration']!=self.configuration:
                s['history'].append({'event':'resultat_tardif','version':token['version']});self.save(s);return 'obsolete'
            try:
                m,pdf=self.capture(s)
                self.check_configuration()
                job=self.root/'jobs'/token['id']
                result=read_proofs(job,m,pdf,self.configuration,self.schema)
                prior=[e for e in s['history'] if e.get('documentId')==m['cdaContext']['id'] and e.get('pdfSha')!=m['pdfSha']]
                if prior:result={'status':'refuse','message':'Identifiant documentaire réutilisé pour un contenu différent.'}
                if result['status']=='conforme' and not m['clinical']:result={'status':'revue_requise','message':'Nouvelle validation clinique requise.'}
                s.update(status=result['status'],message=result['message'])
                s['history'].append({'documentId':m['cdaContext']['id'],'pdfSha':m['pdfSha'],'status':s['status']})
            except Exception as e:s.update(status='non_verifie',message='Preuves ou copie indisponibles : '+str(e))
            self.save(s);return s['status']
    def recover(self):
        with self.lock():
            s=self.read()
            if not s['current']:return s
            try:
                m,pdf=self.capture(s)
                self.check_configuration()
                if s['status']=='en_cours':s.update(status='non_verifie',message='Exécution interrompue ; aucune relance automatique.')
                elif s['job']:
                    if s['job']['configuration']!=self.configuration:raise Blocked('Configuration modifiée, contrôles à refaire')
                    result=read_proofs(self.root/'jobs'/s['job']['id'],m,pdf,self.configuration,self.schema)
                    # Never promote an interrupted or previously refused state on reopen.
                    if s['status']=='conforme' and (result['status']!='conforme' or not m['clinical']):raise Blocked('Conclusion incohérente')
            except Exception as e:s.update(status='non_verifie',message='Actions suspendues : '+str(e))
            self.save(s);return s

def make_cda(template,pdf,c):
    r=parse_xml(template)
    paths={'patient':'c:recordTarget/c:patientRole/c:id','author':'c:author/c:assignedAuthor/c:id','structure':'c:custodian/c:assignedCustodian/c:representedCustodianOrganization/c:id','date':'c:effectiveTime','confidentiality':'c:confidentialityCode','type':'c:code','id':'c:id','setId':'c:setId','version':'c:versionNumber'}
    for k,path in paths.items():
        attr='extension' if k in ['patient','author','structure'] else 'code' if k in ['confidentiality','type'] else 'root' if k in ['id','setId'] else 'value'
        r.find(path,NS).set(attr,c[k])
    r.find('c:title',NS).text=c['title'];r.find('c:component/c:nonXMLBody/c:text',NS).text=base64.b64encode(pdf).decode()
    return E.tostring(r,xml_declaration=True,encoding='UTF-8')

def proof_manifest(job,version,configuration,code):
    files={str(p.relative_to(job)):digest(p.read_bytes()) for p in job.rglob('*') if p.is_file() and p.name not in ['proof.json','token.json']}
    write_json(job/'proof.json',{'schema':1,'version':version,'configuration':configuration,'returncode':code,'files':files})

def read_proofs(job,m,pdf,configuration,schema):
    job=safe_tree(job);p=json.loads((job/'proof.json').read_text())
    if p['version']!=m['version'] or p['configuration']!=configuration:raise Blocked('Rapport non corrélé à cette version')
    required={'document.pdf','document.xml','verapdf.xml','metadata.json','xsd.json'}|{Path(n).name+'.svrl.xml' for n in PROFILES}
    if not required.issubset(p['files']):raise Blocked('Rapports incomplets')
    for name,h in p['files'].items():
        if '/' in name or '\\' in name or name in ('.','..'):raise Blocked('Chemin de preuve interdit')
        if digest((job/name).read_bytes())!=h:raise Blocked('Preuve altérée')
    if (job/'document.pdf').read_bytes()!=pdf:raise Blocked('Rapport PDF non corrélé')
    pr=interpret_verapdf(pdf,(job/'verapdf.xml').read_bytes(),p['returncode'],expected_profile='1b')
    xml=(job/'document.xml').read_bytes();meta=json.loads((job/'metadata.json').read_text())
    errors=cda_checks(xml,pdf,m['cdaContext'],meta)
    xsd=json.loads((job/'xsd.json').read_text())
    # XSD outcome bound to the exact XML by native worker; manifest protects all
    # files. This local integrity scheme is deliberately not cryptographic trust.
    if xsd.get('sha256')!=digest(xml) or type(xsd.get('valid'))!=bool:raise Blocked('Rapport XSD non corrélé')
    native_xsd=schema.validate(parse_xml(xml))
    if native_xsd!=xsd['valid']:raise Blocked('Verdict XSD contradictoire')
    failed=not native_xsd
    for name in PROFILES:
        r=parse_xml((job/(Path(name).name+'.svrl.xml')).read_bytes())
        ns={'s':'http://purl.oclc.org/dsdl/svrl'}
        if r.tag!='{http://purl.oclc.org/dsdl/svrl}schematron-output' or not r.findall('.//s:active-pattern',ns):raise Blocked('Rapport SVRL incomplet')
        failed=failed or bool(r.findall('.//s:failed-assert',ns))
    if errors or failed or pr['status']=='refuse':return {'status':'refuse','message':'Préparation refusée : '+('; '.join(errors) or 'contrôle natif non conforme.')}
    if pr['status']!='conforme':return {'status':'non_verifie','message':'Conformité non vérifiée. Préparation bloquée.'}
    return {'status':'conforme','message':'Version cliniquement validée et contrôles techniques conformes — retenue permanente, aucun envoi disponible.'}

class NativeWorker:
    def __init__(self,resources,validator,java,work,template):
        self.resources=Path(resources);self.validator=validator;self.work=Path(work);self.template=template
        self.work.mkdir();(self.work/'cda').mkdir()
        self.cda=CdaValidator(resources,java,self.work/'cda');self.cache={}
        refs={str(p.relative_to(self.resources)):digest(p.read_bytes()) for p in self.resources.rglob('*') if p.is_file() and '.bench-' not in p.name}
        binaries={str(p.relative_to(Path(validator).parent)):digest(p.read_bytes()) for p in Path(validator).parent.rglob('*.jar')}
        binding={'veraPDFLibraries':binaries,'refs':refs,'validator':digest(Path(validator).read_bytes()),'java':digest(Path(java).read_bytes()),'profile':'1b','protocol':1}
        self.configuration=key(binding)
        files={str(self.resources/n):h for n,h in refs.items()}
        files.update({str(Path(validator).parent/n):h for n,h in binaries.items()})
        files.update({str(Path(validator)):binding['validator'],str(Path(java)):binding['java']})
        write_json(self.resources/'unified-configuration.json',{'binding':binding,'files':files})
        write_json(self.work/'configuration.json',{'digest':self.configuration,'references':refs})
    def execute(self,token,m,job,pdf,xml=None):
        xml=xml if xml is not None else make_cda(self.template,pdf,m['cdaContext'])
        (job/'document.pdf').write_bytes(pdf);(job/'document.xml').write_bytes(xml)
        write_json(job/'metadata.json',dict(m['cdaContext'],formatCode=FMT))
        k=key([digest(pdf),digest(xml),self.configuration])
        if k in self.cache:
            source=self.cache[k]
            for name in ['verapdf.xml','verapdf.stderr','xsd.json',*[Path(n).name+'.svrl.xml' for n in PROFILES]]:shutil.copyfile(source/name,job/name)
            code=json.loads((source/'proof.json').read_text())['returncode'];cached=True
        else:
            result=validate_pdfa(job/'document.pdf',self.validator,job)
            code=result.get('returncode',-1)
            result_cda=self.cda.validate(xml,token['id'])
            write_json(job/'xsd.json',{'sha256':digest(xml),'valid':result_cda['xsd'],'errors':result_cda.get('xsdErrors',[])})
            for n in PROFILES:
                f=self.work/'cda'/token['id']/(Path(n).name+'.svrl.xml')
                if f.exists():shutil.copyfile(f,job/f.name)
            cached=False
        proof_manifest(job,m['version'],self.configuration,code)
        if not cached:
            saved=self.work/('cache-'+k);shutil.copytree(job,saved);self.cache[k]=saved
        return cached
