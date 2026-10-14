---
title: "gltf-transform tangents and ACCESSOR_VECTOR3_NON_UNIT: the trigger is sliver triangles, not degenerate UVs"
description: "If gltf-transform tangents is failing glTF-Validator with ACCESSOR_VECTOR3_NON_UNIT, the real cause is collinear positions (sliver triangles) from mesh generation, not degenerate UV coordinates. Renormalizing the output is the wrong fix."
date: 2026-10-14
project: three-d-stack
tags: ["gltf-transform", "mikktspace", "3d", "debugging", "gltf"]
---

Every AI-generated mesh I push through my 3D pipeline goes through a compliance gate before it leaves the machine. The gate runs `gltf-validate` and fails the whole batch if anything comes back red. For two weeks, tangent validation was failing on a predictable class of assets.

My log said: "`gltf-transform tangents` emits zero-length TANGENT values on degenerate-UV triangles."

I was about to file that as a bug. Then I decided to reproduce it first.

## The error

Validator output for the failing assets looked like this:

```
ERROR (ACCESSOR_VECTOR3_NON_UNIT) Accessor element at index 1234 is not unit-length: 0.0000
```

The zero-length tangents were coming out of `gltf-transform` v4's `tangents()` pass, which uses `mikktspace@1.1.1` under the hood. My pipeline runs this pass after retopology and UV unwrapping. The failing assets were all generated meshes: TRELLIS outputs and decimated scans. Hand-authored models were fine.

The pattern was consistent enough that I logged a hypothesis: degenerate UVs (triangles with all three UV coordinates identical) were confusing MikkTSpace and producing zero-length tangents.

Before filing the bug, I built a minimal repro.

## What the sweep found

I wrote a script that generated 11 degenerate mesh variants and ran `gltf-transform tangents` on each:

- Triangle with all three UVs identical (UV point)
- Triangle with two UVs identical (UV edge)
- Triangle with three collinear UVs (UV line)
- Triangle with three collinear positions (sliver in XZ plane)
- Triangle with three collinear positions (arbitrary axis)
- Several combinations of degenerate UV and degenerate position

The result destroyed my hypothesis. MikkTSpace returns a valid `(1, 0, 0)` fallback for both identical UVs and collinear UVs. The UV-degenerate variants all passed validation cleanly.

The actual trigger was the position-degenerate variants: **collinear positions, where all three vertices lie on the same line.** Those produce zero-length tangents that fail `ACCESSOR_VECTOR3_NON_UNIT`. Degenerate UVs were irrelevant.

Generated meshes produce sliver triangles constantly. Mesh generation (TRELLIS, Hunyuan3D) and decimation passes both introduce them as a side effect of geometry simplification. My pipeline had been running `tangents()` downstream of decimation without cleaning up the slivers the decimator left behind.

The log recorded a real symptom. The cause it named was wrong.

## The fix I proposed (also wrong)

Once I had the right root cause, I filed an issue against glTF-Transform. My proposed fix was a guard inside `tangents()`: detect zero-length output and substitute `(1, 0, 0)` before writing.

The maintainer declined it. His reasoning, paraphrased: this would feel like disguising a real problem to bypass the validator.

He was right. A sliver triangle is a defect in the geometry. Substituting a unit tangent makes the validator stop complaining without making the geometry less broken. The validator was doing its job correctly. My proposed fix would have silenced it without restoring what it was protecting.

His redirect: remove the degenerate triangles upstream, before `tangents()` runs. He pointed to an internal `cleanPrimitive()` function he would expose as public API if someone submitted a design for extending it. I replied with three design questions. The issue is still open.

## The right fix

The correct place to address this is before `tangents()` is called. In practice, that means cleaning up slivers at the point where they enter the pipeline, not at the point where they cause a validator failure:

```js
import { tangents, weld } from '@gltf-transform/functions';

// Weld first: collapses duplicate vertices the decimator scattered.
// This resolves some slivers as a side effect.
// Full degenerate-triangle removal needs cleanPrimitive() once it's public.
await document.transform(
  weld(),
  tangents(),
);
```

Until `cleanPrimitive()` lands as public API, aggressive welding resolves part of the problem. Fully-degenerate geometry may still need a decimation tuning pass to avoid producing slivers in the first place.

**Adjacent finding from the same sweep:** `mikktspace@1.1.1` traps with `unreachable` and `memory access out of bounds` on fully-degenerate triangles (zero area in both position and UV space). This is a separate issue from the zero-length tangent case, filed separately.

## What I'd tell you to check today

1. **Read your validator output before writing the bug report.** The error names the symptom. The cause requires a repro.
2. **A production log is not a reproduction.** A note that something failed under real conditions is a starting point, not a mechanism.
3. **If your pipeline runs `tangents()` on generated or decimated meshes**, weld and audit for sliver triangles (collinear positions) before the pass. The slivers come from the generator and decimator, not from `tangents()`.
4. **When a maintainer rejects your fix**, read the reasoning before pushing back. "The validator stops complaining" is not the same as "the problem is solved."

---

*The full 3D pipeline, failures included, is at [github.com/MushiSenpai/mushishi-3d-stack](https://github.com/MushiSenpai/mushishi-3d-stack).*
