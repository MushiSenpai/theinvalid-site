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
"failure log" framing) no template has.

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
└── pages/
    ├── index.astro           # hero + Now building + Operating daily + latest posts
    ├── projects/index.astro  # all projects, status-badged
    ├── projects/[slug].astro # project detail + auto-attached related posts
    ├── blog/index.astro      # "The failure log"
    ├── blog/[slug].astro     # post detail
    ├── resume.astro          # renders content/resume.md (+ /resume.md download)
    └── rss.xml.js            # RSS feed
public/resume.md              # downloadable copy — keep in sync with content/resume.md
```

**Key property:** pages are *generated from* the content folders. Statuses
(`building` / `shipped` / `parked`) drive the homepage sections automatically.
Posts link to projects via the `project:` frontmatter key matching the project
filename.

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
