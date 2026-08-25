# MADHAN KUMAR REDDY

**On-Premises AI Solutions Engineer · Sovereign / Self-Hosted LLM Deployment** — I spec, direct LLMs, and verify.

Singapore | +65 8179 6884 | reddy.madhankumar.sg@gmail.com
**Portfolio:** [theinvalid.me](https://theinvalid.me) | **GitHub:** [github.com/MushiSenpai](https://github.com/MushiSenpai) | **HuggingFace:** [huggingface.co/MushiSenpai](https://huggingface.co/MushiSenpai) | **LinkedIn:** [linkedin.com/in/reddymk](https://www.linkedin.com/in/reddymk/)

---

## HOW I WORK — READ THIS FIRST

I work spec-first: I author the architecture and specifications, direct LLMs (Claude primarily; Gemini / Grok / Kimi / DeepSeek as a review council) to implement against them, and verify the result with benchmarks and gates. B.E. Computer Science — I read code fluently and own the parts that decide whether a system is trustworthy: design, tool evaluation, verification, and day-2 operations. The proof is public: documented repositories where the method, the failures, and the fixes are all visible.

If a role needs hand-written algorithms on a whiteboard, I'm not the fit — this paragraph just saved us both an interview. If it needs someone who takes an idea to a running, secured, monitored, honestly-operated system, keep reading.

---

## SUMMARY

AI infrastructure engineer who designs, deploys, and operates **sovereign, on-premises LLM systems** on hardware the client controls — private RAG, local serving (vLLM), multi-agent pipelines, air-gapped where data never leaves the building. Ten+ years in quality control, security governance (GRC), and client services, now applied to **daily-operating** a documented three-stack AI system on a single RTX 5090 (32GB, 128GB DDR5, Ubuntu 24.04). Based in Singapore; **available for project-based travel** to client facilities, data centres, and secure sites worldwide.

**Core:** Retrieval-Augmented Generation (RAG) · LLM serving (vLLM, llama.cpp, LiteLLM) · multi-agent / tool use · on-prem & air-gapped deployment · Docker · FastAPI · Python · Linux · security governance.

---

## SKILLS

- **LLM & AI serving:** vLLM, Nemotron (NVFP4), llama.cpp, LiteLLM, OpenAI-compatible endpoints, quantization, GPU inference (RTX 5090 / Blackwell), KV-cache tuning
- **RAG & retrieval:** BGE-M3 (dense + sparse), Qdrant, hybrid retrieval + reciprocal rank fusion, cross-encoder reranking, OCR ingestion, evaluation (recall@k / MRR / faithfulness)
- **Multimodal:** ComfyUI, FLUX.2, Wan 2.2, HunyuanVideo, SAM3 / VACE, vision-LLM analysis, voice cloning / TTS / lip-sync
- **Infrastructure & ops:** Docker, FastAPI, Redis/RQ, Ubuntu, systemd, UFW, Tailscale, restic (3-2-1 backups), monitoring & alerting, VRAM lifecycle orchestration
- **Languages:** Python, Bash, Dart / Flutter
- **Security / GRC:** SOP authoring, access-control / ethical-wall design, audit logging

---

## SELECTED WORK — public, verifiable, operating daily

### SovereignSec-AI — Air-Gapped Code-Security Auditor → [github.com/MushiSenpai/SovereignSec-AI-Auditor](https://github.com/MushiSenpai/SovereignSec-AI-Auditor)
A fully air-gapped AI code-security auditor for codebases that can't leave the network: **cross-file taint analysis + SAST + an LLM, hybridized**, finding vulnerabilities across files and returning deterministic, proof-carrying findings.
- **0.97** on a hard 29-module / 6-CWE benchmark vs **0.90** for an LLM alone — the system beats the model; high-confidence findings carry `✔ PROVEN (taint)` evidence to triage first
- Rigorously measured that **fine-tuning adds ~0 detection capability** (its real value is output schema + calibration) — the clean measurement caught **4 of my own eval bugs**; capability lives in the architecture, not the fine-tune
- Trained **7B and 32B QLoRA adapters on a single RTX 5090**, published with honest model cards: [HF 7B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-7B) · [HF 32B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-32B)
- Deterministic core runs with **no GPU and `--network=none`** (Docker) — air-gapped by construction; licensing constraints (CodeQL/Semgrep-Pro) drove the architecture, not the other way around

### Sovereign AI Stack → [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack)
Self-hosted multimodal LLM infrastructure with **routing-enforced privacy**: three fallback chains where "client data never touches a cloud API" is guaranteed by architecture, not policy — including a client profile that refuses to fall back, because failing loudly beats degrading silently.
- vLLM + Nemotron NVFP4 on RTX 5090: **275 tok/s measured**, 180K context at FP8 KV cache, ~28–30GB of a 32GB budget — including disconnecting the display to onboard graphics to reclaim VRAM for inference
- Always-on CPU fallback (llama.cpp, 60GB of system RAM) so agents survive GPU mode-switches
- Cloud budget layer (LiteLLM) cascading across free-tier providers under zero-budget constraints
- Full Decision Log published — including six hours of TensorRT-LLM debugging that ended in choosing vLLM, and why

### Creative Stack → [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack)
Local AI video production: generation (FLUX.2, Wan 2.2, HunyuanVideo), editing (object removal that takes the object *and its reflection*; SAM3+VACE masked edits), finishing (60fps interpolation, 4K upscale).
- **Anti-hallucination by design:** a "forensic mode" multimodal analysis pass produces dense scene constraints *before* any diffusion model runs — the generator gets specifications to obey, not space to confabulate
- Six named, tested workflows shipped as importable JSON; a days-long SAM3 tensor-dimension bug and its fix documented in a public problems-and-solutions glossary
- VRAM lifecycle orchestration: stateful mode-switch scripts stop containers, flush GPU memory, and hot-swap stacks on a 32GB budget

### Audio Stack → [github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack)
Fully local voice cloning, TTS, lip-sync avatars (three quality tiers), music generation, and auto-dubbing — job-queue architecture (FastAPI + Redis/RQ), every model MIT/Apache-2.0.
- End-to-end avatar pipeline: photo + voice sample → cleaned clone → narration → lip-synced MP4
- **25+ documented install lessons** — every deviation between spec and working system, published so others don't pay the same cost
- Verified rebuildable: fresh containers pass an end-to-end music-generation job with zero manual intervention

### Sovereign Legal RAG → *private repo — live walkthrough on request*
Private document intelligence for legal teams — production-grade retrieval, grounded answers with **pinpoint citations**, and a system that **refuses rather than invents**.
- Multi-mode retrieval fused: BGE-M3 dense + sparse + cross-encoder rerank over Qdrant; side-by-side mode comparison in the UI
- Matter-level **ethical walls** + append-only, hash-chained **audit log**; embeddings/reranker on CPU so they never contend with the serving GPU
- **Measured:** labeled CUAD eval (recall@k / MRR / faithfulness), failures kept in; passed an adversarial multi-agent code audit (4 high-severity defects found + fixed)

### My infrastructure ships products

**Comic Narrator** → [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator)
A comic page goes in; a dramatized video comes out — panel detection (vision LLM + OpenCV), cloned character voices acting the dialogue, narrator on captions, Ken Burns + 2.5D parallax camera. Built entirely on the three stacks above — the proof the infrastructure isn't shelf-ware.

**Komorebi** → [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi)
A Studio Ghibli-inspired productivity suite in Flutter (tasks, kanban, calendar, notes, pomodoro, and a physics tower-stacking break game with online leaderboards). Local-first SQLite; built with the same spec-driven, phase-gated method — visible in its public phase table.

---

<!-- oss-auto:start -->
## OPEN-SOURCE CONTRIBUTIONS — 2 merged

Upstream fixes submitted to the tools I run in production — each links to the live PR.

- **FlagEmbedding** (BGE-M3 / bge-reranker-v2-m3) — [#1584](https://github.com/FlagOpen/FlagEmbedding/pull/1584): `device=` was silently swallowed by `**kwargs`, loading the reranker across every visible GPU (OOM); aliased it to `devices=` with a regression test.
- **qdrant-client** — [#1247](https://github.com/qdrant/qdrant-client/pull/1247) (merged): local mode runs exact search, so `search_params` is ignored — but silently, making `exact=True` look like a no-op. Added a one-time warning + batch-path coverage + regression tests.
- **whisperX** — [#1442](https://github.com/m-bain/whisperX/pull/1442): a chunk mis-detected as a language with no alignment model crashed the *entire* transcription; made it warn and keep the segment-level result. Validated on real audio with a same-clip before/after.
- **ComfyUI-WanVideoWrapper** — [#2041](https://github.com/kijai/ComfyUI-WanVideoWrapper/pull/2041): the VRAM-management node wrapped meta-device tensors before materializing them → `Cannot copy out of meta tensor` crash on no-LoRA VACE; materialize-before-wrap fix, validated end-to-end on a Wan-VACE run (live before/after traceback).
- **MuseTalk** — [#419](https://github.com/TMElyralab/MuseTalk/pull/419), [#420](https://github.com/TMElyralab/MuseTalk/pull/420): a PyTorch 2.6 `weights_only` crash on the legacy face-parse checkpoints; an `UnboundLocalError` on image input — two clean, low-risk fixes.
- **fish-speech** — [#1303](https://github.com/fishaudio/fish-speech/pull/1303), [#1304](https://github.com/fishaudio/fish-speech/pull/1304): empty TTS text returned an HTTP 500 (which streaming clients wrote as a `.wav`); constrained the request schema to reject it with a clean 4xx (Fixes #946); `pyaudio`'s hard PortAudio build dependency broke every headless / slim / API-only install; moved it to an optional `[client]` extra.
- **colpali** (vision-document retrieval) — [#418](https://github.com/illuin-tech/colpali/pull/418) (merged): wired `fast-plaid` in as the `plaid` optional dependency — the maintainer-requested integration (#335) that a previous volunteer had left stalled.
- **YuE** (music generation) — [#153](https://github.com/multimodal-art-projection/YuE/pull/153): the documented `git clone` of the codec checkpoints silently yields ~133-byte LFS pointer stubs when git-lfs is missing or the HF bandwidth quota is hit; added an `hf download` fallback + a stub warning (#118).
<!-- oss-auto:end -->

---

## OPERATIONS DISCIPLINE — the unglamorous part, done properly

- **Monitored backups, not hopeful ones:** discovered my own restic backup had been failing silently for 2.5 weeks (cron PATH bug); fixed it, then built a watchdog that checks *outcomes* (snapshot age, both local and offsite repos) and pushes phone alerts. The watchdog caught a disk-capacity issue on its first day.
- **3-2-1 backups:** local restic repo + encrypted offsite (Hetzner Storage Box) + originals
- **Network discipline:** default-deny UFW, Tailscale-only service exposure, and the DOCKER-USER iptables fix for the documented gap where Docker bypasses UFW — verified from an untrusted device, not assumed
- **Spec-driven, gate-verified:** every build phase has a written spec and a verification gate; snapshots before changes; status tracked in one place

---

## EARLIER EXPERIENCE

**IT Security Governance Analyst** — Merck Sigma-Aldrich, Singapore (Feb–Jul 2017)
Part of the GRC team authoring Standard Operating Procedures from security requirements across operational teams; compliance documentation and policy rollout in a multinational environment. *(The skill that became agent guardrails and sovereignty-tier rules.)*

**Client Services Executive** — Sandpaper Creative Solutions (May 2016 – Feb 2017)
Sole point of contact between clients and the creative team at a small advertising agency: extracted requirements, translated them into briefs, shielded the team from scope churn. *(The skill that became spec-writing for AI execution.)*

**Search Analyst** — Yahoo, Singapore (Dec 2009 – Jul 2013)
Supported premium advertiser accounts for the US sales team; high-volume accuracy and quality benchmarks in a KPI-driven environment.

**Quality Control Editor** — Deluxe DigiCaptions (Mar–Nov 2009)
Subtitle QC across **36 foreign languages** for Universal, Fox, Paramount, and Warner: spotting cross-language inconsistencies and negotiating corrections with translators worldwide. *(The skill that became multi-pass output validation of AI pipelines.)*

**Co-Founder** — Teragreen Studios (Jul 2007 – Dec 2008)
Web and graphic design services; client coordination and delivery for a small studio.

---

## CAREER BREAKS — stated plainly

Two intentional breaks (2014–2016, 2017–2023): recovery from burnout, care for a newborn, building a family property, and supporting my spouse's career. The later years included structured cybersecurity self-study (ThinkCyber bootcamp; ongoing TryHackMe / Hack The Box practice) — the Linux fluency from that period is the direct foundation of everything in Selected Work.

---

## EDUCATION & SELF-STUDY

- **B.E. Computer Science** — Visvesvaraya Technological University (RNSIT), India, 2003–2007
- **M.Tech Cyber Forensics** — PESIT, India *(incomplete)*
- **ThinkCyber Cybersecurity Bootcamp** (2023–2024): Linux fundamentals, Python for automation, network research, penetration testing basics
- Continuous: TryHackMe & Hack The Box labs; vLLM/ComfyUI/inference documentation in practice

---

## TARGET ROLES

- **Field AI Deployment Specialist / On-Premises AI Solutions Engineer** — deploying local models inside client facilities where data cannot leave the building (this is literally what my home lab practices daily)
- **AI Implementation Consultant / Solutions Delivery Manager** — translating messy client requirements into rigid specs for AI execution
- **Sovereign AI Infrastructure Planner** — self-hosted, private-network, open-weight deployments
- **AI Data Curation & Localization** — the same cross-language error-spotting I did on 36 languages of studio subtitles at Deluxe, applied to AI training-data quality

Fast learner, comfortable in roles I haven't done before; equally at home as a one-person operation or inside a team. **Open to international project-to-project travel.**

---

## WORK PASS & AVAILABILITY

Indian National | Singapore Dependant's Pass (DP). **Authorized for remote contract work with overseas clients** — no sponsorship needed for remote engagements; Singapore on-site employment requires employer sponsorship (EP). **Open to project-based travel** to client facilities and secure sites worldwide.

---

*Everything above is verifiable: the repositories are public, the benchmarks are committed weekly, and the failure logs are part of the documentation — not hidden from it.*
