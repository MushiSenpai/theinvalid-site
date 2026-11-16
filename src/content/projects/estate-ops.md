---
title: "Estate ops: one ledger, one switch, one remote"
oneliner: "The tooling that keeps 22 tracks and seven GPU tenants honest: a single status ledger with drift detection, a mode switch that will not evict a busy model, and a tailnet-only command panel."
status: shipped
private: true
writeup: "/blog/one-yaml-file-to-rule-my-estate"
stack: ["Python stdlib", "systemd", "GTK4 / libadwaita", "FastAPI + SSE", "Tailscale"]
started: 2026-06-14
order: 9
---

Three small tools, each written up with the failure that shaped it.

**The ledger.** One YAML file is the canonical status of every project; per-project status files are mirrors, and a local dashboard renders all layers and flags where they disagree. It also taught the fail-open lesson: a stray quote once made the dashboard fall back to sample data and serve convincing lies. [Write-up](/blog/one-yaml-file-to-rule-my-estate).

**The switch.** Seven AI stacks share one 32GB card, never concurrently. A native GTK4 switcher shows VRAM state and tells a loaded-but-idle model (safe to evict) from one mid-request (not safe). It is a front-end only: the same mode scripts run from cron and a terminal. [Write-up](/blog/a-gtk-switch-for-one-gpu-shared-by-seven-ai-stacks).

**The remote.** A web command panel for 25 services, reachable only over the tailnet: GPU modes, service health, logs, live telemetry. [Write-up](/blog/driving-a-linux-ai-workstation-from-the-couch).

These repos describe my own infrastructure, so they stay private. The write-ups are the public part.
