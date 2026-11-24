---
title: "ADASHINO: a fitness planner that refuses to guess"
oneliner: "Sets, reps, load and progression come from a deterministic solver with property-tested safety invariants. The LLM is the conversational shell, never the source of the numbers."
status: building
private: true
writeup: "/blog/a-fitness-ai-that-refuses-to-guess"
stack: ["Python", "PostgreSQL + pgvector", "Hypothesis", "mypy --strict"]
started: 2026-07-05
order: 14
---

Most AI workout generators let the model synthesize the plan, so nothing catches a plan that is too heavy or unsafe for your history. Here the two jobs are split by what can be verified. A solver you can test exhaustively owns the numbers; a safety kernel can only remove or shrink what the solver proposed; the LLM maps your context to solver inputs and explains the output.

The safety invariants are property-tested with Hypothesis at 10,000 examples each, and that testing paid for itself early: it caught a rounding bug where a "max 10% weekly increase" cap rounded *up* past its own limit, which code review had missed.

No demo video, and no claims until a four-week dogfood gate passes.
