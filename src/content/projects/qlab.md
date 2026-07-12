---
title: "QLAB — Honest Quantum-ML Lab"
oneliner: "A local-first quantum machine-learning lab with one rule: a quantum number is never shown alone. Eleven experiments, every one raced against a classical baseline, two runs on real quantum hardware, zero manufactured wins."
status: shipped
caseStudy: "/case-studies-honest-qml-lab/"
stack: ["PennyLane", "Qiskit", "IBM Quantum", "IonQ", "cuQuantum", "scikit-learn baselines"]
started: 2026-07-08
order: -1
---

Quantum computing is the most over-marketed idea in tech: vendors publish the cherry-picked win and almost nobody publishes the honest classical baseline next to it. QLAB exists to be that neutral read. Every quantum model is raced against ordinary classical methods (logistic regression, an MLP, an RBF-SVM) on the identical data split, and every number traces to a reproducible job id.

The capstone: I reproduced a published quantum advantage (0.900 vs a weak classical 0.730), then erased it three ways. A fairly tuned classical model beat it (0.910), classical dequantization matched it (0.900), and device noise took the rest. Underneath: a barren plateau collapsing gradient variance **1,436×**, the same circuit run on two real QPUs (superconducting ibm_fez and trapped-ion IonQ Forte), and the GPU running small circuits ~60× slower than the CPU. The finding across five state-of-the-art techniques is one wall: whatever makes a quantum ML model trainable tends to make it classically reproducible. That result sells judgment, not hype.

**Links:** [the full case study, all eleven honest findings](/case-studies-honest-qml-lab/) · the 7-post experiment series in [the knowledge base](/blog#blog). Repo goes public after its release pass.
