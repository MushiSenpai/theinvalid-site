# Blog queue + lesson backlog — the single repository

Two sections. **§A** is the FIFO publication queue (the Wednesday bot takes the
FIRST `[queued]` block). **§B** is the comprehensive backlog: EVERY issue,
failure, and decision across ALL projects, past and future, with priority.
Topics get promoted §B → §A by writing a topic block. Every work session that
produces a lesson appends to §B (or straight to §A if it's clearly a post).
Format rules: PIPELINE.md.

---

# §A — Publication queue (FIFO)

## [queued] your-firewall-isnt-protecting-your-docker-containers
**Angle:** Docker silently bypasses UFW for every published port — found because a phone on my own Wi-Fi could open my ComfyUI with zero auth. The DOCKER-USER chain fix, and why you must verify from an untrusted device.
**Sources:** sovereign-ai-stack repo LESSONS.md (Docker bypasses UFW); scripts/harden-docker-firewall.sh; backlog I-2.
**Targets:** linkedin, reddit:r/selfhosted, hn

## [queued] a-32gb-gpu-is-a-budget-not-a-suggestion
**Angle:** The VRAM discipline that makes one RTX 5090 run an LLM stack, a video stack, and an audio stack: unplugging the monitor from the GPU to run display on onboard graphics (~25K context tokens reclaimed), never co-loading models — purge VRAM, fresh-load per task, sequential modes with handoff scripts — and why NVFP4 was the only quantization leaving real KV-cache headroom.
**Sources:** Decision Log §12 (sequential workflow), §13 (iGPU switch), §7 (180K ctx math), README VRAM tables; backlog S-1..S-5.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

## [queued] nightly-wheels-are-a-depreciating-asset
**Angle:** Rebuilding a one-month-old Dockerfile failed twice because "install from the nightly index" instructions expire in weeks; the working container had silently drifted to stable torch. Pin what's proven; runtime pip installs rot.
**Sources:** audio-stack repo LESSONS.md ("The June rebuild"); worker-pip-freeze-2026-06-10.txt; backlog I-4.
**Targets:** linkedin, reddit:r/LocalLLaMA

## [queued] moving-dockers-data-root-doesnt-move-containerd
**Angle:** /var hit 99% weeks after I "moved Docker to the big disk" — image builds live in containerd's store, a different root. How the watchdog caught it day-1, finding the eater, the migration script.
**Sources:** EXECUTION-PLAN 2026-06-11; scripts/move-containerd-root.sh; backlog I-3.
**Targets:** linkedin, reddit:r/selfhosted, hn

## [queued] six-hours-in-tensorrt-llm-so-you-dont-have-to
**Angle:** Eight distinct failures ending at AutoDeploy's inability to trace multimodal-mandatory models; NVIDIA's own benchmark paper uses vLLM. How to recognize when to stop digging.
**Sources:** Decision Log §3.1–3.8, §4; backlog S-9.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

## [queued] what-i-designed-in-may-vs-what-shipped-in-june
**Angle:** The AI-generated architecture image (gorgeous, wrong in 7+ places within a month) vs the versioned Mermaid diagram. Plans are hypotheses; diagrams that can't be diffed will drift — and so do spec status lines (the audio spec said "Planned" for 3 weeks after the system was built).
**Sources:** the v1.6.4 image; Decision Log §v1.6-1, §v1.7-1; backlog M-6, M-7.
**Targets:** linkedin, hn

## [queued] sovereignty-as-routing-not-policy
**Angle:** Three LLM fallback chains, three guarantees — including the client profile that refuses to fall back, because silent degradation is worse than failure.
**Sources:** sovereign doc §Provider Fallback Routing + §Sovereignty Tiers; backlog S-11.
**Targets:** linkedin, reddit:r/selfhosted

## [queued] i-built-a-3-stack-ai-system-without-writing-code
**Angle:** The method post: discuss (multi-LLM) → consolidate → spec → execute (LLM-directed) → verify (gates) → operate. B.E. in CS, reads code, directs rather than writes. The repos are the evidence.
**Sources:** profile README; every repo's "How this was built"; resume.
**Targets:** linkedin, hn

## [queued] the-sam3-mask-that-crashed-vace
**Angle:** A days-long tensor-dimension bug that looked like a model problem and was a wiring problem: image-mode [1,H,W] masks vs video-mode [N,H,W].
**Sources:** creative repo problems-and-solutions glossary §8 + changelog; backlog C-7.
**Targets:** reddit:r/StableDiffusion, linkedin

## [queued] 25-ways-the-audio-stack-install-deviated-from-its-spec
**Angle:** Entry points lie, pin everything, the spec is a hypothesis — a tour of the LESSONS.md genre and why publishing failures beats hiding them.
**Sources:** audio repo LESSONS.md (all); backlog A-1..A-6.
**Targets:** linkedin, reddit:r/LocalLLaMA

## [queued] shipping-a-domain-site-and-offsite-backup-in-one-evening
**Angle:** The small lessons nobody writes down: parking DNS records block custom domains, zone-scoped API tokens can't touch Pages/Workers, storage boxes ship with all access toggles off, restic sftp needs relative paths, and Cloudflare Pages is quietly becoming Workers.
**Sources:** EXECUTION-PLAN 2026-06-11; SITE-DECISIONS.md §8; backlog I-5..I-9.
**Targets:** linkedin, reddit:r/selfhosted

## [queued] killing-the-two-pass-dance
**Angle:** Fitting a 30B multimodal LLM and a TTS engine on one 32GB RTX 5090: six boot attempts, why `gpu-memory-utilization` is a fraction of TOTAL validated against FREE, weights-in-VRAM ≠ checkpoint-on-disk (21.5GiB vs "~18"), and `--max-num-batched-tokens` as the hidden knob nobody mentions (16384→4096 freed the GiBs that utilization tweaking couldn't). Full draft already exists in the repo — bot adapts, not writes from scratch.
**Sources:** comic-manga-narrator docs/BLOG-killing-the-two-pass-dance.md; DEVLOG session 2; backlog P-8.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

## [queued] the-model-echoed-my-prompt-back
**Angle:** A real manga page lost ALL its dialogue because Nemotron returned `"dialogues[]"` — the prompt's array notation — as literal JSON keys, and `.get("dialogues")` silently got nothing. Model output variance as a distribution: same prompt at temp 0.1 produced pixel bboxes, normalized floats, plain keys, bracket keys, and occasionally no JSON at all (json_repair returns a bare string; callers .get() and die). The discipline: normalize at the parse boundary, validate types, retry once per item.
**Sources:** comic-manga-narrator docs/DEVLOG.md sessions 2+5 (bugs 3, 6, 9); docs/LESSONS.md §1-2; backlog P-6, P-7.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn
## [queued] i-benchmarked-open-source-object-removal-for-client-work
**Angle:** E1 bench, honestly scored: VOID removed a person from real footage in 149s on an RTX 5090 (27GB peak) — mid-clip fill statistically as stable as untouched pixels (frame-deltas 7.0-8.0 vs 8.3 control), BUT a partial-removal ghost where the subject crouched, half-resolution output, and a truncated tail. The verdict: not client-deliverable yet, and exactly what to fix next. Numbers, frames, and the scoring method included.
**Sources:** creative repo benchmarks.csv Vanisher row (2026-06-12); EXECUTION-PLAN E1 entry; /tmp/e1-frames methodology (frame-delta vs control region).
**Targets:** linkedin, reddit:r/StableDiffusion, hn

## [queued] the-bug-was-a-zero-size-stack
**Angle:** A Flutter game rendered pure blank — and three sophisticated theories (dual-GPU passthrough, the Flame engine, "X11 screenshots of GL animations lie") were all wrong. The fix was one line: a Stack sizes itself to its largest NON-positioned child, and a conditional `SizedBox.shrink()` overlay collapsed the whole game to 0×0 during play. What found it: replacing the subtree with a red ColoredBox and bisecting — plus a human eyewitness report that falsified the lying-screenshots theory. Debug by bisection, not theory; and when your verification tool might be lying, verify the verifier.
**Sources:** komorebi repo CHANGELOG 1.1.1 + commit 3ed3b9d (regression test); session memory 2026-06-12.
**Targets:** linkedin, reddit:r/FlutterDev, hn

## [queued] i-slept-while-the-llm-shipped-five-releases
**Angle:** "Finish all the phases, I'm going to sleep." Overnight: a pomodoro module, a physics tower game, v1.0 polish with whole-DB export, and an online leaderboard — each phase tested, committed, CI-green before the next began. The honest parts: the safety classifier refused to let the agent install services on production infra unattended (correctly), so the deploy became a script-as-deliverable blessed in the morning; one "lesson" recorded overnight turned out to be wrong and was corrected by daylight. Method post: phase gates, CI as the night watchman, and why autonomy needs refusal points.
**Sources:** komorebi repo commits e3f5998→19ebcd1 + CHANGELOG 0.7.0–1.1.0; server/arena/deploy.sh; session memory.
**Targets:** linkedin, hn

## [queued] multiplayer-without-servers-seed-the-rng-with-the-date
**Angle:** Real-time multiplayer needs WebSockets, state sync, and anti-cheat. A daily duel needs none of it: seed the piece RNG with the UTC date and everyone on Earth stacks the same blocks that day — a leaderboard row is the only network traffic. Fair, async, offline-tolerant competition from one integer. When "play together" actually means "compare honestly," determinism is the whole server.
**Sources:** komorebi lib/services/arena_api.dart (dailyMode/dailySeed) + seed-determinism test; server/arena/README.md modes section.
**Targets:** linkedin, reddit:r/gamedev, hn

## [queued] i-benchmarked-an-ai-avatar-pipeline-end-to-end
**Angle:** E2: photo + script → cloned-voice talking-head video, fully local, in ~5 min (TTS 25s + LatentSync 280s for 34.5s of speech). Gross sync verifiably correct (mouth tracks speech/silence against ffmpeg silencedetect), but lip-interior artifacts kill broadcast close-ups while staying fine for social-format. The honest deliverability line: avatar work is sellable at small format today, not at full-frame.
**Sources:** audio repo benchmarks.md E2 result; outputs/audio/lip-sync/5d4c4fca_lipsync.mp4.
**Targets:** linkedin, reddit:r/LocalLLaMA

## [manual] why-theinvalid-dot-me
**Angle:** The name story — reclaiming the worst insult. Personal; the human writes this one.
**Targets:** linkedin

---

# §B — Lesson & decision backlog (comprehensive, all projects, forever)

Priority: **H** = strong standalone post · **M** = good section/short post ·
**L** = footnote material, fold into related posts.
Status: `unmined` → `queued` (promoted to §A) → `published` (date).

## Sovereign stack (S)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| S-1 | H | iGPU/headless decision: monitor off the 5090 → ~1GB VRAM / ~25K ctx reclaimed | Decision Log §13 | queued (32gb-budget) |
| S-2 | H | Sequential modes: never co-load — purge VRAM, fresh-load per task | §12 | queued (32gb-budget) |
| S-3 | H | NVFP4 over FP8/BF16: the only quant leaving real KV headroom on 32GB | §weights rationale | queued (32gb-budget) |
| S-4 | M | 180K not 256K: leave 25% context headroom, bump only on real errors | §7 | queued (32gb-budget) |
| S-5 | M | FP8 KV cache ≈ free 2× context for description tasks | §8 | queued (32gb-budget) |
| S-6 | M | EVS off for forensic work: 30% slower beats missed details | §9 | unmined |
| S-7 | M | Tiered triage (hero/secondary/category/atmospheric) stops hallucinated enumeration in dense scenes | §10 | unmined |
| S-8 | M | Capture model reasoning traces as provenance for client work | §11 | unmined |
| S-9 | H | TRT-LLM: 8 distinct failures (schema, subcommand, mamba_ssm, CUTLASS, use_cache, HF_HUB_OFFLINE, deps, pixel_values) | §3.1–3.8 | queued (trt-llm post) |
| S-10 | M | KV-cache ceiling: 3–5 concurrent agents max; "60-agent local swarm" claims = serialized or cloud fan-out | v1.4 analysis | unmined |
| S-11 | H | Three profiles, three guarantees; client profile refuses fallback | §Routing | queued (sovereignty post) |
| S-12 | M | Always-on CPU floor (llama.cpp, 60GB RAM): agents survive GPU purges | Phase 4.5 | unmined |
| S-13 | L | llama.cpp builds <9283 lack nemotron_h_moe arch — rebuild after pulls | memory/lessons | unmined |
| S-14 | M | Tool-evaluation checklist; "LLM recommends with zero trade-offs" = red flag | §6, v1.4 | unmined |
| S-15 | L | Keep failed-attempt artifacts on disk deliberately (TRT-LLM dirs) — they're the receipts | §15 | unmined |

## Hermes / LiteLLM / cockpit (H)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| H-1 | M | `fallback_providers` is top-level in profile YAML — nested form silently ignored | memory/litellm-lessons | unmined |
| H-2 | M | Profile-scoped .env pre-empts global .env (HERMES_HOME set before dotenv) | same | unmined |
| H-3 | L | Provider slug `custom` not `openai_compatible` (v0.14 canonical list) | same | unmined |
| H-4 | M | LiteLLM image ignores mounted config without explicit `--config` flag → database-only mode, cryptic 400s | same | unmined |
| H-5 | L | LiteLLM needs both docker networks (postgres bridge + phoenix) for OTEL | same | unmined |
| H-6 | L | Phoenix OTLP = gRPC :4317, not HTTP :4318 | same | unmined |
| H-7 | M | COOKIE_SECURE=0 required for PWA over HTTP-on-tailscale (cookie RFC) | §v1.6.3-1 | unmined |
| H-8 | M | Pin HERMES_DASHBOARD_SESSION_TOKEN or every restart breaks remote pairing | §v1.7-1 | unmined |
| H-9 | L | Port collisions: verify actual ports (DeerFlow :2026 not :3000) before reserving | §v1.6.1-1, §v1.6.4-5 | unmined |
| H-10 | M | Cockpit churn: Aion UI → 3rd-party PWA → official Desktop in 6 weeks — UI layers are the least stable part of the stack | §v1.6-1, §v1.7-1 | unmined |
| H-11 | M | Free-tier cloud cascade (Option B): budget caps + cooldowns make $0 inference reliable | §v1.6.4-2 | unmined |

## Creative stack (C)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| C-1 | H | Wan 2.2 "crystalline shadow": days-long artifact bug = missing two-sampler MoE chain (wiring, not model) | glossary §1 | unmined |
| C-2 | M | FLUX 4B base vs distilled filename trap | glossary §2 | unmined |
| C-3 | H | `docker system prune` deleted the ComfyUI image — prune is not housekeeping when containers are stopped | glossary §3 | unmined |
| C-4 | M | Migrating docker data-root under three live stacks without breaking them | glossary §4 | unmined |
| C-5 | M | Multi-stack boundary discipline: don't nuke the neighbors (shared daemon, shared GPU) | glossary §5 | unmined |
| C-6 | M | Local patches (4× WanVideoWrapper VRAM) must be documented + re-applied after every update | glossary §6 | unmined |
| C-7 | H | SAM3 image-mode vs video-mode masks crashed VACE (tensor dims) | glossary §8 + changelog | queued (sam3 post) |
| C-8 | L | VOID subgraph "Prompt has no outputs" trap | glossary §7 | unmined |
| C-9 | L | VACE color splotches = unconnected mask input | glossary §8 | unmined |
| C-10 | L | flash_attn KeyError was a false alarm — read the actual traceback origin | glossary §9 | unmined |
| C-11 | M | Tool churn (SeedVR2 v2.5, RTX VSR re-eval): re-verify "facts" monthly in fast ecosystems | glossary §10 | unmined |
| C-12 | H | The reframe: client work is video EDITING not generation — changed the whole architecture tier | glossary §11, v1.3 | unmined |
| C-13 | M | An upstream model repo vanished overnight — mirror critical dependencies, check licenses early | v1.5 changelog | unmined |
| C-14 | M | VOID removed the object AND its reflection — capability discoveries belong in test logs | v1.4 notes | unmined |
| C-15 | M | Forensic bridge: dense scene constraints starve diffusion of room to hallucinate | v1.5 bridge files | unmined |

## Audio stack (A) — details in repo LESSONS.md
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| A-1 | H | Entry points lie: 3 of 5 model repos had different real entry points than their README | LESSONS.md | queued (25-ways post) |
| A-2 | M | faster-whisper needs CTranslate2 conversion + preprocessor_config (n_mels silent corruption) | LESSONS.md | queued (25-ways) |
| A-3 | M | Fish Speech pinned to v1.5.1: code and weights must move together | LESSONS.md | queued (25-ways) |
| A-4 | M | Hallo2: six stacked fixes (xformers index, NCCL, GLES symlink, eager attn, output path, right repo org) | LESSONS.md | queued (25-ways) |
| A-5 | M | YuE: LFS pointer stubs from plain git clone; sdpa patch; mono MP3 output | LESSONS.md | queued (25-ways) |
| A-6 | M | RQ pattern: gateway enqueues, separate GPU worker consumes — and the worker needs the full nvidia runtime block | LESSONS.md | queued (25-ways) |

## Infra / ops (I)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| I-1 | H | cron PATH ≠ shell PATH; monitor outcomes not exit codes; heartbeat the watchdog | post live | published 2026-06-10 |
| I-2 | H | Docker bypasses UFW (DOCKER-USER chain fix; verify from untrusted device) | LESSONS.md | queued |
| I-3 | H | Docker data-root move ≠ containerd store move (169GB on /var) | EXECUTION-PLAN | queued |
| I-4 | H | Nightly wheels depreciate; runtime pip installs rot on container recreation | audio LESSONS | queued |
| I-5 | M | Registrar parking DNS records block Cloudflare custom domains | 2026-06-11 | queued (one-evening) |
| I-6 | M | Zone-scoped CF tokens can't manage Workers/Pages (account-level perm) | same | queued (one-evening) |
| I-7 | M | Hetzner Storage Boxes ship with ALL access toggles off — looks like wrong password | same | queued (one-evening) |
| I-8 | L | restic sftp needs relative path on storage boxes (`:./repo` not `:/repo`) | same | queued (one-evening) |
| I-9 | L | Cloudflare Pages → Workers migration: new sites need wrangler.jsonc assets config | same | queued (one-evening) |
| I-10 | L | smartd on Ubuntu: enable error is an alias quirk; real unit is smartmontools.service | 2026-06-10 | unmined |
| I-11 | L | GitHub email-privacy rejects pushes with real email — use the noreply identity from commit #1 | same | unmined |
| I-12 | M | Backup coverage inventory question: "can I re-download this?" — everything answering no goes in | backup.sh history | unmined |
| I-13 | M | Docs referenced a script (agent-mode.sh) that never existed — phantom-reference drift | 2026-06-10 | unmined |
| I-14 | M | GUI mode-picker at login: zenity + autostart beats remembering mode scripts | mode-picker.sh | unmined |

## Products (P) — komorebi, comic narrator, arena
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| P-1 | M | ffmpeg zoompan requires even-aligned dimensions (2.5D parallax gotcha) | comic narrator session | superseded → P-12 |
| P-2 | M | Job-status contract between app and RQ gateway: design the status vocabulary first | comic narrator session | unmined |
| P-3 | M | PocketBase as a one-binary leaderboard backend: anon-create capped + admin-only mutations | komorebi arena deploy | unmined |
| P-4 | L | Fresh VPSes lack unzip — deploy scripts must self-install their tools | arena deploy.sh | unmined |
| P-5 | M | Local-first app + opt-in online features: the sync boundary as a privacy feature | komorebi SPEC | unmined |
| P-6 | H | Models echo prompt notation as literal output keys ("dialogues[]"); normalize at parse, never only at prompt | comic-narrator LESSONS §1, bug 6 | queued (model-echo post) |
| P-7 | M | Model variance is a distribution: coerce geometry, type-check parses (json_repair returns bare strings), retry once per item | LESSONS §2, bugs 3/9 | queued (model-echo post) |
| P-8 | H | vLLM coexistence on 32GB: util = TOTAL-fraction checked vs FREE; weights-in-VRAM ≠ disk; --max-num-batched-tokens is the hidden knob | LESSONS §7-9, BLOG draft | queued (two-pass post) |
| P-9 | H | The model already extracts what the pipeline ignores (tone/pacing/bboxes were dead data for 5 sessions) — immersion gaps are consumer problems | LESSONS §3, §12 | unmined |
| P-10 | M | Forensic soundscape: ambient from what's VISIBLE (cow → moo), per-panel beds, duck under speech — the author drew the sound sources on purpose | DEVLOG sessions 3+5, Track E | unmined |
| P-11 | M | ALL-CAPS lettering is typography, not speech: interjection lexicon for TTS, original lettering for subtitles | LESSONS §13 | unmined |
| P-12 | M | Own your camera math: one Python trajectory consumed by background AND overlay beats reverse-engineering zoompan (incl. its undocumented even-snap) | LESSONS §10, supersedes P-1 | unmined |
| P-13 | M | License-first voice sourcing: emotive corpora are NC; pitch-ladder autocorrelation selects speakers with zero metadata; cloning follows accent AND affect | LESSONS §14-15, VOICES.md | unmined |
| P-14 | M | Voice-actor cloning is a publicity-rights violation; similarity CASTING (acoustic distance over licensed banks) is the legal equivalent | VOICES.md, match-voice.py | unmined |
| P-15 | M | Cast diversity must be explicit: score ties collapsed an entire cast (narrator included) onto dict-order-first | bug 10 + en-parity fix | unmined |
| P-16 | M | Unit tests don't cover seams: a function reduced to return-None passed 24 green tests; the smoke test added after caught a real regression in hours | LESSONS §19-20, bugs 8 | unmined |
| P-17 | L | Common Voice moved to Mozilla Data Collective (Oct 2025): HF repos are stubs, no search API (enumerate sitemap.xml), per-dataset web terms gate, CSV field-limit overflow | DEVLOG session 6 | unmined |
| P-18 | L | concat demuxer wants uniform streams (the establishing shot carries silent AAC for this); alpha intermediates need ProRes4444/VP9 — libx264 cannot | LESSONS §5, §11 | unmined |
| P-19 | H | Flutter Stack sizes to its largest NON-positioned child — a conditional SizedBox.shrink() collapsed a game view to 0×0; red-box bisection beat three days of GPU/engine theories | komorebi 3ed3b9d, CHANGELOG 1.1.1 | queued (zero-size-stack post) |
| P-20 | M | When the verification tool might lie, verify the verifier: blank X11 captures of a live GL window spawned a false lesson; a human eyewitness falsified it — keep eyewitnesses in the loop | komorebi session 2026-06-12 | queued (zero-size-stack post) |
| P-21 | M | drift stream `.first` inside mutations/dialogs deadlocks under widget-test fake-async (bit twice); reads in write paths use one-shot get() | komorebi CHANGELOG 0.3.0 + 0.6.0 fixes | unmined |
| P-22 | H | Date-seeded RNG = async multiplayer with zero realtime infra: same daily piece sequence for everyone, scores compare fairly | komorebi arena_api.dart dailySeed | queued (date-seed post) |
| P-23 | M | Overnight autonomous phases with CI gates; safety classifier correctly refused unattended prod-VPS installs → ship the deploy as an idempotent script to bless in the morning | komorebi overnight run 2026-06-12 | queued (slept-while-shipping post) |
| P-24 | M | GitHub macOS runners give a Linux-only shop continuous iOS/macOS compile verification (free on public repos); signing stays the only Mac-bound step | komorebi ci.yml apple job | unmined |
| P-25 | L | 800MB /tmp: flutter test/build scratch dirs fill it and runs die mid-suite or hang — export TMPDIR to the big disk | komorebi session | unmined |
| P-26 | L | System openjdk was JRE-only → Gradle "toolchain does not provide JAVA_COMPILER"; user-space Temurin JDK + flutter config --jdk-dir fixes without sudo | komorebi android build | unmined |
| P-27 | L | ListView(children:) in bottom sheets is viewport-lazy — scrollUntilVisible before asserting below-the-fold widgets in tests | komorebi widget tests | unmined |
| P-28 | L | Game loops without an engine: event-loop Timer + CustomPainter repaint Listenable beats setState-per-frame from a Ticker (and sidesteps embedder quirks) | komorebi tower_view.dart | unmined |

## Bench & headless-ComfyUI session (E, 2026-06-12)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| E-1 | H | Driving ComfyUI headless via its OWN frontend: TCP proxy + browser preview + `app.loadGraphData()`/`app.queuePrompt()` — sidesteps UI-vs-API JSON formats AND subgraph conversion | this session | unmined |
| E-2 | H | E1 bench results: 149s/27GB person removal, stable fill, t=0.5 ghost, half-res output | benchmarks.csv | queued (bench post) |
| E-3 | M | ComfyUI container doesn't mount input/ — UI-uploaded videos die with container recreation; mount it or docker cp | compose inspection | unmined |
| E-4 | M | creative-mode.sh pointed at a compose dir that never existed — phantom-path drift, found only when actually run | this session | unmined |
| E-5 | M | VOID outputs half-resolution + caps frames — editing tier needs the upscale pass chained for deliverables | E1 bench | unmined |
| E-6 | L | Chrome+extension refused a localhost port that curl could reach — when one client fails, try another before debugging the server | this session | unmined |
| E-7 | H | E1b: ghost root-caused — Vanisher uses image-mode SAM3_Detect (no temporal propagation) so masks drop when subject is occluded; same bug class as the Shapeshifter fix. Frame-cap and fill-prompt fixes verified (6s full duration) | E1b bench 2026-06-12 | unmined |
| E-8 | M | Custom-node updates shift widget order — saved UI workflows silently misalign values into wrong slots (resolution=0); construct API prompts from live /object_info instead | crystalforge debugging | unmined |
| E-9 | M | After restarting ComfyUI, the browser frontend keeps a stale node registry — reload the page or unknown-class nodes serialize without class_type | same | unmined |
| E-10 | M | Runtime-pip-rot case #3: SeedVR2 deps (rotary_embedding_torch, omegaconf) died with container recreation; dry-import loop (import → catch ModuleNotFoundError → pip install → repeat) finds the full set in one pass | same | unmined |
| E-11 | L | The fill prompt said 'empty sidewalk daylight' in a laboratory scene — template prompts left over from other tests quietly degrade results; always read the actual widget values | E1b | unmined |
