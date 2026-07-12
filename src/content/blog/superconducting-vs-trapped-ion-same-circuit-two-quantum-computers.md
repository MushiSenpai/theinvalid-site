---
title: "Superconducting vs trapped-ion: I ran the same circuit on two quantum computers"
description: "One trained VQC, two hardware technologies. The trapped-ion raw ⟨Z₀⟩ (+0.60) beat superconducting (+0.49) at getting near the sim (+0.72) — then its cheap error-mitigation misfired and moved the answer to +0.32, further from truth. The higher-fidelity machine, and a mitigation that backfired."
date: 2026-07-11
tags: ["quantum", "ibm-quantum", "ionq", "trapped-ion", "hardware", "error-mitigation", "zne", "honest-benchmarks"]
---


We took the **exact same trained quantum circuit** and ran it on **two physically different quantum computers**: IBM's, which stores qubits in tiny **superconducting** loops chilled near absolute zero, and another built from single **trapped ions** — individual atoms held still by lasers. Same recipe, two utterly different machines. Then we compared each machine's answer to the perfect **simulator** answer, and tried to **clean up the noise** on each — honestly reporting when the cleanup *helped* and when it *backfired*.

## Same model, two machines

We never retrain per machine — that would burn hardware time for zero learning. We train once on the simulator, reconstruct the circuit natively, prove it matches the trained model to ~1e-15, then run **inference** on each backend. The superconducting run (ibm_fez) used 2048 shots; the trapped-ion run (ionq:forte-1) used 100. Both aim at the same exact simulator value, +0.7240.

## The twist: better raw, worse mitigation

The headline you'd expect — 'superconducting vs trapped-ion, who wins?' — has an honest answer with a sting. The trapped-ion machine's **raw** answer was closer to the truth. But zero-noise extrapolation, the same cheap trick that *helped* on the superconducting run, **hurt** here: at only 100 shots the noise-scaled points came out non-monotonic ([+0.60, +0.80, +0.52] at scales [1, 3, 5]), so the extrapolation ran the wrong way. That's the whole lesson — mitigation is a tool with a failure mode, not a free 'make it better' button.

## Results

| backend | technology | shots | sim ⟨Z₀⟩ | raw ⟨Z₀⟩ | mitigated ⟨Z₀⟩ | raw error | mit error |
|---|---|---|---|---|---|---|---|
| **ibm_fez** | superconducting | 2048 | +0.724 | +0.486 | +0.870 | 0.238 | 0.147 |
| **ionq:forte-1** | trapped-ion | 100 | +0.724 | +0.600 | +0.320 | **0.124** | 0.404 |

## Figures

![grouped sim/raw/mitigated bars: superconducting vs trapped-ion](/qlab-assets/superconducting-vs-trapped-ion-same-circuit-two-quantum-computers/cross-hardware-bars.svg)

> **Same circuit, two machines** (on-brand, generated): the shared simulator truth (gold line), then each backend's raw (red) and ZNE-mitigated (green) ⟨Z₀⟩. The trapped-ion raw sits closest to the gold line — but its green mitigated bar overshoots *past* it, the misfire the numbers actually show.

## Honest caveats

This is a cross-**hardware** reproduction of one trained model on two qubit technologies — **not** a quantum-advantage claim (D1). The honest finding has two halves, and the second is the interesting one:

- **The higher-fidelity machine won the raw round.** The trapped-ion raw ⟨Z₀⟩ (+0.600) landed only **0.124** from the simulator's +0.724, closer than the superconducting raw (+0.486, off by 0.238) — even though it used far fewer shots (100 vs 2048).
- **But its cheap mitigation backfired (§18E).** Zero-noise extrapolation on the trapped-ion run moved the answer to +0.320 — now **0.404** from truth, *further* than the raw 0.124. At 100 shots the noise-scaled measurements at scales [1, 3, 5] came out **non-monotonic** ([+0.60, +0.80, +0.52]), so the extrapolation is dominated by shot noise and pulls the wrong way. Mitigation is not free and can hurt — we report it straight instead of hiding it.
- ZNE cost **3.0× the shots** either way (§18E).
- On this toy 2-qubit task the classical baselines (Phase 1) match or beat the VQC (§18D); the value here is the honest sim-vs-hardware-vs-mitigated comparison across two technologies, not a win.
- Cost honesty (D4): the trapped-ion run billed **15 credits** against a 20-credit cap — a real budget spent, reported.


## Reproduce it

Every number traces to `cross_hardware.json` / `summary.json` / `equivalence.json` (D7). Open Quantum job id(s) `4f0ed05e-49f3-4ddb-ab75-03d00ec7998d, 5e453e57-fb83-4441-91af-5af8a3e654af, b2f1ed57-ef17-4a47-ab39-e67f7f36ba4d`; IBM job id(s) `d97qoc52su3c739if17g`. [`experiments/20260711-090430_p3b-openquantum`](https://github.com/MushiSenpai/qlab/tree/master/experiments/20260711-090430_p3b-openquantum).
