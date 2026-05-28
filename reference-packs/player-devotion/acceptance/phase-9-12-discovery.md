# Devotion Phase 9-12 Acceptance Discovery

Authority for Phase 9-12 is the live Devotion/MO2 environment plus Devotion scripts and verifier gates. This document records the extraction contract; it is not a substitute for generated manifests.

Known live sources:

- MO2 MCP record index: 363 plugins, 354 enabled, no missing masters during discovery.
- Source plugin: `PlayerDevotion_Framework.esp`.
- Existing overlays include VMAD, MCM, structural scaffold, Phase 8, pattern proving, and preflight router overlays.
- Existing Phase 9 manifest: `PDV_Phase9BosmerState.creation-authoring.json`.
- Static combined acceptance manifest: `PDV_Phase9To12_Acceptance.creation-authoring.json`.
- Manifest index: `phase-9-12-manifest-index.json`.

Initial Phase 9-12 acceptance surface to prove:

- Record creation/update: `GLOB`, `MESG`, `ACTI`, `QUST`, `FLST`, plus any discovered Phase 10-12 families.
- Wiring: VMAD script attach, scalar/object/array properties, FormList entries, quest-owned properties.
- Artifacts: SEQ when quest/start-game behavior requires it.
- Verification: MO2 live readback, generic verifier, and Devotion strict verifier for the selected phase gates.

Extraction steps for implementation agents:

1. Query live MO2 records for `PDV_` by type and overlay winner.
2. Compare Phase 9 manifest against live winning records.
3. Inspect Devotion scripts for properties not represented in manifests.
4. Run or extend `pdv_verify` phase gates for 9-12.
5. Create one manifest per phase slice and one combined acceptance manifest only after the phase surfaces are explicit.
6. Treat unknown intent as a blocker, not as an inferred automation requirement.

## Static Implementation Status

Phase 9 is now static-ready:

- `PDV_Phase9BosmerState.creation-authoring.json` uses canonical v1 operation names.
- Phase 9 plans with no manual packets.
- Phase 9 includes CKPE-owned operations for record creation, VMAD array properties, and placement proof.
- `reference.place` has readback normalizer and verifier coverage so placement cannot become a silent proof gap.

The combined Phase 9-12 acceptance manifest exists, but it intentionally contains only executable Phase 9 operations. Phases 10-12 are marked `live-discovery-required` in the manifest index until live MO2 records, Devotion scripts, and verifier gates define their exact intent.

Run the static gate before live proof:

```powershell
.\scripts\check-devotion-phase9-12-static.ps1
```

The live proof boundary begins after this check: MO2 MCP preflight, generated plugin write, CKPE packet execution, compile, MO2 readback, `pdv_verify`, proof ledger emission, and matrix promotion.
