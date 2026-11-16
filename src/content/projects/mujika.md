---
title: "MUJIKA: a study system"
oneliner: "A native study app for phone and Linux from one Kotlin codebase: spaced repetition, closed-book tests where a missed answer becomes a card, and spoken explanations transcribed on the CPU."
status: building
private: true
stack: ["Kotlin Multiplatform", "Compose Multiplatform", "Ktor", "SQLite", "FSRS-6", "CPU speech-to-text"]
started: 2026-11-01
order: 18
---

Built for one learner, me. The plan for the day is sized to the time actually available. Every session opens with a short retest of earlier material before anything new. Cards run on FSRS-6 and work offline. Tests are closed-book, a hint costs half a mark, and whatever is missed comes back as a card. Passed material returns after a week, a month and three months.

Two engineering rules carry over from the rest of the estate. It never touches the GPU: transcription runs on the CPU and every LLM call is logged with its cost. And the curriculum is plain Markdown that the server re-reads, so the app never owns the content, and a test fails if a link in those documents stops reaching the app.

Private because my own learning record and recordings flow through it.
