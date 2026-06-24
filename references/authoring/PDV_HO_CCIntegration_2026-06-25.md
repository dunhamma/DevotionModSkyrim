# HO_CCIntegration -- soft CC/AE integration (Codex Handoff, 2026-06-25)

**Queue A3 (manager-touching; serialize on `PDV__ManagerQuest.psc`).** Form
evidence (all FormIDs below): `references/authoring/PDV_CCIntegration_Findings.md`.

> VERIFY CURRENT STATE FIRST: grep before authoring. Multiple items were found
> already-built this session. Confirm none of `InitCCContent`, `_pdvCC`,
> `IsCCContentEnabled`, `_pdvCCSaintsPresent`, `_pdvCCFishingPresent` already
> exist in `PDV__ManagerQuest.psc` before adding them:
> `grep -n "InitCCContent\|_pdvCC\|CCContentEnabled" live-source/Scripts/Source/PDV__ManagerQuest.psc`

## Goal

Add SOFT, "encouraged not required" Creation Club / AE integration that MIRRORS
the proven `InitSurvivalContext` pattern (detect-by-name, cache forms once,
bounded effect, MCM toggle, NO hard master). 1.0 scope:

1. Saints & Seducers (`ccbgssse025-advdsgs.esm`) main-quest completion ->
   a Sheogorath commitment/recognition signal on `PDV_DaedricPath_Sheo`.
2. Light Fishing (`ccbgssse001-fish.esm`) act -> a Kyne/Kynareth day-to-day
   signal, anti-farmed to once per dawn.

Acceptance: on a CC-less order it is a graceful no-op and Devotion.esp gains NO
hard master on either plugin.

## Design / steps

All seams are in `live-source/Scripts/Source/PDV__ManagerQuest.psc` unless noted.
Model the whole block on `InitSurvivalContext` at **8854** (detect ->
GetFormFromFile -> cache; toggle at 8878; status line at 8943).

### Step 1 -- detection + cached forms (new block beside InitSurvivalContext)

Add after `GetSurvivalContextStatusLine` (~8959+, after its EndFunction).
Mirror the field-declaration block at 8838-8852.

```
Bool _pdvCCContentInit = False
Bool _pdvCCSaintsPresent = False
Bool _pdvCCFishingPresent = False
Quest _pdvCCSaintsRestoringOrder      ; QuestB "Restoring Order"
GlobalVariable _pdvCCFishingIsFishing  ; IsPlayerFishing 0/1
Int _pdvCCFishingLastFlag = 0          ; rising-edge tracker for the tick poll

String Property COMPAT_CC_TOGGLE_KEY = "PDV.Compat.CCContentEnabled" AutoReadOnly

Function InitCCContent()
    if _pdvCCContentInit
        return
    endIf
    _pdvCCContentInit = True

    if Game.GetModByName("ccbgssse025-advdsgs.esm") != 255
        _pdvCCSaintsPresent = True
        _pdvCCSaintsRestoringOrder = Game.GetFormFromFile(0x000913, "ccbgssse025-advdsgs.esm") as Quest
    endIf

    if Game.GetModByName("ccbgssse001-fish.esm") != 255
        _pdvCCFishingPresent = True
        _pdvCCFishingIsFishing = Game.GetFormFromFile(0x000B26, "ccbgssse001-fish.esm") as GlobalVariable
    endIf
EndFunction

Bool Function IsCCContentEnabled()
    return StorageUtil.GetIntValue(None, COMPAT_CC_TOGGLE_KEY, 1) != 0
EndFunction
```

FormIDs are confirmed live (see Findings doc). Reuse the exact
`Game.GetModByName(...) != 255 -> Game.GetFormFromFile(...)` shape so the
no-master invariant holds: `GetFormFromFile` returns None when the plugin is
absent and nothing references the CC master at the record level.

### Step 2 -- call InitCCContent from OnInit-equivalent

`InitSurvivalContext()` is invoked lazily inside its readers (8887, 8944).
Do the same: `InitCCContent()` is called at the top of every CC reader below.
ALSO add one `InitCCContent()` next to the existing `InitSurvivalContext()`
call already on the 10s reconcile cadence if one exists; otherwise the lazy
calls suffice (do NOT add a new per-tick external call -- the poll in Step 4
already guards on `_pdvCCFishingPresent`).

### Step 3 -- Saints & Seducers -> Sheogorath signal (quest-stage edge)

CC quests do NOT fire PDV Story Manager events, so poll the stage. In the 1s
`OnUpdate()` body (**677-808**), after the existing CC-less guards, add a
gated probe (cheap: a single GetStageDone after a present-flag short-circuit):

```
TryCCSaintsRecognition()   ; add the call near TryArgonianEldergleamInterior (739)
```

```
Function TryCCSaintsRecognition()
    if !IsCCContentEnabled() || !_pdvCCSaintsPresent
        return
    endIf
    InitCCContent()
    if !_pdvCCSaintsRestoringOrder
        return
    endIf
    ; once-only: stage 200 = "Restoring Order" complete (Sheogorath beat)
    if StorageUtil.GetIntValue(None, "PDV.CC.SaintsRecognized") != 0
        return
    endIf
    if _pdvCCSaintsRestoringOrder.GetStageDone(200)
        StorageUtil.SetIntValue(None, "PDV.CC.SaintsRecognized", 1)
        PDV_DaedricPathBase sheo = GetDaedricPathByForm(GetSheoPathForm())
        if sheo
            (sheo as PDV_DaedricPath_Sheo).RecordControlledSignal("cc_saints_restoring_order")
        endIf
    endIf
EndFunction
```

REUSED existing functions:
- `GetDaedricPathByForm(Form)` (**2734**) -> the live Sheo path instance.
- `PDV_DaedricPath_Sheo.RecordControlledSignal(String)`
  (`PDV_DaedricPath_Sheo.psc:33`) already does AddCommitmentSignal + AddStigma +
  gated AdjustStoredPiety (**PDV_DaedricPathBase.psc:350**) -- exactly the
  commitment/recognition contract. Do NOT add a new piety path.
- For `GetSheoPathForm()`: if no such helper exists, resolve the Sheo path the
  same way the existing Daedric routing does (it already special-cases
  "Sheogorath"->"Sheo" at **1557** via `IsQuestReactionNameMatch`); reuse
  whatever the existing `GetDaedricPathByName`/by-form path uses to fetch Sheo,
  or iterate `GetDaedricPathAtListIndex` (**2700**) and match the record name
  "Sheo". GREP FIRST for an existing Sheo-path getter before adding one.

GetStageDone is the safe single-fire check (idempotent + the StorageUtil
`SaintsRecognized` flag double-guards against re-award on reload). Note S&S
QuestB's WINNER is USSEP, but the QUST FormID is still defined by the CC esm, so
GetFormFromFile against the CC esm resolves the same record.

### Step 4 -- Fishing -> Kyne/Kynareth day-to-day (rising-edge poll, anti-farmed)

In the same 1s `OnUpdate()` body, add `TryCCFishingDevotion()` next to the
other Try* polls (~739-742):

```
Function TryCCFishingDevotion()
    if !IsCCContentEnabled() || !_pdvCCFishingPresent
        return
    endIf
    InitCCContent()
    if !_pdvCCFishingIsFishing
        return
    endIf
    Int nowFlag = _pdvCCFishingIsFishing.GetValueInt()
    if nowFlag != 0 && _pdvCCFishingLastFlag == 0
        ; 0->1 rising edge: player just started a fishing act
        Float mult = ConsumeDailyRepeatMultiplier("cc_fishing_kyne")
        if mult > 0.0
            AwardPiety(PDV_Kyne, 0.5 * mult, "cc_fishing")
        endIf
    endIf
    _pdvCCFishingLastFlag = nowFlag
EndFunction
```

REUSED existing functions:
- `AwardPiety(PDV_DeityBase, Float, String)` (**1146**) -- the canonical
  day-to-day award entry.
- `ConsumeDailyRepeatMultiplier(String keyPrefix)` (**16751**) -- the standard
  once-per-dawn anti-farm decay (returns the scaled multiplier; gate on >0).
- `PDV_Kyne` manager property (**47**). Kyne is the data-table broad-Nord sky
  deity; if the active-patron context is Kynareth, the existing favor/award
  routing already lane-pins it -- a 0.5 base is a deliberately small day-to-day
  per the piety-pacing model (do not inflate). Confirm the Kyne lane is the
  intended one against the race-architecture reference before authoring; if a
  broad/native dispatch is preferred over a hard `PDV_Kyne`, route via
  `RouteActionToOpenPaths` (**7388**) instead with an env/behavioral event type.

The base value (0.5) and whether to award per fishing-act vs per-catch
(CatchTypeLargeFish 0x000892 / CatchTypeSmallFish 0x000894 as alt edges -- see
Findings) is a tuning decision; keep it day-to-day small and dawn-capped.

### Step 5 -- MCM Compat page line + per-CC toggle

In `PDV_MCM.psc`, `BuildCompatPage()` (**1127-1143**). After the Survival
Context block (1137-1140), add a second cursor column / header:

```
AddHeaderOption("AE / Creation Club", OPTION_FLAG_NONE)
AddTextOption("AE/CC content", "Encouraged (optional)", OPTION_FLAG_DISABLED)
_oidCompatCC = AddTextOption("CC integration", OnOffLabel(CCContentEnabled()), OPTION_FLAG_NONE)
AddTextOption("Detected", GetCompatCCReadout(), OPTION_FLAG_DISABLED)
```

Mirror the Survival toggle plumbing exactly:
- declare `Int _oidCompatCC = -1` beside `_oidCompatSurvival` (**132**).
- in OnOptionSelect, beside the `_oidCompatSurvival` branch (**459-460**), add
  `elseIf a_option == _oidCompatCC` -> `ToggleCCContent()`.
- add `CCContentEnabled()` / `ToggleCCContent()` mirroring `SurvivalContextEnabled`
  (**1182**) / `ToggleSurvivalContext` (**1186**) on key
  `"PDV.Compat.CCContentEnabled"`.
- add `GetCompatCCReadout()` mirroring `GetCompatSurvivalReadout` (**1208**),
  delegating to a new `PDV_Manager.GetCCContentStatusLine()` modeled on
  `GetSurvivalContextStatusLine` (**8943**): list "Saints & Seducers" and/or
  "Fishing" when present, else "No supported CC content detected".

## Serialize note

Manager-touching (new functions + OnUpdate calls + a manager property read in
PDV_MCM). Serialize on `PDV__ManagerQuest.psc` against the A1/A2 queue items;
take the manager lock, rebase on the latest, then author. The MCM edit is a
separate file but reads `PDV_Manager`, so land the manager function
(`GetCCContentStatusLine`) before/with the MCM change to avoid a compile gap.

## Post-1.0 (note only -- do NOT build now)

- Ghosts of the Tribunal (`ccBGSSSE062-*`) -> Dunmer deviation via
  `HandleDunmerDeviationPrice` (**13379**), NOT a new lane. FormIDs
  TBD-via-houseCARL (plugin not probed this pass; confirm it is in the order).
- The Cause (`ccBGSSSE068-*`) -> Mehrunes Dagon path (mirror Step 3 onto
  `PDV_DaedricPath_Dagon`). FormIDs TBD-via-houseCARL.

## Verify

ASCII-only in every `.psc` (a commit hook rejects non-ASCII).

1. `node tools/pdv_compile.mjs`  -> expect 0 errors / 0 warnings.
2. `node tools/pdv_verify.mjs`   -> expect FAIL=0.
3. `node tools/pdv_signal_e2e_gate.mjs` -> expect 0 RED.
4. `node tools/pdv_integrity_harness.mjs` -> expect PASS.

Acceptance (manual / proof-pending): on a load order WITHOUT either CC plugin,
GetModByName returns 255, present-flags stay False, the two Try* polls
short-circuit, no toast/award fires, and Devotion.esp lists NO new master.
With S&S installed, completing "Restoring Order" (stage 200) fires the Sheo
commitment signal once; with Fishing installed, a fishing act awards a small
dawn-capped Kyne pulse.
