# MADHAN KUMAR REDDY

**On-Premises AI Solutions Engineer · Sovereign / Self-Hosted LLM Deployment.** I spec, direct LLMs, and verify.

Singapore | +65 8179 6884 | reddy.madhankumar.sg@gmail.com
[theinvalid.me](https://theinvalid.me) | [github.com/MushiSenpai](https://github.com/MushiSenpai) | [huggingface.co/MushiSenpai](https://huggingface.co/MushiSenpai) | [linkedin.com/in/reddymk](https://www.linkedin.com/in/reddymk/)

## SUMMARY

I design, deploy and operate **private, on-premises AI systems** on hardware the client controls: local LLM serving, private document search (RAG), and multi-model pipelines where data never leaves the building. I work spec-first: I write the architecture and specs, direct LLMs to implement them, and verify with benchmarks and gates. My own estate runs on one RTX 5090: four inference stacks (LLM, video, audio, 3D), a control plane that time-shares the card, and the products on top, all documented in public with the failures left in. B.E. Computer Science; about seven years in quality control, security governance and client services.

**Core:** vLLM · llama.cpp · LiteLLM · RAG (BGE-M3, Qdrant, reranking) · evaluation & benchmarking · Docker · FastAPI · Python · Linux · security governance

## SELECTED WORK (public, measured)

**SovereignSec-AI: air-gapped code-security auditor** · [repo](https://github.com/MushiSenpai/SovereignSec-AI-Auditor)\
Cross-file taint analysis + SAST + an LLM. Scores **0.97 vs 0.90 for the LLM alone** on a 29-module, 6-CWE benchmark; runs with no GPU and `--network=none`. Measured that fine-tuning adds ~0 detection (7B and 32B QLoRA adapters published with honest model cards).

**Sovereign AI Stack: a private LLM that can't leak** · [repo](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack)\
Privacy enforced by routing: the client profile refuses to fall back to cloud. **275 tok/s** single-stream, **728 tok/s across 8 concurrent users**, 180K context on one RTX 5090. Full decision log, including six hours of TensorRT-LLM that ended in choosing vLLM.

**Sovereign Legal RAG: private document search for legal teams** · [public results](https://github.com/MushiSenpai/sovereign-legal-rag-results)\
Hybrid retrieval with reranking, pinpoint citations, matter-level ethical walls, hash-chained audit log, zero egress. On 150 questions over real contracts: **MRR 0.564 vs 0.434** for semantic-only search.

**Conductor: one control plane for a one-GPU estate** · [project page](https://theinvalid.me/projects/conductor)\
One job API, one VRAM-lease scheduler and one trace/cost plane over four stacks. **20 live GPU switches, 0 failures.**

**QLAB: honest quantum-ML lab** · [repo](https://github.com/MushiSenpai/qlab)\
Eleven experiments, each against a classical baseline, two on real quantum hardware (IBM, IonQ). Reproduced a published quantum advantage, then erased it three ways.

**Also:** a 3D asset pipeline whose compliance gate refuses bad models, local video and voice stacks, a comic-to-video app, and newer private builds (security audit, trading research, a film studio). All at [theinvalid.me/projects](https://theinvalid.me/projects).

## EXPERIENCE

**Shop Assistant**, Indian mini-mart, Singapore (Sep 2026 – present)\
Run the shop floor end to end: cashier and till, stocking, supplier orders, and whatever manual work the day needs. The AI work above continues alongside it.

**Open-Source Contributor**, AI/ML infrastructure projects, remote (Jun 2026 – present)\
13 upstream pull requests to tools I run (qdrant-client, colpali, YuE, PyDriller, trimesh, FlagEmbedding, whisperX, fish-speech, MuseTalk, xFormers and others), 5 merged. Each came from a real bug I hit and root-caused.

**IT Security Governance Analyst**, Merck Sigma-Aldrich, India (Feb – Jul 2017)\
GRC team: authored Standard Operating Procedures from security requirements; compliance documentation and policy rollout.

**Client Services Executive**, Sandpaper Creative Solutions, India (May 2016 – Feb 2017)\
Sole link between clients and the creative team: turned requirements into briefs and held scope.

**Search Analyst**, Yahoo, India (Dec 2009 – Jul 2013)\
Premium advertiser accounts for the US sales team; high-volume accuracy and quality targets.

**Quality Control Editor**, Deluxe DigiCaptions, India (Mar – Nov 2009)\
Subtitle QC across **36 languages** for Universal, Fox, Paramount and Warner.

**Co-Founder**, Teragreen Studios, India (Jul 2007 – Dec 2008)\
Web and graphic design studio; client coordination and delivery.

*Career breaks 2014–2016 and 2017–2023 (recovery, family). Cybersecurity bootcamp and self-study 2023–2024.*

## EDUCATION

**B.E. Computer Science**, Visvesvaraya Technological University (RNSIT), India, 2003–2007 · **ThinkCyber Cybersecurity Bootcamp**, 2023–2024 · TryHackMe and Hack The Box, ongoing

## WORK PASS & AVAILABILITY

Indian National | Singapore Dependant's Pass with a DP-linked Work Permit for my current employer; a new Singapore employer applies for its own pass. Open to remote contract work for overseas clients and project-based travel.

*Full résumé, with every project and all 13 pull requests linked: [theinvalid.me/resume](https://theinvalid.me/resume)*
