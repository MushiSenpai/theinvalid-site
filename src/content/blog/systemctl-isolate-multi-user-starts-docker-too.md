---
title: "systemctl isolate multi-user.target starts Docker, not just stops things"
description: "If you use systemctl isolate to clear the GPU before NVIDIA maintenance, Docker starts up automatically and your GPU containers come back. The fix is one explicit command, but the mental model is what needs replacing."
date: 2026-10-21
project: sovereign-ai-stack
tags: ["nvidia", "docker", "systemd", "linux", "ops"]
---

The GPU maintenance step that's supposed to free the GPU is the step that keeps it busy. That's the whole trap, and it took several identical failures before I understood why.

## The mental model most people carry

`systemctl isolate multi-user.target` feels like "switch to text mode, stop things I don't need." That is approximately what `init 3` used to mean on SysV systems, and the muscle memory carries over.

The actual behavior is different. `systemctl isolate <target>` brings the system to a state where exactly the named target's requirements are satisfied. It stops units NOT required by that target. It also STARTS everything the target requires, if those units aren't already running.

`docker.service` has `WantedBy=multi-user.target` in its unit file. That means Docker is started when you isolate to `multi-user.target`. Docker has containers with `restart: unless-stopped`. They restart. Those containers have GPU access configured. The GPU is held.

## The symptoms

If you're lucky, the NVIDIA driver installer refuses with something like:

```
ERROR: An NVIDIA kernel module 'nvidia' appears to already be loaded in your kernel.
```

Or the module query shows a non-zero refcount with nothing visibly holding it:

```bash
$ cat /proc/driver/nvidia/params | grep -i ref
# or check with:
$ nvidia-smi | grep "Processes"
# or the classic:
$ fuser /dev/nvidia0
# returns nothing, but:
$ lsmod | grep nvidia
nvidia               ... used by 4
```

`fuser /dev/nvidia0` returning nothing while the kernel module reports `used by 4` is the classic symptom. The holders are inside container mount namespaces; `fuser` on the host only sees the host namespace.

If you're unlucky, the installer proceeds anyway (with some flag combinations), installs incompatibly, and the mismatch surfaces later as a flash-attention kernel symbol error or a CUDA version fault mid-run.

## What actually happens on isolate

To see it live, check what `multi-user.target` requires before you run anything:

```bash
systemctl list-dependencies multi-user.target --no-pager
```

Docker will be in that list. On a typical Ubuntu or Debian system with Docker installed from the official repo, `docker.service` is `WantedBy=multi-user.target` by default. Isolating to that target starts it.

If you have containers running with GPU access and `restart: unless-stopped`, this sequence happens:

1. You run `systemctl isolate multi-user.target`
2. systemd stops the display manager (good)
3. systemd starts Docker, because multi-user requires it
4. Docker's daemon starts the containers per their restart policy
5. Containers with `--gpus all` or a `devices:` stanza reopen `/dev/nvidia*`
6. The GPU is held again inside container namespaces invisible to host `fuser`

## The fix

Stop Docker explicitly before doing any GPU work:

```bash
systemctl stop docker
systemctl stop docker.socket     # stops the socket activation too
systemctl stop nvidia-persistenced
# now stop the display manager directly:
systemctl stop gdm   # or lightdm, sddm, whatever you run
```

Then verify nothing holds the GPU before proceeding:

```bash
for pid in $(docker inspect --format='{{.State.Pid}}' $(docker ps -q 2>/dev/null) 2>/dev/null); do
  nsenter --mount=/proc/$pid/ns/mnt -- fuser /dev/nvidia0 2>/dev/null \
    && echo "GPU held in container with host PID $pid"
done
lsmod | grep nvidia    # refcount should be 0 after stopping everything
```

Only then run the installer or the driver upgrade command.

## The isolate-as-maintenance-mode problem

`systemctl isolate` is useful, but it is not a GPU-clearance primitive. If your maintenance use case requires the GPU to be free, you have to enumerate what the target STARTS and explicitly stop anything GPU-adjacent before you isolate, or just skip the isolate entirely and stop individual units.

The deeper issue is that I had been using `systemctl isolate` for a year as a mental shortcut for "prep for maintenance." The script that used it had never logged a single successful run. I had installed the driver by hand every time and forgotten about it, treating the script as proven because I had written it. "Exists" and "works" are different things.

## What I'd tell you to check today

1. Run `systemctl list-dependencies multi-user.target` and look for `docker.service`. If it's there, isolating to that target starts Docker.

2. Check your Docker container restart policies. Anything with `restart: unless-stopped` or `restart: always` will come back when the daemon starts. `docker ps --format "table {{.Names}}\t{{.Status}}\t{{.RestartCount}}"` shows what's configured.

3. Before any NVIDIA driver operation: `systemctl stop docker && systemctl stop docker.socket`. Then run `nvidia-smi` and `lsmod | grep nvidia` to confirm the GPU is truly free.

4. If your upgrade or maintenance script has no record of successful runs, it has not been proven. Read the log before trusting the script.

---

*The runbook for GPU maintenance on this stack, including the updated upgrade script with proper pre-flight checks, is at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
