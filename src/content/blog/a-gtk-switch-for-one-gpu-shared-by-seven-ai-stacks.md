---
title: "A GTK switch for one GPU shared by seven AI stacks"
description: "GTK4 mode switcher for an RTX 5090 shared across seven local AI stacks: the idle-vs-busy detection problem, an SM-util false positive from reverse-PRIME graphics, and why the app is a front-end only."
date: 2026-08-08
project: sovereign-ai-stack
tags: ["linux", "gtk4", "gpu", "local-llm", "ops"]
---

Seven AI stacks, one 32GB RTX 5090, and a rule: only one runs at a time.

The rule is easy to state. Enforcing it without accidentally killing a running render, without remembering which Docker containers each mode owns, and without re-deriving the kill sequence every time I add a new stack: that is the problem Mushishi Mode solves.

The predecessor was a `zenity` dialog. Pick a mode, confirm, a script runs. It worked. But it couldn't show VRAM state, couldn't warn when something was actually in flight, and couldn't distinguish a model that was loaded-but-idle (safe to purge) from one mid-request (not safe to kill). So I built a native GTK4 + libadwaita switcher.

## The modes

Seven operating modes share the card, never concurrently:

| Mode | Stack | VRAM estimate |
|------|-------|---------------|
| Coding | Qwen3-Coder 30B-AWQ (:8000) | ~29 GB |
| Forensic | Nemotron omni 30B (:8000, 180K ctx) | ~30 GB |
| Agent | Nemotron light (:8000) + Fish Speech | ~22 GB |
| Creative | ComfyUI (FLUX / Wan / Hunyuan) | ~14-24 GB |
| Audio | Fish Speech + WhisperX + lipsync tiers | varies |
| Music | YuE 7B | ~16 GB |
| 3D Foundry | TRELLIS.2 + mesh ops + rigging | ~5-31 GB |

Two CPU floor models (Nemotron :8001, Qwen-coder :8002) stay up through every switch. The mode scripts know to leave them alone.

## The design line: front-end only

The app never calls `docker stop` itself. Applying a mode runs `scripts/*-mode.sh`, the same scripts cron and a terminal would use. All stop/start logic lives in those scripts, not in the GUI.

`gpu-tenants.sh` is the single source of truth: one file, sourced by every mode script, declaring the full list of containers that can be stopped (`GPU_TENANTS`). Mode scripts only act on names in that array. A foreign process, a container from a different project, a model someone else loaded: none of them are touched. The constraint is structural, not a convention that drifts when memory fades.

## The real problem: idle vs busy

A model holding 28GB of VRAM and doing nothing is safe to evict. A model serving a request is not. These are not the same condition, and "is the container running?" answers neither.

`gpu_busy_report()` in `gpu-tenants.sh` checks in this order:

1. **vLLM `/metrics`**: `vllm:num_requests_running` + `vllm:num_requests_waiting` (exact)
2. **ComfyUI `/queue`**: running and pending items (exact)
3. **Audio RQ (`creative-redis`)**: started/queued registries across stt/voice/lipsync/music/dub queues (exact)
4. **3D RQ (`td-redis`)**: jobs across s3-s10/chain queues (exact)
5. **SM-utilization backstop**: only reached if 1-4 are all quiet

## The error hiding in step 5

The SM-util backstop has a trap specific to this hardware. My display runs over reverse-PRIME: the AI GPU has no monitor port, so the compositor offloads to it via PRIME. Desktop graphics activity spikes SM-util to 23-27% with zero CUDA compute processes. A raw threshold would report BUSY every time a window animates.

The fix is one AND:

```bash
# F79-CORR: desktop graphics spike util with no compute process
local peak; peak=$(gpu_sm_peak)
if [ "${peak:-0}" -gt 15 ]; then
  local capps
  capps=$(nvidia-smi --query-compute-apps=pid,process_name,used_memory \
            --format=csv,noheader,nounits 2>/dev/null | sed '/^[[:space:]]*$/d')
  if [ -n "$capps" ]; then
    out+="GPU compute active: ${peak}% SM util ..."
  fi
fi
```

If `--query-compute-apps` returns nothing, the util spike is graphics, not a workload. This distinction matters on any headless AI box running a compositor over PRIME offload.

## Three bugs that hit before the first week was out

**`Gtk.ListBox` single-click auto-apply.** `Gtk.ListBox` defaults to `activate-on-single-click=TRUE`. Clicking any mode row fired `row-activated`, which called `_apply()`. The Apply button was never used because every click was already a commit. Fix:

```python
self.mode_list.set_activate_on_single_click(False)
```

**Python `str.splitlines()` eating `\x1d`.** `probe.sh` used ASCII Group Separator (`\x1d`) as a field delimiter between process records. Python's `str.splitlines()` treats `\x1d`, `\x1c`, and `\x1e` as line boundaries, so every telemetry process record was split into fragments and the list always showed empty. Fix: switch to TAB (`\x09`), which is not a splitlines boundary.

**Stale busy verdict at Apply time.** Pressing Apply used `self.busy`, populated at last probe and up to 4 seconds stale. A session that started a job after the last refresh could be killed without a warning. Fix: Apply re-probes and decides on a fresh verdict before launching anything.

## What I'd tell you to check today

If you run multiple AI stacks on one GPU:

1. Write one canonical stop-list. Not a `grep` in each script that drifts when you add a container.
2. Keep stop/start logic in scripts the CLI can run directly. If the UI is the only way to switch modes, the UI becomes load-bearing infrastructure.
3. SM-utilization is not a workload signal on a machine running a display compositor over PRIME. AND it with `nvidia-smi --query-compute-apps`.
4. Check whether your "safe to switch" guard uses a fresh probe or a cached one.

The app source is private (it encodes the GPU-tenancy layout for the whole estate), but the design spec lives in `DESIGN.md` alongside the rest of the estate docs.

---

*The AI workstation this switcher manages is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
