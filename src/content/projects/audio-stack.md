---
title: "Mushishi Audio Stack"
oneliner: "Fully local voice cloning, TTS, lip-sync avatars, music generation, and auto-dubbing: job-queue architecture, every model MIT/Apache-2.0."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-audio-stack"
stack: ["Fish Speech", "WhisperX", "LatentSync", "Hallo2", "YuE 7B", "Redis/RQ"]
started: 2026-05-23
order: 3
---

A photo and a voice sample go in; a lip-synced, voice-cloned narration video comes out. The install deviated from its spec in **25+ documented places**, all published as LESSONS.md, because the failures are more useful than the successes.

Verified rebuildable: fresh containers pass an end-to-end music-generation job with zero manual intervention.

**Since launch (updated November 2026).**

- **An avatar that says what it is.** The demo avatar opens by naming itself as an avatar. Fully local with Fish Speech 1.5 and LatentSync: gross lip sync correct, close-up artefacts visible, and both stated up front. [The write-up](/blog/i-built-an-avatar-that-introduces-itself-as-an-avatar).
- **The install log, in full:** every one of the 25+ places the build deviated from its April spec. [25 deviations](/blog/25-ways-the-audio-stack-install-deviated-from-its-spec).
- **Upstream fixes from running it:** merged into YuE, and submitted to Fish Speech, WhisperX and MuseTalk, each from a real failure hit here.

