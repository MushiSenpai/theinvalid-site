---
title: "The ATS parser was silently dropping my open-source section"
description: "hiring-agent (gemma3:12b) scored my resume 45-65 because my Open-Source Contributions section was silently dropped. One line in EXPERIENCE fixed it to 84-89."
date: 2026-10-17
tags: ["ats", "resume", "job-search", "llm", "open-source"]
---

I spent weeks documenting upstream AI/ML contributions: PRs merged to qdrant-client, colpali, YuE. I built a proper "Open-Source Contributions" section with real, public, measurable work. Then I ran an AI screener and the score went down.

That was experiment one. This post is about what I found in experiment two.

## What the parser keeps

The screener is HackerRank's hiring-agent, running gemma3:12b. When you look at the parsed JSON (not the score, the actual JSON output), the schema is:

```json
{ "basics": {}, "work": [], "education": [], "skills": [], "projects": [], "awards": [] }
```

No `contributions` key. No `open_source` key. A section called "Open-Source Contributions" gets dropped in full, from every version of the resume, on every run. Zero PR links survived the parse either way.

The rubric also penalizes portfolios that skew toward self-owned projects. At 6 own-repo projects the model was lenient. At 9 it applied a stricter cap. So adding real work to a custom section had two effects at once: the work was invisible to the evaluator, and the self-project count looked worse.

Baseline scores, N=3 runs: **45, 52, 65**.

## The fix

Put the claim in a slot the schema actually keeps.

I added one entry to the EXPERIENCE section of the resume:

```
**Open-Source Contributor** — upstream AI/ML infrastructure projects (Jun 2026 – present)
```

Nothing else changed. Same PDF renderer, same scorer (hiring-agent, gemma3:12b), N=3.

Scores: **84/83/78**. The `open_source` rubric dimension jumped from 15 to 25-30.

I also tested a more elaborate restructure: each upstream PR as its own work entry, own-repo projects trimmed from 9 to 4. That variant scored **87/89/89**. The full restructure is worth about 6 additional points over the single line. Not worth deleting real work for.

## The mechanism wasn't what I designed

I assumed the high scores on the restructured variant came from the individual PR entries being parsed and evaluated. They weren't.

Parsed JSON from the best run of the restructured variant: **0 PR links in the output**. Projects parsed: 4. The per-entry PR blocks were being dropped the same way the contributions section was.

The evaluator's evidence string (the text it produces to justify each rubric dimension) quoted the `Open-Source Contributor` work entry verbatim. The single line did nearly all the work. The per-PR entry formatting contributed noise, not signal.

If I had stopped at "it went from 55 to 88, the restructure worked," I would have spent months maintaining a dozen individual PR entries in my resume, believing they were load-bearing. They weren't.

## What actually matters

Three things made this clear:

**Check the parsed JSON, not just the score.** The score is downstream of the parse. If your work doesn't appear in the `work` or `projects` array of the parsed output, it was not evaluated. The score reflects what the parser kept, not what the PDF says.

**Read the evaluator's evidence string.** Most scorers expose the text they used to justify each rubric dimension. That text quotes your resume directly. If it quotes your work entry and not your contributions section, the contributions section did not exist for the evaluator.

**Ablate before crediting a change.** I ran a version that changed exactly one thing: added the single work entry, everything else untouched. That version scored 84-89. That version told me where the lift came from. An A/B test shows you the score moved. An ablation shows you which change moved it.

The mechanism you assume explains the number is often not the one that does.

## What I'd check today

1. Run your resume through a screener that exposes the parsed JSON. Check whether your open-source work appears in the `work` or `projects` array. If it doesn't, the evaluator never saw it.
2. Move the claim to a slot the schema has. A dated, honest `work` entry for your actual contribution area outperforms a custom section that the parser drops silently.
3. Add one change at a time and check the parsed output after each one. The evidence string is the ground truth for what was read.

---

*The oss-observer that tracks my upstream PRs and regenerates the resume section daily is part of the [Mushishi Sovereign AI Stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
