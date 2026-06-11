# The Blog Pipeline — full operating manual

Automated weekly blog production with one human gate for social promotion.
Built 2026-06-11. This document is the single reference: how it works, how to
feed it, how to stop it.

---

## The flow, end to end

```
 ┌─ LESSONS ACCUMULATE ──────────────────────────────────────────────┐
 │ Any work session that produces a lesson/failure/decision appends  │
 │ a topic block to pipeline/queue.md  (status: [queued])            │
 └──────────────────────────────┬────────────────────────────────────┘
                                │  every Wednesday 09:00 (cron on mushishi)
 ┌─ THE BOT RUNS ───────────────▼────────────────────────────────────┐
 │ /data/ai/01-workspace/scripts/blog-bot.sh                         │
 │  1. git pull (site repo)                                          │
 │  2. headless Claude reads queue.md, picks FIRST [queued] topic    │
 │  3. writes the full post → src/content/blog/<slug>.md             │
 │  4. writes promo variants → drafts/<slug>/ (linkedin.txt,         │
 │     reddit-<sub>.txt, hn-title.txt)   [drafts/ is gitignored]     │
 │  5. flips the topic to [published <date>] in queue.md (no repeats)│
 │  6. npm run build (must pass) → git commit + push                 │
 │     → Cloudflare auto-deploys → POST IS LIVE on theinvalid.me     │
 │  7. ntfy push to phone: link to live post + what to do next       │
 └──────────────────────────────┬────────────────────────────────────┘
                                │  human gate (you, ~10 min)
 ┌─ YOU PROMOTE ────────────────▼────────────────────────────────────┐
 │ 1. Read the live post. Edit if needed (edit the md, push —        │
 │    site updates itself). Honesty check is YOURS.                  │
 │ 2. Open drafts/<slug>/linkedin.txt → paste to LinkedIn            │
 │ 3. Open drafts/<slug>/reddit-*.txt → paste to the named subreddit │
 │ 4. (optional) hn-title.txt → submit to news.ycombinator.com      │
 │ 5. Done. Next post: next Wednesday.                               │
 └───────────────────────────────────────────────────────────────────┘
```

## Why the blog auto-publishes but socials don't

- The blog is your own property — an imperfect post can be edited a minute
  later and the edit deploys itself. Low blast radius.
- LinkedIn/Reddit posts can't be unsent, platform ToS prohibit unapproved
  posting automation, and subreddits ban bot self-promo. High blast radius →
  human gate.

## Feeding the queue (the "one single place")

`pipeline/queue.md` is the only intake. A topic block looks like:

```markdown
## [queued] some-slug-here
**Angle:** one sentence — the hook of the post.
**Sources:** where the raw material lives (repo LESSONS.md section, plan entry, chat date).
**Targets:** linkedin, reddit:r/selfhosted, hn
```

Rules:
- New lessons from ANY project (current or future) get appended here in the
  same session they happen — that's the standing convention.
- Slugs are kebab-case and become the URL: `/blog/<slug>`.
- Topics marked `[manual]` are reserved for the human to write personally
  (e.g., the why-theinvalid story) — the bot skips them.
- The bot only ever takes the FIRST `[queued]` block → strict FIFO, no repeats
  (status flip is the lock).

## Operating commands

| Action | How |
|---|---|
| Run the bot NOW (off-cycle) | `bash /data/ai/01-workspace/scripts/blog-bot.sh` |
| Pause the pipeline | `crontab -e` → comment the blog-bot line |
| Skip next topic | move its block below another, or mark `[manual]` |
| Edit a live post | edit `src/content/blog/<slug>.md` → commit → push |
| Check bot history | `git log --oneline --author-date-order -- src/content/blog/` + `/data/ai/04-logs/blog-bot.log` |

## Failure behavior

- If the build fails, the bot does NOT push — it ntfy-pings "draft failed
  build" and leaves the work-in-progress for inspection.
- If the queue has no `[queued]` topics, it pings "queue empty — add lessons."
- Everything the bot does is in git history; reverting a post is `git revert`.
