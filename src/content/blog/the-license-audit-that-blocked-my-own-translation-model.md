---
title: "The license audit that blocked my own translation model"
description: "NLLB-200, MMS, SeamlessM4T all CC-BY-NC: the Apache label on the repo does not cover the weights inside it."
date: 2026-07-18
tags: ["translation", "licensing", "nllb", "open-source", "local-llm"]
---

I wanted to build a Mizo translator. Mizo is a Kuki-Chin language spoken in northeast India, underrepresented in almost every public model. I found NLLB-200, MMS, and SeamlessM4T, all from Meta Research. State of the art for low-resource translation. I listed them in the spec and moved on to architecture.

Then I ran an actual license audit.

## The error

My spec said NLLB-200 weights were MIT-licensed. One of the LLMs I used to review the spec had said "MIT" with full confidence. I checked the actual model card.

The code is MIT. The weights are CC-BY-NC-4.0.

I checked MMS. CC-BY-NC-4.0. SeamlessM4T v2: CC-BY-NC-4.0, and no Mizo coverage at all. XTTS-v2 from Coqui (abandoned; the idiap fork carries it forward): code is MPL-2.0, weights are CPML, non-commercial.

Four separate model families. Four non-commercial licenses. I had planned to use all four.

This matters because the end goal is a translation service for low-resource-language communities. "Personal use" and "research" are the only safe buckets under NC licenses. Commercial use, even at cost, is not.

The Apache label on a repository does not cover the model weights inside it. The code is open. The weights, which are the product of years of training data and GPU time, are a different artifact with a different license. They are not code. Checking the repo license and stopping there is the trap.

## What the license matrix actually looks like

```
NLLB-200 weights:    CC-BY-NC-4.0  (code: MIT — not the same thing)
MMS ASR + TTS:       CC-BY-NC-4.0  (facebook/mms-tts-lus exists but is NC)
SeamlessM4T v2:      CC-BY-NC-4.0  + no Mizo language support
XTTS-v2 weights:     CPML (non-commercial)

Whisper:             MIT           (commercial-clean)
Qwen3-Omni-30B-A3B: Apache-2.0    (speech-in, speech-out, commercial-clean)
Gemma 3:             Gemma Terms   (not Apache, but commercial-OK)
```

The commercial-safe options are there. They just are not the famous ones.

## The fix: two tracks that never share weights

The stack now has two tracks.

**Track A** is the NC prototype: NLLB-200, MMS, Bible audio alignments from FCBH. Fastest path to a working system. Every artifact from this track is quarantined in `data/nc/`. It cannot feed Track B training sets.

**Track B** is the commercial lane: Whisper fine-tuned on owned audio, Qwen3 LoRA trained on clean parallel data, VITS/Piper TTS built from scratch on consented recordings. Slower to build. Actually deployable.

Then I wrote license CI to make "these tracks never cross" a build-time enforcement rule, not a promise.

Every training run is described by a manifest YAML that lists its data sources. Before any GPU runs, the CI gate checks each source against a provenance ledger. If a Track-B manifest references anything tagged NC or unresolved, the build fails:

```
license-ci: trackA-mt-v0.manifest.yaml [track-a] -> ok
license-ci: trackB-mt-v0.manifest.yaml [track-b] -> ok
license-ci: all manifests clean.
```

The red-team test: plant the NC Bible audio in a Track-B manifest and run the gate.

```
license-ci: redteam-nc-in-b.manifest.yaml [track-b] -> FAIL

license-CI FAILED (D9 NC-quarantine violations):
  - [redteam] source 'fcbh-mizo-bible-audio': is non-commercial
    (license=CC-BY-NC-4.0, quarantined=True) — forbidden in a Track-B set
```

The enforcement is also structural: a pydantic validator refuses an NC source from claiming Track-B eligibility at the time you write the ledger row. A DB constraint blocks it at the relational layer. Three independent points. One mistake at any layer should not be enough to contaminate the commercial track.

## The corpus problem has the same shape

The data side has the same pattern. A 6.98M-pair English-Mizo corpus from HuggingFace looked large and useful until I traced its lineage: NLLB-mined, OPUS-lineage, no license tag. The NC taint from the generator model runs through to the output. Track A only, quarantined.

The FineTranslations `lus_Latn` set (90,411 pairs, ODC-BY, Gemma-3-27B generated) is clean for Track B after a quality-evaluation gate passes, because ODC-BY is commercial-safe. A quality gate matters here: COMET-QE is blind to Mizo and scored the full 90k at a mean of -0.66, with an absolute cutoff accepting only 0.49% of rows. That is not "99.5% of the data is garbage." It means absolute score thresholds do not work for low-resource languages, and the gate has to be percentile-based with a complementary round-trip filter.

## The dialect gate

The other thing that blocked the fine-tune: the owner's helper speaks Mizo, or something related to it. She described her variety as "Ziak" and her written form as "Maianbai". I put both in the spec.

Then I actually looked them up. "Ziak" is the ordinary Mizo verb for "to write". "Maianbai" is a pumpkin-leaf stew. Neither is a dialect name.

This matters because every public Mizo corpus is standard written Mizo (Duhlian variety, Latin script). If her variety diverges from that significantly, training on the public corpus builds the wrong model. Before any fine-tune runs, she records a dialect identification session: 200 elicitation phrases, 30 minutes of free speech, 20 writing samples. The dialect report from that session is a gate. If it says her variety is not standard Mizo, the data plan gets rewritten before any GPU runs.

"I don't know which variety she speaks" was always true. Putting a guessed variety name in the spec made it invisible.

## What I'd tell you to check today

1. If a model shows "Apache-2.0" on the repository, read the model card separately. Check what that license actually covers. Weights are frequently different.
2. NLLB-200, MMS ASR/TTS, SeamlessM4T, XTTS-v2: all CC-BY-NC. If you are building something commercial, these are the wrong starting points regardless of what any LLM tells you about their licenses.
3. If you have NC and non-NC training data in the same pipeline, enforce the separation structurally. A comment in the spec is not enforcement.
4. If your corpus uses a generator model, the generator's license taint runs through to the outputs. Trace it before you assume the output is clean.

The repo is private for now (household audio, owned training data). The framework code and fine-tuned models publish when Track B has benchmark numbers to back them up.

---

*Spec and architecture at [github.com/MushiSenpai/isaza](https://github.com/MushiSenpai/isaza) (private until the HF release gate clears).*
