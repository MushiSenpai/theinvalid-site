---
title: "Refcount 4, no holders: how Docker containers block an NVIDIA driver upgrade"
description: "My driver upgrade script died every time with a non-zero GPU refcount and fuser reporting nothing — because systemctl isolate multi-user.target restarts Docker, and Docker container GPU opens are invisible to host-level fuser."
date: 2026-10-10
project: sovereign-ai-stack
tags: ["nvidia", "docker", "systemd", "linux", "ops"]
---

The GPU upgrade script died at the same step every time. `fuser` on the device path came back empty. The driver refcount said four. No processes holding the GPU, and yet the GPU was definitely held. The installer refused. The driver got installed by hand. The script stayed in my notes as "the upgrade path."

This happened across every driver version for months. The inconsistency crept in because each manual install happened at a different time, matched to whatever version I had available rather than the one pinned to my containers. That drift compounded quietly until a flash-attention kernel symbol mismatch showed up weeks later at exactly the wrong moment.

## What systemctl isolate actually does

The standard NVIDIA driver upgrade flow needs the GPU completely idle: no display server, no CUDA processes, nothing with an open file descriptor to `/dev/nvidia*`. The go-to method:

```bash
systemctl isolate multi-user.target
```

My mental model was: drop the graphical session, switch to text mode, GPU goes idle. Half right. `systemctl isolate` stops units that are *not required* by the target. It *starts* everything the target requires. `multi-user.target` requires Docker. Docker starts. Docker has containers with `restart: unless-stopped`. Twenty-seven containers came straight back, some with the NVIDIA device mounted inside their own mount namespaces.

## The error

After the isolate, `fuser /dev/nvidia0` reported:

```
fuser: no process found
```

But the NVIDIA kernel module was still loaded with a refcount of 4. The diagnosis from the driver state: "refcount 4, no holders." The installer read this as contradictory and refused to proceed. Which it should. Something held it.

## Why fuser came back empty

Container GPU opens happen inside the container's mount namespace. `fuser /dev/nvidia0` iterates `/proc/*/fd/` in the host mount namespace. The processes holding the device file are visible through their container's namespace, not the host's. Host-level `fuser` sees nothing. The kernel refcount disagrees, because it counts across all namespaces.

To actually find the holders you have to look inside the namespaces:

```bash
for pid in $(docker inspect --format='{{.State.Pid}}' $(docker ps -q 2>/dev/null)); do
  nsenter --mount=/proc/$pid/ns/mnt -- fuser /dev/nvidia0 2>/dev/null \
    && echo "GPU held in container with host PID $pid"
done
```

Or skip the investigation entirely and stop Docker before the upgrade:

```bash
systemctl stop docker
systemctl stop nvidia-persistenced
# now kill the display manager directly — do not use isolate for this
```

## The script-as-memory problem

Every run of the upgrade script had failed. I knew this in the sense that I had installed the driver by hand each time. But the script had no log of successful runs, and I had not checked for one. It was "the upgrade path" in my notes because I wrote it, not because it had ever worked.

That gap between "script exists" and "script runs" is how the driver versioning went inconsistent. No two manual installs matched the same CUDA toolkit or ran on the same day. A driver version mismatch that does not throw on container start is invisible until you hit a kernel symbol version boundary. At which point you spend an afternoon debugging something that looked unrelated.

## What I'd tell you to check today

1. Before any NVIDIA driver upgrade: `systemctl stop docker` explicitly. Do not rely on `systemctl isolate` to do this for you. Verify with `docker ps` that nothing is running before proceeding.

2. `fuser /dev/nvidia0` returning empty does not mean the GPU is free. If the driver module shows a non-zero refcount, check container namespaces with the `nsenter` loop above.

3. Read your upgrade script's last three log entries. If there are no successful runs recorded, the script is not proven. It is remembered, which is a different thing entirely.

4. Cross-check `nvidia-smi | grep Driver` against the CUDA version baked into your GPU containers (`docker run --rm --gpus all nvidia/cuda:12.x.x-base-ubuntu22.04 nvidia-smi`). A mismatch that does not fail at container start will fail later, somewhere worse.

---

*The upgrade runbook and its failure history live at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
