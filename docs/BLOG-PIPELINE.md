# Blog Pipeline — one source, many outlets, one human gate

## Flow
```
learnings accumulate                    weekly scheduled job          human (5 min)
─────────────────────                   ────────────────────          ─────────────
Blog Content Mine (queue)        →      drafts/<slug>/         →      review/edit  →  publish:
LESSONS.md in each repo                  ├── post.md                                  • blog: mv to src/content/blog/ + push (auto-deploys)
EXECUTION-PLAN done log                  ├── linkedin.txt  (story-first, no bare link)  • linkedin: paste
                                         ├── reddit-<sub>.txt (per-sub culture)         • reddit: paste
                                         └── hn-title.txt                               • HN: submit
                                        + ntfy ping: "bundle ready"
```

## Rules
1. `drafts/` is gitignored — staging is local; only reviewed posts reach the public repo.
2. Generation is automated (Hermes cron or headless Claude run on the workstation); **publishing is always human-approved** — brand is verified honesty, and LinkedIn/Reddit ToS prohibit unapproved posting automation anyway.
3. One promoted post per week. The queue is the "Blog Content Mine" table (sovereign stack doc).
4. LinkedIn variant: 3–6 sentences, hook first, link last. Reddit variant: written for the specific sub, discloses it's your own project. HN: plain descriptive title, no marketing voice.
