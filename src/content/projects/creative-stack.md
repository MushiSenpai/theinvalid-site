---
title: "Mushishi Creative Stack"
oneliner: "Local AI video production: generation, object removal, masked edits, and 4K60 finishing, with a forensic-analysis bridge that starves diffusion models of room to hallucinate."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-creative-stack"
stack: ["ComfyUI", "FLUX.2", "Wan 2.2", "HunyuanVideo", "SAM3", "SeedVR2", "RIFE"]
started: 2026-04-25
order: 2
---

Six named, tested workflows — from seed-locked fast iteration (⚡ Flashfire) to object removal that takes the object *and its reflection* (🫥 Vanisher). The interesting engineering is upstream: a multimodal "forensic mode" produces dense scene constraints *before* any diffusion model runs, so generators obey specifications instead of inventing shadows.

Quality benchmarking against client-grade standards is happening in public — the benchmark table ships with empty cells and fills in weekly, pass or fail.
