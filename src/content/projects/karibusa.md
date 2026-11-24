---
title: "KARIBUSA: the estate ledger"
oneliner: "One YAML file is the canonical status of every track I run. A local dashboard renders it against the plan and the live machine, and shows where the three disagree."
status: shipped
private: true
writeup: "/blog/one-yaml-file-to-rule-my-estate"
stack: ["Python stdlib", "YAML", "systemd", "git / docker / nvidia-smi collectors"]
started: 2026-07-01
order: 9
---

Named for the family in Mushishi who keep the scrolls recording every mushi. Before it, project status lived in three places that drifted constantly: a status file per project, memory files agents wrote between sessions, and an execution plan. With more than twenty tracks, "I think that one is in phase 4" stopped being good enough.

Now one file is canonical and every work session must update it before it closes. Per-project status files are generated mirrors. The dashboard renders the ledger next to live collectors (git, containers, services, GPU, disk) and flags drift between what the plan says and what is actually running. Each track carries declared scores for build, test depth and benchmark evidence, plus a computed GitHub axis.

It earned its two write-ups the hard way. A stray quote in the YAML once made the dashboard fall back to its sample data and serve convincing lies, a fail-open trap. Later, a generator wrote status mirrors into a vault that only sessions were forbidden to touch: [the rule guarded sessions, not tools](/blog/vault-rule-guarded-sessions).

The engine is clean, but the ledger itself is the private record of everything I run, so the repo stays private.
