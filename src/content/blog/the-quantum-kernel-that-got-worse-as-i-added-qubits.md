---
title: "The quantum kernel that got worse as I added qubits"
description: "A fidelity quantum kernel loses to a classical RBF-SVM on both datasets — and its off-diagonal similarities concentrate 64× as qubits grow, the kernel version of the barren plateau. An honest negative result."
date: 2026-07-11
tags: ["quantum", "qml", "quantum-kernel", "svm", "concentration", "honest-benchmarks"]
---


A **quantum kernel** works by asking *how similar do these two things look through a quantum lens?* — then hands those similarities to an ordinary classifier. **Kernel concentration** is its version of the barren plateau: as the circuit grows, *everything* starts looking equally similar, so it can no longer tell points apart. We compared it three ways against classical methods, and watched it concentrate.

## Three-way, identical splits

A fidelity quantum kernel (IQP feature map) feeding a classical SVC, compared on the *same* splits (D2) against the re-uploading VQC and a classical RBF-SVM.

## Results

| dataset | qubits | quantum-kernel SVM | re-uploading VQC | classical RBF-SVM |
|---|---|---|---|---|
| two_moons | 2 | 0.787 | 0.973 | 0.973 |
| mnist01 | 6 | 0.900 | 0.830 | 1.000 |

## Figures

![kernel concentration curve (generated)](/qlab-assets/the-quantum-kernel-that-got-worse-as-i-added-qubits/kernel-concentration.svg)

> **Everything starts to look the same, on-brand (generated)**: off-diagonal Gram-matrix variance collapsing 64× as qubits grow — the kernel analogue of the barren plateau.

![kernel concentration: off-diagonal Gram variance vs qubits](/qlab-assets/the-quantum-kernel-that-got-worse-as-i-added-qubits/kernel_concentration.png)

> The matplotlib source figure: off-diagonal kernel-similarity spread shrinking with qubit count.

## Honest caveats

The quantum kernel **loses to** the classical RBF-SVM on every dataset here — the spec-sanctioned honest outcome (§18D, D1/D2).

- No quantum-advantage claim: a negative result, reported plainly.
- The IQP fidelity kernel is one standard construction; concentration is a general property of expressive fidelity kernels.
- Off-diagonal Gram variance shrank **64×** as qubits grew — scaling qubits makes it *worse* at separating points, not better.

## Reproduce it

Accuracies trace to `three_way.csv`, concentration to `concentration.csv` (D7). [`experiments/20260710-095452_qk-qkernel`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260710-095452_qk-qkernel).
