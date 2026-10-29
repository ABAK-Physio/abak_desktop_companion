"""Fault and refusal tests on an already seeded native synthetic generation."""
import argparse
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import coordinated_recovery as c
import recovery as r

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('root', type=Path)
args = ap.parse_args()
root = r.root_check(args.root)
checks = []
def check(value, label):
    if not value: raise AssertionError(label)
    checks.append(label)
def refuses(action, label):
    try: action()
    except (ValueError, FileNotFoundError, BlockingIOError): check(True, label)
    else: raise AssertionError(label)

pin = json.loads((root/'snapshot-pin.json').read_text())['sha256']
current = root/'observations/upgrade-snapshot.json'
old, new = c.generation(root/'snapshot/payload'), c.generation(root/'active')
check(old['database']['schema'] == 36 and new['database']['schema'] == 37,
      'Migration réelle synthétique 36 vers 37 avant retour')
c.compatible(old, new)
check(True, 'Application signée, données et pièces cohérentes avant retour')
refuses(lambda: c.prepare(root, 'snapshot', '0'*64, current), 'Mauvaise empreinte de sauvegarde refusée')
fresh = root/'active/unexpected-new-proof.txt'
fresh.write_text('SYNTHETIC NEW PROOF\n')
try:
    refuses(lambda: c.prepare(root, 'snapshot', pin, current), 'Nouvelle preuve hors dossier connu : retour refusé')
finally: fresh.unlink()
changed = copy.deepcopy(new)
table = next(k for k,v in changed['database']['tables'].items() if v['rows'])
changed['database']['tables'][table]['sha256'] = 'changed'
refuses(lambda: c.compatible(old, changed), 'Modification de données métier refusée')
changed = copy.deepcopy(new)
changed['database']['tables']['new_nonempty'] = {'rows': 1}
refuses(lambda: c.compatible(old, changed), 'Nouvelles lignes après sauvegarde refusées')
changed = copy.deepcopy(new)
changed['signature']['identifier'] += '.foreign'
refuses(lambda: c.compatible(old, changed), 'Identité native différente refusée')
foreign = json.loads(current.read_text()); foreign['identity'] = 'fr.abakphysio.abakdesktopcompanion.local'
bad = root/'foreign-preferences.json'; bad.write_text(json.dumps(foreign))
refuses(lambda: c.prepare(root, 'snapshot', pin, bad), 'Préférences utilisateur refusées par le banc')
plan_hash = c.prepare(root, 'snapshot', pin, current)
(root/'plan-pin.json').write_text(json.dumps({'sha256': plan_hash}))
refuses(lambda: c.prepare(root, 'snapshot', pin, current), 'Deuxième retour concurrent refusé')
refuses(lambda: c.switch(root, '0'*64), 'Plan non authentifié refusé')
code = 'import sys,os;from pathlib import Path;import coordinated_recovery as c;c.switch(Path(sys.argv[1]),sys.argv[2],fault=lambda p:os._exit(79) if p=="after-preserve" else None)'
result = subprocess.run([sys.executable, '-c', code, str(root), plan_hash],
    env=dict(os.environ, PYTHONPATH=str(Path(__file__).parent.resolve())), timeout=90)
check(result.returncode == 79 and not (root/'active').exists() and (root/c.PENDING).exists(),
      'Arrêt brutal réel après conservation : journal durable, aucune génération partielle publiée')
c.switch(root, plan_hash)
plan = c.load(root, plan_hash)
check(c.generation(root/'active') == plan['target'] and c.generation(root/plan['preserved']) == plan['before'],
      'Reprise de la bascule : les deux générations exactes sont conservées')
check(c.switch(root, plan_hash)['pending'], 'Répétition idempotente laisse la reprise bloquée')
refuses(lambda: c.finish(root, plan_hash, '0'*64), 'Finalisation sans reçu natif interdite')
# Shared POSIX lock: even another process cannot swap files under the live app.
with r.locked(root):
    result = subprocess.run([sys.executable, '-c',
        'import sys;from pathlib import Path;import coordinated_recovery as c;c.switch(Path(sys.argv[1]),sys.argv[2])',
        str(root), plan_hash], env=dict(os.environ,PYTHONPATH=str(Path(__file__).parent.resolve())),
        capture_output=True,timeout=20)
    check(result.returncode != 0 and b'BlockingIOError' in result.stderr, 'Verrou interprocessus interdit la bascule pendant utilisation')
(root/'coordinated-tests.json').write_text(json.dumps({'passed':True,'checks':checks,'plan':plan_hash},ensure_ascii=False,indent=2))
print(json.dumps({'passed':True,'checks':len(checks),'plan':plan_hash}))
