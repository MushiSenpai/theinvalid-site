---
title: "One YAML file to rule my estate"
description: "How PROJECT-STATUS.yaml became the single source of truth for 22 projects, and the fail-open trap where a stray quote made the dashboard serve convincing lies."
date: 2026-08-07
tags: ["yaml", "ops", "homelab", "monitoring", "tooling"]
---

One morning I checked my status dashboard and saw an alert: `VM DOWN`. I opened a terminal and checked the VM. It was fine. The dashboard was lying.

## The problem it solved first

Before KARIBUSA, project status lived in three places simultaneously: a `STATUS.md` in each project's docs folder, session-updated memory files agents wrote to between calls, and an `EXECUTION-PLAN.md` that tracked what was supposedly done. In practice, they drifted constantly. An agent would update the plan but forget the status mirror. A memory file would say "Phase 3 complete" three weeks after Phase 4 had started. The more projects I ran (22 and counting), the faster the rot.

The solution was one canonical file that every session is required to update before it closes, with a dashboard that renders it live and flags drift between layers.

`PROJECT-STATUS.yaml` became that file. The conventions header makes the rule explicit:

```yaml
# UNIVERSAL RULE: every session that changes a project's state updates that
# project's entry here IN THE SAME SESSION (status_line, updated_at, phase,
# scores.build/test/benchmark + basis, needs_owner, next_actions)
```

Every project entry carries a `status_line`, a `phase`, three declared scores (build progress against the spec's phase plan, test depth, benchmark evidence), and a computed live GitHub axis. The three-layer model: `PROJECT-STATUS.yaml` is canonical, per-project `STATUS.md` files are mirrors, and `EXECUTION-PLAN.md` is the narrative layer. KARIBUSA renders all three and flags when they disagree.

It replaced four or five context lookups per session with one endpoint call. More importantly, it replaced "I think that project is in phase 4" with a number and a date.

## The error

Then I introduced the fail-open trap.

One session I hand-edited the YAML to update a project's phase. A stray quote. The YAML parser threw an exception. `server.py` didn't catch it cleanly, so `/api/status` returned a 500.

The dashboard's JavaScript caught the 500 and fell back to `mock.json`, the offline sample file I'd built for UI development. That file has hardcoded sample alerts from a made-up estate: services down, VMs unreachable, disk warnings. Real-looking statuses for things that do not exist.

There was a banner indicating sample mode. It was not prominent enough. I read the alert first.

A dashboard that fails into fiction is worse than one that fails into an error screen. A 500 page at least tells you something is broken. A dashboard showing plausible-looking fake alerts trains you to distrust it, and eventually to ignore it.

## The fix

Two changes, both placed at the right layer.

On the server side, `build_status()` now catches `yaml.YAMLError` explicitly:

```python
except yaml.YAMLError as e:
    # A stray quote in any session's hand-edit to the (session-updated)
    # status file must NOT blind the whole dashboard. Degrade to
    # estate-level status (docker/gpu/disk don't need the YAML) with a
    # loud, accurate alert instead of 500-ing — a 500 drops the UI to
    # its offline sample data, which cries false alarms (e.g. "VM DOWN").
    cfg = {}
    mark = getattr(e, "problem_mark", None)
    yaml_error = ("PROJECT-STATUS.yaml parse error"
                  + (f" at line {mark.line + 1}" if mark else "")
                  + " — project rows unavailable until the YAML is fixed")
```

The endpoint still returns 200. Estate-level data (Docker containers, GPU state, disk usage) comes through normally, because those collectors don't touch the YAML. The project rows come back empty. The parse error goes into the `alerts` array with a line number. That is the honest state: infrastructure is fine, the ledger is broken, here is where to look.

On the UI side, the sample fallback sets a `connStale` flag that triggers a hard banner inserted at the very top of the document body:

```
⚠ SAMPLE DATA — /api/status unreachable. NOTHING below is real.
Check: systemctl --user status karibusa.service
```

Red background, bold, first thing you see. Not a subtle badge in the corner.

The principle: if your system's fallback state is visually indistinguishable from its healthy state, you have not designed a fallback. You have designed a trap.

## What I'd tell you to check today

1. **What does your dashboard show when the API is down?** If the answer is "old data" or "sample data," verify that it is visibly different from live data. Not slightly different. Unmissably different.

2. **Does your YAML loader propagate exceptions to the HTTP layer?** A single malformed line should degrade one section, not 500 the whole endpoint. Catch at the boundary, serve what you can, flag what you cannot.

3. **Do you know what line the parse error is on?** `yaml.problem_mark.line` exists. Use it. "YAML parse error" without a location is an invitation to re-read the whole file.

A status system that lies in failure is not a status system. It is an anxiety machine that happens to show correct data most of the time.

---

*The Mushishi estate stack is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
