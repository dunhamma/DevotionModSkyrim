# B4 Authored Arcs -- Feasibility Assessment

**Status:** DESIGN COMPLETE, 2026-06-10.
Honesty bar: same as `03_feasibility.md`. No CK, no Skyrim runtime in this session.
All seams traced to real function NAMES (names are the contract; line numbers drift).
Proof-still-required items listed per mechanism.

---

## Grounding seams confirmed this pass (live source)

| Seam (NAME is the contract) | Where | Used by B4 mechanism |
|---|---|---|
| `ApplyQuestReaction(Quest, Int stageValue)` | live `PDV__ManagerQuest.psc:816` | reminiscence flag write at matrix milestone |
| `FulfillDemand(deity, ...)` | LD-P1/P2 slice | reminiscence + prefer counter write; bond-advance check |
| `RunDawnProcessDemands()` | LD-P1 slice | bond-stage advance dawn check |
| `SendPrismaEventToast(eventName, deity, context, tierLabel, rival)` | live `:1057` | bond-stage advance toast |
| `PDV_DiegeticDirector.Dispatch(...)` + `SurfaceTransition(...)` | live `:1119` + `PDV_DiegeticDirector.psc:41` | stage-advance omen; reminiscence dream dispatch |
| `OnSleepStart` hook | live `PDV_PlayerEvents.psc:140` | reminiscence-tagged dream dispatch |
| `SelectDemandKey(deity, trigger)` | LD-P2 slice | BDI prefer bias input |
| `GetDeityMoodBand(deity)` / `PDV.Mood.<deity>.Band` | LD-P1 slice / StorageUtil | bond-advance mood gate |
| `GetStoredTier()` | live `PDV_DeityBase.psc` | bond-advance tier gate |
| `HasRecentCommitmentSignalDays(deity, count, window)` | live `PDV__ManagerQuest.psc:6624` | active patron pool gate (reused for stage advance) |
| `ScoreRepeatableAction(...)` | live `PDV_DeityBase.psc` | anti-farm gate on bond-advance ritual check |
| `StorageUtil.SetIntValue / GetIntValue (per deity form)` | live (used everywhere) | `PDV.Bond.*` namespace writes |

**Key finding: no `PDV.Bond.*` namespace exists in live source today.** The namespace is
entirely new storage -- clean, no collision. The pattern (per-deity-form StorageUtil) is
identical to `PDV.Mood.*` and `PDV.Demand.*`; no new technique.

---

## Mechanism A -- Bond-stage ladder

**Confidence: HIGH (design) / MED-HIGH (full build)**
**Recomposition vs greenfield:** principally recomposition. New code: a
`RunDawnCheckBondAdvance(deity)` sub-phase inserted after `RunDawnProcessDemands`; a
`TryAdvanceBondStage(deity, reason)` writer; `PDV.Bond.<deity>.Stage` (int 0-4) and
`PDV.Bond.<deity>.StageEntryDay` (int) StorageUtil keys per deity form; authoring columns
in `PDV_DemandTable.csv` (`bond_advance_tag`, `bond_advance_days`). No new actor, no new
external dependency.

The dual-gate check at dawn is pure StorageUtil comparison:
`currentDay - StageEntryDay >= bond_advance_days && GetDeityMoodBand >= MOOD_PLEASED`
OR `latestDemandFulfillTag == bond_advance_tag`. Both sides read existing seams.

The bond-stage number has NO runtime effect until omen/demand text dispatches; it only
gates which text keys are unlocked. This makes pre-smoke authoring safe: wrong stage
just shows wrong text, not a broken demand loop.

**Proof still required:**
- Stage persists across save/load (StorageUtil save/load proven generally; this is a new
  namespace, so verify at least one cycle)
- Advance fires exactly once per stage; no multi-fire on the same dawn
- Dual gate: time path fires when mood condition and day count both met; ritual path fires
  when `bond_advance_tag` matches exactly (not a substring match -- string equality)
- Stage 4 advance requires both (verify the AND gate, not OR, for the capstone)
- Band gate uses the effective mood (LD-P2 `GetEffectiveMood`), not the raw EWMA scalar

---

## Mechanism B -- Reminiscence flags

**Confidence: HIGH**
**Recomposition vs greenfield:** pure recomposition. The write is a
`StorageUtil.SetIntValue(deityForm, "PDV.Bond.<deity>.Remi.<flagKey>", 1)` call at two
existing call sites:
1. Inside `ApplyQuestReaction` at matching matrix rows (a 2-line conditional; no new
   parameter threaded)
2. Inside `FulfillDemand` when `demand.reminiscence_key` is non-empty (an optional column
   in `PDV_DemandTable.csv`)

The read is inside the dream dispatch in the `OnSleepStart` probability roll in
`PDV_PlayerEvents.psc:140`: after selecting a text key pool for the deity, if a
`PDV.Bond.<deity>.Remi.*` flag is set AND the dream text bank has a matching
`PDV.Bond.<deity>.Remi.<flagKey>.DreamTextKey` entry, the flagged dream text replaces the
generic pool pick. Text bank lives in `LIVING_DEITIES_FILE` JSON under
`bond.<deity>.remi.<flagKey>.dreamTextKey`; compiled from a new `PDV_BondTextBank.csv`.

No new event hook. No new Papyrus system. The only risk is flag accumulation
(unbounded): mitigated by capping the authored flag vocabulary per deity at 4 (compile-
time self-test gate).

**Proof still required:**
- A matrix milestone row fires `ApplyQuestReaction` and the flag is set; readable via
  console `StorageUtil.GetIntValue`
- A dream selects the flagged text key when the flag is set; selects a generic key when
  no flags are set (the fallback path)
- Text key survives save/load (same StorageUtil guarantee as modifier cause strings in
  LD-P2 mechanism 1)
- No double-set if the same quest stage fires `ApplyQuestReaction` twice (use the
  existing `Noted/Marked` anti-spam ladder)

---

## Mechanism C -- BDI demand personalization

**Confidence: HIGH**
**Recomposition vs greenfield:** pure recomposition. This is a weighting bias passed into
the already-designed `SelectDemandKey(deity, trigger)` (LD-P2 `05_ld_p2_architecture.md`
3.2). The prefer counter (`PDV.Bond.<deity>.Prefer.<demandType>`, int, max 5) is
incremented by one additional line in `FulfillDemand`. `SelectDemandKey` reads the
prefer counts and adjusts the selection probability of each pipe-list key before choosing.

This is NOT a new branch in demand logic. The function already chooses between keys; the
bias just changes the weight. If no prefer data exists (new player), weights are uniform.
The function degrades gracefully to the existing trigger-keyed default.

**Proof still required:**
- Prefer counter increments on `FulfillDemand` and is bounded at max
- `SelectDemandKey` demonstrably picks the higher-prefer key more often than the lower
  over N sampled calls (probabilistic; a self-test can seed the counter and verify
  distribution skew over 20 draws)
- Prefer bias does NOT override the single-active invariant or the trigger-type gate
  (a `band_down`-trigger demand still cannot be offered via the `expect_red` trigger path)

---

## Mechanism D -- Dread axis (Molag Bal pilot)

**Confidence: MED (design HIGH; build requires new actor)**
**Recomposition vs greenfield:** a mix. The scalar storage, decay, and band-flip
machinery is recomposition of the mood pattern (`PDV.Bond.<deity>.Dread`, float [0,100];
`PDV.Bond.<deity>.DreadBand`, int 0-3; `RunDawnDecayDread(deity)` sub-phase). The
submission-act accrual is a new branch in `ScorePrinceAction` (live
`PDV_DaedricPathBase.psc:58`) checking `demand_type == submission`.

**Critical cost honest assessment:** Molag Bal has NO `PDV_Deity_*` face in live source.
Live source has only `PDV_DaedricPath_Molag extends PDV_DaedricPathBase`. The Dread axis
REQUIRES the mood infrastructure (`PDV.Mood.*`, `GetDeityMoodBand`, `SyncPatronBoonsToBand`)
which lives on `PDV_DeityBase`. Therefore: **a `PDV_Deity_Molag extends PDV_DeityBase` or
`PDV_DaedricPathBase` greenfield actor is required**, with the same cost structure as
`PDV_Deity_Hircine` (new QUST + SGE flag + SEQ entry + stance matrix rows + VMAD
wiring). This is the same precedent pattern the owner already approved for Hircine
(ruling 2026-06-10), but is a non-trivial authoring budget and should be a conscious
owner decision before Dread build begins.

The behavioral-flip bands do NOT require new Papyrus: band drives text-key selection in
`GetProfileTone` / demand label arms, same pattern as mood bands. No ability swap needed
for V1 (Dread text is the only output in V1 scope).

**Proof still required (post-actor creation):**
- Dread scalar accrues on submission acts and is independent of mood movement
- Dread does NOT decay below `Defiant` threshold on normal dawns; only resets on a hard
  defiance act
- Band text changes at the correct thresholds; omen tone registered correctly by director
- Dread-band reads do not interfere with mood-band reads (separate StorageUtil keys,
  separate function names)
- No Dread movement for non-coercive deities (gate on an authored `is_coercive` bool in
  `PDV_DeityMood.csv`)

---

## Feasibility verdict table

| Mechanism | Live seam | Confidence | Recomposition vs greenfield | Owner decision needed? |
|---|---|:-:|---|:-:|
| A -- Bond-stage ladder | `RunDawnProcessDemands`, `FulfillDemand`, `StorageUtil` pattern | HIGH/MED-HIGH | recomposition (new namespace + dawn sub-phase) | No |
| B -- Reminiscence flags | `ApplyQuestReaction:816`, `OnSleepStart:140`, `FulfillDemand` | HIGH | pure recomposition | No |
| C -- BDI personalization | `SelectDemandKey` (LD-P2 slice) | HIGH | pure recomposition | No |
| D -- Dread axis | `PDV_DaedricPathBase.ScorePrinceAction:58` | MED (build) | mixed; requires greenfield `PDV_Deity_Molag` | YES |

**Conclusion.** Mechanisms A, B, C are buildable as pure recomposition after LD-P2 closes
its smoke. Mechanism D is design-complete and buildable but carries a greenfield-actor
cost (same class as the approved `PDV_Deity_Hircine`). The Dread pilot should be deferred
until the owner explicitly allocates that authoring budget.
