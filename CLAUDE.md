# theinvalid.me — rules for any session touching this repo (auto-loaded)

Job-seeker portfolio + engineering blog. Static **Astro 6** → Cloudflare (push to
`main` = deploy in ~60s). The full reference — every decision, the architecture,
the operating playbook, and the brand/visual-identity spec — is
**[docs/SITE-DECISIONS.md](docs/SITE-DECISIONS.md)**. Read it before non-trivial work.

## Non-negotiables — the brand IS the constraints (SITE-DECISIONS §3, §10)
- **Two designs, split by page (owner decision 2026-11-17).**
  - **Homepage `/` only = "light vein":** `src/pages/index.astro` + `layouts/Home.astro`
    + `styles/home.css`. Night-forest ink, gold accent `#f2c14e`, Mincho display face,
    the GPU card. Its header and footer link to the classic pages (blog, résumé,
    projects, field guide, work with me, classic homepage). Never import `home.css`
    anywhere else.
  - **Every other page = classic**, unchanged: `layouts/Base.astro` + `styles/global.css`.
    The classic homepage lives on at `/classic/` (`src/pages/classic/index.astro`).
    Do not restyle classic pages toward the new look; the owner wants them kept as is.
- **Classic tokens** (`global.css :root`, the source of truth for classic pages):
  **one accent only**, lantern gold `--accent #e8a33d`; bg `#0b0e14` · raise `#11151f`
  · fg `#e6e1d7` · muted `#8a8f98` · line `#1e2430`. System fonts, no client JS
  (the field guide's calculator is the existing exception), no gradients/shadows.
- **Homepage tokens** live in `home.css :root`. The `--p-*` stack pigments name a GPU
  tenant on the card and nowhere else. Fonts are self-hosted subsets in `public/fonts/`
  (OFL files beside them): no font CDN, no third-party request of any kind. A new
  kanji glyph needs a regenerated `shippori-mincho-kanji` subset. Its script is inline,
  the page is complete without it, and `prefers-reduced-motion` is respected.
- **Use the vars, never hardcode a new hex**, in either stylesheet.

## Brand marks (full spec: SITE-DECISIONS §10)
- **Mark = the empty set ∅** (invalid / null). Favicon / app icon / social card, the
  classic contact band, and the homepage's nav brand.
- **On-page identity:** classic pages use the wordmark `>theinvalid.me` (gold `>`, cream
  name, gold `.me`; keep it tight, the 46rem nav wraps if it grows). The homepage uses
  the ∅ mark + `theinvalid` + gold `.me`.
- **Favicons** live in `public/`, wired in BOTH `src/layouts/Base.astro` and `Home.astro`, and are
  cache-busted `?v=<token>` (now `?v=nullset`). **Bump the token on ANY favicon
  change** or browsers keep the stale icon. Master assets + regen: `~/Documents/design/theinvalid-logo/`.
- **Intro / loader videos** (5 options × 16:9/9:16 × 15 s/5 s, incl. a transparent overlay):
  `~/Documents/design/theinvalid-logo/video/` + `gen_intro.py`. Spec: SITE-DECISIONS §10.7.
- **Standalone HTML pages** (`public/*-catalogue.html`, case studies) have their OWN
  `<head>` — they do NOT inherit Base.astro. Apply brand/favicon changes to them AND
  their generators (`generate-catalogue.py`, `scripts/deploy-3d-catalogue.sh`).

## Writing style (owner rule 2026-07-12)
- **No em dashes (—) in site copy.** Use commas, colons, periods, or parentheses
  instead. The one exception: the `<title>` tag separator ("Page — theinvalid.me").
  Applies to all NEW copy (pages, posts, case studies); existing blog posts get
  cleaned opportunistically when otherwise edited, not in a mass rewrite.

## Deploy
- `npm run build` MUST pass, then `git push` to `main` auto-deploys.
- 3D catalogue: run **`scripts/deploy-3d-catalogue.sh`** (never hand-edit the deployed
  `public/3d-catalogue.html`).
- Lessons/decisions → append a row to `pipeline/queue.md` §B (same session).

## Publishing policy (2026-07-12)
This repository — and the site it deploys — is **PUBLIC**. Hard rules:
- Never commit secrets or credentials, business or pricing figures, client names
  or data, private network details, or working dirt (`.claude/`, `*.bak-*` are
  gitignored — never force-add them).
- Samples/media must be rights-clean and safe-for-work; failures documented
  alongside successes.
- Every capability claim must trace to a test/benchmark artifact that ran; a page
  isn't "published" until it's linked from every index its siblings appear in AND
  verified reachable with a real `curl`.
- Run a secrets scan (gitleaks) before every push.
