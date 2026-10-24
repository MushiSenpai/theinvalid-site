---
title: "My vault rule guarded sessions, not tools"
description: "I added a rule: no authoring inside the Obsidian vault. Then my own sync script broke it automatically for weeks. Prose rules bind humans; config paths need code."
date: 2026-10-24
project: sovereign-ai-stack
tags: ["ops", "obsidian", "automation", "failure", "karibusa"]
---

In August I added a rule to my estate: no authoring of real files inside the Obsidian vault. The vault is a read-only mirror. Symlinks in, nothing written out. Simple enough.

Two months later I ran `find ~/Documents/Mushi's\ Vault -type f` and got five real files back. None of them should have existed.

## What the rule actually said

The 08-30 rule came out of a file-divergence incident. Two sessions had been appending to separate copies of the same file because one lived in the vault as a real file instead of a symlink. The fix was structural: the vault runs `obsidian-sync.sh`, which does `mkdir -p` for every folder and symlinks every `.md` file. No writes, no orphaned copies.

The prose rule reinforced that: sessions must not create or edit files inside `~/Documents/Mushi's Vault`. And sessions didn't. I checked. Every session since August played by the rule.

The problem was everything that wasn't a session.

## The config key that nobody audited

KARIBUSA -- my estate-status system -- carries a ledger file with a `homes.docs` key. The purpose is to tell `sync_status_md.py` where to drop its generated `STATUS.md` after it runs. Since version 1.0, filed July 9, that key had read:

```
homes.docs: "~/Documents/Mushi's Vault/Projects/data-ai/08-portfolio/theinvalid-site"
```

The vault houses a symlink mirror of the site repo. KARIBUSA's ledger treated the mirror path as the docs home. So every run of `sync_status_md.py --root ~/Documents` wrote a real `STATUS.md` into the vault at that path.

No session broke the rule. The tool did it for them, on a schedule, every time the estate status refreshed.

## Why the sync script never warned

`obsidian-sync.sh` has a check for anomalous real files. It looks for real files at paths where it knows a source file exists. If `queue.md` shows up as a real file where the script planted a symlink, that's a conflict worth surfacing.

But `STATUS.md` is generated, not sourced. There is no source counterpart for it in the repo. The script never planted a symlink at that path. So when the real file appeared there, the script had no reference to compare it against, and it stayed silent.

`find <vault> -type f` found five real files total. The sync script's per-path logic hadn't seen a single one of them.

## The fix

Two layers. First, `validate.py` now rejects any ledger entry with a `homes.*` path that falls inside the vault tree. It fails loudly on startup so a misconfigured config can't run at all:

```
ValidationError: homes.docs resolves to a vault path — writes are not permitted here
```

Second, `sync_status_md.py` adds its own guard: before writing any output file, it checks whether the destination is under the vault root and refuses if so:

```
REFUSED: output path is inside vault — aborting write
```

Proven with a negative copy: FAIL on validation, REFUSED on write attempt, vault mtime unchanged.

## The real lesson

A prose rule binds people. A path in a config file writes files just like a session does, and the config doesn't read the rules document.

This comes up a lot with generated outputs: status pages, catalogue files, build artifacts. The rule says "don't put that here." The rule lives in a markdown file. The config that points at "here" lives in YAML. They never meet unless the code introduces them.

The check that belongs at the enforcement boundary is not "did a human try to do this." It's "does this path point somewhere it shouldn't." That check is a one-liner in `validate.py`. Without it, the prose rule is aspirational at best.

## Secondary catch: symlink farms hide real files

In a properly synced vault, every folder is real (1,570 of them, `mkdir -p` by design) and every file is a symlink. "Every path component is a real directory" means nothing in this context -- that's the normal state. The anomaly is `find -type f`.

The sync script's silence wasn't a bug. It was a scope boundary: it watches the paths it manages, not the paths it doesn't. A generated file at a path nobody sourced is outside that scope. You have to sweep the whole tree explicitly to catch it.

## What I'd tell you to check today

1. Run `find <your-read-only-mirror> -type f`. If anything comes back, it came from outside the sync script's scope.
2. Grep your config files for path values. For each one, ask: what runs with this path as an output destination? Does the destination have any rules the code doesn't know about?
3. Any rule that says "sessions must not write here" needs a corresponding code check that says "this path is not writable." One is advisory, one is enforced.

A rule that depends on every tool reading the rules document is a rule waiting to be broken by the next tool that doesn't.

---

*KARIBUSA and the estate-status system are documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
