"""File-only demonstration, launched under network denial. Synthetic DB only."""
from identity import *
import time
BRIDGE='ABAK-IDENTITY-DEMO-1'
MODES={'qualified':'Identité qualifiée synthétique','doubtful':'Identité douteuse','nia':'Identifiant NIA','missing':'Identité incomplète','changed':'Identité modifiée','different':'Identité CDA différente','unavailable':'Source indisponible'}
def fixture(root,m):
    root.mkdir();(root/'scope').write_text(SCOPE2);path=root/'synthetic.db';c=m['pdfContext']
    with sqlite3.connect(path) as db:
        db.executescript('CREATE TABLE patients(patient_id TEXT, archived_at INTEGER); CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT,archived_at INTEGER); CREATE TABLE care_episode_reports(report_id TEXT,care_episode_id TEXT,archived_at INTEGER); CREATE TABLE patient_fr_health_identity('+','.join(f+' '+('INTEGER' if f in ['identity_doubtful','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at'] else 'TEXT') for f in FIELDS)+');')
        db.execute('INSERT INTO patients VALUES (?,NULL)',(c['patient'],));db.execute('INSERT INTO care_episodes VALUES (?,?,NULL)',(c['episode'],c['patient']));db.execute('INSERT INTO care_episode_reports VALUES (?,?,NULL)',(c['document'],c['episode']))
        values=[c['patient'],c['patient'],'FIXTURE-KEY',OID,'SYNTHETIQUE','Fictif','1987-01-01','M','SIM-LIEU','qualified',0,'fixture-proof',1,'SIM-AGENT',1,1,1]
        db.execute('INSERT INTO patient_fr_health_identity VALUES ('+','.join('?' for _ in values)+')',values)
    return IdentityReader(root,path)
class Demo:
    def __init__(self,spec):
        self.root=safe_tree(spec['root']);r=self.root
        if r.exists() and any(r.iterdir()) and not (r/'demo.scope').exists():raise Blocked('Dossier neuf requis')
        r.mkdir(exist_ok=True,parents=True)
        if (r/'demo.scope').exists() and (r/'demo.scope').read_text()!=BRIDGE:raise Blocked('Dossier incorrect')
        (r/'demo.scope').write_text(BRIDGE)
        self.lock=(r/'service.lock').open('a');fcntl.flock(self.lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        for n in ['requests','responses','stores']:(r/n).mkdir(exist_ok=True)
        self.source=Path(spec['snapshot']);self.m,_=snapshot(self.source);self.template=Path(spec['template']).read_bytes()
        work=r/('worker-'+uuid.uuid4().hex);work.mkdir();refs=work/'references';shutil.copytree(spec['references'],refs)
        home=work/'java-profile';home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(home)
        self.worker=NativeWorker(refs,spec['validator'],spec['java'],work/'native',self.template);self.refs=refs
        if (r/'session.json').exists():
            e=json.loads((r/'session.json').read_text());self.session=e['state']
            if key(self.session)!=e['digest']:raise Blocked('Session altérée')
            for k,prefix in [('source','source-'),('workflow','identity-isole-')]:
                if not re.fullmatch(prefix+r'[a-f0-9]{32}',self.session[k]):raise Blocked('Chemin session invalide')
            self.reader=IdentityReader(r/self.session['source'],r/self.session['source']/'synthetic.db')
            self.flow=IdentityWorkflow(r/'stores'/self.session['workflow'],self.reader,self.worker.configuration,refs)
            self.flow.recover()
        else:self.select('qualified')
        # Requests interrupted by shutdown are not automatically replayed.
        for p in (r/'requests').glob('*.working'):
            self.response(p.stem,'Commande interrompue ; état à vérifier.');p.rename(p.with_suffix('.done'))
        self.publish()
    def save(self):write_json(self.root/'session.json',{'state':self.session,'digest':key(self.session)})
    def select(self,mode):
        if mode not in MODES:raise Blocked('Scénario inconnu')
        source='source-'+uuid.uuid4().hex;self.reader=fixture(self.root/source,self.m)
        with sqlite3.connect(self.reader.database) as db:
            if mode=='doubtful':db.execute('UPDATE patient_fr_health_identity SET identity_doubtful=1')
            if mode=='nia':db.execute("UPDATE patient_fr_health_identity SET ins_oid='fixture:oid:nia'")
            if mode=='missing':db.execute('UPDATE patient_fr_health_identity SET birth_last_name=NULL')
        self.flow=IdentityWorkflow.create(self.root/'stores',self.reader,self.worker.configuration,self.refs)
        self.session={'mode':mode,'source':source,'workflow':self.flow.root.name};self.save()
        try:self.flow.stage(self.source)
        except Exception as e:
            s=self.flow.read();s.update(status='bloque',message=str(e));self.flow.save(s)
        if mode=='unavailable':
            self.reader.database.rename(self.reader.database.with_suffix('.absent'));self.flow.recover()
    def state(self):
        s=self.flow.read();i=s.get('identity',{}).get('payload',{}).get('identity',{})
        return {'mode':self.session['mode'],'binding':s['binding'],'approved':s['approved'],'status':s['status'],'message':('Source indisponible : historique conservé, poursuite bloquée.' if self.session['mode']=='unavailable' else s.get('message','Confirmation de cette version requise.')),'pdfSha':self.m['pdfSha'],'patient':self.m['pdfContext']['patient'],'family':i.get('birth_last_name','Indisponible'),'given':i.get('birth_first_names','Indisponible'),'birthDate':i.get('birth_date','Indisponible'),'held':True,'calls':0,'scope':BRIDGE}
    def publish(self):
        v=self.state();write_json(self.root/'view.json',{'state':v,'digest':key(v)});write_json(self.root/'ready.json',{'scope':BRIDGE,'at':time.time()})
    def response(self,id,error=''):
        if not re.fullmatch(r'[a-f0-9]{32}',id):raise Blocked('Commande invalide')
        result={'id':id,'error':error};write_json(self.root/'responses'/(id+'.json'),{'result':result,'digest':key(result)})
    def command(self,q):
        if set(q)!={'id','action','binding','mode'}:raise Blocked('Commande invalide')
        action=q['action'];s=self.flow.read()
        if action=='select':self.select(q['mode']);return
        if action=='refresh':self.flow.recover();return
        if q['binding']!=s['binding'] or q['mode']!=self.session['mode']:raise Blocked('Version modifiée : confirmation à refaire.')
        if action=='approve':self.flow.approve(q['binding'],True)
        elif action=='change':
            if self.session['mode']!='changed':raise Blocked('Scénario incorrect')
            with sqlite3.connect(self.reader.database) as db:db.execute("UPDATE patient_fr_health_identity SET birth_last_name='SYNTHETIQUE-MODIFIE',updated_at=updated_at+1")
            self.flow.recover();self.flow.stage(self.source)
            changed=self.flow.read();changed['message']='Identité modifiée : nouvelle confirmation de la version requise.';self.flow.save(changed)
        elif action=='run':
            token,m,job=self.flow.begin();self.publish();_,pdf=self.flow.base.capture(self.flow.base.read());xml=self.flow.xml(self.template,m,pdf)
            if self.session['mode']=='different':
                r=parse_xml(xml);r.find('c:recordTarget/c:patientRole/c:patient/c:name/c:family',NS).text='AUTRE';xml=E.tostring(r)
            self.worker.execute(token,m,job,pdf,xml);self.flow.finish(token)
        else:raise Blocked('Action inconnue')
    def serve(self):
        print('Service identité prêt. Dossier à choisir dans ABAK : '+str(self.root),flush=True)
        while True:
            safe_tree(self.root);self.publish()
            for p in sorted((self.root/'requests').glob('*.json')):
                w=p.with_suffix('.working');p.rename(w);error=''
                try:
                    q=json.loads(w.read_text())
                    if q.get('id')!=p.stem:raise Blocked('Identifiant de commande invalide')
                    self.command(q)
                except Exception as e:error=str(e)[:250]
                self.publish();self.response(p.stem,error);w.rename(w.with_suffix('.done'))
            time.sleep(.5)
if __name__=='__main__':
    try:Demo(json.loads(Path(sys.argv[1]).read_text())).serve()
    except KeyboardInterrupt:print('Service arrêté, états conservés.')
