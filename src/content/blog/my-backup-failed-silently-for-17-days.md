---
title: "My backup failed silently for 17 days"
description: "A cron PATH bug, the morning I found it, and why I now monitor outcomes instead of trusting automation."
date: 2026-06-10
project: sovereign-ai-stack
tags: ["ops", "backups", "failure", "monitoring"]
---

Every Sunday at 3am, cron ran my backup script. Every Sunday at 3am, it failed. For two and a half weeks, nobody knew — least of all me.

## The setup

My whole AI stack lives on one Linux workstation: model weights, hand-tuned configs, voice profiles, client pipeline outputs, weeks of specs. The backup plan was textbook — [restic](https://restic.net/), encrypted, incremental, scheduled by cron, with a monthly integrity check. I'd tested the script by hand. It worked. I moved on.

That last sentence is where the failure lives.

## The bug

When an AI-stack review made me actually *look* at the backup log, it read like this:

```
/data/ai/01-workspace/scripts/backup.sh: line 20: restic: command not found
Backup starting...
/data/ai/01-workspace/scripts/backup.sh: line 20: restic: command not found
Backup starting...
```

`restic` was installed in `~/.local/bin` — which is on *my* shell's PATH, because my login profile puts it there. Cron doesn't run my login profile. Cron's PATH is a stub: `/usr/bin:/bin`. So the same script that worked every time I ran it by hand failed every time the machine ran it alone.

The repository's last snapshot was 17 days old. If the data drive had died that morning, the "backed up" system would have lost two and a half weeks of work — including things I could never regenerate.

## The boring fix and the real fix

The boring fix took one minute: hardcode the absolute path.

```bash
RESTIC="/home/mushi/.local/bin/restic"
```

The real fix is the lesson: **the script never failed loudly because nothing was listening.** Cron dutifully appended the error to a log file nobody read. The exit code went nowhere. Automation without monitoring isn't automation — it's a feeling.

So now a systemd timer runs a watchdog every day that checks *outcomes*, not intentions:

- Is the newest restic snapshot **less than 8 days old**? (Both repos — local *and* the offsite one in Falkenstein.)
- Are the always-on services actually up?
- Are the disks under 90%?
- Do the last lines of the backup log contain error strings?

If anything fails, it pushes a notification to my phone via [ntfy](https://ntfy.sh). If everything passes, it stays silent — except a Monday heartbeat, because a watchdog that fails silently would be a joke I refuse to be the punchline of twice.

## It paid for itself in one day

On its very first full pass, the watchdog flagged a disk at 99% — `/var/lib/containerd` had quietly eaten 169GB, because moving Docker's data-root doesn't move containerd's image store. That's a different post, but the point stands: the watchdog caught in hours what the backup bug got away with for weeks.

## What I'd tell you to check today

1. **Read your backup log right now.** Not the schedule — the log. The last three entries.
2. Any script cron runs must use **absolute paths to binaries**. Your PATH is not cron's PATH.
3. Monitor the **outcome** (snapshot age), not the exit code. Exit codes vanish; stale snapshots accumulate.
4. Give your monitoring a **heartbeat**, so silence means "all good" instead of "also broken."

The infrastructure that survives isn't the cleverest — it's the kind that tells you when it's sick.

---

*This system is documented end-to-end, failures included, at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
