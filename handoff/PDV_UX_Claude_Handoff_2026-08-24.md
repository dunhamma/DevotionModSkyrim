# PDV UX Workstream Handoff for Claude -- 2026-08-24

> **SUPERSEDED for workflow (2026-08-25).** Use
> `handoff/PDV_UX_NextSession_Handoff_2026-08-25.md` for the operating pattern
> (recover -> reconcile -> implement). This file is kept as historical context and
> has been partially updated since; its discovery-first framing and its workbook
> path are both superseded. The prose authority is now
> `references/authoring/prose-workbook/PDV_ProseWorkbook.xlsx`.

## Purpose

Continue PDV's UX design work with the user while Codex works on separately approved coding. This handoff is design-only. It does not authorize changes to `Devotion.esp`, Papyrus, Prisma, the prose authority, or the historical race-content manifest.

The user owns artistic direction and exact prose. Claude's role is to map the experience, expose decisions and trade-offs, maintain traceability, and help the user work through the designs. Do not rewrite or “improve” owner wording unless explicitly asked.

## Current artifacts and authority

- **Exact prose and prose review:** `outputs/PDV_Accessible_Prose_Workbook_2026-08-24/PDV_Accessible_Prose_Editing_Workbook_v2.xlsx`
  - `Journey & Reactions`, `Rewards & Effects`, and `UI Labels` contain the 4,173 live player-facing rows.
  - Only the blue `Review status`, `Your wording`, and `Your notes` cells control prose review.
  - Hidden `Roundtrip Data` preserves all 5,166 stable copy IDs and protected source fields.
- **Historical-reference triage:** the same workbook's `Disposition Audit` sheet.
  - Blue `Owner decision` and `Owner notes` cells are planning fields only.
  - The proposed disposition is evidence-based guidance, not approval.
- **Flow and visual design:** the Penpot project named **Devotion UX Workbench**, especially the split Nord UX Studio pages and the existing surface/template reference pages.
  - Penpot owns flow, adjacency, surface experiments, and design annotations.
  - It does not own final prose or authorize implementation.
- **Surface constraints:** `references/authoring/PDV_UXSurfaceCatalogue.json`.
- **Stable flow map:** `references/authoring/PDV_CopyFlowMap.json` plus regenerable census material under `generated/pdv-copy-census/`.
- **Race implementation audit:** `references/authoring/PDV_RaceArchitectureAtlas.json`, rendered locally by `node tools/pdv_atlas_render.mjs`.
  - Stable node IDs keep Papyrus, ESP, reachability, copy, and runtime-proof evidence separate.
  - The compact queue is regenerable with `node tools/pdv_implementation_audit_export.mjs --write` under `generated/pdv-race-implementation-audit/`.
  - Direct ESP readback establishes record presence and property values; it is not in-game route or presentation proof.

Do not copy exact prose into a second authority. Penpot should show representative text and stable copy IDs; the workbook remains the editable source for exact owner wording.

## Disposition audit result

The 493 May-manifest rows are historical Markdown authoring slots, not 493 ESP records, and not old-save compatibility material. The audit classified every row:

| Proposed disposition | Rows | Meaning |
|---|---:|---|
| Reconcile to current runtime | 311 | The moment survives in a renamed, shared, or dynamic current surface. Do not recreate the historical EditorID. |
| Retire stale proposal | 48 | The old mechanic or interaction conflicts with current authority. |
| Archive as historical provenance | 87 | Useful provenance or explicitly future material, but not current-release copy. This includes all 29 V2 recognition-dialogue proposals. |
| Consider new implementation | 45 | A related mechanic/state remains, but a dedicated player-facing beat would be a new UX feature requiring approval and proof. |
| Manual review | 2 | Current design and source disagree or leave the presentation decision unresolved. |

The two manual-review rows are:

1. `reference:PDV_Notif_Argonian_SithisActivation_FullActivation` — the three-signal threshold exists, but there is no distinct threshold-crossing surface and the transition map calls emergence N/A.
2. `reference:PDV_Notif_Khajiit_NeglectTexture_SubstrateThinning` — the design says the substrate does not decay, while current source still computes lunar neglect and applies a neglect spell.

The 45 `Consider new implementation` rows are the useful UX opportunity queue. They include thematic neglect presentation, Breton/Dunmer curse explanations, Imperial Concordat states, two Nord Talos “Marked” beats, select Khajiit act-specific signals, and a few race-specific transition moments. Filter the sheet by proposed disposition, then by race/deity; do not promote them en masse.

## Recommended UX working loop

1. Pick one race journey or one tightly related surface cluster. The current queue deliberately moves to Imperial rather than requiring more Nord work.
2. In Penpot, verify the full player sequence and neighbouring surfaces before changing a module.
3. In the workbook, filter by race, deity/prince, event, and surface. Read exact current wording and gameplay context there.
4. Discuss the decision with the user using neutral labels:
   - mechanical truth;
   - player comprehension job;
   - current presentation;
   - feasible alternatives and constraints;
   - branch or recovery behaviour;
   - open design question.
5. Record surface/layout decisions in Penpot. Record exact prose decisions in the workbook only.
6. Mark a Penpot module `Approved for implementation` only when the user explicitly approves it. An Excel edit alone does not approve a surface change; a Penpot status alone does not approve prose.
7. Produce a no-write implementation packet for Codex rather than changing game files.

## Implementation packet required from Claude

For each approved moment, provide:

- stable copy ID(s);
- race and deity/prince;
- trigger and mechanical truth;
- current surface and approved replacement/treatment;
- exact owner-approved workbook wording, if wording changes;
- buttons, alternate branches, dismissal, recovery, or persistence behaviour;
- dependencies and fallback surface;
- required proof bucket: static/readback, runtime route, player surface, save/load, and/or package;
- Penpot module ID and workbook row reference.

Freeform arrows, moved components, sketches, and comments are evidence, not requirements. Only named fields and explicit approval enter the implementation packet.

## Good first Claude session

- Open `generated/pdv-race-implementation-audit/PDV_ImplementationAudit.csv` and filter `kind` to `ux-decision` and `race` to `Imperial`.
- Work through exactly one of the three current Imperial questions: curse rupture/recovery communication, Champion entry recognition, or Concordat threshold beats.
- Use `PDV_ImplementationAuditCopyLinks.csv` to locate the 4, 9, or 5 relevant reference rows in the workbook's `Disposition Audit`; these are references, not approved live copy.
- Review the chosen moment against its stable atlas node and current runtime context. Do not turn the two shared technical blockers into UX questions.
- End with either an explicit parked decision or one small approved implementation packet.

## Proof and change boundary

- No game files were modified during the workbook or disposition work.
- No game files or owner prose were modified during the race implementation audit.
- Direct readback confirmed the Imperial offers/responses, Concordat track, substrate, civic rewards, runtime quest, extracted service bindings, and ten-member origin-adapter list. The active source tree still differs from the repo mirror in 26 shared scripts and contains one additional test script, so source-route claims remain version-qualified until reconciled.
- Direct PEX review classified Manager `OriginRuntime`, Imperial Akatosh `HealSpell`, and Concordat `ExtremeStateIndexes` findings as intentional or inactive, not defects.
- The audit used the current census plus tracked race design, reward specs, transition coverage, and origin-runtime source. It is not fresh in-game presentation proof.
- Historical rows are not deleted from `PDV_RaceContent_Manifest.md` until the user records owner decisions and a separate cleanup is approved.
- The current branch is `fix/2.0-copy-uplift`; unrelated worktrees and dirty/untracked output files remain out of scope.
