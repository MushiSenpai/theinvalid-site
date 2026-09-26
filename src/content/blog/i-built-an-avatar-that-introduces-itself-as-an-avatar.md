---
title: "I built an avatar that introduces itself as an avatar"
description: "Fish Speech 1.5 + LatentSync fully local lipsync in five minutes: gross sync correct, close-up artifacts visible. The avatar opens by naming what it is."
date: 2026-09-26
project: audio-stack
tags: ["audio-stack", "lipsync", "latentsync", "fish-speech", "avatar"]
---

Most talking-head demos open with something like "hello, this is a test of our pipeline." Mine opens with: "Hi. I'm an avatar. I was generated on one machine, fully locally, in about five minutes. The voice you're hearing is cloned from a single sample."

That's the script I wrote. Not a product pitch. A thing that names what it is.

## The pipeline

Two stages, both local, no API calls:

1. A reference voice sample goes into **Fish Speech 1.5** for voice cloning and synthesis. That produced 34.5 seconds of speech in about 25 seconds.
2. The audio and a single reference photo go into **LatentSync** for the lip-sync pass. That took about 280 seconds.

Total wall clock: around five minutes. Photo in, talking-head video out. This is from benchmark run E2 on 2026-06-12 on the full chain.

## The result

The benchmark verdict was **PARTIAL PASS**, and that framing is the honest one. Not "it works," not "it failed." Partial.

## What passed

Gross lip-sync: correct. Verified by comparing `ffmpeg -af silencedetect` timestamps against the video timeline. The mouth closes during silence and opens during speech. That's the baseline contract, and it holds.

![Left: silence segment, mouth closed. Right: speech segment, mouth open and synced to audio.](/avatar-lipsync-frames.png)

At this format, it works. Head stays stable. Mouth tracks correctly. For short-format social video or anything where the face isn't filling the frame, this is real, usable output.

## What didn't

At full-frame close-up zoom, lip-interior artifacts appear. The geometry of teeth and tongue during vowels doesn't survive inspection at broadcast resolution. The transitions between mouth shapes look interpolated in a way that doesn't match how human faces actually move.

Social-grade output, not broadcast-grade. That line is real and worth knowing before you quote a client.

There are three tiers in the local stack now. MuseTalk 1.5 (social, ~78s wall clock per clip) is the fast path. LatentSync 1.6 (production portrait, ~242s) is what this post benchmarked. Hallo2 (cinematic, ~20 minutes) adds head pose and CodeFormer at roughly 15x the cost. None of them clear broadcast close-up. For that, you're still on a cloud path.

## Why a meta script

The script I wrote wasn't clever for the sake of it. Most demo scripts quietly lie. They show only the angles that work, they pick only the lines where nothing looks wrong, and they implicitly suggest the viewer should be impressed rather than informed.

Writing a script where the avatar opens with "I'm not real, here's what I can do and here's what I can't" forced me to actually commit to that assessment. The artifact of the pipeline became the evaluation.

It's also a useful calibration. If a viewer watches an avatar that says "I'm an AI and this is what local AI video looks like" and still finds it usable for their purpose, you've measured something real. You haven't sold a feeling.

## What I'd tell you to check today

If you're building a lipsync pipeline, verify both layers independently:

1. **Gross sync:** Does the mouth close during silent segments? Run `ffmpeg -af silencedetect` on your audio and compare against the video timeline. This catches the failure mode where lip motion runs independently of audio rhythm.
2. **Close-up artifacts:** Zoom to where the viewer would actually see the face at the intended display size. Lip-interior during vowels and consonant transitions degrade first. Know your honest ceiling before your client finds it.

The gap between "the mouth is moving" and "this works at broadcast close-up" is where most projects stop being honest with themselves.

---

*The full local audio stack, including Fish Speech 1.5 voice cloning and the LatentSync lipsync pipeline, is documented at [github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack).*
