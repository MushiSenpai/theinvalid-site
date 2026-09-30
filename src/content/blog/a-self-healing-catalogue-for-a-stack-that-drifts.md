---
title: "A self-healing catalogue for a stack that drifts"
description: "After 4 of 9 ComfyUI workflows broke from upstream node renames, I built a monthly validation job that detects drift, regenerates the public catalogue, and refuses to auto-fix the renames."
date: 2026-09-30
project: creative-stack
tags: ["comfyui", "workflow-validation", "maintenance", "automation", "ops"]
---

[An earlier post](/blog/my-tested-workflows-broke-from-upstream-drift) covered the find: four of nine ComfyUI workflows I had marked tested had silently broken from upstream node renames. `HunyuanVideoModelLoader` became a family of `HunyuanVideo15*` nodes. `EmptyWanLatentVideo` became `Wan22ImageToVideoLatent`. Four workflows, two days of rebuilds, render-verified before anything was marked fixed.

That post ends with a recommendation: schedule re-validation. This one is what that looks like when you actually build it.

## The validation script

`workflow-validate.py` is 55 lines. It fetches the live `/object_info` registry from the ComfyUI API, walks every workflow JSON in the workflows directory, and compares each node's `type` field against the registry. Any type with no match is drift. Output is JSON:

```json
{
  "dreamforge": {
    "status": "drift",
    "missing_nodes": ["HunyuanVideoModelLoader"]
  },
  "quickdraw": {
    "status": "drift",
    "missing_nodes": ["EmptyWanLatentVideo"]
  },
  "goldsmith": {
    "status": "ok",
    "missing_nodes": []
  }
}
```

It does not render anything. ComfyUI only needs to answer `/object_info`, which is lightweight. The script excludes a few well-known non-registry types (`Note`, `MarkdownNote`, `Reroute`, `PrimitiveNode`) and explicitly skips the two retired in-graph LLM cinematic graphs that will never validate against current nodes and are intentionally not rebuilt.

## The maintenance job

`workflow-maintenance.sh` (v1, 2026-06-14) wraps the validator into a cron job that runs on the 1st of each month at 08:00. What it does automatically:

1. Checks GPU availability. If free VRAM is above 6GB, proceed. If the GPU is held by a foreign process, skip and report. If held by our own idle tenants, flush them for the run and restore them afterward.
2. Starts ComfyUI if it is not already running (only for the registry call, not a full creative session).
3. Runs `workflow-validate.py` and saves the output to a dated log file.
4. Runs `generate-catalogue.py --strict` to regenerate the public HTML catalogue from the benchmark CSVs.
5. Commits and pushes the catalogue if it changed.
6. Sends an ntfy notification to my phone:

```
Workflow maintenance: 9 ok
OK: 9
DRIFTED (rebuild needed): dreamforge (missing HunyuanVideoModelLoader, ...)
Catalogue regenerated -> theinvalid.me/workflow-catalogue.html
```

## What it deliberately refuses to do

Auto-fix the renames.

A node rename almost always means changed inputs or outputs. If the script auto-patched `HunyuanVideoModelLoader` to `HunyuanVideo15*`, it would be connecting wires that no longer match. The workflow might pass validation and still produce garbage on the next render. The only safe fix for a renamed node with different I/O is a rebuild: start from the node pack's current example template, rewire against the new nodes, run a real render and check the output. A script cannot do that safely, so the script does not try.

The design principle: automate detection and reporting fully. Gate the repairs behind judgment.

## Why `--strict` matters

Without it, a newly-added workflow that never gets classified just quietly disappears from the public catalogue, or worse, gets published with placeholder data. With `--strict`, any unclassified workflow that shows up in the benchmark CSVs causes the catalogue regeneration to fail and notifies my phone instead. The catalogue only regenerates from a known-complete inventory.

This also means the catalogue automatically picks up new entries when I add a workflow to the CSVs and write its metadata. Discovery is automatic. The editorial decision is manual.

## What I'd tell you to check today

1. The core of `workflow-validate.py` is about 20 lines: fetch `localhost:8188/object_info`, compare each node's `type` against the key set, report any miss. Adapt it for your stack before you need it.
2. Run this before a client session, not after. Finding drift on the morning of a job is a different experience from finding it on the first of the month with nobody waiting.
3. Do not auto-fix node renames. Detect and report automatically. Rebuild with eyes on the output.
4. Wire a heartbeat to your maintenance job. The script writes a success sentinel only at the end of a real completed run; a skipped cycle stays overdue. If your monitoring can fail silently, you do not have monitoring.

---

*Workflow JSONs, benchmark data, and the maintenance tooling are at [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack).*
