---
title: "VISHWAKARMA: a robotics stack, planned before buying a servo"
oneliner: "Manipulation arm first, drone perception second. The software gate comes before the hardware order, and it already caught four decisions that would have cost money."
status: building
private: true
writeup: "/blog/planning-a-robotics-stack-before-buying-a-single-servo"
stack: ["LeRobot", "ManiSkill3", "Python"]
started: 2026-07-09
order: 16
---

Nothing here claims a working robot. Software phase zero is complete (CI green, 43 tests passing) and the arm is still on a buy list, on purpose.

What planning first caught: the obvious simulator hit support gaps on the RTX 5090's Blackwell architecture and was quarantined on day one (ManiSkill3 runs headless in its place); the target drone was discontinued mid-spec; and a headline robot foundation model carried a non-commercial weights licence that the repository badge did not show.

Hardware phases stay gated on the software gate.
