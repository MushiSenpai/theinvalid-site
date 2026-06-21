---
title: "I benchmarked an AI avatar pipeline end to end"
description: "Ten local audio and avatar pipelines on one RTX 5090 — TTS, voice clone, transcription, lip-sync, music, dubbing — measured wall-clock and VRAM for each, including the two pipelines that stayed blocked and the close-ups that still go to cloud."
date: 2026-06-22
project: audio-stack
tags: ["audio", "avatar", "lip-sync", "tts", "whisper", "rtx-5090"]
---

I built a local audio and avatar stack — text to speech, voice cloning, transcription, a lip-sync talking head, music, and auto-dubbing — and then I measured every pipeline end to end on one RTX 5090. Wall-clock seconds, peak VRAM, throughput, for each one. Some are genuinely fast, one takes twenty minutes a clip, and the three lip-sync engines each had to be torn out of the shared worker and given their own isolated environment before any of them worked at all. Broadcast close-ups still go to the cloud. This post is the honest table walk-through, the two hard walls I had to beat, and the one thing the numbers taught me that I didn't expect.

I don't hand-write the code. I architect the stack, write the specs the LLMs build against, debug, and verify. The measuring is the part I trust least to anyone but myself, so that's the part I want to be public.

## Why local at all

The whole reason to run this on my own box is that the inputs never leave it. A speaking-avatar job takes a portrait and a voice sample — someone's face and someone's voice — and turns them into a talking head. That is exactly the kind of input you don't want to hand to a cloud API. Same for the voice profile: cloning a voice means the reference clip and the saved profile both live on disk under my control and nowhere else. Sovereignty here isn't a slogan, it's the threat model. The artwork and the voice stay on the machine.

## The architecture

The shape is a job queue, and that shape exists for a reason: these jobs run anywhere from ten seconds to a few minutes, so you cannot make them synchronous HTTP calls without something timing out.

A FastAPI gateway on `:9000` does one thing — it reads intent, resolves a `(job_type, quality)` pair, and enqueues the job to Redis. A separate GPU worker container consumes the RQ queue and runs the actual inference: `stt.py`, `voice.py`, `lipsync.py`, `music.py`, `dub.py`. The worker has to be its own GPU container — the gateway only enqueues, and if you forget the worker, jobs sit in `queued` forever. Some models that can't share the worker's pinned dependencies run as their own microservices that the worker HTTP-calls, exactly the way it calls Fish Speech. I'll come back to why that isolation matters, because it's most of the engineering.

## The measured table

Here's what each pipeline actually did. Every number below is a real measured run, not a spec target.

**Voice cloning** — Demucs to separate the speech from background noise, then Fish Speech to build a reusable voice profile. **5 seconds**, ~4GB peak. One ordering gotcha: run Demucs first, or the clone comes out robotic.

**TTS** — Fish Speech 1.5, synthesizing a 75-word ad-read in the cloned voice. **25 seconds** for a 34.5-second WAV, ~4GB peak, about 145 words per minute. The voice doesn't sound robotic; quality tier is just a speed parameter.

**Transcription** — Whisper Large V3 Turbo plus WhisperX for word-level alignment. **15 seconds** for 34.5 seconds of speech, ~2GB peak — about 2.3x realtime. Production quality runs the WhisperX word alignment; draft is Whisper alone.

**Music** has three engines, and the spread between them is the most interesting part of the table:

- **ACE-Step 3.5B** — **10 seconds** including model load for a 30-second stereo 48kHz clip, ~7.4GB. The diffusion itself is ~1.8s, roughly 30x realtime.
- **Stable Audio Open 1.0** — **18 seconds** for a 30-second stereo 44.1kHz clip, ~8GB.
- **YuE 7B** — **176 seconds** for 15 seconds of mono 44.1kHz output, ~16GB. About 11.7x slower than realtime, and the mono is a hard limit of YuE's vocoder, not a setting. ACE-Step's stereo 48kHz is both faster and higher fidelity; YuE earns its place only when you need full songs with vocals.

**Dubbing** — same-language, the chain is Whisper to a local LLM to Fish Speech, muxed back over the video. **20 seconds** for a 34.5-second video, ~4GB. Cross-language is a different animal entirely, and it's one of the two walls below.

**The lip-sync avatar** is the centerpiece, so it gets its own section.

## The avatar: a 1024×1024 talking head in 78 seconds

MuseTalk 1.5 takes a margined portrait and the 34.5-second cloned-voice narration and produces a **1024×1024, 25fps talking head in 78 seconds**, ~7.7GB peak. That's about 0.44x realtime, and roughly 25 seconds of that is the per-job model load — it loads on demand and frees the VRAM when idle, which is the right behavior on a shared card.

The honest quality verdict is **social-grade, not broadcast**. What that means concretely: the mouth interior is coherent, there's no melt or smear, and the visemes track the audio — mouth open in speech, closed in silence. That's good enough for social content. It is not good enough for a broadcast close-up, and I'll say so plainly: broadcast close-ups still go to a cloud path. I'd rather under-claim that than ship someone a talking head that falls apart when they zoom in.

Getting even social-grade out of MuseTalk locally was the first of the two real walls.

## Wall one: the mmcv / SM_120 lip-sync wall

MuseTalk ships with an mmpose/mmcv landmark backend, and on an RTX 5090 (Blackwell, SM_120) there is simply no buildable path for it. There's no `mmcv._ext` wheel for torch 2.8 / cu128, and `mmcv-lite` can't stand in — mmpose imports `EDPoseHead → mmcv.ops` at import time, so it dies before it does anything. You can spend a day fighting that and lose.

The escape hatch was to stop fighting it. DWPose — the pose model MuseTalk actually needs — ships an ONNX file (`dw-ll_ucoco_384.onnx`). So `rtmlib + onnxruntime` runs the *exact same model*, returns the *identical* 133-keypoint output (the face is indices 23:91), and never touches mmcv at all. I pulled MuseTalk into its own pinned image with rtmlib behind a small FastAPI service, and the worker HTTP-calls it like any other microservice — so the YuE-and-Fish-Speech worker env is never disturbed.

Three smaller traps sat behind that one: PyTorch 2.6 flipped `torch.load(weights_only)` to `True` and rejects the legacy face-parse checkpoints (restore the old default for a trusted-local-weights process); `inference.py` throws `NameError: save_dir_full` on image inputs because of a video-only cleanup path; and the Whisper feature extractor has to be whisper-**tiny** (hidden=384, matching the positional-encoding `d_model`) — whisper-large is the wrong dimension and just fails.

## Wall two: the cross-language dub doesn't fit in 32GB

Cross-language dubbing needs a translation model in the loop, and the naive version of that pipeline wants to hold three big models in VRAM at once: the GPU Nemotron translator (~26GB on its own), Whisper for transcription, and Fish Speech for TTS. That's ~31.7GB. The card is 32GB. There is no margin, and it OOMs.

And you can't tune your way out. Lowering the translator's `gpu-memory-utilization` to free room just starves its own KV cache so the model won't load at all — it needs ~0.80 or more. The dimensions don't fit, full stop.

The fix that works is to stop treating the dub as one job and **phase the VRAM** — keep exactly one big model resident at a time. Transcribe with Whisper → **restart the worker to free Whisper** → load Nemotron (now only Fish is also resident, ~29GB peak) → translate → **purge Nemotron** → TTS with Fish → ffmpeg mux. Validated end to end, EN→ES, and it lands in about **3–4 minutes** including that per-job Nemotron load. Same-language dub skips the whole dance and stays at ~20 seconds.

Two sub-lessons fell out of that. The translation stays sovereign — the worker only reaches Nemotron through LiteLLM, and LiteLLM had cooled the local model out for an hour after one failed health check until I set `cooldown_time: 0` so a per-job-loaded model doesn't get locked out. And the GPU Nemotron is a reasoning model, so it needs `detailed thinking off` plus a generous `max_tokens` (with a `reasoning_content` fallback) or it just returns empty content.

## The third wall: three lip-sync engines, three environments

I wanted three lip-sync models, not one — a fast social tier, a higher-fidelity portrait tier, and a cinematic tier with real head motion. In the shared worker, two of the three were broken, and both for the same underlying reason.

**LatentSync** produced structurally corrupt output — mouth melt and affine seams, no error thrown, just garbage, reproduced on two different portraits (an earlier 280-second run was unusable too). **Hallo2** crashed outright on a diffusers API change: it ships its own UNet that overrides `_set_gradient_checkpointing(module, value)` the old way, and the worker's newer diffusers calls it with `enable=` and dies. Hallo2 had worked fine in its own container months earlier — which was the tell.

The common cause is the same one MuseTalk taught me: **a single shared environment cannot satisfy models that each shipped pinned to a specific diffusers version.** The worker had drifted to a newer diffusers; both models needed the older one; you cannot have both in one env. So the fix wasn't to debug the models — it was to stop sharing. Each got its own image off the same base, pinned to `diffusers==0.32.2`, behind its own small FastAPI service the worker HTTP-calls — `:9005` MuseTalk, `:9007` LatentSync, `:9006` Hallo2. The YuE-and-Fish worker env is never touched.

That closed both regressions. LatentSync 1.6's melt and seams are gone — clean faces on the same two portraits that broke 1.5. Hallo2 renders coherent half-body motion with expression. The honest catch is cost: these are not interchangeable tiers. MuseTalk does a 1024² head in **78 seconds**. LatentSync 1.6 takes **242 seconds** at ~20GB for a cleaner lower-face blend (though its teeth are about a tie with MuseTalk, not the clear win I'd hoped for — so MuseTalk stays the default and LatentSync is the opt-in). Hallo2 takes **1197 seconds** — about twenty minutes for a 34.5-second clip, ~35x slower than realtime — and earns that only when you need genuine head-pose and expression, not a talking headshot. The local ceiling across all three is social-grade; broadcast close-ups still go to a cloud path, and I say so up front.

## The takeaway

The thing the numbers taught me, that I half-expected but hadn't internalized: on a 32GB GPU the binding constraint is almost never raw model power. It's VRAM co-residence. Every wall in this stack — the cross-language dub that OOMs at 31.7GB, the lip-sync models that work alone and break when they share an env, the avatar that loads and frees per job — comes down to *what can be in VRAM at the same time*. The models are individually fine. The engineering is sequencing them so only what must be resident is resident, and isolating the ones whose dependencies fight.

The fix is almost always to phase, not to optimize. One model in VRAM at a time, conflicting deps in their own environments, microservices the worker calls instead of imports it co-loads. That's the whole game on a single card.

---

*The audio stack, the full benchmark table — empty cells, blocked rows, and all — and the LESSONS.md behind every fix here live at [github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack).*
