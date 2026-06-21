---
title: "Six hours in TensorRT-LLM so you don't have to"
description: "I picked NVIDIA's 'official' inference path for a multimodal model and spent six hours hitting walls, ending on one AutoDeploy can't fix. The lesson: 'theoretically compatible' is not 'someone benchmarked this.'"
date: 2026-06-22
project: sovereign-ai-stack
tags: ["vllm", "tensorrt-llm", "nemotron", "rtx-5090", "inference"]
---

The plan was supposed to be boring. Pull NVIDIA's official container, mount the weights, run it. I'd sized that phase at about two and a half hours. It took six-plus, ended in a wall I couldn't climb, and the actual deployment ended up being a different engine entirely.

This is the log of how I got there, because the conclusion — "use vLLM" — is worthless without the dead ends. The dead ends are the expensive part.

## The setup: why TRT-LLM looked like the right call

The model is NVIDIA's Nemotron-3-Nano-Omni — a 30B-total, 3B-active Mamba-Transformer MoE with a vision encoder (C-RADIOv4-H) and an audio encoder (Parakeet-TDT-0.6B-v2) baked in, quantized to NVFP4 so its ~21GB of weights fit on a single 32GB RTX 5090. The whole reason it's worth the trouble is that it reads video and images forensically and emits the dense, structured descriptions that downstream creative tools need to regenerate footage consistently.

For deployment, NVIDIA NIM was the obvious starting point. NVIDIA published `nvcr.io/nim/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning` as the *official* container. NIM is marketed as the production-grade path, TensorRT-LLM under the hood, with auto-selection of NVFP4 on Blackwell and the engine complexity hidden behind a `docker run`. On paper it ticked every box. My tool-evaluation checklist — tier, overlap, hardware fit, sovereignty, reversibility — passed it on a surface read.

That surface read is exactly where this went wrong.

## The wall: six failures, then the one that doesn't have a fix

I started Phase 1 on May 14–15 against the cookbook-recommended container, `nvcr.io/nvidia/tensorrt-llm/release:1.3.0rc13`. Rather than bail at the first error, I debugged each one. The point wasn't stubbornness — every fix taught me something real about where the gaps were. In order:

**The config schema was wrong.** The cookbook's YAML had fields the actual Pydantic models in 1.3.0rc13 rejected. I introspected `llm_args.py` inside the container and rewrote the config to match the real schema. The cookbook was out of date.

**The subcommand was wrong.** Cookbook says `trtllm-serve <model>`; 1.3.0rc13 wants `trtllm-serve serve <model>`. Small, but a sign of how far the docs had drifted from the build.

**Mamba kernels were missing.** Nemotron's hybrid backbone needs `mamba_ssm` and `causal_conv1d`, and the container ships neither. The PyPI wheels target stable PyTorch, not NVIDIA's nightly (`torch 2.11.0a0+...nv26.02`), so I compiled from source inside the container — `MAMBA_FORCE_BUILD=TRUE`, `CAUSAL_CONV1D_FORCE_BUILD=TRUE`, `TORCH_CUDA_ARCH_LIST=12.0` to build only for SM_120 (about 7× faster than building for every arch). Roughly 5–15 minutes of CUDA kernel compilation, persisted to a named volume so I didn't pay it twice.

**CUTLASS version conflict.** Installing `mamba_ssm` upgrades `nvidia-cutlass-dsl` from 4.3.4 to 4.5.0; TRT-LLM 1.3.0rc13 is pinned to 4.3.4 and breaks at import. Fix: downgrade afterward with `--no-deps`. The compiled Mamba kernels bundle their own and don't care at runtime.

**A model bug: `use_cache` kwarg.** Once TRT-LLM imported and started loading, AutoDeploy called the model with `use_cache=...`, but the model's custom `modeling.py` only accepts `config`. I patched line 76 to add `**kwargs`:

```python
def __init__(self, config: NemotronH_Nano_Omni_Reasoning_V3_Config, **kwargs):
```

(Backup at `modeling.py.original`.) This is a genuine upstream bug in the model's HuggingFace code, not something I caused — it should be fixed by NVIDIA.

**`HF_HUB_OFFLINE` and missing multimodal deps.** The model reaches HuggingFace at runtime to pull the vision encoder's auxiliary files; my `HF_HUB_OFFLINE=1` blocked that, so I removed it and added a volume to persist the downloads. Then the multimodal path wanted `timm`, `open_clip_torch`, `librosa`, `soundfile`, `decord`, `ftfy`, `regex` — none in the container — so those went into the startup script too.

Six fixes deep, the model finally reached construction. And then:

```
TypeError: NemotronH_Nano_Omni_Reasoning_V3.forward() missing 1 required positional argument: 'pixel_values'
```

This is the wall. AutoDeploy traces the model's `forward()` with text-only inputs during graph capture. But Nemotron's `forward()` *requires* `pixel_values` — it's multimodal-mandatory, not text-with-optional-image — and AutoDeploy in 1.3.0rc13 doesn't know how to synthesize dummy multimodal inputs for the trace. This isn't a one-line patch like the `use_cache` thing. It's a structural gap: *AutoDeploy doesn't support multimodal-mandatory models.* There's a `--backend pytorch` escape hatch that skips the tracing pass, but at that point I stopped and went to research instead of guessing.

## The research turn: NVIDIA doesn't use TRT-LLM for this either

A web search for how this model is actually run turned up four facts that reframed the whole exercise:

1. **NVIDIA's own Nemotron-3-Nano-Omni paper** (April 2026) states: *"All measurements use a single NVIDIA B200 GPU and vLLM nightly as of 2026-04-19 with EVS 50%. Nemotron 3 Nano Omni is evaluated in NVFP4."* NVIDIA benchmarks their own model, on their own flagship hardware, on **vLLM** — not TRT-LLM.

2. **The HuggingFace model card** for all three weight variants (BF16, FP8, NVFP4) says explicitly: *"Required version: vLLM 0.20.0 is needed."*

3. **vLLM has a dedicated blog post** announcing day-zero support: NVFP4 on Blackwell, 3D conv video kernels, EVS, and the `nemotron_v3` reasoning parser.

4. **NVIDIA's model card admits** that for the constrained deployment targets it lists, *"vLLM, SGLang, Ollama, llama.cpp..."* are the supported paths — the consumer-card TRT-LLM coverage is a different, thinner story than the data-center one.

The conclusion writes itself: TRT-LLM 1.3.0rc13 is undertested for *this specific model*. The cookbook's happy path works for text-only Nemotron variants; the Omni multimodal variant walks straight into AutoDeploy's blind spot. vLLM 0.20.0 is the path NVIDIA themselves validate.

## The decision (and the part where the use case helped)

There was a second realignment happening in parallel. Mid-pivot, the real use case got clarified: not agent throughput, but commercial-grade creative work on pre-shot client video. Sequential, not concurrent — Nemotron analyzes, flushes, then the creative stack runs. Forensic detail over speed, every frame analyzed, 180K context for dense descriptions plus reasoning plus reference images.

That mattered because the one argument left for TRT-LLM was raw text-generation throughput — maybe a 10–20% edge over vLLM on Blackwell. And that edge is completely irrelevant when the engine *can't read the video at all*. The thing TRT-LLM might be faster at is not the thing I needed. So vLLM wasn't just the technical call; it was the strategic one. I'd been asking "which engine is faster?" when the question was "which engine can do the job?"

## What it cost, and what it saved

The cost was six-plus hours against a phase I'd budgeted for two and a half, and a stack of debugging that produced exactly zero serving capability. Not nothing, though — every one of those six fixes was real upstream knowledge, and the `modeling.py` patch is a legitimate bug that needed finding.

The savings show up at every startup. vLLM goes from `docker compose up` to a ready server — weights loaded, KV cache allocated, CUDA graphs captured, Uvicorn listening on `:8000` — in about **5–10 minutes**. The TRT-LLM path I was fighting toward carries an engine-compile step of roughly **30 minutes** before it serves a single token. On a stack I switch in and out of constantly between forensic and creative modes, that gap is paid back over and over.

One operational caveat I'd flag for anyone copying this on the same hardware: stable vLLM releases don't ship SM_120 kernels for the RTX 5090 (Blackwell), so you want a nightly/cu130 image or a pinned version known to include them — otherwise you get `no kernel image available` at first inference, not at load, which is a much worse place to discover it.

## The one-line lesson

My tool-evaluation checklist passed NIM on a surface read, and the question it should have asked harder was hardware fit. Not "is this theoretically compatible with my GPU?" — NVFP4 on SM_120 is, on paper. The real question is: **has anyone actually validated this exact engine, on this class of hardware, with this specific model variant, in public?** "Theoretically compatible" and "someone has benchmarked this and published it" are different claims, and only the second one is worth betting a deployment on.

If I'd demanded that sign-off up front — an "NVIDIA benchmarked this combination publicly" gate — I'd have found the paper that uses vLLM in ten minutes instead of six hours. The dead end was the tuition. This post is me passing it on so you don't have to pay it twice.

---

*The full decision log — all six TRT-LLM failures, the research, and the vLLM config with every flag justified — lives at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
