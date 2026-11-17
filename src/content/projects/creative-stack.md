---
title: "Mushishi Creative Stack"
oneliner: "Local AI video production: generation, object removal, masked edits, and 4K60 finishing, with a forensic-analysis bridge that starves diffusion models of room to hallucinate."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-creative-stack"
stack: ["ComfyUI", "FLUX.2", "Wan 2.2", "HunyuanVideo", "SAM3", "SeedVR2", "RIFE"]
started: 2026-04-25
order: 2
---

Six named, tested workflows, from seed-locked fast iteration (⚡ Flashfire) to object removal that takes the object *and its reflection* (🫥 Vanisher). The interesting engineering is upstream: a multimodal "forensic mode" produces dense scene constraints *before* any diffusion model runs, so generators obey specifications instead of inventing shadows.

Quality benchmarking against client-grade standards happens in public: the benchmark table shipped with empty cells and fills in as runs complete, pass or fail. A monthly job re-validates every workflow against upstream drift and regenerates the [live catalogue](/workflow-catalogue.html).

**Since launch (updated November 2026).**

- **Drift is the main maintenance cost.** A sweep of nine workflows marked "tested" found four broken by upstream node renames and API changes. Rather than auto-fix them, a monthly job now re-validates every workflow, regenerates the public catalogue, and reports what drifted. [The drift](/blog/my-tested-workflows-broke-from-upstream-drift) · [the monthly job](/blog/a-self-healing-catalogue-for-a-stack-that-drifts).
- **A dedicated video lane** joined the GPU modes in August. Choosing its model was mostly a fit-and-licence exercise: a 33B omni-modal video model needed two 5090s and its licence excludes self-hosting in the US, EU, UK and South Korea, outputs included. LTX-2.5 runs on one card with no territorial restriction, so it won.
- **Five wiring mistakes that looked like model bugs:** "Prompt has no outputs", colour splotches from an unconnected mask, a harmless flash-attention traceback, and two more. [The list](/blog/five-comfyui-gotchas-that-looked-like-model-failures).
- **The same stack now feeds a film pipeline:** [UTSUSHIE](/projects/utsushie) runs script to screen on this card.

