#!/bin/bash
# make-stack-briefs.sh — regenerate public/briefs/*.pdf (one-page stack briefs).
# Print-friendly styling matching make-resume-pdf.sh. All numbers are measured
# runs already published on the site/repos — update here when benchmarks move.
# Run: bash scripts/make-stack-briefs.sh   (requires google-chrome)
set -e
cd "$(dirname "$0")/.."
mkdir -p public/briefs

CSS='<style>
  body { font-family: -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
         font-size: 10pt; line-height: 1.42; color: #1a1a1a;
         max-width: 7.3in; margin: 0 auto; }
  h1 { font-size: 17pt; margin: 0 0 1pt; }
  .sub { color: #555; margin: 0 0 8pt; font-size: 10.5pt; }
  h2 { font-size: 11.5pt; border-bottom: 1.5pt solid #c8901f; padding-bottom: 2pt;
       margin: 11pt 0 5pt; }
  table { border-collapse: collapse; width: 100%; font-size: 9.5pt; margin: 4pt 0; }
  th, td { text-align: left; padding: 3pt 6pt; border-bottom: 0.5pt solid #ddd; }
  th { font-size: 8.5pt; text-transform: uppercase; letter-spacing: 0.05em; color: #666; }
  td.num { font-family: ui-monospace, Menlo, Consolas, monospace; white-space: nowrap; }
  ul { margin: 4pt 0; padding-left: 15pt; }
  li { margin-bottom: 2.5pt; }
  a { color: #1a5276; text-decoration: none; }
  .honest { background: #fdf6ec; border-left: 2.5pt solid #c8901f; padding: 5pt 8pt; margin: 6pt 0; }
  .foot { margin-top: 10pt; padding-top: 5pt; border-top: 0.5pt solid #ccc;
          font-size: 8.5pt; color: #666; }
  @page { margin: 0.5in 0.6in; }
</style>'

render() { # $1 = slug, stdin = body html
  local TMP; TMP=$(mktemp /tmp/brief-XXXX.html)
  { echo "<!doctype html><html><head><meta charset=\"utf-8\">$CSS</head><body>"; cat -; echo "</body></html>"; } > "$TMP"
  google-chrome --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="public/briefs/$1.pdf" "file://$TMP" 2>/dev/null
  rm -f "$TMP"
  ls -lh "public/briefs/$1.pdf"
}

FOOT='<p class="foot">Madhan Kumar Reddy · Singapore · reddy.madhankumar.sg@gmail.com · theinvalid.me — every number above is a measured run on one RTX 5090 (32 GB); benchmarks and failure logs are public in the repo. Generated 2026-07-02.</p>'

render sovereign-stack-brief <<EOF
<h1>Sovereign AI Stack — one-page brief</h1>
<p class="sub">A private LLM that physically can't leak: self-hosted multimodal serving where "client data never touches a cloud API" is enforced by routing, not policy. Public repo: github.com/MushiSenpai/mushishi-sovereign-ai-stack</p>
<h2>What it is</h2>
<ul>
  <li><b>Routing-enforced privacy tiers</b> — the "client" profile refuses to fall back to cloud at all; it fails loudly instead of degrading silently. Auditable, because the whole configuration is public.</li>
  <li>vLLM + Nemotron (NVFP4) on one RTX 5090; always-on CPU fallback (llama.cpp) so agents survive GPU mode-switches; optional cloud budget layer for the tiers your data rules allow.</li>
  <li>Operations included: default-deny firewall, Tailscale-only exposure, monitored 3-2-1 backups, runbook handover.</li>
</ul>
<h2>Measured (not projected)</h2>
<table>
<tr><th>Metric</th><th>Measured</th><th>Note</th></tr>
<tr><td>Single-stream throughput</td><td class="num">276 tok/s</td><td>real multimodal load</td></tr>
<tr><td>Context window</td><td class="num">180K tokens</td><td>FP8 KV cache, ~28–30 GB of 32 GB</td></tr>
<tr><td>Concurrency knee</td><td class="num">~8 concurrent</td><td>~2.65× aggregate; past it, users just wait</td></tr>
<tr><td>Practical users / card</td><td class="num">10–15 heavy</td><td>~30–40 light chat users, &lt;2.5 s latency</td></tr>
</table>
<div class="honest"><b>What it isn't:</b> a 30B local model is not a frontier model. The stack is honest about that — sensitive work stays local by architecture; anything routed to cloud is a tier your data rules explicitly allow. The decision log (including six hours of failed TensorRT-LLM debugging) is published.</div>
<h2>Engagement</h2>
<ul>
  <li><b>AI Readiness Audit</b> — SGD 500–1,000: two hours + a written gap analysis and roadmap. The low-commitment first step.</li>
  <li><b>Deployment</b> — SGD 3,000–8,000 by scope: ~2 weeks spec + staging, 1 week on-site if needed. Hardware spec'd to buy or deployed on yours.</li>
  <li><b>Health retainer</b> — SGD 800–1,500/mo: backups verified, watchdog reviewed, dependencies current.</li>
</ul>
$FOOT
EOF

render creative-stack-brief <<EOF
<h1>Creative Stack — one-page brief</h1>
<p class="sub">Local AI video production — generation, surgical editing, 4K finishing — on hardware you control. Unreleased footage never leaves the building. Public repo: github.com/MushiSenpai/mushishi-creative-stack</p>
<h2>What it is</h2>
<ul>
  <li><b>Generation:</b> FLUX.2 stills, Wan 2.2 / HunyuanVideo video, shipped as six named, tested ComfyUI workflows (importable JSON).</li>
  <li><b>Editing:</b> object removal (VOID) with SAM3 video-mask tracking — including the object's reflection; masked edits (SAM3 + VACE); a <b>forensic bridge</b> where a local vision LLM measures the scene first and writes the mask + fill constraints itself, so the diffusion model gets specifications to obey, not room to hallucinate.</li>
  <li><b>Finishing:</b> 60 fps interpolation (RIFE) + 4K upscale (SeedVR2).</li>
</ul>
<h2>Measured (not projected)</h2>
<table>
<tr><th>Job</th><th>Measured</th><th>Note</th></tr>
<tr><td>Object removal, representative clip</td><td class="num">180 s</td><td>clean — no ghost, background reconstructed</td></tr>
<tr><td>Object removal, worst case</td><td class="num">residue</td><td>subject behind glassware, low light — stated up front</td></tr>
<tr><td>Forensic-bridge pipeline, end to end</td><td class="num">203 s</td><td>analysis → auto mask/fill prompts → render, unattended</td></tr>
</table>
<div class="honest"><b>What it can't do yet:</b> liquids, heavy occlusion, and low-light targets defeat the mask — the published case studies show the failures, not just the wins. Hard footage is quoted only after a <b>free sample frame</b>, and I'll say honestly if the tech isn't there.</div>
<h2>Engagement</h2>
<ul>
  <li><b>Object removal:</b> Draft SGD 12/sec (min 80) · Production SGD 25/sec (min 150) · Delivery 4K SGD 40/sec (min 240), revision included.</li>
  <li><b>Turnkey pipeline deployment</b> for studios/agencies — the whole stack on your hardware, with the workflow catalogue and runbook.</li>
</ul>
$FOOT
EOF

render audio-stack-brief <<EOF
<h1>Audio Stack — one-page brief</h1>
<p class="sub">Fully local voice cloning, TTS, lip-sync avatars, music, and auto-dubbing — job-queue architecture, every model MIT/Apache-2.0. A face and a voice are the most privacy-sensitive inputs there are; here they never leave the machine. Public repo: github.com/MushiSenpai/mushishi-audio-stack</p>
<h2>Measured (not projected) — 34.5 s reference clip</h2>
<table>
<tr><th>Job</th><th>Measured</th><th>Note</th></tr>
<tr><td>Voice clone (Demucs + Fish Speech)</td><td class="num">5 s</td><td>reusable profile, ~4 GB</td></tr>
<tr><td>TTS narration, cloned voice</td><td class="num">25 s</td><td>34.5 s WAV, ~145 wpm</td></tr>
<tr><td>Transcription (WhisperX, word-aligned)</td><td class="num">15 s</td><td>~2.3× realtime</td></tr>
<tr><td>Avatar — draft (MuseTalk)</td><td class="num">78 s</td><td>1024², 25 fps, ~7.7 GB</td></tr>
<tr><td>Avatar — production (LatentSync 1.6)</td><td class="num">242 s</td><td>~20 GB; cleaner blend, teeth a tie with draft</td></tr>
<tr><td>Avatar — cinematic (Hallo2)</td><td class="num">1197 s</td><td>~35× slower than realtime; real head motion</td></tr>
<tr><td>Music — 30 s stereo clip (ACE-Step)</td><td class="num">10 s</td><td>incl. model load</td></tr>
<tr><td>Music — 15 s song w/ vocals (YuE)</td><td class="num">176 s</td><td>mono is a model limit, stated</td></tr>
<tr><td>Dub, same language</td><td class="num">20 s</td><td>cross-language 3–4 min (phased VRAM)</td></tr>
</table>
<div class="honest"><b>The honest ceiling:</b> avatar quality is social-grade across all three engines. Broadcast close-ups still go to a cloud path — I say that before you pay, not after. The three lip-sync engines run as isolated, version-pinned services; the 25+ install lessons are public.</div>
<h2>Engagement</h2>
<ul>
  <li><b>Avatar video:</b> Draft SGD 80 · Production SGD 150 · Cinematic quoted per job.</li>
  <li><b>Turnkey deployment</b> — the pipeline on your hardware (marketing ad-reads, narration, dubbing), with runbook and quality-tier guidance.</li>
</ul>
$FOOT
EOF
