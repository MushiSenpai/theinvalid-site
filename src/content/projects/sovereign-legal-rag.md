---
title: "Sovereign Legal RAG"
oneliner: "Private document search and Q&A for legal teams: hybrid retrieval with reranking, pinpoint citations, matter-level ethical walls, and a system that refuses rather than invents. Zero egress."
status: shipped
private: true
repo: "https://github.com/MushiSenpai/sovereign-legal-rag-results"
stack: ["BGE-M3", "Qdrant", "bge-reranker-v2-m3", "reciprocal rank fusion", "hash-chained audit log"]
started: 2026-06-25
order: 7
---

The application layer of the sovereign deployment offer: a private LLM is only useful to a law firm once it can search the firm's own contracts, cite the exact section, and say "the documents do not contain that" instead of guessing.

Measured on 150 clause-localization questions over real, expert-annotated commercial contracts (CUAD v1):

| mode | MRR | R@1 | R@5 |
|---|---|---|---|
| semantic only | 0.434 | 0.307 | 0.587 |
| keyword only | 0.551 | 0.393 | 0.747 |
| hybrid | 0.531 | 0.380 | 0.767 |
| **hybrid + rerank** | **0.564** | **0.440** | 0.740 |

The finding worth more than the headline: semantic-only search, the standard "chat with your PDFs" recipe, is the **weakest** mode on legal text. Clause language is exact-term heavy. Fusion alone does not fix it either; the reranking pass is what turns recall into rank-1 precision.

Around the retrieval: users only retrieve documents in matters they are cleared for (walled documents cannot surface in an answer or a citation), and every query is written to an append-only, hash-chained audit log.

The engine is the commercial deliverable, so its code stays private. The linked repo is the public results sibling: full tables, method, live transcripts and the honest limitations.
