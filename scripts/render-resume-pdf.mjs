// Render the built /resume page to dist/resume.pdf with headless Chromium.
// Run AFTER `astro build`, BEFORE `wrangler deploy` — the freshly rendered PDF
// is then part of the deployed dist. Uses Astro's preview server to serve dist
// (so absolute asset paths resolve) and Playwright's print-media PDF.
//
// Requires: playwright (+ `npx playwright install chromium`). Intended for CI.

import { preview } from 'astro';
import { chromium } from 'playwright';

const server = await preview({ logLevel: 'warn' });
const host = !server.host || server.host === '::' || server.host === '0.0.0.0' ? 'localhost' : server.host;
const url = `http://${host}:${server.port}/resume`;

const browser = await chromium.launch();
try {
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  await page.pdf({
    path: 'dist/resume.pdf',
    format: 'A4',
    printBackground: false,
    margin: { top: '14mm', bottom: '14mm', left: '12mm', right: '12mm' },
  });
  console.log(`Wrote dist/resume.pdf from ${url}`);
} finally {
  await browser.close();
  await server.stop();
}
