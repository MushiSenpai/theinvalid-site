---
title: "Four LiteLLM Docker config traps that swallowed their own errors"
description: "Provider slug renamed in v0.14, OTEL needs two Docker networks, Phoenix gRPC is port 4317 not 4318, and app defaults lie. Each cost an afternoon."
date: 2026-11-07
project: sovereign-ai-stack
tags: ["litellm", "docker", "llm-ops", "observability", "self-hosted"]
---

I was wiring LiteLLM into my local AI stack alongside Phoenix for observability. The usual approach: docker compose, a config file, a few services, ship it. Each of the following issues looked like a misconfiguration somewhere upstream. None of them produced an error message pointing at the actual cause.

## The error (or lack of one)

That is the whole problem. Each failure produced either silence or a symptom so far from the root cause that it sent me chasing something else entirely. The config loaded. The containers started. The logs were clean.

## Gotcha 1: `openai_compatible` is not the provider slug anymore

My profile YAML had an entry like this:

```yaml
provider: openai_compatible
model_list:
  - model_name: my-local-model
    litellm_params:
      model: openai/my-model
      api_base: http://localhost:8000
```

This worked in an older version. After moving to LiteLLM v0.14 it stopped routing calls to that backend, with no error.

The canonical slug in v0.14 is `custom`. Not `openai_compatible`. The old name silently does nothing: the router skips it without a warning, and your provider disappears.

```yaml
# v0.14 and later:
provider: custom
```

If your custom OpenAI-compatible backend calls are vanishing without a trace, check the slug first. It is the cheapest possible fix.

## Gotcha 2: LiteLLM needs BOTH Docker networks to reach Phoenix

My docker compose had LiteLLM attached to the postgres bridge network and Phoenix on its own network. I added LiteLLM to the Phoenix network, expecting traces to flow. The Phoenix board stayed empty.

The issue: LiteLLM needs to be on BOTH networks simultaneously. Single-network attachment leaves the OTEL exporter unable to reach its endpoint, with no error surfaced in the LiteLLM logs. The container starts fine either way.

```yaml
services:
  litellm:
    networks:
      - postgres_bridge   # the database
      - phoenix_network   # OTEL, must also be here
```

If Phoenix is empty and LiteLLM logs look clean, run `docker inspect <litellm-container>` and check the Networks block. If only one network is listed, that is your problem.

## Gotcha 3: Phoenix OTLP gRPC is port 4317, not 4318

Even with both networks connected, traces still did not appear. Phoenix has two OTLP endpoints: gRPC on port `4317` and HTTP on port `4318`. I had the port off by one, and the wrong protocol.

LiteLLM's OTEL exporter speaks gRPC. HTTP receives nothing without an error at the sender. The exporter happily reports success while Phoenix receives zero traces.

```bash
# In your LiteLLM env or compose config:
OTEL_EXPORTER_OTLP_ENDPOINT=http://phoenix:4317   # gRPC endpoint
# 4318 is HTTP/Protobuf -- different protocol entirely
```

After fixing the slug (gotcha 1) and the network (gotcha 2), this was the third layer I needed to peel back before anything showed up in Phoenix.

## Gotcha 4: Verify default ports before reserving them

I had a slot I believed was free at `:3000` and assigned an incoming service, DeerFlow, to it. DeerFlow's actual default port is `:2026`, not `:3000`. It bound there instead, which meant every part of the stack pointing at the assumed `:3000` was talking to nothing, while DeerFlow silently operated on a port that could collide with other services.

The assumption that "new service, probably `:3000`" is an expensive one. Before adding any new container to a stack with reserved ports:

```bash
# Check what the image actually binds before writing any compose config:
docker run --rm <image> env | grep -i port
# Or read the Dockerfile's EXPOSE line
# Or just: docker compose up, then docker ps
```

DeerFlow is `:2026`. Whatever you are adding is probably not `:3000` either.

## The pattern

All four of these are "it starts, it looks fine, it does nothing" failures. That category is harder to debug than a crash because there is no failure signal to follow. The only defense is: after any new service comes up, verify that it is actually doing what you expect, not just running.

**What to check right now if you are in this:**

1. `docker inspect <litellm-container> | grep -A 20 Networks` -- are ALL required networks listed?
2. Check your OTLP endpoint: Phoenix gRPC is `:4317`, not `:4318`.
3. `grep -r 'openai_compatible' ~/.litellm/` -- rename any hits to `custom`.
4. `docker ps` on every container you added recently, check the actual port column.

---

*The sovereign AI stack this runs on, with failure logs included, is documented at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack).*
