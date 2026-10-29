"""Build a new native restoration recipe using the prior verified durable resources."""
import argparse,json,shutil,subprocess
from pathlib import Path
import native_recipe as n
import bundle_recovery as b
import recovery as r
ap=argparse.ArgumentParser();ap.add_argument('--project',type=Path,required=True);ap.add_argument('--build',required=True);ap.add_argument('--run',required=True)
a=ap.parse_args()
out=a.project/'output/correction-lancement-natif'
root=out/('abak-maintenance-controls-'+a.run)
root.mkdir();(root/'SYNTHETIC-ONLY').write_text(r.MARKER)
candidate=out/('candidate-'+a.build)/'Companion-candidate.app'
source=a.project/'output/recette-native-bundle/abak-maintenance-bundle-1/snapshot/payload'
old=json.loads((a.project/'output/recette-native-bundle/abak-maintenance-bundle-1/snapshot/manifest.json').read_text())
if b.inventory(source)!=old['entries']:raise ValueError('Ancienne sauvegarde altérée')
n.create(candidate,root/'seed',bundle_resources=True)
subprocess.run(['/usr/bin/ditto',str(candidate),str(root/'seed/Companion-candidate.app')],check=True)
for name in ['resources','active','fixtures']:
    subprocess.run(['/usr/bin/ditto','--rsrc','--extattr','--acl',str(source/name),str(root/'seed'/name)],check=True)
shutil.copy2(source/'resources.json',root/'seed/resources.json')
pin=b.snapshot(root,'seed','snapshot')
b.restore(root,'snapshot',pin,'restored')
shutil.copytree(root/'restored/active',root/'active')
(root/'seed').rename(root/'seed-retired')
r.durable_json(out/('restoration-'+a.run+'.json'),{'root':str(root),'snapshotSha256':pin,'signature':b.signature(root/'restored'/b.APP),'candidateSignature':b.signature(root/'restored/Companion-candidate.app'),'activeBefore':r.inventory(root/'active'),'candidate':str(candidate)})
print('Copie signée restaurée préparée :',root,flush=True)
