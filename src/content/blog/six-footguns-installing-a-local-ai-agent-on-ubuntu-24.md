---
title: "Six footguns installing a local AI agent on Ubuntu 24"
description: "Hermes AI agent install on Ubuntu 24.04 via pip hits six traps: systemd PATH, silent aiohttp omission, nvm Node invisibility, dashboard flags, and a .env override that silently downgrades your API key."
date: 2026-09-18
project: sovereign-ai-stack
tags: ["hermes", "ubuntu", "systemd", "pip", "self-hosted"]
---

Phase 2.5 of my Hermes install. Two hours in, service still not running. Six separate issues, none of them in the docs, each costing real time.

These are in the order I hit them.

## Footgun 1: PEP 668 and the binary that isn't where systemd can see it

`pip install hermes` on Ubuntu 24 with `--break-system-packages` (required because Ubuntu 24 marks system Python as externally-managed) drops the `hermes` binary into `~/.local/bin`.

Your shell can find it. Systemd cannot.

```
ExecStart=/usr/local/bin/hermes start
```

That `ExecStart` fails at boot with no output. No `hermes` there. Fix: resolve the actual path at install time and hardcode it.

```bash
which hermes
# /home/mushi/.local/bin/hermes
```

```ini
ExecStart=/home/mushi/.local/bin/hermes start
```

Parameterize it in your install script so it never goes stale.

## Footgun 2: pip extras specs that don't actually pull their deps

```
pip install hermes[web]
```

That `[web]` extras spec is supposed to pull everything Hermes needs for web features. It does not pull `aiohttp`. You get a runtime `ImportError` when web components start, not an install-time error, so you only discover this after you've already written the service file.

Fix: install explicitly.

```bash
pip install "hermes[web]" aiohttp
```

Verify the imports are actually importable before wiring up the service.

## Footgun 3: the dashboard refuses 0.0.0.0 without a flag

Binding to `0.0.0.0` to access the dashboard over the LAN? You get a refusal with no useful error. The required flag:

```
hermes start --insecure
```

Not a confidence-inspiring name, but the intent is deliberate: it forces you to acknowledge you're exposing the service outside localhost. The flag is load-bearing, not optional.

## Footgun 4: nvm-managed Node is invisible to systemd

nvm installs Node under `~/.nvm/versions/node/<version>/bin`. That path does not appear in systemd's environment.

If any part of Hermes spawns a Node subprocess (the desktop dashboard does), the subprocess dies immediately when started as a service. The service reports healthy. The Node process is gone. Nothing in the logs explains why.

Fix: install Node via NodeSource apt for anything systemd manages.

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Keep nvm for interactive dev work. Use apt Node for system services.

## Footgun 5: HOST=0.0.0.0 silently requires HERMES_PASSWORD

When you set `HOST=0.0.0.0`, Workspace enforces password authentication. With no `HERMES_PASSWORD` set, it rejects all connections silently. The service runs, the port is open, and connections are dropped with no log entry explaining that a password is required.

Add to your `.env`:

```
HOST=0.0.0.0
HERMES_PASSWORD=<something strong>
```

## Footgun 6 (the worst): .env override=True replaces your generated API key

This one is a security bug disguised as a config behavior.

Hermes generates a strong random `API_SERVER_KEY` on first run. If you have a profile-level `.env` loaded with `override=True`, and that file contains any `API_SERVER_KEY` value (a leftover placeholder, a dev default, anything), it silently replaces the generated key with whatever is in the file.

Strong random key, gone. Weak guessable value, installed. No warning, no log line.

Fix: audit your `.env` precedence before running anything with `override=True`. That setting means the file wins over everything, including values the application generated specifically to be secure. Either remove `API_SERVER_KEY` from the profile-level file, or switch to `override=False`.

## The four lessons

These six issues aren't Hermes-specific. They're the same trap on any pip-installed Python service running under systemd on Ubuntu 24.

1. **Resolve binary paths at install time.** Don't write `/usr/local/bin/<tool>` in a service file until you've run `which <tool>` and confirmed that's where it actually lives.
2. **Extras specs are aspirational, not contractual.** After `pip install foo[bar]`, verify the extras-implied imports actually work.
3. **nvm and systemd are parallel universes.** Anything systemd manages needs apt-installed runtimes.
4. **Config precedence bugs are security bugs.** `override=True` means "my file wins over everything." Make sure you mean that before using it anywhere near generated credentials.

## What I'd tell you to check today

If you have a pip-installed service running under systemd on Ubuntu 24:
- Run `systemctl status <service>` and compare the `ExecStart` path against `which <binary>`.
- If the service depends on Node, run `which node` as the service user to confirm systemd can see it.
- If you're using a `.env` file with `override=True`, audit what it sets against what the application generates on first run.

The documentation for most of these tools assumes you're running things interactively in a user shell. Systemd is not that. It has its own PATH, its own environment, and zero patience for assumptions that only hold in your terminal.

---

*The full sovereign AI stack, with service files, configs, and every decision logged, is at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
