---
title: "Komorebi"
oneliner: "A Studio Ghibli-inspired productivity suite in Flutter: tasks, kanban, calendar, notes, pomodoro, and a physics tower-stacking break game with online leaderboards."
status: shipped
repo: "https://github.com/MushiSenpai/komorebi"
stack: ["Flutter", "SQLite", "Drift", "custom design system"]
started: 2026-05-28
order: 6
---

木漏れ日: *sunlight filtering through leaves.* Local-first (everything in on-device SQLite), two hand-tuned themes (Totoro meadow / Spirited Away twilight), and the same spec-driven, phase-gated method as the AI stacks: the public phase table shows exactly what's done and what isn't.

v1.1 added the Arena: an opt-in handle, shared leaderboards and a daily duel on a self-hosted PocketBase. All eight build phases are done; the app-store release is the part still pending.

**Since launch (updated November 2026).**

- **A daily duel with no game server:** every player gets the same pieces each day because the random generator is seeded with the UTC date. [How](/blog/multiplayer-without-servers-seed-the-rng-with-the-date).
- **An agent shipped four phases overnight,** against the phase table, with two honest caveats. [The write-up](/blog/i-slept-while-the-llm-shipped-five-releases).
- **Bugs worth sharing:** a zero-size Stack that collapsed the whole game view without an error ([the bug](/blog/the-bug-was-a-zero-size-stack)), and four Linux and Android build footguns ([the list](/blog/four-flutter-linux-gotchas)).

