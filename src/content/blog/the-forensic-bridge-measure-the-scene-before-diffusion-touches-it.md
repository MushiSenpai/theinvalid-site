---
title: "The forensic bridge: measure the scene before diffusion touches it"
description: "A vision LLM does a three-pass forensic scan of the footage — heroes, reflections, atmospheric fields — and writes the SAM3 mask prompts and fill constraints itself. Full pipeline in 203 seconds, autonomy proven, and the one target it honestly couldn't remove."
date: 2026-07-02
project: creative-stack
tags: ["ai-video", "sam3", "vace", "comfyui", "anti-hallucination", "case-study"]
---

Diffusion models hallucinate because we let them. Hand an inpainting model a masked region and a one-line prompt, and it will improvise: invent a shadow that points the wrong way, change the countertop's material, add a bottle that was never there. For client work — "remove this object from production footage" — improvisation is a defect. The fix I built isn't a better model. It's a bridge that **starves the model of room to hallucinate**: a multimodal LLM forensically measures the scene *first*, and the diffusion model gets specifications to obey instead of space to confabulate.

This is the case study of that bridge — what it does, the 203-second end-to-end run that proved the architecture, and the target it honestly failed on.

## The pipeline

Everything runs locally on one RTX 5090 — the footage never leaves the machine, which for unreleased client footage is the point. Three stages:

**1. Forensic analysis (Nemotron, three passes).** A local vision LLM scans the frame and classifies everything it sees into four tiers: **hero subjects** (up to 5, individually identified), **secondary subjects** (up to 15 — and crucially, the *reflections and shadows of the heroes count as independent targets here*), **background density** (grouped, counted as ranges — "~12–15 motorbikes" — never enumerated), and **atmospheric fields** (rain, smoke, steam described as fields with density and direction, not objects). Passes two and three extract the forensic detail — color hex codes, lighting direction on a clock face, shadow angles, pixel regions, surface reflectivity — and build a consistency map that ties every reflection back to its source object. Reasoning budget is tunable per pass: deep for heroes, light for categories. Prefix caching means repeat passes on the same footage reuse tokens, 5–7× faster.

**2. The machine payload.** A converter turns the prose analysis (a VFX artist can edit it first) into structured JSON: SAM3 mask prompts as an explicit **remove list and preserve list**, a reflection map where each entry carries its surface type, fidelity, and an edit dependency — *if the source object is removed, this reflection must be masked and regenerated too* — and an auto-written fill prompt that pins the lighting direction and ends with the most important instruction in the file: **"no added objects, natural continuation of background only."**

**3. Render.** An orchestrator injects the SAM3 text prompt and fill prompt into the ComfyUI workflow by node ID and drives the render — VOID for removal, Wan VACE for masked inpainting — polling until done.

The prompt SAM3 receives is not something a user guessed. It's "the egg (yolk and white) in the black frying pan" — derived from the forensic pass. Vague prompts make ambiguous masks, and ambiguous masks are where hallucination starts, because **the mask is the instruction**. I learned that one the expensive way: SAM3 in image mode emits a single `[1,H,W]` mask, VACE needs per-frame `[N,H,W]`, and the mismatch cost me days — [written up separately](/blog/the-sam3-mask-that-crashed-vace).

## The E4 run: 203 seconds, autonomy proven

The proof run: a kitchen scene — egg frying in a cast-iron pan, espresso machine behind it, flames, steam. Instruction: "remove the egg."

The full pipeline ran end to end in **~203 seconds**: forensic scan, detail passes, payload build, SAM3 video segmentation, two-pass VOID fill. Unattended. The analysis correctly picked out three hero subjects (egg, pan, espresso machine), catalogued **13 dependent reflections and shadows** on the steel surfaces, put the flames and steam in the preserve list as atmospheric fields, and wrote its own fill prompt.

It even caught its own wiring bug along the way: the first run silently rendered a stale test clip because the node-ID map pointed at the old image-mode SAM3 node. The fix (target the video-segmentation node's `text_prompt`, verify inputs on a live job) is exactly the kind of thing this log exists to record.

## The honest verdict

The architecture is proven. The result on *this* target was not deliverable.

An egg mid-fry is a **liquid** — a spreading thing with an ambiguous boundary — and that's the known hard case for the whole segmentation-plus-inpaint approach. The fill didn't make the egg vanish; it regenerated something plausibly egg-like. Measurably the region was touched (pixel deltas ~14.7 vs an 8.1 baseline), visually it didn't read as "removed." This matches the boundary I'd already published in the [object-removal arc](/blog/object-removal-arc): clean separable objects come out beautifully in ~180 seconds; liquids, heavy occlusion, and low light do not, and I tell clients that before quoting, with a free sample frame.

So the case study splits cleanly in two, and I want both halves on the record:

- **What's proven:** a local LLM can autonomously produce the dense scene constraints, the mask prompts, and the fill prompts for a video edit, and drive the render, in ~3.4 minutes, with reflections and shadows tracked as first-class dependents of the objects that cast them. No cloud API saw a frame.
- **What isn't:** that this beats a naive prompt on the *hard* targets. Liquids still defeat the mask. The next planned run re-tests on a clean separable object, where the preserve-lists and reflection logic should show their value directly.

Anti-hallucination by design isn't a claim that the model can't fail. It's an architecture where the model is never asked to imagine what the scene contains — that part is measured, written down, and enforced. The failures that remain are boundary failures you can name in advance, which is exactly what you want to be able to tell a client.

---

*The bridge scripts, the workflow JSON, and the problems-and-solutions glossary (including the SAM3 lesson) are public at [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack).*
