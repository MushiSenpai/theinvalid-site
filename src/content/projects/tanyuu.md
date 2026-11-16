---
title: "TANYUU: sovereign OSINT substrate"
oneliner: "Open-source intelligence collected into a bitemporal knowledge graph on Postgres and Apache AGE, with evidence on every claim and an analyst portal that ships as one self-contained, no-egress HTML file."
status: building
private: true
writeup: "/blog/the-best-osint-dashboard-i-could-build-with-zero-external-assets"
stack: ["PostgreSQL", "Apache AGE", "pgvector", "FastAPI", "vanilla JS + inline SVG"]
started: 2026-07-04
order: 12
---

Passive, public-source collection feeds a graph where every event and claim carries at least one evidence reference and two timelines: when it was true, and when the system learned it. Confidence and source reliability are stored and shown separately, because they are different things.

The analyst surface follows one estate rule: nothing on the analysis box calls out. So the portal (overview, map, timeline, link graph, entities, claims, sources, alerts) is a single HTML file with inline JS and SVG. The map uses no tile server: a public-domain coastline is baked into an equirectangular SVG path. A chart with no data says "calibration pending" instead of looking authoritative.

The write-up also covers the adversarial AI code review of the portal, including the top finding that turned out to be wrong.

Private by doctrine: the collection side is never published.
