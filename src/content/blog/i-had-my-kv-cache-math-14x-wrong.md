---
title: "I had my KV-cache math 14× wrong (I treated my Mamba-hybrid like a transformer)"
description: "How much KV-cache does a Mamba-2/Transformer hybrid use per token? I priced all 52 layers when only 6 attend — my numbers came out 7–14× too low."
date: 2026-06-21
project: sovereign-ai-stack
tags: ["nemotron", "mamba", "kv-cache", "vllm", "vram"]
---

A few days ago I published a post about treating 32GB of VRAM like a budget. In it I made a confident, tidy claim: freeing ~500 MiB of VRAM buys you about **25,000 more context tokens** of KV-cache on Nemotron. It was a clean number, it sounded right, and it was wrong — the real figure for that 500 MiB is closer to **170,000** tokens (I was ~7× too low), and the per-gigabyte rate I'd baked into my spec was off by a full **~14×**.

This is the correction, and the reason I got it wrong is more interesting than the arithmetic.

## The mistake: I costed KV like a transformer

The KV-cache formula everyone carries in their head is for a dense transformer:

```
bytes/token = 2 (K and V) × num_layers × num_kv_heads × head_dim × dtype_bytes
```

The load-bearing term is `num_layers`. In a normal transformer, *every* layer is an attention layer, so every layer contributes a K and a V tensor to the cache. For a ~50-layer model that's a big number, and dividing 500 MiB by a big per-token number gives you a small token count. That's how I landed on ~25,000 tokens.

The problem: **Nemotron-3-Nano-Omni is not a transformer.** It's a NemotronH model — a **Mamba-2 / Transformer-MoE hybrid**. And on a hybrid, `num_layers` is the wrong number to multiply by.

## What a hybrid actually does

NemotronH interleaves three kinds of layers: Mamba-2 (state-space) layers, MoE feed-forward layers, and a small number of self-attention layers. The whole point of the architecture is that attention is *rare*. Mamba-2 layers carry sequence information through a fixed-size recurrent state, not a growing KV-cache, so they cost the same per token whether you're at token 100 or token 100,000.

Concretely, in this model **only 6 of the 52 layers do attention.** The other 46 are Mamba-2 or MoE. So the only layers that contribute to the KV-cache are those 6 — not all 52.

That single substitution is the entire 14× error. I multiplied by 52 (well, by "all of them"); I should have multiplied by 6.

## The corrected math

Per-token attention-KV on this model, at FP8 KV-cache:

```
bytes/token = 2 (K and V) × 6 (attention layers) × 2 × 128 (head dim)
            = 3,072 bytes/token   (~3 KB/token)
```

Now redo the headroom calc:

```
500 MiB / 3,072 bytes  ≈  170,000 tokens
1 GiB    / 3,072 bytes  ≈  ~350,000 tokens
```

So freeing ~500 MiB doesn't buy ~25K tokens of attention-KV. It buys roughly **170,000 tokens** of attention-KV. Per GiB, a NemotronH hybrid stores around **~350K tokens** of attention-KV — call the rate **~3 KB/token**. My original number treated attention-KV as ~14× more expensive than it is, because I priced 52 layers of cache for a model that only caches 6.

## The bigger correction: KV isn't the bottleneck anyway

Here's the part that actually changed how I think about the box.

Once you realize attention-KV on a hybrid is this cheap — ~3 KB/token, ~350K tokens per GiB — the obvious follow-up is: *then why am I capping context at 180K?* If KV were the constraint, I'd have room for far more.

The answer is that **on a hybrid, attention-KV is not the context bottleneck.** It's nearly negligible. The 32GB ceiling is dominated by everything *else*:

- **Weights** (~18GB at NVFP4) — by far the biggest line.
- **CUDA graphs and activations** (~2GB) — captured once, fixed cost.
- **Multimodal preprocessing buffers** (~1.5GB) — vision + audio encoders for Nemotron-Omni.
- **Mamba-2 per-sequence state** — every concurrent sequence carries its recurrent state, and that scales with concurrency, not with context length.

The attention-KV — the thing I'd been agonizing over — is a small slice of what's left after all of that. The practical limit on context isn't "how many tokens of KV fit," it's "total VRAM allocation across weights + graphs + multimodal buffers + per-sequence Mamba state + that small KV slice." You hit the total-allocation wall long before you run out of attention-KV.

So the iGPU trick (moving the display off the 5090 to free ~500 MiB) is still worth doing — but for the honest reason: it's ~500 MiB back in the *total* budget, the budget that's actually tight. It is not "25,000 more tokens," and framing it as a KV win was costing-by-the-wrong-line-item.

## Where I'd been double-counting

The original FP8-KV-cache note in my spec said FP8 "halves memory per token (~32KB → ~16KB at MoE 30B sizes)" and used a "~32 KB per token" figure to derive a ~228K-token ceiling. That ~32 KB/token is a dense-transformer-shaped number — it's roughly what you'd get multiplying across all the layers. For a NemotronH hybrid the attention-KV per token is an order of magnitude smaller. The ~228K and ~180K numbers I run aren't *KV* ceilings at all; they're **total-VRAM** ceilings, and the model's `max_position_embeddings` of **256K** is a separate, purely theoretical cap. Three different numbers I had been quietly collapsing into one:

- **256K** — `max_position_embeddings`. The architecture's theoretical maximum position. Not a memory statement.
- **~228K** — the practical total-VRAM ceiling: what actually fits once weights, graphs, multimodal buffers, and per-sequence state are accounted for. *Not* a KV ceiling.
- **180K** — what I run, with ~25% operational headroom for spiky real workloads.

## The lesson

Compute KV-cache against the **actual architecture**, not the transformer template in your head. For a Mamba-2 / Transformer hybrid like NemotronH, per-token KV is nearly negligible because only a handful of layers attend — here, 6 of 52 — and the recurrent layers don't grow a cache at all. If you find yourself multiplying by the full layer count on a hybrid, stop: you're about to be wrong by the ratio of total layers to attention layers, which for this model is ~8–9×. Compounded with some older sloppiness, that turned a clean, confident "25,000 tokens" into a figure ~7× too low — and the per-gigabyte rate in my spec ~14× too low.

The honest version of my original post: the iGPU switch frees ~500 MiB of *total* VRAM, which is genuinely useful on a 32GB card; attention-KV on a hybrid is so cheap it's never the thing you're short of; and the real scarcity is total allocation — weights first, then graphs, multimodal buffers, and Mamba state.

I've corrected the [32GB budget post](/blog/a-32gb-gpu-is-a-budget-not-a-suggestion) and the spec to match. Leaving the wrong number up would have been the easier choice. It also would have been a lie with a footnote.

## A note on "how wrong," precisely

There are really three numbers hiding behind the title, and on a post about KV math I owe you all three:

- The specific claim — *500 MiB ≈ 25K tokens* — was **~7× too low** (it's ~170K).
- The per-gigabyte rate in my spec — *1 GB ≈ 25K tokens* — was **~14× too low** (it's ~350K/GiB). That's the "14×" in the title: the worst, most-published version of the error.
- The root cause — pricing **52 layers** of KV-cache when only **6** attend — is an **~8.7× per-token** overestimate. The remaining gap to 14× is older sloppiness I'm not proud of.

One mistake, three magnitudes, depending on which number you look at. I kept the worst one in the title on purpose.

---

*The corrected VRAM budget and KV-cache math live, failure included, at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
