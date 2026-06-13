// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://theinvalid.me',
  integrations: [
    sitemap({
      // lastmod = build time. Every deploy (incl. each scheduled blog post)
      // refreshes it, so crawlers see the site as updated and re-fetch.
      serialize(item) {
        item.lastmod = new Date().toISOString();
        item.changefreq = item.url.includes('/blog/') ? 'weekly' : 'monthly';
        return item;
      },
    }),
  ],
});
