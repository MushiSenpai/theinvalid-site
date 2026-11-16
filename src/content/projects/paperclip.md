---
title: "Paperclip: an AI agent company on local hardware"
oneliner: "Five agents (coordinator, architect, builder, QA, reviewer) running on a local gateway, writing real code for a side project. Parked after it taught what it had to teach."
status: parked
private: true
writeup: "/blog/i-built-an-ai-agent-company-on-my-own-hardware"
stack: ["Paperclip", "Hermes", "LiteLLM", "local and free-tier models"]
started: 2026-06-10
order: 22
---

An experiment in governed multi-agent work. It ran: agents wrote TypeScript, built CI config and filed their own issues.

What it taught: every run carried a fixed 30 to 40 second overhead that had nothing to do with the model, a code review passed a broken health check, and "you are a coordinator, never implement" is a wish, not a rule, unless something enforces it. The overhead forced a two-tier design that outlived the experiment: a warm single-agent path for fast jobs, the governed multi-agent path only where the cost is worth it.

Those lessons now shape [KOUJOU](/projects/koujou), which replaces judgement with gates.
