"""Shared macOS build lock, inherited by nested build scripts.

The lock lives outside build/ and .dart_tool/ so cleaning cannot remove it.
Never unlink it: the kernel releases flock when the last inherited fd closes.
Direct IDE/Flutter builds do not participate in this script-level lock.
"""
import fcntl
import hashlib
import os
from pathlib import Path
import stat
import sys

REPO = Path(__file__).resolve().parents[2]
LOCK_FD_ENV = 'ABAK_MACOS_BUILD_LOCK_FD'


def lock_path(repo):
    identity = hashlib.sha256(os.fsencode(Path(repo).resolve())).hexdigest()
    return Path('/tmp') / f'abak-macos-build-{os.getuid()}-{identity}.lock'


def inherited_lock(repo):
    try:
        fd = int(os.environ[LOCK_FD_ENV])
        info = os.fstat(fd)
        expected = lock_path(repo).stat()
        if (info.st_dev, info.st_ino) != (expected.st_dev, expected.st_ino):
            return None
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid():
            return None
        # flock on the inherited open file description is reentrant.
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return fd
    except (KeyError, ValueError, OSError):
        return None


def acquire_lock(repo):
    fd = inherited_lock(repo)
    if fd is not None:
        return fd
    fd = os.open(lock_path(repo), os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    try:
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid():
            raise RuntimeError('Fichier de verrou de compilation non valide')
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        os.close(fd)
        print('Compilation macOS déjà en cours pour ce dépôt. '
              'Attendez sa fin avant de relancer ce script.', file=sys.stderr)
        raise SystemExit(75)
    except BaseException:
        os.close(fd)
        raise
    os.set_inheritable(fd, True)
    os.environ[LOCK_FD_ENV] = str(fd)
    return fd


def main():
    if sys.argv[1:] == ['--held']:
        return 0 if inherited_lock(REPO) is not None else 1
    if len(sys.argv) < 2:
        print('Usage: macos_build_lock.py COMMANDE [ARGUMENTS...]', file=sys.stderr)
        return 2
    acquire_lock(REPO)
    # Replace this process: preserve exit codes, signals and inherited lock.
    os.execvpe(sys.argv[1], sys.argv[1:], os.environ)


if __name__ == '__main__':
    sys.exit(main())
