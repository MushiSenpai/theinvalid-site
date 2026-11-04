---
title: "Five ComfyUI gotchas that each looked like a model failure"
description: "VOID says 'Prompt has no outputs', VACE shows color splotches, flash_attn throws a KeyError. None were model bugs. Five wiring and config mistakes from building a local video stack."
date: 2026-11-04
project: creative-stack
tags: ["comfyui", "debugging", "creative-stack", "local-ai", "flux"]
---

Building out the creative stack this month, I hit five ComfyUI failures in a row that presented the same way: garbage output, or a confusing error, with nothing obviously wrong in the graph. Each time I went looking for a model problem. Each time it was the wiring, the settings, or me.

Here they are.

## 1. `Prompt has no outputs` in a VOID subgraph

VOID (the ComfyUI object removal workflow) uses subgraphs for its inpainting pipeline. I hit this:

```
Prompt has no outputs
```

My first assumption was a node rename or schema change, something the whole workflow depended on. It was a disconnected subgraph output node.

A subgraph that produces results but whose output node is not wired into the parent graph looks, from ComfyUI's validator perspective, like a workflow with no outputs at all. The error is accurate but points at the wrong level of abstraction. The fix is to open the subgraph, find its output nodes, and confirm they have connections back up in the parent graph. One wire, error gone.

## 2. VACE color splotches

VACE is the video-aware inpainting node. I ran it on a clip, got obvious color splotches through the inpainted region, and started looking at the mask quality, the checkpoint, the step count.

The mask input wasn't connected.

When VACE's mask socket has no source, it does not refuse to run. It runs with something: either a full mask, an empty mask, or garbage, depending on its defaults. The result looks like a bad diffusion pass. It is not. The model is trying to inpaint without spatial guidance.

Before debugging VACE output quality, right-click the mask socket and confirm it has an actual source connection. This took me a solid half hour to find because the output looked like a generation artifact, not a wiring error.

## 3. The `flash_attn` KeyError wasn't about flash_attn

I got a traceback with `flash_attn` prominently in the last few lines:

```
KeyError: 'flash_attn'
```

I spent a while checking the flash_attn install: version, CUDA compatibility, reinstall.

The actual problem was several frames higher in the traceback. Something in the model loading sequence had failed first, and the cascade ended at flash_attn's initialization. The named package at the bottom was a symptom, not the cause.

When debugging ComfyUI crashes: open the terminal where ComfyUI is running (not just the browser console) and read the traceback from the top. The browser often shows only the final exception frame. The terminal shows the full chain. Find where the error starts, not where it ends.

## 4. Flashfire and Goldsmith use opposite settings

The creative stack has two FLUX workflows: Flashfire (the fast draft, based on a distilled/turbo checkpoint) and Goldsmith (the quality baseline, based on FLUX.1-dev). They are in the same catalogue. Their sampler settings are not just different, they are opposite:

| Setting | Distilled (Flashfire) | Base dev (Goldsmith) |
|---|---|---|
| Steps | 4 | 20 |
| CFG / Guidance | CFG 1.0 | FluxGuidance 3.5 |

If you raise the step count on a distilled model, quality goes down. If you run a base model at 4 steps, you get soft underformed images. Same model family, opposite knobs.

This gets painful when you grab a community workflow that does not label which variant it was tuned for, or when you switch checkpoints without updating the KSampler. The output does not error. It is just wrong in a way that looks like the model struggling with the content.

If FLUX output is wrong: first question is which variant is loaded, second is whether the sampler settings match that variant.

## 5. The fill prompt was from a previous benchmark

During a benchmarking run on an object removal workflow, I queued a job on a laboratory scene and the fill looked completely wrong. The model was filling the removed area with concrete, daylight, sidewalk textures. In a room full of equipment.

The fill prompt widget still said `empty sidewalk daylight` from the previous benchmark on an outdoor clip. I had not read the widget before queuing.

ComfyUI does not warn you that your prompt is probably wrong for this scene. It runs what it is given. I ran two more iterations trying to understand why the model kept generating outdoor textures before I looked at the actual widget value.

Read your prompt widgets before you queue. Not what you think you last set. The actual text in the box right now.

## The pattern

None of these were model failures. The models ran exactly what they were given. The problems were: disconnected subgraph output, missing mask input, wrong traceback frame, mismatched sampler settings, stale prompt widget.

ComfyUI is a wiring diagram for ML ops. When output is wrong, check the wiring before blaming the model.

## What to check right now

1. Are your mask inputs actually connected? Right-click the socket, verify the connection.
2. For any traceback: check the terminal (not just the browser) and read from the top.
3. FLUX loaded: distilled or base dev? Do your step count and guidance type match?
4. Read your prompt widgets before you queue. Memory is wrong more often than you would expect.

---

*Full workflow set and benchmark data are at [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack).*
