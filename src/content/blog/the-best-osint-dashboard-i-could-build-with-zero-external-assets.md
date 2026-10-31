---
title: "The best OSINT dashboard I could build with zero external assets"
description: "Building a sovereign no-egress OSINT portal in one self-contained HTML file: geospatial maps without tile servers, and why the AI code reviewer's top finding about Apache AGE parameterized LIMIT was wrong."
date: 2026-10-31
tags: ["osint", "vanilla-js", "apache-age", "postgres", "dashboard"]
---

Four dashboards. All binding port 5000. All showing synthetic data. The actual intelligence feeds were running fine, inserting real rows into Postgres+AGE, but nothing rendered them. That was the state of my OSINT substrate when I finally sat down to build something usable.

## The constraint

My estate rule: no external network egress from the analysis box. No CDN calls, no npm at runtime, no tile server requests. Any dashboard ships as a single self-contained HTML file, inline JS, inline SVG, CSP-safe, capable of running air-gapped.

No React, no Mapbox, no Bootstrap. Every widget hand-rolled from scratch. That constraint turned out to be the interesting part.

## What I built

One consolidated portal over the live Postgres+Apache AGE graph store: overview, map, timeline, graph, entities, claims, sources, and alerts. The four previous dashboards were each one panel and never talked to each other. This one is all of it in a single file.

Three widgets required real work. A force-directed link graph for entity relationships. A Tufte-dense timeline for event sequences. And a geospatial map with no tile server.

The map is the part I would build the same way again. There is no Mapbox, no OpenStreetMap tile fetch, no external request of any kind. I baked a public-domain Natural Earth coastline directly into an equirectangular SVG path using two lines of math:

```
x = (lon + 180) * (width / 360)
y = (90 - lat) * (height / 180)
```

Different sources tag locations differently: USGS supplies raw `lat,lon` coordinates, GDELT uses country names. I resolve those server-side to centroids before anything reaches the client. The frontend gets uniform `{lat, lon}` pairs and plots them with the formula above. The whole map is a static SVG path baked into the HTML, plus a few dozen lines of JS to place dots on it.

Information design choices mattered too: confidence and reliability are displayed separately because they are different things, provenance is one click away, and a chart shows "calibration pending" at `n=0` rather than looking authoritative with nothing behind it.

## The adversarial review

After shipping the portal, I ran a four-dimension adversarial AI code review over the change. It returned eight findings. The top one, labeled high-severity: **"Apache AGE rejects a parameterized `LIMIT` clause and will throw a 500 in production."**

I checked by running the actual query against the actual database:

```python
snapshot(limit=5)
# returned exactly 5 rows
```

Not a 500. Not an error. Five rows. The parameterized `LIMIT` worked fine in this version of Apache AGE.

The reviewer had applied a general claim about PostgreSQL extension behavior that was false for this instance. It stated the claim with confidence, labeled it high-severity, and explained the failure path in convincing detail. None of that made it correct.

The other seven findings were real: a missing nonce on the CSP header, multi-source claims being credited to the most permissive source instead of the most restrictive, a shape inconsistency in one API response, a misleading comment in the deploy script. All worth fixing, and all fixed.

The lesson is not that adversarial reviewers are useless. Seven out of eight is a strong hit rate, and fixing those seven made the system meaningfully more correct. The lesson is that a confident-sounding explanation is not a verified fact. **Measure the named cause against the running system before touching the code.** An adversarial reviewer is a hypothesis generator. The verification step belongs to you.

## The canary that caught the real bug

Before pushing to the VPS, I added a run-canary to the deploy process: a one-shot collect run that must produce real rows in the database, not just start and exit 0. Containers can report healthy; endpoints can return 200; the service can still not be working.

On the first live VPS deploy, the canary failed with exit 137. Every container showed healthy. Every endpoint returned 200. The canary was the only honest signal.

Root cause: OpenSanctions' consolidated `entities.ftm.json` is 2.74 GB, one FtM entity per line. The collector read the whole response body into RAM before processing it. On my 32 GB dev box with no cgroup limit, local tests passed every time. On the 2 GB VPS container, it OOM'd. Raising the cgroup cap just moved the OOM to 6 GB.

The fix streams and samples only the first 8 MiB of complete lines. Local success on an unmetered box hides unbounded reads that only a memory-capped environment reveals.

## What I would tell you to check today

1. **If your dashboard makes external requests, it is not air-gap safe.** Natural Earth is public domain, the coastline file is small, and equirectangular is fifteen lines of math.
2. **Run adversarial AI code reviews.** Treat their findings as hypotheses. Run the named failure case against your actual system before writing a line of fix code.
3. **Add a deploy canary that checks for real output**, not container health. A container that OOM-loops on every collect run looks exactly like a healthy container until you check for rows.
4. **Your local test environment has unlimited RAM.** Your production container does not.

---

*Tanyuu is a private OSINT substrate. The portal approach (one self-contained HTML file, no external dependencies, CSP-safe, air-gap capable) applies anywhere you are building for a sovereignty-first or restricted environment.*
