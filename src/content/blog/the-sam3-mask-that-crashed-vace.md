---
title: "The SAM3 mask that crashed VACE"
description: "A segmenter was handing my video editor a single still-frame mask shaped [1,H,W] when the model wanted one mask per frame, [N,H,W] — a tensor-dimension mismatch that looked like everything except what it was."
date: 2026-06-22
project: creative-stack
tags: ["comfyui", "sam3", "vace", "wan", "video-editing"]
---

Two fixes in my creative stack turned out to be the same fix wearing different clothes. The first was a crash. The second was the opposite of a crash — output that was *too* obedient. Both came down to the same realisation: with editing models, the instruction isn't the prompt. It's the mask. Here's the honest version, dead ends included.

## The symptom: a "change this region" tool that repainted the whole frame

My masked-edit workflow — internally I call it Shapeshifter — is Wan 2.1 VACE driven by a SAM3 segmentation mask. You point SAM3 at a thing ("the writing board"), it produces a mask, and VACE only edits inside that mask. That's the theory.

The first time I ran it, VACE didn't edit a region. It produced random RGB patches — colour splotches scattered across the frame. Not a subtle artifact. The whole plate had been partially regenerated into garbage.

That one I diagnosed correctly, and it taught me the lesson the *second* bug would later weaponise against me. The VACE Encode node's `input_masks` was unconnected. With no mask, VACE has nothing telling it where the edit boundary is, so it runs full-frame at denoise 1.0 — it treats the entire frame as fair game and regenerates arbitrary regions. The fix was to feed the SAM3 mask into `input_masks`. The edit then stays inside the masked region, and the prompt only has to describe what that region *becomes*.

So: no mask, whole-frame chaos. I wrote that down. I thought I understood it. I didn't, not all the way.

## The second symptom: now it crashes outright

With the mask connected, the splotches were gone — but now Shapeshifter crashed before producing anything. A tensor-dimension mismatch, deep in VACE.

This is where I went down the wrong road for a while. A dimension mismatch inside a video model is a generic-looking failure. My first instincts were all the usual suspects: a resolution that didn't divide cleanly, a frame count VACE didn't like, a dtype mismatch from the VRAM-offloading patches I'd already had to make to get VACE running under WanVideoVRAMManagement at all (four separate surgical patches to a third-party node's source — that's its own war story). I had a recent history of fighting that exact node, so I assumed this was more of the same.

It wasn't. None of those were it.

## The actual root cause: image-mode mask, video model

The mask was the right *content* and the wrong *shape*.

SAM3 has two ways to run. In image mode it segments a single frame and hands back one mask — a tensor shaped `[1, H, W]`. One mask, height, width. Perfectly valid if you're editing a still image.

But VACE is a video model. It doesn't want one mask. It wants a mask *per frame* — a stack shaped `[N, H, W]`, where N is the number of frames. I was feeding a single-frame `[1, H, W]` mask into a node that expected `[N, H, W]`, and the tensor algebra simply didn't line up. The crash wasn't VACE being fragile. It was VACE correctly refusing to broadcast one still mask across a whole clip's worth of frames.

The earlier splotch bug had been "no mask at all." This was its sneakier sibling: a mask that was technically present, technically correct, and the wrong dimensionality for a temporal model. The connection was there. The instruction was malformed.

## The fix: stop segmenting a frame, start segmenting a video

The fix was to rebuild the SAM3 stage from image mode into SAM3's video pipeline — a four-node chain:

```
LoadSAM3Model → SAM3VideoSegmentation → SAM3Propagate → SAM3VideoOutput
```

The important node there is `SAM3Propagate`. Instead of segmenting one frame and reusing that mask, you segment once and then *propagate* the mask through every frame of the clip — tracking the subject as it moves, gets partially occluded, comes back. The output is a per-frame `[N, H, W]` mask stack: exactly what VACE was asking for. (The SAM3 custom node, for anyone retracing this, is `PozzettiAndrea/ComfyUI-SAM3`.)

That fixed the crash. And it's worth saying that the closely related VOID removal workflow benefits from the identical change — I confirmed VOID cleanly removing a blackboard from real lab footage using the SAM3 label `writing board`. Same mask-shape lesson, different editing model.

The deeper takeaway, the one I'd tell anyone wiring up VACE, VOID, or any inpainting model:

**Editing models are mask-driven, not prompt-driven. The mask is the instruction; the prompt only describes what the masked region becomes.** Get the mask wrong by *omission* and you get whole-frame chaos. Get it wrong by *dimensionality* and you get a crash that masquerades as ten unrelated problems. Either way, the failure isn't really in the model. It's in the instruction you handed it.

## The connection: a forensic bridge that constrains generation

The second half of this story is about the same idea pointed in the opposite direction.

I'd built a forensic analyzer — a tool that watches a clip and emits a dense, structured description of the scene: a machine-readable payload, schema-stamped, that captures what's actually in the frame. The question was whether I could feed that structured scene description straight into ComfyUI to *drive* a generation or edit, rather than hand-writing prompts.

So I wrote the bridge. It's deliberately *not* a ComfyUI custom node — it's an external orchestration script (`forensic_to_comfy.py`) that reads the forensic machine payload, builds a ComfyUI API-format prompt for either the VOID or VACE workflow, posts it to the `/prompt` endpoint, and polls `/history` until the job finishes. Concretely, it injects the analyzer's output into the right places: the SAM3 mask prompts (what to segment), and the fill or edit prompt (what the masked region becomes). The forensic description stops being something a human reads and becomes the thing that configures the graph.

Why keep it external rather than building a node? Because it keeps the forensic logic cleanly separated from ComfyUI's internals. The bridge speaks the public API; it doesn't reach inside the engine. If a workflow's node IDs change, I fix a small mapping table, not a plugin.

And here's where the two halves of the post meet. The whole reason editing models *exist* — the reason I pivoted from pure generation to a dedicated editing tier — is that pure generation hallucinates the things you need preserved: shadows, reflections, lighting, the untouched regions of the plate. A mask-and-constraint approach exists precisely to *take room away* from the model so it can't invent. The mask says "only here." The forensic payload says "and it looks exactly like this." Both are constraints. Both are instructions encoded as structure rather than prose.

There's a tempting stronger claim — that if you constrain a diffusion model densely enough, you starve it of the room it needs and the output gets stiff or worse. I've noted that as a working hypothesis in my own build log, and I've seen hints of it, but I haven't benchmarked it cleanly against a looser prompt, so I won't assert it as a finding. What I *can* say honestly is the documented principle behind the whole editing tier: generation invents; editing preserves; and the mask plus the structured description are how you tell the model which mode you actually want.

## The takeaway

The crash that cost me the most time wasn't a bug in VACE. It was me handing a video model an image's idea of a mask. A single `[1, H, W]` still where it needed a `[N, H, W]` stack — right content, wrong dimension, and a tensor error that wore ten disguises before it admitted what it was.

The one-line version, the thing I now check first on any masked-edit workflow: **with editing models, debug the instruction before you debug the engine — and the instruction is the mask.**

---

*This is part of a fully local, sovereign AI creative stack on one RTX 5090. The build — workflows, fixes, and the failures that produced them — is at [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack).*
