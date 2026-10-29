from context import *
import socket

def main():
    spec=json.loads(Path(sys.argv[1]).read_text());out=Path(spec['out']);out.mkdir();(out/'stores').mkdir()
    refs=out/'references';shutil.copytree(spec['references'],refs)
    home=out/'java-profile';home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(home)
    template=Path(spec['template']).read_bytes();worker=NativeWorker(refs,spec['validator'],spec['java'],out/'native',template)
    m,pdf=snapshot(Path(spec['snapshot']));pc=m['pdfContext'];cc=m['cdaContext']
    checks=[];assertions=[];runs=[];sources=[]
    def ok(v,label):
        assert v,label
        assertions.append(label)
    def blocked(fn):
        try:fn()
        except (ValueError,OSError,sqlite3.Error,KeyError,TypeError):assertions.append('blocage attendu');return
        raise AssertionError('Blocage absent')
    def defaults():
        typ={'code':cc['type'],'system':TYPE_SYSTEM,'label':'CR ou fiche de suivi de soins par auxiliaire médical'}
        cls={'code':cc['class'],'system':CLASS_SYSTEM,'label':'Document synthétique'}
        cat={'source':'synthetic','version':'SIM-1','usable':True,'fresh':True,'entries':[dict(typ,active=True),dict(cls,active=True)],'pairs':[[typ['code'],cls['code']]],'mediaPairs':[['application/pdf',FMT]],'lastError':''}
        structure={'id':{'value':'SIM-CABINET','authority':STRUCTURE_AUTHORITY},'name':'CABINET SYNTHETIQUE'}
        return {'profile':PROFILE,'revision':1,'author':'SIM-KINE','authorIdentity':{'value':'SIM-KINE','authority':AUTHORITY},'profession':70,'operator':'SIM-OPERATEUR','rolesConfirmed':True,
          'situation':'SIM-S1','situations':[{'id':'SIM-S1','author':'SIM-KINE','active':True,'mode':'SIM-LIBERAL','status':'SIM-ACTIF','sector':'AMBULATOIRE','facility':'SA07','structure':structure}],
          'custodian':copy.deepcopy(structure),'document':{'title':cc['title'],'date':cc['date'],'type':typ,'class':cls,'media':'application/pdf','format':FMT,'language':'fr-FR','confidentiality':'N','id':cc['id'],'setId':cc['setId'],'version':cc['version']},
          'visibility':{'minor':False,'mode':'normal','patient':True,'rl':True,'maskedPS':False,'previousPatient':False,'previousRL':False,'cumulative':False,'opposition':False,'parameterVersion':'SIM-1'},
          'catalog':cat,'catalogDigest':key(cat),'provenance':'synthetic-explicit'}
    def fixture():
        root=out/('source-'+uuid.uuid4().hex);root.mkdir();(root/'scope').write_text(SCOPE2);(root/'context-scope').write_text(CONTEXT_SCOPE);path=root/'synthetic.db';(root/'final.pdf').write_bytes(pdf)
        with sqlite3.connect(path) as db:
            db.executescript('CREATE TABLE patients(patient_id TEXT, archived_at INTEGER); CREATE TABLE care_episodes(care_episode_id TEXT,patient_id TEXT,archived_at INTEGER); CREATE TABLE episode_documents(document_id TEXT,case_id TEXT,title TEXT,file_path TEXT,mime_type TEXT,source TEXT,created_at INTEGER,updated_at INTEGER,archived_at INTEGER); CREATE TABLE practitioners(practitioner_id TEXT,display_name TEXT,first_name TEXT,last_name TEXT,professional_id TEXT,email TEXT,phone TEXT,is_active INTEGER,created_at INTEGER,updated_at INTEGER,archived_at INTEGER); CREATE TABLE synthetic_document_context(document_id TEXT,body TEXT,revision INTEGER); CREATE TABLE patient_fr_health_identity('+','.join(f+' '+('INTEGER' if f in ['identity_doubtful','identity_validated_at','ins_retrieved_at','ins_last_checked_at','updated_at'] else 'TEXT') for f in FIELDS)+');')
            db.execute('INSERT INTO patients VALUES (?,NULL)',(pc['patient'],));db.execute('INSERT INTO care_episodes VALUES (?,?,NULL)',(pc['episode'],pc['patient']))
            db.execute('INSERT INTO episode_documents VALUES (?,?,?,?,?,?,1,1,NULL)',(pc['document'],pc['episode'],'PDF final synthétique',str(root/'final.pdf'),'application/pdf','fixture'))
            vals=[pc['patient'],pc['patient'],'FIXTURE-KEY',OID,'SYNTHETIQUE','Fictif','1987-01-01','M','SIM-LIEU','qualified',0,'fixture-proof',1,'SIM-AGENT',1,1,1]
            db.execute('INSERT INTO patient_fr_health_identity VALUES ('+','.join('?' for _ in vals)+')',vals)
            db.execute("INSERT INTO practitioners VALUES ('SIM-KINE','KINE SYNTHETIQUE',NULL,NULL,'SIM-KINE',NULL,NULL,1,1,1,NULL)")
            db.execute('INSERT INTO synthetic_document_context VALUES (?,?,1)',(pc['document'],json.dumps(defaults())))
        r=ContextReader(root,path);sources.append(r);return r
    def sql(r,s,args=()):
        with sqlite3.connect(r.database) as db:db.execute(s,args)
    def change(r,fn,catalog=False):
        with sqlite3.connect(r.database) as db:
            c=json.loads(db.execute('SELECT body FROM synthetic_document_context').fetchone()[0]);fn(c);c['revision']+=1
            if catalog:c['catalogDigest']=key(c['catalog'])
            db.execute('UPDATE synthetic_document_context SET body=?,revision=revision+1',(json.dumps(c),))
    def read(r):return r.read(pc['patient'],pc['episode'],pc['document'])
    def bad(fn):
        r=fixture();fn(r);before=digest(r.database.read_bytes());blocked(lambda:read(r));ok(before==digest(r.database.read_bytes()),'refus en lecture seule')
    def fresh(r=None,approve=True):
        r=r or fixture();b=ContextWorkflow.create(out/'stores',r,worker.configuration,refs);a=ContextImport(b,spec['dart'],spec['poppler'],spec['repo']);binding=a.capture_context(pc)
        if approve:a.confirm(binding,pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True)
        return b,r,a
    def reopen(b,r):
        cp=subprocess.run([sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root),str(r.root),str(r.database),worker.configuration,str(refs)],capture_output=True,text=True,timeout=60)
        ok(cp.returncode==0,cp.stderr);return json.loads(cp.stdout)
    def run(b,alter=None,w=None):
        result,cached=execute_context(w or worker,b,template,alter);runs.append({'status':result,'cached':cached,'store':str(b.root),'injected':bool(alter or w)});return result
    def check(n,fn):
        start=len(assertions);fn();checks.append({'id':f'CTX{n:02d}','status':'PASS','assertions':len(assertions)-start});write_json(out/'Resultats_32.json',checks);print(f'CTX{n:02d} PASS',flush=True)
    def positive():
        b,r,a=fresh();before=digest(r.database.read_bytes());ok(run(b)=='conforme','conformité native');ok(reopen(b,r)['status']=='conforme','conformité persistante');ok(before==digest(r.database.read_bytes()),'DB source intacte')
    check(1,positive)
    check(2,lambda:bad(lambda r:change(r,lambda c:c.update(author=''))))
    check(3,lambda:[bad(lambda r:sql(r,s)) for s in ['UPDATE practitioners SET is_active=0','UPDATE practitioners SET archived_at=1']])
    check(4,lambda:[bad(lambda r:sql(r,s)) for s in ['DELETE FROM practitioners','INSERT INTO practitioners SELECT * FROM practitioners']])
    def authorities():
        bad(lambda r:change(r,lambda c:c['authorIdentity'].update(authority='unknown')))
        for s in ['UPDATE practitioners SET professional_id=NULL',"UPDATE practitioners SET professional_id='12345678901'"]:bad(lambda r:sql(r,s))
    check(5,authorities)
    def roles():
        r=fixture();a=read(r);ok(a['payload']['professionalContext']['context']['operator']!='SIM-KINE','opérateur distinct sans substitution');bad(lambda r:change(r,lambda c:c.update(rolesConfirmed=False)))
    check(6,roles)
    def report():
        r=fixture();before=read(r);sql(r,'CREATE TABLE care_episode_reports(report_id TEXT,author_practitioner_id TEXT)');sql(r,"INSERT INTO care_episode_reports VALUES ('SIM-DOC1','SIM-OTHER')");ok(before==read(r),'aucun repli sur rapport homonyme');bad(lambda r:change(r,lambda c:c.update(provenance='inferred-from-title')))
    check(7,report)
    check(8,lambda:bad(lambda r:change(r,lambda c:c.update(situations=[]))))
    def choice():
        r=fixture();change(r,lambda c:c['situations'].append(dict(c['situations'][0],id='SIM-S2')));change(r,lambda c:c.update(situation=''));blocked(lambda:read(r));change(r,lambda c:c.update(situation='SIM-S2'));ok(read(r)['payload']['professionalContext']['selectedSituation']['id']=='SIM-S2','choix explicite exact')
    check(9,choice)
    check(10,lambda:bad(lambda r:change(r,lambda c:c['situations'][0].update(author='SIM-AUTRE'))))
    def structures():
        bad(lambda r:change(r,lambda c:c['custodian'].update(name='')))
        r=fixture();change(r,lambda c:c['custodian']['id'].update(value='SIM-DEPOSITAIRE'));i=read(r);ok(i['payload']['professionalContext']['context']['custodian']!=i['payload']['professionalContext']['selectedSituation']['structure'],'dépositaire distinct exercice')
        b,r,a=fresh(r);ok(run(b)=='conforme','rôles structures distincts validés nativement');ok(reopen(b,r)['status']=='conforme','structures persistantes')
    check(11,structures)
    check(12,lambda:[bad(lambda r:change(r,lambda c:c['document'].update({field:value}))) for field,value in [('title',''),('date','20261317120000+0200'),('date','20261017120000')]])
    check(13,lambda:[bad(lambda r:change(r,fn,True)) for fn in [lambda c:c['document']['type'].update(code='unknown'),lambda c:c['catalog']['entries'][0].update(active=False),lambda c:c['catalog'].update(pairs=[])]])
    check(14,lambda:bad(lambda r:change(r,lambda c:c['document'].update(format='unknown'))))
    check(15,lambda:[bad(lambda r:change(r,fn)) for fn in [lambda c:c.update(catalog={}),lambda c:c.update(catalogDigest='bad')]])
    def cache():
        r=fixture();change(r,lambda c:c['catalog'].update(lastError='503 simulé'),True);ok(read(r)['payload']['professionalContext']['context']['catalog']['lastError']=='503 simulé','cache valide distinct échec');change(r,lambda c:c['catalog'].update(fresh=False),True);blocked(lambda:read(r))
    check(16,cache)
    def invalidation(fn,catalog=False):
        b,r,a=fresh();old=b.read()['binding'];change(r,fn,catalog);blocked(b.begin);s=reopen(b,r);ok(not s['approved'] and s['status']=='bloque','invalidation persistante');ok(s['binding']==old,'historique non réécrit')
    check(17,lambda:invalidation(lambda c:c['catalog'].update(version='SIM-2'),True))
    check(18,lambda:[bad(lambda r:change(r,lambda c:c['visibility'].update(v))) for v in [{'minor':True,'mode':'secret','rl':True},{'patient':False,'maskedPS':True},{'opposition':True}]])
    check(19,lambda:[bad(lambda r:change(r,lambda c:c['visibility'].update(v))) for v in [{'previousPatient':True,'patient':False},{'previousRL':True,'rl':False}]])
    def author():
        b,r,a=fresh();sql(r,"UPDATE practitioners SET display_name='AUTRE NOM'");blocked(b.begin);ok(not reopen(b,r)['approved'],'auteur modifié invalide')
        b,r,a=fresh();ok(run(b)=='conforme','avant mutation auteur');change(r,lambda c:c['authorIdentity'].update(authority='unknown'));ok(not reopen(b,r)['approved'],'après contrôle auteur invalide')
    check(20,author)
    check(21,lambda:invalidation(lambda c:c['situations'][0]['structure'].update(name='AUTRE CABINET')))
    check(22,lambda:[invalidation(fn) for fn in [lambda c:c['document'].update(title='Autre titre'),lambda c:c['document'].update(date='20261018120000+0200'),lambda c:c['document']['type'].update(code='invalid'),lambda c:c['document']['class'].update(code='invalid'),lambda c:c['document'].update(confidentiality='R')]])
    def source_changes():
        for mode in ['identity','episode','pdf']:
            b,r,a=fresh()
            if mode=='identity':sql(r,"UPDATE patient_fr_health_identity SET birth_last_name='AUTRE'")
            elif mode=='episode':sql(r,"UPDATE episode_documents SET case_id='SIM-E2'")
            else:(r.root/'final.pdf').write_bytes(pdf+b'\n')
            blocked(b.begin);ok(not reopen(b,r)['approved'],'source invalide '+mode)
    check(23,source_changes)
    def other_piece():
        b,r,a=fresh();old=b.read()['binding'];sql(r,'INSERT INTO episode_documents SELECT ?,case_id,title,file_path,mime_type,source,created_at,updated_at,archived_at FROM episode_documents',('SIM-DOC2',));sql(r,'INSERT INTO synthetic_document_context SELECT ?,body,revision FROM synthetic_document_context',('SIM-DOC2',));new=a.capture_context(dict(pc,document='SIM-DOC2'));ok(old!=new and not b.read()['approved'],'autre pièce sans héritage');blocked(b.begin);ok(not reopen(b,r)['approved'],'non confirmation persistante')
    check(24,other_piece)
    def races():
        r=fixture();r.hook=lambda:change(r,lambda c:c['document'].update(title='mutation'));blocked(lambda:fresh(r))
        b,r,a=fresh(approve=False);original=a.export
        def delayed(*args,**kwargs):
            dest=original(*args,**kwargs);change(r,lambda c:c['document'].update(title='mutation confirmation'));return dest
        a.export=delayed;blocked(lambda:a.confirm(b.read()['binding'],pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True));ok(not reopen(b,r)['approved'],'confirmation tardive bloquée')
    check(25,races)
    def late():
        b,r,a=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());cached=worker.execute(token,manifest,job,data,b.xml(template,manifest,data));runs.append({'store':str(b.root),'cached':cached,'delayed':True});write_json(job/'professional-context.json',b.read()['identity']['payload']['professionalContext']);proof_manifest(job,manifest['version'],worker.configuration,json.loads((job/'proof.json').read_text())['returncode'])
        change(r,lambda c:c['document'].update(title='temp'));change(r,lambda c:c['document'].update(title=cc['title']));ok(b.finish(token)!='conforme','aller-retour révision rejette résultat natif achevé');ok(not reopen(b,r)['approved'],'ancien jeton bloqué')
    check(26,late)
    def altered(path,value):
        def fn(xml):
            x=parse_xml(xml);parent,attr=path.rsplit('/',1);el=x.find(parent,NS)
            if attr=='text()':el.text=value
            else:el.set(attr[1:],value)
            return E.tostring(x)
        return fn
    def wrong_professional():
        b,r,a=fresh();ok(run(b,altered('c:author/c:assignedAuthor/c:id/@root','2.25.999'))=='refuse','autorité différente refusée');ok(reopen(b,r)['status']=='refuse','refus persiste')
        s=b.read();xml=(b.base.root/'jobs'/s['token']['id']/'document.xml').read_bytes();good=b.xml(template,snapshot(b.root/s['capture'])[0],pdf)
        ctx=s['identity']['payload']['professionalContext']
        for path,value in [('c:author/c:assignedAuthor/c:assignedPerson/c:name/c:family/text()','AUTRE'),('c:documentationOf/c:serviceEvent/c:performer/c:assignedEntity/c:representedOrganization/c:standardIndustryClassCode/@code','OTHER')]:blocked(lambda:verify_context_xml(altered(path,value)(good),ctx,pc['episode']))
    check(27,wrong_professional)
    def wrong_doc():
        b,r,a=fresh();ok(run(b,altered('c:code/@codeSystem','2.25.999'))=='refuse','système documentaire refusé');ok(reopen(b,r)['status']=='refuse','refus document persiste')
        b,r,a=fresh();token,manifest,job=b.begin();_,data=b.base.capture(b.base.read());worker.execute(token,manifest,job,data,b.xml(template,manifest,data));write_json(job/'professional-context.json',b.read()['identity']['payload']['professionalContext']);meta=json.loads((job/'metadata.json').read_text());meta['class']='wrong';write_json(job/'metadata.json',meta);proof_manifest(job,manifest['version'],worker.configuration,0);ok(b.finish(token)=='refuse','classe metadata refusée')
        good=b.xml(template,manifest,data)
        for path,value in [('c:title/text()','AUTRE'),('c:effectiveTime/@value','20261018120000+0200'),('c:id/@root','2.25.999'),('c:component/c:nonXMLBody/c:text/text()',base64.b64encode(data+b'\n').decode())]:
            ok(bool(cda_checks(altered(path,value)(good),data,manifest['cdaContext'],dict(manifest['cdaContext'],formatCode=FMT))),'CDA documentaire incohérent '+path)
    check(28,wrong_doc)
    def tools():
        b,r,a=fresh();w=copy.copy(worker);w.validator=str(out/'missing-verapdf');w.cache={};w.work=out/'native-missing';w.work.mkdir();ok(run(b,w=w)=='non_verifie','outil absent non vérifié');ok(reopen(b,r)['status']=='non_verifie','non vérifié persiste')
        b,r,a=fresh();token,_,_=b.begin();ok(b.finish(token)=='non_verifie','preuve absente bloque')
    check(29,tools)
    def persistence():
        b,r,a=fresh();ok(reopen(b,r)['approved'],'confirmation persiste');ok(run(b)=='conforme','natif conforme');before=len(list((b.base.root/'jobs').iterdir()));ok(reopen(b,r)['status']=='conforme','succès après processus neuf');ok(before==len(list((b.base.root/'jobs').iterdir())),'pas de relance')
        change(r,lambda c:c['visibility'].update(minor=True,mode='secret',rl=False));ok(not reopen(b,r)['approved'],'secret non restauré, mapping non vérifié')
    check(30,persistence)
    def crashes():
        b,r,a=fresh();b.begin();ok(reopen(b,r)['status']=='bloque','interruption sans rejeu')
        b,r,a=fresh(approve=False);old=b.save;b.save=lambda s:(_ for _ in ()).throw(OSError('écriture injectée'));blocked(lambda:a.confirm(b.read()['binding'],pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True));b.save=old;ok(not reopen(b,r)['approved'],'commit échoué non validé')
        b,r,a=fresh();(b.root/'identity.json').write_text('{}');blocked(b.read)
        b,r,a=fresh();fd=(b.root/'lock').open('a');fcntl.flock(fd,fcntl.LOCK_EX)
        code="import fcntl,sys;f=open(sys.argv[1],'a');fcntl.flock(f,fcntl.LOCK_EX|fcntl.LOCK_NB)"
        cp=subprocess.run([sys.executable,'-c',code,str(b.root/'lock')],capture_output=True);ok(cp.returncode!=0,'second propriétaire bloqué');fd.close()
        blocked(lambda:a.confirm('ancienne-version',pages=[1],clinical=True,patient=pc['patient'],context_confirmed=True))
        before=b.read();(b.root/'identity.new').write_text('{interrupted');ok(reopen(b,r)['binding']==before['binding'],'écriture temporaire jamais activée')
    check(31,crashes)
    def isolation():
        r=fixture();before={str(p):digest(p.read_bytes()) for p in [r.database,r.root/'final.pdf']};read(r);ok(before=={p:digest(Path(p).read_bytes()) for p in before},'source inchangée');write_json(out/'Empreintes_source.json',before)
        with sqlite3.connect(r.database.as_uri()+'?mode=ro',uri=True) as db:blocked(lambda:db.execute('DELETE FROM practitioners'))
        s=socket.socket()
        try:blocked(lambda:s.bind(('127.0.0.1',0)))
        finally:s.close()
        for root in (out/'stores').iterdir():
            j=json.loads((root/'identity.json').read_text())
            if j:ok(j['state']['held'] and j['state']['calls']==0,'retenue zéro transport')
    check(32,isolation)
    write_json(out/'Synthese.json',{'groups':len(checks),'assertions':len(assertions),'nativeRuns':runs,'sourceDatabases':len(sources),'networkDenied':True,'transportCalls':0,'scope':'synthetic-only','unsupportedSecret':'blocked, no inferred CDA mapping'})
if __name__=='__main__':
    if sys.argv[1]=='--reopen':
        _,_,root,source,db,configuration,resources=sys.argv
        print(json.dumps(ContextWorkflow(Path(root),ContextReader(Path(source),Path(db)),configuration,Path(resources)).recover()))
    else:main()
