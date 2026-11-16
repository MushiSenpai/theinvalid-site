---
title: "SETU, Mode and TRINETRA: one GPU, three remotes"
oneliner: "The control surfaces for a card that seven stacks share: a desktop mode switch that will not evict a busy model, a tailnet-only web panel, and a native cockpit app for a foldable phone."
status: shipped
private: true
writeup: "/blog/a-gtk-switch-for-one-gpu-shared-by-seven-ai-stacks"
stack: ["GTK4 / libadwaita", "FastAPI + SSE", "Kotlin / Jetpack Compose", "Tailscale", "bash mode scripts"]
started: 2026-06-14
order: 10
---

All three are front-ends only. The stop and start logic lives in one set of mode scripts, and one file declares which containers are allowed to be stopped. Nothing else is touched.

**Mushishi Mode** is a native GTK4 switcher. It shows VRAM state and tells a loaded-but-idle model (safe to evict) from one mid-request (not safe). [Write-up](/blog/a-gtk-switch-for-one-gpu-shared-by-seven-ai-stacks).

**SETU** (the bridge) is a web command panel for 25 services, reachable only over the tailnet: GPU modes, service health, logs, live telemetry. [Write-up](/blog/driving-a-linux-ai-workstation-from-the-couch).

**TRINETRA** is the phone client, a native Android app that adapts between a foldable's cover and unfolded screens and keeps its live stream across a fold. Built and unit-tested; not yet verified on the device, and it says so.

The lesson that keeps repeating: a second front-end that mirrors a list drifts from it. The mode table went stale twice, once while a workload was live and the panel reported the mode as unknown. The fix is a test that asserts the mirror matches what is on disk, and a guard you have not seen fail is not a guard.

These describe my own infrastructure, so the repos stay private.
