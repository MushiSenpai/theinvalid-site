---
title: "My security auditor is 80 percent assembled, not invented"
description: "How BHAIRAVA shipped as a real one-person security product: 80% existing measured components, 20% new connective tissue, and Stage V honest failures including 0/12 recall on real Django CVEs."
date: 2026-08-01
project: sovereign-code-auditor
tags: ["security", "code-audit", "owasp-llm", "validation", "sscai"]
---

The thing nobody tells you about building a security product solo is that it doesn't start with the product. It starts with a list of everything you already have.

I started BHAIRAVA, a code and infrastructure security auditor, with a doc dump of every component in the estate. Cross-file taint analysis: shipped (SovereignSec-AI). OSINT passive collectors: shipped (Tanyuu CASM). Egress monitors, honeytoken canaries, bitemporal knowledge graph, chain-of-custody primitives: all shipped, all tested. The spec ended up with a doctrine line: "~80% of BHAIRAVA is assembly. Rebuilding measured components wastes budget and loses the proof lineage."

That became the build rule.

## What "assembly" actually means

Assembly is not glue code. It is thin adapters over measured engines with one constraint: a thing that is already tested does not get rebuilt.

The 20% that is new: a cross-layer security correlation graph (code findings, surface assets, cloud posture, and attacker behavior on one queryable AGE graph); a zero-day variant engine that mines patch diffs from 879 vuln/fix pairs and hunts structural siblings of known bugs; an execution/proof oracle where "verified" is defined as a sandboxed proof capsule replaying green on a fresh third-party checkout; a delivery backbone that signs findings with ed25519 and emits SARIF 2.1.0; and an AI/LLM audit engine that turns the OWASP LLM Top-10 (2025) into static detectors against a client's agent app at rest (system prompt, tool scopes, MCP manifests, RAG corpus, all analyzed without executing any client material).

The 80% came with tests already. The 20% added 282 of its own across P0 through P9, all running offline with no key and no active scan.

## Symptoms (Stage V)

Stage V was real-corpus validation against 55 post-cutoff Django CVEs (advisory >= 2025-01, fix commit >= 2024-07, leak-resistant double-cutoff).

The result: P1 code-audit recall on in-scope real Django CVEs = **0/12**. That is a true result, not a broken harness. The same engine scores 6/9 on its own haystack with known positives. The root cause for the Django misses is named: `check_alias`, `add_filtered_relation`, and the other SQLi targets are framework-internal ORM query-compiler rewrites with no source-to-sink change in the isolated function. There is no taint signature to find. A fine-tuned Qwen2.5-Coder added **+0.0 detection** over base on these, measured on the same leak-resistant corpus.

The metamorphic suppression gate had a calibration bug. The 30B sovereign model correctly proposed CVE-2025-59682 (path traversal, CWE-22/23) but the gate suppressed it:

```
hybrid_kept=False
# 0 of 6 proposals JSON-parseable at 320 tokens
# 5 of 6 JSON-parseable at 1024 tokens
```

`sscai.structured_llm_findings` was capped at 320 output tokens. The reasoning model spent its entire budget in the `<think>` block and the JSON was truncated. The correct proposal was appearing 9/12 = 75% of the time at an untruncated budget, well above the majority threshold. The fix was a K-sample majority gate (K=3, keep if >=2 of 3 draws agree) instead of a single-shot identity check. K=1 reproduces the old byte-deterministic behavior.

The aiohttp `pickle.load` CWE-502 deserialization was also missed. The untrusted input is a plain parameter in the isolated function, not a recognized attacker source in that scope. Whole-repo/framework-aware taint that traces back to the call boundary fixes it. Obvious once you see it.

## The error that didn't happen

CVE-2025-59682 verified end-to-end: Z3 proved the path feasible, the sandboxed runner detonated, the proof capsule replayed green on a fresh third-party checkout. Capsule replay rate: 1/1. FP death-spiral gate on 1369 LOC of real audited Django utility code: 0 high-severity findings. That gate held.

## The boundary that matters

D6 in the spec: no autonomous exploitation of third-party targets, ever. Active scanning, exploitation, honeypot pivots, and bug bounty submissions require a signed authorization file with an ownership/legal-basis attestation. BHAIRAVA proposes. A human authorizes and acts.

This is not a late safety addition. The authorization ledger is checked at corpus assembly time: a target without a recorded basis is excluded in code, not by convention. The check raises before the corpus runs. "By convention" does not survive a distracted session.

## What I'd tell you to check today

1. List what you already have before speccing what you are building. "80% assembly" is a planning discipline, not an apology.
2. A 0/N recall on a real benchmark is a true result if the same engine scores on a sanity control and the root cause is named. "Framework-internal ORM query semantics" is a named root cause.
3. Token budget truncation kills reasoning models silently. 320 tokens completed the `<think>` block. 0 proposals survived to JSON. Log raw token counts alongside parse failures.
4. The authorization gate needs to be software. Write the code that enforces it, then document what the code does. Convention-only gates do not hold.

---

The SovereignSec-AI code-audit engine that BHAIRAVA builds on is documented at [github.com/MushiSenpai/SovereignSec-AI-Auditor](https://github.com/MushiSenpai/SovereignSec-AI-Auditor). BHAIRAVA (the orchestration layer) stays private until Stage P, when a sanitized public framework core extracts.
