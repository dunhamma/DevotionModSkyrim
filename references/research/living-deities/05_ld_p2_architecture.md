# LD-P2 -- Living Deities Phase 2: Architecture (buildable spec)

**Status:** DRAFT buildable spec, 2026-06-10. Extends the authored LD-P1 Block B slice
(`research/living-deities/src/PDV__ManagerQuest.psc`, `PDV_DeityBase.psc`,
`PDV_Deity_Hircine.psc`). No code is written by this dossier. Reuses the data-driven
JSON pattern (`LIVING_DEITIES_FILE = "PlayerDevotion/PDV_LivingDeities"`) and the
CSV->JSON compiler (`tools/pdv_living_deities_compile.mjs`) + self-test
(`tools/pdv_living_deities_selftest.mjs`). Function names are the contract.

> Slots into the LD-P1 dawn/demand flow without adding a tick or an event hook. Every
> new function below names where it inserts relative to existing LD-P1 functions.

## 1. New StorageUtil namespaces (per deity form, mirroring `PDV.Mood` / `PDV.Demand`)

```
; Mechanism 1 -- materialized decaying modifiers (fixed ring, N=4)
PDV.MoodMod.Count            (int)    ; live entries in the ring [0..N]
PDV.MoodMod.<slot>.Delta     (float)  ; signed mood contribution
PDV.MoodMod.<slot>.Expire    (int)    ; devotion-day index when it decays out
PDV.MoodMod.<slot>.Cause     (string) ; e.g. "demand_fulfilled", "the_hunt", "mercy_at_gate"
PDV.MoodMod.<slot>.Born      (int)    ; devotion day created (for half-life decay)

; Mechanism 2 -- expectation tracking (reuses live PDV.LastEventGameTime; adds only:)
PDV.Demand.ExpectRedArmed    (int)    ; 1 when an expectation-red offer is queued (parallels Mood.DownCrossPending)

; Mechanism 3 -- second demand type: NO new keys. The existing PDV.Demand.* cache
;   (Key, EventTypesCsv, EventFilter, QuestMatrixTag, OfferedAt, ExpiresAt, Pending,
;    Fulfilled) already holds the SELECTED demand instance. Only the SELECTION input
;    (JSON) changes, not the runtime cache.

; Mechanism 4 -- director routing: NO new per-deity keys. The director owns its own
;   PDV.Diegetic.* StorageUtil cache already.
```

No JContainers needed: the ring is a fixed small N (4) of flat StorageUtil keys, keeping
the LD-P1 "StorageUtil-only, no new master" discipline.

## 2. Mechanism 1 -- materialized modifiers: functions + slot-in

### 2.1 Effective-mood model (the one owner decision)
Two options; spec recommends **(B) damped-additive**:
- (A) **Pure additive:** `effectiveMood = scalarMood + sum(active modifier deltas)`.
  Simple, but double-counts: the act that creates a "+12 demand_fulfilled" modifier ALSO
  already nudged the EWMA, so the band can over-swing.
- (B) **Damped-additive (recommended):** modifiers carry only the *named, narratable*
  portion (demand fulfill/expiry, curated milestones) and are EXCLUDED from the EWMA
  step that dawn, so each act lands in exactly one layer. `ApplyMoodDelta` already exists
  as the "outside the dawn EWMA" path -- modifiers replace its direct scalar write with a
  ring insert, and `GetEffectiveMood` sums scalar + ring.

### 2.2 New functions (manager)
- `Function PushMoodModifier(PDV_DeityBase deity, Float delta, Int lifetimeDays, String cause)`
  -- inserts into the ring (evict oldest if full); sets `Expire = currentDay +
  lifetimeDays`. **Replaces the direct scalar write** inside `FulfillDemand` (push
  `+GetDemandMoodSwing`, cause `"demand_fulfilled"`) and `ApplyDemandExpiry` (push
  `-GetDemandMoodSwing`, cause `"demand_expired"`). Curated milestones can call it from
  `ApplyDeityReaction`.
- `Float Function GetEffectiveMood(PDV_DeityBase deity)` -- `PDV.Mood` scalar + sum of
  non-expired ring deltas (optionally half-life-scaled by `(Expire-currentDay)/lifetime`).
- `Function DecayMoodModifiers(PDV_DeityBase deity, Int currentDay)` -- prune entries
  with `Expire <= currentDay`, compact the ring, update `Count`. **Called once per deity
  inside the existing `RunDawnUpdateMoodForDeity` loop**, before the band recompute.

### 2.3 Slot-in (minimal edits to LD-P1 functions)
- `RunDawnUpdateMoodForDeity`: after the EWMA scalar write, call
  `DecayMoodModifiers(deity, currentDay)`, then compute the band from
  `GetEffectiveMood(deity)` instead of the raw `newMood`. `ComputeMoodBand` is unchanged
  -- it just receives the effective value.
- `ApplyMoodDelta`: route demand fulfill/expiry through `PushMoodModifier` (option B), so
  fulfill/expiry contributions decay rather than permanently shifting the scalar.

### 2.4 New authoring CSV columns
`PDV_DeityMood.csv` gains: `mod_lifetime_days` (default modifier lifetime),
`mod_halflife` (bool: linear-prune vs half-life scale). Compiled to
`mood.<Deity>.modLifetimeDays` / `mood.<Deity>.modHalflife` in `LIVING_DEITIES_FILE`.

## 3. Mechanism 3 -- second demand type: functions + slot-in

### 3.1 Config change (data, not runtime)
`LIVING_DEITIES_FILE` `demandKey.<DeityName>` (scalar) -> `demandKeys.<DeityName>`
(pipe-list, e.g. `"honor_the_wild|kyne_mercy"`). The LD-P1 scalar is the 1-element case,
so existing rows keep working.

### 3.2 New function (manager)
- `String Function SelectDemandKey(PDV_DeityBase deity, Int trigger)` -- reads the pipe-
  list, returns one key. **Trigger-keyed selection** (recommended): `trigger ==
  TRIGGER_BAND_DOWN` -> the deity's reproach demand; `trigger == TRIGGER_EXPECT_RED` ->
  its "come back to me" demand. Falls back to index 0 if only one key. Avoids immediate
  repeat by reading the last-offered key from a new `PDV.Demand.LastKey` (string) cache.

### 3.3 Slot-in
- `OfferDemand(deity, nowTime)` gains a `trigger` parameter and calls `SelectDemandKey`
  to resolve the key it currently reads from `demandKey.<Deity>`. Everything downstream
  (the `PDV.Demand.*` cache writes, `NotifyDemandFaucetSignal`, `NotifyDemandQuestTag`,
  `FulfillDemand`, `ApplyDemandExpiry`) is UNCHANGED -- it already reads the cache.
- `RunDawnProcessDemands` passes the trigger that made the deity eligible (see 4 below).

### 3.4 Authoring
`PDV_DemandTable.csv` gains rows (one per demand definition), and one column `trigger`
(`band_down` | `expect_red` | `any`) so the self-test can verify each deity's pipe-list
keys resolve to real `demand.<key>.*` blocks and that triggers are covered.

## 4. Mechanism 2 -- expectation-red trigger: functions + slot-in

### 4.1 New function (manager)
- `Bool Function IsExpectationRed(PDV_DeityBase deity, Float nowTime)` -- true when the
  deity is in the active pool AND days-since-last-positive-act exceeds an authored
  cadence. Reads live `PDV.LastEventGameTime` (`nowTime - last > expectationRedDays`) and
  may corroborate with the live neglect flag `IsNeglectFlagActive(deity)` for the patron.
  Suppressed while `PDV.Demand.Pending == 1`.

### 4.2 Slot-in
- `IsEligibleForDemandOffer(deity, nowTime)`: the LD-P1 gate becomes
  `(DownCrossPending AND band<=Cool) OR IsExpectationRed(deity, nowTime)`. The LD-P1
  comment "expectation-red joins in LD-P2" marks the exact line.
- `RunDawnProcessDemands`: when selecting `bestCandidate`, record which trigger fired so
  it can be passed into `OfferDemand(deity, nowTime, trigger)` (mechanism 3). Weighting:
  band-down keeps `-GetDeityMood`; expectation-red weights by days-overdue.

### 4.3 Authoring
`PDV_DeityMood.csv` gains `expectation_red_days` (per-deity cadence, scaled to alpha:
patient Kyne longer, impatient Hircine shorter), compiled to
`mood.<Deity>.expectationRedDays`. **TUNING GATE (feasibility 2):** leave Kyne's value
conservative / effectively off until the `2e665b7` faucet-breadth smoke proves the
non-combat receivers live, or expectation-red mis-fires on a Kyne that only registers
(penalized) kills.

## 5. Mechanism 4 -- director routing: functions + slot-in

### 5.1 Slot-in (no new modality code -- the director already has it)
Add `SurfaceTransition(...)` calls ALONGSIDE the existing `SendPrismaEventToast` calls:
- `OnMoodBandCross`: on up-cross `SurfaceTransition("mood", deity.DeityName, "up",
  deity.DeityIndex, tone)`; on down-cross `"down"`. (Toast stays as the fallback channel;
  the director caches/skips when `D1Enabled` is False.)
- `OfferDemand` -> `SurfaceTransition("demand", deity.DeityName, "offer", ...)`;
  `FulfillDemand` -> `"fulfill"`; `ApplyDemandExpiry` -> `"lapse"`.

### 5.2 Director edit (small, in the director's own file -- flagged as its track, not LD-P2 core)
`GetProfileTone` gains arms: `eventClass == "mood"` -> `direction=="up"` returns a warm
tone (e.g. `"reverent"`/`"revelation"`), `"down"` returns `"absence"`/`"dread"`;
`eventClass == "demand"` -> a `"turning"`-class tone. Journal text rows for these go in
`ResolveJournalLine` per deity. This is the only edit OUTSIDE the manager; per charter 4
it belongs to the director's hardening track and is optional for LD-P2 (the manager's
toast fallback fully covers the player-facing surface if it is skipped).

### 5.3 Authoring
`PDV_OmenProfile.csv` gains a `director_tone` column per `(deity, transition)` so the
omen profile, not hard-coded `GetProfileTone` arms, drives the tone. Compiler maps it to
`omen.<Deity>.<transition>.tone`; `SurfaceTransition` reads it as the `toneOverride`.

## 6. Verifier / self-test expectations (extend `pdv_living_deities_selftest.mjs` + runtime readback)

Compile/self-test gates (machine proof, pre-wiring):
- **Modifiers:** every `PDV_DeityMood.csv` row has a numeric `mod_lifetime_days`; ring N
  is a compile constant; no deity references a modifier cause with no journal row.
- **Second demand:** every key in each `demandKeys.<Deity>` pipe-list resolves to a real
  `demand.<key>.*` block (binding-integrity, extended); every demand row's `trigger` is a
  known value; no deity's pipe-list is empty.
- **Expectation-red:** every deity has an `expectation_red_days`; Kyne's value flagged if
  set aggressive before the faucet smoke (a WARN, not a hard fail).
- **Director:** every `(deity, transition)` omen row has a `director_tone` that maps to a
  tone `GetProfileTone`/`GetImageSpaceForTone` recognizes (else fail closed -- the
  director already fails closed on unknown tone -> `"quiet"`, but the self-test should
  catch it earlier).

Runtime readback (in-CK/in-game proof session -- NOT done here):
- `PDV.MoodMod.*` bounded (Count <= N) and pruned across save/load; effective band ==
  scalar+ring sum after a seeded sequence; modifier cause survives save/load.
- Two demands per pilot deity each offer + fulfill correctly; single-active invariant
  holds; fulfillment matches the currently-cached binding only.
- Expectation-red fires once without a band cross; suppressed while pending; respects the
  shared offer cooldown.
- `SurfaceTransition` records the expected `PDV.Diegetic.LastDispatch`/`LastTone`; with
  `D1Enabled` True + CK records, modalities fire once per cross; toast fallback covers the
  `D1Enabled==False` path with no double/dropped surface.

## 7. Build-order hand-off
Authoring (CSV columns 2.4/3.4/4.3/5.3 + compiler/self-test extensions) -> manager
Papyrus wiring (mechanisms 1/2/3 functions + slot-ins; mechanism 4 routing calls) ->
optional director `GetProfileTone`/journal edit (its own track) -> CK records only if the
owner flips `D1Enabled` for the visible modalities -> compile + in-CK/in-game proof per
the per-mechanism "proof still required" lists in `05_ld_p2_feasibility.md` -> QASmoke
counted run. **Precondition (charter 3): do not start until LD-P1's smoke has closed
mood-persistence, demand-loop, faucet-breadth, and Hircine-gate proof items.**
