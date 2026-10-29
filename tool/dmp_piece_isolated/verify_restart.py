"""Restart only the explicitly configured synthetic test service, never user services."""
from pathlib import Path
import sys,os,json,subprocess,signal,time,uuid
from piece import key
spec_path=Path(sys.argv[1]);spec=json.loads(spec_path.read_text());root=Path(spec['root']);out=spec_path.parent
if root.name!='test-final' or (root/'demo.scope').read_text()!='ABAK-PIECE-DEMO-1':raise RuntimeError('Stockage test-final requis')
def view():
    e=json.loads((root/'view.json').read_text());assert key(e['state'])==e['digest'];return e['state']
before=view();assert before['approved'] and before['calls']==0
jobs_before=sorted(str(p) for p in (root/'stores').glob('*/unified-isole-*/jobs/*/proof.json'))
# Caller stops the known test process first; never enumerate or signal user processes.
import fcntl
with (root/'service.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    fcntl.flock(lock,fcntl.LOCK_UN)
# Orphaned in-flight request must be marked interrupted, never replayed.
id=uuid.uuid4().hex
(root/'requests'/(id+'.working')).write_text(json.dumps({'id':id,'action':'run','binding':before['binding'],'mode':before['mode'],'review':{}}))
started=time.time();log=(out/'Service_redemarrage.txt').open('w')
p=subprocess.Popen([sys.executable,'tool/dmp_piece_isolated/demo_service.py',str(spec_path)],cwd=spec['repo'],stdout=log,stderr=subprocess.STDOUT)
try:
    for _ in range(240):
        if p.poll() is not None:raise RuntimeError('Échec du redémarrage')
        if (root/'ready.json').exists() and json.loads((root/'ready.json').read_text())['at']>started and (root/'responses'/(id+'.json')).exists():break
        time.sleep(.25)
    else:raise RuntimeError('Délai démarrage dépassé')
    after=view();jobs_after=sorted(str(q) for q in (root/'stores').glob('*/unified-isole-*/jobs/*/proof.json'))
    for k in ['document','patient','episode','binding','approved','status','nativeJobs','calls','held']:assert before[k]==after[k],k
    assert jobs_before==jobs_after
    response=json.loads((root/'responses'/(id+'.json')).read_text())['result'];assert 'interrompue' in response['error']
    duplicate=subprocess.run([sys.executable,'tool/dmp_piece_isolated/demo_service.py',str(spec_path)],cwd=spec['repo'],capture_output=True,text=True,timeout=15)
    assert duplicate.returncode!=0 and 'BlockingIOError' in duplicate.stderr
    result={'scope':'synthetic-only','selectionPreserved':True,'confirmationPreserved':True,'bindingPreserved':True,'nativeJobsBefore':before['nativeJobs'],'nativeJobsAfter':after['nativeJobs'],'proofFilesUnchanged':jobs_before==jobs_after,'interruptedRequestNotReplayed':True,'secondServiceBlocked':True,'transportCalls':after['calls']}
    (out/'Redemarrage_service.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
finally:
    p.send_signal(signal.SIGINT);p.wait(timeout=20);log.close()
