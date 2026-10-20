const {test, expect} = require('@playwright/test');
const fs = require('node:fs/promises');
const {openFlutter} = require('./flutter_helpers');

function visibleText(page, value) {
  return page.getByText(value, {exact: true})
    .or(page.locator(`[aria-label*=${JSON.stringify(value)}]`)).first();
}

// Flutter activates its DOM editing element on a semantics frame after focus.
// Wait for that handoff, then for the controller update before submitting.
async function settleFlutter(page) {
  await page.evaluate(() => new Promise(resolve => {
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
  }));
}
async function fillFlutterField(page, field, value) {
  await field.click();
  await expect(field).toBeFocused();
  await settleFlutter(page);
  await field.fill(value);
  await settleFlutter(page);
  await expect(field).toHaveValue(value);
}

const sample = {
  format: 'vertice-backup', version: 1,
  lists: [{id: 1, storeName: 'Mercado offline', date: 1792454400000, description: 'Teste PWA'}],
  categories: [{id: 1, title: 'Essenciais', shoppingListId: 1}],
  items: [{id: 1, name: 'Arroz', price: 20, quantity: 0.5, unit: 'kg', isPurchased: 1, categoryId: 1, shoppingListId: 1}],
};

for (const renderer of ['auto', 'canvaskit']) {
test(`installable shell and persistence offline (${renderer})`, async ({page, context}) => {
  const appPath = renderer === 'canvaskit' ? '/?renderer=canvaskit' : '/';
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await openFlutter(page, appPath);
  const assets = await page.evaluate(() => performance.getEntriesByType('resource').map(r => r.name));
  expect(assets.some(url => url.includes(renderer === 'auto' ? 'main.dart.wasm' : 'main.dart.js'))).toBe(true);
  await expect(page.getByRole('button', {name: 'Backup e restauração'})).toBeVisible();
  await page.getByRole('button', {name: 'Backup e restauração'}).click();
  await fillFlutterField(page, page.getByRole('textbox', {name: 'Conteúdo do backup'}), JSON.stringify(sample));
  await page.getByRole('button', {name: 'Restaurar', exact: true}).click();
  await page.getByRole('button', {name: 'Substituir', exact: true}).click();
  await expect(page.getByText('Backup restaurado.', {exact: true})).toBeVisible();
  await page.getByRole('button', {name: 'Fechar', exact: true}).click();

  await page.locator('[flt-semantics-identifier="list-1"]').click();
  await page.locator('[flt-semantics-identifier="category-1"]').click();
  await expect(page.getByText('Total: R$ 10.00', {exact: true}).first()).toBeVisible();
  await fillFlutterField(page, page.getByRole('textbox', {name: 'Quantity', exact: true}), '2');
  await page.getByRole('textbox', {name: 'Quantity', exact: true}).press('Enter');
  await expect(page.getByText('Total: R$ 40.00', {exact: true}).first()).toBeVisible();

  await page.waitForFunction(() => window.verticeOfflineReady === true && !!navigator.serviceWorker.controller);
  await expect.poll(() => page.evaluate(() => window.verticeOnline)).toBe(true);
  await context.setOffline(true);
  await fillFlutterField(page, page.getByRole('textbox', {name: 'Adicionar item', exact: true}), 'Feijão offline');
  await page.getByRole('button', {name: 'Adicionar item', exact: true}).click();
  await expect(visibleText(page, 'Feijão offline')).toBeVisible();
  await page.close();
  const reopened = await context.newPage();
  await context.setOffline(true);
  reopened.on('pageerror', error => errors.push(error.message));
  await openFlutter(reopened, appPath);
  expect(await reopened.evaluate(() => fetch('/online.txt?check=offline', {cache: 'no-store'}).then(() => true, () => false))).toBe(false);
  await expect(visibleText(reopened, 'Offline · dados salvos neste aparelho')).toBeVisible();
  await reopened.locator('[flt-semantics-identifier="list-1"]').click();
  await reopened.locator('[flt-semantics-identifier="category-1"]').click();
  await expect(visibleText(reopened, 'Feijão offline')).toBeVisible();
  // Flutter's inactive semantics input is a proxy, not the editing controller.
  // Check the displayed total here and the actual persisted quantity in the exported backup below.
  await expect(reopened.getByText('Total: R$ 40.00', {exact: true}).first()).toBeVisible();

  // A reload at the home screen also stays offline. Export verifies the actual persisted rows.
  await openFlutter(reopened, appPath);
  await reopened.getByRole('button', {name: 'Backup e restauração'}).click();
  const downloaded = reopened.waitForEvent('download');
  await reopened.getByRole('button', {name: 'Baixar backup', exact: true}).click();
  const file = await downloaded;
  const exported = JSON.parse(await fs.readFile(await file.path(), 'utf8'));
  expect(exported.items).toHaveLength(2);
  expect(exported.items.find(item => item.name === 'Arroz').quantity).toBe(2);
  expect(errors).toEqual([]);
});
}

// Keep accessible DOM diagnostics in CI when a browser check fails.
test.afterEach(async ({context}, info) => {
  if (info.status === info.expectedStatus) return;
  const current = context.pages().at(-1);
  if (!current) return;
  console.log('SEMANTICS:', JSON.stringify(await current.locator('flt-semantics,input,textarea').evaluateAll(nodes => nodes.map(node => ({
    tag: node.tagName, role: node.getAttribute('role'), label: node.getAttribute('aria-label'),
    identifier: node.getAttribute('flt-semantics-identifier'), value: node.value, text: node.textContent?.slice(0, 120),
  })))));
});
