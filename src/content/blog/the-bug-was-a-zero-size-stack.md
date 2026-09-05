---
title: "The bug was a zero-size stack"
description: "Flutter Stack sizes itself to its largest non-positioned child. A SizedBox.shrink() in a conditional game-over overlay collapsed an entire game view to 0x0, silently, no exception."
date: 2026-09-05
project: komorebi
tags: ["flutter", "dart", "debugging", "gamedev"]
---

Komorebi has a physics tower-stacking game as a pomodoro break feature. First human play report: blank screen.

Not a crash. Not an exception in the logs. The game-over overlay appeared at exactly the right moment when pieces ran out. Then the next run started and went blank again.

## Three wrong theories

**Dual-GPU passthrough.** The workstation has an RTX 5090, and some workloads use a VM with passthrough. Maybe the wrong display adapter was active. This theory ate a solid hour.

**The Flame engine.** Komorebi's game uses a custom `CustomPainter`, not Flame (Flutter's game engine), but the code structure looks superficially similar. Maybe something about the paint pipeline was misbehaving on this platform. Wrong.

**X11 lies about OpenGL frames.** On Linux, screenshot tools sometimes capture stale frames when GL is rendering asynchronously. Maybe the game was running fine and the screenshot was just not capturing it. This was the most sophisticated theory, and also the easiest to falsify: a human watched the physical screen. Blank.

## The symptoms

No error output to quote. The game view returned a `Stack` with four children:

- `TowerView` (the game canvas, a `CustomPainter` with `SizedBox.expand()` as its child)
- A `Positioned` widget: HUD row at the top
- A `Positioned` widget: touch controls at the bottom
- A `ValueListenableBuilder` watching `game.gameOver`

The builder returned one of two things depending on game state:

```dart
builder: (context, over, _) => over
    ? Positioned.fill(...)     // game-over card
    : const SizedBox.shrink(), // "nothing" while playing
```

The game ran. Physics ticked. The canvas painted. Nothing appeared on screen.

## The fix

Replacing the entire game subtree with `ColoredBox(color: Colors.red)` and adding children back one at a time took about ten minutes. The moment the `ValueListenableBuilder` rejoined the children list, the game went blank again.

From the Flutter docs: **a Stack sizes itself to its largest non-positioned child.** `TowerView` and the `ValueListenableBuilder` were both non-positioned children. During play, the builder returned `const SizedBox.shrink()`, which measures as 0x0. The Stack had no tight constraints from its parent to override this. The Stack became 0x0. `TowerView` was laid out inside 0x0 constraints and painted onto a zero-size surface.

The fix was one argument:

```dart
Stack(
  fit: StackFit.expand, // forces Stack to fill its parent
  children: [
    TowerView(world: game),
    Positioned(...),   // HUD
    Positioned(...),   // touch controls
    ValueListenableBuilder(
      valueListenable: game.gameOver,
      builder: (context, over, _) => over
          ? Positioned.fill(...)
          : const SizedBox.shrink(),
    ),
  ],
)
```

`StackFit.expand` tells the Stack to fill its parent instead of sizing to its children. The `SizedBox.shrink()` branch stays, but it can no longer influence the Stack's size.

The regression test added to `test/widget_test.dart` is explicit about what it guards:

```dart
// Start a run: the game view must lay out at full size with the HUD
// visible (regression: a SizedBox.shrink overlay branch once collapsed
// the Stack to 0x0 during play -- the "blank game" bug).
final gameSize = tester.getSize(find.byType(TowerView));
expect(gameSize.width, greaterThan(100));
expect(gameSize.height, greaterThan(100));
```

## The lesson

Three theories, none of them correct. The one that worked: replace the broken subtree with a solid-color box, add pieces back until the blank reappears, then read the Flutter docs for what actually sizes a `Stack`.

The X11 screenshot theory was the most seductive because it offered a reason to stop looking at the code. "The verification tool is lying" is sometimes true, but it demands a second verification path before you accept it. One human, one monitor, thirty seconds.

The general form: bisection beats theorizing when the search space is a widget tree. A `ColoredBox` where your broken widget lives is not elegant debugging, but it is fast and unambiguous. The widget either covers a 600x800 rectangle of red or it does not.

## What I'd tell you to check today

Any Flutter `Stack` that renders blank under some condition without throwing: look for non-positioned children that return zero-size widgets conditionally. `SizedBox.shrink()`, a bare `Container()` with no dimensions, anything that measures as 0x0. Either add `fit: StackFit.expand` to the Stack, or wrap those conditional branches in `Positioned` so they cannot affect the Stack's intrinsic size.

---

*Komorebi is an open-source Flutter productivity suite (tasks, kanban, calendar, notes, pomodoro, and this game) at [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi).*
