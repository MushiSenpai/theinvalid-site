# Scheduled rebuild & live GitHub status

The site is static (Astro → Cloudflare Pages). To make it *reflect current
GitHub activity*, two pieces work together:

1. **Build-time GitHub fetch** (`src/lib/github.js`) — at every build, each
   project's repo is queried for its last push, and the project cards
   (homepage, `/projects`) and the resume's live project list show
   "updated X ago". Fail-soft: if the API is unreachable or rate-limited, the
   badge is simply omitted — the build never breaks.

2. **Scheduled rebuild** (`.github/workflows/scheduled-rebuild.yml`) — a daily
   cron that re-triggers a deploy, so the snapshot in (1) stays fresh even on
   days you don't push. Without it, "updated X ago" only refreshes when you
   deploy for another reason.

## One-time setup (owner)

### a) Scheduled rebuild — Cloudflare deploy hook
1. Cloudflare dashboard → Pages → the `theinvalid-site` project →
   **Settings → Builds & deployments → Deploy hooks** → create one
   (e.g. name `scheduled-refresh`, branch `main`). Copy the URL.
2. GitHub repo → **Settings → Secrets and variables → Actions → New repository
   secret** → name `CF_DEPLOY_HOOK`, value = that URL.
3. Done. The workflow runs daily at 06:00 UTC (and on-demand from the Actions
   tab). Until the secret exists, the job no-ops safely.

The hook URL is a credential — it can trigger deploys. Keep it in the secret,
never in the repo.

### b) Optional — higher GitHub rate limits
Unauthenticated GitHub API is ~60 requests/hour per IP, which is plenty for a
handful of repos per build. If builds ever start missing badges due to rate
limits, add a fine-grained read-only token as the Cloudflare Pages build
environment variable `GITHUB_TOKEN` (Pages project → Settings → Environment
variables). `src/lib/github.js` uses it automatically when present.

## Still TODO (Phase 2b) — resume PDF auto-generation

The `/resume` *page* is already current (its project list is generated from the
projects collection). The downloadable **PDF** is still a hand-made file in
`public/resume.pdf`. To make the PDF auto-current, add a step to a workflow that
renders the built `/resume` page to PDF with a headless browser (Playwright) and
commits it — best run here in CI, not in the Cloudflare build (no browser there).
Left as a deliberate next step pending owner review.
