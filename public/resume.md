# MADHAN KUMAR REDDY

**AI Infrastructure Operator** — I spec, direct LLMs, and verify.

Singapore | +65 8179 6884 | reddy.madhankumar.sg@gmail.com
**Portfolio:** [theinvalid.me](https://theinvalid.me) | **GitHub:** [github.com/MushiSenpai](https://github.com/MushiSenpai) | **LinkedIn:** [linkedin.com/in/reddymk](https://www.linkedin.com/in/reddymk/)

---

## HOW I WORK — READ THIS FIRST

I don't hand-write production code, and I won't pretend otherwise. I have a B.E. in Computer Science — I read code fluently — but every system below was built by directing LLMs (Claude primarily; Gemini, Grok, and Kimi as a consultation council) against specifications I author. My work is everything around the code: architecture, tool evaluation, spec writing, debugging direction, verification gates, and day-2 operations. The proof is public: three documented repositories where the method, the failures, and the fixes are all visible.

If your role requires hand-written algorithms on a whiteboard, I'm the wrong hire — this paragraph just saved us both an interview. If your role requires someone who can take an idea to a running, secured, monitored system and operate it honestly, keep reading.

---

## SUMMARY

Ten+ years across quality control, security governance (GRC), and client services — now applied to designing and operating **sovereign, self-hosted AI infrastructure**. Built and daily-operate a three-stack AI system on dedicated hardware (RTX 5090 32GB, 128GB DDR5, Ubuntu 24.04): multimodal LLM serving, generative video production, and a full local audio pipeline — all documented publicly with benchmarks and failure logs. Based in Singapore; **available for project-based travel** to client facilities, data centres, and secure sites worldwide.

---

## SELECTED WORK — public, verifiable, operating daily

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

### My infrastructure ships products

**Comic Narrator** → [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator)
A comic page goes in; a dramatized video comes out — panel detection (vision LLM + OpenCV), cloned character voices acting the dialogue, narrator on captions, Ken Burns + 2.5D parallax camera. Built entirely on the three stacks above — the proof the infrastructure isn't shelf-ware.

**Komorebi** → [github.com/MushiSenpai/komorebi](https://github.com/MushiSenpai/komorebi)
A Studio Ghibli-inspired productivity suite in Flutter (tasks, kanban, calendar, notes, pomodoro, and a physics tower-stacking break game with online leaderboards). Local-first SQLite; built with the same spec-driven, phase-gated method — visible in its public phase table.

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
- **AI Data Curation & Localization roles** — built on the 36-language QC instincts

Fast learner, comfortable in roles I haven't done before; equally at home as a one-person operation or inside a team. **Open to international project-to-project travel.**

---

## WORK PASS

Indian National | Singapore Dependent Pass (DP) | Employer sponsorship required

---

*Everything above is verifiable: the repositories are public, the benchmarks are committed weekly, and the failure logs are part of the documentation — not hidden from it.*
