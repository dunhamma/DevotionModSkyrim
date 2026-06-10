# B4 Authored Arcs -- Buildable Spec

**Status:** DESIGN COMPLETE, 2026-06-10.
Precondition: LD-P2 smoke closed (mood-persistence, demand-loop, faucet-breadth,
Hircine-gate items from `05_ld_p2_architecture.md` 7). Do not start B4 wiring until then.
Function names are the contract; line numbers drift.

---

## 1. StorageUtil namespace (new `PDV.Bond.*`)

All keys stored per deity form (same pattern as `PDV.Mood.*`, `PDV.Demand.*`).
No JContainers. All reads fail-closed to safe defaults.

```
; Bond-stage ladder (Mechanism A)
PDV.Bond.<deity>.Stage             (int, 0-4)          ; default 0 = Unnoticed
PDV.Bond.<deity>.StageEntryDay     (int)               ; devotion-day index when current stage was entered
PDV.Bond.<deity>.LastAdvanceReason (string)            ; "time_gate" or the bond_advance_tag string

; Reminiscence flags (Mechanism B)
; One key per authored flag. Max 4 per deity (self-test gate).
PDV.Bond.<deity>.Remi.<flagKey>    (int, 0 or 1)       ; set once, never cleared

; BDI prefer counters (Mechanism C)
; One key per demand type in the deity's demandKeys pipe-list. Bounded at 5.
PDV.Bond.<deity>.Prefer.<demandType>  (int, 0-5)

; Dread axis -- coercive Princes only (Mechanism D)
PDV.Bond.<deity>.Dread             (float, 0.0-100.0)  ; default 0.0
PDV.Bond.<deity>.DreadBand         (int, 0-3)          ; 0=Defiant, 1=Compliant, 2=Subjugated, 3=Enslaved
```

---

## 2. Authoring tables

### 2.1 New: `PDV_BondProfile.csv`
One row per deity. Columns:
`deity, bond_advance_days_S1, bond_advance_days_S2, bond_advance_days_S3, bond_advance_days_S4,
bond_advance_min_tier, bond_advance_min_band, remi_flags (pipe-list of flagKey names),
is_coercive (bool), dread_decay_rate, dread_subjugation_requires_defiance_tag`

Compiled to `bond.<deity>.*` block in `LIVING_DEITIES_FILE`.

### 2.2 Extended: `PDV_DemandTable.csv`
New columns (optional; default = empty = not a bond-advance demand):
`bond_advance_tag` -- if non-empty, fulfilling this demand triggers a `TryAdvanceBondStage`
check on the ritual path.
`reminiscence_key` -- if non-empty, fulfilling this demand sets `PDV.Bond.<deity>.Remi.<key>`.

### 2.3 Extended: `PDV_QuestReactionMatrix_Full.csv`
Rows with `magnitude == milestone` may carry a new optional column `bond_remi_key`
(flagKey to set when this row fires in `ApplyQuestReaction`). Compiler validates that
every referenced key appears in `PDV_BondProfile.csv:remi_flags` for the named deity.

### 2.4 New: `PDV_BondTextBank.csv`
Columns: `deity, stage, remi_key (or empty), text_slot (stage_toast/dream/omen),
text_key, fallback_text_key`
Compiled to `bond.<deity>.stage<N>.<slot>.textKey` and
`bond.<deity>.remi.<flagKey>.<slot>.textKey` in `LIVING_DEITIES_FILE`.
`fallback_text_key` used when the slot fires but conditions are not met.

---

## 3. Runtime shape: where each mechanism runs

### 3.1 Bond-stage advance: `RunDawnCheckBondAdvance(deity)` (Mechanism A)
**Inserted once** in `ProcessDawn()` as a sub-phase after `RunDawnProcessDemandsNoop()`,
before `RunDawnNotifyNoop()`:
```
RunDawnCheckBondAdvanceNoop()     ; NEW -- evaluates stage advance for each pool deity
```

Logic per deity in the pool (filtered by `HasRecentCommitmentSignalDays`):
```
Int stage = StorageUtil.GetIntValue(deityForm, "PDV.Bond.<deity>.Stage")
if stage >= 4
    return  ; cap at Beloved/Feared
endIf
Int currentDay = GetCurrentDevotionDay()  ; existing dawn counter
Int entryDay   = StorageUtil.GetIntValue(deityForm, "PDV.Bond.<deity>.StageEntryDay")
Int advDays    = ReadBondAdvanceDays(deity, stage)  ; from LIVING_DEITIES_FILE
Int minBand    = ReadBondAdvanceMinBand(deity)
Bool timeGate  = (currentDay - entryDay >= advDays) && (GetDeityMoodBand(deity) >= minBand)
                 && (GetStoredTier(deity) >= ReadBondAdvanceMinTier(deity))
if timeGate
    TryAdvanceBondStage(deity, "time_gate")
endIf
; Ritual-gate fires from FulfillDemand (see 3.2) -- NOT checked again here
```

`TryAdvanceBondStage(deity, reason)`:
- Increments `PDV.Bond.<deity>.Stage`
- Sets `PDV.Bond.<deity>.StageEntryDay` to currentDay
- Sets `PDV.Bond.<deity>.LastAdvanceReason` to reason string
- Calls `OnBondStageAdvance(deity, newStage)` which dispatches a stage-advance toast
  via `SendPrismaEventToast("bond_advance", deity, stage_label, ...)` and a
  `SurfaceTransition("bond", deity.DeityName, "advance", deity.DeityIndex, tone)` call
  into the live `PDV_DiegeticDirector.Dispatch` path.

### 3.2 FulfillDemand additions (Mechanisms A, B, C)
After the existing `FulfillDemand` logic (clear pending, mood uplift, single-act reset):

```
; Mechanism B: reminiscence flag
String remiKey = ReadDemandReminiscenceKey(deity, currentDemandKey)
if remiKey != ""
    StorageUtil.SetIntValue(deityForm, "PDV.Bond." + deity.DeityName + ".Remi." + remiKey, 1)
endIf

; Mechanism A: ritual advance gate
String advanceTag = ReadDemandBondAdvanceTag(deity, currentDemandKey)
if advanceTag != ""
    TryAdvanceBondStage(deity, advanceTag)
endIf

; Mechanism C: prefer counter
String demandType = ReadDemandType(deity, currentDemandKey)
if demandType != ""
    String preferKey = "PDV.Bond." + deity.DeityName + ".Prefer." + demandType
    Int current = StorageUtil.GetIntValue(deityForm, preferKey)
    if current < 5
        StorageUtil.SetIntValue(deityForm, preferKey, current + 1)
    endIf
endIf
```

### 3.3 ApplyQuestReaction addition (Mechanism B)
After the existing piety/stigma routing in `ApplyQuestReaction(Quest, Int stageValue)`:

```
; Reminiscence: set flag for milestone-magnitude rows that carry a bond_remi_key
String remiKey = ReadMatrixReminiscenceKey(sourceQuest, stageValue)  ; reads LIVING_DEITIES_FILE
if remiKey != "" && matchedDeity != None
    StorageUtil.SetIntValue(matchedDeity, "PDV.Bond." + matchedDeity.DeityName + ".Remi." + remiKey, 1)
endIf
```

### 3.4 SelectDemandKey bias (Mechanism C)
In `SelectDemandKey(deity, trigger)` (LD-P2 `05_ld_p2_architecture.md` 3.2), after
reading the pipe-list and applying the trigger-keyed base weights, apply the prefer bias:

```
; For each key in the pipe-list:
;   baseWeight[i] += preferWeight * StorageUtil.GetIntValue(deityForm,
;                       "PDV.Bond.<deity>.Prefer.<demandType[i]>")
; where preferWeight is a small authored constant (e.g. 0.15 per counter point)
; Normalize weights before selection. Bounded counters (max 5) cap the bias at 0.75.
```
The trigger-type hard gate (band_down demand not offered via expect_red trigger) is
applied BEFORE the bias step and is not overridden.

### 3.5 Dream dispatch (Mechanism B) -- in `PDV_PlayerEvents.psc:OnSleepStart`
After the existing deity/probability check for dream dispatch:

```
; Look for a reminiscence override
PDV_DeityBase activeDeity = GetActivePatronOrTopPoolDeity()
if activeDeity
    String dreamKey = ResolveReminiscenceDreamKey(activeDeity)  ; checks all set Remi flags,
                                                                  ; picks highest-stage set flag
    if dreamKey != ""
        SendPrismaEventToast("bond_dream", activeDeity, dreamKey, ...)
        SurfaceTransition("bond", activeDeity.DeityName, "dream", activeDeity.DeityIndex, "revelation")
        return  ; consumed; skip generic dream
    endIf
endIf
; fall through to generic dream pool
```

### 3.6 Dread axis (Mechanism D) -- `RunDawnDecayDread(deity)` dawn sub-phase
Only runs for deities where `bond.<deity>.isCoercive == true`.
```
Float dread = StorageUtil.GetFloatValue(deityForm, "PDV.Bond.<deity>.Dread")
Float decayRate = ReadDreadDecayRate(deity)
dread = Math.Max(0.0, dread - decayRate)
StorageUtil.SetFloatValue(deityForm, "PDV.Bond.<deity>.Dread", dread)
Int newBand = ComputeDreadBand(dread)  ; thresholds: 0=0-24, 1=25-59, 2=60-84, 3=85-100
Int oldBand = StorageUtil.GetIntValue(deityForm, "PDV.Bond.<deity>.DreadBand")
if newBand != oldBand
    StorageUtil.SetIntValue(deityForm, "PDV.Bond.<deity>.DreadBand", newBand)
    OnDreadBandCross(deity, oldBand, newBand)
endIf
```

Dread accrual fires in `ScorePrinceAction` (live `PDV_DaedricPathBase.psc:58`) when
`demand_type == submission` AND the demand was fulfilled during band <= MOOD_BAND_COOL:
```
Float dreadAccrual = ReadDreadAccrualRate(deity)  ; authored per demand row
StorageUtil.SetFloatValue(deityForm, "PDV.Bond.<deity>.Dread",
    Math.Min(100.0, StorageUtil.GetFloatValue(deityForm, "PDV.Bond.<deity>.Dread") + dreadAccrual))
```

Hard-defiance reset: a curated matrix tag `defy_<deityName>` (e.g. `defy_molag`) at
stage >= Bound zeroes `PDV.Bond.<deity>.Dread` and fires an `OnDreadBandCross` to band 0.

---

## 4. Verifier expectations

Extend `tools/pdv_living_deities_selftest.mjs`:
- Every deity in `PDV_BondProfile.csv` has numeric `bond_advance_days_S1..S4` and
  `bond_advance_min_tier`; no row has `remi_flags` count > 4.
- Every `bond_remi_key` in `PDV_QuestReactionMatrix_Full.csv` appears in its deity's
  `remi_flags` list.
- Every `reminiscence_key` in `PDV_DemandTable.csv` appears in its deity's `remi_flags`.
- Every `bond_advance_tag` in `PDV_DemandTable.csv` is a unique string (not duplicated
  across stages for the same deity).
- Every `(deity, stage, text_slot)` in `PDV_BondTextBank.csv` has a non-empty `text_key`
  and `fallback_text_key`.
- Coercive deities have `dread_decay_rate` > 0 and `dread_subjugation_requires_defiance_tag`
  non-empty; non-coercive deities have all Dread columns empty.
- `PDV_BondTextBank.csv` `remi_key` rows reference only keys declared in
  `PDV_BondProfile.csv:remi_flags` for the same deity.

Runtime readback (in-CK/in-game proof session):
- `PDV.Bond.*` keys present and bounded after seeded advance sequence.
- Stage advance fires once per stage; `StageEntryDay` updates; dual gate both paths verified.
- Reminiscence flag set by `ApplyQuestReaction` after the relevant matrix quest stage fires.
- Reminiscence dream chosen over generic pool when flag is set; generic chosen when not.
- Prefer counter increments; `SelectDemandKey` skews distribution after 3+ fulfills.
- Dread accrues on submission act; decays at dawn; band text changes at band boundary.
- No Dread movement for non-coercive deities.

---

## 5. Build-order hand-off

1. Authoring: author `PDV_BondProfile.csv`, extend `PDV_DemandTable.csv` + matrix CSV
   + `PDV_BondTextBank.csv`; run self-test gate.
2. Extend `pdv_living_deities_compile.mjs` with bond block; re-run self-test.
3. Papyrus wiring (in order):
   a. `FulfillDemand` additions (B, A ritual gate, C prefer counter) -- smallest change,
      highest value, fully recomposition.
   b. `ApplyQuestReaction` reminiscence write -- one conditional, no new parameter.
   c. `RunDawnCheckBondAdvance` sub-phase + `TryAdvanceBondStage` + `OnBondStageAdvance`.
   d. `SelectDemandKey` bias input (after LD-P2 mechanism 3 is wired + smoke-proven).
   e. `OnSleepStart` reminiscence dream dispatch.
4. Dread axis: deferred. Wire only after `PDV_Deity_Molag` greenfield actor is owner-
   approved and authored (same checklist as `PDV_Deity_Hircine`: QUST, SGE+SEQ, stance
   rows, VMAD wiring).
5. CK: no new ability records required for V1 text-only scope. CK records needed only if
   `D1Enabled` is flipped for the bond modalities (IMOD/sound records for advance moment).
6. Compile + in-game proof per verifier items above.
