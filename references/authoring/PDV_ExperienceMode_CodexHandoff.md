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

**2b. Gain multiplier** — `RunGainPipeline` (live **lines 7970–7981**). Append
the mode multiplier as the LAST factor so stance/curse/etc. still dominate the
shape. Insert after the Khajiit-lunar line (**7977**), before `endIf`:
```papyrus
        appliedAmount = appliedAmount * GetKhajiitLunarAlignmentMultiplier(deity)
        if PDV_ModePresetRef
            appliedAmount = appliedAmount * PDV_ModePresetRef.GainMultiplier()
        endIf
    endIf
```

**2c. Daily-cap scalar** — `RunDawnConsolidateScratch`, the clamp at live
**line 7386**. Per DesignReference §5.2, scale the cap BOUND (not the clamped
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
Leave the existing post-clamp Orc/Imperial multipliers (lines 7388–7389)
untouched.

**2d. (Optional, only if v3 decay slot is live)** `DecayScalar()`/`GraceScalar()`
hooks in `RunDawnApplyDecay`/`ApplyDecayToDeity`. The current decay path
(`ApplyDecayToDeity`, see `PDV.LastDecayAppliedDay` gate) is live, so apply
`DecayScalar()` to the per-deity decay step there. Confirm the exact decay-step
line with Claude before editing — flag if you can't find a single clean step.

## Step 3 — `PDV_GLO_Mode` mirror (follow the DebugLevel idiom)

The mirror lives on `PDV_ModePreset` (it owns `SetMode`→`PDV_GLO_Mode.SetValue`).
You do NOT need new setter/getter on the manager. BUT replicate the **track-sync
fan-out**: search `PDV__ManagerQuest.psc` for every `PDV_GLO_DebugLevel !=`
block (pattern at **lines 870–872**, repeated ~12×) and, if any deity-track
script needs mode for a CK condition, add a parallel `PDV_GLO_Mode` sync. If no
track reads mode (likely true for V1), skip this — the mirror is only for future
CK-condition dialogue. Note in your commit whether you added syncs.

## Step 4 — `PDV_ActionRouter.psc` cheap-signal gate

DesignReference §5.3 assumes a cheap-repeatable reject branch. **Locate it
first** (search the router for the raw-skill-XP / raw-craft-count / generic-
radiant rejection). Two cases:
- If a clean `IsCheapRepeatableSignal(...) → return` reject exists: gate it on
  `PDV_ModePresetRef.AllowCheapRepeatables()` and, when admitted, dispatch with
  `CheapRepeatableWeight()` (§5.3 snippet).
- If there is NO single reject branch (rejections are implicit/scattered):
  **stop and report to Claude** — we'll decide whether Wayfarer's cheap-signal
  admission ships in beta or is deferred. Do not invent a gate.

## Step 5 — `PDV_MCM.psc` Experience Mode page

Per DesignReference §5.4: add property `PDV_ModePresetRef`, a third page
`"Experience Mode"`, `BuildModePage()` (current path + read-only "what changes"
labels), and `OnOptionSelect_Mode` (flip 0↔1 with a `ShowMessage` confirm). Also
add the single read-only mode row to the **Status/Player page** — note the
player page already shows a `"Mode"` line at **line 1009**
(`PDV_Manager.GetPlayerMcmModeLine()`); decide with Claude whether that line
becomes the path display or stays the existing content, to avoid a duplicate.

## Records Claude provides before you wire properties

| Record | Type | Note |
|--------|------|------|
| `PDV_ModePreset` | QUST | hidden, start-game-enabled, no aliases, script `PDV_ModePreset`; props `PDV_Manager`→`PDV__ManagerQuest`, `PDV_GLO_Mode`→`PDV_GLO_Mode` |
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
curated signal; (4) Wayfarer dawn cap = 1.5×; (5) cheap-signal gate (if shipped);
(7) mid-save flip changes nothing stored. Record in the manual evidence ledger.

## Open items for Claude (flag, don't guess)

1. Step 2d decay-step exact anchor.
2. Step 4 — whether a clean cheap-repeatable reject branch exists in
   `PDV_ActionRouter`; if not, escalate the beta-scope decision.
3. Step 5 — the `GetPlayerMcmModeLine()` duplicate-vs-repurpose call.
