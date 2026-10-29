"""Read-only guards for the uninstalled native preferences acceptance copy."""
import argparse,json,plistlib,subprocess
from pathlib import Path
import native_recipe as n
p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path);a=p.parse_args()
out=a.output
app=out/'native-1/ABAK Maintenance Recipe.app'
candidate=out/'candidate-recipe-12/Companion-candidate.app'
root=out/'abak-maintenance-preferences'
checks=[]
def check(ok,label):
 if not ok: raise AssertionError(label)
 checks.append(label)
info=plistlib.loads((app/'Contents/Info.plist').read_bytes())
m=json.loads((app.parent/'recipe.json').read_text())
check(m.get('preferencesRecipeOnly') is True,'Copie déclarée réservée à la recette des préférences')
check(info.get('ABAKMaintenanceRecipeOnly') is True and info.get('ABAKPreferencesRecipeOnly') is True,'Deux gardes natives de recette présentes')
check(info['CFBundleIdentifier']==m['identity'] and m['identity'].startswith('fr.abakphysio.maintenance.recipe.'),'Identité distincte de Companion installé')
check(n.entitlements(app)==n.PREFERENCES_ENTITLEMENTS,'Droits exacts : sandbox, dossier choisi, signet, chargement des frameworks')
check(not any('network' in k or 'smartcard' in k or 'audio-input' in k for k in n.entitlements(app)),'Aucun droit réseau, CPS ou microphone')
check(n.files(app)==m['files'],'Copie signée inchangée après les sept sessions')
command=n.prepare(app,root)
check(command[1:]==['--abak-maintenance','--abak-maintenance-root='+str(root),'--abak-maintenance-authorize'],'Préparation limitée à la racine synthétique')
run=subprocess.run([command[0]],capture_output=True,text=True,timeout=20)
check(run.returncode==78,'Lancement sans arguments refusé avant les fonctions métier')
(out/'no-flags.json').write_text(json.dumps({'exitCode':run.returncode,'stderr':run.stderr},indent=2))
try:n.create(candidate,out/'forbidden-wrong-mode')
except ValueError:check(not (out/'forbidden-wrong-mode').exists(),'Candidate de recette refusée par le préparateur normal')
else:raise AssertionError('Recipe candidate accepted without recipe mode')
check(json.loads((candidate.parent/'manifest.json').read_text())['preferencesRecipeOnly'] is True,'Compilation de recette distincte d’une candidate produit distribuable')
report={'passed':True,'assertions':len(checks),'checks':checks}
(out/'native-guards.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps(report,ensure_ascii=False,indent=2))
