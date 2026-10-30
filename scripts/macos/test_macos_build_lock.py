"""Exercise the build lock without compiling, signing or installing anything."""
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import unittest

from macos_build_lock import LOCK_FD_ENV, lock_path

SCRIPTS = Path(__file__).resolve().parent
ENTRIES = (
    'compile_macos_local_only.sh',
    'build_macos_notarized.sh',
    'build_macos_release_local.sh',
    'build_macos_release_local_offline.sh',
)


class BuildLockTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='abak-lock-test-')
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / 'repo with spaces'
        self.scripts = self.repo / 'scripts/macos'
        self.scripts.mkdir(parents=True)
        for name in (*ENTRIES, 'macos_build_lock.py'):
            shutil.copy2(SCRIPTS / name, self.scripts / name)
        self.helper = self.scripts / 'macos_build_lock.py'
        self.env = dict(os.environ)
        self.env.pop(LOCK_FD_ENV, None)

    def run_locked(self, *command, env=None):
        return subprocess.run([sys.executable, str(self.helper), *command],
                              env=self.env if env is None else env,
                              capture_output=True, text=True, timeout=10)

    def hold_lock(self, nested=False):
        code = 'import sys; print("ready", flush=True); sys.stdin.read()'
        if nested:
            code = ('import subprocess, sys; '
                    'subprocess.run([sys.executable, sys.argv[1], "--held"], '
                    'close_fds=False, check=True); '
                    'print("ready", flush=True); sys.stdin.read()')
        process = subprocess.Popen(
            [sys.executable, str(self.helper), sys.executable, '-c',
             code, str(self.helper)],
            env=self.env, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, text=True)
        def cleanup():
            if process.poll() is None:
                process.kill()
            process.communicate(timeout=10)
        self.addCleanup(cleanup)
        import select
        self.assertTrue(select.select([process.stdout], [], [], 10)[0])
        self.assertEqual(process.stdout.readline().strip(), 'ready')
        return process

    def test_all_real_entrypoints_refuse_before_any_preparation(self):
        self.hold_lock()
        before = sorted(p.relative_to(self.repo) for p in self.repo.rglob('*'))
        for name in ENTRIES:
            with self.subTest(script=name):
                result = subprocess.run(['/bin/zsh', str(self.scripts / name)],
                                        env=self.env, capture_output=True,
                                        text=True, timeout=10)
                self.assertEqual(result.returncode, 75, result.stderr)
                self.assertIn('déjà en cours', result.stderr)
        self.assertEqual(before, sorted(p.relative_to(self.repo) for p in self.repo.rglob('*')))

    def test_exit_codes_and_release_after_success_or_error(self):
        for code in (0, 23, 0):
            result = self.run_locked(sys.executable, '-c', f'raise SystemExit({code})')
            self.assertEqual(result.returncode, code, result.stderr)

    def test_release_after_termination(self):
        for sig in (signal.SIGTERM, signal.SIGKILL):
            with self.subTest(signal=sig):
                process = self.hold_lock()
                process.send_signal(sig)
                process.communicate(timeout=10)
                result = self.run_locked('/usr/bin/true')
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_nested_shell_guards_and_sandbox_inherit_lock(self):
        # Use the exact production guards with harmless bodies in a temp repo.
        for name in ENTRIES:
            p = self.scripts / name
            prefix = p.read_text().split('\nfi\n', 1)[0] + '\nfi\n'
            p.write_text(prefix + '\nexec "$@"\n')
        command = ['/usr/bin/python3', str(self.helper), '--held']
        for name in ENTRIES:
            command = ['/bin/zsh', str(self.scripts / name), *command]
        command = ['/usr/bin/sandbox-exec', '-p',
                   '(version 1)(allow default)(deny network*)', *command]
        result = self.run_locked(*command)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_nested_process_cannot_release_parent_lock(self):
        self.hold_lock(nested=True)
        result = self.run_locked('/usr/bin/true')
        self.assertEqual(result.returncode, 75)
        result = self.run_locked('/usr/bin/true')
        self.assertEqual(result.returncode, 75)

    def test_invalid_inherited_descriptor_does_not_bypass_lock(self):
        self.hold_lock()
        for value in ('invalid', '-1', '99999', '1'):
            result = self.run_locked('/usr/bin/true', env=dict(self.env, **{LOCK_FD_ENV: value}))
            self.assertEqual(result.returncode, 75, result.stderr)

    def test_stale_file_and_different_tmpdir_do_not_change_lock(self):
        lock_path(self.repo).touch(exist_ok=True)
        result = self.run_locked('/usr/bin/true')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.hold_lock()
        result = self.run_locked('/usr/bin/true', env=dict(self.env, TMPDIR=self.temp.name))
        self.assertEqual(result.returncode, 75)

    def test_canonical_repo_identity(self):
        alias = Path(self.temp.name) / 'alias'
        alias.symlink_to(self.repo, target_is_directory=True)
        self.assertEqual(lock_path(alias), lock_path(self.repo))
        self.assertNotEqual(lock_path(self.repo), lock_path(self.repo / 'another-repo'))
        self.hold_lock()
        result = subprocess.run([sys.executable, str(alias / 'scripts/macos/macos_build_lock.py'),
                                 '/usr/bin/true'], env=self.env, capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 75)


if __name__ == '__main__':
    unittest.main()
