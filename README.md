# theinvalid.me

> They called me invalid; this is me.

Portfolio + engineering **failure log** for a sovereign AI stack built and run on
one RTX 5090 — LLM serving, creative/audio/3D pipelines, and the write-ups of
everything that broke on the way. The site is the honest record: benchmarks
include the losses, case studies include the dead ends.

**Live: [theinvalid.me](https://theinvalid.me)**

## What this repo is

- **Astro 6, content-as-files, zero JS frameworks, system fonts only.** Posts and
  project pages are markdown in `src/content/`; the build is fully static and
  the performance is the flex (100/100 Lighthouse).
- **Deploy = push to `main`.** Cloudflare rebuilds and ships in about a minute.
- **One accent color.** If a design needs a second one, the design is wrong.

## Map

| Path | What lives there |
|---|---|
| `src/content/blog/` | posts + case studies (failure logs included) |
| `src/content/projects/` | project pages — the stacks, apps, and experiments |
| `src/pages/` | routes: index, blog, projects, services, resume |
| `public/` | static assets + standalone catalogue pages |
| `pipeline/` | editorial queue + publishing checklist |

## House rules

Content follows the same rules the projects are built with: measured numbers
over adjectives, failures named next to wins, and nothing published that can't
be traced back to an artifact that actually ran.
