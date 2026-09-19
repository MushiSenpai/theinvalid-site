---
title: "My tested workflows broke from upstream drift"
description: "Swept 9 ComfyUI workflows I'd marked tested: 4 broke from upstream node renames and API changes. The exact errors, the rebuild method, and why a workflow JSON is a promise against an environment that keeps moving."
date: 2026-09-19
project: creative-stack
tags: ["comfyui", "hunyuanvideo", "wanvideo", "workflow-validation", "upstream-drift"]
---

I sat down to run a benchmark sweep across 9 ComfyUI workflows I'd built and "tested" weeks earlier. The plan was numbers: how fast, how much VRAM, render-verified pass or fail. What I got instead was four broken workflows and a lesson about what "tested" actually means on a fast-moving stack.

## The sweep

The nine workflows covered the range of my creative pipeline: fast image generation (Flashfire, Goldsmith), video generation (Wan 2.2 T2V/I2V, HunyuanVideo 1.5), object removal (Vanisher), upscaling (Crystalforge), and slow-motion finishing (Silkmotion). I'd run each of them at least once, at some point, on some version of ComfyUI. I expected maybe 10 minutes of validation, then an hour of numbers.

Five workflows loaded clean. Four didn't.

## The errors

```
Node 'Video Latent' has no class_type
```

That was Quickdraw, the Wan 2.1 draft workflow. The `EmptyWanLatentVideo` node had been renamed to `Wan22ImageToVideoLatent` in a custom node update. The old name simply no longer existed in the registry. ComfyUI didn't warn me when I last ran it; it just stopped working when the node disappeared underneath the saved JSON.

```
ModelSamplingFlux.patch() got an unexpected keyword argument
```

That was Ledger, the FLUX.1 Dev draft workflow. The internal `.patch()` method signature in ComfyUI core had changed. The workflow JSON's node inputs were technically unchanged. The layer of Python underneath moved.

Then the two Hunyuan workflows: **dreamforge** (T2V) had 4 nodes missing, **quickening** (I2V) had 5. The root cause: `HunyuanVideoModelLoader` had been renamed to `HunyuanVideo15*` across the node pack update. Four to five call sites per workflow, all referencing a name that no longer existed.

Four workflows, three categories of breakage: node renamed with different I/O, API signature changed without warning, and a loader renamed that cascaded into a missing-node count across every dependent node.

None of this involved me touching anything.

## Why day one was diagnosis, not fixing

The instinct is to open the workflow JSON and swap the class names. I didn't.

The renames weren't cosmetic. `EmptyWanLatentVideo` and `Wan22ImageToVideoLatent` don't have identical inputs. `HunyuanVideoModelLoader` and `HunyuanVideo15*` aren't wire-compatible. Changing a string in JSON and calling it fixed produces a workflow that validates clean and renders garbage. The standard I hold the stack to is render-verified, not just validator-green.

So day one was recorded diagnosis: what broke, why it broke, and why each repair needed a full graph rebuild with visual QA. Not an afternoon sprint.

## The fix

Day two, rebuilt all four using the workflow pack's own example templates as the starting point (not editing in place), then converted each from the litegraph format to API format via `scripts/ui2api_render.py`, then ran a real render and checked the output frame by frame.

| Workflow | Was | Now |
|---|---|---|
| HunyuanVideo 1.5 T2V (dreamforge) | 4 nodes missing | rebuilt, 16s, render-verified |
| HunyuanVideo 1.5 I2V (quickening) | 5 nodes missing | rebuilt, 21s, render-verified |
| Wan 2.1 draft (Quickdraw) | `Video Latent` no class_type | rebuilt, 1.3B draft, clean |
| FLUX.1 Dev draft (Ledger) | `ModelSamplingFlux.patch()` kwarg | rebuilt, render-verified |

Two days total. Not catastrophic. Not free either.

## The lesson

A ComfyUI workflow JSON is a snapshot. It captures the graph structure at one moment, against one version of ComfyUI core and one version of every custom node pack the graph depends on. When a node author renames a loader (no deprecation period, no migration path, no notice), the snapshot references a name that no longer exists. When the core team changes a method signature, the node's inputs break at the Python level, not the JSON level. The file looks the same; the environment underneath has moved.

"Tested and working" means "worked on date X against environment Y." The environment doesn't ask permission before updating.

The two options:

1. **Pin the node versions.** Lock every custom node pack to a known-good commit in your Docker image. Rebuilds become a deliberate choice instead of an upstream surprise.
2. **Schedule re-validation.** Run a validator against the live node registry on a cadence. Find the drift before a client does, or before you spend half a day debugging a workflow you were sure was fine.

Both of these feel like overhead until the first time a benchmark sweep turns into a repair sprint.

## What I'd tell you to check today

1. When did you last actually *run* each workflow end-to-end, not just open it in the UI? If the answer involves a month or more, run the validator now.
2. Do you know which custom node pack versions your workflows were built against? If the answer is "whatever was current at the time," that's the gap.
3. If you're running ComfyUI in Docker and the image is more than a few weeks old with unlocked node packs, treat every workflow in it as unverified until you re-run it.

A workflow marked "tested" three weeks ago is a hypothesis about a state that may no longer exist.

---

*Full benchmark data and workflow validation tooling are at [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack).*
