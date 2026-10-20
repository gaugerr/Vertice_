const {test, expect} = require('@playwright/test');
const {openFlutter} = require('./flutter_helpers');

// Relative CPU comparison only: CI has no physical phone GPU.
// Both versions use accessibility so controls can be measured consistently.
test('compare published and candidate UI under CPU pressure', async ({browser}, info) => {
  test.skip(!process.env.VERTICE_PERF_BASELINE, 'Set a published baseline URL to compare');
  test.setTimeout(240000);
  const samples = [];
  for (const [label, url] of [
    ['published', process.env.VERTICE_PERF_BASELINE],
    ['candidate', 'http://127.0.0.1:8080'],
  ]) {
    const context = await browser.newContext({
      viewport: {width: 412, height: 915}, deviceScaleFactor: 3,
      serviceWorkers: 'allow',
    });
    const page = await context.newPage();
    const cdp = await context.newCDPSession(page);
    await cdp.send('Emulation.setCPUThrottlingRate', {rate: 4});
    const started = Date.now();
    await openFlutter(page, url);
    const readyMs = Date.now() - started;
    const sample = {
      format: 'vertice-backup', version: 1,
      lists: [{id: 1, storeName: 'Performance', date: 1792454400000, description: 'Temporary browser context'}],
      categories: [{id: 1, title: 'Performance', shoppingListId: 1}],
      items: Array.from({length: 100}, (_, i) => ({
        id: i + 1, name: `Item ${i + 1}`, price: 5, quantity: 1,
        unit: 'un', isPurchased: 0, categoryId: 1, shoppingListId: 1,
      })),
    };
    await page.getByRole('button', {name: 'Backup e restauração'}).click();
    const field = page.getByRole('textbox', {name: 'Conteúdo do backup'});
    await field.click();
    await page.evaluate(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))));
    await field.fill(JSON.stringify(sample));
    await page.evaluate(() => new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r))));
    await page.getByRole('button', {name: 'Restaurar', exact: true}).click();
    await page.getByRole('button', {name: 'Substituir', exact: true}).click();
    await expect(page.getByText('Backup restaurado.', {exact: true})).toBeVisible();
    await page.getByRole('button', {name: 'Fechar', exact: true}).click();
    await page.locator('[flt-semantics-identifier="list-1"]').click();
    await page.locator('[flt-semantics-identifier="category-1"]').click();
    await expect(page.getByRole('textbox', {name: 'Adicionar item', exact: true})).toBeVisible();
    await page.waitForFunction(() => window.verticeOfflineReady === true);

    // Measure warm interaction round trips; exclude navigation/download time.
    const togglesMs = [];
    for (let i = 0; i < 8; i++) {
      const checkbox = page.getByRole('checkbox').first();
      const before = await checkbox.isChecked();
      const start = Date.now();
      await checkbox.click();
      if (before) await expect(checkbox).not.toBeChecked();
      else await expect(checkbox).toBeChecked();
      togglesMs.push(Date.now() - start);
    }

    await page.evaluate(() => {
      window.verticeFrames = [];
      window.verticeMeasureFrames = true;
      let previous;
      function frame(t) {
        if (previous !== undefined) window.verticeFrames.push(t - previous);
        previous = t;
        if (window.verticeMeasureFrames) requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    });
    await cdp.send('Input.synthesizeScrollGesture', {
      x: 200, y: 650, yDistance: -1200, speed: 500, gestureSourceType: 'mouse',
    });
    const rendering = await page.evaluate(() => {
      window.verticeMeasureFrames = false;
      const frames = window.verticeFrames.sort((a, b) => a - b);
      const assets = performance.getEntriesByType('resource').map(r => r.name);
      return {
        frameP95Ms: frames[Math.floor(frames.length * .95)] ?? null,
        framesOver50Ms: frames.filter(t => t > 50).length,
        frameCount: frames.length,
        wasm: assets.some(url => url.includes('main.dart.wasm')),
        skwasm: assets.some(url => /skwasm.*\.wasm/.test(url)),
        crossOriginIsolated,
      };
    });
    if (label === 'candidate') {
      expect(rendering.wasm).toBe(true);
      expect(rendering.skwasm).toBe(true);
      expect(rendering.crossOriginIsolated).toBe(true);
    }
    togglesMs.sort((a, b) => a - b);
    samples.push({label, readyMs, toggleMedianMs: togglesMs[4], togglesMs, ...rendering});
    await context.close();
  }
  console.log('PERFORMANCE_COMPARISON', JSON.stringify(samples));
  await info.attach('performance-comparison', {
    body: JSON.stringify(samples, null, 2), contentType: 'application/json',
  });
});
