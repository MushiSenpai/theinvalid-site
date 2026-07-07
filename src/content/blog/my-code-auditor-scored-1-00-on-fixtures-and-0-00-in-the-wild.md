---
title: "My code auditor scored 1.00 on fixtures and 0.00 in the wild"
description: "13 real Python web apps, 276 findings, zero true positives. The five rule bugs real code exposed, the −90% fix pass that still found nothing, and the LLM oracle that coin-flips on the hard case."
date: 2026-07-08
project: sovereign-code-auditor
tags: ["security", "sast", "static-analysis", "benchmarking", "failure", "taint-analysis"]
---

I built a local, zero-egress AI code auditor — cross-file taint tracking plus curated Semgrep/Bandit rules, with an LLM validation pass on top. On its own seeded benchmark suite, the cross-file taint engine measured precision **1.00**. Perfect score. Every planted vulnerability found, nothing false flagged.

Then I pointed it at 13 real, actively maintained open-source Python web apps — Flask, Django, FastAPI, Tornado, ~8,500 Python files, the largest repo alone over 2,000 files.

**276 findings. Zero true positives. Precision: 0.00.**

Not "lower than fixtures." Zero. This post is the arc from that number to something honest: the five rule bugs real code exposed, the fix pass that cut noise 90% and still found nothing real, a seeded-CVE experiment on the LLM oracle, and one result I had to retract because my measurement harness was lying to me.

## Why fixture benchmarks lie

The fixture score wasn't fake. The taint engine genuinely found every vulnerability in the seeded repos, cleanly. The problem is structural: **I wrote the fixtures and I wrote the rules, so the fixtures contain exactly the patterns the rules match.** A seeded benchmark measures whether your engine does what you designed it to do. It cannot measure whether what you designed corresponds to real code, because real code is written by people who never saw your sink list.

Real code, it turns out, does things like call `.json()` on an HTTP response. Which brings us to the bugs.

## The five bug classes real code exposed

Every high-signal false positive traced back to one of five reproducible rule bugs. These, not the scan results, were the actual deliverable of the first wild run.

**1. The SSRF rule flagged every `requests.get(...).json()` — a 100% FP generator.** The rule's taint sources included the bare attributes `$REQ.json` and `$REQ.data`, meant to catch Flask's `request.json`. But they also matched the ubiquitous `.json()` accessor on a `requests` *response* object. So `requests.get(url)` — the very call whose `.json` gets read — became a taint source, and it is *also* the SSRF sink. The call self-taints and fires. Minimal repro: `requests.get("https://example.com", timeout=3)` → 0 findings; append `.json()` → 1 finding. Every flagged URL in the wild was a hardcoded vendor endpoint, an env var, or an admin-configured backend.

**2. The deserialization sink matched any `.loads` tail.** `json.loads`, a URL-safe query-string decoder's `.loads`, an HMAC-signed serializer's `.loads` — all flagged as CWE-502 as if they were `pickle`. Only `pickle`/`cPickle`/`marshal`/unsafe `yaml.load` deserve that sink. Match the receiver module, not the method name.

**3. Sink arg-focus was positional-only.** The engine flagged `cursor.execute(sql, params)` where the user value was in the *bound params* — the safe part — and flagged `send_file(BytesIO(...))` as path traversal when the "path" was an in-memory buffer. It couldn't tell a string-built query from a parameterized one, or a filename from a buffer.

**4. No reachability model at all.** Every function's parameters were treated as attacker-controlled. So it flagged offline database migrations, CLI scripts, and data-source connectors that fetch from their own configured backends — code no web request can reach or influence.

**5. The SAST layer could vanish silently.** Run the CLI without the venv's bin on `PATH` and the `semgrep` subprocess fails; the tool printed a `[warn]` to stderr and returned taint-only results with exit code 0. A user could lose an entire analysis tier and never know.

Notice what these have in common: none of them can be caught by fixtures that were written to match the rules. You need code you didn't write.

## The fix pass: −90% noise, still zero bugs

I fixed all five, each with a paired regression test — the false-positive repro guarded next to a positive control, so an over-broad fix that silently killed real detection would fail the suite. Then I re-ran the exact same harness on the same 13 repos.

High-signal findings: **20 → 2**. Default output (with the generic Bandit tier demoted behind a flag, where its 256:0 noise belongs): **276 → 2**. Runtime dropped too.

True positives: **still zero.** 0/2 is still precision 0.00.

Here's the part I want to say carefully, because it's the honest expected result, not a consolation prize: **finding zero real vulnerabilities in well-maintained, popular OSS web apps is what a truthful tool should report.** These projects use ORMs and parameterized queries everywhere; my one genuinely precise SQL-injection rule — verified to flag string-built queries and skip the parameterized call next to them — produced zero findings across all 13 repos because there was nothing for it to catch. The fixes removed *noise*; they did not and could not conjure bugs that aren't there. (Caveat that matters: this is a precision-only study. There's no ground truth for these repos, so recall — "did it miss real bugs?" — is unmeasured. Both numbers can be bad at once.)

The two surviving false positives weren't rule-firing bugs. They were two deeper, nameable limits:

- **Reachability**: one finding flagged an f-string-interpolated table identifier that is allowlist-guarded two lines up, with the actual user value safely bound as a parameter. The engine has no model of "this value is checked against a fixed set before use."
- **Value provenance**: the other flagged a connector building a URL whose *host* comes from an admin-configured setting — only a path segment varies. The SSRF sink judges the whole URL argument; it has no concept of who controls the host position.

Those two classes are exactly what the project's LLM validation oracle is supposed to handle. Which finally made that testable.

## Seeding CVEs to test the oracle

With zero real true positives, the oracle had nothing to preserve — I couldn't measure "keeps TPs while dropping FPs" on an all-FP surface. So I built the missing half: into three of the same repos (pinned SHAs, shallow clones, deleted after the run, never pushed anywhere), I injected one idiomatic vulnerable endpoint each, modeled on real CVE patterns and written in the repo's own style — a SQL injection that string-builds a query from a request arg, a `pickle.loads` on base64-decoded POST data, and a `requests.get` on a user-supplied URL parameter.

The deterministic core found all three planted vulns (it had better — that's what the fixtures already proved) plus the two real FPs. Five findings, known labels. Then the LLM triage — a local qwen3-coder on my own GPU, one-word REAL/SAFE verdict, 20 votes per finding at temperature 0 — filled in the 2×2:

|  | Oracle says REAL | Oracle says SAFE |
|---|:---:|:---:|
| **Planted TP (3)** | **3** | 0 |
| **Real FP (2)** | 1 | **1** |

- **True positives preserved: 3/3, at 20/20 votes each**, across all three CWE classes, in every prompt variant I tried. The oracle never dropped a real vulnerability.
- **The obvious FP (admin-fixed host): rejected 20/20.** Clean kill, sane reasoning.
- **The subtle FP (bound param + allowlist guard): 40% correct.** A coin-flip, leaning *wrong* — the oracle rubber-stamps this false positive as REAL 60% of the time. The transcripts show it *sees* the allowlist check and the bound parameter, then waffles about whether the interpolated identifier is user-controlled. The guard is in-function; this isn't missing context. It's genuine model uncertainty on exactly the value-provenance question the deterministic core also can't answer.

Chain-of-thought didn't rescue it. A "reason briefly, then emit a verdict" variant left the hard case at exactly 0.40.

So: net precision on this surface went 0.60 → 0.75 with zero recall cost. The thesis — LLM oracle filters the deterministic core's FPs while keeping its TPs — is *partially* supported. Reliable TP-preserver, good filter for obvious noise, not sufficient for the hard class. The engineering consequence: single-shot triage is untrustworthy (temp 0 under vLLM's continuous batching is not deterministic — same prompt, split verdicts), so the wiring becomes an N-run vote with an asymmetric rule: unanimous-SAFE drops a finding; any disagreement escalates to the human gate rather than silently clearing it.

## The result I retracted

One more, because it's the most transferable lesson in the whole arc.

An earlier chain-of-thought run *appeared* to show something exciting: reasoning-first prompting fixed the subtle FP (1.00 correct!) — at the cost of cratering SSRF detection to 0.12. A dramatic, publishable trade-off. It was neither. Both numbers were a harness bug: my 220-token output cap truncated responses before the `VERDICT:` line, and a naive fallback parser then guessed the verdict from whether the word "real" appeared in the truncated text. It was mis-scoring answers that were reasoning *correctly*. With a larger cap and a strict parser, the effect vanished entirely: CoT neither helps nor harms.

I nearly wrote conclusions about model behavior that were actually facts about my regex. When a result is surprising in *both* directions at once — one number jumps, another craters — suspect the measurement before the model. You have to measure your measurer.

## What I'd tell you to check

1. **If your analyzer has only ever seen benchmarks you authored, its precision number is a statement about your test-writing, not your tool.** Run it on real code you didn't write; triage every finding by hand. The bug list you get back is worth more than the scan.
2. **Report the zero.** "We found no vulnerabilities in 13 well-maintained OSS apps" is the correct output of an honest tool on that corpus. A tool that always finds something is describing itself.
3. **LLM verdicts are distributions, not answers.** Vote N times and route disagreement to a human — and make the vote asymmetric, because keeping a false positive and dropping a true positive are not equal-cost errors.
4. **Before you publish a surprising eval number, attack the harness.** Token caps, fallback parsers, and lenient regexes will hand you exciting results that are about nothing.

The auditor's code, benchmark harness, and honest results — failures included — are public.

---

*SovereignSec-AI-Auditor is at [github.com/MushiSenpai/SovereignSec-AI-Auditor](https://github.com/MushiSenpai/SovereignSec-AI-Auditor); the fine-tuned LoRA adapters are on HuggingFace ([7B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-7B), [32B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-32B)). The 13 wild repos stay anonymized (repo-A…M): zero true positives means zero disclosures, and naming projects a tool false-flagged would be noise dressed as news.*
