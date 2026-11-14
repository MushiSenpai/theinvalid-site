---
title: "Three audio assembly gotchas from building an AI comic narrator"
description: "Docker exec silently doing nothing against an unmounted path, ffmpeg concat breaking on a video-only clip, and SFX one-shots stretching panel dwell to 19 seconds: each looked like a model problem."
date: 2026-11-14
project: comic-narrator
tags: ["comic-narrator", "ffmpeg", "docker", "audio", "debugging"]
---

The comic narrator turns a manga page into a dramatized video: panels detected by a vision LLM, dialogue acted in cloned voices, SFX and music beds underneath, all assembled by ffmpeg. The model layers worked fine in isolation. These three bugs came from the assembly layer, and each one looked like a model problem until it wasn't.

## Gotcha 1: `docker exec` exited 0 and produced nothing

ACE-Step, the music bed generator, runs inside `creative-audio-worker`. That container mounts specific subdirectories of `/data/ai` for model weights and outputs. It does not mount `08-portfolio`.

The music generation script lived at `/data/ai/08-portfolio/comic-narrator/music/gen.py`. Running it via:

```bash
docker exec creative-audio-worker python /data/ai/08-portfolio/comic-narrator/music/gen.py
```

exited 0 on the outer wrapper. No music file appeared. Inside the container, Python raised:

```
python: can't open file '/data/ai/08-portfolio/comic-narrator/music/gen.py': [Errno 2] No such file or directory
```

The wrapper saw exit 0 because that error code came from the Python launcher itself, which the shell wrapper was not catching. The container wrote nothing to the mounted output directory and nothing to the wrapper's stdout.

The fix: run the script from a path the container actually mounts, or `docker cp` it in first. Output goes to a mounted directory; host-copy afterward.

The lesson: a `docker exec` exit 0 is the wrapper's exit code, not a guarantee the script ran against the host filesystem path you think it did. When a container-side script produces nothing and exits clean, the first check is whether the path exists inside the container:

```bash
docker exec creative-audio-worker ls /data/ai/08-portfolio
```

That answers the question immediately.

## Gotcha 2: ffmpeg concat needs uniform streams, and libx264 cannot carry alpha

**The missing audio track.** The establishing shot (the overview frame that opens a chapter) is video only, no audio. The narration clips have both video and audio. The ffmpeg `concat` demuxer requires every input to carry the same stream types. A video-only clip followed by an audio+video clip is not uniform; the concat either fails or silently drops audio from the joined file depending on the concat mode.

The fix: pad the video-only clip with a silent AAC track before the concat:

```bash
ffmpeg -i establishing.mp4 -f lavfi -i anullsrc=r=44100:cl=stereo \
  -c:v copy -c:a aac -shortest establishing-with-audio.mp4
```

After that, every clip going into the concat has matching stream topology.

**Alpha channels and libx264.** The 2.5D parallax overlay clips carry a transparency channel through the composition stage. libx264 does not support alpha. When you encode a clip with an alpha channel using libx264, ffmpeg silently drops the alpha plane with:

```
Encoder libx264 does not support pixel format yuva420p; auto-selecting format yuv420p
```

The fix: use ProRes 4444 or VP9 for intermediates that carry transparency. Neither drops the alpha.

These two bugs are independent but surface in the same pipeline because the concat and the composition happen close together. I found the audio drop first, fixed it, then found the flat overlay, and lost another hour to it.

## Gotcha 3: SFX one-shots stretched panel dwell to 19 seconds

The SFX engine drops one-shot sound effects on action panels. Source clips from Freesound are whatever length the original recording was: often 5 to 15 seconds with long tails of reverb or crowd noise.

The video renderer holds a panel on screen until all audio for that panel finishes. With three SFX cues on one action panel and each clip running 6 seconds, panel dwell stretched to 19 seconds on a single frame that was supposed to last 2 seconds.

The fix: trim every SFX one-shot to roughly 2.5 seconds at ingest. The punch or crash lands, the tail fades, and the panel moves on.

The lesson: an open audio library has no reason to know your pacing budget. If panel dwell time is driven by the longest audio on that panel, and your SFX clips are unconstrained in length, panel timing becomes an artifact of which Freesound clip you happened to pick. Gate the clip length explicitly, at ingest, not at mix time.

## What I'd tell you to check today

1. When a `docker exec` command produces no output and exits 0, verify the path is actually mounted: `docker exec <container> ls <path>`.
2. Before any ffmpeg `concat`, check that every input has the same stream count. Pad video-only clips with `anullsrc`.
3. Alpha intermediates: use ProRes 4444 or VP9. libx264 will silently drop the alpha plane.
4. SFX clips from open libraries: trim them to your panel pacing budget at ingest.

---

*The comic narrator pipeline is at [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator).*
