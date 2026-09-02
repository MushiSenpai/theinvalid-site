---
title: "The model echoed my prompt back"
description: "Three ways Nemotron's JSON output silently broke my parser: prompt notation echoed as literal keys, json_repair returning a bare string, normalized floats failing strict type checks. The parse-boundary discipline that handles all three."
date: 2026-09-02
project: comic-narrator
tags: ["llm", "nemotron", "json-parsing", "ai-integration", "debugging"]
---

I'd been running the comic narration pipeline on synthetic test pages for a week. Every pass found the dialogue, extracted characters, scripted the voices. Then I fed in the first real manga page and zero dialogue made it into the narration script. Not wrong dialogue. Zero.

## The error

My PASS2_SYSTEM prompt described the response schema like this:

```
"dialogues[]": ["the spoken lines, in reading order"]
```

Reasonable documentation notation for an array field. The problem: Nemotron read that bracket suffix and returned it as the literal key name.

The actual response:

```json
{
  "dialogues[]": ["HEY, LUFFY!", "HMPH"],
  "captions[]": ["The sea stretched endlessly..."]
}
```

The consumer did `data.get("dialogues")`, which returned `None`. All the dialogue was right there in the response, indexed under a key nobody asked for.

The synthetic fixtures happened to return plain keys. Every test passed; the real-world behavior was completely unexercised.

## Two more shapes of the same problem

Bug 6 introduced a pattern that came back twice more in the same project:

**Normalized geometry (Bug 3, Session 1).** Same prompt, same page, temperature 0.1: one panel returned pixel bboxes like `[145, 203, 88, 61]`, another returned normalized floats like `[0.22, 0.3, 0.14, 0.18]`. The Pydantic `BBox` schema rejected floats (strict ints) and dropped the whole panel's analysis silently. The log read:

```
[WARN] Pass 2 failed for panel 3: validation errors for BBox
```

No exception raised. The panel disappeared.

**`json_repair` returning a bare string (Bug 9, Session 5).** When Nemotron's output couldn't be parsed as JSON at all, `json_repair` returned a bare string, not a dict and not `None`. The caller did `.get()` on a string and got `None`. One bad sample voided an entire dialogue panel with no crash and no logged error.

Three bugs, one shape: model output varied from what the code expected, and the failure mode was silent.

## The fix

All three fixes land at the same place: the parse boundary, before any consumer touches the data.

**Normalize bracket-suffixed keys:**

```python
def _normalize_keys(d: dict) -> dict:
    return {k.rstrip("[]"): v for k, v in d.items()}
```

Called once per parsed response. Any `key[]` the model echoed back becomes `key`.

**Coerce geometry unconditionally:**

```python
def _coerce_bbox(coords, img_w, img_h):
    if all(c <= 1.0 for c in coords):
        coords = [c * dim for c, dim in zip(coords, [img_w, img_h, img_w, img_h])]
    return [max(0, int(c)) for c in coords]
```

The `<= 1.0` signature reliably detects normalized coordinates. Scale, clamp, move on.

**Reject non-dict output and retry once:**

```python
result = json_repair.loads(raw)
if not isinstance(result, dict):
    result = json_repair.loads(call_model_again(prompt))
if not isinstance(result, dict):
    return stub_panel()
```

`json_repair` returning a bare string is a valid outcome, not a library bug. Check `isinstance(result, dict)` before trusting it as one. A single retry at temperature 0.1 lands a parseable result most of the time.

## The lesson

Any literal notation in your prompt is a candidate output key. Document a field as `"dialogues[] (array):"` and some samples return `"dialogues[]"` as the key. The model is interpolating from your format, not following a grammar.

Model output at temperature 0.1 is not deterministic. It's a distribution. The same prompt produces pixel bboxes or normalized floats; `"dialogues"` or `"dialogues[]"`; valid JSON or a repaired string. The prompt controls the center of that distribution. The parse layer handles the tails.

The discipline: normalize at the parse boundary, validate types, retry once per item before stubbing. Not "write a better prompt." Boundary-level coercion, every time.

## What I'd tell you to check today

1. Run your LLM integration against real inputs, not just synthetic fixtures. Fixtures look cleaner than what the model sends on content it hasn't encountered before.
2. Trace every `.get()` call on parsed model output. What happens when it returns `None`? Is it a recoverable stub or a silent data loss propagating three calls downstream?
3. If your prompt uses any notation to describe a field structure (brackets, type annotations, colons), add key normalization at parse time. Any literal in your prompt is a candidate key.
4. Check `isinstance(result, dict)` after calling `json_repair`. On a badly malformed response, it gives you a string. Calling `.get()` on a string in Python 3 doesn't raise: it returns `None`.

---

*The comic-manga-narrator pipeline, from manga page to narrated MP4 with voice acting and sound design, is at [github.com/MushiSenpai/comic-manga-narrator](https://github.com/MushiSenpai/comic-manga-narrator).*
