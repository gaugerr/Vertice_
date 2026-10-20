const {expect} = require('@playwright/test');

async function openFlutter(page, url = '/') {
  await page.goto(url);
  const placeholder = page.locator('flt-semantics-placeholder');
  const backup = page.getByRole('button', {name: 'Backup e restauração'});
  await placeholder.or(backup).first().waitFor({state: 'attached'});
  if (await placeholder.count()) {
    // Flutter puts this control just outside the viewport for screen readers.
    await placeholder.evaluate(element => element.click());
  }
  await expect(backup).toBeVisible();
}

module.exports = {openFlutter};
