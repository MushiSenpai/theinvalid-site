---
title: "Sovereignty as routing, not policy"
description: "How to enforce 'client data never reaches a cloud API' with LiteLLM routing profiles — including a chain that deliberately errors instead of degrading silently."
date: 2026-07-04
project: sovereign-ai-stack
tags: ["litellm", "vllm", "llm-routing", "sovereignty", "selfhosted"]
---

"We don't send your data to the cloud" is one of those things that's easy to say and surprisingly hard to make true in a system with fallback chains.

I run three LLM stacks on one machine. When GPU capacity is gone, something has to give. For personal work, that's fine — fall back to the CPU model, then to a cloud API. For client work, that's not fine at all. "We're using Kimi because the GPU was busy" is not a sentence I want to say to a client whose data I said would never leave the machine.

The fix wasn't a policy. It was a route.

## The four tiers

Before I wired anything up, I classified every workflow into one of four tiers:

- **T1 Sovereign** — local only, no path to cloud, period
- **T2 Speed-optional** — local-first, cloud fallback permitted when local is saturated
- **T3 Cloud-explicit** — deliberately uses cloud features (the tool earns this classification)
- **T4 Coordination** — local-hosted orchestration layer

The classification happens before a model is chosen, before a workflow is built. It's the first question: does this data get to leave?

## Three chains, three guarantees

The tier classification feeds three profiles, each with a different fallback behavior:

**Personal (T2):**
```
GPU Nemotron → CPU Nemotron → Kimi → Groq → OpenRouter
```
Full cascade. If the GPU is saturated, the CPU handles it. If the CPU queue is full, cloud picks it up. This is where my own experiments and notes live. I'm fine with Kimi reading my personal prompts.

**Private (T1):**
```
GPU Nemotron → CPU Nemotron → QUEUE
```
Queues locally if both are busy. Never leaves the machine. This is the profile for anything that touches real names, real addresses, or client material not yet under an engagement.

**Client:**
```
GPU Nemotron (forensic config) → ERROR
```
No CPU fallback. No cloud fallback. If the GPU isn't free, the request fails with an error.

This is intentional.

## Why the client profile errors

For paid deliverables, a silent quality downgrade is worse than an explicit failure. If I'm processing client footage through the forensic vision config and the request falls back to a smaller model because of load, the output changes in ways I might not catch. An error is loud. A degraded output that looks fine is invisible until it isn't.

"Failing loudly beats degrading silently" sounds like a platitude until you've shipped something that silently used the wrong model. Then it sounds like a requirement.

## How it's wired

[LiteLLM](https://github.com/BerriAI/litellm) (running at `:4000`) acts as the cloud-budget proxy — it handles T2 speed-optional requests and manages the cloud API keys and cost caps. [Hermes](https://github.com/run-llama/llama_agents) (`:8642`) is the routing layer that directs each request to the right profile based on context.

Private and client requests never reach LiteLLM at all. They go directly to vLLM on the GPU, or they fail. There's no configuration toggle that could accidentally route a T1 request through the cloud proxy, because the cloud proxy isn't in the path.

That's the thing about routing over policy: a policy can be misconfigured. A route that doesn't exist can't be accidentally taken.

## The non-obvious design call

The instinct is to maximize availability — keep trying fallbacks until something responds. But "something responded" and "the right model responded" are different things, and for client work, only one of them is acceptable.

The other decision that mattered: tier classification happens at tool-adoption time, not at runtime. If I add a new workflow and it touches client data, I pick its tier before I write the first line of config. Not after it's in prod and I'm wondering whether that Groq API call was a problem.

## What I'd tell you to check today

1. **Trace one workflow that touches private data all the way through.** Does it ever reach a cloud endpoint? Does that match what you'd tell the person whose data it is?
2. **If you're using LiteLLM**, look at your `router_settings` and `fallback_providers`. A missing or misconfigured fallback list doesn't always fail loudly — it can silently route in ways you didn't intend.
3. **Ask whether availability is the right goal for your highest-trust workloads.** For some of them, a loud failure is the more honest outcome.

The infrastructure is documented end-to-end, including the Decision Log with the choices that didn't work, at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).
