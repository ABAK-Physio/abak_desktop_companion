"""Compile the production resolver without launching Companion or opening user files.

Run: python3 scripts/macos/test_user_documents_directory.py
The container regression uses CFFIXED_USER_HOME to reproduce Foundation's
home-directory redirection in a fresh native process, using temporary folders.
"""
import json
import os
from pathlib import Path
import pwd
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
HARNESS = r'''import Foundation
import Darwin

let resolved = try UserDocumentsDirectory.resolve().path
let injected = CommandLine.arguments[1]
var invalidRejected = true
for invalid in ["", "relative/home", "/", "bad\0path"] {
  do { _ = try UserDocumentsDirectory.resolve(accountHome: { invalid }); invalidRejected = false }
  catch { }
}
var lookupFailurePropagated = false
do {
  _ = try UserDocumentsDirectory.resolve(accountHome: {
    throw NSError(domain: NSPOSIXErrorDomain, code: Int(ENOENT))
  })
} catch { lookupFailurePropagated = true }
let data: [String: Any] = [
  "resolved": resolved,
  "foundation": FileManager.default.homeDirectory(forUser: NSUserName())!.path,
  "injected": try UserDocumentsDirectory.resolve(accountHome: { injected }).path,
  "invalidRejected": invalidRejected,
  "lookupFailurePropagated": lookupFailurePropagated
]
print(String(data: try JSONSerialization.data(withJSONObject: data), encoding: .utf8)!)
'''

class UserDocumentsDirectoryTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix="abak-m1-resolver-")
        cls.addClassCleanup(cls.temp.cleanup)
        cls.root = Path(cls.temp.name)
        main = cls.root / "main.swift"
        main.write_text(HARNESS)
        cls.binary = cls.root / "resolver"
        subprocess.run(["xcrun", "swiftc", "-module-cache-path", str(cls.root / "cache"),
                        str(ROOT / "macos/Runner/UserDocumentsDirectory.swift"),
                        str(main), "-o", str(cls.binary)], check=True, capture_output=True, text=True)

    def resolve(self, container=False):
        env = dict(os.environ)
        env.pop("CFFIXED_USER_HOME", None)
        if container:
            path = self.root / "Library/Containers/test.companion/Data"
            path.mkdir(parents=True, exist_ok=True)
            env["HOME"] = str(path)
            env["CFFIXED_USER_HOME"] = str(path)
        result = subprocess.run([str(self.binary), str(self.root / "other account")],
                                env=env, check=True, capture_output=True, text=True)
        return json.loads(result.stdout)

    def test_current_uid_uses_account_database(self):
        self.assertEqual(self.resolve()["resolved"], str(Path(pwd.getpwuid(os.getuid()).pw_dir) / "Documents"))

    def test_sandbox_foundation_redirection_is_not_used(self):
        data = self.resolve(container=True)
        container = str(self.root / "Library/Containers/test.companion/Data")
        # This assertion ensures the old resolver really fails in this fixture.
        self.assertEqual(data["foundation"], container)
        self.assertEqual(data["resolved"], str(Path(pwd.getpwuid(os.getuid()).pw_dir) / "Documents"))
        self.assertNotEqual(data["resolved"], str(Path(container) / "Documents"))
        self.assertFalse((Path(container) / "Documents").exists())

    def test_nonstandard_account_home_and_spaces(self):
        data = self.resolve()
        self.assertEqual(data["injected"], str(self.root / "other account/Documents"))
        self.assertFalse((self.root / "other account").exists())

    def test_invalid_account_home_is_rejected(self):
        self.assertTrue(self.resolve(container=True)["invalidRejected"])

    def test_failed_lookup_does_not_fall_back_to_container(self):
        self.assertTrue(self.resolve(container=True)["lookupFailurePropagated"])

if __name__ == "__main__":
    unittest.main(verbosity=2)
