---
title: "NAVARATNA: a pool of specialist local models"
oneliner: "Plan stage. Instead of one generalist LLM, a routed pool of small specialists on CPU and RAM that borrows the GPU only when the render queue is empty."
status: planned
private: true
stack: ["llama.cpp", "LiteLLM", "routing model (mmBERT-base family)", "systemd"]
started: 2026-11-04
order: 20
---

Nothing is built. This page is the plan and what planning already got wrong, because the mistakes were the useful part.

**Decisions so far.** A task gets its own specialist only when a machine can check its output (it renders, compiles, or scores). The router is sticky per session, because switching models mid-session throws away the prompt cache, and on CPU that costs minutes, not cents. Every agent profile gets a prompt budget. The pool never co-runs with a film render: it borrows the card when the queue is empty and drains back to CPU first. Any new classifier runs in shadow, log-only, for a month.

**What planning caught.**
- Two rounds of research missed an open routing model that already did what the plan was going to hand-build. The search had been framed around one product's alternatives, not the job. Rule since: survey by function, and inventory what is already running on the machine.
- The GPU runs at PCIe x8, not x16, because of where the NVMe drives sit. Nobody chose that. It hurts weight streaming, not resident models.
- A memory lock set in a user service silently did nothing, because it cannot exceed the user manager's own limit. The weights were being swapped out.
- A chatbot's list of "models to run" was half real. Checking each name against the model hub took minutes and found the one genuine win the chat had missed.

The build waits on a hardware fix and a few owner decisions.
