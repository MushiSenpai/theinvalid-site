# SPEC — `/calculator` → "The Local LLM Field Guide" (in-brand upgrade)

Status: DRAFT (2026-06-22). Owner-review before build. Local-only until then —
do not deploy (push to `main` = auto-deploy).

---

## 0. Provenance — why this spec exists

A Google **Stitch** export regenerated theinvalid.me as a "Technical Terminal"
design system and shipped a 6-section **"Local LLM Field Guide — Apple Silicon
Edition"** (sections: *the math nobody tells you → memory tier map → what runs
where → interactive picker*). Archived at
`~/Documents/design/theinvalid-stitch-export/` (see the
`reference_theinvalid_stitch_design` memory for the full verdict).

**What we keep:** the *structure* and the "*without the benchmarketing*" framing
— both are excellent and already match this site's voice.

**What we throw out:** the *implementation* (Tailwind CDN runtime JS, 4 Google
webfonts, a 2nd co-equal green accent, navy `#0b1326` bg) and the *domain*
(Apple-Silicon unified memory, a generic flat "70% rule," invented model names
like "Qwen 3.5 9B" / "DeepSeek V4 Flash"). None of that is ours.

This spec re-grounds the good bones in **measured RTX-5090 reality** and the
site's own three published posts, implemented with zero new dependencies.

---

## 1. Goal

Upgrade the single-purpose `/calculator` (cloud-vs-local break-even) into a
multi-section, interactive, zero-dependency **field guide** that turns the
site's own published lessons into tools a reader can poke:

- [i-had-my-kv-cache-math-14x-wrong](../src/content/blog/i-had-my-kv-cache-math-14x-wrong.md) — KV math is architecture-dependent
- [a-32gb-gpu-is-a-budget-not-a-suggestion](../src/content/blog/a-32gb-gpu-is-a-budget-not-a-suggestion.md) — the VRAM subtraction
- `one-rtx-5090-how-many-users-the-honest-answer` (queued, §A) — the concurrency knee

It becomes the strongest "show, don't tell" artifact for the infra brand: an
interactive companion to the writing, and a high-intent SEO surface.

---

## 2. Non-negotiable constraints (inherited from `SITE-DECISIONS.md`)

These are the locked decisions the Stitch export broke. **Do not break them.**

1. **System fonts only.** No webfonts. (Reject Hanken Grotesk / Inter / the
   webfont JetBrains Mono — use the existing `--mono` / `--sans` stacks.)
2. **No JS framework.** Vanilla `<script is:inline>` only, exactly like the
   current calculator. No Tailwind CDN, no build-step changes.
3. **One accent** — lantern gold `--accent #e8a33d`. Green stays reserved for
   `--ok` (shipped/measured). Do **not** add a second co-equal accent.
4. **Existing dark palette** from `global.css` (`--bg #0b0e14`, *not* Stitch's
   navy). Reuse `.card`, `.badge`, `.meta`, `nav.site`.
5. **46rem column. 100/100 Lighthouse. Instant load.** No external requests.
6. **Honesty is the feature.** Every number editable, every assumption shown,
   failures stated. Measured numbers badged `measured`; derived ones `estimate`.

One *permitted* small addition: a single **semantic** error color token
(`--error`, e.g. `#ff6b6b`) for the "doesn't fit" verdict — this is a state
color like `--ok`, not a second brand accent. Add to `global.css :root`.

---

## 3. Information architecture (one page, `/calculator`, anchored sections)

Keep **one** page and the existing URL. Add a monospace in-page anchor nav
(styled like `nav.site`). Sections:

| § | Title | Type | Source |
|---|---|---|---|
| 0 | Hero | static | terminal voice; `$ how much AI fits on one machine_` (blinking `_`, CSS-only) |
| 1 | The math nobody tells you | static | "Your '32 GB' is not 32 GB" — the dedicated-VRAM subtraction |
| 2 | What fits | **interactive (NEW)** | VRAM calculator — the core new tool |
| 3 | The memory tier map | static + table | "what runs where" for dedicated GPUs |
| 4 | How many users | **interactive (NEW)** | concurrency knee from the stress test |
| 5 | Cloud vs local | interactive (EXISTING) | the current calculator, preserved as-is |
| 6 | Sources & honesty note | static | links the 3 posts + restates the disclaimer |

### §1 — The math nobody tells you
Replaces Stitch's Mac "70% rule" headline. For a **dedicated GPU**, show the
honest subtraction of a nominal 32 GB: model weights (and that
weights-in-VRAM ≠ checkpoint-on-disk — 21.5 GiB vs "~18"), CUDA graphs,
activation + multimodal buffers, per-sequence state, then KV cache. Headline
correction from the kv-cache post: **on a Mamba-hybrid, attention-KV is *not*
the context bottleneck** — weights + graphs + buffers dominate. The flat Mac
"~70% usable" heuristic appears only as a **clearly-labelled secondary
footnote** for laptop/unified-memory readers (a different regime).

### §2 — What fits (interactive VRAM calculator — the centerpiece)
Inputs (all editable):
- VRAM (GB) — default 32
- Model params (B) — default 30
- Quantization → bytes/param: FP16=2, FP8=1, **NVFP4≈0.5**, INT4≈0.5
  (+ note real ~10–15% overhead from scales/zeros)
- Context length (tokens) — default 180000
- Concurrent sequences — default 1
- **Architecture toggle: dense transformer ↔ Mamba-hybrid** ← the 14× swing,
  the whole point of the post

Outputs (a `.card` verdict panel):
- weights GiB, KV GiB (per the arch toggle), overhead reserve, total vs VRAM
- verdict: **fits / fits-but-no-headroom (will swap, crawls) / doesn't fit**
  — "doesn't fit" uses `--error`; everything else uses `--fg`/`--ok`
- the formula shown inline + an honest caveats list

### §3 — The memory tier map ("what runs where")
A stripped table (no vertical rules, mono cells — per DESIGN.md tables). Rows =
**dedicated GPUs a reader actually buys**: 8 / 12 / 16 / 24 / 32 GB, plus **one**
labelled Mac unified-memory row (the other regime). Each row: usable estimate +
a real model *class* (generic descriptor + a couple of real anchors, dated —
**not** invented version numbers). The 32 GB row points to this stack's measured
reality (Nemotron, Qwen-Image "Sterling" ~28 GB peak, MoE 30B-A3B).

### §4 — How many users (interactive concurrency)
From the stress test: single-stream **~276 tok/s** (measured), 2u≈1.4×,
4u≈2.4×, **knee at ~8 concurrent** on 32 GB; KV-cache memory is the cap, *not*
a per-user throughput divide (continuous batching). Input model + ctx → rough
concurrent-session ceiling + aggregate tok/s. Honest "one card, YMMV" note.

### §5 — Cloud vs local break-even
The **existing** calculator, moved verbatim into this section (it's good and
on-message). Closes the page: "so what does owning it cost vs renting" →
links `/services`.

---

## 4. Ground-truth constants (use these — do not invent)

Inline JS constants block. Badge every value `measured` (`--ok`) or
`estimate` (`--muted`):

```js
const BYTES_PER_PARAM = { fp16: 2, fp8: 1, nvfp4: 0.5, int4: 0.5 }; // +~10-15% quant overhead
// KV per token:
//   dense  ≈ 2 * layers * kv_heads * head_dim * kv_bytes        (worked example shown)
//   hybrid ≈ only ATTENDING layers count → Nemotron ≈ ~3 KB/token ≈ ~350K tokens/GiB (measured-correction)
const OVERHEAD_GIB_DEFAULT = 3;   // CUDA graphs + activations + multimodal buffers (editable; dominates on 32GB)
const CONCURRENCY = { single_toks: 276, scale: {1:1, 2:1.4, 4:2.4, 8:2.65}, knee: 8 }; // measured, 32GB
```

KV worked-example and the "256K = max_position_embeddings (theoretical) vs
~228K = total-VRAM ceiling (NOT a KV ceiling)" distinction come straight from
the post — reuse that phrasing.

---

## 5. UX / styling

- Reuse `.card`, `.meta`, input styles already in `calculator.astro`.
- Badges: add `.badge.measured { color: var(--ok) }` and
  `.badge.estimate { color: var(--muted) }` — **no new accent hues**.
- Anchor nav: mono, styled like `nav.site`.
- Hero blinking `_`: CSS `@keyframes` only (matches DESIGN.md "terminal prompt"
  note, zero JS).
- Verdict panels: bold conclusion; `--error` **only** for "doesn't fit."
- Mobile: inputs stack (already the calculator's behavior).

---

## 6. Implementation notes

- Stays one Astro file: `src/pages/calculator.astro`; all logic in one
  `<script is:inline>` (like today). No new deps, no config changes.
- Factor pure helpers: `kvGiB()`, `weightsGiB()`, `fitVerdict()`,
  `concurrencyCeiling()`.
- Total page JS stays a few KB; no external requests → Lighthouse stays 100.
- SEO title/description target high-intent infra queries: "how much VRAM to run
  an LLM locally," "what model fits in a 24GB / 32GB GPU," "local LLM VRAM
  calculator." Honest, no benchmarketing.

---

## 7. Explicitly rejected (from the Stitch export)

- Apple-Silicon as the *primary* lens (we're dedicated-GPU first; Mac = one
  labelled secondary row).
- The flat "70% rule" as the *headline* math (it's a laptop heuristic; our
  headline is the dedicated-VRAM subtraction + the arch-dependent KV correction).
- Invented model names/versions — real shipping models or dated class
  descriptors only.
- All Stitch chrome: webfonts, Tailwind CDN, navy bg, dual green/amber accent,
  "Technical Terminal Publishing" footer.

---

## 8. Build order (each step shippable)

1. Refactor the existing calculator into **§5** of a sectioned page + anchor
   nav (no behavior change). Ship.
2. Add **§1 + §3** (static content lifted from the posts). Ship.
3. Add **§2** VRAM calculator (the core new tool). Ship.
4. Add **§4** concurrency tool. Ship.
5. SEO polish + cross-link the 3 posts + `/services` CTA.

---

## 9. Open questions for owner

1. **One page or split?** Recommend: keep everything on `/calculator` (one fast
   artifact, preserves the URL). Alternative: `/field-guide` with `/calculator`
   redirect.
2. **Include the Mac unified-memory regime?** Recommend: yes, as **one**
   clearly-labelled row/footnote — it's the most-Googled framing and costs
   little — but stay dedicated-GPU-first.
3. **Real model names vs generic class descriptors?** Recommend: generic class +
   2–3 real anchors you actually run, each dated ("verified as of <date>"), to
   avoid the maintenance trap of a model-name list that rots.
