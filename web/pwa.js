window.verticeOfflineReady = false;
window.verticeUpdateReady = false;
window.verticeInstallReady = false;
const changed = () => window.dispatchEvent(new Event('vertice-pwa-changed'));
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
