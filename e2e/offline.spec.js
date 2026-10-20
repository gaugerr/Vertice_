const {test, expect} = require('@playwright/test');
const fs = require('node:fs/promises');

function visibleText(page, value) {
  return page.getByText(value, {exact: true})
    .or(page.locator(`[aria-label*=${JSON.stringify(value)}]`)).first();
}

const sample = {
  format: 'vertice-backup', version: 1,
  lists: [{id: 1, storeName: 'Mercado offline', date: 1792454400000, description: 'Teste PWA'}],
  categories: [{id: 1, title: 'Essenciais', shoppingListId: 1}],
  items: [{id: 1, name: 'Arroz', price: 20, quantity: 0.5, unit: 'kg', isPurchased: 1, categoryId: 1, shoppingListId: 1}],
};

test('installable shell, backup, CRUD and persistence with the network disabled', async ({page, context}) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/');
  await expect(page.getByRole('button', {name: 'Backup e restauração'})).toBeVisible();
  await page.getByRole('button', {name: 'Backup e restauração'}).click();
  await page.getByRole('textbox', {name: 'Conteúdo do backup'}).fill(JSON.stringify(sample));
  await page.getByRole('button', {name: 'Restaurar', exact: true}).click();
  await page.getByRole('button', {name: 'Substituir', exact: true}).click();
  await expect(page.getByText('Backup restaurado.', {exact: true})).toBeVisible();
  await page.getByRole('button', {name: 'Fechar', exact: true}).click();

  await page.locator('[flt-semantics-identifier="list-1"]').click();
  await page.locator('[flt-semantics-identifier="category-1"]').click();
  await expect(page.getByText('Total: R$ 10.00', {exact: true}).first()).toBeVisible();
  await page.getByRole('textbox', {name: 'Quantity', exact: true}).fill('2');
  await page.getByRole('textbox', {name: 'Quantity', exact: true}).press('Enter');
  await expect(page.getByText('Total: R$ 40.00', {exact: true}).first()).toBeVisible();

  await page.waitForFunction(() => window.verticeOfflineReady === true && !!navigator.serviceWorker.controller);
  await expect.poll(() => page.evaluate(() => window.verticeOnline)).toBe(true);
  await context.setOffline(true);
  await page.getByRole('textbox', {name: 'Adicionar item', exact: true}).click();
  await page.keyboard.insertText('Feijão offline');
  await page.getByRole('button', {name: 'Adicionar item', exact: true}).click();
  await expect(visibleText(page, 'Feijão offline')).toBeVisible();
  await page.close();
  const reopened = await context.newPage();
  await context.setOffline(true);
  reopened.on('pageerror', error => errors.push(error.message));
  await reopened.goto('/');
  expect(await reopened.evaluate(() => fetch('/online.txt?check=offline', {cache: 'no-store'}).then(() => true, () => false))).toBe(false);
  await expect(visibleText(reopened, 'Offline · dados salvos neste aparelho')).toBeVisible();
  await reopened.locator('[flt-semantics-identifier="list-1"]').click();
  await reopened.locator('[flt-semantics-identifier="category-1"]').click();
  await expect(visibleText(reopened, 'Feijão offline')).toBeVisible();
  await expect(reopened.getByRole('textbox', {name: 'Quantity', exact: true})).toHaveValue('2.0');
  await expect(reopened.getByText('Total: R$ 40.00', {exact: true}).first()).toBeVisible();

  // A reload at the home screen also stays offline. Export verifies the actual persisted rows.
  await reopened.reload();
  await reopened.getByRole('button', {name: 'Backup e restauração'}).click();
  const downloaded = reopened.waitForEvent('download');
  await reopened.getByRole('button', {name: 'Baixar backup', exact: true}).click();
  const file = await downloaded;
  const exported = JSON.parse(await fs.readFile(await file.path(), 'utf8'));
  expect(exported.items).toHaveLength(2);
  expect(exported.items.find(item => item.name === 'Arroz').quantity).toBe(2);
  expect(errors).toEqual([]);
});

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
