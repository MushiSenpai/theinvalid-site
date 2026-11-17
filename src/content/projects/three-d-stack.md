---
title: "Mushishi 3D Stack"
oneliner: "Local image or text brief → a validated, engine-ready or marketplace-ready 3D asset on one RTX 5090: TRELLIS.2 / Hunyuan3D generation, headless-Blender mesh-ops (retopo, UV, PBR bake, real-world rescale), and an automated compliance gate that refuses assets failing a marketplace's published spec."
status: shipped
repo: "https://github.com/MushiSenpai/mushishi-3d-stack"
stack: ["TRELLIS.2", "Hunyuan3D", "Blender (headless)", "retopology", "PBR bake", "KTX2 GLB", "USDZ"]
started: 2026-07-02
order: 4
---

One product photo goes in; a spec-checked GLB and a machine-generated compliance report come out: geometry retopologised to a triangle budget, UVs unwrapped, PBR textures baked, the mesh rescaled to its real-world dimensions, and a KTX2-compressed GLB (plus USDZ on request) exported against an Amazon-3D or Shopify-3D profile. Two licence lanes: a TRELLIS.2 (MIT) path that ships worldwide, and a premium multi-view Hunyuan tier held back from EU / UK / South-Korea deliverables by the upstream model licence.

The interesting part is the QA wall. On a real five-SKU batch measured on one shared card (63–154 s generation per SKU; delivered GLBs 0.76–1.33 MB against a 4 MB cap), three passed clean, one was refused (UV utilisation below the floor, hallucinated depth), and one was flagged with the exact dimension miss (703 mm reconstructed vs 650 mm listed). Stopping the bad assets *is* the product. See the honest walk-through in the [product-photo → 3D case study](/case-studies-product-photo-to-3d/) and browse the live [3D asset catalogue](/3d-catalogue).

The same chain also drives film/game previs: a mixed shot list (reference photos and one-line text briefs) becomes an Unreal-ready pack: a prop per line, FBX and GLB each, one idempotent import script with Nanite on the heroes. On a real six-prop run, five delivered in 15m12s warm and one was refused with its reason shown. The [shot-list → previs-pack case study](/case-studies-shot-list-to-previs-pack/) walks it end to end.

**Since launch (updated November 2026).**

- **Validator failures traced to their real cause.** A tangent step kept failing glTF-Validator. The cause turned out to be sliver triangles from mesh generation, not degenerate UVs, so renormalising the output was the wrong fix. [The bug](/blog/fixing-the-bug-when-rebuilding-degenerate-uv-triangles).
- **Repro before the upstream report.** A minimal reproduction showed the named cause of a logged symptom was wrong, before it reached a maintainer. [Why the repro comes first](/blog/build-the-repro-before-you-file-the-report).
- **A gate sprint after a reviewer said "the normals still look bad":** every quality gate now runs on the file that actually ships, a failed asset is parked before delivery, and texture work is locked only where the camera actually saw the object.

