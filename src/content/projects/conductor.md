---
title: "Conductor: one control plane for a one-GPU AI estate"
oneliner: "One job API, one VRAM-lease scheduler and one trace and cost plane over four inference stacks (LLM, image and video, audio, 3D) that all share a single RTX 5090."
status: building
private: true
stack: ["FastAPI", "VRAM-lease scheduler", "LiteLLM", "OpenTelemetry", "Phoenix", "Docker"]
started: 2026-07-01
order: 10
---

Four stacks on one workstation each believe the GPU is theirs. Conductor is the layer that settles it: every workload goes through one job API, and a scheduler leases the card to one heavy tenant at a time (use, flush, load). The bet is temporal scheduling on a single GPU, where most tooling only offers spatial sharing across several.

The signature capability is the **chain**: one declarative job that runs several single-modality jobs as a DAG, with each step's output wired into the next by code, never by a model. The script-to-speech path runs end to end through the real stacks today, and one trace id spans both the LLM call and the audio worker, with a single cost ledger (token-priced LLM row, GPU-seconds audio row).

Measured on the box, failures named: **20 live profile switches, 0 failures, 0 refusals**. Swapping into the heavy LLM tenant costs 75.8 to 89.2 s cold and peaks around 26.3 GB, which is exactly the cost the scheduler batches around. Switching into the creative or audio stacks lands in 25 to 44 s.

The repo is private while the last phase lands. The stacks it conducts are public: [sovereign](/projects/sovereign-ai-stack), [creative](/projects/creative-stack), [audio](/projects/audio-stack) and [3D](/projects/three-d-stack).
