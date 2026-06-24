# Scheduled rebuild & live GitHub status

The site is static, deployed as **Cloudflare Workers static-assets** (see
`wrangler.jsonc`: `wrangler deploy` uploads `./dist`). Cloudflare's git
integration redeploys on every push to `main` (push = live).

To make the site *reflect current GitHub activity*, two pieces work together:

1. **Build-time GitHub fetch** (`src/lib/github.js`) — at every build, each
   project's repo is queried for its last push, and the project cards
   (homepage, `/projects`) and the resume's live project list show
   "updated X ago". Fail-soft: if the API is unreachable or rate-limited, the
   badge is simply omitted — the build never breaks. No client-side JS.

2. **Scheduled rebuild** (`.github/workflows/scheduled-rebuild.yml`) — a daily
   cron that rebuilds + redeploys, so the snapshot in (1) stays fresh even on
   days you don't push. (Pushes already refresh it, so this only matters for
   quiet stretches — it's optional.)

## One-time setup (owner) — to enable the scheduled rebuild

Because the site is Workers (not Pages), there's no "deploy hook URL". The cron
deploys with `wrangler`, which needs two repo secrets:

1. Cloudflare dashboard → **My Profile → API Tokens → Create Token** → use the
   "Edit Cloudflare Workers" template (or a custom token with **Workers
   Scripts: Edit** on this account). Copy it.
2. Get your **Account ID** (Workers & Pages → Overview, right sidebar).
3. GitHub repo → **Settings → Secrets and variables → Actions** → add:
   - `CLOUDFLARE_API_TOKEN` = the token
   - `CLOUDFLARE_ACCOUNT_ID` = the account id
4. Done. The workflow runs daily 06:00 UTC (and on-demand from the Actions tab).
   Until **both** secrets exist, the job no-ops safely.

The API token is a credential — keep it in the secret, never in the repo.

### Simpler alternative (no new credential)
If you'd rather not mint a Workers token, the cron can instead push an empty
commit (`git commit --allow-empty`) to `main` and let Cloudflare's existing git
integration rebuild. Trade-off: a daily empty commit in history. Say the word
and I'll switch the workflow to that.

### Or skip it entirely
Since push = live and you push content regularly (blog + commits), the snapshot
already refreshes often. The scheduled rebuild is a nicety, not a requirement.

## Optional — higher GitHub rate limits
Unauthenticated GitHub API is ~60 requests/hour per IP — plenty for a handful of
repos per build. If builds ever miss badges due to rate limits, set a
fine-grained read-only `GITHUB_TOKEN` in the Cloudflare build environment
(Workers & Pages → the project → Settings → Variables). `src/lib/github.js`
picks it up from `process.env` automatically.

## Still TODO (Phase 2b) — resume PDF auto-generation
The `/resume` *page* is already current (its project list is generated from the
projects collection). The downloadable **PDF** is still a hand-made file in
`public/resume.pdf`. To make the PDF auto-current, add a step that renders the
built `/resume` page to PDF with a headless browser (Playwright) and commits it —
best run in CI (this workflow), not the Cloudflare build (no browser there).
Left as a deliberate next step pending owner review.
