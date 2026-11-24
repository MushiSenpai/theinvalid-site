---
title: "UTSUSHIE: a local film studio on one card"
oneliner: "Script to faces to keyframes to video to voices to mix, on one RTX 5090 that also runs a daily-driver LLM. Every stage picks its model by experiment, not reputation."
status: building
private: true
stack: ["ComfyUI", "image and video diffusion models", "Grounding DINO checks", "SQLite job queue", "systemd"]
started: 2026-10-01
order: 7.5
---

A film pipeline for one machine, inspired by filmmaker Nirup Divakaran's Mac AI Film Studio. Local-only: nothing from the films themselves is published, only what building it taught.

**Experiment before choosing.** Each stage ran every candidate model with the same seeds. The results cut both ways in a single day: an undistilled base model beat its own distilled Turbo, full-precision video weights looked identical to int8 and ran 45% slower (76 GB deleted), and one "base" checkpoint rendered noise because its card says it is a training base, not for inference.

**The prompt was the bug.** "I asked for 2D and got 3D" turned out to be the prompt's first sentence, which opened with photography words. A deterministic prompt compiler (look first, restated at the end, wrong-medium words stripped) took the style pass from **6 of 18 to 18 of 18** with the same seeds.

**The checker had to be checked.** The quality gate rejected good empty scenes and missed real extra figures. Both faults were in how the detector was asked. One phrase at one threshold: 84 of 84 lone characters counted right, 3 of 3 planted fakes caught.

**Sharing the card is a permission problem first.** The image engine crashed out of memory twice while the LLM held 29.5 GB. Now the renderer waits whenever a program it does not own holds more than 3 GB, offers a switch that shows exactly what it will stop, and never stops anything that is not a registered GPU mode.

Still open and stated as open: one video model's super-resolution runs out of memory on 32 GB even alone.
