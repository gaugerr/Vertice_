const {defineConfig} = require('@playwright/test');
module.exports = defineConfig({
  testDir: './e2e',
  timeout: 180000,
  expect: {timeout: 20000},
  workers: 1,
  reporter: [['list'], ['html', {open: 'never'}]],
  use: {actionTimeout: 20000, baseURL: 'http://127.0.0.1:8080', viewport: {width: 412, height: 915}, serviceWorkers: 'allow', screenshot: 'only-on-failure', trace: 'retain-on-failure'},
  webServer: {command: 'python3 tool/serve_web.py', url: 'http://127.0.0.1:8080', reuseExistingServer: false},
});
