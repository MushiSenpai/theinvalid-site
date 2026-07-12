---
title: "I let an LLM agent design quantum circuits in a sandbox for 10 cycles"
description: "An LLM proposed VQC variants, each run in a locked no-network sandbox, scored vs a 0.978 baseline. It explored, hit a collapse, recovered, and edged the baseline by +0.0044 — within noise. The honesty and the sandbox are the story."
date: 2026-07-11
tags: ["quantum", "qml", "agents", "llm", "sandbox", "automation", "honest-benchmarks"]
---


We handed the search over to an **agent**: an LLM reads the previous results, proposes a new circuit design, and runs it — but only inside a **locked sandbox** (no network, no writing outside its scratch folder, killed if it hangs). Ten cycles, no human in the loop, every decision written down. It structurally *can't* reach real hardware — so it can never overspend the QPU budget.

## The sandbox comes first

Untrusted, model-written code runs behind hard denials — proven *before* any of it executes. If any denial fails to fire, the whole loop aborts (fails closed):

| denial test | blocked? |
|---|---|
| network | ✅ yes |
| file-escape | ✅ yes |
| timeout | ✅ yes |

All denials held: **True**.

## Ten autonomous cycles

The agent read prior results, proposed the next variant, ran it sandboxed, and scored it against the baseline on identical splits — writing its reasoning each time.

## Results

| cycle | proposed variant | test acc | vs baseline |
|---|---|---|---|
| 0 | iqp/strongly_entangling L=8 | 0.9556 | -0.0222 |
| 1 | angle/basic_entangler L=12 | 0.4844 | -0.4933 |
| 2 | iqp/strongly_entangling L=6 | 0.8356 | -0.1422 |
| 3 | angle/strongly_entangling L=8 | 0.9733 | -0.0044 |
| 4 | angle/strongly_entangling L=10 | 0.9733 | -0.0044 |
| 5 | angle/strongly_entangling L=12 | 0.9822 | +0.0044 ✅ |
| 6 | angle/strongly_entangling L=16 | 0.9822 | +0.0044 ✅ |
| 7 | angle/strongly_entangling L=14 | 0.9822 | +0.0044 ✅ |
| 8 | angle/strongly_entangling L=18 | 0.9822 | +0.0044 ✅ |
| 9 | angle/strongly_entangling L=20 | 0.9689 | -0.0089 |

## Figures

![agentic loop accuracy trajectory vs baseline](/qlab-assets/i-let-an-llm-agent-design-quantum-circuits-in-a-sandbox-for-10-cycles/agent-trajectory.svg)

> **The agent's search path** (on-brand, generated): per-cycle accuracy against the fixed classical baseline (green). Green dots edged it; the dip at the end is the agent discovering that more depth started to hurt.

## Honest caveats

The best cycle edged the baseline by **+0.0044** (0.9822 vs 0.9778) — but the VQC's own seed-to-seed noise is ~1σ of that, so this is **consistent with a small statistical fluctuation on a near-saturated benchmark, not a quantum advantage** (D1). The agent's report says so itself.

- No quantum-advantage claim; the honest reading is a tie-ish improvement.
- Every proposed circuit ran sandboxed on the CPU simulator; the loop fails closed if a sandbox denial ever fails to trigger.
- The interesting result isn't the number — it's that an autonomous agent explored, found a collapse (a bad ansatz dropped to 0.48), abandoned it, and converged — with a written rationale per cycle.

## Reproduce it

Every cycle traces to `cycles.csv` + per-cycle `cycleNN_score.json`; rationales in `rationales.md` (D7). [`experiments/20260710-114217_p5-agent`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260710-114217_p5-agent).
