---
title: "Multiplayer without servers: seed the RNG with the date"
description: "Seeding a Flutter game's RNG with the UTC date gives every player identical pieces that day. No WebSockets, no state sync, no anti-cheat server needed."
date: 2026-09-12
project: komorebi
tags: ["flutter", "dart", "gamedev", "multiplayer", "rng"]
---

When I started planning the Arena for Komorebi, I almost reached for WebSockets. Two players, same game, racing. Then I asked what the daily duel mode actually needed.

It needed everyone to stack the same pieces and compare scores honestly. That's all. No simultaneous play. No reaction-time gaps. No server arbitrating the game state in real time.

The architecture collapsed to two functions.

## The implementation

```dart
String dailyMode([DateTime? when]) {
  final d = (when ?? DateTime.now()).toUtc();
  return 'daily-${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
}

int dailySeed([DateTime? when]) {
  final d = (when ?? DateTime.now()).toUtc();
  return d.year * 10000 + d.month * 100 + d.day;
}
```

`dailySeed()` for June 12, 2026 is `20260612`. That integer seeds the piece RNG. `dailyMode()` produces `daily-20260612`, which tags the leaderboard row.

Player A in Singapore and player B in Berlin both call `dailySeed()`. They both get `20260612`. They both pass it to `Random(20260612)`. They both get the same piece sequence. They're playing the same game.

The test makes this explicit: same seed, same pieces. Different seed, different pieces. The unit test generates a sequence from `Random(20260612)`, saves it, generates it again from the same seed, and asserts equality. That's the entire multiplayer contract, provable in a unit test.

## What "fair" actually means here

Real-time multiplayer fairness is a hard problem: latency compensation, turn order, state prediction, rollback, anti-cheat at the game-logic layer. Daily-duel fairness is a different question: did everyone play the same game?

The date seed answers it. The seed derives from the clock, not from any server secret. Everyone on Earth with the app can generate today's sequence locally. That's not a vulnerability. It's the design. Pre-generating the sequence gives you no advantage when the competition is your own score, not a race against another player watching the same screen.

The leaderboard deduplicates by handle: only your best score per mode appears. Tower height caps at 500 blocks. Those two rules are the only anti-cheat mechanics needed, because there's nothing to race and nothing to intercept.

## The backend

PocketBase. One `scores` collection. The app posts one row per completed game:

```
{ handle, score, pieces, mode: "daily-20260612", duration, ts, device }
```

The server doesn't know or care about pieces or seeds. It stores numbers and returns the top 10 when asked.

The game itself runs fully offline. You can play the daily duel without a connection; the score uploads when connectivity returns. The leaderboard resets each UTC midnight by mode tag, not by any server action.

## The lesson

"Multiplayer" is a bucket that holds a lot of very different things. Real-time racing and asynchronous comparison both qualify. The infrastructure requirements are almost nothing alike.

If you're building a daily challenge mode in Flutter or anywhere else, ask whether you need to synchronize game state or just synchronize the question. A seeded RNG is:

- Free to host (no server compute during play)
- Testable in a unit test (`Random(20260612)` produces the same sequence every time, in every environment, forever)
- Offline-tolerant (the question doesn't require a connection)
- Fair in the sense that actually matters: one game, compared honestly

Determinism is underused as a multiplayer mechanic. When "play together" actually means "compare honestly," you don't need a server. You need a date.

## What I'd tell you to check today

Before you write a WebSocket handler for a daily challenge mode: write the seed function first. The moment you can generate the same sequence twice from one integer, ask whether that's enough.

It might be.

---

*The Arena is live in [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi).*
