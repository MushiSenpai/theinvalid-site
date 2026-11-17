# MADHAN KUMAR REDDY

**On-Premises AI Solutions Engineer · Sovereign / Self-Hosted LLM Deployment.** I spec, direct LLMs, and verify.

Singapore | +65 8179 6884 | reddy.madhankumar.sg@gmail.com
**Portfolio:** [theinvalid.me](https://theinvalid.me) | **GitHub:** [github.com/MushiSenpai](https://github.com/MushiSenpai) | **HuggingFace:** [huggingface.co/MushiSenpai](https://huggingface.co/MushiSenpai) | **LinkedIn:** [linkedin.com/in/reddymk](https://www.linkedin.com/in/reddymk/)

---

## HOW I WORK: READ THIS FIRST

I work spec-first: I author the architecture and specifications, direct LLMs (Claude primarily; Gemini / Grok / Kimi / DeepSeek as a review council) to implement against them, and verify the result with benchmarks and gates. B.E. Computer Science. I read code fluently and own the parts that decide whether a system is trustworthy: design, tool evaluation, verification, and day-2 operations. The proof is public: documented repositories where the method, the failures, and the fixes are all visible.

If a role needs hand-written algorithms on a whiteboard, I'm not the fit, and this paragraph just saved us both an interview. If it needs someone who takes an idea to a running, secured, monitored, honestly-operated system, keep reading.

---

## SUMMARY

AI infrastructure engineer who designs, deploys, and operates **sovereign, on-premises LLM systems** on hardware the client controls: private RAG, local serving (vLLM), multi-agent pipelines, air-gapped where data never leaves the building. Ten+ years in quality control, security governance (GRC), and client services, now applied to operating a documented AI estate on a single RTX 5090 (32GB, 128GB DDR5, Ubuntu 24.04): **four inference stacks** (LLM, video, audio, 3D), **one control plane** that time-shares the card between them, and the products built on top. Based in Singapore; **available for project-based travel** to client facilities, data centres, and secure sites worldwide.

**Core:** Retrieval-Augmented Generation (RAG) · LLM serving (vLLM, llama.cpp, LiteLLM) · GPU scheduling on constrained hardware · multi-agent / tool use · evaluation and benchmarking · on-prem & air-gapped deployment · Docker · FastAPI · Python · Linux · security governance.

---

## SKILLS

- **LLM & AI serving:** vLLM, Nemotron (NVFP4), llama.cpp, LiteLLM, OpenAI-compatible endpoints, quantization, GPU inference (RTX 5090 / Blackwell), KV-cache tuning, QLoRA fine-tuning
- **RAG & retrieval:** BGE-M3 (dense + sparse), Qdrant, hybrid retrieval + reciprocal rank fusion, cross-encoder reranking, OCR ingestion, evaluation (recall@k / MRR / faithfulness)
- **Evaluation & verification:** benchmark design with mandatory baselines, leak-resistant eval corpora, property-based testing (Hypothesis), calibration scoring (Brier / ECE), phase gates
- **Platform & orchestration:** single-GPU VRAM-lease scheduling, DAG job chains, OpenTelemetry tracing (Phoenix), cost ledgers, Redis/RQ job queues
- **Security:** cross-file taint analysis (tree-sitter), Semgrep OSS, SARIF, OWASP LLM Top-10 (2025) review of agent apps, SOP authoring, access-control / ethical-wall design, hash-chained audit logging
- **Multimodal & 3D:** ComfyUI, FLUX.2, Wan 2.2, HunyuanVideo, SAM3 / VACE, vision-LLM analysis, voice cloning / TTS / lip-sync, TRELLIS.2 / Hunyuan3D, headless Blender mesh-ops
- **Data & graph:** PostgreSQL, pgvector, Apache AGE (graph), DuckDB, DVC, provenance and licence ledgers
- **Infrastructure & ops:** Docker, FastAPI, Ubuntu, systemd, UFW, Tailscale, restic (3-2-1 backups), monitoring & alerting
- **Quantum ML (assessment):** PennyLane, Qiskit, runs on IBM Quantum and IonQ hardware, always against classical baselines
- **Languages:** Python, Bash, Dart / Flutter, Kotlin (Compose Multiplatform, Android)

---

## SELECTED WORK: public, verifiable, measured

### SovereignSec-AI: Air-Gapped Code-Security Auditor → [github.com/MushiSenpai/SovereignSec-AI-Auditor](https://github.com/MushiSenpai/SovereignSec-AI-Auditor)
A fully air-gapped AI code-security auditor for codebases that can't leave the network: **cross-file taint analysis + SAST + an LLM, hybridized**, finding vulnerabilities across files and returning deterministic, proof-carrying findings.
- **0.97** on a hard 29-module / 6-CWE benchmark vs **0.90** for an LLM alone: the system beats the model; high-confidence findings carry `✔ PROVEN (taint)` evidence to triage first
- Rigorously measured that **fine-tuning adds ~0 detection capability** (its real value is output schema + calibration). The clean measurement caught **4 of my own eval bugs**; capability lives in the architecture, not the fine-tune
- Trained **7B and 32B QLoRA adapters on a single RTX 5090**, published with honest model cards: [HF 7B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-7B) · [HF 32B](https://huggingface.co/MushiSenpai/SovereignSec-Auditor-LoRA-Qwen2.5-Coder-32B)
- Deterministic core runs with **no GPU and `--network=none`** (Docker), air-gapped by construction; licensing constraints (CodeQL/Semgrep-Pro) drove the architecture, not the other way around

### Sovereign AI Stack → [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack)
Self-hosted multimodal LLM infrastructure with **routing-enforced privacy**: three fallback chains where "client data never touches a cloud API" is guaranteed by architecture, not policy, including a client profile that refuses to fall back, because failing loudly beats degrading silently.
- vLLM + Nemotron NVFP4 on RTX 5090: **275 tok/s measured**, 180K context at FP8 KV cache, ~28–30GB of a 32GB budget, including moving the display to onboard graphics to reclaim VRAM for inference
- Concurrency measured, not assumed: aggregate throughput climbs to **728 tok/s at 8 concurrent users**, then flattens when the KV cache fills
- Always-on CPU fallback (llama.cpp, 60GB of system RAM) so agents survive GPU mode-switches
- Cloud budget layer (LiteLLM) cascading across free-tier providers under zero-budget constraints
- Full Decision Log published, including six hours of TensorRT-LLM debugging that ended in choosing vLLM, and why

### Conductor: one control plane for a one-GPU estate → *private repo, [project page](https://theinvalid.me/projects/conductor)*
One job API, one VRAM-lease scheduler and one trace/cost plane over four independently built inference stacks that share a single RTX 5090. Temporal GPU scheduling (one heavy tenant at a time: use, flush, load) where most tooling only offers multi-GPU sharing.
- **Cross-modal chains:** one declarative job runs LLM, TTS and lip-sync steps as a validated DAG, each output wired into the next **by code, never by a model**; one trace id spans both stacks and one cost ledger prices tokens and GPU-seconds
- **Measured:** 20 scripted live profile switches, **0 failures, 0 refusals**; cold load of the heavy LLM tenant 75.8–89.2 s at ~26.3 GB peak, the cost the scheduler batches around

### Sovereign Legal RAG → [public results: github.com/MushiSenpai/sovereign-legal-rag-results](https://github.com/MushiSenpai/sovereign-legal-rag-results) *(engine private, live walkthrough on request)*
Private document intelligence for legal teams: production-grade retrieval, grounded answers with **pinpoint citations**, and a system that **refuses rather than invents**.
- Multi-mode retrieval fused: BGE-M3 dense + sparse + cross-encoder rerank over Qdrant; side-by-side mode comparison in the UI
- **Measured on 150 CUAD clause questions:** hybrid + rerank MRR **0.564** / R@1 **0.44**, vs 0.434 / 0.31 for semantic-only search, the usual "chat with your PDFs" recipe and the weakest mode on legal text
- Matter-level **ethical walls** + append-only, hash-chained **audit log**; embeddings/reranker on CPU so they never contend with the serving GPU; passed an adversarial multi-agent code audit (4 high-severity defects found + fixed)

### QLAB: Honest Quantum-ML Lab → [github.com/MushiSenpai/qlab](https://github.com/MushiSenpai/qlab) · [case study](https://theinvalid.me/case-studies-honest-qml-lab/)
A feasibility lab with one rule: a quantum number is never shown without its classical baseline. Eleven experiments, two runs on real quantum hardware (IBM superconducting, IonQ trapped-ion), zero manufactured wins.
- Reproduced a published quantum advantage (0.900 vs a weak classical 0.730), then **erased it three ways**: a fairly tuned classical model (0.910), classical dequantization (0.900), and device noise
- Measured a barren plateau collapsing gradient variance **1,436×**, and hit the 32GB statevector wall at 30 qubits. The deliverable is judgment a buyer can trust, not hype

### 3D Stack → [github.com/MushiSenpai/mushishi-3d-stack](https://github.com/MushiSenpai/mushishi-3d-stack)
One product photo in; a spec-checked, marketplace-ready 3D asset and a machine-generated compliance report out: local generation (TRELLIS.2 / Hunyuan3D), headless-Blender retopology, UV, PBR bake and real-world rescale, then a gate that **refuses** assets failing the published spec.
- Real five-SKU batch on one shared card: three passed, **one refused, one flagged with the exact miss** (703 mm reconstructed vs 650 mm listed). Stopping the bad asset is the product
- Two licence lanes enforced in the pipeline: an MIT path that ships worldwide and a premium tier withheld from regions the upstream model licence excludes

### Creative Stack → [github.com/MushiSenpai/mushishi-creative-stack](https://github.com/MushiSenpai/mushishi-creative-stack)
Local AI video production: generation (FLUX.2, Wan 2.2, HunyuanVideo), editing (object removal that takes the object *and its reflection*; SAM3+VACE masked edits), finishing (60fps interpolation, 4K upscale).
- **Anti-hallucination by design:** a "forensic mode" multimodal analysis pass produces dense scene constraints *before* any diffusion model runs, so the generator gets specifications to obey, not space to confabulate
- Named, tested workflows shipped as importable JSON, re-validated monthly against upstream drift; a days-long SAM3 tensor-dimension bug and its fix documented in a public problems-and-solutions glossary

### Audio Stack → [github.com/MushiSenpai/mushishi-audio-stack](https://github.com/MushiSenpai/mushishi-audio-stack)
Fully local voice cloning, TTS, lip-sync avatars (three quality tiers), music generation, and auto-dubbing on a job-queue architecture (FastAPI + Redis/RQ), every model MIT/Apache-2.0.
- End-to-end avatar pipeline: photo + voice sample → cleaned clone → narration → lip-synced MP4, benchmarked per tier
- **25+ documented install lessons**: every deviation between spec and working system, published so others don't pay the same cost

### My infrastructure ships products

**Comic Narrator** → [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator)
A comic page goes in; a dramatized video comes out: panel detection (vision LLM + OpenCV), cloned character voices acting the dialogue, narrator on captions, Ken Burns + 2.5D parallax camera. Seven tagged releases, each carrying its demo video. Built entirely on the stacks above, which is the proof the infrastructure isn't shelf-ware.

**Komorebi** → [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi)
A Studio Ghibli-inspired productivity suite in Flutter (tasks, kanban, calendar, notes, pomodoro, and a physics tower-stacking break game with online leaderboards). Local-first SQLite; built with the same spec-driven, phase-gated method, visible in its public phase table.

### In progress and planned: private repos, public write-ups

Newer builds whose code stays private (security, commercial, or my own data). Each has a page with the numbers and the failures at [theinvalid.me/projects](https://theinvalid.me/projects).

- **UTSUSHIE (local AI film studio):** script to keyframes to video to voices to mix on one RTX 5090 that also runs a daily-driver LLM. Models chosen per stage by same-seed A/B; a deterministic prompt compiler took the style pass from **6/18 to 18/18**; the renderer waits for any GPU holder it does not own instead of crashing it
- **KARIBUSA (estate ledger):** one canonical status file for 20+ tracks, a dashboard that renders it against the plan and the live machine and flags drift; shipped after a fail-open bug served sample data as truth
- **KOUJOU (software dark factory):** frontier models write and judge specs, a local model does the volume, and a scripted scorecard plus a frozen eval set make "which local model?" a monthly keep-or-replace decision; the auditor is deliberately a different model family

- **BHAIRAVA (security audit orchestration):** variant engine, sandboxed proof capsules, signed SARIF, and OWASP LLM Top-10 detectors for agent apps. Published its own losses: **0 of 12** recall on in-scope post-cutoff Django CVEs with the root cause named; one real CVE verified end to end; 0 high-severity false positives on the clean-control gate
- **GINKO (trading intelligence):** shadow predictions scored on an append-only, hash-chained ledger (Brier / ECE); LLMs may not calculate, every number carries row-level provenance; **zero live orders by design** until calibration passes
- **TANYUU (OSINT substrate):** bitemporal knowledge graph on Postgres + Apache AGE with evidence on every claim; analyst portal ships as one self-contained, no-egress HTML file
- **ADASHINO (fitness planner):** deterministic solver owns the numbers, the LLM is only the conversational shell; safety invariants property-tested at 10,000 examples each
- **ISAZA (Mizo ↔ English translation):** a licence audit found the standard low-resource models are non-commercial, so the stack runs two tracks that never share weights, enforced by a build-failing licence gate
- **VISHWAKARMA (robotics):** software gate before any hardware purchase; simulation and dataset round-trip running headless, 43 tests green
- **Planned, not built:** NAVARATNA (a routed pool of specialist local models, sticky per session, borrowing the GPU only when idle) and CHAKRAVYUHA (an isolated security testing lab on its own hosts and network segment, tools pinned by a re-runnable manifest)

---

<!-- oss-auto:start -->
## OPEN-SOURCE CONTRIBUTIONS — 5 merged

Upstream fixes submitted to the tools I run in production — each links to the live PR.

- **FlagEmbedding** (BGE-M3 / bge-reranker-v2-m3) — [#1584](https://github.com/FlagOpen/FlagEmbedding/pull/1584): `device=` was silently swallowed by `**kwargs`, loading the reranker across every visible GPU (OOM); aliased it to `devices=` with a regression test.
- **qdrant-client** — [#1247](https://github.com/qdrant/qdrant-client/pull/1247) (merged): local mode runs exact search, so `search_params` is ignored — but silently, making `exact=True` look like a no-op. Added a one-time warning + batch-path coverage + regression tests.
- **whisperX** — [#1442](https://github.com/m-bain/whisperX/pull/1442): a chunk mis-detected as a language with no alignment model crashed the *entire* transcription; made it warn and keep the segment-level result. Validated on real audio with a same-clip before/after.
- **ComfyUI-WanVideoWrapper** — [#2041](https://github.com/kijai/ComfyUI-WanVideoWrapper/pull/2041): the VRAM-management node wrapped meta-device tensors before materializing them → `Cannot copy out of meta tensor` crash on no-LoRA VACE; materialize-before-wrap fix, validated end-to-end on a Wan-VACE run (live before/after traceback).
- **MuseTalk** — [#419](https://github.com/TMElyralab/MuseTalk/pull/419), [#420](https://github.com/TMElyralab/MuseTalk/pull/420): a PyTorch 2.6 `weights_only` crash on the legacy face-parse checkpoints; an `UnboundLocalError` on image input — two clean, low-risk fixes.
- **fish-speech** — [#1303](https://github.com/fishaudio/fish-speech/pull/1303), [#1304](https://github.com/fishaudio/fish-speech/pull/1304): empty TTS text returned an HTTP 500 (which streaming clients wrote as a `.wav`); constrained the request schema to reject it with a clean 4xx (Fixes #946); `pyaudio`'s hard PortAudio build dependency broke every headless / slim / API-only install; moved it to an optional `[client]` extra.
- **colpali** (vision-document retrieval) — [#418](https://github.com/illuin-tech/colpali/pull/418) (merged): wired `fast-plaid` in as the `plaid` optional dependency — the maintainer-requested integration (#335) that a previous volunteer had left stalled.
- **YuE** (music generation) — [#153](https://github.com/multimodal-art-projection/YuE/pull/153) (merged): the documented `git clone` of the codec checkpoints silently yields ~133-byte LFS pointer stubs when git-lfs is missing or the HF bandwidth quota is hit; added an `hf download` fallback + a stub warning (#118).
- **PyDriller** (git repository mining) — [#326](https://github.com/ishepard/pydriller/pull/326) (merged): on a shallow clone (`--depth 1`, the `actions/checkout` default) the missing parent made `modified_files` die with a bare `exit code(128)` naming neither the cause nor the fix; it now warns on open and raises an actionable `ShallowRepositoryError`, with a depth-1 regression test (Fixes #229, open since 2022).
- **trimesh** (3D mesh processing) — [#2605](https://github.com/mikedh/trimesh/pull/2605) (merged): `simplify_quadric_decimation(percent=)` is forwarded as `target_reduction`, so it is the fraction of faces REMOVED, not kept, and the docstring stopped mid-sentence — the inversion silently returned 8 triangles for a 1200-face target in my 3D pipeline; completed the description with measured numbers (0.9 keeps 510 of 5120 faces).
- **xFormers** (attention kernels) — [#1411](https://github.com/facebookresearch/xformers/pull/1411): the README's development-binaries install omits the `--index-url` the stable block treats as essential, so `pip install --pre -U xformers` resolves from PyPI and can install a wheel built for a different CUDA version over a cuda-specific or nightly PyTorch — on Blackwell that surfaced as an NCCL ABI crash at import, not an install error; documented the failure mode and the matching nightly-index form.
<!-- oss-auto:end -->

---

## OPERATIONS DISCIPLINE: the unglamorous part, done properly

- **Monitored backups, not hopeful ones:** discovered my own restic backup had been failing silently for 2.5 weeks (cron PATH bug); fixed it, then built a watchdog that checks *outcomes* (snapshot age, both local and offsite repos) and pushes phone alerts. The watchdog caught a disk-capacity issue on its first day.
- **3-2-1 backups:** local restic repo + encrypted offsite (Hetzner Storage Box) + originals
- **Network discipline:** default-deny UFW, Tailscale-only service exposure, and the DOCKER-USER iptables fix for the documented gap where Docker bypasses UFW, verified from an untrusted device, not assumed
- **Spec-driven, gate-verified:** every build phase has a written spec and a verification gate; snapshots before changes
- **One source of truth for status:** a single ledger for 20+ tracks with drift detection between what the plan says and what is running; a GPU mode switch that refuses to evict a model mid-request

---

## EXPERIENCE

**Open-Source Contributor**, upstream AI/ML infrastructure projects, remote (Jun 2026 – present)
Submitted 13 upstream pull requests to widely-used AI and developer tooling I run in production (qdrant-client, colpali, YuE, FlagEmbedding, whisperX, ComfyUI-WanVideoWrapper, fish-speech, MuseTalk, PyDriller, trimesh, xFormers), 5 merged as of 2026-09-26. Every fix came from a real production bug I hit and root-caused, with a regression test or a documented before/after reproduction. Links to every PR are in the open-source section above.

**IT Security Governance Analyst**, Merck Sigma-Aldrich, India (Feb–Jul 2017)
Part of the GRC team authoring Standard Operating Procedures from security requirements across operational teams; compliance documentation and policy rollout in a multinational environment. *(The skill that became agent guardrails and sovereignty-tier rules.)*

**Client Services Executive**, Sandpaper Creative Solutions, India (May 2016 – Feb 2017)
Sole point of contact between clients and the creative team at a small advertising agency: extracted requirements, translated them into briefs, shielded the team from scope churn. *(The skill that became spec-writing for AI execution.)*

**Search Analyst**, Yahoo, India (Dec 2009 – Jul 2013)
Supported premium advertiser accounts for the US sales team; high-volume accuracy and quality benchmarks in a KPI-driven environment.

**Quality Control Editor**, Deluxe DigiCaptions, India (Mar–Nov 2009)
Subtitle QC across **36 foreign languages** for Universal, Fox, Paramount, and Warner: spotting cross-language inconsistencies and negotiating corrections with translators worldwide. *(The skill that became multi-pass output validation of AI pipelines.)*

**Co-Founder**, Teragreen Studios, India (Jul 2007 – Dec 2008)
Web and graphic design services; client coordination and delivery for a small studio.

---

## CAREER BREAKS: stated plainly

Two intentional breaks (2014–2016, 2017–2023): recovery from burnout, care for a newborn, building a family property, and supporting my spouse's career. The later years included structured cybersecurity self-study (ThinkCyber bootcamp; ongoing TryHackMe / Hack The Box practice); the Linux fluency from that period is the direct foundation of everything in Selected Work.

---

## EDUCATION & SELF-STUDY

- **B.E. Computer Science**, Visvesvaraya Technological University (RNSIT), India, 2003–2007
- **M.Tech Cyber Forensics**, PESIT, India *(incomplete)*
- **ThinkCyber Cybersecurity Bootcamp** (2023–2024): Linux fundamentals, Python for automation, network research, penetration testing basics
- Continuous: TryHackMe & Hack The Box labs; vLLM/ComfyUI/inference documentation in practice

---

## TARGET ROLES

- **Field AI Deployment Specialist / On-Premises AI Solutions Engineer:** deploying local models inside client facilities where data cannot leave the building (this is literally what my home lab practices daily)
- **AI Implementation Consultant / Solutions Delivery Manager:** translating messy client requirements into rigid specs for AI execution
- **Sovereign AI Infrastructure Planner:** self-hosted, private-network, open-weight deployments
- **AI Data Curation & Localization:** the same cross-language error-spotting I did on 36 languages of studio subtitles at Deluxe, applied to AI training-data quality

Fast learner, comfortable in roles I haven't done before; equally at home as a one-person operation or inside a team. **Open to international project-to-project travel.**

---

## WORK PASS & AVAILABILITY

Indian National | Singapore Dependant's Pass (DP). **Authorized for remote contract work with overseas clients:** no sponsorship needed for remote engagements; Singapore on-site employment requires employer sponsorship (EP). **Open to project-based travel** to client facilities and secure sites worldwide.

---

*Everything above is verifiable: the repositories are public unless marked private, the benchmarks are committed next to the code, and the failure logs are part of the documentation, not hidden from it.*
