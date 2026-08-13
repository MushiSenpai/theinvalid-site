---
title: "Driving a Linux AI workstation from the couch"
description: "How I built a tailnet-only web command panel for 25 services on an RTX 5090 rig, and why typing localhost:PORT from a remote browser connects to the wrong machine."
date: 2026-08-14
project: sovereign-ai-stack
tags: ["tailscale", "selfhosted", "homelab", "linux", "python"]
---

The Linux workstation runs everything. The couch does not have a Linux workstation on it. For a long time this meant that switching GPU modes, checking VRAM, restarting a stuck container, or opening a web UI required either walking across the room or SSHing in from the MacBook and typing commands by hand.

I wanted to click a button.

## The setup

Two machines, one Tailscale tailnet. The Linux box (mushishi, RTX 5090 32GB) runs the full stack: vLLM serving LLMs, ComfyUI for image and video generation, an audio/lipsync pipeline, a Tetris arena with a leaderboard, monitoring. The MacBook Pro (late-2013 Intel, 16GB RAM, Sonoma via OCLP) is where I sit.

The problem with "just open a browser tab" is that it assumes the services are reachable from the Mac. Most of them are not.

## The problem: localhost on the Mac is the Mac

The naive approach is to bookmark service URLs: `http://localhost:8188` for ComfyUI, `http://localhost:3080` for Open WebUI, and so on.

From the Mac, these connect to the Mac's own loopback interface. The Linux box is not involved.

Most services bind to `127.0.0.1` deliberately, because binding to a real network interface would expose them. That is the right call. But it means the Mac cannot reach them over the tailnet, because they are not on the tailnet at all.

Mapping 25 services across the stack, I found four reachability classes:

- **T (tailnet-bound):** already listens on the tailnet IP (`100.106.82.51`). LiteLLM `:4000`, Hermes Dashboard `:9119`, Paperclip Workshop `:3100`. The Mac can open these directly.
- **L (localhost-only):** ComfyUI `:8188`, Open WebUI `:3080`, rq-dashboard `:9010`, and about a dozen more. Not reachable from the Mac without a proxy.
- **N (no web UI):** vLLM `:8000`, Fish Speech `:9002`, Redis `:6379`. Workers with no dashboard. Status and control only.
- **P (public via VPS):** PocketBase Arena, fronted by Caddy on the VPS edge. Reachable from anywhere.

The L class is the hard problem. The tempting solution is to rebind each service to the tailnet interface. That means editing compose files for twelve services, widening the network surface one service at a time, and creating twelve new firewall rules. Minimum blast radius is not a round number when you do this twelve times.

## The fix

SETU (Mushishi Bridge) is a Python FastAPI daemon on the Linux box, bound to the tailnet interface only: `100.106.82.51:8765`. Never `0.0.0.0`. It serves a browser dashboard and a REST API, with bearer token authentication on every `/api/*` call. Tailnet membership is the primary trust boundary; the token is defense-in-depth.

For Class-L services, the answer is `tailscale serve`:

```bash
tailscale serve --bg --https=443 --set-path /open-webui http://127.0.0.1:3080
```

The Mac opens `https://mushishi.<tailnet>.ts.net/open-webui`. The service never left `127.0.0.1`; the Tailscale daemon proxied it. No new firewall rules, no edited compose files.

The one exception is ComfyUI, which is known to be unhappy under a sub-path. It gets its own dedicated serve path rather than sharing the path namespace. Every other Class-L service either works cleanly under a sub-path or gets its own.

The daemon itself (bridge.py) handles telemetry (GPU stats from probe.sh, CPU/RAM/disk from `/proc`), the service registry with live status, GPU mode switching, and service start/stop/restart. The frontend is vanilla HTML/CSS/JS, system fonts, no framework, no bundler. Target payload under 200 KB. The late-2013 Mac runs Orion browser; it does not need a React app.

## The non-obvious problem: scripts that need a TTY

GPU mode switching was more complicated than reachability. The existing mode scripts (`coding-mode.sh`, `creative-mode.sh`, and the rest) prompt before stopping running GPU tenants:

```
Coding LLM stack (vLLM+Qwen3-Coder) is active.
Stop them now? [y/N]
```

The daemon has no TTY. Piping `y` unconditionally would skip the browser confirmation modal, which is the whole point of the guard.

The fix is a `confirm_or_assume` helper added to `gpu-tenants.sh`, the single source of truth for GPU tenant logic. When `MUSHISHI_ASSUME_YES=1`, it auto-confirms and announces it on stderr. The daemon re-probes GPU activity freshness at the start of every mode switch request. If anything is actively serving, the browser gets a confirmation modal before proceeding. If the user confirms there, the daemon sets `MUSHISHI_ASSUME_YES=1` and calls the mode script. The guard is not bypassed; it is just answered after the human already said yes in the UI.

This also means the mode scripts are now headless-safe for any non-interactive caller (cron, a future API client, a shell script), not just the bridge.

## The design rule that kept it small

One constraint held the scope in check: it is a command panel, not a dashboard. Monitoring lives elsewhere (Netdata, KARIBUSA). The bridge shows status, offers control, and opens web UIs in new browser tabs. Every action it exposes is backed by a shell script that also works without the panel. If the bridge daemon is down, the estate still runs; it just requires SSH.

This constraint kept the milestones manageable: M0 was read-only status and telemetry. M1 added GPU mode switching. M2 added service control. M3 added log drawers and a healthcheck panel. The whole thing runs as a `systemd --user` service and is PWA-installable in Orion, so it lives in the Dock like a native app.

Current status: M0 through M3 done, deployed over Tailscale HTTPS, daily driver.

## What I'd tell you to check today

1. Before building any remote control panel, run `ss -tlnp` on the target machine and list every service's actual bind address. Not the documentation: the live socket. That list determines your whole architecture.
2. `tailscale serve` is the near-zero-code answer for localhost-only services. Use it before reaching for a custom reverse proxy, a Caddy instance, or edited compose files.
3. Any script your daemon calls that was written for interactive use almost certainly has a `[y/N]` prompt somewhere. Find it in the code before your daemon finds it at runtime.
4. Bind your control plane to the tailnet interface, not `0.0.0.0`. The blast radius of a misconfigured auth check drops to zero if the service is reachable only inside your tailnet.

---

*The bridge spec, service registry (25 services across LLM, Creative, Audio, Platforms, and Observability groups), and mode-switch guard logic are at [github.com/MushiSenpai/mushishi-bridge](https://github.com/MushiSenpai/mushishi-bridge).*
