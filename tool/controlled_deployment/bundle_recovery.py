"""Native signed-bundle snapshots, restricted to marked synthetic recipe roots.

Uses ditto, preserves internal framework symlinks, modes, ACLs and extended
attributes. Never installs, changes a signature, follows external links, or runs
the copied application. A separately retained manifest hash is required to restore.
"""
import ctypes
import hashlib
import json
import os
from pathlib import Path
import plistlib
import stat
import subprocess
import uuid

import recovery as r

FORMAT = 'ABAK-SIGNED-BUNDLE-SNAPSHOT-1'
APP = 'ABAK Maintenance Recipe.app'
libc = ctypes.CDLL('/usr/lib/libSystem.B.dylib', use_errno=True)
libc.listxattr.argtypes = [ctypes.c_char_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]
libc.listxattr.restype = ctypes.c_ssize_t
libc.getxattr.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint32, ctypes.c_int]
libc.getxattr.restype = ctypes.c_ssize_t
libc.setxattr.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint32, ctypes.c_int]
libc.setxattr.restype = ctypes.c_int
libc.acl_get_link_np.argtypes = [ctypes.c_char_p, ctypes.c_int]
libc.acl_get_link_np.restype = ctypes.c_void_p
libc.acl_to_text.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ssize_t)]
libc.acl_to_text.restype = ctypes.c_void_p
libc.acl_free.argtypes = [ctypes.c_void_p]


def metadata(path):
    name = os.fsencode(path)
    size = libc.listxattr(name, None, 0, 1)  # NOFOLLOW, including framework links.
    if size < 0:
        raise OSError(ctypes.get_errno(), 'listxattr', str(path))
    buffer = ctypes.create_string_buffer(size)
    if libc.listxattr(name, buffer, size, 1) != size:
        raise ValueError('Attributs modifiés pendant lecture')
    attrs = {}
    for key in buffer.raw.split(b'\0'):
        if not key:
            continue
        length = libc.getxattr(name, key, None, 0, 0, 1)
        if length < 0:
            raise OSError(ctypes.get_errno(), 'getxattr', str(path))
        value = ctypes.create_string_buffer(length)
        if libc.getxattr(name, key, value, length, 0, 1) != length:
            raise ValueError('Attribut modifié pendant lecture')
        attrs[key.decode()] = hashlib.sha256(value.raw).hexdigest()
    acl = libc.acl_get_link_np(name, 0x100)  # ACL_TYPE_EXTENDED
    acl_text = None
    if acl:
        length = ctypes.c_ssize_t()
        pointer = libc.acl_to_text(acl, ctypes.byref(length))
        if not pointer:
            libc.acl_free(acl)
            raise ValueError('ACL illisible')
        acl_text = ctypes.string_at(pointer, length.value).decode()
        libc.acl_free(pointer)
        libc.acl_free(acl)
    elif ctypes.get_errno() not in (0, 2, 93):
        raise OSError(ctypes.get_errno(), 'acl_get_link_np', str(path))
    info = path.lstat()
    return {'mode': stat.S_IMODE(info.st_mode), 'uid': info.st_uid,
            'gid': info.st_gid, 'flags': info.st_flags, 'xattrs': attrs, 'acl': acl_text}


def inventory(base):
    base = Path(base)
    r.regular(base, True)
    entries = {}
    def visit(path):
        key = path.relative_to(base).as_posix()
        info = path.lstat()
        entry = metadata(path)
        if stat.S_ISLNK(info.st_mode):
            target = os.readlink(path)
            if os.path.isabs(target):
                raise ValueError('Lien absolu interdit')
            try:
                resolved = path.resolve(strict=True)
                resolved.relative_to(base)
            except (ValueError, RuntimeError, FileNotFoundError):
                raise ValueError('Lien sortant, circulaire ou cassé')
            entry.update(kind='link', target=target)
        elif stat.S_ISDIR(info.st_mode):
            entry.update(kind='directory')
        elif stat.S_ISREG(info.st_mode):
            if info.st_nlink != 1:
                raise ValueError('Lien physique inattendu')
            entry.update(kind='file', size=info.st_size, sha256=r.sha(path))
        else:
            raise ValueError('Fichier spécial interdit')
        entries[key] = entry
        if entry['kind'] == 'directory':
            for child in sorted(path.iterdir()):
                visit(child)
    visit(base)
    return entries


def signature(app):
    subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(app)],
                   check=True, capture_output=True)
    info = plistlib.loads((app/'Contents/Info.plist').read_bytes())
    ent = subprocess.run(['/usr/bin/codesign', '--display', '--entitlements', '-', '--xml', str(app)],
                         check=True, capture_output=True)
    requirement = subprocess.run(['/usr/bin/codesign', '--display', '-r-', str(app)],
                                 check=True, capture_output=True)
    req = next(line for line in (requirement.stdout+requirement.stderr).decode().splitlines()
               if line.startswith('designated =>'))
    return {'identifier': info['CFBundleIdentifier'], 'version': info['CFBundleShortVersionString'],
            'build': info['CFBundleVersion'], 'entitlements': plistlib.loads(ent.stdout),
            'requirement': req}


def child(root, name, exists=True):
    root = r.root_check(root)
    if not name or name in ('.', '..') or Path(name).name != name or name.startswith('.'):
        raise ValueError('Nom de génération simple requis')
    value = root/name
    if exists:
        r.regular(value, True)
    elif value.exists() or value.is_symlink():
        raise ValueError('Destination neuve requise ; aucun remplacement implicite')
    return value


def sync_tree(root):
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in files:
            path = Path(directory)/name
            if not path.is_symlink():
                with path.open('rb') as stream:
                    os.fsync(stream.fileno())
        r.sync_dir(Path(directory))


def copy_verified(source, target, expected):
    subprocess.run(['/usr/bin/ditto', '--rsrc', '--extattr', '--acl', str(source), str(target)], check=True)
    # ditto may refresh only the timestamp of quarantine metadata. Preserve the
    # original attribute verbatim, including ALL protection flags; never strip
    # it or tolerate differences in another attribute or the signed contents.
    actual = inventory(target)
    for key, entry in actual.items():
        wanted = expected.get(key)
        if wanted is None or entry == wanted:
            continue
        left, right = json.loads(json.dumps(entry)), json.loads(json.dumps(wanted))
        left['xattrs'].pop('com.apple.quarantine', None)
        right['xattrs'].pop('com.apple.quarantine', None)
        if left != right or 'com.apple.quarantine' not in wanted['xattrs']:
            continue
        def raw(path):
            length = libc.getxattr(os.fsencode(path), b'com.apple.quarantine', None, 0, 0, 1)
            if length < 0 or length > 65536:
                raise ValueError('Attribut de quarantaine illisible')
            data = ctypes.create_string_buffer(length)
            if libc.getxattr(os.fsencode(path), b'com.apple.quarantine', data, length, 0, 1) != length:
                raise ValueError('Attribut de quarantaine modifié')
            return data.raw
        original, copied = raw(Path(source)/key), raw(Path(target)/key)
        a, z = original.split(b';'), copied.split(b';')
        if (len(a) < 3 or len(a) != len(z) or a[0] != z[0] or a[2:] != z[2:] or
                hashlib.sha256(original).hexdigest() != wanted['xattrs']['com.apple.quarantine']):
            raise ValueError('Protection de quarantaine différente')
        if libc.setxattr(os.fsencode(Path(target)/key), b'com.apple.quarantine', original, len(original), 0, 1) != 0:
            raise OSError(ctypes.get_errno(), 'Restauration exacte de la quarantaine impossible')
    if inventory(target) != expected:
        raise ValueError('Copie native différente (contenu, liens, droits ou attributs)')


def snapshot(root, generation, destination):
    with r.locked(root):
        source = child(root, generation)
        output = child(root, destination, False)
        expected = inventory(source)
        signed = signature(source/APP)
        stage = Path(root)/('.bundle-snapshot-'+uuid.uuid4().hex)
        stage.mkdir()
        copy_verified(source, stage/'payload', expected)
        if signature(stage/'payload'/APP) != signed or inventory(source) != expected:
            raise ValueError('Source ou signature modifiée pendant sauvegarde')
        r.durable_json(stage/'manifest.json', {'format': FORMAT, 'entries': expected, 'signature': signed})
        sync_tree(stage)
        stage.rename(output)
        r.sync_dir(Path(root))
        return r.sha(output/'manifest.json')


def verify(root, archive, expected_sha):
    source = child(root, archive)
    r.regular(source/'manifest.json')
    r.regular(source/'payload', True)
    if set(p.name for p in source.iterdir()) != {'manifest.json', 'payload'}:
        raise ValueError('Archive incomplète ou inattendue')
    if r.sha(source/'manifest.json') != expected_sha:
        raise ValueError('Manifeste non authentifié par empreinte conservée')
    manifest = json.loads((source/'manifest.json').read_text())
    if manifest['format'] != FORMAT or inventory(source/'payload') != manifest['entries']:
        raise ValueError('Sauvegarde altérée ou incomplète')
    if signature(source/'payload'/APP) != manifest['signature']:
        raise ValueError('Signature différente')
    return source, manifest


def restore(root, archive, expected_sha, destination, *, before_commit=None):
    with r.locked(root):
        output = child(root, destination, False)
        source, manifest = verify(root, archive, expected_sha)
        stage = Path(root)/('.bundle-restore-'+uuid.uuid4().hex)
        copy_verified(source/'payload', stage, manifest['entries'])
        if signature(stage/APP) != manifest['signature']:
            raise ValueError('Signature restaurée différente')
        sync_tree(stage)
        if before_commit:
            before_commit()  # Fault injection used only by the recipe.
        stage.rename(output)
        r.sync_dir(Path(root))
        return output
