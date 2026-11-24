---
title: "Four ops surprises from a self-hosted AI estate"
description: "Docker healthchecks testing the wrong port, LLMs advising from a blank slate, burning scraping credits on work WebSearch does for free, and the plan doc pattern that kept eight parallel sessions honest."
date: 2026-11-24
project: sovereign-ai-stack
tags: ["ops", "docker", "self-hosted", "llm", "automation"]
---

The 3D stack build sprint ran eight sessions in a single week, each covering a different phase. What surfaced afterward was a list of small lessons that individually don't justify a full post but collectively add up to a morning of lost time each. This is that list.

## 1. The healthcheck was testing the wrong port for 265 probes

The monitoring stack runs xenrox/ntfy-alertmanager for alertmanager-to-phone alerts. It worked. Alerts landed on my phone. But the container sat in this state for months:

```
ntfy-alertmanager  |  health checks: 265 consecutive failures
```

The image bakes in a healthcheck:

```dockerfile
HEALTHCHECK CMD curl -sf http://localhost:8080/health || exit 1
```

My `config.scfg` binds the service to `:8111`. So every probe since day one hit a port nothing was listening on and returned `connection refused`. The service was fine. The healthcheck was testing the default config, not mine.

The fix is one line in `compose.yml`:

```yaml
healthcheck:
  test: ["CMD", "curl", "-sf", "http://localhost:8111/health"]
  interval: 30s
  timeout: 5s
```

The rule: any image whose port you reconfigure needs its baked-in `HEALTHCHECK` overridden in compose. An inherited check tests the image's default, not your running configuration.

## 2. Five LLMs planned my AI platform and all five assumed I had nothing

I ran planning sessions with five frontier models for a unified Mushishi AI Platform spec. I wanted architecture input: job scheduling, model routing, observability.

Every single one recommended I build: an OpenAI-compatible API layer, per-stack queues, Prometheus-based monitoring, and a GPU scheduler.

I already had all of that. LiteLLM with 14 configured routes. RQ queues per stack. VictoriaMetrics with per-process VRAM attribution. The gpu-tenants/mode/idle-flush system. The whole estate.

What none of them knew is that none of them asked. They assumed a blank slate and designed from scratch.

The correct input to that planning session was an inventory pass first: list what exists, what it does, and what the gaps are. The spec that resulted from doing that was "unification (cross-stack job API, GPU lease scheduler, per-consumer keys, semantic cache, evals)" rather than "construction." A completely different problem.

The lesson: LLM advisory quality is bounded by what the model knows about your existing system. Inventory-first beats architecture-first.

## 3. Free scraping works for most of what you're paying Firecrawl to do

I was burning Firecrawl credits on research sessions. Looking at what those credits were actually buying:

Most of what I needed was reachable for free, in this order:

1. **WebSearch and WebFetch first.** Built-in tools, zero credits, hit these before anything else.
2. **Native sources directly.** `raw.githubusercontent.com` for GitHub files. Sitemap XML for site structure. RSS feeds for update history. These render instantly and never hit an anti-bot wall.
3. **Firecrawl's own refund hook.** The `firecrawl_search_feedback` endpoint refunds 1 credit per search call. Easy to wire into a wrapper.
4. **Firecrawl only for hard cases.** Cloudflare-protected pages with JS rendering are genuinely difficult. That's the tier Firecrawl earns its keep.

One counterintuitive finding: a datacenter IP is *worse* for anti-bot detection than a residential IP. Self-hosting a scraper on a VPS to get "IP diversity" actually makes it easier to fingerprint. Do not reach for self-hosted infrastructure as an IP rotation trick.

The free tier (1000 credits/month, no rollover) covers everything that isn't a Cloudflare target, if you apply this order.

## 4. The plan doc written as a build contract

The 3D stack build ran nine phases across eight parallel sessions in roughly 36 hours. Each session was a fresh context window with no memory of what the others had done.

What kept eight sessions from repeating each other's work was the spec document, structured not as a description but as a build contract:

- **File ownership fences**: which files each phase owned, to avoid collisions
- **GPU-priority protocol**: how to coordinate on the shared card
- **Per-phase acceptance criteria**: what "done" meant before moving on
- **A failure log**: every trap documented with its fix on the first session that hit it (the glossary grew from F1 to F68 by the end)

The failure log was the most valuable part. Session N never paid session N-1's tuition on a build gotcha because it was written down with enough context to apply it. Nightly-pin builds, HF_HOME auth drops, zombie-parked agents, silent delivery gate bugs: each paid once.

The coordination rule that mattered most: verify on disk before accepting any agent's claims, and give parked agents current facts rather than re-asking the same question. A session started mid-sprint can't see the world change around it. Its assumptions about the state of the build are whatever was in the spec when it launched.

---

## What to check today

- Look at every Docker service you reconfigured to a non-default port. Check whether the image baked in a healthcheck that still tests the original port. `docker inspect <container> | grep -A5 Healthcheck` will show you what's running.
- Before your next architecture planning session with an LLM, start with an inventory prompt: list every service, its port, and what it does. Feed that in first.
- Check your scraping API usage by category. If a significant fraction is page scrapes that could have been raw GitHub files or RSS feeds, the free-first order above pays back immediately.

---

*The sovereign AI stack, including the monitoring infrastructure this post pulls from, is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
