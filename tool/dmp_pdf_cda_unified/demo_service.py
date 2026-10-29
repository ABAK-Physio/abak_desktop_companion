"""File-only demonstration bridge. Must run through demo_service.command sandbox."""
from coordinator import *
import time, argparse, signal
BRIDGE='ABAK-UNIFIED-DEMO-1'
def initialize(root):
    root=safe_tree(root)
    if root.exists() and any(root.iterdir()) and not (root/'demo.scope').exists():raise Blocked('Dossier neuf requis')
    root.mkdir(parents=True,exist_ok=True)
    marker=root/'demo.scope'
    if marker.exists() and marker.read_text()!=BRIDGE:raise Blocked('Marqueur incorrect')
    marker.write_text(BRIDGE)
    for name in ['requests','responses','snapshots','stores']:(root/name).mkdir(exist_ok=True)

def serve(spec):
    root=Path(spec['root']);initialize(root)
    lock=(root/'service.lock').open('a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    # Rebuild private working resources per start; never modify reference inputs.
    work=root/('worker-'+uuid.uuid4().hex);work.mkdir();refs=work/'references';shutil.copytree(spec['references'],refs)
    java_home=work/'java-profile';java_home.mkdir();os.environ['JAVA_TOOL_OPTIONS']='-Duser.home='+str(java_home)
    template=Path(spec['template']).read_bytes()
    worker=NativeWorker(refs,spec['validator'],spec['java'],work/'native',template)
    # Interrupted requests remain indeterminate; never retry them implicitly.
    for p in (root/'requests').glob('*.working'):
        req=json.loads(p.read_text());respond(root,req,{'status':'non_verifie','message':'Exécution interrompue ; nouvelle demande explicite requise.'});p.rename(p.with_suffix('.done'))
    print('Service prêt. Dossier à choisir dans ABAK : '+str(root),flush=True)
    while True:
        safe_tree(root)
        write_json(root/'ready.json',{'scope':BRIDGE,'at':time.time(),'configuration':worker.configuration})
        for p in sorted((root/'requests').glob('*.json')):
            working=p.with_suffix('.working');p.rename(working)
            req={}
            try:
                req=json.loads(working.read_text())
                if set(req)!={'id','snapshot','version','mode'} or not re.fullmatch(r'[a-f0-9]{32}',req['id']) or p.stem!=req['id'] or not re.fullmatch(r'snapshot-isole-[a-f0-9]{32}',req['snapshot']) or req['mode'] not in ['native','missing','different'] :raise Blocked('Requête invalide')
                capture=root/'snapshots'/req['snapshot'];m,pdf=snapshot(capture)
                if m['version']!=req['version']:raise Blocked('Version non corrélée')
                b=Coordinator.create(root/'stores',worker.configuration,refs);b.load(capture)
                token,m,job=b.begin()
                if req['mode']=='missing':
                    state={'status':b.finish(token),'message':'Service indisponible simulé : conformité non vérifiée.'}
                else:
                    xml=None
                    if req['mode']=='different':xml=make_cda(template,pdf+b'\n% DIFFERENT SYNTHETIQUE',m['cdaContext'])
                    worker.execute(token,m,job,pdf,xml);b.finish(token);state=b.recover()
                state['store']=b.root.name
                state['pdfStatus']='non_verifie';state['cdaStatus']='non_verifie';state['contentMatch']=False
                if (job/'proof.json').exists():
                    proof=json.loads((job/'proof.json').read_text())
                    state['pdfStatus']=interpret_verapdf(pdf,(job/'verapdf.xml').read_bytes(),proof['returncode'],expected_profile='1b')['status']
                    errors=cda_checks((job/'document.xml').read_bytes(),pdf,m['cdaContext'],dict(m['cdaContext'],formatCode=FMT))
                    state['contentMatch']=not errors
                    cda_ok=json.loads((job/'xsd.json').read_text())['valid'] and not errors
                    for n in PROFILES:
                        report=parse_xml((job/(Path(n).name+'.svrl.xml')).read_bytes())
                        cda_ok=cda_ok and not report.findall('.//{http://purl.oclc.org/dsdl/svrl}failed-assert')
                    state['cdaStatus']='conforme' if cda_ok else 'refuse'
                respond(root,req,state)
            except Exception as e:
                if re.fullmatch(r'[a-f0-9]{32}',str(req.get('id',''))):respond(root,req,{'status':'non_verifie','message':'Contrôle interrompu ou preuves invalides : '+str(e)[:250]})
            working.rename(working.with_suffix('.done'))
        if spec.get('once'):return
        time.sleep(1)

def respond(root,req,state):
    result={'id':req['id'],'version':req['version'],'status':state['status'],'message':state.get('message',''), 'held':True,'calls':0,'mode':req['mode'],'pdfStatus':state.get('pdfStatus','non_verifie'),'cdaStatus':state.get('cdaStatus','non_verifie'),'contentMatch':state.get('contentMatch',False)}
    write_json(root/'responses'/(req['id']+'.json'),{'result':result,'digest':key(result)})
if __name__=='__main__':serve(json.loads(Path(sys.argv[1]).read_text()))
