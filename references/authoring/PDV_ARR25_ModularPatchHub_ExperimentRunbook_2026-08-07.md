# Devotion ARR 2.5 Modular PatchHub Experiment Runbook

## Status and target

This is an experimental machine-verified candidate for ARR 2.5, profile `KoK R11`. It is not a supported compatibility release. Runtime routing, semantic observation, player-facing UI, save/load behavior, and per-option support remain separate proof obligations.

Use these two archives together:

1. `Devotion-1.0.4-20260807.zip`
2. `PDV-QuestModPatchHub-ARR25-Experimental-20260807.zip`

The core archive contains the shared runtime, Book of Days and Prisma UI contract, Altmer and Khajiit updates, the 2,144-cell vanilla/DLC/Creation Club matrix, and the generic per-mod channel/adapter loader. The PatchHub contains 41 independent source-mod-gated options. There is no Authoria combined option and no list-wide patch ESP.

## Installation

1. Create or clone a disposable ARR 2.5 test profile based on `KoK R11`.
2. Install the Devotion core archive as its own mod and enable it.
3. Install the PatchHub archive below Devotion in MO2 and enable it.
4. In the FOMOD, select only the options whose dependency is present. Recommended options are detected from the active source plugin; no option is required merely because ARR is being used.
5. Keep `Devotion.esp` enabled. Enable any narrow patch ESP installed by a selected option and sort it after its masters. The AFDI and Daedric Shrines AIO options each install their own ESL-flagged plugin; the AFDI option also installs its `.seq`.
6. Do not install or retain `PDV_AuthoriaARR_Combined.esp`, `PDV_QuestReactionMatrix_ARR.json`, or an older PatchHub core-script override.
7. Start from a save made before the outcome under test where practical. Keep a separate fallback save.

## Expected UI behavior

For one resolving quest outcome, expect at most one transient Devotion toast and one Book of Days beat, even when several deities react. Piety detail may name multiple deities inside that single surface.

Altmer are not excluded from Prisma UI. Their accepted heritage/practice notices use the same transient-toast policy as other races:

- a credited heritage or practice act may produce one toast and one Book of Days entry;
- zero-credit or rejected acts remain silent;
- a genuine tier transition may add its separate Chronicle/tier beat;
- gameplay must not open or focus the full Prisma panel or Book of Days.

Record any duplicate toast, duplicate Book entry, focused-panel opening, missing notice, or incorrect deity/valence as a failure.

## Minimum experiment record

For every option tested, record:

- PatchHub option and source-plugin version;
- save and route marker or quest/stage reached;
- expected and observed deity, valence, and piety result;
- toast count and text;
- Book of Days beat count and text;
- behavior after save/load;
- Papyrus errors or stack dumps;
- pass/fail and attached screenshot/log evidence.

Controlled `setstage` may prove routing but does not prove inferred semantics. Rows marked `RUNTIME-VERIFY`, especially objective-derived outcomes, require observation through ordinary quest progression before their flag can be cleared.

## Special options

### Aetherium Forge Destroys Items

The option begins by baselining already-destroyed artifacts so an existing save receives no retroactive piety. Only later successful destruction transitions should route, once each. Confirm one combined UI surface even when the destruction affects several deities.

### Daedric Shrines AIO

The option swaps eleven supported statue bases to Devotion prayer activators. Confirm the correct shrine identity, one daily award only, one toast, and one Book entry. Jyggalag remains classification-only and is not included.

### Thieves Guild Alternative Endings

The option is data-only. Its adapter maps the physical TG09 stage 200 into the appropriate synthetic outcome stage from the source mod's selector global. Confirm the selected ending routes and that the alternate ending does not incorrectly trigger Nocturnal commitment.

## Support boundary

Passing static gates or installing successfully means machine-verified experimental only. A PatchHub option becomes supportable only after equivalent runtime, player-surface, semantic, and save/load evidence is recorded for that option.
