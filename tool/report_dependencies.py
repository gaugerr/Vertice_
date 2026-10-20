"""Record only public dependency manifests so reviewed builds can pin their locks."""
import json
from pathlib import Path

print('VERTICE_LOCKFILES=' + json.dumps({
    name: Path(name).read_text()
    for name in ('pubspec.lock', 'package-lock.json')
    if Path(name).is_file()
}))
