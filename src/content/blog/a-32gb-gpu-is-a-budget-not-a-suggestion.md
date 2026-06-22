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

That sounds like nothing. It is nothing — until you're already past 28GB of allocated weights and buffers, where ~500 MiB back is the difference between a stack that fits and one that OOMs on its first big tensor. (An earlier version of this post sold that 500 MiB as "~25,000 more context tokens." That was wrong — Nemotron is a Mamba-hybrid and its attention-KV is far cheaper per token than I'd assumed, so KV isn't what 500 MiB buys you, and KV isn't the thing you're short of. The full correction is its own post: [I had my KV-cache math 14× wrong](/blog/i-had-my-kv-cache-math-14x-wrong).)

The honest framing: ~500 MiB is ~500 MiB back in the **total** VRAM budget — the budget that's actually tight on this card. Free, no quality loss, one BIOS toggle.

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

The intuition you'd start with is "FP8 is smaller, FP8 is better." On paper, sure. In practice, FP8 weights leave you with only ~2GB of free VRAM on Nemotron at 32GB. Two concurrent long-context sessions exhaust that — between activations and each sequence's working set they push each other into system RAM and collapse the engine from ~45 tok/s down to 1–2 tok/s. The throughput cliff is sharp and surprising.

NVFP4 weights at ~18GB give you ~4–14GB of free VRAM depending on context length. That headroom is what lets multiple agentic sessions coexist, and what lets the context window go to 180K stable. Measured throughput on Nemotron NVFP4 via vLLM: **275 tok/s**.

The lesson generalises: on a tight budget, the right quantization is whichever one leaves the most *total* VRAM free for everything that isn't weights — activations, buffers, per-sequence state — not whichever one shrinks the weights most. (On a Mamba-hybrid that "everything else" is the constraint; the attention-KV slice of it is tiny — [the correction](/blog/i-had-my-kv-cache-math-14x-wrong).)

## 180K context, not 256K

Worth being precise about three numbers I used to collapse into one. **256K** is the model's `max_position_embeddings` — the theoretical architectural maximum, a position cap, not a memory statement. **~228K** is the practical ceiling: what actually fits once weights, CUDA graphs, multimodal buffers and per-sequence Mamba state are accounted for — a *total-VRAM* ceiling, **not** a KV ceiling (on a Mamba-hybrid, attention-KV is cheap enough that it's never the binding constraint — [see the correction](/blog/i-had-my-kv-cache-math-14x-wrong)). I run **180K** — roughly 25% headroom under that practical ceiling.

The reason is operational, not architectural. Real workloads are not their stated context length. A "100K-token" forensic pass with three reference images and active reasoning will spike well above 100K of effective allocation. Without headroom you discover this via `OOM` mid-request, not in advance. I bump only when the workload actually shows context-full errors, never speculatively.

## The full budget on this machine

Forensic-mode VRAM allocation, measured:

- NVFP4 weights (Nemotron-3-Nano-Omni): ~18 GB
- Vision encoder (C-RADIOv4-H): ~1.2 GB
- Audio encoder (Parakeet-TDT-0.6B-v2): ~0.6 GB
- CUDA graphs + activations: ~2 GB
- Multimodal preprocessing buffers: ~1.5 GB
- Attention-KV cache (FP8, 180K context): **under ~0.6 GB** — see note
- Per-sequence Mamba state + concurrency working set + safety margin: the rest

Total: ~28–30 GB. The remaining 2–4 GB is what disappears the moment you let a desktop environment, a stray Electron app, or a second model touch the card.

> **The KV line used to read ~7–8 GB here. That was the dense-transformer overestimate.** Nemotron is a NemotronH Mamba-2/Transformer hybrid — only 6 of its 52 layers do attention, so attention-KV costs ~3 KB/token (~350K tokens per GiB). At 180K context that's roughly half a gigabyte, not 7–8. The lesson — that per-token KV is nearly negligible on a hybrid, and the 32GB limit is dominated by weights + CUDA graphs + multimodal buffers + Mamba per-sequence state rather than by KV — has [its own post](/blog/i-had-my-kv-cache-math-14x-wrong).

## What I'd tell you to check today

1. Run `nvidia-smi` on your idle workstation. If your discrete GPU shows ~1GB+ used with nothing running, your display is on it. Move the monitor to onboard graphics — BIOS setting, five-minute job.
2. Stop thinking about "what runs together." Start thinking about "what runs *between* what." A `docker stop` is faster than the OOM.
3. When choosing quants, do the math on the *cache*, not the weights. The cache is where concurrency lives or dies.
4. Leave headroom. A context window you can hit at 100% load is a context window you'll hit at 110% and crash on.

A 32GB card can do work that people assume requires 80GB. It just won't do all of it at once, and it won't forgive you for being sloppy about which gigabyte belongs to whom.

---

*The full VRAM budget, decision log, and mode-switch scripts live at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
