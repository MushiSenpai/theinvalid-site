---
title: "Comic Narrator"
oneliner: "A comic page goes in; a dramatized video comes out: panel detection, cloned character voices, narrator on captions, 2.5D parallax camera."
status: building
repo: "https://github.com/MushiSenpai/comic-manga-narrator"
stack: ["Nemotron omni (vision)", "OpenCV", "Fish Speech", "ffmpeg", "Freesound", "Hermes skill"]
started: 2026-06-01
order: 5
---

The proof that the infrastructure ships products: this is an application built entirely on the three stacks above. A vision LLM detects and reads panels, the audio stack acts the dialogue in cloned voices, and ffmpeg drives a Ken Burns + 2.5D parallax camera across the page.

Seven tagged releases so far (v0.1.0 to v0.7.0), each carrying the actual demo video from that pass, so the quality curve is public. Voice direction, SFX beds, and pacing are still being tuned.

**Since launch (updated November 2026).**

- **One pass instead of two.** The vision model and the voice stack used to need a full GPU swap between them, about ten minutes of model loading per page. Lowering one vLLM flag (`--max-num-batched-tokens`, 16384 to 4096) let both fit on the 32 GB card together. [Six boot attempts](/blog/killing-the-two-pass-dance).
- **Parsing a model's JSON safely:** three ways the vision model's output silently broke the parser, and the parse-boundary rules that now catch all three. [The write-up](/blog/the-model-echoed-my-prompt-back).
- **Audio assembly:** a silent no-op `docker exec`, an ffmpeg concat that broke on a video-only clip, and sound effects stretching a panel to 19 seconds. Each looked like a model problem first. [Three gotchas](/blog/three-comic-narrator-audio-assembly-gotchas).
- It also runs as an agent skill: hand it a page, get a video back.

