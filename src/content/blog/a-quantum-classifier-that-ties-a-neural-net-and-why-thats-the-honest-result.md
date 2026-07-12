---
title: "A quantum classifier that ties a neural net — and why that's the honest result"
description: "A re-uploading VQC hits 97.8% on two-moons, dead even with an MLP and well above logistic regression (85.3%). The framework trains; nobody won. That side-by-side honesty is the whole point."
date: 2026-07-11
tags: ["quantum", "qml", "vqc", "pennylane", "honest-benchmarks", "classification"]
---


A **VQC** is a quantum circuit with tunable knobs that learns to sort things — here, to separate two interleaving crescent-moon shapes of dots (the classic *two-moons* test). We train it exactly like any AI: show it examples, let it guess, measure how wrong it was, nudge the knobs, repeat. Then — and this is the whole honesty engine of the project — we race it against ordinary (classical) methods on the *same* split. A quantum number is never shown alone.

## What we built

A configurable **re-uploading VQC** (angle embedding, strongly-entangling ansatz, data re-uploading on) trained with Adam on two-moons, 3-seed mean, on the CPU statevector simulator. Beside it — mandatory (D2) — logistic regression and a small MLP on the *identical* splits.

## Results

| model | mean test acc | std | per-seed |
|---|---|---|---|
| **re-uploading VQC** | **0.978** | 0.006 | 0.973, 0.987, 0.973 |
| logistic regression | 0.853 | 0.000 | 0.853, 0.853, 0.853 |
| MLP (16,16) | 0.978 | — | 0.987, 0.973, 0.973 |

## Figures

![QLAB publishing pipeline diagram](/qlab-assets/a-quantum-classifier-that-ties-a-neural-net-and-why-thats-the-honest-result/qlab-pipeline.svg)

> **How every QLAB post is built** (on-brand, generated): an experiment folder becomes an honest, visual, reproducible post — baseline beside every quantum number, caveats auto-included.

![VQC training curve](/qlab-assets/a-quantum-classifier-that-ties-a-neural-net-and-why-thats-the-honest-result/training_curve.png)

> Training curve: loss falling as the circuit's knobs are tuned over epochs.

![VQC decision boundary on two-moons](/qlab-assets/a-quantum-classifier-that-ties-a-neural-net-and-why-thats-the-honest-result/vqc_boundary.png)

> The VQC's learned decision boundary carving the two crescents apart.

![decision boundary evolving during training](/qlab-assets/a-quantum-classifier-that-ties-a-neural-net-and-why-thats-the-honest-result/boundary_evolution.gif)

> The boundary *forming* over training — the quantum circuit learning the shape.

## Honest caveats

On this run the VQC (0.978) ties the best classical baseline (0.978). Two-moons is a 2-D toy: this shows the framework **trains**, not quantum advantage.

- Claiming quantum advantage is permanently out of scope (D1) — this is an honest-evaluation portfolio, not a quantum-wins pitch.
- The classical baseline is the credibility engine (D2): the quantum number never ships alone.
- Simulator-only, CPU. Real-hardware columns come later; the classical-simulability audit comes later still.

## Reproduce it

Every number above traces to `metrics.csv` / `seed_summary.csv` (D7). Config + data + plots: [`experiments/20260708-105849_two-moons`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260708-105849_two-moons).
