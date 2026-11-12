---
title: "Four Flutter Linux gotchas that each cost me a session"
description: "flutter test dies mid-suite, Gradle toolchain has no JAVA_COMPILER, ListView invisible to widget tests, game loop performs better without a Ticker — four footguns from building Komorebi on a Linux workstation."
date: 2026-11-12
project: komorebi
tags: ["flutter", "dart", "linux", "testing", "android"]
---

Building [Komorebi](https://github.com/MushiSenpai/komorebi) on a pure-Linux workstation means no Xcode, no Android Studio GUI, no Mac to catch the iOS edge cases. It also means hitting the gotchas that Flutter's docs quietly assume a macOS or Windows user will never see. Here are four of them, in roughly increasing order of subtlety.

## 1. /tmp is too small and flutter dies silently

Flutter's test runner and build system scatter scratch files in `/tmp`. On my workstation, `/tmp` is a tmpfs sized at 800 MB (the kernel default on a 32 GB machine ends up smaller after tuning). A `flutter test` run against a mid-sized app fills it. The result is not a helpful error: runs die mid-suite or hang indefinitely, with the failure point moving between runs.

The fix is one environment variable:

```bash
export TMPDIR=/path/to/a/large-disk/flutter-tmp
mkdir -p "$TMPDIR"
```

Add it to your shell profile and to any CI wrapper. The Flutter tooling respects `TMPDIR` throughout.

**Check `df -h /tmp` first** if `flutter test` or `flutter build` dies mysteriously partway through. If it is under 2 GB, set `TMPDIR` now.

## 2. Gradle says "toolchain does not provide JAVA_COMPILER"

The error:

```
> Could not resolve com.android.tools.build:gradle:8.x.x.
> ...
Toolchain 'JDK17' does not provide JAVA_COMPILER.
```

The cause: the system-managed OpenJDK on Ubuntu ships as a JRE, not a JDK. `javac` is absent. Gradle needs the full JDK for its toolchain-auto-provisioning step and fails exactly here.

The fix: install a user-space Temurin JDK (no sudo required) and point Flutter at it:

```bash
# Download from adoptium.net/releases or install via SDKMAN
flutter config --jdk-dir /path/to/temurin-17
```

Verify with `flutter doctor --android`, which will show a green Android toolchain once it finds `javac`.

The confusing part: `java -version` returns something fine. It is `javac` that is missing, and `flutter doctor` does not check for it until you actually attempt a build.

## 3. ListView in a bottom sheet is viewport-lazy

This one burned two hours of widget tests.

`ListView(children: [...])` renders its children lazily as the viewport scrolls. Inside a `showModalBottomSheet`, the initial visible area may not include everything below the fold. A widget test that asserts on a widget below the fold will fail with:

```
The following widget was not found in the widget tree:
find.text('Submit')
```

...even when the widget is correctly built and the route is correct.

The fix: scroll to it before asserting.

```dart
await tester.scrollUntilVisible(
  find.text('Submit'),
  500.0,
  scrollable: find.byType(Scrollable).last,
);
```

This applies to any `ListView(children:)` inside a constrained container (bottom sheets, dialogs, sidebars) where the content can exceed the visible height. If you want everything mounted at widget-test time, use `SingleChildScrollView + Column` instead. If you want explicit lazy loading, use `ListView.builder` and accept the scroll step in tests.

## 4. The right game loop does not use a Ticker

Komorebi includes a tower-stacking break game built entirely in Flutter, no Flame or any engine. The first version drove the game loop with `Ticker` + `setState` per frame. That is the intuitive approach: Ticker gives you frame deltas, `setState` repaints. It also has a problem: `setState` on the whole subtree triggers a rebuild of everything in scope, and on Linux desktop the repaint schedule can interact with the embedder's own refresh in ways that produce jank you cannot reliably reproduce in tests.

The alternative that worked cleanly:

```dart
// Game widget init:
late final Timer _gameLoop;

@override
void initState() {
  super.initState();
  _gameLoop = Timer.periodic(
    const Duration(milliseconds: 16),
    (_) => _gameState.tick(), // tick() calls notifyListeners()
  );
}
```

Pair that with a `CustomPainter` that listens to a `ChangeNotifier`. It repaints only the `CustomPaint` widget, not the entire tree, and the update path is simple enough to reason about in tests.

The tradeoff: `Timer.periodic` is not frame-exact. For a physics-toy game where deterministic timing is not critical, that is fine. If you need deterministic physics, pin your `dt` to a fixed step and avoid relying on wall-clock deltas anyway.

## What I'd tell you to check today

1. Run `df -h /tmp`. Under 2 GB: set `TMPDIR` before the next test run.
2. Run `flutter doctor --android`. Toolchain complaint: install Temurin, not `default-jdk-headless`.
3. Any widget test asserting on content inside a bottom sheet: add `scrollUntilVisible` before the assertion, even if the widget looks like it should be visible.
4. Choppy game loop on Linux desktop or in tests: try `Timer.periodic + CustomPainter Listenable` before adding an engine dependency.

None of these appear in the Flutter guides in a way that would surface at 1am when things break. The docs assume Android Studio, a Mac, and a cooperative target platform. Linux desktop is the exception that teaches you what the defaults are actually doing.

---

*Komorebi is at [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi).*
