from piece import *
import socket

def main():
    spec=json.loads(Path(sys.argv[1]).read_text());out=Path(spec['out']);out.mkdir();(out/'stores').mkdir()
    refs=out/'references';shutil.copytree(spec['references'],refs)
    home=out/'java-profile';home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(home)
    template=Path(spec['template']).read_bytes();worker=NativeWorker(refs,spec['validator'],spec['java'],out/'native',template)
    m,pdf=snapshot(Path(spec['snapshot']));pc=m['pdfContext'];cc=m['cdaContext'];assets=Path(spec['assets'])
    checks=[];runs=[];mutations=[];fixtures=[];assertions=[]
    def ok(value,label):
        assert value,label
        assertions.append(label)
    def blocked(fn):
        try:fn()
        except (ValueError,OSError,sqlite3.Error,KeyError,TypeError):assertions.append('blocage attendu');return
        raise AssertionError('Blocage absent')
    def fixture(data=pdf):
        root=out/('source-'+uuid.uuid4().hex);root.mkdir();(root/'scope').write_text(SCOPE2);path=root/'synthetic.db';(root/'final.pdf').write_bytes(data)
        with sqlite3.connect(path) as db:
            db.executescript('CREATE TABLE patients(patient_id TEXT, archived_at INTEGER); CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT,archived_at INTEGER); CREATE TABLE episode_documents(document_id TEXT,case_id TEXT,title TEXT,file_path TEXT,mime_type TEXT,source TEXT,created_at INTEGER,updated_at INTEGER,archived_at INTEGER); CREATE TABLE patient_fr_health_identity('+','.join(f+' '+('INTEGER' if f in ['identity_doubtful','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at'] else 'TEXT') for f in FIELDS)+');')
            db.execute('INSERT INTO patients VALUES (?,NULL)',(pc['patient'],));db.execute('INSERT INTO care_episodes VALUES (?,?,NULL)',(pc['episode'],pc['patient']))
            db.execute('INSERT INTO episode_documents VALUES (?,?,?,?,?,?,1,1,NULL)',(pc['document'],pc['episode'],'PDF final synthétique',str(root/'final.pdf'),'application/pdf','fixture'))
            vals=[pc['patient'],pc['patient'],'FIXTURE-KEY',OID,'SYNTHETIQUE','Fictif','1987-01-01','M','SIM-LIEU','qualified',0,'fixture-proof',1,'SIM-AGENT',1,1,1]
            db.execute('INSERT INTO patient_fr_health_identity VALUES ('+','.join('?' for _ in vals)+')',vals)
        fixtures.append(path);return PieceReader(root,path)
    def mutate(r,sql,args=()):
        mutations.append({'database':str(r.database),'sql':sql,'parameters':args})
        with sqlite3.connect(r.database) as db:db.execute(sql,args)
    def read(r):return r.read(pc['patient'],pc['episode'],pc['document'])
    def badsql(sql,args=()):
        r=fixture();mutate(r,sql,args);before=digest(r.database.read_bytes());blocked(lambda:read(r));ok(before==digest(r.database.read_bytes()),'source inchangée après refus')
    def fresh(r=None,approve=True):
        r=r or fixture();b=PieceWorkflow.create(out/'stores',r,worker.configuration,refs);a=PieceImport(b,spec['dart'],spec['poppler'],spec['repo']);binding=a.capture(pc,cc)
        if approve:a.confirm(binding,pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True)
        return b,r,a
    def run(b,alter=None):
        token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data)
        if alter=='identity':xml=xml.replace(b'SYNTHETIQUE',b'AUTRE',1)
        if alter=='pdf':
            x=parse_xml(xml);x.find('c:component/c:nonXMLBody/c:text',NS).text=base64.b64encode(data+b'\n').decode();xml=E.tostring(x)
        cached=worker.execute(token,manifest,job,data,xml);runs.append({'job':str(job),'cached':cached,'alter':alter or 'none'})
        return token,b.finish(token)
    def reopen(b,r):
        cp=subprocess.run([sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root),str(r.root),str(r.database),worker.configuration,str(refs)],capture_output=True,text=True,timeout=60)
        ok(cp.returncode==0,cp.stderr);return json.loads(cp.stdout)
    def check(n,fn):
        start=len(assertions);fn();checks.append({'group':n,'status':'PASS','assertions':len(assertions)-start});write_json(out/'Resultats_28.json',checks);print(n,'PASS',flush=True)
    def positive():
        b,r,a=fresh();before=digest(r.database.read_bytes());ok(run(b)[1]=='conforme','PDF/A et CDA natifs conformes');ok(before==digest(r.database.read_bytes()),'source en lecture seule');ok(b.read()['held'] and b.read()['calls']==0,'envoi interdit')
    check('P01',positive)
    check('P02',lambda:badsql("UPDATE care_episodes SET patient_id='SIM-B'"))
    check('P03',lambda:badsql("UPDATE episode_documents SET case_id='SIM-E2'"))
    check('P04',lambda:[badsql(s) for s in ['DELETE FROM care_episodes','UPDATE episode_documents SET case_id=NULL']])
    check('P05',lambda:[badsql(s) for s in ['DELETE FROM episode_documents','UPDATE episode_documents SET archived_at=1']])
    check('P06',lambda:[badsql('UPDATE '+t+' SET archived_at=1') for t in ['patients','care_episodes']])
    def ambiguous():
        for t in ['episode_documents','patients','care_episodes','patient_fr_health_identity']:badsql('INSERT INTO '+t+' SELECT * FROM '+t)
        r=fixture();before=read(r);mutate(r,'CREATE TABLE care_episode_reports(report_id TEXT,care_episode_id TEXT)');mutate(r,'INSERT INTO care_episode_reports VALUES (?,?)',(pc['document'],'SIM-OTHER'));ok(before==read(r),'aucun repli sur rapport de même identifiant')
    check('P07',ambiguous)
    check('P08',lambda:[badsql(s) for s in ['DELETE FROM patient_fr_health_identity',"UPDATE patient_fr_health_identity SET identity_status='retrieved'",'UPDATE patient_fr_health_identity SET identity_doubtful=1',"UPDATE patient_fr_health_identity SET ins_oid='fixture:oid:nia'",'UPDATE patient_fr_health_identity SET birth_last_name=NULL',"UPDATE patient_fr_health_identity SET ins_oid='unknown'"]])
    def inaccessible():
        r=fixture();f=r.root/'final.pdf';f.unlink();blocked(lambda:read(r))
        r=fixture();f=r.root/'final.pdf';f.chmod(0)
        try:blocked(lambda:read(r))
        finally:f.chmod(0o600)
        badsql('UPDATE episode_documents SET file_path=NULL')
    check('P09',inaccessible)
    def paths():
        for name in ['/etc/passwd',str(out/'external.pdf'),'../final.pdf']:
            r=fixture();mutate(r,'UPDATE episode_documents SET file_path=?',(name,));blocked(lambda:read(r))
        r=fixture();f=r.root/'final.pdf';f.unlink();f.symlink_to(out/'external.pdf');blocked(lambda:read(r));f.unlink()
        r=fixture();f=r.root/'final.pdf';f.unlink();f.mkdir();blocked(lambda:read(r))
        r=fixture();f=r.root/'final.pdf'
        def link():f.unlink();f.symlink_to(out/'external.pdf')
        r.hook=link;blocked(lambda:read(r));f.unlink()
    check('P10',paths)
    def mime():
        for value in [None,'text/plain']:badsql('UPDATE episode_documents SET mime_type=?',(value,))
        r=fixture(b'not a PDF');blocked(lambda:read(r))
        r=fixture();f=r.root/'final.pdf';f.rename(r.root/'final.docx');mutate(r,'UPDATE episode_documents SET file_path=?',(str(r.root/'final.docx'),));blocked(lambda:read(r))
    check('P11',mime)
    def limits():
        for data in [b'',pdf+b' '*(LIMIT+1),pdf[:-8]]:r=fixture(data);blocked(lambda:read(r))
        r=fixture(pdf+b' '*(LIMIT-len(pdf)));ok(read(r)['payload']['document']['pdfSize']==LIMIT,'limite exacte 20 MiB autorisée')
        r=fixture((assets/'chiffre.pdf').read_bytes());blocked(lambda:fresh(r))
    check('P12',limits)
    def empty():
        for name in ['blanc','entete']:
            b,r,a=fresh(fixture((assets/(name+'.pdf')).read_bytes()),False)
            blocked(lambda:a.confirm(b.read()['binding'],pages=[1],clinical=(name=='blanc'),patient=pc['patient'],context_confirmed=True));ok(not b.read()['approved'],'absence clinique non validée');ok(not reopen(b,r)['approved'],'absence clinique persistante')
    check('P13',empty)
    def context():
        b,r,a=fresh(approve=False);i=read(r)
        for k in ['author','structure','type','class','confidentiality','date']:
            c=dict(cc);del c[k];blocked(lambda:a.export(r.frozen,i,pc,c))
        blocked(lambda:a.confirm(b.read()['binding'],pages=[1],clinical=True,patient=pc['patient'],context_confirmed=False))
    check('P14',context)
    def race():
        for mode in ['replace','truncate','row']:
            r=fixture()
            def change():
                if mode=='row':mutate(r,"UPDATE episode_documents SET title='modifié'")
                else:(r.root/'final.pdf').write_bytes(pdf+b'\n' if mode=='replace' else b'%PDF-')
            r.hook=change;blocked(lambda:read(r))
    check('P15',race)
    def changed(approve):
        b,r,a=fresh(approve=approve);(r.root/'final.pdf').write_bytes((assets/'contenu_modifie.pdf').read_bytes())
        blocked(lambda:b.begin() if approve else a.confirm(b.read()['binding'],pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True));ok(not reopen(b,r)['approved'],'modification invalide la revue')
    check('P16',lambda:changed(False))
    def during():
        changed(True);b,r,a=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data);cached=worker.execute(token,manifest,job,data,xml);runs.append({'job':str(job),'cached':cached})
        (r.root/'final.pdf').write_bytes(pdf+b'\n');ok(b.finish(token)=='bloque','résultat natif devenu périmé refusé')
    check('P17',during)
    def metadata():
        b,r,a=fresh();data=pdf.replace(b'%%EOF',b'% metadata-only fixture\n%%EOF');(r.root/'final.pdf').write_bytes(data);blocked(b.begin);ok(not reopen(b,r)['approved'],'octets changés même sans changement visuel')
    check('P18',metadata)
    def rows():
        for col,value in [('title','nouveau'),('mime_type','application/x-pdf'),('source','autre'),('updated_at',2),('created_at',2),('file_path','MOVE')]:
            b,r,a=fresh()
            if value=='MOVE':new=r.root/'moved.pdf';shutil.copyfile(r.root/'final.pdf',new);value=str(new)
            mutate(r,'UPDATE episode_documents SET '+col+'=?',(value,));blocked(b.begin);ok(not reopen(b,r)['approved'],'changement ligne invalide '+col)
    check('P19',rows)
    def moving():
        for sql in ["UPDATE episode_documents SET case_id='SIM-E2'","UPDATE care_episodes SET patient_id='SIM-B'"]:
            b,r,a=fresh();mutate(r,sql);blocked(b.begin);ok(not reopen(b,r)['approved'],'rattachement modifié bloqué')
    check('P20',moving)
    def identity_change():
        for sql in ["UPDATE patient_fr_health_identity SET birth_last_name='AUTRE'",'UPDATE patient_fr_health_identity SET updated_at=2','UPDATE patient_fr_health_identity SET identity_doubtful=1']:
            b,r,a=fresh();mutate(r,sql);blocked(b.begin);ok(not reopen(b,r)['approved'],'identité modifiée bloquée')
    check('P21',identity_change)
    def cda():
        for mode in ['identity','pdf']:
            b,r,a=fresh();status=run(b,mode)[1];ok(status in ['bloque','refuse'],'CDA différent refusé '+status);ok(reopen(b,r)['status']==status,'refus CDA persistant')
    check('P22',cda)
    def late():
        for different in [False,True]:
            b,r,a=fresh();token,_,_=b.begin()
            c=dict(pc)
            if different:
                c['document']='SIM-DOC2';mutate(r,'INSERT INTO episode_documents SELECT ?,case_id,title,file_path,mime_type,source,created_at,updated_at,archived_at FROM episode_documents',(c['document'],))
            old_binding=b.read()['binding'];new_binding=a.capture(c,cc);ok(old_binding!=new_binding,'nouvelle génération même contenu');blocked(lambda:a.confirm(old_binding,pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True));ok(b.finish(token)=='bloque','ancien jeton rejeté après nouvelle sélection')
        b,r,a=fresh();original=a.export;second={}
        def delayed(*args,**kwargs):
            dest=original(*args,**kwargs);a.export=original
            second['binding']=a.capture(pc,cc)
            return dest
        a.export=delayed;blocked(lambda:a.capture(pc,cc));ok(b.read()['binding']==second['binding'],'import tardif ne remplace pas la sélection récente')
    check('P23',late)
    def stable():
        b,r,a=fresh();ok(reopen(b,r)['approved'],'confirmation persistante autre processus');run(b);before=len(runs);count=len(list((b.base.root/'jobs').iterdir()));s=reopen(b,r);ok(s['status']=='conforme' and s['held'] and s['calls']==0,'conformité persistante');ok(len(runs)==before and len(list((b.base.root/'jobs').iterdir()))==count,'aucune relance implicite')
    check('P24',stable)
    def changed_reopen():
        for mode in ['delete','move','identity','archive','journal']:
            b,r,a=fresh()
            if mode=='delete':(r.root/'final.pdf').unlink()
            if mode=='move':(r.root/'final.pdf').rename(r.root/'moved.pdf')
            if mode=='identity':mutate(r,'DELETE FROM patient_fr_health_identity')
            if mode=='archive':mutate(r,'UPDATE episode_documents SET archived_at=1')
            if mode=='journal':(b.root/'identity.json').write_text('{}');blocked(b.read);continue
            s=reopen(b,r);ok(s['status']=='bloque' and s['history'] and not s['approved'],'réouverture modifiée '+mode)
    check('P25',changed_reopen)
    def failures():
        b,r,a=fresh(fixture((assets/'sans_xmp.pdf').read_bytes()));ok(run(b)[1]=='refuse','non conformité distincte');ok(reopen(b,r)['status']=='refuse','refus persistant')
        b,r,a=fresh();b.begin();ok(reopen(b,r)['status']=='bloque','interruption sans reprise automatique')
        b,r,a=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());xml=b.xml(template,manifest,data)
        # Inject a missing tool path only into this worker, never alter the installation.
        fault_worker=copy.copy(worker);fault_worker.validator=str(out/'absent-verapdf');fault_worker.cache={};fault_worker.work=out/'native-absent';fault_worker.work.mkdir()
        fault_worker.execute(token,manifest,job,data,xml)
        ok(b.finish(token)=='non_verifie','outil absent distinct du refus')
        ok(reopen(b,r)['status']=='non_verifie','outil absent non vérifié persistant')
        b,r,a=fresh(approve=False);old=b.save
        def fail(s):raise OSError('écriture indisponible injectée')
        b.save=fail;blocked(lambda:a.confirm(b.read()['binding'],pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True));b.save=old
        ok(not reopen(b,r)['approved'],'échec écriture ne valide pas')
    check('P26',failures)
    def lineage():
        b,r,a=fresh();old=b.read()['binding'];c=dict(pc);c['document']='SIM-DOC2';mutate(r,'INSERT INTO episode_documents SELECT ?,case_id,title,file_path,mime_type,source,created_at,updated_at,archived_at FROM episode_documents',(c['document'],));new=a.capture(c,cc)
        ok(new!=old and not b.read()['approved'],'même PDF autre pièce sans héritage');blocked(b.begin);blocked(lambda:b.stage(Path(spec['snapshot'])));ok(not b.read()['approved'],'ancienne archive sans héritage')
    check('P27',lineage)
    def isolation():
        r=fixture();before={str(p):digest(p.read_bytes()) for p in [r.database,r.root/'final.pdf']};read(r);ok(before=={p:digest(Path(p).read_bytes()) for p in before},'empreintes source conservées')
        with sqlite3.connect(r.database.as_uri()+'?mode=ro',uri=True) as db:blocked(lambda:db.execute('DELETE FROM patients'))
        s=socket.socket()
        try:blocked(lambda:s.bind(('127.0.0.1',0)))
        finally:s.close()
        for root in (out/'stores').iterdir():
            j=json.loads((root/'identity.json').read_text())
            if j:ok(j['state']['held'] and j['state']['calls']==0,'retenue permanente et aucun transport')
        write_json(out/'Empreintes_source.json',before)
    check('P28',isolation)
    write_json(out/'Mutations_du_harnais.json',mutations)
    write_json(out/'Synthese.json',{'groups':len(checks),'assertions':len(assertions),'nativeRuns':runs,'sourceDatabases':len(fixtures),'transportCalls':0,'networkDenied':True,'identityWritesByAdapter':0,'scope':'synthetic-only'})
if __name__=='__main__':
    if sys.argv[1]=='--reopen':
        _,_,root,source,db,configuration,resources=sys.argv
        print(json.dumps(PieceWorkflow(Path(root),PieceReader(Path(source),Path(db)),configuration,Path(resources)).recover()))
    else:main()
