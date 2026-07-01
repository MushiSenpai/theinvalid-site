---
title: "What I designed in May vs what shipped in June"
description: "I generated an architecture diagram for my local AI stack. It was gorgeous. Within a month, seven things in it were wrong — and I couldn't diff the PNG to find what changed."
date: 2026-07-02
project: sovereign-ai-stack
tags: ["architecture", "documentation", "diagrams", "ops", "lessons"]
---

In May I generated an architecture diagram for the sovereign AI stack. Fed a text description to an image model, got back something genuinely beautiful — neat boxes, clean arrows, everything in approximately the right place. I committed it to the repo and moved on.

By June it was wrong in seven places I could count.

Not catastrophically wrong. Each individual error was small: a service label that said "cloud" when the service had moved to a local port, a UI layer showing something that had since been replaced, a status column in a spec doc still reading "Planned" long after the thing was running. Small things. But wrong is wrong, and wrong in seven places you can count is wrong in more places you haven't counted yet.

## What drifted

The fastest-moving part of the stack turned out to be the layer I'd least expected: the cockpit UI. In six weeks it changed three times — Aion UI, then a third-party PWA, then the official Hermes Desktop. Each time, whatever diagram existed still showed the previous thing. Not because anyone forgot to update it. Because the diagram was a PNG.

The most persistent error: the diagram labelled Hermes as a cloud agent for roughly two months after Hermes had moved to a local systemd service on `:8642`. Not cloud, not SSH, not remotely invoked. A process running on the workstation itself, bound to a host port. The label still said cloud.

The audio stack spec had a different flavour of the same problem. Its phase status column read "Planned" for three weeks after everything in that phase was already deployed and running in production. Nobody had updated the spec because the spec wasn't in the deploy path — it was a separate document, edited separately, updated when someone happened to think of it. The system moved; the spec didn't notice.

## Why a PNG can't keep up

There is no mechanism by which a committed image file knows the system has changed.

You can `git diff` a Mermaid file. You can grep an SVG for a service name. You can write a CI check that fails if a label in `docs/architecture.svg` doesn't match the service name in `docker-compose.yml`. None of that works on a PNG.

A commit message can say "moved Hermes to local :8642" but the PNG just quietly keeps saying cloud. The diff for the code change and the diff for the diagram change are never in the same PR, because one of them has no diff to show.

The spec status problem is slightly different but has the same root: a document that tries to hold both design intent and live operational state will always be stale on whichever axis moves faster. Design intent is stable; operational state changes every session. One document, two jobs, different rates of change. It never ends well.

## The fix

The v1.6.4 AI-generated image is still in the repo as a historical artifact — I kept it because it accurately documents what the stack looked like at one point, and that information has value even after it stops being current.

The working diagrams are now SVGs in each repo's `docs/` directory. Hand-authored, one gold accent on a dark canvas, consistent visual language across all three stacks. They render on GitHub as images but they're text underneath. Text that can be grepped, diffed, and checked in the same PR as the thing it describes.

For operational state: a `STACK-STATUS.md` that gets updated every session. The spec holds design intent. The status file holds the truth. Two documents, two rates of change, two separate update paths.

## What I'd tell you to check today

1. **Find your architecture diagram.** Is it a committed text file or a static image? If it's a PNG, when was it last updated versus the last time the underlying system changed?
2. **Count the labels.** How many services in your diagram still accurately describe where those services actually run?
3. **Look for "Planned" anywhere** in spec docs or project trackers. Check whether any of those things are already running.

The image was beautiful. It was also a snapshot with no mechanism for detecting its own drift. The stack moved and the image had no way to notice. That's not a documentation problem — that's a format problem. Any artifact that can't participate in your version control workflow will eventually lie to you.

---

*The sovereign AI stack — including the current versioned SVG architecture — is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
