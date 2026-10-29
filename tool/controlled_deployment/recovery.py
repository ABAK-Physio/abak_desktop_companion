"""Durable snapshot/rollback rehearsal restricted to explicitly synthetic roots.

No installation target, real container, application launch or network API exists.
An active generation groups app surrogate, SQLite, PDFs/proofs and preferences.
"""
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sqlite3
import uuid

MARKER = 'ABAK-MAINTENANCE-SYNTHETIC-V1\n'
DB = 'support/database/abak_desktop.db'


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def fingerprint(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def regular(path, directory=False):
    path = Path(path)
    if not path.is_absolute() or path.resolve() != path or any(p.is_symlink() for p in [path, *path.parents]):
        raise ValueError('Chemin non canonique ou lien interdit')
    if not (path.is_dir() if directory else path.is_file()):
        raise ValueError('Ressource absente : ' + str(path))


def root_check(root):
    root = Path(root)
    regular(root, True)
    if not root.name.startswith('abak-maintenance-') or any(p in root.parts for p in ['Applications', 'Containers', 'Group Containers']):
        raise ValueError('Périmètre synthétique requis')
    regular(root / 'SYNTHETIC-ONLY')
    if (root / 'SYNTHETIC-ONLY').read_text() != MARKER:
        raise ValueError('Marqueur synthétique incorrect')
    return root


@contextlib.contextmanager
def locked(root):
    root = root_check(root)
    lock_path = root / '.companion-instance.lock'
    if lock_path.exists() or lock_path.is_symlink():
        regular(lock_path)
    with lock_path.open('a+b') as lock:
        fcntl.lockf(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield root


def inventory(root):
    regular(root, True)
    result = {}
    for path in sorted(root.rglob('*')):
        if path.is_symlink() or not (path.is_file() or path.is_dir()):
            raise ValueError('Entrée non régulière')
        result[str(path.relative_to(root))] = ({'kind': 'directory'} if path.is_dir() else
            {'kind': 'file', 'size': path.stat().st_size, 'sha256': sha(path)})
    return result


def database_state(generation):
    db = generation / DB
    regular(db)
    for suffix in ['-wal', '-shm', '-journal']:
        side = Path(str(db) + suffix)
        if side.exists() or side.is_symlink():
            regular(side)
            if side.stat().st_size:
                raise ValueError('Base non fermée proprement ; conservation des auxiliaires requise')
    # Immutable prevents recovery or sidecar writes. We only inspect closed copies.
    with contextlib.closing(sqlite3.connect(db.as_uri() + '?mode=ro&immutable=1', uri=True)) as cx:
        if cx.execute('PRAGMA integrity_check').fetchall() != [('ok',)]:
            raise ValueError('Base intègre requise')
        if cx.execute('PRAGMA foreign_key_check').fetchall():
            raise ValueError('Références de base incohérentes')
        tables = {}
        for (name,) in cx.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"):
            quoted = '"' + name.replace('"', '""') + '"'
            columns = [r[1] for r in cx.execute('PRAGMA table_info(' + quoted + ')')]
            rows = cx.execute('SELECT * FROM ' + quoted).fetchall()
            # Include binary values without storing clinical plaintext in the report.
            canonical = sorted((json.dumps(list(r), default=lambda x: {'hex': x.hex()}, sort_keys=True) for r in rows))
            tables[name] = {'columns': columns, 'rows': len(rows), 'sha256': fingerprint(canonical)}
        return {'schema': cx.execute('PRAGMA user_version').fetchone()[0], 'tables': tables}


def durable_json(path, value):
    temp = path.with_name(path.name + '.partial')
    with temp.open('x') as stream:
        json.dump(value, stream, ensure_ascii=False, indent=2)
        stream.flush()
        os.fsync(stream.fileno())
    temp.rename(path)
    sync_dir(path.parent)


def sync_dir(path):
    fd = os.open(path, os.O_RDONLY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def copy_verified(source, target, expected):
    shutil.copytree(source, target, copy_function=shutil.copy2)
    if inventory(target) != expected or inventory(source) != expected:
        raise ValueError('Copie incomplète ou source modifiée pendant la copie')
    for path in target.rglob('*'):
        if path.is_file():
            with path.open('rb') as stream:
                os.fsync(stream.fileno())
    for path in sorted((p for p in target.rglob('*') if p.is_dir()), reverse=True):
        sync_dir(path)
    sync_dir(target)


def checkpoint(root, name):
    if not re.fullmatch(r'[a-z][a-z0-9-]{0,48}', name):
        raise ValueError('Nom de point de repli invalide')
    with locked(root) as root:
        if (root / 'rollback.pending.json').exists():
            raise ValueError('Retour arrière interrompu à examiner')
        active = root / 'active'
        expected = inventory(active)
        state = database_state(active)
        for name_required in ['app', 'support', 'preferences', 'documents']:
            regular(active / name_required, True)
        base = root / 'checkpoints'
        base.mkdir(exist_ok=True)
        regular(base, True)
        destination = base / name
        if destination.exists() or destination.is_symlink():
            raise ValueError('Point de repli existant ; aucun écrasement')
        staging = base / ('.partial-' + uuid.uuid4().hex)
        staging.mkdir()
        copy_verified(active, staging / 'generation', expected)
        durable_json(staging / 'manifest.json', {'format': 'ABAK-SYNTHETIC-ROLLBACK-1',
                     'entries': expected, 'database': state, 'fingerprint': fingerprint(expected)})
        staging.rename(destination)
        sync_dir(base)
        return destination


def checkpoint_read(root, name):
    if not re.fullmatch(r'[a-z][a-z0-9-]{0,48}', name):
        raise ValueError('Nom invalide')
    base = root / 'checkpoints' / name
    regular(base / 'manifest.json')
    manifest = json.loads((base / 'manifest.json').read_text())
    if (manifest['format'] != 'ABAK-SYNTHETIC-ROLLBACK-1' or
        fingerprint(manifest['entries']) != manifest['fingerprint'] or
        inventory(base / 'generation') != manifest['entries'] or
        database_state(base / 'generation') != manifest['database']):
        raise ValueError('Point de repli altéré')
    return base, manifest


def unchanged_documents(entries, saved):
    # App and preferences change with a release, SQLite with its migration.
    # Every other file must remain identical: restoring must not lose a PDF,
    # proof, source document or any newly created file outside the database.
    def documents(value):
        return {k: v for k, v in value.items()
                if not (k == 'app' or k.startswith('app/') or
                        k == 'preferences' or k.startswith('preferences/') or k == DB)}
    if documents(entries) != documents(saved):
        raise ValueError('Pièces ou preuves modifiées : examen requis avant retour arrière')


def prepare_rollback(root, name):
    with locked(root) as root:
        if (root / 'rollback.pending.json').exists():
            raise ValueError('Récupération préalable requise')
        _, manifest = checkpoint_read(root, name)
        entries = inventory(root / 'active')
        unchanged_documents(entries, manifest['entries'])
        current = database_state(root / 'active')
        before = manifest['database']
        if not 1 <= before['schema'] <= current['schema'] <= 37:
            raise ValueError('Générations incompatibles')
        # Automatic rollback is only permitted for a schema-only upgrade. Any
        # new clinical data, attempt, result, review or hold requires examination.
        for table, original in before['tables'].items():
            if current['tables'].get(table) != original:
                raise ValueError('Données métier modifiées : examen requis avant retour arrière')
        if any(t['rows'] for k, t in current['tables'].items() if k not in before['tables']):
            raise ValueError('Données nouvelles : examen requis avant retour arrière')
        return {'checkpoint': name, 'expectedActive': fingerprint(entries)}


def rollback(root, preview, fault=None):
    with locked(root) as root:
        if (root / 'rollback.pending.json').exists():
            raise ValueError('Retour interrompu à récupérer')
        base, manifest = checkpoint_read(root, preview['checkpoint'])
        before = inventory(root / 'active')
        unchanged_documents(before, manifest['entries'])
        if fingerprint(before) != preview['expectedActive']:
            raise ValueError('La génération active a changé depuis la préparation')
        # Revalidate semantic eligibility while holding the same lock.
        current = database_state(root / 'active')
        old = manifest['database']
        if (not 1 <= old['schema'] <= current['schema'] <= 37 or
            any(current['tables'].get(k) != v for k, v in old['tables'].items()) or
            any(v['rows'] for k, v in current['tables'].items() if k not in old['tables'])):
            raise ValueError('Retour automatique incompatible avec les données présentes')
        token = uuid.uuid4().hex
        new, failed = root / ('staging-' + token), root / ('preserved-' + token)
        copy_verified(base / 'generation', new, manifest['entries'])
        pending = {'token': token, 'before': before, 'checkpoint': preview['checkpoint']}
        durable_json(root / 'rollback.pending.json', pending)
        try:
            if fault: fault('before_preserve')
            (root / 'active').rename(failed)
            sync_dir(root)
            if fault: fault('after_preserve')
            new.rename(root / 'active')
            sync_dir(root)
            if fault: fault('after_activate')
            if inventory(root / 'active') != manifest['entries']:
                raise ValueError('Génération restaurée non identique')
            (root / 'rollback.pending.json').rename(root / ('rollback-complete-' + token + '.json'))
            sync_dir(root)
            return {'restored': manifest['fingerprint'], 'preserved': str(failed)}
        except Exception:
            _recover(root)
            raise


def _recover(root):
    pending_file = root / 'rollback.pending.json'
    regular(pending_file)
    pending = json.loads(pending_file.read_text())
    token = pending['token']
    if not re.fullmatch(r'[0-9a-f]{32}', token):
        raise ValueError('Journal interrompu invalide')
    failed, active = root / ('preserved-' + token), root / 'active'
    if failed.exists():
        if inventory(failed) != pending['before']:
            raise ValueError('Génération conservée altérée ; arrêt sans suppression')
        if active.exists():
            active.rename(root / ('abandoned-' + uuid.uuid4().hex))
        failed.rename(active)
    elif not active.exists() or inventory(active) != pending['before']:
        raise ValueError('État interrompu ambigu ; conserver toutes les copies')
    sync_dir(root)
    pending_file.rename(root / ('rollback-recovered-' + token + '.json'))
    sync_dir(root)
    return fingerprint(inventory(active))


def recover(root):
    with locked(root) as root:
        return _recover(root)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation', choices=['checkpoint', 'preview', 'rollback', 'recover'])
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--name', default='before-upgrade')
    parser.add_argument('--expected-active')
    opts = parser.parse_args()
    if opts.operation == 'checkpoint': result = str(checkpoint(opts.root, opts.name))
    elif opts.operation == 'preview': result = prepare_rollback(opts.root, opts.name)
    elif opts.operation == 'recover': result = recover(opts.root)
    else:
        if not opts.expected_active: parser.error('Préparation --expected-active requise')
        result = rollback(opts.root, {'checkpoint': opts.name, 'expectedActive': opts.expected_active})
    print(json.dumps(result, ensure_ascii=False, indent=2))
