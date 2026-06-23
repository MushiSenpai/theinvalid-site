// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
  site: 'https://theinvalid.me',
  // Knowledge base now lives at /blog (case studies + the failure log + the
  // field guide). Case studies were merged in from the old standalone page.
  // Keep the old URLs alive so existing links / crawler indexes don't 404.
  redirects: {
    '/knowledge-base': '/blog',
    '/case-studies': '/blog#case-studies',
  },
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
