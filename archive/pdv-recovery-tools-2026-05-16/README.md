# PDV Recovery Tools Archive (2026-05-16)

This folder holds historical one-off artifacts from the Phase 4/5/6 repair and
merge-back pass.

Contents here are **not** part of the normal PDV workflow.

They are archived for provenance only:

- emergency xEdit merge-back helper
- one-off framework master repair script
- bridge behavior test scripts
- generated Phase 5 working files and wire-request payloads

Do not treat these files as canonical source, active tooling, or routine build
inputs.

Current canonical workflow remains:

- `tools/pdv_compile.mjs`
- `tools/pdv_verify.mjs`
- `tools/pdv_author.mjs`
- living phase CK walkthrough docs at repo root

If a future session needs to understand how the rescue path worked, read these
files as historical context and mirror any durable lessons into the living
docs instead of restoring the archived workflow by default.
