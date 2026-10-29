"""Offline synthetic professional/document context, no application DB or card service.
The limited SIM profile is not an RPPS validator, authentication or DMP transport.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'dmp_piece_isolated'))
from piece import *

CONTEXT_SCOPE = 'ABAK-CONTEXT-SYNTHETIC-1'
PROFILE = 'SIM-CDA-NORMAL-1'
AUTHORITY = '2.25.123456789'
STRUCTURE_AUTHORITY = '1.2.250.1.71.4.2.2'
TYPE_SYSTEM = '2.16.840.1.113883.6.1'
CLASS_SYSTEM = '1.2.250.1.213.1.1.4.1'

class Unverified(Blocked):
    pass

def require(condition, message):
    if not condition:
        raise Blocked(message)

def sim(value):
    return isinstance(value, str) and re.fullmatch(r'SIM-[A-Za-z0-9-]+', value)

def typed_id(value, authority=AUTHORITY):
    require(isinstance(value, dict) and set(value) == {'value', 'authority'}, 'Identifiant typé requis')
    if not sim(value['value']) or value['authority'] != authority:
        raise Unverified('Identifiant professionnel ou autorité non vérifiés')

def clean(value):
    return {k: clean(v) for k,v in value.items()} if isinstance(value,dict) else [clean(v) for v in value] if isinstance(value,list) else {'null':True} if value is None else value

class ContextReader(PieceReader):
    def __init__(self, root, database, verifier=None, hook=None):
        super().__init__(root, database, verifier, hook)
        require((self.root/'context-scope').read_text() == CONTEXT_SCOPE, 'Source de contexte synthétique requise')
        self.secret_session = None

    def context(self, document):
        safe_tree(self.root)
        # Same synthetic database only; no production default or fallback.
        with sqlite3.connect(self.database.as_uri()+'?mode=ro', uri=True) as db:
            db.row_factory = sqlite3.Row
            db.execute('PRAGMA query_only=ON'); db.execute('BEGIN')
            def one(sql, args):
                rows=db.execute(sql,args).fetchall()
                require(len(rows)==1,'Contexte absent ou ambigu')
                return dict(rows[0])
            row=one('SELECT * FROM synthetic_document_context WHERE document_id=?',(document,))
            c=json.loads(row['body'])
            require(set(c)=={'profile','revision','author','authorIdentity','profession','operator','rolesConfirmed','situation','situations','custodian','document','visibility','catalog','catalogDigest','provenance'},'Contrat de contexte incomplet')
            require(c['profile']==PROFILE and type(c['revision'])==int and c['revision']>0 and c['provenance']=='synthetic-explicit','Profil ou provenance inconnus')
            require(sim(c['author']) and sim(c['operator']) and c['rolesConfirmed'] is True,'Auteur et rôles explicites requis')
            p=one('SELECT * FROM practitioners WHERE practitioner_id=?',(c['author'],))
            require(p['archived_at'] is None and p['is_active']==1,'Auteur absent ou inactif : préparation bloquée')
            require(p['display_name'] and p['professional_id'],'Auteur incomplet')
            # ABAK's practitioners table does not carry an authority or profession.
            # Those come from the explicit synthetic provider, never from ID length.
            typed_id(c['authorIdentity'])
            require(p['professional_id']==c['authorIdentity']['value'],'Auteur et identifiant professionnel différents')
            require(c['profession']==70,'Profession hors profil synthétique')
            require(c['situation'] and isinstance(c['situations'],list),'Situation à sélectionner')
            ids=[x['id'] for x in c['situations']]
            require(len(ids)==len(set(ids)),'Situations ambiguës')
            matches=[s for s in c['situations'] if s['id']==c['situation']]
            require(len(matches)==1,'Situation à sélectionner')
            s=matches[0]
            require(set(s)=={'id','author','active','mode','status','sector','facility','structure'} and sim(s['id']) and s['author']==c['author'] and s['active'] is True,'Situation incohérente')
            require(s['mode']=='SIM-LIBERAL' and s['status']=='SIM-ACTIF' and s['sector']=='AMBULATOIRE' and s['facility']=='SA07','Situation hors mapping synthétique')
            for structure in [s['structure'],c['custodian']]:
                require(set(structure)=={'id','name'} and bool(structure['name']),'Structure incomplète')
                typed_id(structure['id'], STRUCTURE_AUTHORITY)
            cat=c['catalog']
            if not isinstance(cat,dict) or key(cat)!=c['catalogDigest'] or not cat.get('usable') or not cat.get('fresh'):
                raise Unverified('Référentiel indisponible ou à revérifier')
            require(cat['version'].startswith('SIM-') and cat['source']=='synthetic','Catalogue synthétique requis')
            d=c['document']
            require(set(d)=={'title','date','type','class','media','format','language','confidentiality','id','setId','version'},'Métadonnées incomplètes')
            require(bool(d['title'].strip()),'Titre requis')
            require(re.fullmatch(r'\d{14}[+-]\d{4}',d['date']) is not None,'Date clinique avec fuseau requise')
            datetime.datetime.strptime(d['date'],'%Y%m%d%H%M%S%z')
            for field,system in [('type',TYPE_SYSTEM),('class',CLASS_SYSTEM)]:
                code=d[field]
                require(set(code)=={'system','code','label'} and code['system']==system and bool(code['label']),'Code ou système invalide')
                require(any(e==dict(code,active=True) for e in cat['entries']),'Code absent ou inactif')
            require([d['type']['code'],d['class']['code']] in cat['pairs'],'Type et classe incompatibles')
            require(d['media']=='application/pdf' and d['format']==FMT and [d['media'],d['format']] in cat['mediaPairs'],'Média/format incompatible')
            require(d['language']=='fr-FR' and d['confidentiality']=='N','Mapping documentaire non disponible')
            require(all(re.fullmatch(r'[0-9A-Fa-f-]{36}',d[k]) or re.fullmatch(r'2\.25\.\d+',d[k]) for k in ['id','setId']) and re.fullmatch(r'[1-9]\d*',d['version']),'Identifiants documentaires invalides')
            v=c['visibility']
            require(set(v)=={'minor','mode','patient','rl','maskedPS','previousPatient','previousRL','cumulative','opposition','parameterVersion'},'Visibilité incomplète')
            require(all(type(v[k])==bool for k in ['minor','patient','rl','maskedPS','previousPatient','previousRL','cumulative','opposition']),'Visibilité mal typée')
            require(v['mode'] in ['normal','secret'] and v['parameterVersion'].startswith('SIM-'),'Choix de session requis')
            require(not v['opposition'],'Opposition : préparation bloquée')
            require(not v['previousPatient'] or v['patient'],'Visibilité patient irréversible')
            require(not v['previousRL'] or v['rl'],'Visibilité RL irréversible')
            require(v['cumulative'] or v['patient'] or not v['maskedPS'],'Cumul interdit')
            if v['mode']=='secret':
                require(v['minor'] and not v['rl'],'Secret incompatible avec visibilité RL')
                # No mapping of secret to a generic confidentialityCode, nor session replay.
                raise Unverified('Connexion secrète : mapping de session hors profil local, nouvelle décision requise')
            require(v['patient'] and v['rl'] and not v['maskedPS'],'Visibilité hors profil CDA normal simulé')
            return {'context':c,'practitioner':clean(p),'selectedSituation':s,'rowRevision':row['revision']}

    def read(self,patient,episode,document):
        first=self.context(document)
        identity=super().read(patient,episode,document)
        second=self.context(document)
        require(first==second,'Contexte modifié pendant capture')
        identity['payload']['professionalContext']=second
        identity['version']=key(identity['payload'])
        return identity

def contexts(identity, pc):
    a=identity['payload']['professionalContext']; c=a['context'];d=c['document'];p=a['practitioner']
    pc=dict(pc,author=p['professional_id'],type=d['type']['code'],visibility='normal')
    cc={'patient':pc['patient'],'author':p['professional_id'],'structure':c['custodian']['id']['value'],
        'title':d['title'],'date':d['date'],'confidentiality':d['confidentiality'],'type':d['type']['code'],
        'class':d['class']['code'],'id':d['id'],'setId':d['setId'],'version':d['version']}
    return pc,cc

# Exact supported mappings; no arbitrary XPath from user data.
def mappings(a):
    c=a['context'];p=a['practitioner'];s=a['selectedSituation'];d=c['document']
    result={}
    for path in ['c:author/c:assignedAuthor','c:legalAuthenticator/c:assignedEntity','c:documentationOf/c:serviceEvent/c:performer/c:assignedEntity']:
        result[path+'/c:id/@root']=c['authorIdentity']['authority'];result[path+'/c:id/@extension']=p['professional_id']
        result[path+'/c:assignedPerson/c:name/c:family/text()']=p['display_name']
    for path,st in [('c:custodian/c:assignedCustodian/c:representedCustodianOrganization',c['custodian']),('c:documentationOf/c:serviceEvent/c:performer/c:assignedEntity/c:representedOrganization',s['structure'])]:
        result[path+'/c:id/@root']=st['id']['authority'];result[path+'/c:id/@extension']=st['id']['value'];result[path+'/c:name/text()']=st['name']
    for path in ['c:effectiveTime','c:author/c:time','c:legalAuthenticator/c:time','c:documentationOf/c:serviceEvent/c:effectiveTime/c:low','c:documentationOf/c:serviceEvent/c:effectiveTime/c:high','c:componentOf/c:encompassingEncounter/c:effectiveTime/c:low']:
        result[path+'/@value']=d['date']
    for attr,value in [('code',d['type']['code']),('codeSystem',d['type']['system']),('displayName',d['type']['label'])]:result['c:code/@'+attr]=value
    result['c:languageCode/@code']=d['language']
    result['c:confidentialityCode/@codeSystem']='2.16.840.1.113883.5.25'
    result['c:confidentialityCode/@displayName']='Normal'
    base='c:documentationOf/c:serviceEvent/c:performer/c:assignedEntity/c:representedOrganization/c:standardIndustryClassCode'
    result[base+'/@code']=s['sector'];result[base+'/@codeSystem']='1.2.250.1.213.1.1.4.9';result[base+'/@displayName']='Ambulatoire'
    base='c:componentOf/c:encompassingEncounter/c:location/c:healthCareFacility'
    result[base+'/c:code/@code']=s['facility'];result[base+'/c:code/@codeSystem']='1.2.250.1.71.4.2.4';result[base+'/c:code/@displayName']='Cabinet individuel';result[base+'/c:location/c:name/text()']=s['structure']['name']
    return result

def apply_context(xml,a,episode):
    r=parse_xml(xml)
    for path,value in mappings(a).items():
        parent,attr=path.rsplit('/',1);nodes=r.findall(parent,NS)
        require(len(nodes)==1,'Mapping CDA absent ou ambigu : '+parent)
        if attr=='text()':nodes[0].text=value
        else:nodes[0].set(attr[1:],value)
    r.find('c:componentOf/c:encompassingEncounter/c:id',NS).set('extension',episode)
    return E.tostring(r,xml_declaration=True,encoding='UTF-8')

def verify_context_xml(xml,a,episode):
    r=parse_xml(xml)
    for path,value in mappings(a).items():
        require(r.xpath(path,namespaces=NS)==[value],'Contexte CDA différent : '+path)
    require(r.xpath('c:componentOf/c:encompassingEncounter/c:id/@extension',namespaces=NS)==[episode],'Épisode CDA différent')
    # Roles/structure subtrees reject unexpected additional IDs or names too.
    for path in ['c:author','c:legalAuthenticator','c:custodian','c:documentationOf','c:componentOf']:
        require(len(r.findall(path,NS))==1,'Rôle CDA ambigu')
    for path in ['c:author/c:assignedAuthor','c:legalAuthenticator/c:assignedEntity','c:documentationOf/c:serviceEvent/c:performer/c:assignedEntity']:
        person=r.find(path,NS)
        require(person is not None and len(person.findall('c:id',NS))==1,'Identifiant professionnel ambigu')
        names=person.findall('c:assignedPerson/c:name',NS)
        require(len(names)==1 and len(names[0])==1 and names[0][0].tag=='{'+NS['c']+'}family','Nom professionnel hors profil')

class ContextWorkflow(PieceWorkflow):
    def current(self,s):
        m,i=super().current(s)
        pc,cc=contexts(i,m['pdfContext'])
        require(pc==m['pdfContext'] and cc==m['cdaContext'],'Contexte documentaire non corrélé')
        return m,i
    def xml(self,template,m,pdf):
        s=self.read();_,i=self.current(s)
        return apply_context(super().xml(template,m,pdf),i['payload']['professionalContext'],m['pdfContext']['episode'])
    def verify_job(self,s):
        job=self.base.root/'jobs'/s['token']['id']
        xml=(job/'document.xml').read_bytes();a=s['identity']['payload']['professionalContext']
        verify_context_xml(xml,a,s['identity']['payload']['episode']['care_episode_id'])
        require(json.loads((job/'professional-context.json').read_text())==a,'Contexte de preuve différent')
    def finish(self,token):
        # Base finish validates token and proofs under the same file lock.
        with self.lock():
            s=self.read()
            try:
                self.current(s);require(s.get('token')==token and s['status']=='en_cours','Résultat tardif')
                self.verify_job(s)
            except Exception as e:
                s.update(approved=False,status='non_verifie' if isinstance(e,(OSError,Unverified)) else 'refuse',message=str(e));self.save(s);return s['status']
        return super().finish(token)
    def recover(self):
        s=super().recover()
        with self.lock():
            s=self.read()
            if s['status']=='conforme':
                try:self.verify_job(s)
                except Exception as e:s.update(approved=False,status='non_verifie',message=str(e));self.save(s)
        return s

class ContextImport(PieceImport):
    def export(self,data,identity,pdf_context,cda_context,review=None):
        pc,cc=contexts(identity,pdf_context)
        require(pc==pdf_context and cc==cda_context,'Contexte non issu de la capture')
        return super().export(data,identity,pc,cc,review)
    def capture_context(self,pc):
        # Clear any preceding approval even if the provider cannot be read.
        with self.flow.lock():
            s=self.flow.read();s.update(approved=False,status='non_verifie');s.pop('token',None);self.flow.save(s)
        i=self.flow.reader.read(pc['patient'],pc['episode'],pc['document'])
        pc,cc=contexts(i,pc)
        return self.capture(pc,cc)

def execute_context(worker,flow,template,alter=None):
    token,m,job=flow.begin();_,pdf=flow.base.capture(flow.base.read());xml=flow.xml(template,m,pdf)
    if alter:xml=alter(xml)
    cached=worker.execute(token,m,job,pdf,xml)
    write_json(job/'professional-context.json',flow.read()['identity']['payload']['professionalContext'])
    code=json.loads((job/'proof.json').read_text())['returncode'];proof_manifest(job,m['version'],worker.configuration,code)
    return flow.finish(token),cached
