---
title: "A fitness AI that refuses to guess"
description: "ADASHINO plans training with a deterministic solver -- the LLM is the conversational shell, not the source of the numbers. No demo video, and a four-week dogfood gate before any claims ship."
date: 2026-07-22
tags: ["fitness", "adashino", "deterministic", "property-testing", "llm"]
---

Every AI workout generator I've tried does the same thing: you describe yourself, the model synthesizes a plan, and the plan sounds authoritative. If it's wrong -- too heavy, poorly distributed, unsafe for your history -- there's no mechanism to catch that before it reaches you. The model doesn't know what it doesn't know.

ADASHINO is the fitness planner I'm building for my own training. The architecture is deliberately hostile to guessing.

## The split

Sets, reps, load, and weekly progression come from a deterministic solver. The LLM's job is the conversational wrapper: it takes your context, maps it to solver inputs, and renders the solver's output in plain language. It does not generate numbers. It talks around them.

This split exists because the two components have different reliability properties. A solver can be tested exhaustively -- you can run 10,000 property tests and know exactly what it produces. An LLM can be sampled, but you're reasoning about a distribution, not a function. Safety invariants belong in the thing you can verify.

## The rounding bug that property tests caught

During P1, building the solver's safety kernel, a [Hypothesis](https://hypothesis.readthedocs.io/) property test found a bug that code review had missed.

The constraint: weekly load may not increase by more than 10%. The naive implementation:

```python
new_max = round(prev * 1.10, 1)
```

For `prev=10.5`: `10.5 × 1.10 = 11.55`, then `round(11.55, 1) = 11.6`. That is 0.05 kg over the cap. The constraint meant to enforce safety silently violated itself on certain input values. Four hundred Hypothesis examples found it in minutes.

The fix rounds toward the safe side:

```python
new_max = math.floor(prev * 1.10 * 10) / 10
```

Any clamp-then-round in a safety invariant is suspect. Round toward the limit, not away from it.

## The allocation bug

Property testing also surfaced a volume-distribution problem. Early plan outputs included lines like `"16 × 8 chest press"` -- a muscle group's entire weekly volume stacked onto one exercise. That is within a set-count constraint but wrong in a way no set-count constraint can catch.

Domain-shaped caps are now in the solver: no more than 4 sets per exercise, volume split across at least two lifts. Constraint satisfaction is not the same as a sensible plan.

The safety pass now raises `SafetyEnforcementError` if it cannot verify that every output line traces to a solver input line and that total load is non-increasing per constraint. Violations abort the run. The kernel does not produce degraded plans -- it stops.

## Why there is no demo video

The standard move here is to generate a sample plan, record a screen capture, and post it. I'm not doing that.

A demo plan is evidence that the output looks like a plan. It is not evidence that the plans work. Those two things feel the same and are completely different, and a lot of AI fitness products are trading on that ambiguity.

## The release gate

ADASHINO will not ship until I have trained with it for four weeks. Not "tested it" -- trained with it, tracking actuals.

The plans must pass the solver's safety invariants. The invariants were written by me. The only honest gate beyond that is: does the owner get stronger and stay uninjured under the system's guidance?

P0 (data model and ontology), P1 (solver and safety kernel), and P2 are built. The Hypothesis suite runs 400 examples per invariant for the PR gate and 10,000 for the nightly acceptance pass, across 8 invariants. The dogfood gate starts when I enter structured training under its plans. I'll write something when it passes or fails -- and if it fails, what it got wrong.

## The takeaway

The LLM is not the fitness expert. The fitness constraints are the fitness expert, and constraints can be formally tested. If you are building anything where a wrong output has physical consequences, put the invariants in the most testable layer and use the language model as the interface, not the source of truth.

---

*Source: [github.com/MushiSenpai/adashino](https://github.com/MushiSenpai/adashino)*
