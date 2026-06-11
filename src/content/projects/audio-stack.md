---
title: "Mushishi Audio Stack"
oneliner: "Fully local voice cloning, TTS, lip-sync avatars, music generation, and auto-dubbing — job-queue architecture, every model MIT/Apache-2.0."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-audio-stack"
stack: ["Fish Speech", "WhisperX", "LatentSync", "Hallo2", "YuE 7B", "Redis/RQ"]
started: 2026-05-23
order: 3
---

A photo and a voice sample go in; a lip-synced, voice-cloned narration video comes out. The install deviated from its spec in **25+ documented places** — all published as LESSONS.md, because the failures are more useful than the successes.

Verified rebuildable: fresh containers pass an end-to-end music-generation job with zero manual intervention.
