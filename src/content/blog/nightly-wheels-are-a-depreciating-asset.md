---
title: "Nightly wheels are a depreciating asset"
description: "Rebuilding a one-month-old audio-stack Dockerfile failed with xformers ResolutionImpossible on cu130, because the nightly index it pinned had moved on. Pin proven stable, never pip-install at runtime."
date: 2026-06-20
project: audio-stack
tags: ["docker", "pip", "torch", "xformers", "rtx-5090"]
---

I rebuilt a one-month-old Dockerfile for my audio stack in June, the same week I rebuilt the workstation around it. The build that had worked perfectly in May now refused to resolve, twice, for two different reasons that turned out to be the same reason. The running container, the one I was actually serving from, had been quietly running a completely different set of versions than the file I thought built it.

That gap is what this post is about.

## The error

The May install for an RTX 5090 (Blackwell, SM_120) needed bleeding-edge wheels — torch and xformers from the nightly index, because stable releases didn't yet have kernels for the architecture. The Dockerfile carried instructions that looked roughly like "install xformers from the cu130 nightly index."

In June, that instruction produced:

```
ERROR: ResolutionImpossible
```

The reason: **xformers stopped publishing cu130 nightlies in December 2025**. The index page the Dockerfile pointed at still existed; it just no longer had a wheel that matched. Pip wasn't lying. There was nothing to install.

The textbook workaround for this — put torch and xformers in one pip invocation so the resolver can pick a coherent pair — also failed. The newest torch nightly and the newest xformers nightly had drifted nearly six months apart, and pip couldn't bridge that gap. Same `ResolutionImpossible`, longer to give up.

## The fix

I went and looked at what the *running* container was actually using — the one quietly serving audio jobs the whole time I'd been "unable to rebuild." `docker exec` into it, `pip freeze`, and the answer was immediately obvious: it wasn't on nightlies at all. It had ended up on stable torch 2.8.0, which by June fully supported Blackwell. The reason I'd needed nightlies in May had stopped being true, and I hadn't noticed because nothing had failed.

The fix was to throw out the nightly instructions and pin the stable set the working container was already on:

```
torch==2.8.0
torchvision==0.23.0
torchaudio==2.8.0
xformers
```

A fresh container built from that pin runs the end-to-end YuE music job with zero manual post-install commands. I keep a `pip freeze` from the working container saved next to the Dockerfile as the ground truth — if the two ever disagree, the freeze wins, not the file.

## The corollary: `docker exec pip install` rots

The other half of the lesson is uglier. The reason the running container had drifted to stable torch was that I'd been doing the thing everyone does: when a model needed an extra package, `docker exec <container> pip install <thing>`, ship it, move on. Those installs live in the container's writable layer. They are gone the moment the container is recreated — `docker compose down && up`, a host reboot under restart=always, an image rebuild, any of it.

Container recreation silently dropped:

- `sentencepiece` and `pydub` — broke YuE music generation with a `ModuleNotFoundError` only at job time, not at startup.
- `xformers` — broke the Hallo2 tier the same way, weeks after I'd "installed" it.

No log line said "you lost these." The container came up green. The next job to need them died.

## What I'd tell you to check today

1. **Stop installing into running containers.** If a runtime `pip install` ever fixes a problem, the next step is moving that line into the Dockerfile and rebuilding. The fix isn't done until the image carries it.

2. **`pip freeze` your working container.** Save the output next to the Dockerfile. When the build stops resolving, this file tells you what the real working set looked like — much faster than re-deriving it from changelogs.

3. **Don't pin to nightly indexes for anything you want to rebuild later.** Nightly URLs are receipts, not addresses. They expire. Pin a specific stable version the moment one exists for your hardware, and re-pin again whenever you re-verify.

4. **Re-verify the reason you reached for the bleeding edge.** The whole reason I was on nightly torch was Blackwell support. By the time I rebuilt, that support had landed in stable. Most "we need the nightly" justifications have a shelf life shorter than your Dockerfile.

A container that hasn't been rebuilt from scratch in a month isn't reproducible; it's a snapshot you're hoping doesn't die. The day it does — host reboot, disk move, a stray `docker system prune` — you find out which packages were really in the image and which were just memories.

---

*The audio stack, the full LESSONS.md, and the pinned Dockerfile live at [github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack).*
