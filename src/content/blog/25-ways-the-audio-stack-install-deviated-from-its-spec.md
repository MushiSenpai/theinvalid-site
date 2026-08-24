---
title: "25 ways the audio stack install deviated from its spec"
description: "Fish Speech, WhisperX, LatentSync 1.6, Hallo2, and YuE 7B on an RTX 5090 -- the April spec said one thing, May's install said 25 other things."
date: 2026-08-24
project: audio-stack
tags: ["fish-speech", "whisperx", "latentsync", "hallo2", "yue"]
---

Three meta-lessons live at the bottom of the audio stack's LESSONS.md:

1. Entry points lie.
2. Pin everything.
3. The spec is a hypothesis.

I could have written these before starting. I wrote them after, when the deviation count hit 25.

## The stack

A fully local audio pipeline on one RTX 5090: Fish Speech v1.5.1 for TTS and voice cloning, WhisperX (faster-whisper) for transcription, MuseTalk 1.5 / Hallo2 / LatentSync 1.6 for lip-sync avatars, and YuE 7B for music generation. Jobs route through an RQ gateway backed by Redis. Everything MIT or Apache 2.0. Designed in April. Working in June. The gap between those two dates is LESSONS.md.

## The worker that vanishes silently

The gateway only enqueues jobs to Redis. A separate `audio-worker` container consumes them. Without it, jobs sit in `queued` forever and nothing errors: the queue is healthy, Redis is healthy, everything looks fine. You just never get results.

The worker must also carry `runtime: nvidia` and `NVIDIA_VISIBLE_DEVICES=all` in its compose block. Without those:

```
CUDA driver version is insufficient for CUDA runtime version
```

from CTranslate2 the instant WhisperX tries to infer. The error does not mention Docker or NVIDIA runtime.

## Entry points lie

Three of five model repos had a different real entry point than their README described.

**MuseTalk 1.5**: the entry point is `scripts/inference.py`, driven by a per-job YAML config, not CLI media args. **YuE 7B**: the root `infer.py` is a stub. Actual inference lives at `inference/infer.py` and must run with `cwd=inference/` because xcodec paths are relative. **Hallo2**: the weights live in `fudan-generative-ai/hallo2`. The similarly-named org without weights costs you an afternoon.

Bonus YuE gotcha: a plain `git clone` gives you 133-byte LFS pointer stubs where the 1.3GB `xcodec_mini_infer` checkpoint should be. Use the `hf` CLI instead. Also: YuE outputs MP3, mono, 44.1kHz. Workers globbing for `*.wav` find nothing.

## WhisperX does not take HuggingFace safetensors

faster-whisper requires a CTranslate2 model. Convert inside the container:

```
ct2-transformers-converter --model openai/whisper-large-v3-turbo \
  --output_dir /models/whisper-ct2 --quantization float16
```

Then copy `preprocessor_config.json` from the HF cache into the output directory. The model reads `feature_size` from that file to set mel spectrogram bins (128 for large-v3-turbo). Skip this step and you get silently wrong transcription: no error, just the wrong spectrogram shape going through the model.

## One version broke three models

The consolidated audio worker carried the base image's default diffusers version, which had drifted away from what three separate lip-sync models expected. The failures looked unrelated:

- **LatentSync 1.5**: no error. Silent, structurally corrupt output: a melted lower face with diagonal affine seams across two different portraits. Reproducible every time.
- **Hallo2**: failed at load time with `_set_gradient_checkpointing() got an unexpected keyword argument 'enable'`.

The fix was identical for both, and applied a third time when rebuilding MuseTalk:

```
diffusers==0.32.2
```

Each of these models authored its own UNet overrides against the 0.32 API. The newer base diffusers (`~0.38`) changed the `_set_gradient_checkpointing` signature in a way that either threw immediately or silently corrupted the latent-diffusion UNet decode. None of them flagged the version mismatch at install time.

Isolated images per model, each with that single pin, fixed all three.

## The last-step trap

Hallo2 ran a complete job: face detected, audio separated, 150 diffusion frames generated. Then died muxing the mp4:

```
TypeError: must be real number, not NoneType
```

on `fps`. Root cause: `decorator==5.3.1` in the base image. moviepy 1.0.3 uses the `decorator` library to inject keyword arguments into clip methods; under `decorator>=5`, the explicit `fps=25` argument gets silently dropped before reaching ffmpeg. Fix:

```
decorator==4.4.2
```

The tell was the shape: every compute step passed and only file-writing failed. That pattern points at an I/O library version mismatch, not the model.

## The nightly wheels story is its own post

Rebuilding the worker image a month after the original install failed because `xformers` had stopped publishing cu130 nightlies (`ERROR: ResolutionImpossible`). The running container had quietly settled on stable `torch==2.8.0`, which by then fully supported Blackwell. That story has [its own post](/blog/nightly-wheels-are-a-depreciating-asset). The short version: `pip freeze` the working container before you need to rebuild it.

## The transferable lesson

Every one of these is a gap between intent and running system. The spec says "install from the nightly index." The index stops publishing that wheel six months later. The spec says "clone the repo and run the model." The repo serves LFS pointer stubs without `--lfs`. The spec says "use the RQ gateway." Nobody wrote down that the gateway needs a worker.

The fix is not a better spec. It is a `pip freeze` of the working container saved next to the Dockerfile, plus a verification gate that runs a real job end-to-end before declaring done.

## What I'd check today

1. If you have an RQ gateway: run `rq info` and confirm there are active workers, not just a healthy Redis queue.
2. Before trusting any model's entry-point docs: read the actual installed Python files. The README is not the code.
3. If a lip-sync model produces corrupt frames without raising an error: check `pip show diffusers` before anything else.
4. `pip freeze` the working container. Do it before you need to rebuild.

The full list of 25 deviations lives in the repo.

---

*[github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack)*
