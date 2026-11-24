---
title: "KOUJOU: a dark factory for software"
oneliner: "Frontier models write the spec and judge the result. A local model does the volume. A scripted scorecard decides, every month, whether that local model keeps its job."
status: building
private: true
stack: ["local 27B builder model", "cloud architect model", "independent auditor model", "scripted scorecards", "frozen eval set"]
started: 2026-11-04
order: 19
---

Koujou means factory. The design is at v3.4 and under active rework, so this page describes the rules, not results.

**Frontier directs, local executes, and it is measured.** The strong model writes the spec, audits it cold, and coaches only after two failed tries, with a hard cap on coaching per ticket. Coach turns are counted, because hints flatter the local model. A scripted scorecard per ticket and a frozen private eval set turn "which local model?" into a monthly keep-or-replace call with a fixed promotion margin.

**The best checker is a different family, not the strongest model.** A quantised local copy of the cloud architect would repeat its blind spots. A weaker model from another family is the better referee. Re-reading the role table per data class found a quiet self-review: on one class of ticket the same model wrote the spec and audited it.

**Gates, not judgement.** Ideas were borrowed from orchestrator tools (alert levels where unknown counts as broken, a per-turn record of which model served it). The tools themselves were not, because a factory that runs while the owner sleeps cannot depend on someone being awake to decide.

Two more rules it lives by: an improver must never be able to edit its own evaluator, and a project folder is added to the backup list the day it is created. That last one was learned the uncomfortable way.
