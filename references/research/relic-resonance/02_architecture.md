# Relic Resonance -- Architecture Spec

**Status:** DESIGN DOSSIER ONLY -- buildable spec, no in-game proof yet.
**Date:** 2026-06-10

> Do NOT invent Papyrus APIs. Items marked [PROOF REQUIRED] must be
> confirmed against live behavior before wiring.

---

## 1. Data model

### 1.1 Per-deity relic FormList (new, one per deity)

EditorID pattern: `PDV_FLST_Relic_<DeityName>` (mirrors the existing
`PDV_FLST_P2_<Race><Deity>Sources` pattern).

P1 pilot lists:

| FormList EditorID | Contents |
|---|---|
| `PDV_FLST_Relic_Hircine` | Savior's Hide, Ring of Hircine |
| `PDV_FLST_Relic_Nocturnal` | Skeleton Key [PROOF REQUIRED: see 01_feasibility P2] |
| `PDV_FLST_Relic_Meridia` | Dawnbreaker |

These FormLists are authored in CK and populated with the vanilla/DLC BASE
forms of the relics (Armor/Weapon/MiscItem records, not ObjectReferences).
No new keywords or scripts attach to the items themselves -- relic resonance
is a polling scan, not an item-side hook.

### 1.2 Authoring table: PDV_RelicResonance.csv (new)

Minimal schema:

```
deity_name, flst_editorid, nudge_delta, notes
Hircine, PDV_FLST_Relic_Hircine, 2.0, curse-gated (see sec 3.4)
Nocturnal, PDV_FLST_Relic_Nocturnal, 2.0, accepted-face required (proof P5)
Meridia, PDV_FLST_Relic_Meridia, 2.0, accepted-face required (proof P5)
```

`nudge_delta` is the signed float passed to `ApplyMoodDelta`. Value
derivation in section 3.1 below. No compiler tooling needed for P1 --
values hand-coded as properties; generate a tool only when scaling past 5
deities.

### 1.3 New properties on PDV__ManagerQuest (in the LD-P1 authored slice)

```
; One FormList per pilot deity -- wired in CK, None-safe in Papyrus.
FormList Property PDV_FLST_Relic_Hircine Auto
FormList Property PDV_FLST_Relic_Nocturnal Auto
FormList Property PDV_FLST_Relic_Meridia Auto
```

At scale, these move to a parallel-array pattern (matching
`PDV_DemandTable.csv`) keyed by `PDV_FLST_AllDeities` index.

---

## 2. Runtime shape

### 2.1 Where it slots into ProcessDawn

Current ordering (from authored `research/living-deities/src/PDV__ManagerQuest.psc` :3933):

```
RunDawnConsolidateScratch()        ; computes clampedToday + EWMA mood
RunDawnApplyRelicResonance()       ; NEW -- inventory scan + nudge
RunDawnRefreshTrackStates()
RunDawnApplyDecayNoop()
RunDawnApplySpellAndNeglectLayersNoop()
RunDawnProcessCommitmentOffersNoop()
RunDawnProcessDemandsNoop()
RunDawnNotifyNoop()
RequestPanelRefresh()
```

`RunDawnApplyRelicResonance()` runs AFTER `RunDawnConsolidateScratch` so the
EWMA has already updated mood for the day. The relic nudge is additive on top
of the EWMA result, not a competing input to it.

### 2.2 RunDawnApplyRelicResonance -- pseudocode spec

```
Function RunDawnApplyRelicResonance()
    Actor playerActor = Game.GetPlayer()
    if !playerActor
        return
    endIf

    ; Iterate over pilot relic lists. At scale: parallel arrays keyed by deity.
    CheckRelicListForDeity(playerActor, PDV_HircineDeity, PDV_FLST_Relic_Hircine)
    CheckRelicListForDeity(playerActor, PDV_NocturnalDeity, PDV_FLST_Relic_Nocturnal)
    CheckRelicListForDeity(playerActor, PDV_MeridiaDeity, PDV_FLST_Relic_Meridia)
EndFunction

Function CheckRelicListForDeity(Actor playerActor, PDV_DeityBase deity,
                                  FormList relicList)
    if !deity || !relicList
        return
    endIf

    ; Pool guard: only nudge a deity the player has committed to.
    ; [PROOF REQUIRED: confirm IsDeityInActivePool is the correct guard]
    if !IsDeityInActivePool(deity)
        return
    endIf

    ; Anti-stacking: one nudge per deity per dawn regardless of how many relics.
    ; Use the devotion-day index (same as ScoreRepeatableAction boundary).
    Int devotionDay = GetDevotionDayIndex()
    Form deityForm = deity as Form
    if StorageUtil.GetIntValue(deityForm, "PDV.Relic.LastNudgeDay") == devotionDay
        return
    endIf

    ; Scan the relic FormList for any item in the player's inventory.
    Bool hasRelic = false
    Int i = 0
    Int count = relicList.GetSize()
    while i < count && !hasRelic
        Form relicForm = relicList.GetAt(i)
        if relicForm && playerActor.GetItemCount(relicForm) > 0
            hasRelic = true
        endIf
        i += 1
    endWhile

    if !hasRelic
        return
    endIf

    ; Hircine: additional curse gate (matches PDV_Deity_Hircine.ScoreAction gate).
    ; [PROOF REQUIRED: confirm PDV_CurseStateService is accessible here]
    if deity == PDV_HircineDeity && !PDV_CurseStateService.IsWerewolf()
        return
    endIf

    ; Apply the nudge through the canonical mood path.
    StorageUtil.SetIntValue(deityForm, "PDV.Relic.LastNudgeDay", devotionDay)
    Float nudgeDelta = GetRelicNudgeDelta(deity)
    ApplyMoodDelta(deity, nudgeDelta, "relic_resonance")
    Trace(2, "Relic resonance nudge: " + deity.DeityName + " +" + nudgeDelta)
EndFunction
```

`GetRelicNudgeDelta(deity)` returns the per-deity value from properties (P1)
or from a loaded JSON table at scale. `GetDevotionDayIndex()` is the existing
`(Utility.GetCurrentGameTime() - DAWN_DAY_OFFSET) as Int` helper confirmed in
`PDV_DeityBase` as the anti-farm day boundary.

---

## 3. Pacing and magnitude

### 3.1 Nudge delta derivation

The mood EWMA formula is:
`MoodNew = alpha * (clampedToday / PIETY_DAILY_MAX_DELTA * 100) + (1-alpha) * MoodOld`

An "ideal day" at `PIETY_DAILY_MAX_DELTA` = 4.3 injects:
`alpha * 100` mood points into the EWMA (e.g. Hircine alpha=0.22 => 22 points/day).

Relic resonance should be a **small ambient supplement**, not a substitute for
genuine devotion. Target: roughly 10% of an ideal day's EWMA contribution.

For Hircine (alpha 0.22): ideal EWMA day = 22 mood points. 10% = 2.2.
Round to `nudge_delta = 2.0`.

For Nocturnal/Meridia (assuming alpha ~0.15, default): ideal EWMA day = 15.
10% = 1.5. Round to `nudge_delta = 2.0` (uniform P1 value; tune per deity
in the CSV at scale).

Sustained relic-carrying at 2.0/day with no devotional activity (alpha=0.22,
MoodOld=0): after 7 days, mood plateaus near:
`0.22*2.0 + 0.78*prev` converges to approx `2.0*0.22/(1-(0.78)) = 2.0` --
a small positive baseline. At alpha=0.15: converges to ~2.0. This is within
the Cool band (0--39) and does not reach Pleased (40--79) on relic nudge alone,
which is correct: the relic sustains a small positive tilt, not a path to
Pleased without real devotion.

### 3.2 Anti-stacking rule

**One nudge per deity per dawn regardless of how many relics the player holds.**
If the player has both Savior's Hide AND Ring of Hircine, they still get one
2.0 nudge, not two 4.0 nudges. The `PDV.Relic.LastNudgeDay` StorageUtil key
enforces this at the earliest exit point.

### 3.3 No piety feed

Relic resonance feeds `ApplyMoodDelta` only -- it does NOT call
`AwardPiety`/`AwardPietyInternal`. Mood and piety are orthogonal inputs in
LD-P1. Piety feeds mood at dawn through the EWMA (`RunDawnUpdateMoodForDeity`);
relic resonance bypasses the EWMA and writes mood directly. This is the same
pattern used by demand fulfillment and demand expiry in
`RunDawnProcessDemands`.

### 3.4 Hircine curse gate

`PDV_Deity_Hircine` (the curse-gated deity face introduced in LD-P1) scores
zero while `!IsWerewolf()`. Relic resonance must mirror this: carrying the
Savior's Hide while cured should not feed the deity face's mood. Gate:
`if deity == PDV_HircineDeity && !PDV_CurseStateService.IsWerewolf() -> return`
immediately before `ApplyMoodDelta`. [PROOF REQUIRED: PDV_CurseStateService
property accessible on PDV__ManagerQuest -- it exists as
`PDV_CurseState Property PDV_CurseStateService Auto` at live :90.]

---

## 4. StorageUtil namespace

New key per deity form:

| Key | Type | Meaning |
|---|---|---|
| `PDV.Relic.LastNudgeDay` | Int | Dawn-day index of last relic nudge; anti-stacking guard |

Follows the existing `PDV.Mood.*` / `PDV.Demand.*` per-deity namespacing.
Initialized to 0 (unset); the devotion day index is always >= 1 for any
real play session, so 0 is a safe sentinel.

---

## 5. Verifier expectations

Extend `tools/pdv_verify.mjs` (or `pdv_content_verify.mjs`) with:

- **FormList presence:** `PDV_FLST_Relic_Hircine`, `PDV_FLST_Relic_Nocturnal`,
  `PDV_FLST_Relic_Meridia` exist and are non-empty.
- **Anti-stacking:** in the dawn-tick smoke, giving the player both Hircine
  relics results in exactly one `[PDV] Relic resonance nudge: Hircine` log
  line per dawn, not two.
- **Nudge magnitude:** logged delta = 2.0 for each pilot deity.
- **Curse gate:** with `PDV_CurseState.IsWerewolf() == false`, no
  `relic_resonance` nudge fires for Hircine even when Savior's Hide is
  in inventory. Log must be absent.
- **Pool gate:** nudge does not fire for deities with no prior commitment
  signal; `PDV.Mood.*` keys for that deity must remain at their pre-scan
  values.
- **No piety contamination:** `PDV.PietyToday` must not change during
  `RunDawnApplyRelicResonance` execution (log-verify against pre/post).

---

## 6. CK authoring checklist

- [ ] Author `PDV_FLST_Relic_Hircine`, `PDV_FLST_Relic_Nocturnal`,
      `PDV_FLST_Relic_Meridia` FormLists in the PDV ESP.
- [ ] Populate each FormList with the correct BASE form IDs
      (Skyrim.esm / Dawnguard.esm).
- [ ] Wire the three `PDV_FLST_Relic_*` properties on PDV__ManagerQuest
      (the LD-P1 authored QUST).
- [ ] Confirm `PDV_CurseStateService` property is wired (it already exists
      at live :90 -- verify in CK after LD-P1 Block C wiring).
- [ ] Add `RunDawnApplyRelicResonance()` call to `ProcessDawn` after
      `RunDawnConsolidateScratch()`.
- [ ] Bump `LIVING_DEITIES_VERSION` or equivalent version gate when the
      relic resonance state key `PDV.Relic.LastNudgeDay` is first introduced.

---

## 7. Open owner decisions

| # | Decision | Options | Notes |
|---|---|---|---|
| D1 | Which deities are in P1 pilot? | Hircine only (safest: curse-gate proof exists) vs. all three (Nocturnal + Meridia need accepted-deity face) | Proof item P5 in 01_feasibility.md -- owner must rule |
| D2 | Nudge magnitude: uniform 2.0 or per-deity? | Uniform simplest for P1; per-deity allows flavor (patient Kyne-type god = lower nudge, impatient Hircine = higher) | Lock at 2.0 uniform for P1; tune in CSV at scale |
| D3 | Pool guard strictness | `IsDeityInActivePool` (recent signals) vs. "any prior commitment ever" | Proof item P1 -- pool guard semantics must be confirmed |
| D4 | Amulets of the Divines (Aedra) | Small nudge to corresponding Aedra deity? Eight Divines sets exist in vanilla | Lower signal value (not unique); defer to P2 content fill after pilot proves pattern |
| D5 | Negative relic effect (unintended contact) | e.g. Stendarr dislikes player holding Daedric artifact | This is already handled by event 368 / `PDV_FLST_FaucetDaedricArtifacts` via piety (ScoreAction Stendarr -1.0); do NOT double-count via relic resonance | OMIT negative path from relic resonance |
