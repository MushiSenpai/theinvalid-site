---
title: "I built a trading intelligence stack that isn't allowed to trade yet"
description: "GINKO: nine phases of financial intelligence infrastructure, a hard Live Gate, and zero live orders. No performance numbers published because none have passed the audit. That is the post."
date: 2026-07-15
tags: ["trading", "fintech", "backtesting", "ops", "ai-infrastructure"]
---

The system is called GINKO. It observes markets across four exchanges, runs shadow predictions against a scored ledger, and has a nine-gate execution engine sitting ready.

It has placed zero real orders.

That is not a bug. That is the design.

## What it is

Three layers. First: a deterministic intelligence platform, CPU-only Python with PostgreSQL 16. Ingests from SEC EDGAR, FRED, CoinGecko, and a handful of other free sources. Runs screeners, computes net-after-withholding dividend yields (US 30% withholding matters when you are a Singapore resident comparing US yields against SGX REITs), classifies market regime. No GPU dependency anywhere, by design: the platform has to migrate to a VPS later, and the CPU constraint keeps that to a config change.

Second: a research AI layer. LLMs write morning briefs, read SEC filings, generate strategy hypotheses. They do not calculate. Every number an LLM includes must carry a provenance reference to a database row; a validator rejects anything unreferenced. This rule exists because LLM math hallucination in a trading context is not an edge case. Given enough runs, it is a certainty.

Third: a gated execution engine in its own container with its own PostgreSQL role. It can route paper orders through nine risk gates. Each gate is tested. Each gate writes to an audit log. The engine cannot read the LLM tables. Not "is not configured to read them." Provably cannot: different role, different grants, a CI test that asserts the permission error.

The LLM cannot fire a trade. The architecture closes that path structurally.

## The prediction ledger

Every prediction the system emits (direction, magnitude band, horizon, confidence) gets written to an append-only, hash-chained table with a timestamp, model version, and the evidence rows it cited. When the prediction matures, the resolution loop scores it against realized prices: Brier score, expected calibration error, alpha over consensus where options or prediction market odds give you a baseline.

If confidence was 0.62, the system should win about 62% of the time. Calibration, not bravado.

The autopsy loop writes a structured postmortem for every resolved call. The mistake memory feeds back into future briefs. This is what "learns from experience" looks like when it has to be measurable.

## The Live Gate

The rule locked in before I wrote any application code:

> Live trading is a feature flag that stays OFF until a documented audit by (a) a Claude review session, (b) the owner, and (c) an external third party. The flag requires a manually-created signed file outside the repo.

The execution daemon checks for that file on startup and refuses live endpoints without it. Not a config toggle. A physical gate.

The criteria for the audit: at least six months of paper-trading history, calibration reports showing genuine edge over baselines (including a cheap statistical time-series baseline every LLM signal must beat to justify its token cost), zero unexplained risk-gate breaches, and two successful kill-switch drills on record.

Why the discipline? I am new to trading. The backtest engine is honest: it catches lookahead bias (there is a deliberately leaky test strategy in CI that the no-lookahead guard must catch), applies real fee models including withholding tax, and separates in-sample from out-of-sample windows cleanly. NautilusTrader v1.230.0 runs the event-driven backtests; the double-commission bug reported in March 2026 is verified fixed in this version and the fix is a CI acceptance item.

But a backtest is a hypothesis. A backtest on data an LLM has already been trained on is a hypothesis with a memorization problem built in. Look-Ahead-Bench class experiments show that LLM alpha can flip negative past the training cutoff. The Live Gate exists because "the backtest looks great" is not a claim.

## Where it stands

P0 through P9 are merged: foundations, data platform, analytics, prediction ledger, research AI, backtesting lab, execution engine, OSINT layer (including a consumer plugin for typed world events), VPS migration. Fourteen merged PRs, 72 test files. Provider keys for FRED, SEC EDGAR, CoinGecko, FMP, and Alpaca paper are live.

Zero orders placed. Recurring LLM briefs are disarmed, waiting on a cloud-spend budget decision. The prediction ledger holds five smoke predictions, none resolved.

The six-month shadow clock has not started. That is the honest state. It is documented as such, not papered over.

## What I would check if this were your project

1. **Write the gate criteria before phase one.** Not as a vague future intention: write exactly what evidence the audit needs, and build toward that spec. Otherwise you are building toward an ambiguous standard, and ambiguous standards get quietly loosened when you are impatient.
2. **Score calibration, not hit rate.** "65% correct" is meaningless without knowing what you were predicting. Being right on easy calls and wrong on hard ones is often worse than a coin flip. Brier score and reliability curves are the minimum honest reporting surface.
3. **If the LLM can calculate, it will miscalculate.** Give it tool calls that return database-sourced numbers. Validate and store provenance on every output. Reject anything that arrives without an evidence ref.
4. **"Certified on mocks" is a separate state from "works."** The broker adapters here pass the mock certification suite. Neither has touched a real paper account. I document this explicitly because the distinction matters and gets elided constantly in this space.

The repo is private: strategies, ledger, and tax profile stay private by design, with a public framework extraction planned for a later stage. Architecture and doctrine at [github.com/MushiSenpai/ginko](https://github.com/MushiSenpai/ginko).
