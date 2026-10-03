---
title: "My uncensored LLM was leaking raw tokenizer output"
description: "Dolphin 24B AWQ in vLLM returned Ġ and Ċ BPE artifacts at ~2 tok/s: what a chat-template misconfiguration looks like when you actually inspect the bytes."
date: 2026-10-03
project: sovereign-ai-stack
tags: ["vllm", "llm-serving", "awq", "tokenizer", "dolphin"]
---

The model answered. The output looked like this:

```
ĠThe Ċidea ĠisĊ toĊ writeĊ aĊ scriptĊ that...
```

Not a terminal encoding issue. Not a font problem. Those are raw BPE token prefixes leaking verbatim into the response: `Ġ` is the Unicode character Roberta-style tokenizers use to mark "space before this token," `Ċ` marks newline. They're internal tokenizer annotations that are supposed to disappear during detokenization. They were not disappearing.

## The setup

The sovereign stack runs two unrestricted LLMs for the creative pipeline: script writers that won't refuse a morally ambiguous scene or append unsolicited content warnings. Both served via vLLM, routed through LiteLLM.

Benchmark run, 2026-06-14. Two models, same workflow.

First: Nemotron PRISM on CPU. Clean output, no refusals, 18 tok/s. Exactly what the spec said it would do.

Second: Dolphin 24B AWQ on GPU. Configuration: `awq_marlin`, GPU memory utilization 0.25. Waited for warmup, ran the same creative prompt.

## The symptoms

Two problems in one output run.

**Speed:** ~2 tok/s. This is CPU-tier throughput on a GPU model. Something about the serving configuration was not using the hardware effectively. The output still arrived. It just took a while.

**The artifacts:** Every response contained `Ġ` and `Ċ` characters distributed through the text. Coherent sentences, complete thoughts, correct structure — but with raw tokenizer notation still present. The model was generating valid token IDs for its vocabulary. The decode stage was not stripping the BPE prefix annotations before returning the text.

Both problems together are a recognizable pattern. Neither on its own tells the full story.

## The diagnosis

Chat-template/decode misconfiguration at the serving layer.

When a model is served with the wrong chat template, or when the tokenizer config loaded at startup doesn't match what the model expects, the final detokenization pass can't do its job correctly. The token IDs come out valid and coherent in the model's vocabulary, but the layer responsible for converting `Ġword` to ` word` and `Ċ` to a newline character is operating against the wrong spec. The artifacts survive into the response.

The `awq_marlin` configuration adds another dimension: the marlin kernel has specific requirements around CUDA versions and quantization format. If the kernel fails to load, vLLM logs a warning and continues serving through a fallback path. Startup logs are long. A kernel fallback warning mid-scroll is easy to miss, and "fallback" still produces output at whatever throughput the fallback path manages.

The output looked real. That is the trap.

## The lesson

"It responds" is not "it works."

A misconfigured serving config produces plausible-looking garbage. A person skimming responses might miss the `Ġ` artifacts — the text is coherent, the refusal rate is right, the structure looks correct. The throughput problem reads as "this model is slow" rather than "this model is misconfigured."

You only catch it if you actually benchmark (to establish a throughput baseline to compare against) and actually read the raw output bytes, not just the high-level shape of the response.

Since this run: every LLM in the pipeline gets a benchmark on initial setup and after any serving config change. The benchmark checks both throughput against an expected baseline and a scan for known artifact characters. "Running" without those two checks is not done.

## What I'd tell you to check today

1. **Read actual response bytes** from every LLM endpoint you depend on. Scan a few raw outputs for `Ġ`, `Ċ`, `<0x0A>`, or any non-ASCII characters that should not be there.
2. **Compare throughput against your expected baseline.** If a GPU model is running at CPU-tier speeds, a kernel likely fell through. Search the startup log for "fallback" and "warning."
3. **AWQ with marlin specifically:** verify your torch and CUDA version combination meets the kernel's requirements before you deploy. The fallback to a slower path is not an error in vLLM's view — it is the default behavior, and it is silent.
4. **Chat templates on quantized models:** the template in the model repo and the template your serving layer applies are not always the same thing. Specify explicitly; do not let the framework guess.

A model that answers is not the same bar as a model that works correctly. Benchmark everything you rely on. Inspect the output, not just the status code.

---

*The sovereign AI stack — serving configs, benchmark scripts, and the failure log — is at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
