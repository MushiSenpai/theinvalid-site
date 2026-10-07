---
title: "I built an AI agent company on my own hardware"
description: "Running Paperclip multi-agent on a local Hermes+LiteLLM stack: the overhead tax you don't see coming, the code review that passed a broken health check, and why 'you are a coordinator, never implement' is not a rule."
date: 2026-10-07
project: sovereign-ai-stack
tags: ["agents", "paperclip", "hermes", "litellm", "local-llm"]
---

A few months ago I stood up a multi-agent company on my workstation: five Paperclip agents (CEO-coordinator, Architect, Builder, QA, Reviewer) running on a local Hermes+LiteLLM stack, autonomously writing code and tests for a side project called DevKit. It worked. Agents wrote real TypeScript, built CI config, filed their own issues. It also taught me three things I couldn't have read in a blog post.

## The setup

[Paperclip](https://paperclip.sh) is a multi-agent framework with a board-approval model: agents can hire each other, spend a budget, and report status on GitHub issues. [Hermes](https://github.com/KoLogicAI/hermes-agent) is the local CLI and gateway that forwards requests to a LiteLLM proxy (port `:4000`), which routes to whatever model you want. I used DeepSeek-Flash for fast agentic work and Kimi-via-NGC for longer-context tasks.

The goal: have the CEO coordinate while the Builder implemented and QA reviewed. Routine delegation.

---

## Lesson 1: the 30-40s overhead is structural, not the model's fault

The first few runs felt sluggish. I assumed it was the model. It wasn't.

After timing carefully, there was a fixed ~30-40s cost on every Paperclip run regardless of model: cold Hermes spawn plus LiteLLM provider probing at startup. DeepSeek-Flash itself answered in **0.8 seconds**. Kimi-via-NGC ranged from 27 to 40 seconds (sometimes timing out). That is a ~30-50x swing from changing one config field. The overhead dwarfed inference time on every fast run.

Before I even got there, I hit a provider routing bug. Hermes agents need `--provider custom` in their extra args, or Hermes can't resolve a LiteLLM model name and falls back to Anthropic auto-detection:

```
Normalized model anthropic/claude-sonnet-4
```

Routing via `--provider custom` fixes it by pointing through the active profile's provider at `:4000`, auto-loading `LITELLM_MASTER_KEY` from `~/.hermes/.env` even under a clean spawn environment.

The structural overhead forced a two-tier architecture I now treat as non-negotiable:

- **Hermes-direct** (warm gateway at `:8642`): fast single-agent jobs, code search, summaries, digests
- **Paperclip**: governed multi-agent work only, where the 30-40s cost buys real coordination value

If the task can be done by one agent, Paperclip is the wrong tool.

---

## Lesson 2: cheap model self-review is not review

The CEO agent wrote `stack_health.py`, a health check that polls the stack's services and reports their status. I asked it to review its own work. It reported: "spec-compliant."

## The error

The bug it missed: `stack_health.py` made unauthenticated HTTP requests to the LiteLLM endpoint.

```python
resp = requests.get("http://localhost:4000/health")
if resp.status_code != 200:
    print("LiteLLM: DOWN")
```

LiteLLM requires an auth header. No header, `401`. The script reported LiteLLM as `DOWN` whenever it was actually running fine.

## The fix

The tests passed because they mocked the HTTP calls. The mock returned `200`. The contract between the script and the real endpoint was never exercised. CEO approved its own work, the mock tests agreed, the bug shipped.

A separate reviewer (one that didn't write the code and wasn't in the same conversation context) would have caught this in thirty seconds by asking whether the endpoint required authentication. Mocked tests pass mocked behavior: that's the trap.

The human merge gate is not bureaucracy. It is the only reviewer whose context isn't anchored to the same assumptions that produced the bug.

---

## Lesson 3: prompt-level role constraints are not enforced

I reconfigured the CEO with a clear instruction: "you are a coordinator who NEVER implements code." I expected the Architect and Builder to start getting invoked.

The CEO fixed the code itself. The Architect, Builder, and QA agents were never hired. Not once.

A capable model with file-write and code-execution tools doesn't need to delegate. It can self-serve, and it will, because delegating means spawning agents, waiting, reviewing, and paying overhead. Doing the work directly is faster. The instruction "never implement" is a preference, not a constraint.

The fix is structural: remove file-write and code tools from the CEO agent entirely. If the CEO cannot write files, it has no choice but to delegate. Any guardrail you can phrase as a sentence, a capable model can override when it judges the task warrants it. Any guardrail you encode into tool availability cannot be overridden at all.

This isn't specific to Paperclip. It applies to any multi-agent system: role boundaries enforced by prompt are advisory. Role boundaries enforced by tool inventory are real.

---

## What I'd tell you to check today

1. **Time your full agent lifecycle**, not just inference. Cold-spawn overhead compounds across every run; if it's structural, you need a warm-gateway tier.
2. **Never let a model review its own output** from the same run. Use a separate agent with no prior context on the task, or a human.
3. **Mock tests only prove the mock behaves correctly.** Any test that doesn't hit the real endpoint cannot catch a contract mismatch.
4. **Encode role constraints in tool inventory, not system prompts.** If a role should never write code, it should not have the code-write tool.

The org did produce real working code. The capability isn't in doubt. The governance is the unsolved part, and all three of these lessons are about governance gaps that only show up when agents are capable enough to route around them.

---

*The sovereign AI stack this runs on is documented, failures included, at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
