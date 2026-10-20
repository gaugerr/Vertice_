"""Precache the exact release, including local CanvasKit, fonts and SQLite."""
import hashlib
import json
from pathlib import Path

root = Path('build/web')
files = sorted(p for p in root.rglob('*') if p.is_file() and p.suffix not in ('.map', '.dart') and p.name not in ('service-worker.js', 'flutter_service_worker.js'))
digest = hashlib.sha256()
for path in files:
    digest.update(str(path.relative_to(root)).encode())
    digest.update(path.read_bytes())
version = digest.hexdigest()[:20]
urls = ['./' + str(path.relative_to(root)) for path in files]
urls.append('./')
prefix = f"const CACHE = 'vertice-shell-{version}';\nconst FILES = {json.dumps(urls)};\n"
worker = r"""
self.addEventListener('install', event => {
  event.waitUntil((async () => {
    try {
      const cache = await caches.open(CACHE);
      await cache.addAll(FILES.map(url => new Request(url, {cache: 'reload'})));
    } catch (error) {
      await caches.delete(CACHE);
      throw error;
    }
  })());
});
self.addEventListener('message', event => {
  if (event.data?.type === 'ACTIVATE_UPDATE') self.skipWaiting();
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (key.startsWith('vertice-shell-') && key !== CACHE) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.origin !== self.location.origin) return;
  // Connectivity checks must reach the network, even when the app is cached.
  if (url.pathname.endsWith('/online.txt')) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    if (event.request.mode === 'navigate') {
      return await cache.match('./index.html') || fetch(event.request);
    }
    const cached = await cache.match(event.request, {ignoreSearch: true});
    return cached || fetch(event.request);
  })());
});
"""
(root / 'service-worker.js').write_text(prefix + worker)
print(f'Offline release {version}: {len(files)} files')
