window.verticeOfflineReady = false;
window.verticeUpdateReady = false;
window.verticeInstallReady = false;
window.verticeOnline = navigator.onLine;
const changed = () => window.dispatchEvent(new Event('vertice-pwa-changed'));
let connectivityRequest;
async function checkConnectivity() {
  connectivityRequest?.abort();
  const request = new AbortController();
  connectivityRequest = request;
  const timeout = setTimeout(() => request.abort(), 4000);
  let online = false;
  try {
    const url = new URL('online.txt', document.baseURI);
    url.searchParams.set('t', Date.now());
    online = (await fetch(url, {cache: 'no-store', signal: request.signal})).ok;
  } catch (_) { /* Offline is a normal state. All data stays local. */ }
  finally { clearTimeout(timeout); }
  if (connectivityRequest !== request) return;
  if (window.verticeOnline !== online) {
    window.verticeOnline = online;
    changed();
  }
}
window.addEventListener('offline', () => { window.verticeOnline = false; changed(); });
window.addEventListener('online', checkConnectivity);
window.addEventListener('focus', checkConnectivity);
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') checkConnectivity();
});
setInterval(() => {
  if (document.visibilityState === 'visible') checkConnectivity();
}, 60000);
checkConnectivity();
let registration;
let installPrompt;
let reloading = false;

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  installPrompt = event;
  window.verticeInstallReady = true;
  changed();
});
window.addEventListener('appinstalled', () => {
  installPrompt = null;
  window.verticeInstallReady = false;
  changed();
});
window.verticeInstall = async () => {
  if (!installPrompt) return;
  await installPrompt.prompt();
  await installPrompt.userChoice;
  installPrompt = null;
  window.verticeInstallReady = false;
  changed();
};
window.verticeApplyUpdate = () => registration?.waiting?.postMessage({type: 'ACTIVATE_UPDATE'});

if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      registration = await navigator.serviceWorker.register('service-worker.js', {updateViaCache: 'none'});
      const markReady = () => { window.verticeOfflineReady = true; changed(); };
      if (registration.active) markReady();
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        if (window.verticeUpdateReady && !reloading) {
          reloading = true;
          window.location.reload();
        } else { markReady(); }
      });
      const markUpdate = () => {
        if (registration.waiting && registration.active) {
          window.verticeUpdateReady = true;
          changed();
        }
      };
      markUpdate();
      registration.addEventListener('updatefound', () => {
        const worker = registration.installing;
        worker?.addEventListener('statechange', () => {
          if (worker.state === 'activated') markReady();
          if (worker.state === 'installed') markUpdate();
        });
      });
      navigator.serviceWorker.ready.then(markReady);
      // Ask for durable storage; browsers may decline. Backups remain essential.
      navigator.storage?.persist?.().catch(() => {});
    } catch (error) {
      console.warn('Não foi possível preparar o uso offline.', error);
    }
  });
}
