"""Offline checks for distribution integrity across the signing boundary."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

import sign_distribution_tools as signer


class DistributionIntegrityTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='abak-signing-test-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.app = self.base / 'Companion.app'
        self.root = self.app / 'Contents/Resources/DmpTools/arm64'
        for name, data in {'java/bin/java': b'\xcf\xfa\xed\xfejava',
                           'java/bin/java-cps': b'\xcf\xfa\xed\xfecps',
                           'vera/cli.jar': b'synthetic jar',
                           'NOTICE.txt': b'synthetic notice'}.items():
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        self.manifest = self.root / 'manifest.json'
        self.manifest.write_text(json.dumps({'protocol': 1, 'profile': 'PDF/A-1b', 'files': signer.inventory(self.root)}))
        (self.base / 'dmp_tools.lock.json').write_text(json.dumps({'arm64': {'vera': hashlib.sha256(b'synthetic jar').hexdigest()}}))
        self.patch = patch.object(signer, '__file__', str(self.base / 'sign_distribution_tools.py'))
        self.patch.start()
        self.addCleanup(self.patch.stop)

    def invoke(self, operation='--refresh'):
        with patch.object(sys, 'argv', ['signer', str(self.app), operation]):
            signer.main()

    def test_native_signature_change_refreshes_manifest(self):
        (self.root / 'java/bin/java').write_bytes(b'\xcf\xfa\xed\xfe signed')
        self.invoke()
        self.assertEqual(json.loads(self.manifest.read_text())['files'], signer.inventory(self.root))

    def test_license_modification_rejected(self):
        (self.root / 'NOTICE.txt').write_text('modified notice')
        with self.assertRaisesRegex(ValueError, 'Non-native resource'):
            self.invoke()

    def test_unpinned_jar_rejected(self):
        (self.root / 'vera/cli.jar').write_bytes(b'modified jar')
        with self.assertRaisesRegex(ValueError, 'Unpinned'):
            self.invoke()

    def test_missing_and_added_files_rejected(self):
        (self.root / 'unexpected').write_text('extra')
        with self.assertRaisesRegex(ValueError, 'inventory changed'):
            self.invoke()
        (self.root / 'unexpected').unlink()
        (self.root / 'java/bin/java-cps').unlink()
        with self.assertRaisesRegex(ValueError, 'Incomplete'):
            self.invoke()

    def test_symlinks_rejected(self):
        (self.root / 'link').symlink_to(self.root / 'NOTICE.txt')
        with self.assertRaisesRegex(ValueError, 'Symlink'):
            self.invoke()

    def test_signing_uses_developer_id_timestamp_and_preserves_permissions(self):
        with patch.object(signer.subprocess, 'run') as run:
            self.invoke('Developer ID Application: Synthetic')
            self.assertEqual(run.call_count, 2)
            for call in run.call_args_list:
                command = call.args[0]
                self.assertIn('--timestamp', command)
                self.assertIn('--preserve-metadata=entitlements', command)
            with self.assertRaisesRegex(ValueError, 'Developer ID'):
                self.invoke('Apple Development: Synthetic')


if __name__ == '__main__':
    unittest.main()
