---
title: "Mushishi Sovereign AI Stack"
oneliner: "Self-hosted multimodal LLM infrastructure where 'client data never touches a cloud API' is enforced by routing, not policy."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-sovereign-ai-stack"
stack: ["vLLM", "Nemotron NVFP4", "LiteLLM", "llama.cpp", "Tailscale", "restic"]
started: 2026-05-14
order: 1
---

One RTX 5090, 32GB of VRAM, and three fallback chains with three different guarantees — including a client profile that *refuses* to fall back, because for paid work, failing loudly beats degrading silently.

Measured: **275 tok/s** on Nemotron NVFP4 via vLLM, 180K context at FP8 KV cache. The repo carries the full Decision Log, including the six hours of TensorRT-LLM debugging that ended in choosing vLLM — the dead ends are documented because they were the expensive part.
