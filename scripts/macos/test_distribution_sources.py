"""Exercise source selection against real temporary Git indexes, without Flutter."""
from pathlib import Path
import subprocess
import tempfile
import unittest

from prepare_distribution import dependency_source_names, VITALE_B1_ADDITIONS


class DistributionSourceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='ABAK-distribution-sources-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git('init', '-q')

    def git(self, *args):
        return subprocess.check_output(['git', *args], cwd=self.root)

    def file(self, name, text='fixture', tracked=False):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        if tracked:
            self.git('add', '--', name)
        return path

    def vitale(self):
        for name in VITALE_B1_ADDITIONS:
            self.file(name)
        self.file('pubspec.yaml', 'name: abak_vitale\n', tracked=True)
        self.file('macos/abak_vitale/Package.swift', tracked=True)

    def test_deleted_generated_payload_is_excluded_and_new_sources_included(self):
        self.vitale()
        stale = self.file('runtime/macos/.gitkeep', tracked=True)
        stale.unlink()
        self.file('runtime/macos/usr/local/lib/old.dylib', tracked=True)
        self.file('runtime/macos_avant_prive_20261115/source.tmp', tracked=True)
        self.file('untracked_personal_notes.txt')
        # Use current modified working bytes, rather than the index version.
        self.file('macos/abak_vitale/Package.swift', 'modified source')
        names = dependency_source_names(self.root, 'abak_vitale')
        self.assertTrue(set(VITALE_B1_ADDITIONS).issubset(names))
        self.assertEqual(names, sorted(set(names)))
        self.assertFalse(any(name.startswith('runtime/macos/') for name in names))
        self.assertFalse(any('macos_avant_prive_' in name for name in names))
        self.assertNotIn('untracked_personal_notes.txt', names)
        self.assertEqual((self.root/'macos/abak_vitale/Package.swift').read_text(), 'modified source')

    def test_deleted_real_source_is_still_rejected(self):
        self.vitale()
        self.file('lib/real_source.dart', tracked=True).unlink()
        with self.assertRaisesRegex(RuntimeError, 'abak_vitale/lib/real_source.dart'):
            dependency_source_names(self.root, 'abak_vitale')

    def test_missing_b1_native_source_is_rejected(self):
        self.vitale()
        (self.root/VITALE_B1_ADDITIONS[0]).unlink()
        with self.assertRaisesRegex(RuntimeError, 'ABAKVitaleRuntime.m'):
            dependency_source_names(self.root, 'abak_vitale')

    def test_shared_dependency_keeps_its_tracked_files(self):
        self.file('lib/catalog.dart', tracked=True)
        self.file('runtime/macos/.gitkeep', tracked=True)
        self.file('private_notes.txt')
        self.assertEqual(dependency_source_names(self.root, 'abak_shared'),
                         ['lib/catalog.dart', 'runtime/macos/.gitkeep'])
        (self.root/'runtime/macos/.gitkeep').unlink()
        with self.assertRaisesRegex(RuntimeError, 'Dependency source missing'):
            dependency_source_names(self.root, 'abak_shared')


if __name__ == '__main__':
    unittest.main(verbosity=2)
