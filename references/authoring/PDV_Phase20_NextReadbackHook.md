# PDV Phase 20 Next Readback Hook

**Created:** 2026-06-03
**Status:** Next-session handoff for all-race exact-source readback
**Owner:** Companion to `PDV_Phase20_AllRaceSourceCuration_Runbook.md`

## Paste-In Hook

Continue Phase 20 from the all-race exact-source curation boundary. Do not
promote scan-only quest candidates into live FormLists or route sources. The
next task is readback only: select and inspect exact candidate source records
for all ten race immersive hook contracts, then produce an approved-source
dossier that says which records are safe to fill later and which remain
manual-only or rejected.

Start from:

- `references/authoring/PDV_Phase20_NoInGameProof_Gates.json`
- `references/authoring/PDV_Phase20_AllRaceSourceCuration_Runbook.md`
- `references/authoring/PDV_Phase20_P2SourceCuration_Runbook.md`
- `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`
- `references/vanilla-gameplay/extracted/vanilla-quest-candidates.csv`
- `references/vanilla-gameplay/extracted/vanilla-book-signal-candidates.csv`
- `references/vanilla-gameplay/extracted/vanilla-spell-effect-candidates.csv`
- `references/vanilla-gameplay/pdv-crosswalk/quest-moral-signal-crosswalk.csv`
- `references/vanilla-gameplay/pdv-crosswalk/hook-recipe-cards.md`

For each proposed source, record:

- race
- route family
- source kind
- exact form key in `ModName.ext:localHex` form
- EditorID and display name if available
- accepted context
- rejected context
- anti-farm rule
- route target
- readback evidence source
- approval status: `approved-for-fill`, `manual-only`, `rejected`, or
  `needs-stage-readback`

Quest-stage sources require stronger readback before approval:

- exact quest record
- exact stage or mutually exclusive outcome
- whether every observed stage change is safe for the intended route family
- duplicate guard
- rejected nearby stage or generic quest-progress case

If the receiver cannot distinguish the meaningful stage from generic quest
progress, do not approve the quest for FormList fill. Keep it manual-only or
design a narrower receiver.

## Required Output

Create or update a source curation artifact under `references/authoring/` that
contains all approved and rejected readback decisions. Do not write to the ESP
and do not run `--fill-source-entries` unless the user explicitly asks for the
fill step after reviewing the dossier.

After the dossier is written, run:

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
```

## Stop Conditions

Stop and report instead of filling sources if:

- any source is only a scan-table candidate
- a quest source has no exact stage or outcome readback
- a route would fire from generic quest progress, generic book reading, generic
  travel, generic crime, generic combat, or generic crafting
- a source would double-score through two receiver families
- a source needs a new receiver shape rather than an existing FormList
- a source would require a new mesh or visual asset

Current expected asset posture remains: no required new custom mesh assets for
the end-state hook network.
