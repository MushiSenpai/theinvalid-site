---
title: "A local 3D asset foundry with two license lanes"
description: "TRELLIS.2 vs Hunyuan3D on one RTX 5090, QuadRemesher tracing-stop when Python launches it, and why the VLM judge failed a good asset the pixel metrics cleared."
date: 2026-07-29
project: three-d-stack
tags: ["3d-pipeline", "docker", "licensing", "quadremesher", "trellis2"]
---

The pitch: client image in, validated game-ready 3D asset out, fully local on one RTX 5090. No cloud, no per-model billing. I've been building this (URO, the 3D sibling of my creative stack) for about a month. The technical problems were mostly expected. The licensing problems were not.

## Two lanes from the start

My first instinct was to use the best available model. Hunyuan3D 2.1 produces better image-to-mesh results than anything else open in 2026. It also carries a Tencent Community License that is void in the EU, UK, and South Korea, caps at 1M MAU, and prohibits using outputs to train other models. "Probably fine" does not work when a client pipeline could touch any of those cases.

The result is two lanes, decided at intake:

- **Lane C (commercial-safe):** TRELLIS.2 4B (MIT) plus all-MIT/Apache mesh tooling. Any client, any territory.
- **Lane Q (best-quality):** Hunyuan3D 2.1. Own portfolio and clients who pass a territory and MAU gate at intake.

RMBG-2.0 (background removal) almost made it into Lane C. The masks are better than the alternatives. I quarantined it the day I read the license: CC BY-NC 4.0 is categorical, no revenue threshold, no commercial use, no exception. The production S0 stage uses rembg and SAM3 (both MIT-class). The better-quality model stays in the test notebook.

Lane enforcement is a gate at S0, not a policy document. Every job records its lane, territory answers, and license-lane statement in a `manifest.json` that every downstream stage reads and writes. You cannot accidentally ship a Lane Q asset under a Lane C delivery profile.

## The CUDA version trap

TRELLIS.2 4B requires CUDA 12.8. The host runs CUDA 13.2. The model breaks on CUDA above 13.1 (upstream issue #19). Downgrading the host would break everything else on the shared workstation. The answer: every 3D generation service runs inside cu128 devel containers with `TORCH_CUDA_ARCH_LIST=12.0` source builds. The host toolchain is untouched.

Three containers: `td-trellis2` (:9101) for generation, `td-meshops` (:9102) for headless Blender 4.5 LTS plus the mesh toolchain (trimesh, pymeshlab, xatlas, QuadWild, gltf-transform), `td-unirig` (:9103) for auto-rigging. The orchestrator enforces use-flush-load: two heavy GPU tenants never co-reside.

## The error

QuadRemesher is a commercial retopo engine ($110 perpetual). It runs headless from Blender's Python API. Its license is node-locked to an ethernet MAC address. The compose file pins `eth0` to a specific MAC so the license survives container recreation.

The first sign of trouble was not an error. S4 retopo reported a QuadWild fallback with a waiver note and no further explanation. Checking the engine's own user log:

```
_UserLog_Remesher.txt: progress = -2
```

And in `/proc/<pid>/status` on the engine process:

```
State: T (tracing stop)
```

QuadRemesher carries ptrace anti-debug (`PTRACE_TRACEME`). When the engine is launched from a Python or Blender parent process, Linux treats the parent as a potential debugger. The first signal to the traced child parks it permanently in tracing-stop. On a four-second retopo job, the timeout waited 30 minutes before killing it. The identical settings file ran clean from a shell.

The fix is in the launch code: `subprocess.Popen` with `start_new_session=True`, stdin redirected to `/dev/null`, and a poller that reads `/proc/<pid>/status` every few seconds. If `State: T` persists for more than 30 seconds, kill and retry once.

There is also a path contract. QuadRemesher validates that its FileIn, FileOut, and ProgressFile all live under `/tmp/Exoside/QuadRemesher/Blender/`. Any other path produces:

```
ERR 'HostApp com failed. (bdfps;bdfpi;bdfpo)'
```

The S4 driver keeps engine I/O in that directory and copies artifacts to the job folder afterward. Real diagnostics are in `_UserLog_Remesher.txt`, not stdout.

## The second license failure

After a storage migration moved `/data` to a mergerfs FUSE pool, QuadRemesher's node-lock activation was silently invalidated. The job downgraded to QuadWild without complaint. The only trace was a G4 gate waiver naming the fallback tool.

Reactivation requires an Xvfb session plus xdotool to click through the GUI. The runbook now lives in the repo, including the non-obvious package list:

```
x11-utils libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0
libxcb-render-util0 libxcb-shape0 libxcb-xinerama0 libxcb-xkb1
libxcb-cursor0 libxkbcommon-x11-0
```

Without those, `xrLicenseManager` SIGABRTs with zero output. Finding that took longer than it should have.

There is now an activation canary at stack-start: if the engine probe returns `progress = -2`, the job parks as `needs-review` instead of silently downgrading. A fallback that changes deliverable quality must be loud and gate-visible.

## The VLM judge that failed a good asset

The pipeline includes a visual quality gate (G17) backed by a vision model (nvidia/nemotron-3-nano-omni-30b, running via vLLM on the same card). I ran it against a delivered metallic crate. The verdict was `FAIL`, with the reasoning: "holes, tears, worn, dirty, faded panel lines" and `silhouette_clean = false`.

The deterministic L1 gate ran in the same pass. Results: `hole_px_fraction = 0.0`, `roughness_ratio = 0.926`, `best_iou = 0.8973`. All three pass. I extracted the delivered textures and checked manually: the asset was correct.

The VLM was judging the flood-white QA turntable renders. A metallic surface under flat white light renders as a muddy grey blob with no weave visible. The model described what it saw in the render, not what the asset actually was. The deterministic numbers were right. The VLM was wrong about a good asset.

G17's L2 (VLM) verdict now defers to L1 (deterministic pixel gates) on holes and silhouette. Single-shot judgment is replaced with three-vote consensus. A VLM running against a poorly calibrated render rig is not a quality gate; it is a noise source with a confidence score attached.

## What I'd tell you to check today

1. Any commercial tool launched from Python: check if it uses ptrace. Launch with `start_new_session=True`, redirect stdin to `/dev/null`, poll `/proc/<pid>/status` for `State: T`.
2. Read the license on every model in your production pipeline, including preprocessors and conditioners. The top-level license does not cover what the pipeline pulls in at runtime.
3. Before treating a VLM gate as authoritative, verify what it is actually judging. The render rig matters as much as the model.

The full stack, failures included, is at [github.com/MushiSenpai/mushishi-3d-stack](https://github.com/MushiSenpai/mushishi-3d-stack).
