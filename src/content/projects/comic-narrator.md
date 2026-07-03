---
title: "Comic Narrator"
oneliner: "A comic page goes in; a dramatized video comes out — panel detection, cloned character voices, narrator on captions, 2.5D parallax camera."
status: building
repo: "https://github.com/MushiSenpai/comic-manga-narrator"
stack: ["Nemotron vision", "OpenCV", "Fish Speech", "ffmpeg", "Freesound"]
started: 2026-06-01
order: 5
---

The proof that the infrastructure ships products: this is an application built entirely on the three stacks above. A vision LLM detects and reads panels, the audio stack acts the dialogue in cloned voices, and ffmpeg drives a Ken Burns + 2.5D parallax camera across the page.

First end-to-end run is complete; voice direction, SFX beds, and pacing are being tuned.
