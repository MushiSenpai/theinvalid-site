---
title: "ISAZA: Mizo to English translation, licence-clean"
oneliner: "A translation stack for a low-resource language, built on two tracks that never share weights, because the famous models turned out to be non-commercial."
status: building
private: true
writeup: "/blog/the-license-audit-that-blocked-my-own-translation-model"
stack: ["FastAPI", "PostgreSQL", "DVC", "COMET-QE", "provenance ledger"]
started: 2026-07-03
order: 15
---

Mizo is spoken in northeast India and is missing from almost every public model. The first spec leaned on NLLB-200, MMS and SeamlessM4T. A real licence audit found all three carry non-commercial weights: the permissive badge on the repository covers the code, not the weights inside it.

So the stack has two tracks. Track A is the non-commercial prototype, quarantined. Track B is the commercially clean path. The separation is structural: a provenance ledger tags every source, and the build fails if a Track B training manifest references a non-commercial, unresolved or eval-only source. That gate is proven by a planted red-team fixture.

Foundations and data ingestion are done on CPU. Fieldwork and GPU training come next.
