# PDV Balancing — Implementation Handoff (for Codex)

This is the single, ordered worklist to apply the locked balancing decisions to the Papyrus source.
Every decision below is already settled in the design docs; this file maps each one to the **exact
script, function, and edit** so no re-derivation is needed.

## How to read this

- **All edits are in `PDV__ManagerQuest.psc`** unless a task says otherwise.
- **Locate by FUNCTION NAME, not line number.** Bracketed line numbers like `[~1117]` are hints from
  the Phase-18 handoff snapshot (`handoff/Devotion_Phase18_Nord_Beta_.../Source-Papyrus/`); the live
  source on the dev rig may have drifted. Function names are stable.
- **New constants** are `Float/Int Property … = X AutoReadOnly` added to the constants block
  (alongside `DECAY_PER_DAY`, `PIETY_DAILY_MAX_DELTA`, etc., `[~75–135]`).
- Code snippets are illustrative Papyrus — adapt to the live source's surrounding style.

## Source-of-truth docs (read before editing)

| Doc | What it locks |
|---|---|
| `references/authoring/PDV_PietyPaceBalancingTable.md` | calendar, clamp, per-act values |
| `references/authoring/PDV_DecayAudit.md` | grace, hysteresis, curse-floor, Orc decay |
| `references/authoring/PDV_SignalDensityAudit.md` | per-mode calendars, the 3.3/day bar |
| `references/authoring/PDV_TriggerTopups_Exchange_KnightsRoad.md` + `…_DetectionProbe_Runbook.md` | the two new trigger families (probe-gated) |
| `race-sheets/PDV_RaceDesign_Orc.md` (Mode ceiling LOCKED, ~:219) | Orc multiplier theology |

## Target outcome (what "done" looks like)

| | Observant (25) | Faithful (50) | Devoted/Champion (85) |
|---|---|---|---|
| Normal god, default | ~8 days | ~15 | ~26 |
| Normal god, ceiling (maximizer) | ~6 | ~12 | ~20 |
| Orc Stronghold | 8 | 15 | 26 |
| Orc City (×0.75) | 10 | 20 | 34 |
| Orc Legion/Exile (×0.60) | 13 | 25 | 43 |

---

## Task 1 — Compress the calendar (global gain scale + clamp)

**Why:** raise realized gain from ~2.5 → ~3.3 piety/day and set the maximizer ceiling to 4.3/day.
**Where:** `Function ProcessDawn()` `[~1087]`, constants block `[~86]`.

1. Change the clamp constant: `PIETY_DAILY_MAX_DELTA` `5.0 → 4.3`. *(Note: the snapshot still has 5.0 —
   the balancing doc's earlier "lower the clamp" step was never applied; 4.3 implements it now.)*
2. Add a new constant: `Float Property GAIN_RATE_SCALE = 1.32 AutoReadOnly` *(= 3.3 / 2.5)*.
3. In `ProcessDawn`, edit the per-deity clamp line `[~1117]`:
   ```
   ; OLD:
   Float clampedToday = ClampValue(pietyToday, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)
   ; NEW:
   Float clampedToday = ClampValue(pietyToday * GAIN_RATE_SCALE, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)
   ```

**Do NOT** edit per-deity `SIGNAL_*` properties or favor-spell magnitudes. Those raw values are
distributed across every deity script; the single global `GAIN_RATE_SCALE` scales the whole realized
distribution uniformly and is correct regardless of each raw value. This is the surgical knob.

**Milestones are unaffected** — they apply via a direct `Adjust(...)` that bypasses `ProcessDawn`
(and the clamp), so `GAIN_RATE_SCALE` never touches them. Leave milestone magnitudes at face value;
the balancing doc's "+6/+10" is nominal and need not be rescaled (a face-value +5 is still ~1.5 days
and safe).

**Acceptance:** a steady day (1 prayer + 1 standard favor) adds ~3.3 to persistent `PDV.Piety`; a
maximizer caps at +4.3/day; thresholds land at ~8/15/26 days.

---

## Task 2 — Orc life-mode gain multiplier (AFTER the clamp, gain only)

**Why:** City/Legion Orc accrue Malacath piety slower (the calendars above). **Correction to earlier
docs:** they said "apply the multiplier *before* the clamp" — that is **wrong** with a fixed clamp
(a City maximizer would still hit 4.3). Multiplying the **already-clamped** daily gain scales *both*
the typical day (×0.75 → 2.5) and the ceiling (×0.75 → 3.2). Apply it **after** the clamp.
**Where:** `ProcessDawn()` (right after the Task 1 line); new helper; constants block.

1. Add constants:
   ```
   Float Property ORC_RATE_MULT_STRONGHOLD  = 1.00 AutoReadOnly
   Float Property ORC_RATE_MULT_CITY        = 0.75 AutoReadOnly
   Float Property ORC_RATE_MULT_LEGIONEXILE = 0.60 AutoReadOnly
   ```
2. In `ProcessDawn`, immediately after the clamp line:
   ```
   clampedToday = clampedToday * GetOrcLifeModeGainMultiplier(deity)
   ```
3. Add the helper (returns 1.0 for everything except the Orc's Malacath lane):
   ```
   Float Function GetOrcLifeModeGainMultiplier(PDV_DeityBase deity)
       if deity != PDV_Malacath           ; only Malacath is mode-scaled
           return 1.0
       endIf
       if PlayerRef.GetRace() ... != Orc  ; only for Orc players (use the existing race check)
           return 1.0
       endIf
       Int mode = PDV_GLO_OrcLifeMode.GetValueInt()   ; or PDV_StateTrack_OrcLifeMode
       if mode == 1            ; Stronghold (see enum: City=0, Stronghold=1, LegionExile=2)
           return ORC_RATE_MULT_STRONGHOLD
       elseIf mode == 2        ; Legion/Exile
           return ORC_RATE_MULT_LEGIONEXILE
       endIf
       return ORC_RATE_MULT_CITY            ; City (0) and default
   endFunction
   ```
   *(Enum values from `PDV_Phase20OrcImplementationCosting.manifest.json`: City=0, Stronghold=1,
   LegionExile=2. Use whichever life-mode surface the live build reads — global mirror or state track.)*

**Decay must NOT be scaled.** Do **not** add this multiplier to `ApplyDecayToDeity`. Orc passive decay
stays at the universal base rate (locked decision — exile faith has no passive reinforcement, so it
must not decay slower).

**Acceptance:** with `PDV_GLO_OrcLifeMode = LegionExile`, Malacath steady gain ≈ 2.0/day, ceiling
≈ 2.6/day → 13/25/43; City ≈ 2.5/day → 10/20/34; non-Orc deities unchanged.

---

## Task 3 — Tier-down hysteresis (anti-whiplash)

**Why:** a freshly-earned tier sits on its threshold and would drop on the first decay tick. Require
piety to fall 5 *below* the threshold before the tier label drops.
**Where:** `Int Function RecomputeTier(PDV_DeityBase deity)` `[~1008]`; new helper; constant.

1. Add `Float Property TIER_DOWN_HYSTERESIS = 5.0 AutoReadOnly`.
2. Add a helper returning a deity's threshold for a given tier:
   ```
   Float Function ThresholdForTier(PDV_DeityBase deity, Int tier)
       if tier >= TIER_CHAMPION
           return deity.ThresholdChampion
       elseIf tier >= TIER_DEVOTED
           return deity.ThresholdDevoted
       elseIf tier >= TIER_SEEKER
           return deity.ThresholdSeeker
       endIf
       return 0.0
   endFunction
   ```
3. In `RecomputeTier`, between `Int newTier = ComputeTierFromPiety(deity, piety)` and
   `RefreshPassiveDecayFloorForDeity(deity, newTier)`, insert:
   ```
   if newTier < oldTier                      ; downward transition — apply hysteresis
       if piety >= (ThresholdForTier(deity, oldTier) - TIER_DOWN_HYSTERESIS)
           newTier = oldTier                 ; hold the tier; not far enough below to demote
       endIf
   endIf
   ```
   Ensure `RefreshPassiveDecayFloorForDeity` and the `PDV.Tier` write use the **post-hysteresis**
   `newTier`. Upward transitions are unchanged (hit the threshold → promote immediately).

**Acceptance:** a deity at exactly 85 (just hit Champion) stays Champion until piety < 80; under
base decay (0.5/day, 2-day grace) that's ~12 idle days before the label drops.

---

## Task 4 — Tighten decay grace 3 → 2 days

**Why:** decided — the meter should breathe; coverage keeps engaged gods tended daily so this only
catches genuine neglect.
**Where:** constants block `[~87]`.

- `DECAY_GRACE_DAYS` `3.0 → 2.0`.

**Acceptance:** `ApplyDecayToDeity` no-ops when `(now - PDV.LastEventGameTime) < 2.0`; decays at ≥ 2.0.

---

## Task 5 — Vampire curse decay bypasses the floor (true excommunication)

**Why:** decided — vampirism severs the bond with the Divines; werewolf is strain, not severance.
**Where:** `Float Function GetDecayFloorForDeity(PDV_DeityBase deity, Float currentPiety)` `[~1626]`.

1. Need an Aedric/Divine predicate on the deity. If one does not already exist, add
   `Bool Property IsAedric = False Auto` to `PDV_DeityBase.psc` and set it **true** on the Nine
   Divines deity records, **false** on Daedra / Hist / ancestor / Malacath. *(Vampirism only
   excommunicates from the Aedra.)*
2. At the top of `GetDecayFloorForDeity`, before the normal floor logic:
   ```
   if PDV_CurseStateService && PDV_CurseStateService.IsVampire() && deity.IsAedric
       return 0.0                 ; vampire severs Aedric piety entirely — no protective floor
   endIf
   ```
   Curse state already **accelerates** the decay rate via `GetCurseGainMultiplier` in
   `ApplyDecayToDeity` `[~1261]`; this change only removes the **floor** for vampires. `IsWerewolf()`
   gets no floor change.

**Acceptance:** a vampire's Aedric piety can decay to 0; a werewolf's (and a vampire's Daedric/Hist)
still stops at the tier floor.

---

## Task 6 — Verify thresholds (assumption check, usually no edit)

The whole calendar assumes `deity.ThresholdSeeker / ThresholdDevoted / ThresholdChampion = 25 / 50 / 85`
on **every** deity (used by `ComputeTierFromPiety` `[~3859]` and the floor logic). Confirm; fix any
deity that diverges.

---

## Task 7 — Re-prove

1. Re-run the Phase-17 decay proof paths (`DebugRunDecayProofDaysByIndex`, grace/eligible/floor
   traces). Expectations shift with the new constants: grace no-op now at <2 days; fresh-tier label
   holds ~12 idle days (hysteresis); vampire Aedric floor = 0.
2. Gates: `node ./tools/pdv_verify.mjs --strict-phase17` and the full bridge gate (see
   `PDV_Architecture_v3.md` §15.5). Expect clean.
3. Update the §15 pseudocode in `PDV_Architecture_v3.md` to match once proven (the forward-retune
   note there flags exactly these changes).

---

## Task 8 — Trigger top-ups (separate, probe-gated lane — not required for the retune above)

1. **First**, run `PDV_TriggerTopups_DetectionProbe_Runbook.md` on a vanilla save (5 trace-only
   probes). Apply each probe's "redesign if" fallback to the spec before wiring.
2. **Then** wire per `PDV_TriggerTopups_Exchange_KnightsRoad.md`: Z'en Reciprocity (Z1 Exchange via
   `RegisterForMenu` gold-delta + Z2 Production via Add-Item/Increase-Skill) and Knight's Road
   Justice (K1 predator-kill-without-stealth-opener + K2 charity). These are **Class B** raw
   `+0.5` / daily cap `1.5` — and they ride the same `GAIN_RATE_SCALE`, so no special-casing
   (raw +0.5 → ~0.66 effective; floor+family still = the default calendar). Register family
   keywords, add `PDV_ActionRouter` routes, update the verifier expected-record set.

---

## Final constants block (after Tasks 1–5)

```
PIETY_DAILY_MAX_DELTA      = 4.3     ; was 5.0  (ceiling clamp, post-gain-scale)
GAIN_RATE_SCALE            = 1.32    ; NEW — global gain multiplier in ProcessDawn (2.5 -> 3.3/day)
DECAY_GRACE_DAYS           = 2.0     ; was 3.0
DECAY_PER_DAY              = 0.5     ; unchanged (Orc modes do NOT scale this)
TIER_DOWN_HYSTERESIS       = 5.0     ; NEW — demote only 5 below threshold
ORC_RATE_MULT_STRONGHOLD   = 1.00    ; NEW — applied to GAIN, after the clamp, Malacath/Orc only
ORC_RATE_MULT_CITY         = 0.75    ; NEW
ORC_RATE_MULT_LEGIONEXILE  = 0.60    ; NEW
; thresholds unchanged: ThresholdSeeker 25 / ThresholdDevoted 50 / ThresholdChampion 85 (per deity)
; PDV_DeityBase: add Bool IsAedric (Nine Divines = true) for the vampire floor bypass
```

## Summary of new symbols Codex introduces

| Symbol | Kind | Where |
|---|---|---|
| `GAIN_RATE_SCALE` | const | `PDV__ManagerQuest` |
| `TIER_DOWN_HYSTERESIS` | const | `PDV__ManagerQuest` |
| `ORC_RATE_MULT_STRONGHOLD/CITY/LEGIONEXILE` | const | `PDV__ManagerQuest` |
| `GetOrcLifeModeGainMultiplier(deity)` | function | `PDV__ManagerQuest` |
| `ThresholdForTier(deity, tier)` | function | `PDV__ManagerQuest` |
| `IsAedric` | Bool property | `PDV_DeityBase` (+ true on the Nine) |
