---
title: "I watched a quantum model become untrainable — the barren plateau, measured"
description: "Gradient variance of a hardware-efficient circuit collapses 1,436× as it grows (global cost, α≈0.64, r²=0.99) — a textbook barren plateau. A local cost decays 7.1× slower: the known escape, quantified."
date: 2026-07-11
tags: ["quantum", "qml", "barren-plateau", "trainability", "vqa", "honest-benchmarks"]
---


Training works by feeling which way is *downhill* (less wrong) and stepping that way. A **barren plateau** is when the landscape becomes a perfectly flat desert — every direction feels equally flat, so the circuit has no idea which way to step and training stalls. The nasty part: the desert gets **exponentially flatter the bigger** you build the circuit. We measured it on our own machine.

## The measurement

Hardware-efficient ansatz (RY layers + CZ ring, depth ∝ width). We took the gradient variance Var[∂C/∂θ] over 200 random initialisations at each width, n = 2…14, for a **global** and a **local** cost observable. Global variance fell from 1.70e-01 to 1.18e-04 — a 1,436× collapse — fitting a clean exponential (α ≈ 0.638, r² = 0.990). The local observable decayed ~7.1× slower: the Cerezo-style shallow+local escape.

## Results

| cost observable | decay rate α | log-linear fit r² | reading |
|---|---|---|---|
| **global** ⟨Z₀…Z_{n−1}⟩ | **0.638** | 0.990 | steep — a barren plateau |
| local ⟨Z₀Z₁⟩ | 0.089 | 0.913 | ~7.1× shallower — the escape |

## Figures

![gradient variance decay: global vs local cost](/qlab-assets/i-watched-a-quantum-model-become-untrainable-the-barren-plateau-measured/barren-plateau-decay.svg)

> **The flat desert, on-brand (generated)**: gradient variance vs qubits on a log axis. The global cost (gold) plunges 1,436× — a barren plateau; the local cost (green) barely moves — the escape.

![log gradient-variance vs qubits](/qlab-assets/i-watched-a-quantum-model-become-untrainable-the-barren-plateau-measured/bp_logvar.png)

> The matplotlib source figure: log gradient-variance falling as qubits grow (global collapses 1,436×; local stays shallow).

## Honest caveats

This is a diagnostic sweep, not a training run: it measures where variational trainability **fails**, which is the deliverable (D1).

- The plateau is a real, quantitative negative result for global-cost hardware-efficient circuits; no quantum-advantage claim is made or implied.
- Parameter-shift gradients on a single scalar parameter — exact, seeded, reproducible.
- The deepest finding pairs with this: the *trainable* (shallow, plateau-free) regime is exactly the one a classical computer can cheaply copy. Trainable ⇒ not special; special ⇒ not trainable. That's the honest 2025 dilemma, measured.

## Reproduce it

Every variance traces to `bp_metrics.csv`, every fit to `bp_fits.csv` (D7). [`experiments/20260710-090941_bp-barren-plateau`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260710-090941_bp-barren-plateau).
