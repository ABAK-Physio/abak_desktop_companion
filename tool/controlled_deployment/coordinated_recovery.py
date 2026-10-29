"""Rehearse coordinated rollback; synthetic roots and signed recipe apps ONLY.

Disk generations switch atomically by rename. Native preferences remain a separate
transaction: the pending marker cannot be retired until the signed recipe reports
readback of UserDefaults, launch history and the security-scoped bookmark. The
caller must retain the plan SHA-256 independently. Both generations are preserved.
This is acceptance tooling, not an installer or a production recovery facility.
"""
import json
from pathlib import Path
import re
import uuid
import bundle_recovery as b
import recovery as r

PENDING = 'coordinated.pending.json'
FORMAT = 'ABAK-COORDINATED-RECIPE-1'


def generation(path):
    entries = b.inventory(path)
    # macOS alone adds an access-control label to the launched .app directory.
    # Do not ignore this attribute on any other entry or ignore any signed byte.
    entries[b.APP]['xattrs'].pop('com.apple.macl', None)
    signed = b.signature(path / b.APP)
    if (not signed['identifier'].startswith('fr.abakphysio.maintenance.recipe.') or
            signed['entitlements'] != __import__('native_recipe').PREFERENCES_ENTITLEMENTS):
        raise ValueError('Identité et droits de recette coordonnée obligatoires')
    return {'entries': entries, 'signature': signed, 'database': r.database_state(path)}


def preferences(path, identity):
    r.regular(path)
    data = json.loads(path.read_text())
    if (data.get('format') != 'ABAK-NATIVE-PREFERENCES-RECIPE-1' or
            data.get('identity') != identity or not re.fullmatch('[a-f0-9]{64}', data.get('sha256', ''))):
        raise ValueError('Sauvegarde native de la même identité requise')
    import base64, hashlib, plistlib
    payload = base64.b64decode(data['payload'], validate=True)
    values = plistlib.loads(payload)
    if (hashlib.sha256(payload).hexdigest() != data['sha256'] or
            sorted(values) != data['keys'] or any(not k.startswith('flutter.') for k in values)):
        raise ValueError('Préférences natives altérées')
    return data


def compatible(before, after):
    if before['signature']['identifier'] != after['signature']['identifier']:
        raise ValueError('Une seule identité native requise')
    if before['signature']['requirement'] != after['signature']['requirement']:
        raise ValueError('Exigence de signature différente')
    old, new = before['database'], after['database']
    if not (old['schema'] <= new['schema'] <= 37):
        raise ValueError('Migration de schéma non prise en charge')
    if any(new['tables'].get(k) != v for k, v in old['tables'].items()):
        raise ValueError('Données métier modifiées : retour automatique refusé')
    if any(v['rows'] for k, v in new['tables'].items() if k not in old['tables']):
        raise ValueError('Nouvelles données : retour automatique refusé')
    def durable(entries):
        # Only the application, its fixed validator distribution and the closed
        # SQLite file may differ during a schema-only upgrade. Unknown new files
        # are user data until proven otherwise; never silently discard them.
        return {k: v for k, v in entries.items()
                if k not in (b.APP, 'recipe.json', r.DB, 'resources')
                and not k.startswith((b.APP+'/', 'resources/'))}
    if durable(before['entries']) != durable(after['entries']):
        raise ValueError('Pièces ou preuves modifiées : retour automatique refusé')


def prepare(root, archive, archive_hash, current_preferences):
    with r.locked(root):
        root = Path(root)
        if (root/PENDING).exists():
            raise ValueError('Retour déjà en attente')
        if Path(current_preferences) != root/'observations/upgrade-snapshot.json':
            raise ValueError('Lecture limitée au relevé natif de la recette synthétique')
        source, _ = b.verify(root, archive, archive_hash)
        old = generation(source/'payload')
        new = generation(root/'active')
        compatible(old, new)
        identity = old['signature']['identifier']
        target = preferences(source/'payload/preferences/native.json', identity)
        current = preferences(Path(current_preferences), identity)
        token = uuid.uuid4().hex
        stage = root/('rollback-stage-'+token)
        b.copy_verified(source/'payload', stage, b.inventory(source/'payload'))
        b.sync_tree(stage)
        if generation(stage) != old or generation(root/'active') != new:
            raise ValueError('Génération modifiée pendant préparation')
        plan = {'format': FORMAT, 'token': token, 'identity': identity,
                'archive': archive, 'archiveHash': archive_hash,
                'stage': stage.name, 'preserved': 'preserved-'+token,
                'before': new, 'target': old,
                'beforePreferences': current['sha256'], 'targetPreferences': target['sha256'],
                'targetArchiveHash': r.sha(source/'payload/preferences/native.json')}
        r.durable_json(root/PENDING, plan)
        return r.sha(root/PENDING)


def load(root, plan_hash):
    r.root_check(root)
    path = Path(root)/PENDING
    r.regular(path)
    if r.sha(path) != plan_hash:
        raise ValueError('Plan différent de l’empreinte conservée')
    plan = json.loads(path.read_text())
    if plan['format'] != FORMAT or not re.fullmatch('[a-f0-9]{32}', plan['token']):
        raise ValueError('Plan invalide')
    for key, prefix in [('stage', 'rollback-stage-'), ('preserved', 'preserved-')]:
        if plan[key] != prefix+plan['token']:
            raise ValueError('Chemin du plan invalide')
    b.verify(root, plan['archive'], plan['archiveHash'])
    return plan


def switch(root, plan_hash, fault=None):
    with r.locked(root):
        root = Path(root)
        plan = load(root, plan_hash)
        active, stage, saved = root/'active', root/plan['stage'], root/plan['preserved']
        if not saved.exists():
            if generation(active) != plan['before'] or generation(stage) != plan['target']:
                raise ValueError('Génération modifiée : bascule refusée')
            active.rename(saved)
            r.sync_dir(root)
            if fault: fault('after-preserve')
        if generation(saved) != plan['before']:
            raise ValueError('Génération conservée altérée')
        if not active.exists():
            if generation(stage) != plan['target']:
                raise ValueError('Génération de retour altérée')
            stage.rename(active)
            r.sync_dir(root)
            if fault: fault('after-activate')
        if stage.exists() or generation(active) != plan['target']:
            raise ValueError('Génération active ambiguë : reprise bloquée')
        return {'pending': True, 'nativePreferencesRequired': True}


def finish(root, plan_hash, receipt_hash):
    with r.locked(root):
        root = Path(root)
        plan = load(root, plan_hash)
        if generation(root/'active') != plan['target'] or generation(root/plan['preserved']) != plan['before']:
            raise ValueError('Ensemble de fichiers différent : reprise refusée')
        receipt = root/'observations/recovery-receipt.json'
        r.regular(receipt)
        if r.sha(receipt) != receipt_hash:
            raise ValueError('Reçu natif différent')
        data = json.loads(receipt.read_text())
        if data != {'plan': plan_hash, 'identity': plan['identity'],
                    'preferences': plan['targetPreferences'], 'bookmarkVerified': True,
                    'history': 'unchanged', 'passed': True}:
            raise ValueError('Vérifications natives incomplètes')
        (root/PENDING).rename(root/('coordinated-complete-'+plan['token']+'.json'))
        r.sync_dir(root)
        return {'complete': True, 'bothGenerationsPreserved': True}
