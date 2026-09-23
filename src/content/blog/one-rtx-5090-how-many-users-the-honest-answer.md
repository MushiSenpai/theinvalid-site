---
title: "One RTX 5090, how many users: the honest answer"
description: "vLLM continuous batching stress test on Nemotron NVFP4 — throughput scales to 8 concurrent users, then the KV-cache fills and throughput flatlines at 728 tok/s."
date: 2026-09-23
project: sovereign-ai-stack
tags: ["rtx-5090", "vllm", "nemotron", "concurrency", "inference"]
---

The question comes up constantly in local-LLM forums: "Great throughput, but how many people can actually use this at once?" The answer is always "it depends" with no data attached. I ran the test instead.

## The setup

One RTX 5090, 32GB VRAM. Nemotron-3-Nano-Omni at NVFP4 quantization, served by vLLM 0.20.0. Single-stream baseline: **276 tok/s**. The earlier posts cover how I got here; the relevant context is that NVFP4 weights sit at ~18GB, leaving 4-14GB for KV cache depending on context length. That remaining headroom is what determines concurrency.

On June 13 I ran a concurrency sweep: 1, 2, 4, 8, and higher simultaneous users, each firing continuous requests. I measured aggregate throughput and observed where it stopped climbing.

## The numbers

| Concurrent users | Aggregate tok/s | Multiplier vs solo | Avg latency (s) |
|---|---|---|---|
| 1 | 276 | 1.0x | 1.1 |
| 2 | 385 | 1.4x | 1.6 |
| 4 | 652 | 2.4x | 1.8 |
| 8 | 728 | 2.6x | 2.5 |
| 16 | 727 | 2.6x | 4.1 |

The GPU does not divide evenly. At 4 concurrent users, aggregate throughput is 2.4x the solo rate, not 4x. At 8, it's 2.6x. At 16, the aggregate line is flat, meaning the 9th through 16th users are queuing, not running in parallel. The knee is exactly at 8 concurrent.

## Why this curve

vLLM continuous batching is the reason throughput scales up rather than down as users are added. Instead of completing one generation before starting the next, it slots tokens from queued requests into each forward pass as prior sequences free up space. The GPU is better utilized at 4 concurrent users than at 1 because idle CUDA cores get work.

The ceiling is memory, not compute. The ~728 tok/s plateau corresponds to the point where KV-cache memory for 8 concurrent heavy-context requests fills the available headroom. New requests queue for a slot rather than starting immediately, and aggregate throughput stops climbing. The GPU's compute throughput is not the constraint at that point.

"8 concurrent users" is specifically the limit for heavy workloads: long document analysis, 100K+ token contexts. For lighter chat-style requests (8-16K context), each session's KV footprint is much smaller, so more fit within the same headroom simultaneously.

## What 728 tok/s actually buys

Two capacity numbers, depending on the workload:

**Heavy users** (forensic analysis, long documents): latency holds under 2.5 seconds at 8 concurrent requests. At 16, it climbs to 4.1 seconds, which is noticeable. In practice these sessions are staggered, not simultaneous. Realistic capacity: **10-15 heavy users**.

**Light users** (short-context chat, Q&A): smaller KV footprint means more concurrent slots available before the ceiling hits. Realistic capacity: **30-40 light-chat users**.

The same GPU, the same model, the same deployment: a 3-4x difference in capacity depending solely on context length per request.

## The transferable lesson

Single-stream throughput is the number everyone benchmarks and quotes. "276 tok/s" is a clean headline. But it is the ceiling for one user, not a capacity number.

Real capacity is where the KV-cache fills at your workload's typical context length. That ceiling is lower than single-stream throughput implies, and it varies with context in ways that matter for planning.

Capacity has two axes: compute and memory. On a memory-constrained GPU like the 5090, you hit the KV-cache floor before you exhaust compute throughput. The throughput plateau and the memory plateau happen at the same concurrency level. If you ignore one axis, your capacity estimate is wrong by 2-3x.

## What I'd tell you to check today

1. **Measure single-stream throughput first.** It establishes the upper bound; actual serving capacity will be lower.
2. **Profile typical request context lengths.** Not the model's maximum, not your theoretical maximum: what your workloads actually send. This number drives KV-cache consumption and therefore concurrent capacity more than anything else.
3. **Watch `nvidia-smi` memory at increasing concurrency.** The moment utilization plateaus near the ceiling is your real capacity limit, not the compute saturation point.
4. **Don't conflate aggregate and per-user latency.** 728 tok/s aggregate is the ceiling regardless of how many users are queued behind it. Going from 8 to 16 concurrent added no throughput, but it doubled average latency from 2.5s to 4.1s. Beyond 8 concurrent, you are buying latency, not speed.

The correct answer to "how many users?" is two numbers: one for heavy context workloads, one for light ones. Anyone giving you one number is averaging across those two populations and the average will be wrong for both.

---

*The stress test data, vLLM config, and full Decision Log live at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
