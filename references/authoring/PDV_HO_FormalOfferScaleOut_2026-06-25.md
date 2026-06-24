# HO: Formal Commitment-Offer Scale-Out (audit + Codex build spec, 2026-06-25)

## What the owner asked
Audit ALL patron/champion-capable gods so each gets an **in-voice commitment-offer pop-up**,
and ensure **every offer names the god/prince** offering. Daedric Princes are "well done"
(separate pact/champion system) but their offer text does **not** name the Prince in the body --
add the Prince name **as a title** at the top.

## Audit result (verified 2026-06-25)
The formal-commitment-offer machinery (weight/cooldown/signal-days in `IsEligibleForFormalCommitmentOffer`)
is **generic**, but `UsesFormalCommitmentOffersForDeity -> IsNordOfferEligibleDeity` gates it
**Nord-only**, and `GetFormalCommitmentOfferMessage` maps **Nord deities only**.

| Status | Races |
|---|---|
| Offers wired + in-voice | **Nord** (13, done this session) · **Daedric Princes** (16, "well done") |
| **Copy authored + names deity, NOT wired** (the build) | **Imperial** (9 Divines) · **Dunmer** (Azura/Boethiah/Mephala) · **Altmer** (Auri-El/Magnus/Xarxes) · **Redguard** (Tu'whacca/Leki/HoonDing) |
| **By design, NO offer** (owner ruling: keep as-is) | **Bosmer** (path-choice = commitment) · **Khajiit** (silent moon-emergence, Arch v3 §12.4a) · **Argonian** (Hist substrate) · **Orc** (Malacath spine / life-mode) · **Breton** (tradition setup + 3 tradition-level champion entries, NOT per-deity; per-deity offers explicitly deferred, manifest 1990) |

All 18 unwired offers already name their deity in title+body (e.g. "Carry Tu'whacca as your own").
Copy lives in `references/authoring/PDV_FormalOffer_RecordWave.spec.json` (30 records: 18 offers
+ 12 responses).

## OWNER RULINGS (this session)
1. **Scope = Option 1:** wire the 4 copy-ready races (Imperial/Dunmer/Altmer/Redguard). Keep the
   5 by-design races on their intentional models.
2. **Breton confirmed:** champion moments are tradition-level (3), not per-deity; stays by-design.
3. **Daedric naming:** add the Prince's name **as the title** of each of the 16 Daedric offers
   (the body stays in-voice; the title states who is offering).

## THE BUILD -- the gate IS the spec
`node tools/pdv_formal_offer_check.mjs --source-only` enumerates EVERY required snippet (it
currently lists ~52 FAILs). Build to make it (and the full gate) PASS. Concretely:

### 1. Author the 30 records (Devotion.esp)
`dotnet run --project tools/pdv-phase20-race-author -- --author-rewards --rewards-spec
references/authoring/PDV_FormalOffer_RecordWave.spec.json --esp <Devotion.esp>` (the tool already
backs up + the `--check-rewards` path is what the gate calls). This authors the 18 offer MESGs +
12 response MESGs and VMAD-wires the manager properties. (Buttons are [Accept, Not yet, Refuse] =
choice 0/1/2, already in the spec.)

### 2. Manager properties (`PDV__ManagerQuest.psc`, after the Nord offer props ~465)
Declare all 30: `Message Property PDV_Msg_{Dunmer,Altmer,Imperial,Redguard}_{Deity}_Offer Auto`
(18) + `..._OfferResponse_{Accept,NotYet,Refuse} Auto` (12). Exact editorIds in the spec +
`pdv_formal_offer_check.mjs` `offerRoster` / `expectedResponseProperties`.

### 3. Race-aware dispatch (`GetFormalCommitmentOfferMessage`)
Rename the current Nord body to `GetNordFormalCommitmentOfferMessage(deity)`, and make
`GetFormalCommitmentOfferMessage` dispatch by `GetPlayerOriginRaceIndex()`:
```
if race == ORIGIN_NORD     return GetNordFormalCommitmentOfferMessage(deity)
elseIf race == ORIGIN_IMPERIAL  return GetImperialFormalCommitmentOfferMessage(deity)
elseIf race == ORIGIN_DUNMER    return GetDunmerFormalCommitmentOfferMessage(deity)
elseIf race == ORIGIN_ALTMER    return GetAltmerFormalCommitmentOfferMessage(deity)
elseIf race == ORIGIN_REDGUARD  return GetRedguardFormalCommitmentOfferMessage(deity)
```
+ the 4 new per-race functions mapping each deity -> its `PDV_Msg_<Race>_<Deity>_Offer`. (ORIGIN
constants: NORD=0 IMPERIAL=1 ALTMER=3 DUNMER=5 REDGUARD=9.) Shared Divines (Akatosh/Mara/...) must
return the IMPERIAL message for an Imperial player and the NORD message for a Nord player -- the
race dispatch handles that.

### 4. Eligibility (`UsesFormalCommitmentOffersForDeity`)
Change its return to:
`return IsNordOfferEligibleDeity(deity) || IsImperialOfferEligibleDeity(deity) || IsDunmerOfferEligibleDeity(deity) || IsAltmerOfferEligibleDeity(deity) || IsRedguardOfferEligibleDeity(deity)`
+ add the 4 helpers (each origin-gated + referencing its deities; rosters in the gate's
`helperExpectations`). Imperial adds `IsImperialTalosOfferAllowed()` gated on
`PDV_ConcordatStandingTrack.GetValue() <= 50` (Talos only offered when not Thalmor-aligned).

### 5. Diegetic cue + offer presentation
Add `Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction,
PDV_DeityBase deity, String toneOverride = "")` (mirror the existing `SurfaceTransition` ->
DiegeticDirector path), and call it in `ShowFormalCommitmentOffer`:
`DispatchDiegeticCue("offer", deity.DeityName, "present", deity, "revelation")` before `.Show()`,
and `DispatchDiegeticCue("offer", deity.DeityName, "accept", deity, "reverent")` after choice 0.

### 6. Quiet-emergence cues (the 5 by-design races surface their commitment diegetically)
The gate requires 7 `SurfaceTransition(...)` cues + `GetKhajiitFocusDeity` / `GetBretonTraditionDeity`
helpers (exact strings in `pdv_formal_offer_check.mjs` `quietEmergenceSnippets`): Khajiit focus +
Breton tradition = "emergence"/"reach"/"revelation"; Orc/Bosmer/Redguard = "reorientation"/"shift"/
"turning". These make the no-offer races announce their (silent) commitment without a pop-up.

### 7. Daedric naming (separate, owner ruling 3)
For the 16 Daedric pact/champion offer MESGs, set the record **title** to name the Prince (body
unchanged). Find them via the Daedric offer/champion presentation (`ShowDaedricMilestonePresentation`
~12928 + the Daedric pact-offer records); author the title via a Mutagen author (clone
`tools/pdv-nord-offer-author` -- MESG title edit only).

## Verify (acceptance)
`pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> **`pdv_formal_offer_check.mjs` PASS** (the definitive
gate -- source flow + ESP readback) -> `pdv_signal_e2e_gate` 0 RED -> `pdv_integrity_harness` PASS.
Sync live-source -> MO2 before compiling. In-game proof (offers fire per race at threshold; names
read clearly) is owner-gated (new save / coc qasmoke).

## Why handed off (not built inline)
The audit + design rulings are done (above). The build is ~52 gate-specified items spanning a
dispatch refactor, a diegetic-cue subsystem touch, and emergence cues across 5 race paths -- bulk
Papyrus + a record-author run, fully specified by the gate. Ideal for a focused Codex pass;
acceptance = `pdv_formal_offer_check.mjs` PASS.
