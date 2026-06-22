# Codex Handoff — Experience Mode (Wayfarer's Path / Pilgrim's Path)

**Owner:** Codex (live Papyrus). **Author of this spec:** Claude.
**Batch:** 1F. **Implement in:** Phase 4 (LAST) — this edits `RunGainPipeline`
and `RunDawnConsolidateScratch`, which would churn during the Phase 1–3
magnitude tuning. Do NOT start until Claude signals "tuning frozen."
**Design lock:** `references/PDV_ExperienceMode_DesignReference.md` (the
canonical `PDV_ModePreset.psc` body is in §4; integration intent in §5). This
handoff pins that design to the **current live line anchors** and the
collision/record rules so it's executable as-is.

## What this builds

A user-facing two-mode toggle that scales the piety **economy** (not reward
magnitudes): **Pilgrim's Path** (default, all 1.0 — current behavior) vs
**Wayfarer's Path** (easy: 1.25× gain, 1.5× daily cap, admits cheap-repeatable
signals at 0.5×). Default 0 (Pilgrim) preserves authored behavior on existing
saves.

## Ownership / collision rules

- **You (Codex):** all `.psc` edits below.
- **Claude (me):** mints the records and hands you their EditorIDs BEFORE you
  wire properties — `PDV_ModePreset` (QUST, hidden start-game-enabled),
  `PDV_GLO_Mode` (GLOB, Short, init 0), and the `PDV_ModePresetRef` property on
  `PDV_MCM`, `PDV__ManagerQuest`, `PDV_ActionRouter`. **Do not** try to create
  QUST/GLOB records — that's the CK-bridge step. If a property is unwired at
  compile time it compiles fine (Auto property = None); the integration helpers
  below all null-guard `PDV_ModePresetRef`, so partial wiring never breaks the
  build.
- Compile only via `node .\tools\pdv_compile.mjs`; snapshot + commit each step.

## Step 1 — New script `PDV_ModePreset.psc`

Create at the live source root exactly as in DesignReference §4 (the body is
final — `GetMode`/`SetMode`/`GetModeLabel`/`GainMultiplier`/`DailyCapScalar`/
`DecayScalar`/`GraceScalar`/`AllowCheapRepeatables`/`CheapRepeatableWeight`,
with `MODE_PILGRIM=0`/`MODE_WAYFARER=1` and the `WAYFARER_*` scalar constants).
It reads/writes StorageUtil `PDV.Mode` on `PDV_Manager as Form` and mirrors
`PDV_GLO_Mode`. No changes from the design body.

## Step 2 — `PDV__ManagerQuest.psc` integrations (exact anchors)

**2a. Property declaration** — after the existing global-mirror property at
**line 31** (`GlobalVariable Property PDV_GLO_DebugLevel Auto`), the mode mirror
is owned by `PDV_ModePreset`; the manager needs the resolver ref. Add near the
other quest-ref properties:
```papyrus
PDV_ModePreset Property PDV_ModePresetRef Auto
```

**2b. Gain multiplier** — `RunGainPipeline` (live **lines 8008–8019**). Append
the mode multiplier as the LAST factor so stance/curse/Survival-damp/etc. still
dominate the shape. Insert after the Khajiit-lunar line (**8014**), before
`endIf`:
```papyrus
        appliedAmount = appliedAmount * GetKhajiitLunarAlignmentMultiplier(deity)
        if PDV_ModePresetRef
            appliedAmount = appliedAmount * PDV_ModePresetRef.GainMultiplier()
        endIf
    endIf
```

**Composition with `GetSurvivalContextGainMultiplier` (decided 2026-06-22 — A).**
Wayfarer composes multiplicatively as the trailing factor. Worst case
Wayfarer + severity-3 survival hardship = `1.25 × 0.9 = 1.125`. Do NOT
short-circuit the Survival damp when Wayfarer is on; the damp is small,
conditional, and a deliberate diegetic feature gated behind its own MCM
toggle (`PDV.Compat.SurvivalContextEnabled`). See DesignReference §5.1.

**2c. Daily-cap scalar** — `RunDawnConsolidateScratch`, the clamp at live
**line 7423**. Per DesignReference §5.2, scale the cap BOUND (not the clamped
value) so Wayfarer raises the ceiling proportionally. Replace:
```papyrus
            Float clampedToday = ClampValue(scaledToday, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)
```
with:
```papyrus
            Float dailyCap = PIETY_DAILY_MAX_DELTA
            if PDV_ModePresetRef
                dailyCap = dailyCap * PDV_ModePresetRef.DailyCapScalar()
            endIf
            Float clampedToday = ClampValue(scaledToday, -dailyCap, dailyCap)
```
Leave any existing post-clamp per-race multipliers untouched.

**2d. Decay-step scalar (live; anchor pinned).** The decay path is live —
`ApplyDecayToDeity` at line **7575**, with the single-line decay step at
line **7610**:
```papyrus
    Float newPiety = currentPiety - (DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity))
```
Add `DecayScalar()` as a trailing factor on the subtrahend so Wayfarer halves
the per-day decay (and Pilgrim is unchanged):
```papyrus
    Float decayStepScalar = 1.0
    if PDV_ModePresetRef
        decayStepScalar = PDV_ModePresetRef.DecayScalar()
    endIf
    Float newPiety = currentPiety - (DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetCurseGainMultiplier(deity) * GetDaedricStigmaGainMultiplier(deity) * decayStepScalar)
```

**2e. Grace-window scalar (gate-only).** `DECAY_GRACE_DAYS` is referenced at
five live sites: the actual decay gate (**7591**), two reset-events
(**7756**, **7784**), and the dashboard "starving" detection (**8001**).
Scale ONLY the decay gate at line 7591:
```papyrus
    Float graceWindow = DECAY_GRACE_DAYS
    if PDV_ModePresetRef
        graceWindow = graceWindow * PDV_ModePresetRef.GraceScalar()
    endIf
    if (nowTime - lastEventTime) < graceWindow
        return
    endIf
```
Do NOT scale the reset-event sites (those write a one-shot timestamp; mode-
dependent scaling there would create save-divergent state) and do NOT scale
the dashboard "starving" gate (UI flavor, not pacing). If you find another
caller that genuinely needs grace scaling, flag rather than scale.

## Step 3 — `PDV_GLO_Mode` mirror (follow the DebugLevel idiom)

The mirror lives on `PDV_ModePreset` (it owns `SetMode`→`PDV_GLO_Mode.SetValue`).
You do NOT need new setter/getter on the manager. BUT replicate the **track-sync
fan-out**: search `PDV__ManagerQuest.psc` for every `PDV_GLO_DebugLevel !=`
block (pattern at **lines 870–872**, repeated ~12×) and, if any deity-track
script needs mode for a CK condition, add a parallel `PDV_GLO_Mode` sync. If no
track reads mode (likely true for V1), skip this — the mirror is only for future
CK-condition dialogue. Note in your commit whether you added syncs.

## Step 4 — Wayfarer Akatosh skill-milestone route (replaces former cheap-signal gate)

**Scope decision (2026-06-22, see DesignReference §5.3).** The original §5.3
plan to gate an `IsCheapRepeatableSignal` reject branch in `PDV_ActionRouter`
is dropped: that branch does not exist (rejection is by absence of handler).
V1 ships ONE curated cheap-signal route instead — a small Akatosh pulse on
player level-up, Wayfarer-only. `PDV_ActionRouter` requires NO edits in this
batch.

**4a. Player-alias level-up hook** — in
`live-source/Scripts/Source/PDV_PlayerEvents.psc`. The script already uses
PO3 Papyrus Extender events (e.g., `OnSpellLearned`, `OnObjectEquipped`,
`OnMagicEffectApplyEx`). Add a new event handler that fires on player
level-up. Preferred path: PO3's `Event OnPlayerLevelUp(...)`. If PO3's signature
doesn't match the player-alias context, fall back to vanilla
`Event OnLevelIncrease(Actor akSelf)` on the alias — either is acceptable.
The handler delegates straight to the manager (no inline logic, no per-event
gating in PlayerEvents):
```papyrus
Event OnPlayerLevelUp(...)
    if PDV_Manager
        PDV_Manager.HandleWayfarerAkatoshLevel()
    endIf
EndEvent
```

**4b. New manager handler** — in `PDV__ManagerQuest.psc`, alongside other
`Handle*` functions. Mode-gate + anti-farm + dispatch via
`AwardPietyInternal`:
```papyrus
Function HandleWayfarerAkatoshLevel()
    if !PDV_ModePresetRef || !PDV_ModePresetRef.AllowCheapRepeatables()
        return ; Pilgrim default — no Akatosh pulse for raw level-up
    endIf
    if !PDV_Akatosh
        return
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
Net first-fire-of-day = `1.0 × 0.5 × 1.0 × 1.25 (Wayfarer GainMultiplier in
RunGainPipeline) = 0.625` Akatosh piety. Subsequent same-day fires decay by
0.7ⁿ via the existing anti-farm primitive. Pilgrim returns at the gate, so
zero behaviour change on default mode.

**4c. No record minting needed.** This route reuses the existing
`PDV_Akatosh` deity reference and `PDV_ModePresetRef` property the manager
already gets from Claude's records pass. No new QUST/GLOB.

**4d. Survey/trace surfacing (nice-to-have).** Reason tag `wayfarer_akatosh_level`
will route through the existing Survey/recent-events surfacing. If
`HumanizeDriverReason` needs an entry, add `"wayfarer_akatosh_level" →
"the everyday work of becoming"` (or similar; defer to player-copy review).

## Step 5 — `PDV_MCM.psc` Experience Mode page

Per DesignReference §5.4: add property `PDV_ModePresetRef`, a third page
`"Experience Mode"`, `BuildModePage()` (current path + read-only "what changes"
labels), and `OnOptionSelect_Mode` (flip 0↔1 with a `ShowMessage` confirm). Also
add the single read-only mode row to the **Status/Player page** — note the
player page already shows a `"Mode"` line at **line 1009**
(`PDV_Manager.GetPlayerMcmModeLine()`); decide with Claude whether that line
becomes the path display or stays the existing content, to avoid a duplicate.

## Records Claude provides before you wire properties

Minting plan + execution path: `references/authoring/PDV_ExperienceMode_RecordSpec.md`.

| Record | Type | Note |
|--------|------|------|
| `PDV_ModePreset` | QUST | hidden, start-game-enabled, priority 60, no aliases, script `PDV_ModePreset`; props `PDV_Manager`→`PDV__ManagerQuest`, `PDV_GLO_Mode`→`PDV_GLO_Mode` |
| `PDV_GLO_Mode` | GLOB | Short, InitialValue 0 |
| `PDV_ModePresetRef` | property | on `PDV_MCM`, `PDV__ManagerQuest`, `PDV_ActionRouter` → `PDV_ModePreset` |

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV_ModePreset --script PDV__ManagerQuest --script PDV_ActionRouter --script PDV_MCM
node .\tools\pdv_verify.mjs
```
Expect `1 succeeded, 0 failed` per script and `FAIL=0` on verify (SEQ-freshness
WARN is acceptable). Snapshot + commit.

## In-game proof (User — Session G, after Phase 4)

DesignReference §6 smoke: (1) existing save defaults to Pilgrim; (2) MCM toggle
round-trips `PDV.Mode` + `PDV_GLO_Mode`; (3) Wayfarer gain = 1.25× a known
curated signal; (4) Wayfarer dawn cap = 1.5×; (5) Akatosh level-up route —
Pilgrim emits nothing, Wayfarer emits ~0.625 first-fire-of-day to Akatosh and
0.7ⁿ-damps subsequent same-day fires; (6) decay halved on Wayfarer; (7) mid-
save flip changes nothing stored. Record in the manual evidence ledger.

## Open items for Claude (flag, don't guess)

1. ~~Step 2d decay-step exact anchor.~~ **Resolved 2026-06-22** — pinned to
   line 7610; spec inlined at Step 2d/2e.
2. ~~Step 4 — whether a clean cheap-repeatable reject branch exists in
   `PDV_ActionRouter`.~~ **Resolved 2026-06-22** — branch does not exist;
   scope reframed to one curated Akatosh level-up route (Step 4 a–d). No
   `PDV_ActionRouter` edits.
3. Step 5 — the `GetPlayerMcmModeLine()` duplicate-vs-repurpose call. The
   existing helper means "player's per-race life-mode" (Hunter/Stalker etc.)
   and is read in ~6 places (Survey, dashboard, journal, etc.). **Do NOT
   repurpose it.** Add the Experience Mode row as a NEW line on the
   Status/Player page (e.g., "Path: Pilgrim's Path") above or below the
   existing "Mode:" line; both rows coexist.
