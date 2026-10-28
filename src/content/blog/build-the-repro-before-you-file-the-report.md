---
title: "Build the repro before you file the report"
description: "I had a logged production symptom, a named cause, and I was wrong about the cause. Building a minimal reproduction caught it before I burned credibility with an upstream maintainer."
date: 2026-10-28
project: three-d-stack
tags: ["debugging", "open-source", "gltf-transform", "mikktspace"]
---

Two weeks of glTF-Validator failures. A clear pattern: AI-generated and decimated meshes breaking every time, hand-authored meshes clean. A log entry that named the cause. I was drafting the upstream bug report when I decided to build a minimal reproduction first.

I'm glad I did.

## The log entry

The error from `gltf-validate`:

```
ERROR (ACCESSOR_VECTOR3_NON_UNIT) Accessor element at index 1234 is not unit-length: 0.0000
```

Zero-length TANGENT values, coming from `gltf-transform v4`'s `tangents()` pass, which uses `mikktspace@1.1.1` under the hood. My 3D log had a note from the day it first appeared: "`gltf-transform tangents` emits zero-length TANGENTs on degenerate-UV triangles." Plausible mechanism: MikkTSpace does peculiar things when UV coordinates degenerate. The note was written in production, from a real failure. I had been treating it as confirmed.

## The repro

Before filing, I wrote a sweep: 11 degenerate mesh variants, each through `gltf-transform tangents`, each validated.

- UV-point triangles (all three UVs identical)
- UV-edge triangles (two UVs identical)
- UV-line triangles (three collinear UVs)
- Position-degenerate triangles (sliver in XZ plane, arbitrary axis)
- Combinations of both

MikkTSpace returns a valid `(1, 0, 0)` fallback for identical UVs. For collinear UVs. Every UV-degenerate variant passed `gltf-validate` cleanly.

The failures came from **position-degenerate variants**: triangles where all three vertices are collinear (sliver triangles), which mesh generators and decimators produce as a byproduct of geometry simplification.

The cause in my log was wrong. I was about to file a bug for a trigger that does not exist.

The full technical breakdown, including why the fix I then proposed was also wrong, is in a separate post: [gltf-transform tangents and ACCESSOR_VECTOR3_NON_UNIT: the trigger is sliver triangles, not degenerate UVs](/blog/fixing-the-bug-when-rebuilding-degenerate-uv-triangles).

## What filing it would have cost

The maintainer would have run my repro. MikkTSpace would have returned unit-length tangents. He would have closed it as "cannot reproduce" -- correctly.

I have been building toward a contribution to glTF-Transform. That requires a maintainer who trusts that my reports are grounded. An issue that does not reproduce on its stated trigger is exactly the kind of noise that closes that door, and it takes a while to reopen. I burned nothing because I checked first. That was luck disguised as discipline.

## The lesson

A production symptom does not carry its cause with it. The log recorded what broke. It did not record why.

This sounds obvious. It stops feeling obvious when you have two weeks of consistent failures and a plausible mechanism already written in the log. At that point the hypothesis has been sitting there long enough to feel like a confirmed fact. It is not. A log entry is not a controlled experiment.

A bug report is a claim about a mechanism, not about a bad day you had. If you cannot trigger the failure on the stated input in a clean environment, you do not know the mechanism.

## What I'd tell you to check today

1. **Before filing any upstream issue, build a self-contained repro** that triggers the failure from scratch. If the failure does not appear on a minimal input with the named trigger, you have a hypothesis, not a root cause.
2. **Keep symptoms and causes separate in your logs.** "X breaks on Y" is a symptom. "X breaks because Z" is a mechanism claim, and it needs a controlled test before it gets written as fact.
3. **Run a sweep before you write the conclusion.** Vary the inputs systematically and let the failing dimension name itself. Your intuition about which input property triggers the failure is often pointing at a correlated feature, not the actual trigger.
4. **Upstream credibility is finite.** A wrong report spends some of it. A correct minimal repro builds it.

---

*The 3D pipeline, failures included, is documented at [github.com/MushiSenpai/mushishi-3d-stack](https://github.com/MushiSenpai/mushishi-3d-stack).*
