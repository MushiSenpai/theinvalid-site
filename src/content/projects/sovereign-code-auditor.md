---
title: "SovereignSec-AI — Code-Security Auditor"
oneliner: "A fully air-gapped AI code-security auditor — cross-file taint + SAST + an LLM, hybridized — that finds vulnerabilities across files and returns deterministic, proof-carrying findings."
status: shipped
repo: "https://github.com/MushiSenpai/SovereignSec-AI-Auditor"
stack: ["tree-sitter taint", "Semgrep OSS", "Qwen2.5-Coder", "QLoRA", "vLLM", "Docker --network=none"]
started: 2026-06-22
order: 0
---

A local, sovereign code auditor for teams whose code can't leave their network. I built it as a *system* — a custom cross-file taint engine, SAST, an agentic loop, and a validation oracle — with an LLM as one component, and proved with a benchmark suite that the system beats the LLM alone: **0.97** on a hard 29-module / 6-CWE benchmark vs **0.90** for the LLM by itself. Findings are proof-carrying — the deterministic core returns `✔ PROVEN (taint)` paths you can triage first, no GPU required (`python -m sscai audit <repo>`, runnable under `--network=none`).

The headline finding, documented honestly: a fine-tuned model adds **output discipline — schema and calibration — not detection capability**. Measuring that cleanly caught 4 of my own eval bugs; capability lives in the architecture, not the fine-tune. I trained 7B and 32B QLoRA adapters on a single RTX 5090 and published both with honest model cards.

**Links:** [GitHub](https://github.com/MushiSenpai/SovereignSec-AI-Auditor) · [HF 7B adapter](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-7B) · [HF 32B adapter](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-32B) · [the plain-English writeup](https://github.com/MushiSenpai/SovereignSec-AI-Auditor/blob/main/INSIGHTS.md)
