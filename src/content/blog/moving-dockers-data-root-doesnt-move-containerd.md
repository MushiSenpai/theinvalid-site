---
title: "Moving Docker's data root doesn't move containerd"
description: "I moved Docker to the big disk and /var kept filling up anyway — because Docker and containerd are two different daemons with two different stores."
date: 2026-06-24
project: sovereign-ai-stack
tags: ["docker", "containerd", "ops", "linux", "self-hosted"]
---

The alert came in: `/var` at 99%. I stared at it for a few seconds because I had already fixed this. Weeks earlier, I'd moved Docker's data root off the OS partition to `/data`, watched the space reclaim, felt good about it. And now the disk was full again.

## The error

Watchdog log, day one of the new monitoring system:

```
ALERT: /var at 99% (169GB used)
```

I ran the obvious check:

```bash
df -h /var
# Filesystem  Size  Used Avail Use%  Mounted on
# /dev/sda2    200G  197G  600M  100% /var
du -sh /var/lib/*
```

The winner:

```
169G    /var/lib/containerd
1.2G    /var/lib/docker
```

That second line was the tell. `/var/lib/docker` was nearly empty — because I had moved it to `/data`. `/var/lib/containerd`, on the other hand, was still sitting on the OS partition, untouched.

## What I thought I did

The Docker documentation says you can move Docker's data root by editing `/etc/docker/daemon.json`:

```json
{
  "data-root": "/data/ai/docker-data"
}
```

I did that, restarted Docker, confirmed `/var/lib/docker` was basically empty, and called it done. The OS partition was healthy. I moved on.

What I didn't know: that was only half the story.

## What actually happened

Modern Docker has two image storage systems running side by side. Docker's own daemon handles some things — but image builds go through a different path. Since Docker 23+, the default image store is managed by **containerd**, which is a separate daemon with its own configuration and its own root directory.

`data-root` in `daemon.json` controls where `/var/lib/docker` points. It does not touch `/etc/containerd/config.toml`, and it does not move `/var/lib/containerd`.

So every image I built after "moving Docker to the big disk" still landed in `/var/lib/containerd` on the OS partition. Weeks of builds, all in the wrong place. 169GB of it.

## How the watchdog caught it

This is the day-one win from the monitoring setup I described in [the backup post](/blog/my-backup-failed-silently-for-17-days). The watchdog's very first full pass flagged the disk. It checked outcomes — actual partition usage — not Docker's opinion of itself.

If I had only monitored Docker's health endpoint, it would have reported clean: Docker can see all its images, all containers are running, nothing is wrong from Docker's perspective. The disk was the thing that was wrong, and only a partition check would catch it.

## The fix

Two changes. First, update containerd's config to point its root at the big disk:

```bash
# /etc/containerd/config.toml
root = "/data/ai/containerd-data"
```

Second, migrate the existing store before restarting:

```bash
systemctl stop docker docker.socket containerd
rsync -aHAX /var/lib/containerd/ /data/ai/containerd-data/
systemctl start containerd docker
```

The rsync on NVMe took about four minutes for 145GB. Containers were down for that window. After restart, I verified image count looked right before doing anything else — if the count had been wrong, the rollback is just restoring the old `config.toml` backup and restarting.

I left the old `/var/lib/containerd` in place for a day of normal use, then deleted it once I was confident nothing was pointing at it.

The full migration script (`move-containerd-root.sh`, v1.8) handles all of this, including the verification step and a rollback note if the image count looks wrong. It's in the repo.

## The lesson

Docker data-root and containerd root are independent settings for independent daemons. Moving one does not move the other. If you're on Docker 23+ and you moved data-root expecting `/var/lib/containerd` to follow, it didn't.

The full picture is three configs, three locations:

| What | Config | Default path |
|---|---|---|
| Docker layers, volumes, networks | `/etc/docker/daemon.json` → `data-root` | `/var/lib/docker` |
| Containerd image store | `/etc/containerd/config.toml` → `root` | `/var/lib/containerd` |
| Containerd state | `/etc/containerd/config.toml` → `state` | `/run/containerd` |

State is runtime-only and small. The one that fills your disk is `root`.

## What I'd tell you to check today

```bash
du -sh /var/lib/docker /var/lib/containerd
```

If containerd is the bigger number and you thought you moved Docker's storage, you moved the wrong store. Check `/etc/containerd/config.toml` for a `root =` line — if it's missing, containerd is using its compiled-in default, which is `/var/lib/containerd` regardless of what `daemon.json` says.

---

*Scripts, config, and the full incident log are in the repo: [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
