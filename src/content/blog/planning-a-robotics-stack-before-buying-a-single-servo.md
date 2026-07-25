---
title: "Planning a robotics stack before buying a single servo"
description: "VISHWAKARMA P0: Isaac Sim quarantined for sm_120 Blackwell bugs, the target drone discontinued, and GR00T weights carrying a non-commercial license the Apache badge did not show."
date: 2026-07-25
tags: ["robotics", "lerobot", "vla", "simulation", "planning"]
---

I am building a physical robot arm. I have not bought anything yet.

That ordering is deliberate. In six weeks of planning I hit four decisions that would have cost real money if I had placed the hardware order first. This post documents them. Nothing here claims a working robot. It documents how to plan so the first purchase is not a mistake.

The project is VISHWAKARMA: manipulation arm first (SO-ARM101 lineage, LeRobot v0.6.x async inference), drone perception second, commercial integration third. Named for Vishwakarma, the divine engineer of Indian mythology. P0 is complete as of 2026-07-09: all software, CI green, 43 tests passing, gateway answering on `127.0.0.1:9340`. The arm and drone are on a buy list. Hardware phases are gated on the software gate passing first.

Here is what the software gate caught.

## Isaac Sim quarantined on day one

The first simulation candidate was Isaac Sim. NVIDIA's own manipulation benchmark platform, deep LeRobot integrations, actively maintained. Obvious first pick.

It does not work on the RTX 5090 for this use case. The 5090 is a Blackwell GPU (compute capability sm_120), and Isaac Sim's CUDA kernels hit sm_120 support gaps that surface as runtime failures. D8 in the spec: Isaac is quarantined.

The replacement is ManiSkill3, running headless. The P0 smoke test is a scripted LeRobot v2.1 pick-place dataset, 10 episodes, round-trip record and replay. It runs headlessly on the 5090 without the compatibility failures. If I had bought the arm first and discovered this during bring-up, I would have spent a week debugging a sim that could not run on my GPU before writing a single policy line.

The lesson is not "Isaac Sim is bad." The lesson is that CUDA kernel compatibility is not guaranteed across GPU generations, and you find that out when you run the sim, not when you order the arm.

## The target drone was discontinued mid-spec

The original T2 hardware pick was the Tello EDU: sub-250g, programmable Python SDK, documented API, well-priced. It appears in every beginner robotics tutorial.

F03 in the problems log: the Tello EDU is discontinued.

The current sub-250g indoor-legal candidates are the RoboMaster TT and the Crazyflie 2.1. Neither is a drop-in replacement. Different SDKs, different flight controller interfaces, different software scaffolding requirements. The drone decision is deferred to P1, where the call can be made with current stock availability rather than a tutorial written two years ago.

If I had ordered the Tello EDU before checking, I would have found either a gray-market unit with unknown warranty or no unit at all.

## The GR00T weights are not Apache-2.0

The VLA ladder I planned has five rungs:

| Rung | Model | Weights license | Lane |
|---|---|---|---|
| 1 | ACT | Apache-2.0 | CLEAN |
| 2 | Diffusion Policy | Apache-2.0 | CLEAN |
| 3 | SmolVLA (~450M params) | Apache-2.0 | CLEAN |
| 4 | pi0 / pi0.5 (openpi, ~3B) | Apache-2.0 | CLEAN |
| 5 | GR00T N1.7 (3B) | NVIDIA Open Model License | NOML |

The trap: the GR00T GitHub repo shows `Apache-2.0` at the top level. The code is Apache-2.0. The weights are under the NVIDIA Open Model License, a separate document. The previous versions (N1, N1.5) were explicitly non-commercial. N1.7 introduced a "fully commercially licensable" claim, but that claim requires per-deployment owner verification. It cannot be assumed to carry forward from the repo badge.

This is F02 in the problems log. The same lesson appeared in ISAZA, the translation stack, where CC-BY-NC weights sat under an Apache-labeled repo. **The badge on the repo is the code license, not the weights license.**

The enforcement is a two-lane system in license-CI, validated before a single GPU-hour is spent:

- **CLEAN**: Apache-2.0 weights, client-shippable
- **NOML**: benchmark rung only, walled off from anything going to a client

Every commit runs a red-team fixture: a CLEAN-lane manifest that references the NOML GR00T weight. The CI step must reject it:

```
license-CI: CLEAN manifest references NOML artifact 'groot-n1-7'
exit 1
```

Unknown licenses fail closed: unrecognized = not CLEAN. The fixture proves the boundary bites, not just that the code exists.

## The sequencing: $0 first, then ~$330

The hardware buy list is approximately $330 to $500 (SO-ARM101 arm plus a drone). That is not a catastrophic expense. But P0 is entirely software, and software gates can fail in ways that require architectural changes. Architectural changes are cheaper before any physical actuator is involved.

P0 is done. The gateway answers on `127.0.0.1:9340`. The license gate rejects the red-team fixture. The sim records and replays. The eval protocol is frozen at N=20 episodes per task, randomized object poses, fixed cameras, reporting success rate and latency (median and p95) across a closed failure taxonomy.

I still have not bought a servo.

## What to check before ordering hardware

1. **Run the sim on your actual GPU.** CUDA kernel compatibility is not guaranteed across generations. sm_120 (Blackwell) broke Isaac Sim for this use case. Verify on the box the robot will run on before you buy anything.
2. **Check whether your target hardware is still available.** Tutorials reference products from two or three years ago. Run the actual product page today.
3. **Read the weights license file, not the repo badge.** Especially for anything published by NVIDIA or Meta. A top-level `Apache-2.0` label on a GitHub repo is the code license. Check the model card or the `LICENSE` file in the weights directory.
4. **Freeze your eval protocol before you train anything.** If you define success after seeing results, you are curating, not measuring. Lock the criteria before the first training run.

Planning is not delay. It is the work that makes the first hardware purchase not a mistake.

---

*VISHWAKARMA is a private repo until hardware phases prove the claims. The estate and all projects ready for public view: [github.com/MushiSenpai](https://github.com/MushiSenpai).*
