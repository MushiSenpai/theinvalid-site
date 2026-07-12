# theinvalid.me — Decisions, Architecture & Playbook

Reference document: every decision behind this site, why it was made, and how
to operate it. Written 2026-06-11, the day the site was built. Shareable —
if you want a site like this, everything you need is here.

---

## 1. Purpose & audience

A job-seeker's portfolio + engineering blog. The audience is hiring managers
and potential freelance clients who decide in a 20-second skim, often on a
phone. Every decision below optimizes for that reader — not for design awards.

## 2. The name

`theinvalid.me` — the owner was once called "invalid"; the domain reclaims it.
Hero tagline: terminal prompt `$ they called me invalid_` answered by
**"This is me."** For an infrastructure engineer, "invalid" also carries the
technical double meaning (what systems call rejected input) — the site is the
counter-evidence.

## 3. Design philosophy — why NOT a 3D animated showpiece

Considered and rejected: the $10k-look 3D/scroll-animated portfolio trend.
Reasons, in order:

1. **Audience mismatch.** Flashy sites sell to people buying *websites*. This
   site's buyers evaluate infrastructure skill; heavy frontends read as
   style-over-substance to them.
2. **Brand contradiction.** The owner's public positioning is radical honesty
   about not being a frontend developer. A vibe-coded imitation of a 3D
   showpiece quietly undermines that.
3. **Performance IS the flex.** For an infra engineer, a 100/100 Lighthouse
   score, instant load, zero JS frameworks, and system fonts *are* the
   demonstration of competence.

Distinctiveness comes from craft instead: dark terminal-inflected palette
(bg `#0b0e14`, warm off-white text, one **lantern-gold accent `#e8a33d`**),
monospace flourishes, honest status badges, and signature content (the
"failure log" framing) no template has. Full brand/visual-identity spec — logo,
wordmark, favicon, tokens, usage rules — in **§10**.

## 4. Stack & hosting decisions

| Decision | Choice | Why | Rejected alternative |
|---|---|---|---|
| Generator | **Astro 6** (static output) | Content collections = site generates itself from markdown files; zero client JS by default | Hugo (fine, weaker content typing); Next.js (overkill, JS-heavy) |
| Hosting | **Cloudflare Pages** (free) | Global edge (fast from anywhere incl. SG), auto-HTTPS, `git push` = deploy in ~60s, zero servers to patch | Caddy on a VPS (works, but a server to maintain for a static site is pure liability) |
| Domain | Porkbun (purchase) + **Cloudflare DNS** (free) | Buy at promo registrars; manage DNS where the hosting is; never bundle registrar hosting | — |
| Repo | Public on GitHub | The site's source is itself portfolio evidence | Private (no upside) |
| Fonts | System stacks only | Zero font download, instant text render | Webfonts (100-300KB for marginal gain) |
| Analytics | None (Cloudflare's edge stats suffice) | No cookie banner needed, on-brand ("no trackers") | GA etc. |

**Running cost: $0/month** beyond the domain (~US$18/yr renewal for .me).

## 5. Architecture — content as files

```
src/
├── content.config.ts        # zod schemas for both collections
├── content/
│   ├── projects/*.md         # ONE file per project (frontmatter: title,
│   │                         #   oneliner, status, repo, stack[], started, order)
│   ├── blog/*.md             # ONE file per post (title, description, date,
│   │                         #   project?, tags[])
│   └── resume.md             # canonical resume (rendered at /resume)
├── layouts/Base.astro        # head/nav/footer, the only layout
├── styles/global.css         # all design tokens, ~200 lines, no framework
├── lib/github.js             # build-time repo status (fail-soft) → "updated X ago"
└── pages/
    ├── index.astro           # hero + CTA row + Latest work (3 newest by `started`)
    │                         #   + compact earlier-builds rows + self-hosting strip
    │                         #   + latest posts + contact band (since 2026-07-12)
    ├── start-here.astro      # plain-English intro (non-technical buyers)
    ├── services.astro        # "Work with me" — the offer, pricing, contact
    ├── projects/index.astro  # all projects, status-badged + "updated X ago"
    ├── projects/[slug].astro # project detail + auto-attached related posts
    ├── blog/index.astro      # "Knowledge base" — case studies + failure log + field guide
    ├── blog/[slug].astro     # post detail
    ├── blog/topics.astro     # posts grouped by topic
    ├── calculator.astro      # "Field guide" — VRAM/fit/tier/concurrency + cloud-vs-local
    ├── resume.astro          # content/resume.md + live project list + dated download
    └── rss.xml.js            # RSS feed
public/resume.md              # downloadable copy — keep in sync with content/resume.md
.github/workflows/scheduled-rebuild.yml  # daily redeploy → fresh GitHub-status snapshot
```

**Key property:** pages are *generated from* the content folders. Statuses
(`building` / `shipped` / `parked`) drive the homepage sections automatically.
Posts link to projects via the `project:` frontmatter key matching the project
filename.

**Navigation — 5 tabs (since 2026-06-23):** `start here · work with me ·
projects · field guide · knowledge base`. GitHub is a footer logo + username
(not a tab); the resume is off-nav (linked from "Why me specifically" on
Work-with-me + a dated download). Case studies were merged into the Knowledge
base (`/blog`); `/case-studies` and `/knowledge-base` redirect there. The site
also reflects live GitHub status: `src/lib/github.js` fetches each repo's last
push at build (fail-soft, no client JS), shown as "updated X ago" on project
cards and the resume, kept fresh by the scheduled rebuild (see
`docs/SCHEDULED-REBUILD.md`). Rationale in `pipeline/queue.md` SITE-3.

## 6. Operating playbook

**Add a project** (when a new build starts):
1. Create `src/content/projects/<slug>.md` with frontmatter + 2 short paragraphs
2. `git add -A && git commit -m "project: <name>" && git push` → live in ~60s

**Ship a project:** change `status: building` → `shipped`. Push.

**Add a blog post:** create `src/content/blog/<slug>.md`, set `project:` to the
related project's filename. Push. (Post ideas queue: the "Blog Content Mine"
table in the sovereign stack doc.)

**Update the resume:** edit `src/content/resume.md`, then
`cp src/content/resume.md public/resume.md`. Push. (The copy in
`~/Documents/resume/` is the working-draft archive.)

**Preview locally:** `npm run dev` (port 4321). **Verify:** `npm run build`
must pass before pushing.

**The discipline that keeps it alive:** every project work-session ends by
updating that project's content file — the site is the public mirror of the
execution plan. A site that visibly moves week-to-week is the point; commit
history is evidence of velocity.

## 7. Deploy pipeline

GitHub repo → Cloudflare Pages (Git integration, framework preset: Astro) →
custom domain `theinvalid.me` (zone already on Cloudflare, record auto-created).
Every push to `main` deploys. No CI config needed — Pages detects Astro.

## 8. Gotchas hit during the build (so you don't)

- **Zone-scoped Cloudflare API tokens cannot manage Pages** — Pages needs an
  *account*-level permission. The dashboard Git-connect was the better answer
  anyway (permanent auto-deploy vs. manual wrangler uploads).
- **Astro 6 content layer:** collections live in `src/content.config.ts` using
  `glob()` loaders; entries render via `render(entry)` from `astro:content`,
  and `entry.id` is the filename-derived slug.
- **node_modules vs backups:** if your backup tool covers the projects folder,
  exclude `node_modules`, `dist`, and `.astro` or your snapshots balloon.
- **Importing markdown as a component** (`import { Content } from '...md'`)
  is the cleanest way to render a standalone doc (the resume) inside a layout.

## 9. Promotion playbook (per-post)

1. **LinkedIn** (primary, job-seeking): native post — 3-6 sentences telling the
   story's hook in plain words, link to the post. Not a bare link-drop.
2. **Hacker News**: submit posts that fit the genre (ops failures, measured
   benchmarks, "X doesn't work the way you think" — the backup post qualifies).
   Plain title, no marketing voice.
3. **Reddit**: r/selfhosted, r/LocalLLaMA, r/homelab where genuinely on-topic;
   follow each sub's self-promo rules; participate, don't just drop links.
4. **dev.to cross-post** with `canonical_url` pointing at theinvalid.me (keeps
   SEO credit while borrowing their distribution).
5. Cadence: one promoted post per week beats five in one day. The RSS feed
   exists for the people who come back.

## 10. Brand & visual identity — logo, favicon, tokens

The brand is deliberately minimal: a dark terminal surface, one warm accent, and
system monospace. The constraints in §3 ARE the identity — the discipline is not
adding to them. Any visual change must hold all of these.

### 10.1 Design tokens — source of truth is `src/styles/global.css :root`
Never hardcode a new hex or font; use the CSS variable. Current values:

| token | value | use |
|---|---|---|
| `--bg` | `#0b0e14` | page background |
| `--bg-raise` | `#11151f` | panels, cards, icon tiles |
| `--fg` | `#e6e1d7` | body text, the wordmark name |
| `--muted` | `#8a8f98` | secondary text, taglines |
| `--line` | `#1e2430` | hairlines, dividers |
| `--accent` | `#e8a33d` | **the lantern gold — the ONLY accent, ever** |
| `--mono` | system mono stack | all UI + the wordmark |
| `--sans` | system sans stack | headings / long-form |

`--ok / --warn / --dim / --error` are **semantic status colors** (badges), not brand
accents — don't repurpose them decoratively. **One accent rule:** if a design needs
a second color to work, the design is wrong. No gradients, shadows, or webfonts.

**Light variant (added 2026-07-12, owner-approved).** Dark stays the brand default;
a CSS-only `@media (prefers-color-scheme: light)` block in `global.css :root`
follows the visitor's OS setting. No toggle, no JS, no localStorage — the zero-JS
claim holds. Values (same lantern-gold family, deepened for contrast on paper):
bg `#f7f3ea` · raise `#efe9db` · fg `#23282f` · muted `#5b6270` · line `#ddd5c2` ·
accent `#8f5e13` · ok `#1a7f37` · error `#b3261e`. `Base.astro` carries paired
`theme-color` metas. Standalone `public/*.html` pages keep their own dark heads
(not yet adapted). Pages must keep using the vars — that's what makes this work.

### 10.2 The mark — empty set ∅
The logo is the **empty-set glyph ∅** ("invalid / null / void" — the technical double
meaning of the name, §2): a gold circle + a rising slash (lower-left → upper-right)
with round caps, on a dark panel.
- Used as favicon / app icon / social-card mark, and (since 2026-07-12,
  owner-approved) in exactly ONE on-page spot: the contact band component
  (`src/components/Contact.astro`), where it anchors the direct CTA. It stays out
  of the hero — it was tried there and removed because it competed with the
  wordmark. On-page identity remains the wordmark.
- Clear space ≥ the height of the ∅. Never recolor, add a second accent, or apply a
  gradient/shadow.

### 10.3 The wordmark — terminal prompt
On-page identity is the nav brand: **`>theinvalid.me`** — a gold `>` prompt (the
`.brand .prompt` span), cream `theinvalid`, gold `.me`. It mirrors the hero's
`$ they called me invalid_` line.
- The nav is fixed `max-width: 46rem` and the 6 items sit right at the edge, so the
  brand must stay tight (no extra spacing around `>`) or a tab wraps to a second line
  (queue.md OPS-63 / the `> `-prefix incident).

### 10.4 Favicon system & the cache-busting rule
Assets in `public/`, wired in `src/layouts/Base.astro` `<head>`: `favicon.svg` (∅),
`favicon.ico` (multi-res), `favicon-16/32.png`, `apple-touch-icon.png` (180, opaque),
`icon-192/512.png` (PWA), `site.webmanifest`, `theme-color #0b0e14`.
- **Cache-bust every icon URL with `?v=<token>` (currently `?v=nullset`).** Browsers
  cache favicons by URL far harder than pages — reusing a filename means the old icon
  sticks even after a hard refresh. **On ANY favicon change, bump the token** in
  Base.astro *and* everywhere below.
- Served bytes are authoritative: verify a favicon with `curl` (render the `.ico`),
  then it's a browser cache — incognito confirms instantly.

### 10.5 Standalone pages do NOT inherit Base.astro
`public/*-catalogue.html` and hand-authored case studies carry their **own** `<head>`,
so a brand/favicon change must be applied to each one **and to what generates them**,
or it silently reverts:
- `workflow-catalogue.html` ← `generate-catalogue.py` (real file in the
  `mushishi-creative-stack` repo; regenerated monthly). Fix the template, not the copy.
- `3d-catalogue.html` ← deployed by **`scripts/deploy-3d-catalogue.sh`** (run it; never
  hand-edit the deployed copy — it bakes in the `thumbs/`→`3d-thumbs/` repoint + a
  broken-image guard). Source draft: `drafts/mushishi-3d-catalogue/` (git-ignored).

### 10.6 Canonical logo assets
Master SVG source, all raster exports, `site.webmanifest`, a usage README, and the
`gen_logo.py` regen script live at **`~/Documents/design/theinvalid-logo/`** (private
working dir). The `public/` copies here are the deployed subset. This machine has **no
SVG rasterizer** (no rsvg/inkscape/cairosvg) — regenerate rasters with Pillow via
`gen_logo.py`, not an SVG renderer.
