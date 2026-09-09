---
title: "I slept while the LLM shipped five releases"
description: "I handed an AI agent four phases of a Flutter app and went to bed. It shipped them. Two honest caveats."
date: 2026-09-09
project: komorebi
tags: ["flutter", "ai-agent", "autonomy", "komorebi", "phase-gates"]
---

"Finish all the phases. I'm going to sleep."

I typed that and closed my laptop. I meant it.

By morning, [Komorebi](https://github.com/MushiSenpai/komorebi) had gone from v0.6 to v1.1.1: a Pomodoro timer, a physics tower game, full database export/import, and opt-in online leaderboards. Four major phases, a patch release, and a production backend running on my VPS.

## What I handed off

Komorebi is a Studio Ghibli-inspired productivity suite in Flutter: tasks, kanban, calendar, notes, and a break game where you stack tetromino pieces on a tiny island using real rigid-body physics. The spec was already written before the session started. The four phases:

- **Phase 5 (0.7.0):** Pomodoro module. Work/break cycle, task linking, a 7-day stats chart, and a floating timer chip that follows you between tabs.
- **Phase 6 (0.8.0):** Tsumiki Towers. Physics tower stacking via forge2d. Tetrominos wobble and slide on each other. Three splashes into the sea end the run; score is the tallest stable height in blocks.
- **Phase 7 (1.0.0):** v1.0 polish. Whole-database export/import as a single JSON file, lossless round-trip. All seven modules live in one local SQLite database.
- **Phase 8 (1.1.0):** Arena. Opt-in leaderboards backed by PocketBase at arena.theinvalid.me. A daily duel mode that seeds the piece RNG with the UTC date, so everyone on Earth stacks the same blocks that day without any real-time server involvement.

The method was phase gates: finish a phase, run tests, commit, only then start the next. CI as the night watchman.

## What shipped

Four commits: `e3f5998` through `19ebcd1`. The CHANGELOG matches the spec.

The Tsumiki Towers physics work: tetrominos drop under gravity, collide, and rotate before and after landing. Gentle wind kicks in above ten blocks. A local high-score table tracks each run. The Pomodoro timer links to any open task and logs every abandoned session (abandoning still counts the minutes, marked incomplete).

The Arena backend deploys idempotently from `server/arena/deploy.sh`: PocketBase v0.39.3 binary, a systemd unit, a Caddy reverse proxy, a Cloudflare DNS record, and collection setup, all in one command. The daily duel is deterministic from a single integer derived from the current UTC date. Every player gets the same piece sequence, no sync required. One `curl https://arena.theinvalid.me/api/health` to confirm it was live.

The phase gate structure held. Nothing cascaded between phases.

## The two honest parts

**The agent would not deploy the backend unattended.** The deploy script writes a persistent systemd service on my production VPS. The safety classifier flagged this correctly: installing services on remote production infrastructure without a human in the loop is not a safe unattended action. So the deliverable became the script itself. I woke up, read it, ran it. The backend was live by 9am. That is the right outcome. The refusal was not a failure; it was the system working.

**One overnight "lesson" turned out to be wrong.** The agent recorded a conclusion it could not actually test in isolation. I noticed it in the morning and corrected it. The phase gates catch code regressions because CI runs tests. They do not catch self-assessment errors. The model works unsupervised; it does not work with full context. Anything it concludes about runtime behavior without a live environment still needs daylight and a human read.

## The transferable lesson

Autonomous overnight runs are viable with the right setup:

1. Write the spec before you sleep, not while the agent is running. A half-written spec produces half-working phases.
2. Phase gates with CI between each phase. The agent should not start phase N+1 until phase N passes tests.
3. Expect refusal points. A classifier that refuses to deploy to production unattended is a feature. Build the session plan around it: the script becomes the deliverable, and you bless it in the morning.
4. Read the overnight notes the way you would read any first draft: with attention, not automatic trust.

The agent is not sleeping when you are. It is also not worrying. That combination is useful exactly up to the boundary where judgment is required.

## What I'd tell you to check today

If you are running long autonomous coding sessions:

- Does your spec have a clear done-condition for each phase? The agent can only gate on a condition you defined.
- Is CI actually blocking? An agent that commits failing tests and moves on compounds failures.
- Does your agent have write access to production systems? Ask whether that access is necessary or just convenient.
- Who reads the overnight notes? If the answer is also the agent, you may be auditing your own homework.

---

*Komorebi is open-source at [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi).*
