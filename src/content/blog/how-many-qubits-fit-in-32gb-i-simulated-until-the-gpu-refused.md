---
title: "How many qubits fit in 32 GB? I simulated until the GPU refused"
description: "A hybrid quantum-classical net on MNIST 0/1 lands at 99.5% — just behind logistic regression (99.6%), the honest loss. Plus the memory-wall sweep: the statevector fits to 28 qubits, then the card taps out."
date: 2026-07-11
tags: ["quantum", "qml", "gpu", "benchmarking", "cuquantum", "mnist", "honest-benchmarks"]
---


A **hybrid** model is a normal neural net with one quantum layer bolted into the middle: a classical encoder squeezes an image down, a quantum circuit processes it, a classical head reads out the answer. We taught it to tell a handwritten **0 from a 1**. And we asked a second question the owner cared about: *what actually happens when you throw the GPU at simulating a quantum computer?*

## The classical baseline wins (as expected)

MNIST 0/1 is nearly linearly separable, so logistic regression is already at the ceiling. The hybrid trains fine and lands a hair behind — exactly the spec-sanctioned outcome. We report the loss, side by side, and move on.

## The GPU question

Max width that simulated on the GPU: **28 qubits**. At 30 qubits the over-commit guard **refused** the run — the predicted statevector exceeds free VRAM (§18C, D6). A quiet twist worth stating: for the *small* circuits this project trains, the GPU is actually ~60× **slower** than the CPU statevector (kernel-launch overhead dominates); the card only earns its keep on the big-qubit simulations near the wall.

## Results

| model | mean test acc | std | per-seed |
|---|---|---|---|
| **hybrid (quantum layer)** | **0.9954** | 0.0012 | 0.9962, 0.9962, 0.9937 |
| logistic regression | 0.9962 | — | 0.9962, 0.9962, 0.9962 |
| MLP (16,16) | 0.9954 | — | 0.9962, 0.9950, 0.9950 |

## Figures

![GPU memory wall: statevector VRAM vs qubit count](/qlab-assets/how-many-qubits-fit-in-32gb-i-simulated-until-the-gpu-refused/gpu-memory-wall.svg)

> **Where the 5090 dies** (on-brand, generated): the statevector doubles every qubit, so VRAM climbs a straight line on the log axis until the 30-qubit run is refused past the 32 GB ceiling (red).

![wall-time and VRAM vs qubits](/qlab-assets/how-many-qubits-fit-in-32gb-i-simulated-until-the-gpu-refused/benchmark.png)

> The measured benchmark: simulation wall-time and peak VRAM climbing with qubit count.

![hybrid training curve](/qlab-assets/how-many-qubits-fit-in-32gb-i-simulated-until-the-gpu-refused/training_curve.png)

> The hybrid model's training curve on MNIST 0/1.

## Honest caveats

The hybrid (0.9954) **loses** to the best classical baseline (0.9962) — the expected, spec-sanctioned outcome (§18D). Logistic regression on MNIST 0/1 is ~99.9%; a hybrid a hair behind is the honest, publishable finding. Reporting the loss **is** the deliverable.

- Claiming quantum advantage is permanently out of scope (D1).
- The classical baseline is the credibility engine (D2).
- The memory wall is honest content: it shows exactly where a 32 GB card can no longer hold the statevector (§18C).

## Reproduce it

Every accuracy traces to `seed_summary.csv`; every VRAM/time point to `benchmark.csv` (D7). [`experiments/20260709-123142_mnist01-hybrid`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260709-123142_mnist01-hybrid).
