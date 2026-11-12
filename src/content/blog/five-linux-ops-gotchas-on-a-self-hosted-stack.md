---
title: "Five Linux ops gotchas on a self-hosted stack"
description: "smartd alias on Ubuntu (enable fails), GitHub GH007 email push rejection, llama.cpp unknown arch nemotron_h_moe, missing unzip on a fresh VPS, Chrome refusing localhost while curl worked."
date: 2026-11-12
project: sovereign-ai-stack
tags: ["linux", "ops", "self-hosting", "ubuntu", "llama-cpp"]
---

Building and maintaining a self-hosted Linux AI workstation generates a steady drizzle of one-hour-each gotchas. These five came up during the same period of standing up the stack. Each one looked like a bigger problem than it was. Each fix is a one-liner.

## Gotcha 1: `systemctl enable smartd` fails on Ubuntu

```
Failed to enable unit: Unit name smartd.service is an alias of smartmontools.service.
```

`smartd` is an alias defined by the `smartmontools` Ubuntu package. `systemctl enable` refuses to work with the alias name. The real unit is `smartmontools.service`.

```bash
sudo systemctl enable --now smartmontools.service
```

After boot, `systemctl status smartd` resolves the alias fine, so this only surfaces at first-time setup. If you are scripting an idempotent setup file, use the canonical name or the script fails on the enable step.

## Gotcha 2: Git push rejected because of a private email address

```
remote: error: GH007: Your push would publish a private email address.
remote: You can make your email public or disable this protection by visiting:
remote: https://github.com/settings/emails
```

GitHub's email privacy setting blocks any push where the commit author's email is a real address not in the account's verified list. GitHub generates a noreply identity for every account, listed under Settings > Emails.

```bash
git config user.email "<id>+username@users.noreply.github.com"
```

The practical trap: if you make commits with your real email before setting the noreply identity, you will need to amend the history and force-push to fix it. Set the noreply identity before the first commit on any new repo.

## Gotcha 3: llama.cpp does not recognize `nemotron_h_moe`

```
error loading model: unknown model architecture 'nemotron_h_moe'
```

The `nemotron_h_moe` architecture support landed in llama.cpp around build 9283. A binary built from an earlier commit does not recognize the architecture and refuses to load the model, regardless of how it was quantized.

```bash
git pull
cmake -B build && cmake --build build --config Release
```

The subtle part: the binary still runs fine for every other model you have. There is no visible signal that it is out of date until you try a model that needs the new architecture. After every llama.cpp pull, rebuild.

## Gotcha 4: deploy script fails because unzip is not installed

```
./deploy.sh: line 42: unzip: command not found
```

A minimal Debian or Ubuntu image does not ship with `unzip`. The script worked locally (where `unzip` was installed months ago and forgotten) and failed on a fresh VPS on the first deploy.

```bash
apt-get install -y unzip curl git
```

The broader lesson: deploy scripts should self-install their own tools. If the script calls a binary, the script installs that binary. Relying on the host to have your tools already installed is relying on a convention nobody is enforcing.

## Gotcha 5: Chrome refused a port that curl could reach

The ComfyUI web interface was not loading in Chrome. The connection failed immediately. `curl http://localhost:8188/` returned a 200 and the HTML. The server log showed no connection attempt from Chrome at all.

The cause: a Chrome extension was blocking the port. Firefox loaded the page immediately.

The lesson: when one client fails to connect to something another client can reach, eliminate the client before diagnosing the server. I spent twenty minutes looking at iptables rules, Docker network config, and the ComfyUI startup log before trying `curl`. That was the wrong order. Try a second client first.

## What I'd tell you to check today

1. If you are scripting `smartmontools` setup: use `smartmontools.service`, not `smartd`.
2. If you are setting up a new GitHub repo: set the noreply identity before the first commit.
3. After any `llama.cpp` pull: rebuild, even if other models are loading fine.
4. In any deploy script: add an explicit install for every binary the script calls.
5. When a browser fails to connect to localhost: try `curl` before reading the server logs.

---

*The full workstation setup, failures and decisions included, is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
