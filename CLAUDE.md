# theinvalid.me — rules for any session touching this repo (auto-loaded)

Job-seeker portfolio + engineering blog. Static **Astro 6** → Cloudflare (push to
`main` = deploy in ~60s). The full reference — every decision, the architecture,
the operating playbook, and the brand/visual-identity spec — is
**[docs/SITE-DECISIONS.md](docs/SITE-DECISIONS.md)**. Read it before non-trivial work.

## Non-negotiables — the brand IS the constraints (SITE-DECISIONS §3, §10)
- **One accent only:** lantern gold `--accent #e8a33d`. If a design needs a second
  color to work, the design is wrong.
- **Tokens are defined in `src/styles/global.css :root`** — that's the source of
  truth. Use the vars (`var(--accent)` …), never hardcode a new hex. Palette:
  bg `#0b0e14` · raise `#11151f` · fg `#e6e1d7` · muted `#8a8f98` · line `#1e2430`.
- **System fonts only** (`--mono` / `--sans`). No webfonts, no client JS, no
  frameworks, no gradients/shadows. Performance is the flex (100/100 Lighthouse).

## Brand marks (full spec: SITE-DECISIONS §10)
- **Mark = the empty set ∅** (invalid / null). Used ONLY as favicon / app icon /
  social card — deliberately NOT on the page.
- **On-page identity = the wordmark** `>theinvalid.me` (nav `.brand`: gold `>`
  prompt, cream name, gold `.me`). Keep it tight — the `max-width:46rem` nav wraps
  if the brand grows.
- **Favicons** live in `public/`, wired in `src/layouts/Base.astro`, and are
  cache-busted `?v=<token>` (now `?v=nullset`). **Bump the token on ANY favicon
  change** or browsers keep the stale icon. Master assets + regen: `~/Documents/design/theinvalid-logo/`.
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
