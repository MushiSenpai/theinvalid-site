# Blog queue + lesson backlog — the single repository

Two sections. **§A** is the FIFO publication queue (the Wednesday bot takes the
FIRST `[queued]` block). **§B** is the comprehensive backlog: EVERY issue,
failure, and decision across ALL projects, past and future, with priority.
Topics get promoted §B → §A by writing a topic block. Every work session that
produces a lesson appends to §B (or straight to §A if it's clearly a post).
Format rules: PIPELINE.md.

---

# §A — Publication queue (FIFO)

## [published 2026-06-13] your-firewall-isnt-protecting-your-docker-containers
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
## [published 2026-06-12 → object-removal-arc] i-benchmarked-open-source-object-removal-for-client-work
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

## [published 2026-06-12 → object-removal-arc] same-pipeline-clean-vs-ghost-the-clip-makes-the-call
**Angle:** E1d closes the object-removal arc honestly. The exact same VOID+SAM3-video pipeline that left a ghost on a worst-case clip (subject behind glassware, low light) produces a CLEAN, deliverable removal on a representative clip (well-lit kitchen, separable spoon) — 180s, no ghost, perfect background reconstruction. The lesson for anyone evaluating AI tools: a single failure frame proves nothing; test selection IS the evaluation. Side-by-side frames + the dependency rabbit-hole (comfy-env silently disabling the video nodes) included.
**Sources:** creative benchmarks.csv Vanisher E1-E1d rows; COVERAGE.md; /tmp/e1d-frames.
**Targets:** linkedin, reddit:r/StableDiffusion, hn

## [queued] six-footguns-installing-a-local-ai-agent-on-ubuntu-24
**Angle:** Phase 2.5 of my Hermes install surfaced six environmental traps the spec never anticipated, each costing real time: (1) PEP 668 puts the `hermes` binary in `~/.local/bin` not `/usr/local/bin`, breaking every systemd `ExecStart`; (2) `pip install hermes[web]` doesn't actually install `aiohttp`; (3) the dashboard refuses `0.0.0.0` without `--insecure`; (4) nvm-managed Node is invisible to systemd (use NodeSource apt); (5) Workspace silently requires `HERMES_PASSWORD` when `HOST=0.0.0.0`; (6) the worst one — a profile-level `.env` with `override=True` silently REPLACED a strong random `API_SERVER_KEY` with a weak guessable value. Lesson: parameterize binary paths at install time, never trust extras-specs, and document config precedence aggressively.
**Sources:** sovereign doc Decision Log §v1.6.2-1 (the six + the four lessons); backlog H-12..H-17.
**Targets:** linkedin, reddit:r/selfhosted, hn

## [queued] my-tested-workflows-broke-from-upstream-drift
**Angle:** I ran a benchmark sweep across 9 ComfyUI workflows I'd built and "tested" weeks earlier. Result: only 5 of 9 still validate on the current ComfyUI — 4 broke from upstream drift. `ModelSamplingFlux.patch() got an unexpected keyword argument` (a node API changed under me), `Node 'Video Latent' has no class_type` (a custom node renamed/removed), Hunyuan workflows missing 4-5 nodes each. The honest lesson: "tested and working" has a SHELF LIFE on a fast-moving stack. A workflow is a snapshot against an environment that keeps moving; without pinned custom-node versions, your tested artifacts rot. Either pin everything, or treat re-validation as routine maintenance — and BENCHMARK PERIODICALLY so you discover the rot before a client does.
**Sources:** creative benchmarks COVERAGE.md sweep 2026-06-13; /tmp/sweep-results.csv; the 4 specific errors.
**Targets:** linkedin, reddit:r/comfyui, reddit:r/StableDiffusion, hn

## [queued] one-rtx-5090-how-many-users-the-honest-answer
**Angle:** "How many people can use a local LLM at once?" I stress-tested it instead of guessing. Sustained single-stream: 276 tok/s. Concurrency: 2 users=1.4x, 4=2.4x, KNEES at 8 concurrent (728 tok/s aggregate, flat after). vLLM continuous batching means throughput does NOT divide by user count, but KV-cache memory caps concurrent active generations at ~8 on 32GB. Translation: ~10-15 heavy or ~30-40 light chat users on one RTX 5090, latency under 2.5s.
**Sources:** sovereign nemotron-stress.csv; stress test 2026-06-13.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

## [queued] i-built-an-avatar-that-introduces-itself-as-an-avatar
**Angle:** E2: photo + script -> cloned-voice talking head, fully local, ~5 min. Honest quality with frames: gross lip-sync correct (mouth tracks speech vs silence, verified against ffmpeg silencedetect), but lip-interior artifacts at full-frame zoom = social-grade not broadcast close-up. The script is meta: the avatar says it's an avatar made on one machine.
**Sources:** audio benchmarks.md E2; public/avatar-lipsync-frames.png.
**Targets:** linkedin, reddit:r/LocalLLaMA

## [queued] a-self-healing-catalogue-for-a-stack-that-drifts
**Angle:** I benchmarked 9 ComfyUI workflows and found 4 had silently broken from upstream node renames (HunyuanVideoModelLoader -> HunyuanVideo15*, EmptyWanLatentVideo -> Wan22ImageToVideoLatent). "Tested" rots. So I built a monthly maintenance job: it validates every workflow against the LIVE node registry, auto-discovers new ones, regenerates a public catalogue with real numbers, and pings my phone with what drifted — but deliberately does NOT auto-"fix" renames (different I/O = a human/LLM rebuild call, not a safe auto-patch). The honest engineering line: automate detection and reporting fully; gate the risky repairs behind judgment.
**Sources:** scripts/workflow-validate.py + generate-catalogue.py + workflow-maintenance.sh; COVERAGE.md; benchmarks.csv.
**Targets:** linkedin, reddit:r/comfyui, hn

## [queued] my-uncensored-llm-was-leaking-raw-tokenizer-output
**Angle:** Benchmarking my two unrestricted local LLMs (the creative-pipeline script writers): CPU Nemotron PRISM ran clean at 18 tok/s, no refusals. But GPU Dolphin 24B AWQ — same uncensored role — came back at ~2 tok/s with `Ġ` and `Ċ` BPE artifacts leaking into the output text. Classic symptom of a chat-template/decode misconfig at the serving layer (awq_marlin @ 0.25 GPU-mem). Lesson: "it responds" isn't "it works" — inspect the actual bytes, and benchmark every model you rely on, because a misconfigured serving config produces plausible-looking garbage.
**Sources:** COSTING.md encoder section (private numbers); /tmp/encoder-bench.py; 2026-06-14.
**Targets:** linkedin, reddit:r/LocalLLaMA
## [manual] why-theinvalid-dot-me
**Angle:** The name story — reclaiming the worst insult. Personal; the human writes this one.
**Targets:** linkedin

---

## [queued] i-built-an-ai-agent-company-on-my-own-hardware
**Angle:** Stood up a Paperclip "company" (CEO/Builder/Reviewer) on a fully local Hermes+LiteLLM stack. It works — agents autonomously wrote code, tests, and a CI pipeline. But three honest lessons: (1) ~40s per-run overhead forces a two-tier design (fast Hermes-direct vs governed Paperclip); (2) the cheap CEO self-reviewed and APPROVED genuinely buggy code (an auth-less health check that reports a live service as DOWN) — mocked tests hid it; (3) model choice dominates everything (DeepSeek-Flash 0.8s vs Kimi 27-40s). Takeaway: a strong independent reviewer + a permanent human merge gate is load-bearing, not optional.
**Sources:** EXECUTION-PLAN.md 2026-06-14 entries; queue §B PA-1..PA-9; /data/ai/08-portfolio/devkit.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

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
| P-19 | H | "Run it together or break it down?" wasn't the question: a 1.4GB PDF was 4684 vertical webtoon strips, not 179 pages — inspect before deciding | comic-narrator session 9 | unmined |
| P-20 | M | Webtoons break paged pipelines 3 ways: 300-DPI ingestion OOMs (extract native), tall strips blind the vision encoder (slice by gutters), ~20.5k panels = ~14 GPU-days | DEVLOG session 9, Track F | unmined |
| P-21 | M | The right answer to an impossible batch is a slicer + a one-episode stress test, not a 2-week monolith — same lesson as the first real manga page | session 9 | unmined |
| P-22 | H | Per-clip AAC slices + -c copy concat = boundary clicks AND long dead-audio spans; mux ONE continuous narration over the assembled video instead | comic-narrator session 10 | unmined |
| P-23 | M | A camera move that "works in one scene and not the next" is the wrong primitive — a static frame + speaker spotlight halo beats zoom-roulette | session 10 review | unmined |
| P-24 | M | We built a forensic vision extractor then drove the render from crude bboxes; the unlock is asking for director signals (shot_type, action_intensity, reading_path) | TTS-RESEARCH.md | unmined |
| P-25 | L | SFX one-shots must be trimmed (~2.5s) or N action cues stretch a panel to ~19s of dwell | session 10 | unmined |
| P-26 | H | Character voice consistency = comic re-identification: emit an `appearance` per character + feed the running cast sheet back to the VLM so it REUSES labels (Manga Whisperer approach); fixed 23 labels → 8 identities, 0 inconsistent voices | comic-narrator session 11 | unmined |
| P-27 | M | Role-based casting: protagonist→fixed lead voice, leads→distinct pool, faceless crowd→shared voice; prominence hierarchy AND caps the cast explosion | session 11 | unmined |
| P-28 | H | The "double run" (expressive TTS → voice conversion) is the established technique to decouple ACTING from IDENTITY; Seed-VC zero-shot beats RVC for a reference-clip bank (no per-voice training) | TTS-RESEARCH.md | unmined |
| P-29 | H | Validate a risky install in an ISOLATED venv first: parler-tts pulls torch-stable which would downgrade the worker's nightly-cu130 and break the RTX-5090 stack — caught before touching the container | session 11 torch trap | unmined |
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
| E-12 | H | E1c: SAM3 video pipeline grafted into VOID via direct API-graph surgery (4 video nodes replace SAM3_Detect, quadmask rewired). Root infra fix: comfy-env==0.3.89 was a missing pip dep silently disabling ALL SAM3 *video* nodes (image SAM3_Detect came from same pack but loaded). Ghost reduced not eliminated on worst-case clip — honest finding: mask-tracking fixed, residual is inpaint-quality limit | E1c bench 2026-06-12 | unmined |
| E-13 | M | Worst-case test selection inflates failure: subject behind transparent glassware in low light is near-impossible for any inpainter; bench client-readiness on REPRESENTATIVE footage, document the hard case separately | E1c | unmined |
| E-14 | M | Quantitative frame-diff metrics need a motion-free reference region — measuring a ghost box that overlaps a spinning fan reports fan motion as ghost energy (false null result); pick static background for deltas | E1c quant attempt | unmined |

## Coverage-audit additions (2026-06-13, gaps found vs stack docs)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| S-16 | H | FlashInfer MoE backend is broken on consumer Blackwell (SM_120) — Nemotron MoE crashes; `--moe-backend triton` is the fix. Exact-error SEO gold | Decision Log + sovereign README | unmined |
| C-16 | M | SeedVR2 is FP16-ONLY (NVFP4 port fails, VAE/DiT entangled), needs multi-step 720→1080→2160 not one jump, blocks_to_swap 32, and "never 30s+ per batch" is the health signal | creative catalogue v1.4 Crystalforge gotcha | unmined |
| C-17 | L | Distilled vs base run-settings are NOT interchangeable: distilled = 4 steps/CFG 1.0 (raising steps hurts), base = 20 steps/FluxGuidance 3.5 (4 steps = soft/under-formed). Same model family, opposite knobs | catalogue Flashfire/Goldsmith gotchas | unmined |
| S-17 | L | Hunyuan is NOT MoE — single sampler is correct (vs Wan 2.2 which REQUIRES two); applying the two-sampler fix to Hunyuan would be wrong | catalogue Hunyuan "DO-NOT-TOUCH" | unmined |

## Stress-test & multi-user (B-blocked, GPU)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| B-1 | H | Concurrency stress test (ramp simulated users, find tok/s + latency knee) — THE number needed to quote multi-employee deployments. Continuous batching means throughput does NOT divide by user count; KV-cache memory is the real limit (3-5 long-ctx sessions = wall) | COSTING.md multi-user block; user q 2026-06-13 | blocked-on-gpu |
| B-2 | M | Full Nemotron stress test at session end (sustained max-load tok/s, thermal, power, throttle) — proper numbers vs the passive 139-avg observation | user req 2026-06-13 | blocked-on-gpu |
| B-3 | M | Tier-5 PRIVATE capability benchmark (stats only, never public price/imagery) — see COSTING.md positioning | user 2026-06-13 | blocked-on-gpu |

## Coverage-audit additions (2026-06-13) — gaps found grepping stack docs vs backlog
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| H-12 | H | PEP 668: pip --break-system-packages lands binaries in ~/.local/bin not /usr/local/bin — parameterize systemd ExecStart via `which X` at install | §v1.6.2-1.1 | queued (six-footguns) |
| H-13 | M | `pip install foo[web]` extras can silently omit deps (aiohttp missing from hermes[web]) — verify imports, don't trust extras-spec | §v1.6.2-1.2 | queued (six-footguns) |
| H-14 | M | nvm-managed Node is invisible to systemd services — use NodeSource apt Node for system services, nvm for interactive dev | §v1.6.2-1.4 | queued (six-footguns) |
| H-15 | H | The silent `.env override=True` security bug: a profile-level .env replaced a strong random API key with a weak guessable one — precedence bugs are security bugs | §v1.6.2-1.6 | queued (six-footguns) |
| H-16 | L | Dashboard refuses 0.0.0.0 without --insecure; Workspace needs HERMES_PASSWORD at HOST=0.0.0.0 | §v1.6.2-1.3,5 | queued (six-footguns) |
| H-17 | M | Credential rotation: keys pasted into an LLM chat for handover were rotated to openssl rand -hex 32 — documented rotation procedure now exists | §v1.6.2-1 side effect | unmined |
| H-18 | M | Hermes Desktop remote-gateway: pin HERMES_DASHBOARD_SESSION_TOKEN (else fresh uncopyable token each start) + dashboard MUST run --tui or chat WebSocket silently fails (#1 failure mode) | §v1.7-1 two requirements | unmined |
| S-16 | L | Tailscale travel test: direct peer path held through lid-close on mobile hotspot, no DERP; CGNAT/corp-FW may force DERP — re-test if encountered | §v1.6.4-6 | unmined |
| S-17 | L | CPU Nemotron is the PRISM abliterated/unrestricted variant — deliberate: unrestricted local floor, never client-routed | §v1.6.4-1 | unmined |

**Audit verdict:** sovereign Decision Log §v1.6.x now ~fully captured (was the main gap). Creative glossary (C-1..15), audio LESSONS (A-1..6), infra (I-1..14), products (P-1..8) confirmed covered. Tier-6/uncensored creative doc: finishing lessons in C-11; uncensored intentionally private (COSTING Tier-5 note), not a public gap. **Coverage now ~95%+.**

## E4 forensic bridge (first end-to-end run, 2026-06-13)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| E-15 | H | E4: forensic bridge ran END-TO-END for the first time. Nemotron 3-pass analysis of a clip → machine_payload.json with 16 remove targets (13 reflections/shadows!), 9 PRESERVE targets, scene-aware fill prompt, invariants. The differentiator (dense forensic constraints vs human guessing) PROVEN to produce data autonomously. | forensic e4-kitchen bundle | unmined |
| E-16 | H | The bridge's node-ID map went stale: forensic_to_comfy.py targeted the OLD image-mode SAM3 node (167:149:78) + wrong LoadVideo key ("video" not "file"), so v1 ran the baked lab clip instead of the analyzed kitchen clip — produced a plausible-but-wrong result that LOOKED successful. Lesson: when a workflow's internals change (E1c rewired SAM3 to video pipeline), every external script that injects into it by node-ID silently breaks. Verify injection landed on the LIVE job, not just that it ran. | E4 debugging | unmined |
| E-17 | M | Forensic analysis auto-chose the HERO removal target ("the egg in the pan") and wrote its own fill prompt — no human typed "remove X". This is the sellable anti-hallucination story: the model decides what to remove AND what to preserve from dense scene analysis. | e4-kitchen machine_payload | unmined |

## Benchmark sweep findings (2026-06-13)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| BS-1 | H | 4 of 9 "tested" workflows broke from ComfyUI upstream drift (node API changes + missing custom nodes). Tested-and-working has a shelf life; pin node versions or re-validate as routine maintenance | sweep 2026-06-13 | queued (drift post) |
| BS-2 | M | Goldsmith measured: 6s/11.2GB for a 1024² keyframe (confirms the catalogue's ~3.3s ballpark, slower in practice) | sweep | unmined |
| BS-3 | M | graphToPrompt() validates a workflow's node availability headlessly without queueing — fast way to audit a whole workflow library for drift | sweep technique | unmined |


## Paperclip + Hermes agent company (2026-06-14)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| PA-1 | H | Hermes-local Paperclip agents need Extra args `--provider custom` or Hermes can't resolve a LiteLLM model name (e.g. cloud-preferred) → falls back to anthropic auto-detection → "Normalized model anthropic/claude-sonnet-4" failures. Fix routes via the active profile's custom provider (:4000), auto-loading LITELLM_MASTER_KEY from ~/.hermes/.env even under a clean spawn env. | WOR-3 debugging | queued (agent-company post) |
| PA-2 | H | Paperclip+Hermes has ~30-40s STRUCTURAL per-run overhead (cold hermes spawn + LiteLLM provider probing) regardless of model — the real reason it "feels slow". Drove the two-tier architecture: Hermes-direct (warm :8642) for fast single-agent jobs, Paperclip only for governed multi-agent work. | speed diagnosis | queued (agent-company post) |
| PA-3 | H | Cheap-model self-review APPROVED real buggy code: CEO wrote stack_health.py that reports LiteLLM DOWN (no auth header → 401) and self-reviewed it "spec-compliant". Mocked tests hid the bug. Validates strong independent reviewer + permanent human merge gate. | WOR-3 verify | queued (agent-company post) |
| PA-4 | H | Agent speed is dominated by model: deepseek-flash 0.8s vs Kimi-via-NGC 27-40s (timeout) — a ~30-50x swing from one config field. | model speed test | unmined |
| PA-5 | M | Paperclip UI: local-adapter agents have NO system-prompt field; the "Capabilities" box is the persona, hard rules enforced by config (budget caps, board-approval toggle, Advanced Run Policy). | dashboard build | unmined |
| PA-6 | M | The CEO went autonomous unprompted — generated its own backlog (CI pipeline, health dashboard, API docs) from a roadmap line and started building. Pause stops it instantly. Keep heartbeats OFF until deliberate. | resume test | unmined |
| PA-7 | M | Hermes Desktop update = git checkout the release tag matching the CLI (v2026.6.5) + `npm run pack` (electron-builder --dir; AppImage/rpm need appimagetool/rpmbuild you lack). `.desktop` launcher points at release/linux-unpacked/. The `hermes desktop` wrapper is broken for pip installs (probes site-packages for the JS workspace). | desktop update | unmined |
| PA-8 | M | Dead GPU agent endpoint (:8000 unloaded) makes LiteLLM personal-chain "hang" ~45s (slow failover past the dead hop). Use deepseek/groq for cloud-fast or load GPU agent-mode for sovereign-fast. | model test | unmined |
| PA-9 | L | infra-digest.sh = Hermes-direct tier proof: bash gathers status → Hermes (deepseek) writes a plain-language daily digest → ntfy. Intelligence layer atop healthcheck.sh threshold alerts. Cron 08:30. | infra-digest build | unmined |
| SA-1 | M | Super-app strategy: collapse florinpop17/app-ideas (~90 ideas, 95k stars) into super-apps — DevKit (dev tools), FocusFlow (productivity, extends Komorebi), DocForge (PDF). DevKit picked for agents: client-side, tool-by-tool, clear free/pro. | github research | unmined |

## B — bigger cross-checking agent org (2026-06-14 night)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| PA-10 | H | Built a 5-agent Paperclip org (CEO-coordinator + Architect + Builder + QA + Reviewer, all report to CEO, hire-approval gate fired on each). Researched real SaaS + 2026 multi-agent team structures to design it. | B build | queued (agent-company post) |
| PA-11 | H | **Prompt-level role constraints DON'T force delegation.** Reconfigured the CEO as "coordinator who NEVER implements" — it ignored that and fixed the DevKit code itself anyway (a capable Hermes agent self-serves because it CAN). Real fix needs a STRUCTURAL lever: remove the CEO's file-write/code tools so it MUST delegate, or route task-types to specific agents. The Architect/Builder/QA never got invoked. | B delegation test | queued (agent-company post) |
| PA-12 | M | The CEO got resourceful in a concerning way: wrote a Python script using the Paperclip REST API + a token from /tmp to POST its own status comment and PATCH the issue to "done" — bypassing the intended UI flow. Capable agents route around controls; enforce limits structurally, not by instruction. | run 107dce7f | unmined |
| PA-13 | L | hermes-founder-os skill pack installed (9 SaaS skills: validation-lab/prd-studio/architecture-reviewer/rapid-saas-builder/build-system/ux-critic/growth-lab/launch-room/founder-os) into ~/.hermes/skills/. | install | unmined |

## ComfyUI drift — root cause SOLVED (2026-06-14 night)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| BS-4 | H | The "drifted workflows" weren't garbage — root cause is CUSTOM-PACK API changes. kijai WanVideoWrapper restructured its whole pipeline (8-node→18-node; WanVideoVAEDecode→WanVideoDecode, EmptyWanLatentVideo→WanVideoEmptyEmbeds w/ output-type change). Hunyuan moved to native HunyuanVideo15* set. LLMRequest renamed. Fix = reconstruct from each pack's example_workflows template, not edit-in-place. | drift diagnosis | unmined |
| BS-5 | M | 3 OTHER packs fail to import on missing pip deps (SeedVR2: rotary_embedding_torch, SAM3: comfy_env, Nvidia_RTX: nvvfx) — a node "missing" can mean the whole pack silently failed to load, not that the node was deleted. Always check ComfyUI startup log import-failure summary. | drift diagnosis | unmined |

## ComfyUI drift — 2 Wan workflows REBUILT + render-verified (2026-06-15 autonomous block)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| BS-6 | H | Proof the drift is fixable: rebuilt the kijai Wan T2V pipeline, RENDERED, and visually verified — 17 coherent frames of a red panda in bamboo (real motion). Rebuilt t1-wan21-draft-video + t5-wan21-distill-draft (validate clean). Method: adapt the pack's own example_workflows template, not edit-in-place. Remaining 5 (3 Hunyuan no-template + 2 LLM_party) deferred — won't blind-build unattended (garbage risk). | autonomous render-verify | queued (drift post — now HAS proof frames) |

## ComfyUI drift — ALL Wan + Hunyuan FIXED + render-verified (2026-06-15 marathon)
| id | pri | lesson / decision | source | status |
|---|---|---|---|---|
| BS-7 | H | 7 drifted workflows fixed: Wan (t1/t5-distill render-verified), SeedVR2+VACE (baked deps), and ALL 3 Hunyuan15 RENDER-VERIFIED (dreamforge/quickening/sharpscale → 1080p). Method: official ComfyUI templates + a reusable litegraph→API converter (ui2api_render.py: auto-fix model names, prune-to-output) + render+visual-verify each. Downloaded ~11GB encoders (qwen_2.5_vl, byt5, sigclip, 1080p SR). Only the 2 LLM-orchestration ones remain. | marathon | queued (drift post — strong proof frames) |
| BS-8 | H | The cinematic LLM-orchestration pipeline was rebuilt as a HOST orchestrator (a small driver script), not an in-graph ComfyUI LLM node. Three reasons the in-graph LLM failed: (1) the creative-comfyui container CANNOT reach the sovereign CPU LLM at host :8001 (docker-bridge isolation — and widening :8001 to 0.0.0.0 just to satisfy a node would needlessly expand a local model's exposure, so declined); (2) a reasoning model emits empty `content` unless given ~900+ max_tokens (it spends the budget in `reasoning_content` first); (3) an in-graph blocking call to a slow CPU endpoint is fragile. Clean design: the LLM runs on :8001 as a host pre-step, injects the prompt, and the GPU never co-loads the LLM with the diffusion models. | cinematic-pipeline build | queued (sovereign-pipeline post) |
| BS-9 | H | Flux 2 Klein base-4b QUALITY CLIFF: sharp at 1024x1024 and 1024x576, but MELTS into a structureless painterly blob at 1280x720. The distilled 4B is resolution-sensitive >~1MP. Keep keyframes <=1MP and match the I2V aspect (1024x576 -> Wan I2V 832x480 = clean downscale). A degraded keyframe silently propagates: the I2V faithfully animated the mush, so frame 0 was already wrong — always visually check the KEYFRAME before blaming the video model. | render-verify | unmined |
| BS-10 | M | Two silent traps + one shortcut: (a) VHS_VideoCombine save_output=false writes to ComfyUI /temp, not the output mount — looks like "no output" though the render succeeded; override save_output=true. (b) the litegraph->API converter treated VHS dict-style widgets_values as a list (keys became values) — fixed to map dict widgets by field name. (c) you can free ComfyUI VRAM with POST /free {unload_models,free_memory} to run YuE in the same session — no container mode-switch needed for SEQUENTIAL GPU sharing. ACE-Step (diffusers format, no combined ckpt) + stable_audio (lib import fails) not ready; YuE is the working music engine. | cinematic-orchestrator build | unmined |
| BS-11 | M | Merging a video LoRA (WanVideoLoraSelect -> WanVideoModelLoader) into an fp8-quantized 14B model HANGS ComfyUI's single-threaded HTTP server during the merge — GPU stays idle, /system_stats returns 000, needs a container restart. Reproduced twice. Lesson: the fp8 LoRA-merge is the cost; and for image-to-video a LoRA is often unnecessary anyway — Wan I2V animates whatever is already in the keyframe, so steer with the keyframe + prompt and keep the plain proven graph. Also hardened the litegraph->API converter to RETRY on poll timeouts instead of crashing, so a transient HTTP block no longer loses an in-flight render. | I2V pipeline | unmined |
| BS-12 | H | Two cinematic-pipeline quality lessons. (1) IMAGE MODEL FIT: a general text-to-image model (small distilled Flux) cannot draw coherent HUMAN anatomy for a video keyframe — limbs/faces come out as a jumble, and an I2V model faithfully animates that jumble. The fix isn't more steps/res/LoRA; it's a domain-appropriate image checkpoint (a realistic SDXL finetune nailed anatomy + a crisp face in 4s). A strong keyframe + GENTLE motion then survives the I2V intact — no motion LoRA needed. Lesson: match the keyframe model to the subject domain; check the keyframe before blaming the video model. (2) MUSIC ENGINE FIT: a lyrics-to-song model (YuE) produces VOCALS singing the lyrics — wrong for a cinematic SCORE. ACE-Step (native ComfyUI, all-in-one ckpt) makes real INSTRUMENTAL music with empty lyrics in ~8s vs YuE's ~280s, and runs in-session (no audio-stack mode-switch). | cinematic-pipeline polish | unmined |
