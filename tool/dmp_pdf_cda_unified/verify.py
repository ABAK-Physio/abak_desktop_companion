from coordinator import *
import subprocess, threading

DART='/Users/jeanclaudebrucher/development/flutter/bin/cache/dart-sdk/bin/dart'
REPO=Path(__file__).resolve().parents[2]
EXPORT=Path(__file__).parent/'export_fixture.dart'

def main():
    spec=json.loads(Path(sys.argv[1]).read_text());out=Path(spec['out'])
    if out.exists():raise SystemExit('Sortie neuve requise')
    out.mkdir(parents=True)
    for n in ['stores','exports','pdfbench']: (out/n).mkdir()
    refs=out/'references';shutil.copytree(spec['references'],refs)
    profile=out/'java-profile';profile.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(profile)
    assets=Path(spec['assets']);template=(REPO/'tool/dmp_pdf_cda_isolated/fixtures/temoin-cda.xml').read_bytes()
    root=parse_xml(template)
    ctx={'patient':'SIM-A','author':'SIM-KINE','structure':'SIM-CABINET','title':'Rapport clinique SYNTHETIQUE','date':'20261017120000+0200','confidentiality':'N','type':'11506-3','class':'11','id':root.find('c:id',NS).get('root'),'setId':root.find('c:setId',NS).get('root'),'version':'1'}
    worker=NativeWorker(refs,spec['validator'],spec['java'],out/'native',template)
    results=[];snapshots={};native_runs=[]
    def dart(args):
        cp=subprocess.run([DART,'--packages='+str(REPO/'.dart_tool/package_config.json'),str(EXPORT),*args],cwd=REPO,capture_output=True,text=True,timeout=90)
        return cp
    def export(name='positif',clinical=True,alter=False):
        k=(name,clinical,alter)
        if k in snapshots:return snapshots[k]
        dest=out/'exports'/('snapshot-isole-'+uuid.uuid4().hex)
        request={'parent':str(out/'pdfbench'),'poppler':spec['poppler'],'pdf':str(assets/(name+'.pdf')),'revision':'source-1','clinical':clinical,'context':ctx,'destination':str(dest),'alterPreview':alter}
        f=out/('request-'+uuid.uuid4().hex+'.json');write_json(f,request)
        cp=dart([str(f)])
        (out/(f.stem+'.log')).write_text(cp.stdout+cp.stderr)
        if alter:
            assert cp.returncode!=0 and 'Aperçu altéré' in cp.stderr;return
        assert cp.returncode==0,cp.stderr
        snapshots[k]=dest;return dest
    def modified(source,mutate,pdf=None):
        dest=out/'exports'/('snapshot-isole-'+uuid.uuid4().hex);shutil.copytree(source,dest)
        m=json.loads((dest/'snapshot.json').read_text());mutate(m)
        if pdf is not None:(dest/'document.pdf').write_bytes(pdf);m['pdfSha']=digest(pdf)
        m['version']=key({k:m[k] for k in VERSION_KEYS});m['clinical']=False;m['review']={}
        write_json(dest/'snapshot.json',m);return dest
    def fresh(source=None):
        b=Coordinator.create(out/'stores',worker.configuration,refs);b.load(source or export());return b
    def reopen(b):
        cp=subprocess.run([sys.executable,str(Path(__file__).resolve()),'--reopen',str(b.root),worker.configuration,str(refs)],capture_output=True,text=True,timeout=40)
        assert cp.returncode==0,cp.stderr
        state=json.loads(cp.stdout);assert state['held'] and state['calls']==0
        return state
    def run(b,xml=None):
        token,m,job=b.begin();_,data=b.capture(b.read());cached=worker.execute(token,m,job,data,xml)
        native_runs.append({'job':str(job),'cached':cached})
        return b.finish(token),job,token
    def blocked(fn):
        try:fn()
        except (ValueError,OSError,KeyError,TypeError):return
        raise AssertionError('Blocage attendu absent')
    def check(id,fn):
        fn();results.append({'id':id,'result':'PASS'});write_json(out/'Resultats_32.json',results);print(id,'PASS',flush=True)
    def positive():
        b=fresh();assert run(b)[0]=='conforme';assert reopen(b)['status']=='conforme'
    check('U01',positive)
    def unreviewed():
        b=fresh(export(clinical=False));assert run(b)[0]=='revue_requise';assert reopen(b)['status']=='revue_requise'
    check('U02',unreviewed)
    for id,name in [('U03','blanc'),('U04','entete')]:
        def empty(name=name):
            b=fresh(export(name,False));status,job,_=run(b)
            assert status=='revue_requise'
            assert interpret_verapdf((job/'document.pdf').read_bytes(),(job/'verapdf.xml').read_bytes(),json.loads((job/'proof.json').read_text())['returncode'],expected_profile='1b')['status']=='conforme'
            assert reopen(b)['status']=='revue_requise'
        check(id,empty)
    def change_pdf(kind):
        source=export();m,pdf=snapshot(source)
        data=(assets/'contenu_modifie.pdf').read_bytes() if kind!='metadata' else pdf.replace(b'/Producer',b'/Creator ',1)
        if kind in ['clinical','metadata']:
            from pypdf import PdfReader,PdfWriter
            import io
            w=PdfWriter();w.clone_document_from_reader(PdfReader(io.BytesIO(pdf)))
            from pypdf.generic import DecodedStreamObject,NameObject,ArrayObject
            if kind=='clinical':
                stream=DecodedStreamObject();stream.set_data(b'BT /F1 10 Tf 60 30 Td (Donnee clinique synthetique modifiee) Tj ET')
                old=w.pages[0].raw_get('/Contents');w.pages[0][NameObject('/Contents')]=ArrayObject([old,w._add_object(stream)])
            else:w.add_metadata({'/Subject':'Metadonnees synthetiques modifiees'})
            buf=io.BytesIO();w.write(buf);data=buf.getvalue()
        assert data!=pdf
        new=modified(source,lambda m:None,data);b=fresh();run(b);b.load(new)
        assert not b.read()['clinical'] and b.read()['status']=='non_verifie';assert reopen(b)['status']=='non_verifie'
    for id,kind in [('U05','clinical'),('U06','graphics'),('U07','metadata')]:check(id,lambda kind=kind:change_pdf(kind))
    def identical():
        b=fresh();run(b);b.load(export());assert b.read()['status']=='conforme';assert reopen(b)['status']=='conforme'
    check('U08',identical)
    def context_changes(fields):
        for field in fields:
            def mutate(m):
                m['cdaContext'][field]+='-MOD'
                if field in ['patient','author']:m['pdfContext'][field]=m['cdaContext'][field]
            b=fresh();b.load(modified(export(),mutate));assert not b.read()['clinical'];assert reopen(b)['status']=='non_verifie'
    check('U09',lambda:context_changes(['patient']))
    check('U10',lambda:context_changes(['author','structure']))
    check('U11',lambda:context_changes(['title','date','type','class','confidentiality']))
    def revision():
        b=fresh();b.load(modified(export(),lambda m:m.update(sourceRevision='source-2')));assert not b.read()['clinical'];assert reopen(b)['status']=='non_verifie'
    check('U12',revision)
    def copy_bad():
        for delete in [False,True]:
            b=fresh();run(b);p=b.root/'captures'/b.read()['current']['capture']/'document.pdf'
            if delete:p.unlink()
            else:p.write_bytes(b'changed')
            assert reopen(b)['status']=='non_verifie';blocked(b.begin)
    check('U13',copy_bad)
    check('U14',lambda:export(alter=True))
    def bad_report(which):
        b=fresh();_,job,token=run(b)
        if which=='pdf':(job/'document.pdf').write_bytes((assets/'contenu_modifie.pdf').read_bytes())
        else:(job/'document.xml').write_bytes((job/'document.xml').read_bytes()+b'\n<!-- modifie -->')
        # Recompute integrity to test semantic correlation, not only hash checks.
        code=json.loads((job/'proof.json').read_text())['returncode'];proof_manifest(job,token['version'],worker.configuration,code)
        assert b.finish(token)=='non_verifie';assert reopen(b)['status']=='non_verifie'
    check('U15',lambda:bad_report('pdf'));check('U16',lambda:bad_report('cda'))
    def forged():
        b=fresh(export('sans_xmp'));status,job,token=run(b);assert status=='refuse'
        write_json(job/'resultat.json',{'status':'conforme'})
        assert b.finish(token)=='refuse'
        (job/'verapdf.xml').write_bytes(b'<report>');assert b.finish(token)=='non_verifie'
    check('U17',forged)
    def payload():
        b=fresh();xml=make_cda(template,(assets/'contenu_modifie.pdf').read_bytes(),ctx);assert run(b,xml)[0]=='refuse';assert reopen(b)['status']=='refuse'
    check('U18',payload)
    def malformed():
        for mode in ['base64','multiple','mime']:
            b=fresh();r=parse_xml(make_cda(template,(assets/'positif.pdf').read_bytes(),ctx));t=r.find('c:component/c:nonXMLBody/c:text',NS)
            if mode=='base64':t.text='!invalid!'
            elif mode=='mime':t.set('mediaType','text/plain')
            else:t.getparent().append(copy.deepcopy(t))
            # Correlation validation is exercised without paying for native
            # reports known to be inapplicable to the mutated XML.
            _,job,token=run(b);xml=E.tostring(r);(job/'document.xml').write_bytes(xml)
            errors=cda_checks(xml,(assets/'positif.pdf').read_bytes(),ctx,dict(ctx,formatCode=FMT));assert errors
            assert b.finish(token)=='non_verifie'
    check('U19',malformed)
    def cda_context():
        for field in ['patient','author','structure','id','version']:
            c=dict(ctx);c[field]+='-OTHER';xml=make_cda(template,(assets/'positif.pdf').read_bytes(),c)
            assert cda_checks(xml,(assets/'positif.pdf').read_bytes(),ctx,dict(ctx,formatCode=FMT))
            b=fresh();_,job,token=run(b);(job/'document.xml').write_bytes(xml);assert b.finish(token)=='non_verifie'
    check('U20',cda_context)
    def reuse_id():
        b=fresh();run(b);b.load(export('contenu_modifie'));assert run(b)[0]=='refuse';assert 'réutilisé' in b.read()['message']
    check('U21',reuse_id)
    def negative_pdf():
        b=fresh(export('sans_xmp'));assert run(b)[0]=='refuse';assert reopen(b)['status']=='refuse'
    check('U22',negative_pdf)
    def errors_pdf():
        for name in ['chiffre','tronque']:
            dest=out/('unreadable-'+name);dest.mkdir();r=validate_pdfa(assets/(name+'.pdf'),spec['validator'],dest);assert r['status']=='non_verifie'
        for kind in ['absent','timeout']:
            b=fresh();token,m,job=b.begin()
            if kind=='absent':r=validate_pdfa(assets/'positif.pdf',None,job);assert r['status']=='non_verifie'
            # Timeout is an injected worker interruption with no complete proof.
            assert b.finish(token)=='non_verifie';assert reopen(b)['status']=='non_verifie'
    check('U23',errors_pdf)
    def errors_cda():
        b=fresh();r=parse_xml(make_cda(template,(assets/'positif.pdf').read_bytes(),ctx));r.remove(r.find('c:recordTarget',NS));assert run(b,E.tostring(r))[0]=='refuse'
        for kind in ['missing','incomplete']:
            b=fresh();_,job,token=run(b);f=job/(Path(PROFILES[0]).name+'.svrl.xml')
            if kind=='missing':f.unlink()
            else:f.write_bytes(b'<svrl>')
            assert b.finish(token)=='non_verifie';assert reopen(b)['status']=='non_verifie'
    check('U24',errors_cda)
    def late():
        b=fresh();token,m,job=b.begin();pdf=b.capture(b.read())[1];b.load(export('contenu_modifie',False));worker.execute(token,m,job,pdf)
        assert b.finish(token)=='obsolete';assert b.read()['status']=='non_verifie';assert not b.read()['clinical']
    check('U25',late)
    def boundary():
        b=fresh();token,m,job=b.begin();pdf=b.capture(b.read())[1];worker.execute(token,m,job,pdf)
        (b.root/'captures'/b.read()['current']['capture']/'document.pdf').write_bytes(b'changed');assert b.finish(token)=='non_verifie'
    check('U26',boundary)
    def concurrent():
        b=fresh();outcomes=[]
        def start():
            other=Coordinator(b.root,worker.configuration,refs)
            try:other.begin();outcomes.append('started')
            except Blocked:outcomes.append('blocked')
        threads=[threading.Thread(target=start) for _ in range(2)]
        for t in threads:t.start()
        for t in threads:t.join()
        assert sorted(outcomes)==['blocked','started'];assert reopen(b)['status']=='non_verifie'
    check('U27',concurrent)
    def interrupted():
        b=fresh();b.begin();assert reopen(b)['status']=='non_verifie';assert reopen(b)['status']=='non_verifie'
    check('U28',interrupted)
    def persistence():
        for source,status in [(export(),'conforme'),(export('sans_xmp'),'refuse')]:
            b=fresh(source);assert run(b)[0]==status;assert reopen(b)['status']==status
        b=fresh();token,_,_=b.begin();assert b.finish(token)=='non_verifie';assert reopen(b)['status']=='non_verifie'
    check('U29',persistence)
    def hostile():
        b=fresh();(b.root/'journal.json').write_text('{}');blocked(lambda:Coordinator(b.root,worker.configuration,refs))
        b=fresh();target=out/'outside.txt';target.write_text('untouched');(b.root/'link').symlink_to(target);blocked(b.read);assert target.read_text()=='untouched'
        dest=modified(export(),lambda m:None);m=json.loads((dest/'snapshot.json').read_text());m['previews']={'../outside.txt':digest(b'untouched')};write_json(dest/'snapshot.json',m);blocked(lambda:fresh(dest))
    check('U30',hostile)
    def configuration():
        b=fresh();run(b);other=Coordinator(b.root,'configuration-modifiee-injectee',refs);assert other.recover()['status']=='non_verifie';assert other.read()['clinical']
        b=fresh();run(b);f=refs/'infrastructure/cda/CDA_extended.xsd';original=f.read_bytes()
        try:
            f.write_bytes(original+b'\n<!-- reference modifiee -->');assert b.recover()['status']=='non_verifie'
        finally:f.write_bytes(original)
    check('U31',configuration)
    def contract():
        source=export();m,_=snapshot(source);obj={k:m[k] for k in VERSION_KEYS};obj['cdaContext']['title']='Évaluation — kiné';obj=dict(reversed(list(obj.items())))
        f=out/'canonical.json';write_json(f,obj);cp=dart(['--canonical',str(f)]);assert cp.returncode==0 and cp.stdout==key(obj),cp.stderr
        for mode in ['unknown','type']:
            dest=modified(source,lambda m:None);m=json.loads((dest/'snapshot.json').read_text())
            if mode=='unknown':m['unknown']=True
            else:m['clinical']='true'
            write_json(dest/'snapshot.json',m);blocked(lambda:fresh(dest))
    check('U32',contract)
    assert len(results)==32
    write_json(out/'Synthese.json',{'passed':32,'calls':0,'held':True,'nativeJobs':native_runs,'exports':len(snapshots),'stores':len(list((out/'stores').iterdir())),'reopenSeparateProcess':True,'injectedGroups':['U17','U19','U20','U23 (outil absent/interruption)','U24 (rapport manquant/tronqué)','U25','U26','U28','U30','U31'],'limits':'No UI or real transport; error injection identified in tests. Local hashes are not signatures.'})
    print('32 groupes réussis',flush=True)

if __name__=='__main__':
    if sys.argv[1]=='--reopen':print(json.dumps(Coordinator(sys.argv[2],sys.argv[3],sys.argv[4]).recover()))
    else:main()
