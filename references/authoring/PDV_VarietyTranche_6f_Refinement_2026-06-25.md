# 6f Variety Tranches -- Authoring Refinement (Codex Handoff, 2026-06-25) [queue B]

Companion delta to `PDV_VarietyTranche_6f_Handoff_2026-06-25.md`. Read that doc first;
this note only narrows the Per-race table to ALREADY-PRESENT vs MISSING after a live grep
of `live-source/Scripts/Source/PDV__ManagerQuest.psc`.

## Goal
Stop 6f authoring from re-building Orc families that already ship. Author only the genuinely
missing Altmer / Redguard / Orc-tail variety rites, mirroring the shipped Bosmer Naming and
Orc Code-Holds records.

## Closeout check (2026-06-24)

Verified-current-state before authoring. Orc is more complete than the initial queue note:
`Hearth-Held`, `The Code Holds`, `Four Holds`, and the four `TrialOfIron` spell properties
are present in the live manager and sync cleanup path. Altmer and Redguard remain mostly
missing at runtime, but their underlying draft manifests still carry a hard effect-review
gate, and `PDV_RaceEffectReviewLedger.md` still marks Altmer, Orc, and Redguard as
`Pending`. No new 6f records or Papyrus signals were authored in this pass; authoring stays
blocked until the row review ratifies magnitudes/effect axes and resolves the open
private-context / form-ID / AV decisions.

## Verify-current-state FIRST (mandatory -- multiple items already-built this session)
The authoring-spec workflow (w24lhsscd) found Orc PARTIAL. Before authoring ANY family,
grep the live manager for each named family below and mark its status ALREADY-PRESENT /
PARTIAL / MISSING. Build only MISSING. Do not trust this table over a fresh grep.

## Per-family status (live grep 2026-06-25)
| Race | Family | Status | Live seam |
|---|---|---|---|
| **Orc** | `Hearth-Held` | ALREADY-PRESENT | `MaybeShowOrcHearthHeldNotice` ~5559; `PDV_SPEL_OrcHearthHeld` prop ~359 |
| **Orc** | `The Code Holds` | ALREADY-PRESENT | `TryOrcCodeHolds` ~4165 (dispatched ~4099) |
| **Orc** | Four Holds visit | ALREADY-PRESENT | `HandleOrcFourHoldsVisit` ~5284 (dispatched ~5203) |
| **Orc** | Trial of Iron disciplines (rite) | grep to confirm -- likely MISSING; author if absent |
| **Altmer** | `Ordered Mind`, `Syrabane's Hand`, Chantry, Disciplines of Return (rite) | MOSTLY MISSING -- only `ApplyAltmerAlignmentAction` ~6593 + curse handlers ~12578 exist; no named-rite family |
| **Redguard** | Leki sword-tending, `Leki's Measure`, `Tava's Departure`, `The Unclean Hour`, Halls, Remembering of Names (rite) | MOSTLY MISSING -- only Ash'abah duty (`ApplyRedguardAshAbahDutyRewards` ~5826) + curse handlers ~12701 + initial choice ~13122 exist; no named-rite family |

Orc authoring SKIPS Hearth-Held / The Code Holds / Four-Holds-visit (all wired). Only the
Orc rite-discipline family (if grep confirms absent) is in scope for Orc.

## Template: the Bosmer Naming rite (mirror this exactly)
The locked one-active / one-shot / once-day contract is already coded for Bosmer -- copy its shape:
- `TryBosmerNaming` ~3786: site/eligibility gate; 7-day cooldown via
  `PDV.BosNaming.LastRiteTime` (`Utility.GetCurrentGameTime() - lastRite < 7.0` rejects);
  "Not yet" (pressed out of 0..3) returns true WITHOUT spending the cooldown (~3810).
- `ApplyBosmerNaming` ~3819: CLEAR-BEFORE-ADD (`RemoveBosmerNamingSpells` first, then one
  AddSpell); records `Active` + `PathAtRite` so the sync pass can fade/restore.
- `SyncBosmerNaming` ~3862 (dawn pass, dispatched ~8247): fade-on-incoherence /
  restore-on-recovery; `Active` stays set while quiet so no re-rite is needed.

Per-race rites name 4 disciplines (Disciplines of Return / Trial of Iron / Remembering of
Names) exactly as the 4 Bosmer told-selves -- one active, swap clears prior, dawn fade/restore
keyed on that race's coherence predicate (mirror `IsBosmerNamingCoherent` ~3890).

## Steps
1. grep-confirm status per family (table above is a starting point, not ground truth).
2. Author missing SPEL/MGEF via `pdv-<race>-variety-author` (the per-race variety reward tool),
   mirroring the shipped Bosmer Naming and Orc Code-Holds / Hearth-Held records.
3. Wire manager Try/Apply/Sync trio per missing rite using the Bosmer seams above; reuse the
   existing dawn pass for fade/restore (do not add a new update tick).
4. Magnitudes PROVISIONAL -- scale to Rooted-Rest; pass the `PDV_RaceEffectReviewLedger.md`
   race-row review.

## Serialize note
Manager-touching (Try/Apply/Sync trio + dawn-pass dispatch in `PDV__ManagerQuest.psc`) =
SERIALIZE with any concurrent manager work. ESP reward records serialize with concurrent
ESP writers.

## Verify
- `node tools/pdv_compile.mjs` 0/0
- `node tools/pdv_verify.mjs` FAIL=0
- `node tools/pdv_signal_e2e_gate.mjs` 0 RED
- `node tools/pdv_integrity_harness.mjs` PASS
