---
title: "Killing the two-pass dance: fitting a 30B multimodal LLM and a TTS engine on one RTX 5090"
description: "Six vLLM 0.20.0 boot attempts to coexist Nemotron-3-Nano-Omni NVFP4 and Fish Speech 1.5 on 32GB, and why --max-num-batched-tokens 16384→4096 was the fix nobody documents."
date: 2026-08-29
project: comic-narrator
tags: ["vllm", "local-llm", "rtx-5090", "tts", "nvidia"]
---

My comic-narrator pipeline needs two GPU tenants running at the same time: **Nemotron-3-Nano-Omni** (30B-A3B, NVFP4) reads comic pages, and **Fish Speech 1.5** turns the extracted dialogue into voiced audio. The forensic Nemotron config eats about 30 GB of the RTX 5090's 32 GB (180K context, FP8 KV cache, `gpu-memory-utilization 0.92`). Fish Speech wants another 2.5 GB plus inference headroom.

They could not coexist. Every narrated page meant the two-pass dance: load Nemotron, run the vision phases, save to JSON, tear it down, load the audio stack, run audio from the saved files. Two mode switches. About ten minutes of model loading per session. The pipeline grew `--from-page-json` and `--from-script-json` resume flags specifically to survive this handoff.

The fix seemed obvious: a lighter Nemotron config that leaves room for TTS. Drop the context window, lower the memory cap, done. What followed was six boot attempts, and the gap between "obvious" and "running" is where all the lessons live.

## The errors

**Attempt 1** (`gpu-memory-utilization 0.68`, 64K context):

```
Free memory on device (20.09/31.36 GiB) is less than desired (21.32 GiB)
```

Two surprises in one line. First, vLLM's utilization knob is a fraction of *total* VRAM, checked against *free* VRAM at boot. It does not adapt to what is actually available. Second, something was holding ~9 GB that should not have been: the audio worker's CUDA allocator, still resident from a prior TTS warmup. Torch caching allocators do not release memory just because a job finished.

**Attempt 2** (same config, retried on a quiet GPU):

```
moe_backend='triton' is not supported for NvFP4 MoE
```

I had copied the engine flags from my own stack documentation, which still said the forensic config uses `--moe-backend triton` and `VLLM_USE_FLASHINFER_MOE_FP4=1`. The as-built compose file had removed both months ago (they break NVFP4 MoE on SM120). The spec lied. The running system knew better.

**Attempts 3-5** (`gpu-memory-utilization` 0.72, then 0.78, then 0.78 with 32K context):

```
No available memory for the cache blocks
```

This is where folk numbers fell apart. The model card and my own architecture notes said the NVFP4 weights were ~18 GB. The boot log disagreed:

```
Checkpoint size: 20.87 GiB
Model loading took 21.5 GiB memory
Available KV cache memory: -1.62 GiB
```

21.5 GiB of weights. About 0.4 GiB of CUDA graphs. And then the real thief: the profiling pass. Before allocating KV cache, vLLM simulates a worst-case forward pass sized by `--max-num-batched-tokens` (I had 16384, inherited from the forensic config) and the multimodal image limits (8 images). That peak gets reserved permanently. My "light" config was budgeting like the heavy one.

## The fix

Right-size the profiling pass to the actual workload. The comic pipeline sends one image per request and never needs long batches:

```
--max-model-len 32768            # was 180000
--max-num-seqs 2                 # was 4
--max-num-batched-tokens 4096    # was 16384  ← the fix that mattered
--limit-mm-per-prompt '{"image": 2}'   # was 8
--gpu-memory-utilization 0.82
```

**Attempt 6** booted clean:

```
Available KV cache memory: 1.1 GiB
GPU KV cache size: 76,608 tokens
```

Final budget on a loaded card: Nemotron NVFP4 weights 21.5 GiB, CUDA graphs plus activations (4K batch profile) ~2.6 GiB, KV cache 1.1 GiB, vLLM total ~25.7 GiB. Fish Speech 1.5 adds 2.3 GiB. About 4 GiB of headroom for TTS inference spikes. Both models loaded, both available.

One command:

```bash
agent-mode.sh
comic-narrator book.pdf --layout manga -o book.mp4
```

A manga PDF goes in; a narrated, voice-acted, sound-bedded, camera-animated MP4 comes out. No VRAM handoff choreography required.

## What I'd tell you to check today

1. **`gpu-memory-utilization` is a promise about total VRAM, validated against free VRAM at startup.** Other tenants' allocator bloat will fail your boot even if the steady state fits. Start the big tenant first, or force the small ones to release before it.

2. **The model card weight size is wrong. Read the log.** `Model loading took X GiB` from a real boot, not the model card and not your own architecture notes. My docs were wrong about the weights and about two engine flags simultaneously.

3. **`--max-num-batched-tokens` is the highest-leverage knob nobody mentions.** It controls the size of the profiling reservation, not just batch throughput. If your workload is single-image and short-batch, say so: 16384 to 4096 freed multiple GiB here.

4. **Iterate on the error, not the theory.** Six boots at three minutes each beat any amount of VRAM arithmetic on paper. The log line `Available KV cache memory: -1.62 GiB` told me exactly how far off I was. No spreadsheet did.

Stack: RTX 5090 32GB, vLLM 0.20.0, Nemotron-3-Nano-Omni NVFP4, Fish Speech 1.5, Ubuntu 24.04.

---

*The comic pipeline is at [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator).*
