---
title: "BHAIRAVA: security audit, mostly assembled"
oneliner: "An orchestration layer over the SovereignSec-AI engine: a variant engine that hunts siblings of known bugs, sandboxed proof capsules, signed SARIF findings, and static detectors for a client's own LLM and agent apps."
status: building
private: true
writeup: "/blog/my-security-auditor-is-80-percent-assembled-not-invented"
stack: ["SovereignSec-AI", "Apache AGE", "Z3", "SARIF 2.1.0", "ed25519", "OWASP LLM Top-10 (2025)"]
started: 2026-07-08
order: 13
---

The build rule: about 80% is assembly. Components that were already shipped and measured (the [code-security auditor](/projects/sovereign-code-auditor), the graph store, chain-of-custody primitives) are wrapped, not rebuilt. The new 20% is the connective tissue: a cross-layer correlation graph, a variant engine that mines patch diffs for structural siblings, a proof oracle where "verified" means a sandboxed capsule replays green on a fresh checkout, and an audit engine that turns the OWASP LLM Top-10 into static detectors run against an agent app at rest.

The validation numbers are published with the losses in. On 55 post-cutoff Django CVEs, code-audit recall on the in-scope set was **0 of 12**, a true result with a named root cause (framework-internal ORM rewrites have no taint signature). One real CVE verified end to end, and its proof capsule replayed green. The false-positive gate held: 0 high-severity findings on 1,369 lines of real audited code.

The boundary that matters: it proposes, a human authorizes. A target without a recorded authorization basis is excluded in code, not by convention.
