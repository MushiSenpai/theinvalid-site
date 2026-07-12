---
title: "I ran a trained circuit on a real IBM quantum computer — here's the noise"
description: "Sim-trained VQC, inferred on ibm_fez: ⟨Z₀⟩ went +0.72 (sim) → +0.49 (noisy hardware) → +0.87 (mitigated). Mitigation cost 3× the shots. 5 s of QPU under a hard 240 s cap."
date: 2026-07-11
tags: ["quantum", "ibm-quantum", "hardware", "error-mitigation", "zne", "honest-benchmarks"]
---


Most of our work runs on a **simulator** — a normal computer pretending to be a quantum one. This time we sent one trained circuit to a **real** quantum computer at IBM (*ibm_fez*), over the internet, for free. Real hardware is **noisy**: the delicate qubits get bumped, so answers come out fuzzy. The question is how fuzzy, and how much of it we can clean up — honestly accounting for what the cleanup costs.

## Three columns, one honest story

We never train on a real QPU (it burns free minutes for zero learning). We train on the simulator, then run *inference* on hardware. The native-Qiskit circuit provably matched the PennyLane model to ~1e-15 before it flew. Backend: ibm_fez, transpiled depth 63, 12 two-qubit gates.

## Results

| measurement | ⟨Z₀⟩ (sample 0) | what it is |
|---|---|---|
| simulator (exact) | **+0.724** | perfect, noise-free reference |
| raw hardware | +0.486 | real QPU, noise drags it toward 0 |
| ZNE-mitigated | +0.870 | error-mitigated, back near the clean value |

## Figures

![sim vs raw vs mitigated bar chart](/qlab-assets/i-ran-a-trained-circuit-on-a-real-ibm-quantum-computer-heres-the-noise/hardware-bars.svg)

> **Noise, then cleanup** (on-brand, generated): the simulator's clean ⟨Z₀⟩, the real hardware's noise-dragged value, and where zero-noise extrapolation pulls it back — bought with 3× the shots.

## Honest caveats

This validates that a sim-trained model **runs on real quantum silicon** and that error mitigation lifts the raw signal — it is **not** a quantum-advantage claim (D1).

- Mitigation isn't free: ZNE cost **3.0× the shots** (§18E). We report the cost, not just the prettier point estimate.
- On this toy 2-qubit task the classical baselines match or beat the VQC; the value is the honest sim-vs-hardware-vs-mitigated comparison.
- The whole job used **5 s** of QPU time against a hard **240 s** budget cap with no override — so we can't accidentally overspend (D4).

## Reproduce it

Job id(s) `d97qoc52su3c739if17g`. Every number traces to `summary.json` / `equivalence.json` (D7). [`experiments/20260709-141149_p3-ibm-fez`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260709-141149_p3-ibm-fez).
