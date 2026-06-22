# Devotion (PDV) — Experience Mode Design Reference

**Started:** May 19, 2026
**Status:** Locked design for the first user-facing difficulty surface — Wayfarer's Path (easy) vs Pilgrim's Path (hard, default)

This reference defines PDV's single user-facing experience-mode toggle: a
lore-flavored switch between two presets that scales piety gain rate, neglect
& decay punishment, and signal-source breadth. It exists alongside the
deliberately locked race/deity/stance taxonomy in
`PDV_RaceArchitecture_DesignReference.md` — the mode toggle is the **only**
high-level difficulty surface exposed to players. Per-axis tuning sliders are
intentionally not exposed.

---

## SECTION 1: Rationale

The mod's authored economy targets a strict, anti-grinding, lore-coherent
climb. That posture is correct for the mod's voice, but it makes early
adoption brittle: newcomers who haven't internalized the signal vocabulary
read "slow" as "broken." A single experience-mode toggle solves this without
fragmenting the design:

- **Pilgrim's Path** keeps the authored experience intact and is the default.
- **Wayfarer's Path** scales three specific axes more leniently so casual play
  still produces visible progress, without altering stance taxonomy, race
  meaning, tier semantics, or contextual-favor authoring.

The mode is **changeable mid-playthrough** from MCM. The value re-reads on
every signal and every dawn, so a flip takes effect on the next gain or
consolidation without touching existing stored piety.

---

## SECTION 2: Mode Definitions

### 2.1 Pilgrim's Path (default, hard)

> "The strict road. Only acts of true cost catch the gods' eye, and their gaze
> falls cold when neglected."

- All scalar multipliers are `1.0` — authored values pass through unchanged.
- Cheap-repeatable signal sources (raw skill XP, raw crafting counts, generic
  radiant repetition, notification-first reward loops) remain **rejected** as
  documented in v3 Section 5.1.

### 2.2 Wayfarer's Path (easy)

> "A gentler road. The gods see your everyday devotions clearly, and look
> kindly on a wandering heart."

- Positive piety gain is multiplied by `1.25` after stance multipliers have
  been applied.
- Per-event daily ceiling is multiplied by `1.5` (where ceilings exist).
- Decay step (when the v3 decay slot is live) is multiplied by `0.5`.
- Neglect grace window is multiplied by `2.0`.
- One curated cheap-repeatable signal route is **admitted** at `0.5x` weight:
  the Akatosh skill-milestone pulse on player level-up (V1 scope; see §5.3).
  Broader cheap-signal admission (per-skill deity attribution, generic
  combat-kill widening, radiant-quest admission) is deferred to Wayfarer V2.

### 2.3 Mode preset table

| Axis | Pilgrim's Path | Wayfarer's Path | Integration slot |
|------|----------------|-----------------|------------------|
| Positive gain multiplier (post-stance) | 1.0 | 1.25 | `PDV__ManagerQuest.AwardPietyInternal` |
| Daily-cap scalar (per-event ceilings) | 1.0 | 1.5 | per-deity / ActionRouter cap reads |
| Decay step scalar | 1.0 | 0.5 | `PDV__ManagerQuest.ProcessDawn` decay slot |
| Grace-period scalar | 1.0 | 2.0 | per-deity grace constant |
| Allow cheap-repeatable signals (V1: Akatosh level-up only) | false | true | `PDV__ManagerQuest.HandleWayfarerAkatoshLevel`, dispatched from `PDV_PlayerEvents` level-up hook |
| Cheap-repeatable signal weight | 0.0 | 0.5 | same handler, when admitted |

All other v3 levers — stance multipliers, tier thresholds, contextual-favor
trigger thresholds, race substrate behavior, rivalry weights — are **invariant
across modes**. Changing them would shift the authored "feel" of each race
and is out of scope for this toggle.

---

## SECTION 3: Storage and Globals

### 3.1 StorageUtil key

| Key | Type | Domain | Owner | Notes |
|-----|------|--------|-------|-------|
| `PDV.Mode` | float | 0.0 (Pilgrim) / 1.0 (Wayfarer) | `PDV__ManagerQuest` via `PDV_ModePreset` | Unset = treated as 0 → Pilgrim's Path, preserving the authored default on existing saves. |

The value lives on `PDV__ManagerQuest as Form` to mirror the storage
discipline used by `PDV.LastTierChange` and similar manager-owned scalars.

### 3.2 Mirror global

| Global | Type | Purpose |
|--------|------|---------|
| `PDV_GLO_Mode` | int (0/1) | CK Condition reads (e.g., conditional dialogue lines that change wording by mode). Refreshed by `PDV_ModePreset.SetMode()` on every toggle. |

Mirror behavior follows the existing pattern from `PDV_GLO_DebugLevel`: never
the source of truth, never read by gameplay scoring, only present for CK
Condition surfaces.

---

## SECTION 4: PDV_ModePreset script (canonical source)

`PDV_ModePreset.psc` is the single owner of the scalar constants. All other
scripts must call into it rather than hard-coding mode-aware numbers.

Place this file at the canonical Papyrus source root in the MO2 mod
(`D:\Wabbajack\modlists\Anvil\mods\Devotion\Source\`) alongside the other
PDV scripts, then compile via `tools/pdv_compile.mjs`.

```papyrus
;/ 
    PDV_ModePreset.psc
    PlayerDevotion - experience mode preset resolver
    -----------------------------------------------------------------------
    OVERVIEW
    Single owner of the two-mode preset table for Wayfarer's Path (easy)
    and Pilgrim's Path (hard, default). Other scripts call these helpers
    and never hard-code mode-aware scalars.

    DESIGN NOTES
    - StorageUtil PDV.Mode on PDV__ManagerQuest holds the canonical value.
    - Mirror PDV_GLO_Mode is for CK Condition reads only.
    - Default is 0 (Pilgrim's Path) so existing saves preserve authored
      behavior the first time the new resolver runs.
    -----------------------------------------------------------------------
/;

Scriptname PDV_ModePreset extends Quest

PDV__ManagerQuest Property PDV_Manager Auto
GlobalVariable Property PDV_GLO_Mode Auto

Int Property MODE_PILGRIM = 0 AutoReadOnly
Int Property MODE_WAYFARER = 1 AutoReadOnly

Float Property WAYFARER_GAIN = 1.25 AutoReadOnly
Float Property WAYFARER_DAILY_CAP = 1.5 AutoReadOnly
Float Property WAYFARER_DECAY = 0.5 AutoReadOnly
Float Property WAYFARER_GRACE = 2.0 AutoReadOnly
Float Property WAYFARER_CHEAP_WEIGHT = 0.5 AutoReadOnly

Int Function GetMode()
    if !PDV_Manager
        return MODE_PILGRIM
    endIf
    return StorageUtil.GetFloatValue(PDV_Manager as Form, "PDV.Mode") as Int
EndFunction

Function SetMode(Int newMode)
    if !PDV_Manager
        return
    endIf

    Int clamped = newMode
    if clamped != MODE_WAYFARER
        clamped = MODE_PILGRIM
    endIf

    StorageUtil.SetFloatValue(PDV_Manager as Form, "PDV.Mode", clamped as Float)

    if PDV_GLO_Mode
        PDV_GLO_Mode.SetValue(clamped as Float)
    endIf
EndFunction

String Function GetModeLabel()
    if GetMode() == MODE_WAYFARER
        return "Wayfarer's Path"
    endIf
    return "Pilgrim's Path"
EndFunction

Float Function GainMultiplier()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_GAIN
    endIf
    return 1.0
EndFunction

Float Function DailyCapScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_DAILY_CAP
    endIf
    return 1.0
EndFunction

Float Function DecayScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_DECAY
    endIf
    return 1.0
EndFunction

Float Function GraceScalar()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_GRACE
    endIf
    return 1.0
EndFunction

Bool Function AllowCheapRepeatables()
    return GetMode() == MODE_WAYFARER
EndFunction

Float Function CheapRepeatableWeight()
    if GetMode() == MODE_WAYFARER
        return WAYFARER_CHEAP_WEIGHT
    endIf
    return 0.0
EndFunction
```

---

## SECTION 5: Integration points in existing scripts

The integrations below are one-to-three-line additions at existing tunable
slots. No pipelines are introduced. Each script gets a new `PDV_ModePreset`
property auto-wired through CK or the paired authoring manifest.

### 5.1 PDV__ManagerQuest.AwardPietyInternal

The current Phase-4 path multiplies positive `amount` by stance multiplier
only. Add the mode gain multiplier after the stance multiplier so stance
taxonomy continues to dominate the shape of the award:

```papyrus
PDV_ModePreset Property PDV_ModePresetRef Auto

; ... inside AwardPietyInternal, after the stance multiplier is applied:
if amount > 0.0
    appliedAmount = amount * deity.GetGainMultiplier(stance)
    if PDV_ModePresetRef
        appliedAmount = appliedAmount * PDV_ModePresetRef.GainMultiplier()
    endIf
endIf
```

#### Composition with Survival Context damp (chosen 2026-06-22)

The live `RunGainPipeline` already runs `GetSurvivalContextGainMultiplier`
(the bounded ≤10% downward damp when a detected survival mod reports unmet
needs). Wayfarer's `GainMultiplier()` composes **multiplicatively as the
trailing factor**, so worst case Wayfarer + severity-3 survival hardship is
`1.25 × 0.9 = 1.125`. Rationale: the damp is small, conditional on player
state, and represents a diegetic "neglect-your-needs" punish that Survival
users opted into via a separate MCM toggle (`PDV.Compat.SurvivalContextEnabled`).
Wayfarer eases the *floor*; Survival damp models *current* neglect; they do
different jobs and compose without contradiction. Players who want pure
Wayfarer gain can flip the Survival Context compat toggle off.

### 5.2 PDV__ManagerQuest.ProcessDawn

When the v3 decay slot is live (currently scaffold; see `PDV_Architecture_v3.md`
Section 15), the per-deity decay step and grace check read the mode scalars:

```papyrus
; decay step (when the slot is implemented):
Float decayStep = baseDecay * PDV_ModePresetRef.DecayScalar()

; grace check:
Float graceDays = baseGraceDays * PDV_ModePresetRef.GraceScalar()
```

The current `ProcessDawn` consolidation logic that clamps `PietyToday` to
`PIETY_DAILY_MAX_DELTA` should scale that clamp by `DailyCapScalar()` so
Wayfarer's Path raises the per-dawn ceiling proportionally:

```papyrus
Float cap = PIETY_DAILY_MAX_DELTA
if PDV_ModePresetRef
    cap = cap * PDV_ModePresetRef.DailyCapScalar()
endIf
Float clampedToday = ClampValue(pietyToday, -cap, cap)
```

### 5.3 Cheap-repeatable signals — V1 scope (Akatosh level-up only)

**Scope decision (2026-06-22).** v3 §5.3 frames cheap-repeatable rejection as
two distinct things: (a) "rejected source shapes" (raw skill XP, raw crafting
counts, generic radiant repetition) which are rejected by *absence of any
handler*, not by a code gate; and (b) "diminishing returns" for curated
repeats (shrine use, sleep, observances), implemented by
`ConsumeDailyRepeatMultiplier` (0.7ⁿ per same-key-per-day). There is no
`IsCheapRepeatableSignal()` gate in `PDV_ActionRouter` to wire — the original
§5.3 snippet assumed one that does not exist.

Rather than build a full cheap-signal taxonomy in V1 (out of scope for the
beta timeline) or drop the axis entirely (which would leave Wayfarer
mathematically inert for the power-gamer persona who skips immersive rites),
V1 ships **one curated cheap-signal route**:

> **Akatosh skill-milestone route (Wayfarer-only).** Player level-up = small
> Akatosh piety pulse, gated on `AllowCheapRepeatables()`, weighted by
> `CheapRepeatableWeight()` (0.5×), and capped via the existing
> `ConsumeDailyRepeatMultiplier` anti-farm primitive.

Rationale: Akatosh's domain ("Time" — growth, the passage of one's life)
diegetically fits "the gods note your everyday work of becoming." Skill
milestones are exactly the v3 "raw skill XP" shape that Pilgrim rejects;
admitting them only under Wayfarer at 0.5× weight preserves Pilgrim's
"only acts of true cost catch the gods' eye" identity while giving Wayfarer
power-gamers a passive devotion stream they actually generate. One deity,
one hook, one anti-farm key — small surface, easy to revert, easy to extend.

**Integration sketch.** A new handler in `PDV__ManagerQuest` (e.g.,
`HandleWayfarerAkatoshLevel`) is dispatched from a player-alias level-up
hook (`PDV_PlayerEvents.OnPlayerLevelUp` via PO3 Papyrus Extender, or a
vanilla `OnLevelIncrease` equivalent — Codex's choice). The handler:

```papyrus
Function HandleWayfarerAkatoshLevel()
    if !PDV_ModePresetRef || !PDV_ModePresetRef.AllowCheapRepeatables()
        return ; Pilgrim default — no Akatosh pulse for raw level-up
    endIf
    Float baseAmount = 1.0
    Float weight = PDV_ModePresetRef.CheapRepeatableWeight() ; 0.5
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")
    Float amount = baseAmount * weight * multiplier
    if amount > 0.0
        AwardPietyInternal(PDV_Akatosh, amount, STANCE_NEUTRAL, "wayfarer_akatosh_level")
    endIf
EndFunction
```

`AwardPietyInternal` then applies the trailing Wayfarer `GainMultiplier()`
inside `RunGainPipeline` (§5.1), so the net first-fire-of-day value is
`1.0 × 0.5 × 1.0 × 1.25 ≈ 0.625`. Subsequent same-day fires decay by 0.7ⁿ
via the existing anti-farm.

**What this is NOT.** Not a general cheap-signal taxonomy. Not per-skill
attribution (no Smithing → Zenithar mapping, etc.). Not radiant-quest
admission, not generic combat-kill widening. Those are intentionally
deferred to Wayfarer V2 (see §7).

### 5.4 PDV_MCM additions

Extend `PDV_MCM.psc` with a third page **"Experience Mode"** and wire the
toggle:

```papyrus
PDV_ModePreset Property PDV_ModePresetRef Auto

String Property PAGE_MODE = "Experience Mode" AutoReadOnly

Int _oidModeToggle = -1

; Pages array grows from 2 to 3 entries; add PAGE_MODE last.

Function BuildModePage()
    AddHeaderOption("Devotional path", OPTION_FLAG_NONE)
    _oidModeToggle = AddTextOption("Current path", GetModeLabel(), OPTION_FLAG_NONE)
    AddEmptyOption()
    AddHeaderOption("What changes", OPTION_FLAG_NONE)
    AddTextOption("Piety gain rate", GetGainLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Daily ceilings", GetCeilingLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Neglect decay", GetDecayLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Everyday work (Akatosh)", GetCheapLabel(), OPTION_FLAG_DISABLED)
EndFunction

Function OnOptionSelect_Mode(Int a_option)
    if a_option != _oidModeToggle
        return
    endIf

    Int current = PDV_ModePresetRef.GetMode()
    Int next = 1 - current ; flip 0<->1
    String label
    if next == 1
        label = "Wayfarer's Path"
    else
        label = "Pilgrim's Path"
    endIf

    if ShowMessage("Walk the " + label + "?", True, "$Yes", "$No")
        PDV_ModePresetRef.SetMode(next)
        SetTextOptionValue(_oidModeToggle, PDV_ModePresetRef.GetModeLabel())
        ForcePageReset()
    endIf
EndFunction
```

The four read-only label helpers (`GetGainLabel`, `GetCeilingLabel`,
`GetDecayLabel`, `GetCheapLabel`) return short lore-flavored phrases keyed to
the current mode, e.g., `"Generous (1.25x)"` vs `"Strict (1.0x)"`.

The existing Status page should also gain a single read-only row showing the
current path, so the player can see at a glance which road they walk without
opening a second tab.

### 5.5 PDV_PrismaBridge mode-change toast (optional)

If the Prisma surface is live in the player's install, `SetMode` can route a
single-line toast through `PDV_PrismaBridge.SendOverlayJson` with payload
`{ "kind": "mode", "label": "<new label>" }`. The bridge already owns the
toast vocabulary; this is one new symbol entry, no contract changes.

---

## SECTION 6: Verification

End-to-end smoke after the integration lands:

1. **Default behavior preserved.** Load an existing save with no `PDV.Mode`
   value. Confirm `PDV_ModePreset.GetMode()` returns `0` and piety gains
   match Phase-4 authored values.
2. **MCM toggle round-trip.** Open MCM, flip Wayfarer's Path on, then off.
   Confirm `PDV.Mode` StorageUtil key reflects the toggle each time and
   `PDV_GLO_Mode` mirror tracks it.
3. **Gain multiplier active.** With Wayfarer's Path on, fire a known curated
   signal (e.g., Auri-El curated signal index 1) and confirm
   `PDV.PietyToday` rises to `1.25x` the Pilgrim-Path value (compare via
   `PDV_Manager.DebugGetPietyMapString` or trace).
4. **Daily ceiling raised.** Force `PDV.PietyToday` near `PIETY_DAILY_MAX_DELTA`
   and run dawn. Confirm Wayfarer's Path consolidates at `1.5x` the
   Pilgrim-Path ceiling.
5. **Cheap-repeatable gate (Akatosh level-up route, V1 scope).** On
   Pilgrim's Path, level the player and confirm Akatosh receives no piety
   pulse from the level-up itself (only authored Akatosh signals fire). Flip
   to Wayfarer's Path and level the player; confirm a small Akatosh pulse
   tagged `wayfarer_akatosh_level` lands at `~0.625` first-fire-of-day
   (`1.0 base × 0.5 weight × 1.25 gain`). Level multiple times within one
   day and confirm subsequent fires decay by 0.7ⁿ via
   `ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")`.
6. **Decay scaling.** When the v3 decay slot is live, skip patron interaction
   past the grace window. Confirm the per-dawn decay step on Wayfarer's Path
   is half the Pilgrim-Path value.
7. **Mid-save flip stability.** Flip modes mid-session. Confirm no stored
   `PDV.Piety` values change; the new scalar applies only to the next signal
   and the next dawn.
8. **Stance invariance.** Run a TABOO and a HOSTILE stance signal in both
   modes. Confirm the stance multiplier from `PDV_DeityBase.GetGainMultiplier`
   is unchanged; only the trailing mode multiplier differs.
9. **Race acceptance regression.** Re-run the proven Slice 1 routes (Dunmer
   portable shrine route 30/31, Bosmer Green Pact route 32, Hircine hunt
   rite route 34) on both modes; confirm no functional regression.

The verifier (`tools/pdv_verify.mjs`) should be extended later to readback
`PDV_ModePreset` quest existence, `PDV_GLO_Mode` declaration, and the
property wiring once the records are minted in CK. Until that extension
lands, treat the manifest at
`references/authoring/PDV_ExperienceMode.manifest.json` as the source of
truth for the required CK records.

---

## SECTION 7: Out of scope (intentional)

### 7.1 Permanently out of scope

- Per-axis sliders in MCM. The whole point of this toggle is to keep the
  configuration surface to one big switch.
- A third or middle mode. Two presets, no in-between. If finer tuning is ever
  needed, it lands as a separate advanced-mode toggle or scripted preset,
  not as more sliders on this surface.
- Changing stance multipliers, tier thresholds, contextual-favor trigger
  thresholds, race substrate semantics, or rivalry multipliers. Those define
  the mod's voice and stay invariant across modes.
- Save-only locking. The user explicitly chose changeable-any-time.
- Diegetic gating behind a setup quest. The first-time setup quest may
  mention the toggle exists, but the toggle is not gated by quest stage.

### 7.2 Deferred to Wayfarer V2 (considered, not rejected)

These were evaluated during the 2026-06-22 scope discussion and deliberately
held back from V1 to keep the beta surface small. They become candidates once
V1 ships and tuned magnitudes are proven in-game.

- **Softer anti-farm base under Wayfarer.** `ConsumeDailyRepeatMultiplier`'s
  0.7 base decays repeated same-day signals aggressively (3rd fire = 0.34×).
  A Wayfarer-only base of ~0.85 would let casual immersive players who DO
  spam shrines/prayers stay productive longer. Held because it touches a
  primitive used in ~30+ manager sites and changes pacing math during the
  same window in which V1 magnitudes are being tuned. Best added as a V2
  follow-up once the magnitude floor is settled — at that point we can
  measure whether the 0.7 floor actually punishes casual immersive play.
- **Broader cheap-signal taxonomy.** V1 ships one cheap route (Akatosh
  level-up). V2 candidates, in roughly decreasing confidence:
  - Per-skill deity attribution: Zenithar ← Smithing/Speech/Enchanting;
    Julianos ← Destruction/Restoration/Alteration/Conjuration/Alchemy/
    Enchanting; Stendarr ← Restoration/Block; Talos/HoonDing ←
    One-Handed/Two-Handed/Heavy Armor; Auri-El ← Marksman/Light Armor.
    Mara/Dibella/Kynareth/Arkay deferred until clear mappings exist.
  - Combat-kill widening: any humanoid kill → tiny HoonDing pulse, any
    beast kill → tiny Hircine pulse, Wayfarer-only, anti-farm capped.
    Power gamers fight constantly; this is background piety flow.
  - Radiant-quest admission at 0.5× weight for the broadly-aligned
    radiants (bandit-camp clears → Stendarr; misc-fetches → no good
    attribution, likely permanently rejected).
- **Notification-first reward-loop signals.** Listed in v3 §5.3 as a
  rejected source shape. Likely stays permanently rejected even in
  Wayfarer V2 — those loops are exactly the kind of grind Wayfarer should
  NOT amplify.

---

## SECTION 8: Revisions

### v1.0 — 2026-05-19 — Initial design lock

- Two modes named (Wayfarer's Path, Pilgrim's Path); Pilgrim is default.
- Three-axis preset table locked (gain, decay & grace, signal breadth).
- `PDV_ModePreset` canonical source attached.
- Integration points named at `PDV__ManagerQuest.AwardPietyInternal`,
  `PDV__ManagerQuest.ProcessDawn`, `PDV_ActionRouter` cheap-signal gate,
  and `PDV_MCM` Experience Mode page.
- Paired authoring manifest at
  `references/authoring/PDV_ExperienceMode.manifest.json`.

### v1.1 — 2026-06-22 — V1 scope tightening

- §5.1: documented composition-with-Survival-Context-damp choice (stack
  multiplicatively; Wayfarer's `GainMultiplier()` trails the existing
  `GetSurvivalContextGainMultiplier`; worst case = 1.125×).
- §5.3 rewritten: the original "cheap-signal reject branch" in
  `PDV_ActionRouter` does not exist; rejection is by absence of handler.
  V1 ships ONE curated cheap route — Akatosh skill-milestone pulse on
  player level-up, gated on `AllowCheapRepeatables()`, weighted 0.5×,
  capped via `ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")`.
  Targets the casual power-gamer persona who skips immersive rites.
- §2.2 / §2.3 / §5.4 narrowed to match V1 scope.
- §6 verification: step 5 rewritten for the Akatosh route smoke.
- §7.2 added: deferred Wayfarer V2 work (softer anti-farm base, broader
  cheap-signal taxonomy) recorded as considered-not-rejected.
