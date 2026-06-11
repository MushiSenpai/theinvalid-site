# Blog topic queue — single intake for all projects

Format and rules: see PIPELINE.md. The bot takes the FIRST `[queued]` block,
top to bottom. Append new lessons at the position that matches their priority.

---

## [queued] your-firewall-isnt-protecting-your-docker-containers
**Angle:** Docker silently bypasses UFW for every published port — found because a phone on my own Wi-Fi could open my ComfyUI with zero auth. The DOCKER-USER chain fix, and why you must verify from an untrusted device.
**Sources:** sovereign-ai-stack repo LESSONS.md (Docker bypasses UFW); scripts/harden-docker-firewall.sh; chat 2026-06-10.
**Targets:** linkedin, reddit:r/selfhosted, hn

## [queued] nightly-wheels-are-a-depreciating-asset
**Angle:** Rebuilding a one-month-old Dockerfile failed twice because "install from the nightly index" instructions expire in weeks; the working container had silently drifted to stable torch. Pin what's proven; runtime pip installs rot.
**Sources:** audio-stack repo LESSONS.md ("The June rebuild"); EXECUTION-PLAN B1 entry; worker-pip-freeze-2026-06-10.txt.
**Targets:** linkedin, reddit:r/LocalLLaMA

## [queued] moving-dockers-data-root-doesnt-move-containerd
**Angle:** /var hit 99% weeks after I "moved Docker to the big disk" — because image builds live in containerd's store, which is a different root. How the watchdog caught it, how to find the eater, the migration script.
**Sources:** EXECUTION-PLAN 2026-06-11 entries; scripts/move-containerd-root.sh; chat 2026-06-11.
**Targets:** linkedin, reddit:r/selfhosted, hn

## [queued] six-hours-in-tensorrt-llm-so-you-dont-have-to
**Angle:** TRT-LLM AutoDeploy can't trace multimodal-mandatory models; NVIDIA's own benchmark paper uses vLLM for this model. How to recognize when to stop digging.
**Sources:** sovereign stack doc Decision Log §1–6.
**Targets:** linkedin, reddit:r/LocalLLaMA, hn

## [queued] what-i-designed-in-may-vs-what-shipped-in-june
**Angle:** Open with the AI-generated architecture image (gorgeous, wrong in 7+ places within a month); close with the versioned Mermaid diagram. Plans are hypotheses; diagrams that can't be diffed will drift.
**Sources:** the v1.6.4 image (user's exports); Decision Log §v1.6-1, §v1.7-1; sovereign repo README Mermaid section.
**Targets:** linkedin, hn

## [queued] sovereignty-as-routing-not-policy
**Angle:** Three LLM fallback chains, three guarantees — including the client profile that refuses to fall back, because silent degradation is worse than failure.
**Sources:** sovereign stack doc §Provider Fallback Routing + §Sovereignty Tiers; repo README.
**Targets:** linkedin, reddit:r/selfhosted

## [queued] i-built-a-3-stack-ai-system-without-writing-code
**Angle:** The method post: discuss (multi-LLM) → consolidate → spec → execute (LLM-directed) → verify (gates) → operate. B.E. in CS, reads code, directs rather than writes. The repos are the evidence.
**Sources:** profile README; every repo's "How this was built"; resume.
**Targets:** linkedin, hn

## [queued] the-sam3-mask-that-crashed-vace
**Angle:** A days-long tensor-dimension bug that looked like a model problem and was a wiring problem: image-mode [1,H,W] masks vs video-mode [N,H,W].
**Sources:** creative repo problems-and-solutions glossary; creative doc v1.5.1 changelog.
**Targets:** reddit:r/StableDiffusion, linkedin

## [queued] 25-ways-the-audio-stack-install-deviated-from-its-spec
**Angle:** Entry points lie, pin everything, the spec is a hypothesis — a tour of the LESSONS.md genre and why publishing failures beats hiding them.
**Sources:** audio repo LESSONS.md (all sections).
**Targets:** linkedin, reddit:r/LocalLLaMA

## [queued] shipping-a-domain-site-and-offsite-backup-in-one-evening
**Angle:** The small lessons nobody writes down: parking DNS records block custom domains, zone-scoped API tokens can't touch Pages, storage boxes ship with all access toggles off, and Cloudflare's Pages is quietly becoming Workers.
**Sources:** EXECUTION-PLAN 2026-06-11 entries; theinvalid-site docs/SITE-DECISIONS.md §8.
**Targets:** linkedin, reddit:r/selfhosted

## [manual] why-theinvalid-dot-me
**Angle:** The name story — reclaiming the worst insult. Personal; the human writes this one.
**Sources:** personal.
**Targets:** linkedin (site about-page derivative)
