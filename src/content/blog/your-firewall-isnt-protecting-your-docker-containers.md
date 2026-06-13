---
title: "Your firewall isn't protecting your Docker containers"
description: "Docker rewrites iptables rules ahead of UFW — every published port is LAN-accessible regardless of your firewall rules. The DOCKER-USER chain fix."
date: 2026-06-13
project: sovereign-ai-stack
tags: ["docker", "ufw", "iptables", "security", "selfhosted"]
---

I found out my entire AI stack was wide open when I picked up my phone.

Not a hacker. Not a port scan. My own phone, on my home Wi-Fi, no VPN, no Tailscale. I opened a browser, typed my workstation's LAN IP and port 8188, and ComfyUI loaded instantly. No auth prompt. No timeout. Full web UI.

I had UFW enabled. Tailscale-only allow rules. Verified them myself. All of that was irrelevant.

## Why Docker ignores your firewall

Docker manages iptables directly, and it does it before UFW gets a chance to speak. When you start a container with a published port — `-p 8188:8188` in a run command, or `ports: - "8188:8188"` in compose — Docker inserts NAT and FORWARD rules into iptables that come *ahead* of the UFW chain. UFW never sees the traffic. It never gets to vote.

This isn't a bug. It's documented Docker behavior, intentional since at least Docker 1.x, and it applies regardless of which Linux firewall frontend you're using. Most people setting up a self-hosted stack will never read the relevant section of the networking docs because everything *looks* fine — UFW shows `active`, the rules look right — until you test from a device that has no special access.

## The symptoms

After verifying this on 2026-06-10, the full exposure on my machine was:

```
ComfyUI         :8188  — no auth, full web UI
LiteLLM proxy   :4000  — OpenAI-compatible inference API
DeerFlow        :2026  — agent UI, no auth
Phoenix OTEL    :6006 / :4318
audio gateway   :9000  — RQ job queue
rq-dashboard    :9010  — worker management UI
vLLM            :8000  — model inference API
```

Every service, visible to any device on the local network. A guest on the Wi-Fi could have queued jobs, called models, or watched traces.

## The fix

The correct fix is the `DOCKER-USER` chain. It's an iptables hook that runs *before* Docker's own accept rules for all forwarded (container-bound) traffic. Put a DROP there and Docker's later rules never fire.

This goes into `/etc/ufw/after.rules`:

```
*filter
:DOCKER-USER - [0:0]
# Tailnet devices may reach containers
-A DOCKER-USER -i tailscale0 -j RETURN
# Replies to connections containers initiated (apt, pip, model downloads)
-A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
# Container-to-container traffic on docker bridges
-A DOCKER-USER -i docker0 -j RETURN
-A DOCKER-USER -i br-+ -j RETURN
# Everything else: drop
-A DOCKER-USER -j DROP
COMMIT
```

Then: `sudo ufw reload`

The `ESTABLISHED,RELATED` line is not optional. Containers need outbound internet access to pull models, install packages, reach cloud APIs. Without it, `apt`, `pip`, and everything else breaks inside the container. The docker bridge lines preserve container-to-container networking.

What this does *not* affect: services published directly on the host (not through Docker) are governed by normal UFW rules as usual. In my case that's llama.cpp on :8001 and the Hermes dashboard on :8642 — already tailscale-only, not touched by DOCKER-USER.

Flush any existing stale rules first (`sudo iptables -F DOCKER-USER 2>/dev/null || true`) before reloading, otherwise stale accepts from a previous Docker startup can persist.

## Why you have to verify from an untrusted device

Testing from your own machine tells you nothing. Your machine might be on Tailscale, or it might be hitting `localhost`, which bypasses the FORWARD chain entirely. The only test that matters is the one I ran by accident:

1. A device with no Tailscale, no special allow, just LAN Wi-Fi — try `http://<workstation-ip>:8188`. Should time out.
2. Your Mac over Tailscale — same address should work.
3. From inside a container — `docker exec <container> curl https://api.groq.com` should succeed.

If (1) times out and (2)+(3) work, you're done. All three. In that order.

`ufw status verbose` showing `active` is not the test. An untrusted device is the test.

## What I'd tell you to check today

Pull up a phone or tablet that is not on your Tailscale network. Type `http://<your-server-ip>:<any-published-port>` into the browser. If anything loads, you have the same problem I had.

The hardening script that applies the DOCKER-USER block, backs up `after.rules` first, adds the tailscale UFW allows, and prints the three verification commands is at the link below.

---

*Sovereign AI Stack — infrastructure, decisions, and failures documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
