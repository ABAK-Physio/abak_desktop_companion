from pathlib import Path
import os,json,subprocess,plistlib,uuid,hashlib,sys,argparse
from contract import assess
repo=Path(__file__).resolve().parents[2];source=Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description='Synthetic-only signed XPC App Sandbox compatibility probe; never launches Companion')
parser.add_argument('--identity',required=True)
parser.add_argument('--team',required=True)
args=parser.parse_args()
import re
if not re.fullmatch('[A-Z0-9]{10}',args.team):parser.error('Invalid signing team')
root=Path('/private/tmp')/('abak-xpc-migration-'+uuid.uuid4().hex);root.mkdir();(root/'caller').mkdir();(root/'SYNTHETIC-ONLY').write_text('ABAK-XPC-SANDBOX-PROBE-1\n');(root/'caller/synthetic-input.txt').write_text('SYNTHETIC INPUT ONLY\n')
team=args.team;identity=args.identity
hostID='fr.abakphysio.sandboxprobe.host.'+uuid.uuid4().hex;serviceID=hostID+'.service'
app=root/'Probe.app';svc=app/'Contents/XPCServices/Probe.xpc'
for p in [app/'Contents/MacOS',svc/'Contents/MacOS',svc/'Contents/Resources']:p.mkdir(parents=True,exist_ok=True)
(app/'Contents/Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier':hostID,'CFBundleName':'ABAK Synthetic Sandbox Probe','CFBundleExecutable':'Host','CFBundlePackageType':'APPL','CFBundleVersion':'1','LSMinimumSystemVersion':'13.0','ProbeService':serviceID,'ProbeTeam':team}))
(svc/'Contents/Info.plist').write_bytes(plistlib.dumps({'CFBundleIdentifier':serviceID,'CFBundleName':'Probe','CFBundleExecutable':'Service','CFBundlePackageType':'XPC!','CFBundleVersion':'1','LSMinimumSystemVersion':'13.0','XPCService':{'ServiceType':'Application','RunLoopType':'dispatch_main','JoinExistingSession':True},'ABAKHostRequirement':f'anchor apple generic and identifier "{hostID}" and certificate leaf[subject.OU] = "{team}"'}))
childEnt=root/'child.entitlements';childEnt.write_bytes(plistlib.dumps({'com.apple.security.app-sandbox':True,'com.apple.security.inherit':True}))
def run(args):subprocess.run(args,check=True)
base=['xcrun','swiftc','-O','-target','arm64-apple-macos13.0']
run(base+[str(source/'Probe.swift'),str(source/'Child.swift'),'-o',str(svc/'Contents/Resources/SandboxChild')])
run(base+[str(source/'Protocol.swift'),str(source/'Probe.swift'),str(source/'Service.swift'),'-o',str(svc/'Contents/MacOS/Service')])
run(base+[str(source/'Protocol.swift'),str(source/'Host.swift'),'-o',str(app/'Contents/MacOS/Host')])
for obj,ent in [(svc/'Contents/Resources/SandboxChild',childEnt),(svc,repo/'macos/DocumentControls/AppSandbox.candidate.entitlements'),(app,None)]:
 args=['codesign','--force','--sign',identity,'--options','runtime','--timestamp=none']
 if ent:args+=['--entitlements',str(ent)]
 run(args+[str(obj)])
run(['codesign','--verify','--deep','--strict',str(app)])
report=root/'result.json'
p=subprocess.run([str(app/'Contents/MacOS/Host'),str(root),str(report)],capture_output=True,text=True,timeout=45)
(root/'host-execution.json').write_text(json.dumps({'returncode':p.returncode,'stderr':p.stderr,'stdout':p.stdout}))
print('Probe root:',root,flush=True)
if p.returncode != 0 or not report.exists():
    raise RuntimeError('XPC recipe failed: '+str(p.returncode)+' '+p.stderr)
result=json.loads(report.read_text())
if 'error' in result or result.get('childExit') != 0: raise RuntimeError(result)
# Compile a separate non-App-Sandbox probe under the exact current production
# Seatbelt profile, to compare boundaries rather than assuming equivalence.
baseline=root/'BaselineChild'
run(base+[str(source/'Probe.swift'),str(source/'Child.swift'),'-o',str(baseline)])
run(['codesign','--force','--sign',identity,'--options','runtime','--timestamp=none',str(baseline)])
private=root/'baseline-private';private.mkdir();work=private/'work';work.mkdir()
production=(repo/'macos/DocumentControls/main.swift').read_text()
line=next(line for line in production.splitlines() if line.startswith('let profile = '))
template=line[len('let profile = '):].replace('\\(quote(work.path))','__PRIVATE_WORK__')
profile=json.loads(template).replace('__PRIVATE_WORK__',json.dumps(str(work)))
assert '__PRIVATE_WORK__' not in profile and str(work) in profile
control=subprocess.run(['/usr/bin/sandbox-exec','-p',profile,str(baseline),str(work),str(private),str(root/'caller')],capture_output=True,text=True,check=True,timeout=20)
control=json.loads(control.stdout)
for field in ['outsideWorkWrite','callerWrite','network']:
    assert control[field]['allowed'] is False and control[field]['errno'] in (1,13), (field,control)
assert control['privateWorkWrite']['allowed'] is True and control['callerRead']['allowed'] is True
(root/'production-policy-control.json').write_text(json.dumps(control,indent=2))
(root/'assessment.json').write_text(json.dumps(assess(result),indent=2))
# Save exact candidate permissions and source provenance without any patient data.
for label,obj in [('service',svc),('child',svc/'Contents/Resources/SandboxChild')]:
    signed=subprocess.run(['codesign','--display','--entitlements','-','--xml',str(obj)],check=True,capture_output=True)
    permissions=plistlib.loads(signed.stdout)
    expected={'com.apple.security.app-sandbox':True}
    if label=='child':expected['com.apple.security.inherit']=True
    assert permissions==expected, permissions
    (root/(label+'-signed-entitlements.json')).write_text(json.dumps(permissions,indent=2))
(root/'sources.json').write_text(json.dumps({str(f.relative_to(repo)):hashlib.sha256(f.read_bytes()).hexdigest() for f in list(source.glob('*.swift'))+[repo/'macos/DocumentControls/main.swift',repo/'macos/DocumentControls/AppSandbox.candidate.entitlements']},indent=2))
print(json.dumps({'root':str(root),'appSandbox':result,'currentPolicy':control,'assessment':assess(result)},indent=2))
