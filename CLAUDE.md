# theinvalid.me — rules for any session touching this repo (auto-loaded)

Job-seeker portfolio + engineering blog. Static **Astro 6** → Cloudflare (push to
`main` = deploy in ~60s). The full reference — every decision, the architecture,
the operating playbook, and the brand/visual-identity spec — is
**[docs/SITE-DECISIONS.md](docs/SITE-DECISIONS.md)**. Read it before non-trivial work.

## Non-negotiables — the brand IS the constraints (SITE-DECISIONS §3, §10)
- **Design = "light vein" (owner decision 2026-11-17).** Night-forest ink, one
  lantern-gold accent, a Mincho display face. The previous design is frozen at
  `/classic/` (`public/classic/`, built by `scripts/snapshot-classic.sh`); never
  hand-edit it and never add new pages to it.
- **One accent only:** lantern gold `--accent #f2c14e` (light theme `#8f6500`).
  The `--p-*` stack pigments name a GPU tenant on the homepage card and nowhere else.
- **Tokens are defined in `src/styles/global.css :root`** — the source of truth. Use
  the vars, never hardcode a new hex. Dark: bg `#0a100e` · raise `#101915` · fg
  `#ebe6d6` · muted `#8d998c` · line `#22312a`.
- **Fonts are self-hosted subsets** in `public/fonts/` (DM Mono, Shippori Mincho,
  Zen Kaku Gothic New; OFL files beside them). No font CDN, no third-party request
  of any kind. A new kanji glyph needs a regenerated `shippori-mincho-kanji` subset.
- **JavaScript only where it earns it:** the homepage GPU card and the field guide,
  inline, no frameworks, every page complete without it, `prefers-reduced-motion`
  respected. No shadows; the only gradient is the card's light vein.

## Brand marks (full spec: SITE-DECISIONS §10)
- **Mark = the empty set ∅** (invalid / null). Favicon / app icon / social card,
  the nav brand, and the contact band.
- **On-page identity = the nav brand**: the ∅ mark + `theinvalid` + gold `.me`
  (since 2026-11-17; the classic `>theinvalid.me` prompt lives on in `/classic/`).
- **Favicons** live in `public/`, wired in `src/layouts/Base.astro`, and are
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
