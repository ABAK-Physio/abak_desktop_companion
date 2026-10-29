"""Prepare/launch an uninstalled native maintenance copy with its OWN App Sandbox.

No nested sandbox-exec at launch: libsecinit rejects the combination before main.
The signed copy keeps App Sandbox and has NO network, smartcard or microphone grant.
Only explicit selection of the exact synthetic folder is permitted by the UI.
"""
import argparse
import json
from pathlib import Path
import plistlib
import subprocess
import uuid

import recovery as r

ENTITLEMENTS = {
    'com.apple.security.app-sandbox': True,
    'com.apple.security.files.user-selected.read-write': True,
    'com.apple.security.cs.disable-library-validation': True,
}
PREFERENCES_ENTITLEMENTS = dict(ENTITLEMENTS, **{'com.apple.security.files.bookmarks.app-scope': True})


def files(app):
    return {str(p.relative_to(app)): ({'link':str(p.readlink())} if p.is_symlink() else {'sha256':r.sha(p)})
            for p in sorted(app.rglob('*')) if p.is_file() or p.is_symlink()}


def entitlements(app):
    result=subprocess.run(['/usr/bin/codesign','--display','--entitlements','-','--xml',str(app)],
                          check=True,capture_output=True)
    return plistlib.loads(result.stdout)


def create(candidate, output, preferences_folder=None, bundle_resources=False, coordinated_folder=None):
    candidate, output=Path(candidate),Path(output)
    r.regular(candidate, True)
    r.regular(output.parent, True)
    if output.exists() or output.is_symlink() or any(p in output.parts for p in ['Applications','Containers','Group Containers']):
        raise ValueError('Sortie neuve hors installation/conteneurs requise')
    # Authenticate the source using the build-only manifest, without executing it.
    source=json.loads((candidate.parent/'manifest.json').read_text())
    if bool(source.get('preferencesRecipeOnly')) != (preferences_folder is not None):
        raise ValueError('Entrée de recette préférences et mode de préparation doivent correspondre')
    if sum([bundle_resources, preferences_folder is not None, coordinated_folder is not None]) > 1:
        raise ValueError('Recettes distinctes requises')
    folder = preferences_folder if preferences_folder is not None else coordinated_folder
    if folder is not None:
        folder=Path(folder)
        r.regular(folder, True)
        if (not folder.name.startswith('abak-bookmarks-') or
            any(p in folder.parts for p in ['Applications','Containers','Group Containers']) or
            (folder/'SYNTHETIC-ONLY').read_text()!='ABAK-BOOKMARKS-SYNTHETIC-V1\n'):
            raise ValueError('Dossier synthétique de signets requis')
    permissions=PREFERENCES_ENTITLEMENTS if folder is not None else ENTITLEMENTS
    source_code=json.loads((candidate.parent/'sources.json').read_text())
    native=Path(__file__).resolve().parents[2]/'macos/Runner/MainFlutterWindow.swift'
    if source_code['macos/Runner'].get('MainFlutterWindow.swift')!={'sha256':r.sha(native)} or int(source['build'])<11:
        raise ValueError('Candidate avec garde native de recette actuelle requise')
    listed=candidate.parent/'candidate-files.json'
    if source['status']!='COMPILED_NOT_INSTALLED' or source['filesManifestSha256']!=r.sha(listed) or files(candidate)!=json.loads(listed.read_text()):
        raise ValueError('Candidate source non vérifiée')
    subprocess.run(['/usr/bin/codesign','--verify','--deep','--strict',str(candidate)],check=True)
    identifier='fr.abakphysio.maintenance.recipe.'+uuid.uuid4().hex
    container=Path.home()/'Library/Containers'/identifier
    if container.exists(): raise ValueError('Conteneur de recette déjà présent')
    output.mkdir()
    app=output/'ABAK Maintenance Recipe.app'
    subprocess.run(['/usr/bin/ditto',str(candidate),str(app)],check=True)
    info_path=app/'Contents/Info.plist'
    info=plistlib.loads(info_path.read_bytes())
    if info['CFBundleIdentifier']!='fr.abakphysio.abakdesktopcompanion.local':
        raise ValueError('Source locale requise')
    info.update(CFBundleIdentifier=identifier,CFBundleDisplayName='ABAK — Maintenance isolée',
                ABAKMaintenanceRecipeOnly=True)
    if preferences_folder is not None:
        info.update(ABAKPreferencesRecipeOnly=True, ABAKRecipeFolder=str(preferences_folder))
    if coordinated_folder is not None:
        info.update(ABAKCoordinatedRecipeOnly=True, ABAKRecipeFolder=str(coordinated_folder))
    if bundle_resources:
        info['ABAKBundleResourcesRecipeOnly']=True
    info_path.write_bytes(plistlib.dumps(info))
    service = app/'Contents/XPCServices/AbakDocumentControls.xpc'
    if service.exists():
        service_info = service/'Contents/Info.plist'
        details = plistlib.loads(service_info.read_bytes())
        details['ABAKHostRequirement'] = ('anchor apple generic and identifier "'+identifier+'" and certificate leaf[subject.OU] = "LP84QVHHSV"')
        service_info.write_bytes(plistlib.dumps(details))
        subprocess.run(['/usr/bin/codesign','--force','--sign','Apple Development: Jean-Calude Brucher (62JVW4B29K)',
                        '--options','runtime','--timestamp=none',str(service)],check=True)

    entitlement_file=output/'recipe.entitlements'
    entitlement_file.write_bytes(plistlib.dumps(permissions))
    subprocess.run(['/usr/bin/codesign','--force','--sign','Apple Development: Jean-Calude Brucher (62JVW4B29K)',
                    '--options','runtime','--timestamp=none','--entitlements',str(entitlement_file),str(app)],check=True)
    subprocess.run(['/usr/bin/codesign','--verify','--deep','--strict',str(app)],check=True)
    if entitlements(app)!=permissions: raise ValueError('Permissions inattendues')
    before, after=files(candidate), files(app)
    allowed={'Contents/Info.plist','Contents/_CodeSignature/CodeResources',
             'Contents/CodeResources','Contents/MacOS/'+info['CFBundleExecutable']}
    allowed.update({'Contents/XPCServices/AbakDocumentControls.xpc/Contents/'+name for name in
                    ['Info.plist','_CodeSignature/CodeResources','MacOS/AbakDocumentControls']})
    changed={k for k in before.keys()|after.keys() if before.get(k)!=after.get(k)}
    if not changed <= allowed: raise ValueError('Code ou ressource modifiée pendant préparation')
    manifest={'format':'ABAK-NATIVE-MAINTENANCE-RECIPE-1','source':str(candidate),
              'sourceManifestSha256':r.sha(candidate.parent/'manifest.json'),
              'sourceFilesManifestSha256':r.sha(listed),'identity':identifier,
              'container':str(container),'changedEntries':sorted(changed),
              'files':after,'entitlements':permissions,'installed':False,
              'preferencesRecipeOnly': preferences_folder is not None,
              'coordinatedRecipeOnly': coordinated_folder is not None,
              'bundleResourcesRecipeOnly': bundle_resources}
    (output/'recipe.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    return app


def prepare(app,root):
    app,root=Path(app),Path(root)
    r.regular(app,True)
    if any(p in app.parts for p in ['Applications','Containers','Group Containers']):
        raise ValueError('Copie non installée requise')
    with r.locked(root): r.database_state(root/'active')
    manifest=json.loads((app.parent/'recipe.json').read_text())
    if manifest['format']!='ABAK-NATIVE-MAINTENANCE-RECIPE-1' or manifest['files']!=files(app):
        raise ValueError('Recette altérée')
    info=plistlib.loads((app/'Contents/Info.plist').read_bytes())
    if not (info.get('ABAKMaintenanceRecipeOnly') is True and
            info['CFBundleIdentifier']==manifest['identity'] and
            info['CFBundleIdentifier'].startswith('fr.abakphysio.maintenance.recipe.')):
        raise ValueError('Identité de recette requise')
    subprocess.run(['/usr/bin/codesign','--verify','--deep','--strict',str(app)],check=True)
    expected=PREFERENCES_ENTITLEMENTS if manifest.get('preferencesRecipeOnly') or manifest.get('coordinatedRecipeOnly') else ENTITLEMENTS
    if bool(info.get('ABAKCoordinatedRecipeOnly')) != bool(manifest.get('coordinatedRecipeOnly')):
        raise ValueError('Mode de recette coordonnée incohérent')
    if bool(info.get('ABAKPreferencesRecipeOnly')) != bool(manifest.get('preferencesRecipeOnly')):
        raise ValueError('Mode de recette incohérent')
    if bool(info.get('ABAKBundleResourcesRecipeOnly')) != bool(manifest.get('bundleResourcesRecipeOnly')):
        raise ValueError('Mode ressources incohérent')
    if entitlements(app)!=expected: raise ValueError('Isolation native incorrecte')
    binary=app/'Contents/MacOS'/info['CFBundleExecutable']
    r.regular(binary)
    return [str(binary),'--abak-maintenance','--abak-maintenance-root='+str(root),
            '--abak-maintenance-authorize'] + (['--abak-bundle-resources'] if manifest.get('bundleResourcesRecipeOnly') else [])


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__)
    sub=ap.add_subparsers(dest='operation',required=True)
    p=sub.add_parser('create');p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--preferences-folder',type=Path);p.add_argument('--bundle-resources',action='store_true')
    p=sub.add_parser('launch');p.add_argument('--app',type=Path,required=True);p.add_argument('--root',type=Path,required=True);p.add_argument('--describe',action='store_true');p.add_argument('--preferences-phase', choices=['seed','mutated','restored','moved','missing','reauthorized','cancel'])
    args=ap.parse_args()
    if args.operation=='create': print(create(args.candidate,args.output,args.preferences_folder,args.bundle_resources))
    else:
        command=prepare(args.app,args.root)
        recipe=json.loads((args.app.parent/'recipe.json').read_text())
        if bool(args.preferences_phase) != bool(recipe.get('preferencesRecipeOnly')):
            raise ValueError('Phase de recette préférences obligatoire et réservée à sa copie dédiée')
        if args.preferences_phase: command.append('--abak-preferences-phase='+args.preferences_phase)
        if args.describe: print(json.dumps(command,indent=2))
        else: raise SystemExit(subprocess.run(command,check=False).returncode)
