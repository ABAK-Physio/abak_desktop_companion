"""Reuse exact package-pinned SQLite binaries already present in the local cache."""
import hashlib
import json
from pathlib import Path
import re
import shutil
from urllib.parse import urljoin, urlparse, unquote

repo = Path(__file__).resolve().parents[2]
config = repo / '.dart_tool/package_config.json'
package = next(p for p in json.loads(config.read_text())['packages'] if p['name'] == 'sqlite3')
package_root = Path(unquote(urlparse(urljoin(config.as_uri(), package['rootUri'])).path))
hashes = (package_root / 'lib/src/hook/asset_hashes.dart').read_text()
cache = repo / '.dart_tool/hooks_runner/shared/sqlite3/build'
out = repo / '.dart_tool/abak_offline_sqlite'
out.mkdir(exist_ok=True)
found = {}
for arch in ('arm64', 'x64'):
    name = f'libsqlite3.{arch}.macos.dylib'
    match = re.search(re.escape("'" + name + "': '") + r"([0-9a-f]{64})'", hashes)
    if not match:
        raise SystemExit(f'Empreinte officielle absente : {name}')
    expected = match[1]
    source = next((p for p in cache.glob('*/libsqlite3.dylib') if hashlib.sha256(p.read_bytes()).hexdigest() == expected), None)
    if source is None:
        raise SystemExit(f'Bibliothèque exacte absente du cache : {name}. Aucun téléchargement autorisé.')
    shutil.copyfile(source, out / name)
    found[name] = expected
print(json.dumps(found, indent=2))
