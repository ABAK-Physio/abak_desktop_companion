from identity import *
import subprocess, socket

def main():
    spec=json.loads(Path(sys.argv[1]).read_text());out=Path(spec['out'])
    if out.exists():raise RuntimeError('Sortie neuve requise')
    out.mkdir();(out/'stores').mkdir();refs=out/'references';shutil.copytree(spec['references'],refs)
    home=out/'java-profile';home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(home)
    template=Path(spec['template']).read_bytes();worker=NativeWorker(refs,spec['validator'],spec['java'],out/'native',template)
    capture=Path(spec['snapshot']);m,pdf=snapshot(capture);c=m['pdfContext'];assert m['clinical']
    fixtures=[];checks=[];runs=[]
    def fixture():
        root=out/('source-'+uuid.uuid4().hex);root.mkdir();(root/'scope').write_text(SCOPE2);path=root/'synthetic.db'
        db=sqlite3.connect(path)
        db.executescript('CREATE TABLE patients(patient_id TEXT, archived_at INTEGER); CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT,archived_at INTEGER); CREATE TABLE care_episode_reports(report_id TEXT,care_episode_id TEXT,archived_at INTEGER); CREATE TABLE patient_fr_health_identity('+','.join(f+' '+('INTEGER' if f in ['identity_doubtful','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at'] else 'TEXT') for f in FIELDS)+');')
        db.execute('INSERT INTO patients VALUES (?,NULL)',(c['patient'],));db.execute('INSERT INTO care_episodes VALUES (?,?,NULL)',(c['episode'],c['patient']));db.execute('INSERT INTO care_episode_reports VALUES (?,?,NULL)',(c['document'],c['episode']))
        values=[c['patient'],c['patient'],'FIXTURE-KEY',OID,'SYNTHETIQUE','Fictif','1987-01-01','M','SIM-LIEU','qualified',0,'fixture-proof',1,'SIM-AGENT',1,1,1]
        db.execute('INSERT INTO patient_fr_health_identity VALUES ('+','.join('?' for _ in values)+')',values);db.commit();db.close();fixtures.append(path)
        return IdentityReader(root,path)
    def mutate(r,sql,args=()):
        with sqlite3.connect(r.database) as db:db.execute(sql,args)
    def read(r):return r.read(c['patient'],c['episode'],c['document'])
    def blocked(fn):
        try:fn()
        except (ValueError,OSError,sqlite3.Error,KeyError,TypeError):return
        raise AssertionError('Blocage absent')
    def fresh(r=None,approve=True):
        r=r or fixture();b=IdentityWorkflow.create(out/'stores',r,worker.configuration,refs);binding=b.stage(capture)
        if approve:b.approve(binding,True)
        return b,r
    def run(b,alter=False):
        token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data)
        if alter:
            x=parse_xml(xml);x.find('c:recordTarget/c:patientRole/c:patient/c:name/c:family',NS).text='AUTRE';xml=E.tostring(x)
        cached=worker.execute(token,manifest,job,data,xml);runs.append({'job':str(job),'cached':cached})
        return token,b.finish(token)
    def reopen(b,r):
        args=[sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root),str(r.root),str(r.database),worker.configuration,str(refs)]
        cp=subprocess.run(args,capture_output=True,text=True,timeout=60);assert cp.returncode==0,cp.stderr
        return json.loads(cp.stdout)
    def check(n,fn):
        fn()
        checks.append({'group':n,'status':'PASS'});write_json(out/'Resultats_20.json',checks);print(n,'PASS',flush=True)
    def positive():
        b,r=fresh();before=digest(r.database.read_bytes());assert run(b)[1]=='conforme',b.read();assert digest(r.database.read_bytes())==before
        assert b.read()['held'] and b.read()['calls']==0
    check('I01',positive)
    def change(sql,args=()):
        r=fixture();mutate(r,sql,args);before=digest(r.database.read_bytes());blocked(lambda:read(r));assert digest(r.database.read_bytes())==before
    check('I02',lambda:change('DELETE FROM patient_fr_health_identity'))
    check('I03',lambda:[change('UPDATE patient_fr_health_identity SET identity_status=?',(v,)) for v in ['provisional','retrieved','validated','unknown']])
    check('I04',lambda:change('UPDATE patient_fr_health_identity SET identity_doubtful=1'))
    check('I05',lambda:change("UPDATE patient_fr_health_identity SET ins_oid='fixture:oid:nia'"))
    check('I06',lambda:[change('UPDATE patient_fr_health_identity SET ins_oid=?',(v,)) for v in ['unknown','fixture:oid:nir']])
    check('I07',lambda:[change('UPDATE patient_fr_health_identity SET '+f+'=NULL') for f in ['ins_number','ins_key','ins_oid']])
    def verifier():
        for fn in [lambda i:False, lambda i:(_ for _ in ()).throw(Blocked('Indisponible'))]:
            r=fixture();r.verifier=fn;blocked(lambda:read(r))
    check('I08',verifier)
    check('I09',lambda:[change('UPDATE patient_fr_health_identity SET '+f+'=?',(v,)) for f,v in [('birth_last_name',''),('birth_first_names',''),('birth_date','2026-99-32'),('sex_code','?'),('birth_place_code','')]])
    check('I10',lambda:[change('UPDATE patient_fr_health_identity SET '+f+'=NULL') for f in ['identity_validation_method','identity_validated_by','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at']])
    check('I11',lambda:[change(sql) for sql in ["UPDATE care_episodes SET patient_id='SIM-B'","UPDATE care_episode_reports SET care_episode_id='SIM-OTHER'"]])
    check('I12',lambda:[change(sql) for sql in ['INSERT INTO patient_fr_health_identity SELECT * FROM patient_fr_health_identity','UPDATE patients SET archived_at=1','UPDATE care_episodes SET archived_at=1']])
    def changed(approved):
        b,r=fresh(approve=approved);binding=b.read()['binding'];mutate(r,'UPDATE patient_fr_health_identity SET updated_at=2')
        blocked(lambda:b.begin() if approved else b.approve(binding,True));assert reopen(b,r)['approved'] is False
    check('I13',lambda:changed(False));check('I14',lambda:changed(True))
    def late():
        b,r=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data)
        cached=worker.execute(token,manifest,job,data,xml);runs.append({'job':str(job),'cached':cached});mutate(r,"UPDATE patient_fr_health_identity SET birth_last_name='MODIFIE'")
        assert b.finish(token)=='bloque';assert reopen(b,r)['status']=='bloque'
        # A restaged capture must also reject a previously issued result token.
        b,r=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data)
        cached=worker.execute(token,manifest,job,data,xml);runs.append({'job':str(job),'cached':cached})
        binding=b.stage(capture);b.approve(binding,True)
        assert b.finish(token)=='bloque';assert reopen(b,r)['status']=='bloque'
    check('I15',late)
    def wrong():
        b,r=fresh();assert run(b,True)[1]=='bloque';assert reopen(b,r)['status']=='bloque'
    check('I16',wrong)
    def persistence():
        b,r=fresh();run(b);count=len(list((b.base.root/'jobs').iterdir()));s=reopen(b,r);assert s['status']=='conforme' and s['held'] and s['calls']==0;assert len(list((b.base.root/'jobs').iterdir()))==count
    check('I17',persistence)
    def unavailable():
        b,r=fresh();run(b);r.database.rename(r.database.with_suffix('.unavailable'));s=reopen(b,r);assert s['status']=='bloque' and s['history']
        b,r=fresh();(b.root/'identity.json').write_text('{}');blocked(b.read)
    check('I18',unavailable)
    def legacy():
        b,r=fresh(approve=False);assert not b.read()['approved'];blocked(b.begin);blocked(lambda:b.approve('wrong',True));blocked(lambda:b.approve(b.read()['binding'],False))
    check('I19',legacy)
    def isolation():
        r=fixture();before=digest(r.database.read_bytes());read(r);assert before==digest(r.database.read_bytes())
        with sqlite3.connect(r.database.as_uri()+'?mode=ro',uri=True) as db:blocked(lambda:db.execute('DELETE FROM patients'))
        link=r.root/'link';link.symlink_to('/tmp');blocked(lambda:read(r));link.unlink()
        try:
            s=socket.socket();s.bind(('127.0.0.1',0))
        except PermissionError:pass
        else:raise AssertionError('Réseau non interdit')
        finally:s.close()
        for store in (out/'stores').iterdir():
            j=json.loads((store/'identity.json').read_text())
            if not j:continue # deliberately corrupted journal in I18
            assert j['state']['calls']==0 and j['state']['held']
    check('I20',isolation)
    write_json(out/'Synthese.json',{'groups':len(checks),'nativeRuns':runs,'sourceDatabases':len(fixtures),'transportCalls':0,'networkDenied':True,'identityWritesByAdapter':0,'scope':'synthetic-only'})
if __name__=='__main__':
    if sys.argv[1]=='--reopen':
        _,_,root,source,db,configuration,resources=sys.argv
        print(json.dumps(IdentityWorkflow(Path(root),IdentityReader(Path(source),Path(db)),configuration,Path(resources)).recover()))
    else:main()
