---
title: "Three local AI stack gotchas that required reading the actual code"
description: "Hunyuan Video needs one sampler not two. Hunyuan3D-Omni's --use_ema flag does nothing. smartctl misses NVMe self-test support entirely. Each cost a day."
date: 2026-11-18
project: sovereign-ai-stack
tags: ["comfyui", "hunyuan", "smartctl", "self-hosted", "ops"]
---

Three separate problems. Three separate "why isn't this working" sessions. Each one resolved by reading the actual code or probing the actual hardware rather than trusting what the documentation said.

## Gotcha 1: Hunyuan Video is not MoE

Wan 2.2 has a well-documented ComfyUI quirk: it uses a mixture-of-experts architecture that requires two separate sampler nodes. You chain a standard KSampler with a KSamplerAdvanced. Dozens of tutorials explain this. It's real, and it matters for Wan 2.2.

What those tutorials do not say: Hunyuan Video is not MoE. It uses a standard single-sampler chain.

If you wire up dual samplers for Hunyuan Video because you read Wan 2.2 advice, you get wrong output with no crash. The model runs fine. The workflow validates fine. The result just looks off in ways that are easy to misread as a prompt quality or settings problem, because the actual error is at the workflow architecture level.

The workflow catalogue has a `DO-NOT-TOUCH` flag on the Hunyuan Video section specifically because of this. Wan 2.2 and Hunyuan Video look similar enough in ComfyUI that the fix for one is tempting to apply to the other. They share a naming family and a generation domain. They do not share an architecture.

**Single KSampler. Standard chain. That is the correct Hunyuan Video setup.**

## Gotcha 2: Hunyuan3D-Omni `--use_ema` is never read by inference.py

The Hunyuan3D-Omni README describes a flag:

```
--use_ema    Use EMA weights for more stable inference
```

I ran A/B comparisons with and without this flag. I noticed differences. I drew conclusions.

None of it was real. The flag is a no-op.

Tracing `--use_ema` through the inference code shows that `inference.py` builds the pipeline with only the `fast_decode` parameter. The `--use_ema` argument is parsed from the command line and then discarded. The model loader does have conditional logic to handle EMA weight loading, but the `variant` parameter is always `None` because `--use_ema` never reaches it.

The EMA weights can be absent and the loader falls back to base weights silently. Even if the ema checkpoint is on disk, the flag bypasses the branch that would select it.

The only honest signal is the initialization log. When Hunyuan3D-Omni starts, it emits a line showing which weights loaded and with which variant. That line is the ground truth. If you are evaluating EMA vs base quality on a 3D generation model, verify the log before reading anything into the results.

This is not unusual for fast-moving ML repos. A flag gets documented before it is wired. The documentation describes intent; the code describes reality.

## Gotcha 3: `smartctl -c | grep -i "self-test"` returns nothing for NVMe drives

The standard way to check whether a drive supports self-testing:

```bash
smartctl -c /dev/nvme0 | grep -i "self-test"
```

Returns nothing. This looks like the drive does not support Device Self-Test. It does.

The `-c` flag prints ATA drive capabilities in ATA-protocol format. NVMe Device Self-Test (DST) is a separate NVMe protocol feature with its own command set. It does not appear in the ATA capability output because it is not an ATA capability. The grep is looking in the wrong section of the output.

To verify DST support, probe it directly:

```bash
smartctl -t short /dev/nvme0
```

If the drive supports DST, it starts a short test immediately. Check the result after one or two minutes:

```bash
smartctl -l selftest /dev/nvme0
```

A modern NVMe drive like the Samsung 990 PRO supports DST. The `-c` grep telling you otherwise is a protocol mismatch, not a capability gap.

This matters for the alert side too. The default smartd setup delivers health alerts by email to the local root account. On a machine with no mail transfer agent (which describes most self-hosted AI workstations), those alerts disappear. Add this to your smartd configuration to route alerts to an exec script instead:

```
-m <nomailer> -M exec /path/to/notify.sh
```

The `<nomailer>` token tells smartd to skip mail delivery but still invoke the script. That script can push to ntfy, Pushover, or anything else. Without it, smartd's drive health alerts are running and arriving nowhere. The drives could start failing tests and the notification infrastructure would dutifully log to a mailer that does not exist.

## The pattern

Each of these cost more time than it should have because I read the documentation before reading the code.

The Wan 2.2 tutorials made me assume all video-gen models in the Hunyuan family use the same workflow architecture. The Hunyuan3D README made me trust a flag that was never wired into the pipeline. Several Stack Overflow answers on smartctl described NVMe self-test as something visible in `-c` output, without noting the ATA vs NVMe protocol distinction.

For anything where the behavior actually matters:

- For ComfyUI workflows, check the architecture of the specific model, not the tutorial written for the nearest relative in the same product family.
- For CLI flags, run a quick grep in the actual call site to confirm the argument is forwarded, not just parsed.
- For drive monitoring, probe the feature directly. The capability output and the actual behavior are written in different protocols.

## What I'd check today

1. If you run Hunyuan Video with two samplers in ComfyUI, verify whether that is intentional. The correct chain uses one.
2. If you have been A/B testing `--use_ema` on any Hunyuan3D model, check the initialization log to confirm which weights actually loaded.
3. Run `smartctl -t short /dev/nvmeX` on each NVMe drive you own. If the command fails, DST is either unsupported or your smartd setup is not covering NVMe drives.
4. Check your smartd configuration for `-M exec` or `NOMAILER`. If neither is present, your drive health alerts are going nowhere.

---

*The sovereign AI stack this runs on, including the monitoring setup, is at [github.com/MushiSenpai/mushishi-sovereign-ai-stack](https://github.com/MushiSenpai/mushishi-sovereign-ai-stack). The 3D generation stack (Hunyuan3D-Omni) is at [github.com/MushiSenpai/mushishi-3d-stack](https://github.com/MushiSenpai/mushishi-3d-stack).*
