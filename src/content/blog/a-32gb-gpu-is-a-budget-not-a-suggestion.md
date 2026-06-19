---
title: "A 32GB GPU is a budget, not a suggestion"
description: "How to fit a 30B multimodal LLM at 180K context on one RTX 5090: move the display to iGPU, never co-load models, and pick NVFP4 over FP8."
date: 2026-06-19
project: sovereign-ai-stack
tags: ["vllm", "rtx-5090", "vram", "nvfp4", "nemotron"]
---

If you have one RTX 5090 and you want to serve a 30B multimodal LLM, generate video, and run an audio stack on it, the first thing you have to internalise is that 32GB is not a lot. It is exactly enough — and only if you treat every gigabyte like money.

Here's what "treat it like money" actually means on my machine.

## Move the monitor off the 5090

The single highest-leverage change I made was unplugging the monitor from the GPU. The display now runs on the motherboard's integrated Radeon, BIOS Primary Display set to IGFX. The RTX 5090's idle baseline dropped from ~1GB to ~500 MiB.

That sounds like nothing. It is nothing — until you do the FP8 KV-cache math. ~500 MiB of recovered VRAM is **~25,000 additional context tokens** on Nemotron. Free, no quality loss, one BIOS toggle.

I would never have prioritised this if I weren't already past 28GB of allocated weights and cache. At that pressure, 500 MiB is the difference between a context window that fits a long forensic document and one that doesn't.

## Never co-load models

A 32GB card has room for one heavy stack at a time. Forensic LLM mode runs around 28–30GB. The video stack on ComfyUI eats roughly the same. Audio is smaller but still wants real VRAM. So I gave up on the idea of running them concurrently.

The handoff between them is a script, not a feature:

```
docker stop vllm-nemotron   # flushes ~30GB
creative-mode.sh            # brings ComfyUI up at 24–30GB
```

The forensic pass writes its conditioning JSON to disk. The next stage reads it. There is no shared VRAM, no co-tenant, no thrash. If I try to be clever and leave one container "just idling" while another loads, both crash on the second model's first big tensor with the classic `torch.cuda.OutOfMemoryError: CUDA out of memory` — and the LLM container ends up doing CPU-offload churn at 1–2 tok/s.

Mode-switch scripts are uglier than concurrent serving. They are also the only thing that works on 32GB without a constant fight.

## NVFP4 over FP8 for the weights

The non-obvious quantization choice: NVFP4 for weights, not FP8 or BF16.

The intuition you'd start with is "FP8 is smaller, FP8 is better." On paper, sure. In practice, FP8 weights leave you with ~2GB of KV-cache headroom on Nemotron at 32GB. Two concurrent long-context sessions push each other into system RAM and collapse the engine from ~45 tok/s down to 1–2 tok/s. The throughput cliff is sharp and surprising.

NVFP4 weights at ~18GB give you ~4–14GB of KV-cache headroom depending on context length. That headroom is what lets multiple agentic sessions coexist, and what lets the context window go to 180K stable. Measured throughput on Nemotron NVFP4 via vLLM: **275 tok/s**.

The lesson generalises: on a tight budget, the right quantization is whichever one leaves room for *the cache*, not whichever one shrinks the weights most.

## 180K context, not 256K

The theoretical KV ceiling on Nemotron at FP8 KV cache, 32GB, NVFP4 weights, is about 228K tokens. I run 180K — roughly 25% headroom.

The reason is operational, not architectural. Real workloads are not their stated context length. A "100K-token" forensic pass with three reference images and active reasoning will spike well above 100K of effective allocation. Without headroom you discover this via `OOM` mid-request, not in advance. I bump only when the workload actually shows context-full errors, never speculatively.

## The full budget on this machine

Forensic-mode VRAM allocation, measured:

- NVFP4 weights (Nemotron-3-Nano-Omni): ~18 GB
- Vision encoder (C-RADIOv4-H): ~1.2 GB
- Audio encoder (Parakeet-TDT-0.6B-v2): ~0.6 GB
- CUDA graphs + activations: ~2 GB
- Multimodal preprocessing buffers: ~1.5 GB
- KV cache (FP8, 180K context): ~7–8 GB
- Safety margin: ~1.5 GB

Total: ~28–30 GB. The remaining 2–4 GB is what disappears the moment you let a desktop environment, a stray Electron app, or a second model touch the card.

## What I'd tell you to check today

1. Run `nvidia-smi` on your idle workstation. If your discrete GPU shows ~1GB+ used with nothing running, your display is on it. Move the monitor to onboard graphics — BIOS setting, five-minute job.
2. Stop thinking about "what runs together." Start thinking about "what runs *between* what." A `docker stop` is faster than the OOM.
3. When choosing quants, do the math on the *cache*, not the weights. The cache is where concurrency lives or dies.
4. Leave headroom. A context window you can hit at 100% load is a context window you'll hit at 110% and crash on.

A 32GB card can do work that people assume requires 80GB. It just won't do all of it at once, and it won't forgive you for being sloppy about which gigabyte belongs to whom.

---

*The full VRAM budget, decision log, and mode-switch scripts live at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
