---
title: "Mushishi Sovereign AI Stack"
oneliner: "Self-hosted multimodal LLM infrastructure where 'client data never touches a cloud API' is enforced by routing, not policy."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-sovereign-ai-stack"
stack: ["vLLM", "Nemotron NVFP4", "Qwen3.8-27B NVFP4", "LiteLLM", "llama.cpp", "Phoenix (OpenTelemetry)", "Tailscale", "restic"]
started: 2026-05-14
order: 1
---

One RTX 5090, 32GB of VRAM, and three fallback chains with three different guarantees, including a client profile that *refuses* to fall back, because for paid work, failing loudly beats degrading silently.

Measured: **275 tok/s** on Nemotron NVFP4 via vLLM, 180K context at FP8 KV cache. The repo carries the full Decision Log, including the six hours of TensorRT-LLM debugging that ended in choosing vLLM: the dead ends are documented because they were the expensive part.

**Since launch (updated November 2026).**

- **How many users one card serves:** single-stream speed is not capacity. A concurrency sweep showed aggregate throughput climbing to **728 tok/s at 8 concurrent users** (2.6× the solo rate), then going flat when the KV cache filled. Users 9 to 16 queue rather than run. [The sweep](/blog/one-rtx-5090-how-many-users-the-honest-answer).
- **A daily-driver model:** a 27B Qwen3.8 NVFP4 model now holds the card day to day, at about 29.5 GB. Sourcing it taught the habit of checking every model repo against the hub's API rather than search results: the advertised repo name did not exist, and the "~23 GB" checkpoint was 24.7 GB.
- **Observability:** LiteLLM now exports traces to a local Phoenix (OpenTelemetry), so every routed call can be followed end to end. [Four gotchas wiring it](/blog/four-litellm-docker-gotchas).
- **Operations:** offsite backups to a Hetzner Storage Box, an agent runtime (Hermes) installed alongside, and two driver-maintenance lessons the hard way: `systemctl isolate` quietly restarts Docker and its GPU containers. [The write-up](/blog/systemctl-isolate-multi-user-starts-docker-too).
- **What sits on top now:** the [Conductor](/projects/conductor) control plane leases this card between the stacks, and the [film studio](/projects/utsushie) shares it with the daily-driver model.

