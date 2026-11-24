---
title: "CHAKRAVYUHA: a security testing lab"
oneliner: "Plan stage. An isolated range for practising attack and defence against my own systems, on its own hosts and its own network segment."
status: planned
private: true
stack: ["isolated lab hosts", "VLAN segmentation", "Tailscale ACL tags", "pinned tool manifest"]
started: 2026-11-05
order: 21
---

Nothing is built, and the decisions are deliberately postponed until a hardware fix lands. Two lessons from the planning are already worth writing down.

**A lab plan written without seeing the machine gets the machine wrong.** The first draft told me to buy hardware I already had, and to run the range on the one workstation that holds the databases, the studio and the secrets. The range goes on its own hosts and its own network segment, and a phone joins on a narrow tag, never the admin one.

**A tool list is a manifest of pins, not a list of names.** The draft named about 80 tools from memory with no versions checked. A scripted check of releases and published advisories found one pick archived, four stale by two or more years, one model family two releases behind, and one widely used scanner that had been compromised earlier this year. No pick had an unpatched advisory. The check is now re-runnable, because pins age.

Scope is my own systems only. It pairs with [BHAIRAVA](/projects/bhairava), where a target without a recorded authorization basis is excluded in code.
