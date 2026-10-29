"""Launch only the uninstalled, signed coordinated recipe with explicit flags."""
import argparse
import json
import subprocess
from pathlib import Path
import native_recipe as n
import recovery as r
import coordinated_recovery as c

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('root', type=Path)
ap.add_argument('phase', choices=['seed', 'upgrade', 'blocked', 'restore-crash', 'recover', 'verify'])
ap.add_argument('--plan')
args = ap.parse_args()
root = r.root_check(args.root)
app = root/'active'/c.b.APP
manifest = json.loads((app.parent/'recipe.json').read_text())
if manifest.get('coordinatedRecipeOnly') is not True:
    raise ValueError('Copie coordonnée requise')
command = n.prepare(app, root)
command.append('--abak-coordinated-phase='+args.phase)
if args.phase in ('blocked', 'restore-crash', 'recover'):
    with r.locked(root):
        plan = c.load(root, args.plan)
        if c.generation(root/'active') != plan['target']:
            raise ValueError('Génération restaurée incohérente')
    command.append('--abak-rollback-plan='+args.plan)
elif args.plan or (root/c.PENDING).exists():
    raise ValueError('Retour incomplet : phase interdite')
process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
(root/('process-'+args.phase+'.json')).write_text(json.dumps({'pid': process.pid, 'command': command}))
output, _ = process.communicate()
(root/('process-'+args.phase+'.log')).write_bytes(output)
(root/('exit-'+args.phase+'.json')).write_text(json.dumps({'exit': process.returncode}))
raise SystemExit(0 if process.returncode == (86 if args.phase == 'restore-crash' else 0) else 1)
