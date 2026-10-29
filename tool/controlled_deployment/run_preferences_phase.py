"""Launch only a verified preferences recipe; archive its exit, never a real app."""
import argparse
import json
from pathlib import Path
import subprocess
import native_recipe as n

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('output',type=Path)
p.add_argument('phase',choices=['seed','mutated','restored','moved','missing','cancel','reauthorized'])
a=p.parse_args()
app=a.output/'native-1/ABAK Maintenance Recipe.app'
recipe=json.loads((app.parent/'recipe.json').read_text())
if recipe.get('preferencesRecipeOnly') is not True: raise ValueError('Copie préférences requise')
command=n.prepare(app,a.output/'abak-maintenance-preferences')+['--abak-preferences-phase='+a.phase]
log=a.output/(a.phase+'-launch.log')
if log.exists(): raise ValueError('Journal de phase existant : ne pas écraser')
with log.open('w') as f:
    proc=subprocess.Popen(command,stdout=f,stderr=subprocess.STDOUT)
    (a.output/(a.phase+'-process.json')).write_text(json.dumps({'pid':proc.pid,'identity':recipe['identity']}))
    code=proc.wait()
(a.output/(a.phase+'-exit.json')).write_text(json.dumps({'exit':code}))
print(json.dumps({'phase':a.phase,'exit':code}))
raise SystemExit(code)
