"""File-only UI bridge for the synthetic attachment workflow. No network listener."""
from piece import *
import time
BRIDGE='ABAK-PIECE-DEMO-1'
MODES={'coherent':'Pièce PDF conforme — SIM-DOC1','second':'Autre pièce, même PDF — SIM-DOC2','wrong_patient':'Pièce d’un autre patient','wrong_episode':'Pièce d’un autre épisode','archived':'Pièce archivée','nia':'Identité NIA','unavailable':'Fichier source indisponible','blank':'Page blanche','header':'En-tête sans contenu clinique','changed_pdf':'PDF modifiable','changed_identity':'Identité modifiable','changed_link':'Rattachement modifiable','different':'Identité CDA différente'}
def fixture(root,pc,pdf):
    root.mkdir();(root/'scope').write_text(SCOPE2);path=root/'synthetic.db';(root/'piece.pdf').write_bytes(pdf)
    with sqlite3.connect(path) as db:
        db.executescript('CREATE TABLE patients(patient_id TEXT,archived_at INTEGER); CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT,archived_at INTEGER); CREATE TABLE episode_documents(document_id TEXT,case_id TEXT,title TEXT,file_path TEXT,mime_type TEXT,source TEXT,created_at INTEGER,updated_at INTEGER,archived_at INTEGER); CREATE TABLE patient_fr_health_identity('+','.join(f+' '+('INTEGER' if f in ['identity_doubtful','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at'] else 'TEXT') for f in FIELDS)+');')
        db.execute('INSERT INTO patients VALUES (?,NULL)',(pc['patient'],))
        db.executemany('INSERT INTO care_episodes VALUES (?,?,NULL)',[(pc['episode'],pc['patient']),('SIM-E2',pc['patient'])])
        for doc in ['SIM-DOC1','SIM-DOC2']:
            db.execute('INSERT INTO episode_documents VALUES (?,?,?,?,?,?,1,1,NULL)',(doc,pc['episode'],'Bilan PDF synthétique '+doc,str(root/'piece.pdf'),'application/pdf','fixture'))
        vals=[pc['patient'],pc['patient'],'FIXTURE-KEY',OID,'SYNTHETIQUE','Fictif','1987-01-01','M','SIM-LIEU','qualified',0,'fixture-proof',1,'SIM-AGENT',1,1,1]
        db.execute('INSERT INTO patient_fr_health_identity VALUES ('+','.join('?' for _ in vals)+')',vals)
    return PieceReader(root,path)
class Demo:
    def __init__(self,spec):
        self.spec=spec;self.root=safe_tree(spec['root']);r=self.root
        if r.exists() and any(r.iterdir()) and not (r/'demo.scope').exists():raise Blocked('Dossier neuf requis')
        r.mkdir(exist_ok=True,parents=True)
        if (r/'demo.scope').exists() and (r/'demo.scope').read_text()!=BRIDGE:raise Blocked('Dossier pièce synthétique requis')
        (r/'demo.scope').write_text(BRIDGE)
        self.lock=(r/'service.lock').open('a');fcntl.flock(self.lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        for n in ['requests','responses','stores']:(r/n).mkdir(exist_ok=True)
        self.m,self.pdf=snapshot(Path(spec['snapshot']));self.template=Path(spec['template']).read_bytes()
        work=r/('worker-'+uuid.uuid4().hex);work.mkdir();refs=work/'references';shutil.copytree(spec['references'],refs)
        home=work/'java-profile';home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(home)
        self.worker=NativeWorker(refs,spec['validator'],spec['java'],work/'native',self.template);self.refs=refs
        if (r/'session.json').exists():
            e=json.loads((r/'session.json').read_text());self.session=e['state']
            if key(self.session)!=e['digest'] or self.session['scope']!=BRIDGE:raise Blocked('Session altérée')
            for k,prefix in [('source','source-'),('workflow','identity-isole-')]:
                if not re.fullmatch(prefix+r'[a-f0-9]{32}',self.session[k]):raise Blocked('Session invalide')
            self.reader=PieceReader(r/self.session['source'],r/self.session['source']/'synthetic.db')
            self.flow=PieceWorkflow(r/'stores'/self.session['workflow'],self.reader,self.worker.configuration,refs)
            self.importer=PieceImport(self.flow,spec['dart'],spec['poppler'],spec['repo']);self.flow.recover()
        else:self.select('coherent')
        for p in (r/'requests').glob('*.working'):
            self.response(p.stem,'Commande interrompue ; vérifier l’état, aucune relance.');p.rename(p.with_suffix('.done'))
        self.publish()
    def save(self):write_json(self.root/'session.json',{'state':self.session,'digest':key(self.session)})
    def select(self,mode):
        if mode not in MODES:raise Blocked('Scénario inconnu')
        source='source-'+uuid.uuid4().hex;pc=dict(self.m['pdfContext']);pc['document']='SIM-DOC2' if mode=='second' else 'SIM-DOC1'
        data=(Path(self.spec['assets'])/({'blank':'blanc','header':'entete'}[mode]+'.pdf')).read_bytes() if mode in ['blank','header'] else self.pdf
        self.reader=fixture(self.root/source,pc,data)
        with sqlite3.connect(self.reader.database) as db:
            if mode=='wrong_patient':db.execute("UPDATE care_episodes SET patient_id='SIM-B' WHERE care_episode_id=?",(pc['episode'],))
            if mode=='wrong_episode':db.execute("UPDATE episode_documents SET case_id='SIM-E2'")
            if mode=='archived':db.execute('UPDATE episode_documents SET archived_at=1')
            if mode=='nia':db.execute("UPDATE patient_fr_health_identity SET ins_oid='fixture:oid:nia'")
        if mode=='unavailable':(self.reader.root/'piece.pdf').unlink()
        self.flow=PieceWorkflow.create(self.root/'stores',self.reader,self.worker.configuration,self.refs)
        self.importer=PieceImport(self.flow,self.spec['dart'],self.spec['poppler'],self.spec['repo'])
        count=getattr(self,'session',{}).get('nativeJobs',0)
        self.session={'scope':BRIDGE,'mode':mode,'source':source,'workflow':self.flow.root.name,'pdfContext':pc,'nativeJobs':count};self.save()
        self.capture()
    def capture(self):
        try:self.importer.capture(self.session['pdfContext'],self.m['cdaContext'])
        except Exception as e:
            s=self.flow.read();s.update(status='bloque',approved=False,message=str(e));self.flow.save(s)
    def state(self):
        s=self.flow.read();i=s.get('identity',{}).get('payload',{}).get('identity',{});pc=self.session['pdfContext'];previews=[];sha='';white=False;context={}
        if s['capture']:
            m,_=snapshot(self.flow.root/s['capture']);sha=m['pdfSha'];white=m['allWhite'];context=m['cdaContext']
            for name,h in sorted(m['previews'].items()):previews.append({'path':str((self.flow.root/s['capture']/name).relative_to(self.root)),'sha256':h})
        mode=self.session['mode'];message=s.get('message','Revue de cette pièce et de cette version requise.')
        if s['status']=='bloque':
            message={'wrong_patient':'Pièce d’un autre patient : rattachement refusé.','wrong_episode':'Pièce d’un autre épisode : rattachement refusé.','archived':'Pièce archivée : préparation bloquée.','unavailable':'Fichier source indisponible : préparation bloquée.'}.get(mode,message)
        if white:message='Page blanche détectée : confirmation clinique impossible.'
        if mode=='header':message='Témoin en-tête seul : aucun contenu clinique à confirmer.'
        if s['status']=='validee':message='Revue de la pièce et confirmation d’identité enregistrées pour cette version. PDF/A et CDA non vérifiés.'
        return {'scope':BRIDGE,'mode':mode,'binding':s['binding'],'approved':s['approved'],'status':s['status'],'message':message,'pdfSha':sha,'patient':pc['patient'],'episode':pc['episode'],'document':pc['document'],'title':'Bilan PDF synthétique '+pc['document'],'family':i.get('birth_last_name','Indisponible'),'given':i.get('birth_first_names','Indisponible'),'birthDate':i.get('birth_date','Indisponible'),'context':context,'previews':previews,'clinicalCandidate':bool(previews) and not white and mode!='header' and s['status']!='bloque','held':True,'calls':0,'nativeJobs':self.session['nativeJobs']}
    def publish(self):
        v=self.state();write_json(self.root/'view.json',{'state':v,'digest':key(v)});write_json(self.root/'ready.json',{'scope':BRIDGE,'at':time.time()})
    def response(self,id,error=''):
        if not re.fullmatch(r'[a-f0-9]{32}',id):raise Blocked('Commande invalide')
        result={'id':id,'error':error};write_json(self.root/'responses'/(id+'.json'),{'result':result,'digest':key(result)})
    def command(self,q):
        if set(q)!={'id','action','binding','mode','review'}:raise Blocked('Commande invalide')
        action=q['action'];s=self.flow.read()
        if action=='select':self.select(q['mode']);return
        if action=='refresh':self.flow.recover();return
        if q['binding']!=s['binding'] or q['mode']!=self.session['mode']:raise Blocked('Version ou pièce modifiée : confirmation à refaire.')
        if action=='approve':
            review=q['review']
            if set(review)!={'pages','clinical','patient','contextConfirmed'} or not self.state()['clinicalCandidate']:raise Blocked('Revue clinique de la pièce requise')
            if review['clinical'] is not True or review['contextConfirmed'] is not True or review['patient']!=self.session['pdfContext']['patient']:raise Blocked('Contenu, patient et contexte à confirmer')
            self.importer.confirm(q['binding'],pages=review['pages'],clinical=True,patient=review['patient'],context_confirmed=True)
        elif action=='change':
            mode=self.session['mode']
            if mode=='changed_pdf':(self.reader.root/'piece.pdf').write_bytes((Path(self.spec['assets'])/'contenu_modifie.pdf').read_bytes())
            elif mode in ['changed_identity','changed_link']:
                with sqlite3.connect(self.reader.database) as db:
                    if mode=='changed_identity':db.execute("UPDATE patient_fr_health_identity SET birth_last_name='SYNTHETIQUE-MODIFIE',updated_at=updated_at+1")
                    else:db.execute("UPDATE episode_documents SET case_id='SIM-E2'")
            else:raise Blocked('Scénario non modifiable')
            self.flow.recover();self.capture()
            s=self.flow.read()
            if s['status']!='bloque':s['message']='Source modifiée : nouvelle copie, revue et confirmation requises.';self.flow.save(s)
        elif action=='run':
            token,m,job=self.flow.begin();self.session['nativeJobs']+=1;self.save();self.publish()
            _,pdf=self.flow.base.capture(self.flow.base.read());xml=self.flow.xml(self.template,m,pdf)
            if self.session['mode']=='different':
                r=parse_xml(xml);r.find('c:recordTarget/c:patientRole/c:patient/c:name/c:family',NS).text='AUTRE';xml=E.tostring(r)
            self.worker.execute(token,m,job,pdf,xml);self.flow.finish(token)
        else:raise Blocked('Action inconnue')
    def serve(self):
        print('Service pièce PDF prêt. Dossier à choisir dans ABAK : '+str(self.root),flush=True)
        while True:
            safe_tree(self.root);self.publish()
            for p in sorted((self.root/'requests').glob('*.json')):
                w=p.with_suffix('.working');p.rename(w);error=''
                try:
                    q=json.loads(w.read_text())
                    if q.get('id')!=p.stem:raise Blocked('Commande invalide')
                    self.command(q)
                except Exception as e:
                    error=str(e)[:300];self.flow.recover()
                self.publish();self.response(p.stem,error);w.rename(w.with_suffix('.done'))
            time.sleep(.5)
if __name__=='__main__':
    try:Demo(json.loads(Path(sys.argv[1]).read_text())).serve()
    except KeyboardInterrupt:print('Service arrêté ; états conservés.')
