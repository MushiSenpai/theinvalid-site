---
title: "I built a three-stack AI system without writing code"
description: "The method behind building a sovereign LLM stack, a video stack, and an audio stack without hand-writing code: spec-driven, LLM-directed, gate-verified."
date: 2026-07-11
project: sovereign-ai-stack
tags: ["llm-directed", "spec-driven", "ai-infrastructure", "workflow", "method"]
---

The claim is simple and needs precision: I designed, deployed, and operate a sovereign LLM stack (vLLM, Nemotron NVFP4, LiteLLM), a video generation stack (ComfyUI, FLUX.2, Wan 2.2, HunyuanVideo, SAM3), and a local audio stack (Fish Speech, WhisperX, LatentSync, YuE 7B, FastAPI + Redis/RQ job queue) — and I did not write a single function in any of those repos.

Every script, Docker Compose file, FastAPI worker, config file, and workflow JSON was written by an LLM under my direction.

That sentence usually gets one of two misreadings. The first is "vibe coding" — type some prompts, accept whatever comes out, hope it works. The second is "used ChatGPT" — one model, one conversational thread, iterative patching until something ran. Neither is what happened.

## The method

```
discuss (multi-LLM) → consolidate → spec → execute (LLM-directed) → verify (gates) → operate
```

**Discuss**: before a line of code exists, the architecture problem goes to a council. Claude is primary — it holds context well across long specs. Gemini, Grok, Kimi, and DeepSeek contribute at idea stage. These aren't coding sessions; they're architecture sessions. The output is a decision, not an artifact.

**Consolidate**: the competing perspectives get synthesized into a position — one choice, with the alternatives documented and why they lost. The Decision Log in the Sovereign AI Stack repo has 20+ of these entries, including six hours of TensorRT-LLM debugging that ended with "use vLLM instead," every dead end preserved.

**Spec**: the decision becomes a machine-executable document. Which image, which flags, what the verification gate looks like, what "done" means. The spec is the artifact I actually produce. If the spec is vague, the implementation will be too.

**Execute (LLM-directed)**: Claude implements the spec, session by session, file by file. I review each piece. I don't write code, but I read it fluently — B.E. in Computer Science; the degree turned out to be useful, just not in the way I expected. I can tell when a FastAPI worker doesn't match the spec. That's enough.

**Verify (gates)**: every phase ends with a gate that can't be faked. The audio stack's gate is a fresh container passing an end-to-end music-generation job with zero manual intervention. The creative stack's gate is a named workflow producing output that matches the benchmark standard. You don't move to the next phase until the gate passes.

**Operate**: this is where most LLM-built systems fall apart, because the model doesn't operate them — you do. Backups (the one that [failed silently for 17 days](/blog/my-backup-failed-silently-for-17-days)). Watchdogs. VRAM lifecycle scripts. Mode-switch handoffs between stacks on a shared 32GB budget. The unglamorous part that determines whether a system is useful or just a demo.

## What this is not

It is not vibe coding. Vibe coding accepts what the model produces. This method produces a spec and then verifies that the model met it.

It is not "AI does the hard part." Architecture decisions are hard. Tool evaluation is hard. Figuring out that a specific batch-token flag is the hidden knob when fitting a 30B multimodal model in 32GB of VRAM is hard. The code is the part that can be delegated.

It is not a workaround for not knowing how to code. "I don't write code" is a choice about where leverage is, not a confession about a gap.

## What it costs

The audio stack install deviated from its spec in 25+ documented places. Every deviation is in `LESSONS.md` in the public repo — because the failures are more useful than the successes. The spec is a hypothesis. The execute phase is where you find out which hypotheses were wrong.

Writing a precise spec is harder than it sounds. A spec that's ambiguous about edge cases becomes a code change that breaks something three phases later. Most of my time in this method is in the spec and verify steps — not the execute step.

## The repos are the proof

Three stacks, publicly documented, operating daily on a single RTX 5090 in Singapore. Decision logs that include the dead ends. Benchmark tables with empty cells that fill in weekly, pass or fail. LESSONS.md files that document every place the original spec was wrong.

The method works. The repositories are the evidence.

---

*All three stacks are documented at [github.com/MushiSenpai](https://github.com/MushiSenpai).*
