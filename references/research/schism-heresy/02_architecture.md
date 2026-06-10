# Bucket 4 -- Schism / Heresy: Buildable Spec

**Status:** Design spec only. No Papyrus/CK/ESP changes. Depends on LD-P1
  (`04_living_deities_architecture.md`) being runtime-proven first.

---

## 1. Orthodoxy CSV shape

File: `references/authoring/PDV_OrthodoxyProfile.csv`
Compiled by the existing `tools/pdv_living_deities_compile.mjs` pipeline
(or a sibling `pdv_schism_compile.mjs`) into JSON under
`SKSE/Plugins/StorageUtilData/PlayerDevotion/`.

### Column schema

| Column | Type | Description |
|---|---|---|
| `deity` | String | Deity name matching `PDV_DeityBase.DeityName` |
| `race_filter` | String or `*` | Origin race this row applies to (e.g., `Nord`, `Imperial`), or `*` for any |
| `track_name` | String | Live track property name to read: `NordPantheonBaseline`, `ConcordatStanding`, `BosmerPath`, `AltmerCrisis`, `OrcLifeMode`, `RedguardSect` |
| `orthodox_values` | Pipe-separated ints | `GetCurrentState()` values considered orthodox for this deity+race combo |
| `modifier_mild` | Float | Mood-contribution multiplier when heterodox (mild); suggested range 0.50-0.80 |
| `modifier_strong` | Float | Multiplier when strongly heterodox (a separate authored state value); suggested range 0.20-0.50 |
| `orthodox_bonus` | Float | Multiplier when orthodox AND patron-committed; suggested range 1.05-1.15; cap at 1.15 |
| `tension_threshold_days` | Int | Days of continuous heterodoxy before priest-tension flag sets; 0 = never |
| `notes` | String | Lore rationale and authoring notes |

### Example rows (Talos P1 pilot)

```
deity,race_filter,track_name,orthodox_values,modifier_mild,modifier_strong,orthodox_bonus,tension_threshold_days,notes
Talos,Nord,NordPantheonBaseline,1,0.70,0.40,1.10,3,Old Ways (0) framing is heterodox for Nine Divines Talos; OldWays player gets mild penalty
Talos,Nord,ConcordatStanding,1|2|3,0.65,0.35,1.12,5,PublicCompliant(3)/Enforcer(4) suppress Nine Divines Talos; orthodox = Uncommitted(2)/PrivateDefiant(1)/OpenDefiant(0)
Talos,Imperial,ConcordatStanding,1|2,0.60,0.30,1.15,3,Imperial ConcordatStanding orthodox = PrivateDefiant(1) or OpenDefiant(0); Enforcer(4)/Compliant(3) = strong heterodoxy
```

Note: `ConcordatStanding` enum values must match the live band indices used
by `PDV_ConcordatStandingTrack.GetCurrentState()`. Verify against live source
before authoring. The values above are illustrative -- confirm from
`RunDawnRefreshTrackStates()` / `RecalculateState()` in the live track script.

### Self-test gates (extend pdv_living_deities_selftest.mjs or sibling)

- Every `deity` value matches a name in `PDV_DeityMood.csv`.
- Every `track_name` matches a known live track identifier.
- `modifier_mild` in [0.10, 0.99]; `modifier_strong` in [0.10, modifier_mild).
- `orthodox_bonus` in [1.0, 1.20].
- No row has both `race_filter = *` and a race-specific row for the same deity
  and track without an explicit override note.

---

## 2. Dawn check: where it slots

### Insertion point

`RunDawnUpdateMood()` is the LD-P1 new dawn slot inserted after
`RunDawnConsolidateScratch()` (see `04_living_deities_architecture.md` section
3.1). Schism runs as a named sub-step inside `RunDawnUpdateMood()`, called
before the EWMA calculation:

```
RunDawnConsolidateScratch()         ; existing -- computes clampedToday
RunDawnUpdateMood()                 ; LD-P1 NEW; contains:
    RunDawnApplySchismModifier()    ; SCHISM sub-step (NEW, Bucket 4)
    ; then EWMA formula + band recompute + crossing dispatch
RunDawnRefreshTrackStates()         ; existing
RunDawnApplyDecayNoop()             ; existing
...
```

`RunDawnApplySchismModifier()` must run BEFORE `PDV.PietyToday` is zeroed
(it is zeroed at the end of `RunDawnConsolidateScratch()`). The cleanest
approach: `RunDawnConsolidateScratch()` writes `PDV.SchismModifier.<deity>`
(float, default 1.0) during the same loop before zeroing scratch, OR
`RunDawnApplySchismModifier()` reads the already-computed `clampedToday` from
a temporary local before zeroing. Prefer writing to StorageUtil during
consolidation so the modifier is inspectable in debug traces.

### Pseudo-logic (RunDawnApplySchismModifier, per deity in AllDeities loop)

```papyrus
; Lookup orthodoxy row for (deity.DeityName, playerOriginRaceLabel)
; If no row found, schismMod = 1.0 (no effect)
; Read the named track: e.g. PDV_NordPantheonBaselineTrack.GetCurrentState()
; If currentTrackState in orthodoxValues -> schismMod = orthodoxBonus (if patron active) else 1.0
; Else if severity == strong -> schismMod = modifierStrong
; Else -> schismMod = modifierMild
; StorageUtil.SetFloatValue(deityForm, "PDV.SchismModifier", schismMod)
; If schismMod < threshold AND days >= tensionThresholdDays:
;     StorageUtil.SetIntValue(None, "PDV.Schism." + deity.DeityName + ".HeterodoxActive", 1)
;     If not already mirrored: PDV_GLO_SchismActive = 1  ; global mirror for CK/SPID
```

### Mood EWMA integration (inside RunDawnUpdateMood, after schism sub-step)

The existing LD-P1 formula (from `04_living_deities_architecture.md` section 3.2):

```
MoodNew = Clamp(
    MoodAlpha * (clampedToday / PIETY_DAILY_MAX_DELTA * 100)
    + (1 - MoodAlpha) * MoodOld,
    -100, 100
)
```

With schism modifier applied to the `clampedToday` input:

```
Float schismMod = StorageUtil.GetFloatValue(deityForm, "PDV.SchismModifier")
; schismMod defaults to 1.0 if not set; clamp to [0.10, 1.20] as a safety rail
Float schismMod = ClampValue(schismMod, 0.10, 1.20)
Float modifiedContribution = (clampedToday / PIETY_DAILY_MAX_DELTA * 100) * schismMod

MoodNew = Clamp(
    MoodAlpha * modifiedContribution + (1 - MoodAlpha) * MoodOld,
    -100, 100
)
```

`PIETY_DAILY_MAX_DELTA` must always be referenced symbolically, never as a
literal, per the LD-P1 spec.

---

## 3. Mood modifier pacing bounds

The pacing model (from `03_feasibility.md`): `PIETY_DAILY_MAX_DELTA = 4.3`,
`alpha*100` = one ideal-day contribution to mood. At alpha=0.12 (Kyne), max
single-day mood shift = ~12 points. At alpha=0.22 (Hircine), ~22 points.

**Schism modifier sizing rule:** A mild heterodoxy penalty of 0.70 means the
god receives 70% of the normal mood signal -- roughly equivalent to the player
contributing at 70% of their daily cap. Over a 6-day window to Exalted
(Kyne-paced), mild heterodoxy extends that to ~8-9 days -- noticeable but not
punishing. Strong heterodoxy at 0.35 cuts the contribution roughly in half
on an impression basis, extending Exalted reach to ~12+ days -- meaningful
theological friction.

**Orthodox bonus cap:** 1.15 maximum. At Kyne alpha=0.12, a 1.15 multiplier
shaves ~1 day off the Exalted path. Must not allow schism bonus + high alpha
to produce faster-than-intended mood escalation for high-alpha deities.

**Anti-farm note:** the modifier applies to `clampedToday` (already capped at
4.3). It does not create a new piety source -- it modulates the existing one.
No additional anti-farm cap is required beyond what LD-P1 already provides.

---

## 4. SPID priest-tension pattern

### Flag writes

Two StorageUtil keys per deity-with-tension:
- `PDV.Schism.<deity>.HeterodoxActive` (Int, 0/1) -- set when
  `tensionThresholdDays` reached; cleared when player returns to orthodox lane
  for 2+ days.
- `PDV.Schism.<deity>.HeterodoxDays` (Int) -- running count for the threshold.

One global mirror readable by CK conditions:
- `PDV_GLO_SchismActive` (GlobalVariable, Int) -- set to 1 when ANY patron
  deity's HeterodoxActive flag is 1. Used by SPID condition. Cleared when all
  deity flags clear.

This mirrors the existing pattern for `PDV_GLO_PatronMoodBand` (LD-P1 planned
global, `04_living_deities_architecture.md` section 2.3).

### SPID distribution record shape

A SPID `.ini` entry targeting priest/temple NPC factions:

```
; Distribute a dummy "PriestTensionAura" spell to priest NPCs in relevant temples
Spell = PDV_PriestTensionAura|ActorTypeNPC + Faction:TemplePriestFaction|
  NONE|NONE|Condition:GetGlobalValue(PDV_GLO_SchismActive) >= 1.0
```

The aura spell contains a zero-cost MGEF that fires a Papyrus `OnEffectStart`
event readable by a PDV script that can adjust NPC disposition or set a
dialogue condition flag (`PDV_GLO_PriestTensionFlagActive`).

P1 scope: flag write + global mirror + one SPID record stub. Actual NPC
reaction dialogue and disposition effects are content authoring, deferred to P2.

### Reads PDV_GLO_PatronMoodBand

The SPID condition may combine schism and mood:

```
Condition A: GetGlobalValue(PDV_GLO_PatronMoodBand) <= 1  ; Wroth or Cool
Condition B: GetGlobalValue(PDV_GLO_SchismActive) >= 1    ; heterodox active
```

Both conditions true = strongest priest-tension reaction. Either alone = mild
acknowledgment. This two-global read is entirely CK-standard.

---

## 5. Verifier expectations

Extend `tools/pdv_verify.mjs` or `pdv_content_verify.mjs`:

- `PDV.SchismModifier.<deity>` present and in [0.10, 1.20] after a seeded dawn
  with an authored orthodoxy row.
- `PDV.Schism.<deity>.HeterodoxDays` increments correctly on each heterodox dawn.
- `PDV.Schism.<deity>.HeterodoxActive` sets and clears with correct day thresholds.
- `PDV_GLO_SchismActive` mirrors the per-deity HeterodoxActive union correctly.
- Mood value for Talos (Nord, OldWays baseline) after 3 heterodox dawns is
  measurably lower than mood for Talos (Nord, NineDivines baseline) under
  identical piety input.
- Self-test: all `PDV_OrthodoxyProfile.csv` rows pass the schema gates above.
- Orthodox-bonus case: mood for a patron-committed, orthodox worshipper after
  3 dawns is measurably higher than an uncommitted control.

---

## 6. Open owner decisions

| Decision | Options | Impact |
|---|---|---|
| Modifier applies to positive-only or both signs | Positive only (heterodox can't amplify loss); OR both signs (heterodox also amplifies negative-day mood drops) | Both-signs is more punishing but lore-consistent for Daedra who want strong commitment |
| Orthodox bonus: patron-committed only, or any worshipper | Patron-committed only (reinforces commitment value) OR any worshipper above Tier 1 | Patron-committed-only is cleaner and avoids casual breadth gaming |
| Tension flag persistence: event-based clear OR dawn-countdown clear | Event-based (return to orthodox lane clears next dawn) OR countdown (N days of orthodoxy required to clear) | Countdown is more forgiving for casual play |
| P1 pilot: Talos only, or Talos + one Dunmer Reclamation deity | Talos only (clean, both tracks live) OR add Azura/ancestor-framing row (tests layered track read) | Talos only is lower risk for P1 |
| SPID priest-tension aura: P1 stub only, or authored NPC reactions | Stub (flag write, no visible NPC change) OR one reaction per priest faction | Stub is the correct P1 posture; reactions are content work |
