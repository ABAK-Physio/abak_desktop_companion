"""Read-only synthetic identity adapter and version-2 binding to the native bench.
No default database, network, CPS, INSi or transport. Not an INS validator.
"""
from pathlib import Path
import sys, sqlite3, datetime
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'dmp_pdf_cda_unified'))
from coordinator import *
SCOPE2='ABAK-IDENTITY-SYNTHETIC-2'
OID='2.25.123456789' # Local synthetic authority, never an official INS authority.
FIELDS=['patient_id','ins_number','ins_key','ins_oid','birth_last_name','birth_first_names','birth_date','sex_code','birth_place_code','identity_status','identity_doubtful','identity_validation_method','identity_validated_at','identity_validated_by','ins_retrieved_at','ins_last_checked_at','updated_at']
class IdentityReader:
    def __init__(self,root,database,verifier=None):
        self.root=safe_tree(root);self.database=Path(database).absolute()
        if self.database.parent!=self.root or (self.root/'scope').read_text()!=SCOPE2:raise Blocked('Source synthétique requise')
        self.verifier=verifier or (lambda i:i['ins_number']==i['patient_id'] and i['ins_key']=='FIXTURE-KEY' and i['ins_oid']==OID)
    def document(self,one,document):
        d=one('SELECT * FROM care_episode_reports WHERE report_id=?',(document,))
        return d,d['care_episode_id']
    def read(self,patient,episode,document):
        safe_tree(self.root)
        if not all(re.fullmatch(r'SIM-[A-Za-z0-9-]+',v) for v in (patient,episode,document)):raise Blocked('Identité synthétique requise')
        db=sqlite3.connect(self.database.as_uri()+'?mode=ro',uri=True)
        db.row_factory=sqlite3.Row
        try:
            db.execute('PRAGMA query_only=ON');db.execute('BEGIN')
            def one(sql,args):
                rows=db.execute(sql,args).fetchall()
                if len(rows)!=1:raise Blocked('Rattachement absent ou ambigu')
                return dict(rows[0])
            p=one('SELECT * FROM patients WHERE patient_id=?',(patient,))
            e=one('SELECT * FROM care_episodes WHERE care_episode_id=?',(episode,))
            d,linked_episode=self.document(one,document)
            if any(x['archived_at'] is not None for x in (p,e,d)) or e['patient_id']!=patient or linked_episode!=episode:raise Blocked('Rattachement invalide')
            i=one('SELECT '+','.join(FIELDS)+' FROM patient_fr_health_identity WHERE patient_id=?',(patient,))
            if i['identity_status']!='qualified' or i['identity_doubtful']!=0:raise Blocked('Identité non qualifiée ou incertaine')
            if any(not isinstance(i[f],str) or not i[f].strip() for f in FIELDS[:9]):raise Blocked('Identité incomplète')
            if i['ins_oid']=='fixture:oid:nia':raise Blocked('Identifiant NIA : préparation bloquée')
            if i['ins_oid']!=OID:raise Blocked('Type ou autorité inconnus')
            if not self.verifier(i):raise Blocked('Identité synthétique incohérente')
            try:datetime.date.fromisoformat(i['birth_date'])
            except ValueError:raise Blocked('Date de naissance incohérente')
            if i['sex_code'] not in ('M','F','UN') or not i['birth_place_code'].startswith('SIM-'):raise Blocked('Traits incohérents')
            if not i['identity_validation_method'] or not i['identity_validated_by'] or any(type(i[f])!=int or i[f]<=0 for f in ['identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at']):raise Blocked('Provenance synthétique incomplète')
            payload={'schema':2,'scope':SCOPE2,'kind':'fixture-NIR','identity':i,'patient':{k:v for k,v in p.items() if v is not None},'episode':{k:v for k,v in e.items() if v is not None},'document':{k:v for k,v in d.items() if v is not None}}
            return {'payload':payload,'version':key(payload)}
        finally:db.close()

def bind_xml(xml,identity):
    r=parse_xml(xml);p=r.find('c:recordTarget/c:patientRole',NS)
    for el in list(p):p.remove(el)
    def add(parent,name,**attrs):return E.SubElement(parent,'{'+NS['c']+'}'+name,**attrs)
    add(p,'id',root=identity['ins_oid'],extension=identity['ins_number'])
    patient=add(p,'patient');name=add(patient,'name')
    # Preserve the source string, no silent tokenization or normalization.
    add(name,'given').text=identity['birth_first_names'];add(name,'family',qualifier='BR').text=identity['birth_last_name']
    add(patient,'administrativeGenderCode',code=identity['sex_code'],codeSystem='2.16.840.1.113883.5.1')
    add(patient,'birthTime',value=identity['birth_date'].replace('-',''))
    place=add(add(patient,'birthplace'),'place');add(place,'name').text=identity['birth_place_code']
    return E.tostring(r,xml_declaration=True,encoding='UTF-8')

def verify_xml(xml,identity):
    r=parse_xml(xml);p=r.find('c:recordTarget/c:patientRole',NS)
    if p is None or len(r.findall('c:recordTarget',NS))!=1:raise Blocked('Patient CDA ambigu')
    expected=parse_xml(bind_xml(xml,identity)).find('c:recordTarget/c:patientRole',NS)
    if E.tostring(p,method='c14n')!=E.tostring(expected,method='c14n'):raise Blocked('Identité CDA différente de la capture qualifiée')

class IdentityWorkflow:
    """Separate v2 envelope; legacy snapshots never inherit identity approval."""
    def __init__(self,root,reader,configuration,resources):
        self.root=safe_tree(root);self.reader=reader
        if (self.root/'scope').read_text()!=SCOPE2:raise Blocked('Stockage v2 requis')
        self.configuration=configuration;self.resources=resources
        s=self.read();self.base=Coordinator(self.root/s['base'],configuration,resources)
    @classmethod
    def create(cls,parent,reader,configuration,resources):
        root=safe_tree(parent)/('identity-isole-'+uuid.uuid4().hex);root.mkdir();(root/'scope').write_text(SCOPE2)
        base=Coordinator.create(root,configuration,resources)
        cls.write(root,{'schema':2,'scope':SCOPE2,'base':base.root.name,'identity':{},'capture':'','binding':'','approved':False,'held':True,'calls':0,'status':'non_verifie','history':[]})
        return cls(root,reader,configuration,resources)
    @staticmethod
    def write(root,s):write_json(root/'identity.json',{'state':s,'digest':key(s)})
    def read(self):
        safe_tree(self.root);j=json.loads((self.root/'identity.json').read_text());s=j['state']
        if j['digest']!=key(s) or s['schema']!=2 or s['scope']!=SCOPE2 or s['held'] is not True or s['calls']!=0 or not re.fullmatch(r'unified-isole-[a-f0-9]{32}',s['base']):raise Blocked('Journal identité invalide')
        if s['capture'] and not re.fullmatch(r'snapshot-isole-[a-f0-9]{32}',s['capture']):raise Blocked('Capture invalide')
        return s
    def save(self,s):self.write(self.root,s)
    @contextmanager
    def lock(self):
        safe_tree(self.root)
        with (self.root/'lock').open('a') as f:
            fcntl.flock(f,fcntl.LOCK_EX)
            try:yield
            finally:fcntl.flock(f,fcntl.LOCK_UN)
    def current(self,s):
        m,_=snapshot(self.root/s['capture']);c=m['pdfContext']
        identity=self.reader.read(c['patient'],c['episode'],c['document'])
        if identity!=s['identity'] or key([2,m['version'],identity['version']])!=s['binding']:raise Blocked('Identité ou source modifiée : nouvelle validation requise')
        return m,identity
    def stage(self,source):
        with self.lock():
            s=self.read()
            if s['binding']:s['history'].append({'binding':s['binding'],'status':s['status'],'event':'nouvelle_capture'})
            s.pop('token',None);s.pop('tokenBinding',None)
            s.update(approved=False,status='non_verifie',identity={},binding='',capture='');self.save(s)
            m,_=snapshot(source);c=m['pdfContext'];i=self.reader.read(c['patient'],c['episode'],c['document'])
            name='snapshot-isole-'+uuid.uuid4().hex;shutil.copytree(source,self.root/name)
            s.update(capture=name,identity=i,binding=key([2,m['version'],i['version']]),message='Identité synthétique cohérente. Revue liée à cette identité requise.')
            self.save(s);return s['binding']
    def approve(self,binding,confirmed):
        with self.lock():
            s=self.read();m,_=self.current(s)
            if confirmed is not True or binding!=s['binding'] or not m['clinical']:raise Blocked('Revue clinique et confirmation identité requises')
            s.update(approved=True,status='validee');self.save(s)
    def begin(self):
        with self.lock():
            s=self.read();m,i=self.current(s)
            if not s['approved'] or s['status']=='en_cours':raise Blocked('Revue requise ou contrôle en cours')
            dest=self.root/('snapshot-isole-'+uuid.uuid4().hex);shutil.copytree(self.root/s['capture'],dest)
            # The v2 identity envelope is part of the actual native proof version.
            m['sourceRevision']=key([m['sourceRevision'],s['binding']]);m['version']=key({k:m[k] for k in VERSION_KEYS});m['review']['version']=m['version'];write_json(dest/'snapshot.json',m)
            self.base.load(dest);token,manifest,job=self.base.begin()
            s.update(status='en_cours',token=token,tokenBinding=s['binding']);self.save(s)
            return token,manifest,job
    def xml(self,template,m,pdf):
        s=self.read();self.current(s)
        return bind_xml(make_cda(template,pdf,m['cdaContext']),s['identity']['payload']['identity'])
    def finish(self,token):
        with self.lock():
            s=self.read()
            try:
                self.current(s)
                if s.get('token')!=token or s.get('tokenBinding')!=s['binding'] or not s['approved'] or s['status']!='en_cours':raise Blocked('Résultat tardif non applicable')
                verify_xml((self.base.root/'jobs'/token['id']/'document.xml').read_bytes(),s['identity']['payload']['identity'])
                status=self.base.finish(token);self.current(s)
                s.update(status=status,message=self.base.read().get('message',''))
            except Exception as e:
                s['history'].append({'status':s['status'],'event':'blocage_identite'})
                s.update(status='bloque',approved=False,message=str(e))
            self.save(s);return s['status']
    def recover(self):
        with self.lock():
            s=self.read()
            try:
                if not s['capture']:return s
                self.current(s)
                if s['status']=='en_cours':raise Blocked('Contrôle interrompu : aucune relance automatique')
                if s['status']=='conforme':
                    if not s['approved'] or s.get('tokenBinding')!=s['binding']:raise Blocked('Approbation identité absente ou périmée')
                    b=self.base.recover()
                    if b['status']!='conforme':raise Blocked('Preuves techniques indisponibles')
                    verify_xml((self.base.root/'jobs'/s['token']['id']/'document.xml').read_bytes(),s['identity']['payload']['identity'])
            except Exception as e:
                s['history'].append({'status':s['status'],'event':'reouverture_bloquee'})
                s.update(status='bloque',approved=False,message=str(e))
            self.save(s);return s
