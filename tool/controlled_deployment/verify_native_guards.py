"""Read-only checks of the native recipe, except disposable synthetic paths."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile
import native_recipe as n
import recovery as r

ap=argparse.ArgumentParser()
ap.add_argument('--app',type=Path,required=True)
ap.add_argument('--root',type=Path,required=True)
ap.add_argument('--output',type=Path,required=True)
args=ap.parse_args()
checks=[]
def check(condition,label):
    if not condition: raise AssertionError(label)
    checks.append(label)
def refuses(action,label):
    try:action()
    except Exception:check(True,label)
    else:raise AssertionError(label)

manifest=json.loads((args.app.parent/'recipe.json').read_text())
source=Path(manifest['source'])
before=r.inventory(args.root/'active')
command=n.prepare(args.app,args.root)
check(command[-3:]==['--abak-maintenance','--abak-maintenance-root='+str(args.root),'--abak-maintenance-authorize'],
      'Arguments imposent maintenance, racine explicite et autorisation exacte')
check(n.entitlements(args.app)==n.ENTITLEMENTS,'App Sandbox actif et permissions réseau/carte/microphone absentes')
check(manifest['files']==n.files(args.app),'Copie native signée identique à son manifeste')
code='Contents/Frameworks/App.framework/Versions/A/App'
check(n.files(source)[code]==manifest['files'][code],'Code Dart compilé strictement identique à la candidate source')
refuses(lambda:n.prepare(source,args.root),'Lanceur refuse l’identité de l’application locale habituelle')
with tempfile.TemporaryDirectory(prefix='abak-maintenance-negative-',dir=args.output.parent) as tmp:
    missing=Path(tmp)
    refuses(lambda:n.prepare(args.app,missing),'Racine sans marqueur refusée avant lancement')
    refuses(lambda:n.create(source,args.app.parent),'Répertoire de recette existant non écrasé')
with r.locked(args.root):
    # POSIX locks from a separate interpreter, not same-process reacquisition.
    script=Path(__file__).parent/'native_recipe.py'
    result=subprocess.run(['/usr/bin/python3',str(script),'launch','--app',str(args.app),
                           '--root',str(args.root),'--describe'],capture_output=True,text=True)
    check(result.returncode!=0 and 'BlockingIOError' in result.stderr,'Verrou interprocessus bloque même la préparation native')
legacy=subprocess.run(['/usr/bin/python3',str(Path(__file__).parent/'maintenance_only.py'),
                       '--candidate',str(source),'--root',str(args.root)],capture_output=True,text=True)
check(legacy.returncode!=0 and 'désactivé' in legacy.stderr,'Ancien lancement imbriqué désormais refusé sans exécution')
check(r.inventory(args.root/'active')==before,'Toutes les gardes laissent les fichiers synthétiques inchangés')
args.output.write_text(json.dumps({'passed':True,'assertions':len(checks),'checks':checks},ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'passed':True,'assertions':len(checks)}))
