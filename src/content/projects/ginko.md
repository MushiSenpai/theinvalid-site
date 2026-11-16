---
title: "GINKO: trading intelligence that is not allowed to trade"
oneliner: "A financial-intelligence stack built observation-first: shadow predictions scored on an append-only ledger, a nine-gate execution engine, and zero live orders until the calibration audit passes."
status: building
private: true
writeup: "/blog/i-built-a-trading-intelligence-stack-that-isnt-allowed-to-trade-yet"
stack: ["Python", "PostgreSQL 16", "DuckDB", "hash-chained ledger", "Brier / ECE scoring"]
started: 2026-07-06
order: 11
---

Three layers. A deterministic, CPU-only intelligence platform ingests free public sources, runs screeners and classifies market regime. A research layer lets LLMs write briefs and read filings, but **LLMs do not calculate**: every number must carry a provenance reference to a database row, and a validator rejects anything unreferenced. A gated execution engine sits in its own container with its own database role, and a CI test asserts that it cannot read the LLM tables.

The heart of it is the prediction ledger: every call (direction, band, horizon, confidence) is written append-only and hash-chained, then scored when it matures. If confidence was 0.62 the system should win about 62% of the time. Calibration, not bravado.

No performance numbers are published because none have passed the audit yet. That is the point of the write-up.
