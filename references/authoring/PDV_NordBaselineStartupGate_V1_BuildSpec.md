# PDV Nord Pantheon Baseline -- Startup Gate (V1 Build Spec / Codex Handover)

Status: READY TO BUILD
Author handoff date: 2026-06-20
Owner on build: Codex
Scope: V1 only. Organic mid-game drift is deferred to V2 (see
`PDV_NordBaselineDrift_V2_LynchpinDossier.md`).

---

## 1. Goal (one paragraph)

Give Nord players an explicit, deliberate **Old Ways vs Nine Divines** choice at
the existing unified startup pop-up, the same way Breton / Bosmer / Redguard / Orc
already choose their tradition / path / sect / life-mode. Today the Nord pantheon
baseline (`PDV_NordPantheonBaselineTrack`) is **load-bearing but un-chosen**: it
silently defaults to Old Ways (state 0) and can only be changed on the MCM debug
page. Nord is the only race whose startup is `STARTUP_MODE_INFO_ONLY` despite
having a real, mutually-exclusive fork in its data model.

## 2. Design rulings (locked by the user 2026-06-20)

- **Hard exclusive.** The chosen baseline is the only pantheon whose reward
  families sync and whose deities are patron-offer-eligible. This is exactly how
  `SyncNordRewardFamily` and `IsNordOfferEligibleDeity` already behave -- **no
  change to that gating logic.** Talos is always eligible in both; Kyne (Old
  Ways) and Kynareth (Nine Divines) are the same storm-mother under two names.
- **Declared at startup, locked for the playthrough in V1.** No organic drift in
  V1. The MCM debug toggle (`DebugSetNordPantheonBaseline`) remains the only
  mid-game override. Lynchpin-based drift is V2.
- **Button index == state value.** Hard invariant across all PDV startup
  choices: `NORD_BASELINE_OLD_WAYS = 0`, `NORD_BASELINE_NINE_DIVINES = 1`, so the
  select message buttons MUST be ordered `[Old Ways, Nine Divines]`. The raw
  `Message.Show()` index is applied with no remap.

## 3. Source-of-truth and operating rules (READ FIRST)

- **Canonical `.psc` is the live untracked dir**, NOT the repo snapshot:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`.
  Edit there. Repo `generated/live-devotion-snapshot/*` LAGS -- do not build from it.
- **Compile with the PDV toolchain**, not the generic MO2 compiler:
  `node .\tools\pdv_compile.mjs` then `node .\tools\pdv_verify.mjs`. Follow
  `pdv-papyrus-ck` skill guidance.
- **Editing `tools/pdv-startup-author/Program.cs` IS in scope** -- that is the
  sanctioned way every other race's startup MESG records were authored. (The
  CLAUDE.md "do not edit toolchain scripts" rule targets `pdv_compile.mjs` /
  `pdv_verify.mjs` / `pdv_author.mjs`, not the startup author.)
- Recompiled `.pex` requires a **fresh Skyrim launch** to load; an in-session
  reload will not pick it up.
- Keep all copy **ASCII-safe** (straight quotes/apostrophes, hyphens not em
  dashes) per `PDV_STANDARDS` and the post-merge sweep.
- Line anchors below are as-of 2026-06-20 on the live file and WILL drift.
  Locate every edit by **function signature**, not line number.

## 4. Data model already present (do not recreate)

- Constants: `NORD_BASELINE_OLD_WAYS = 0`, `NORD_BASELINE_NINE_DIVINES = 1`
  (~`:516`). `STARTUP_MODE_EXPLICIT_CHOICE = 1`, `STARTUP_MODE_INFO_ONLY = 0`
  (~`:503`).
- Track: `PDV_StateTrack Property PDV_NordPantheonBaselineTrack` (~`:86`),
  2 StateLabels, `GetCurrentState()` defaults to 0 (Old Ways).
- Reader: `GetNordPantheonBaselineState()` (~`:8999`).
- Reward gating (DO NOT TOUCH): `SyncNordRewards` (~`:8446`) ->
  `SyncNordRewardFamily(... requiredBaseline ...)` (~`:8472`). Old Ways family =
  Kyne, Shor, Tsun, Stuhn; Nine Divines family = Akatosh, Mara, Arkay, Stendarr,
  Zenithar, Dibella, Julianos, Kynareth.
- Offer gating (DO NOT TOUCH): `IsNordOfferEligibleDeity` (~`:9827`) -- Talos
  always eligible; otherwise the chosen baseline's family.
- Runtime re-sync entrypoint: `SyncFirstTierRaceRewardRuntime()` (~`:7850`) which
  calls `SyncNordRewards(playerRef)` (~`:7912`).
- Existing broad surfaces already keyed on baseline: `GetNordDevotionModeLabel`
  ("Broad Old Ways" / "Broad Nine Divines"), `GetNordSurveyBaseText`,
  `GetPlayerMcmModeLine`. These work automatically once the baseline is set and
  patron-state is BROAD.

## 5. Papyrus changes in `PDV__ManagerQuest.psc`

All edits mirror the existing Orc/Redguard pattern (state-enum race).

### 5.1 New Message properties (declare with the other startup MESG props, ~`:365`)
```papyrus
Message Property PDV_MSG_StartupNordChoice Auto
Message Property PDV_MSG_Confirm_Nord_OldWays Auto
Message Property PDV_MSG_Confirm_Nord_NineDivines Auto
```

### 5.2 `GetStartupModeForOrigin` (~`:11207`) -- add Nord to explicit choice
```papyrus
if originRace == ORIGIN_BRETON || originRace == ORIGIN_BOSMER || originRace == ORIGIN_REDGUARD || originRace == ORIGIN_ORC || originRace == ORIGIN_NORD
    return STARTUP_MODE_EXPLICIT_CHOICE
endIf
```

### 5.3 `GetStartupChoiceMessage` (~`:11405`) -- add branch
```papyrus
elseIf originRace == ORIGIN_NORD
    return PDV_MSG_StartupNordChoice
```

### 5.4 `GetStartupChoiceMaxOption` (~`:11419`) -- Nord max option is 1
```papyrus
if originRace == ORIGIN_BOSMER
    return BOSMER_PATH_BANDIT_ROAD
elseIf originRace == ORIGIN_NORD
    return NORD_BASELINE_NINE_DIVINES   ; == 1
endIf
return 2
```

### 5.5 `GetStartupDefaultOption` (~`:11427`) -- default Old Ways
```papyrus
elseIf originRace == ORIGIN_NORD
    return NORD_BASELINE_OLD_WAYS   ; == 0
```

### 5.6 `GetStartupConfirmMessage` (~`:11350`) -- add Nord per-path confirms
```papyrus
elseIf originRace == ORIGIN_NORD
    if optionValue == NORD_BASELINE_NINE_DIVINES
        return PDV_MSG_Confirm_Nord_NineDivines
    endIf
    return PDV_MSG_Confirm_Nord_OldWays
```

### 5.7 `GetStartupOptionId` (~`:12092`) -- add Nord ids (telemetry strings)
```papyrus
elseIf originRace == ORIGIN_NORD
    if optionValue == NORD_BASELINE_NINE_DIVINES
        return "nine_divines"
    endIf
    return "old_ways"
```

### 5.8 `ApplyStartupChoice` (~`:11441`) -- dispatch + new apply helper
```papyrus
elseIf originRace == ORIGIN_NORD
    ApplyNordInitialChoice(optionValue, reason)
```

New helper (place beside `ApplyOrcInitialChoice`):
```papyrus
Function ApplyNordInitialChoice(Int baselineValue, String reason)
    Int normalized = ClampInt(baselineValue, NORD_BASELINE_OLD_WAYS, NORD_BASELINE_NINE_DIVINES)
    if PDV_NordPantheonBaselineTrack
        PDV_NordPantheonBaselineTrack.SetState(normalized, reason)   ; SetState, NOT ForceState
    else
        StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalized)
    endIf
    ; Establish the broad-worship-of-the-chosen-pantheon starting state.
    ; NOTE: this also closes a latent gap -- nothing in production currently puts a
    ; Nord into PATRON_STATE_BROAD (SetBroadWorship is only called from the debug MCM),
    ; so a fresh Nord otherwise reads "Unsettled" and the broad reward/survey/offer
    ; branches (all gated on == PATRON_STATE_BROAD) never engage.
    SetBroadWorship()
    StorageUtil.SetIntValue(None, "PDV.Nord.SetupComplete", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.StartupReason", reason)
    SyncFirstTierRaceRewardRuntime()   ; activate the chosen family immediately, not next dawn
    RequestPanelRefresh()
EndFunction
```

### 5.9 `HasExplicitStartupState` (~`:11275`) -- migration discriminator
```papyrus
elseIf originRace == ORIGIN_NORD
    return StorageUtil.GetIntValue(None, "PDV.Nord.SetupComplete") == 1
```

### 5.10 (Optional polish) `GetStartupCanonicalSummary` Nord text (~`:12003`)
Only shown now in the migration-info screen. Leave as-is, or lightly reword to
mention the baseline. Not required for V1.

## 6. ESP authoring -- `tools/pdv-startup-author/Program.cs`

Add three `EnsureMessage(...)` blocks and add them to the `WireQuestScript`
property list. Match the existing house style. **Button order is the state
order: Old Ways (0) first, Nine Divines (1) second.**

```csharp
// Nord select (button index == baseline state: OldWays=0, NineDivines=1 -- keep order).
var nordChoice = EnsureMessage(
    mod, index, allocator,
    "PDV_MSG_StartupNordChoice",
    "Nord startup pantheon",
    "A Nord keeps the faith one of two ways.\n\n" +
    "Old Ways: the ancestral storm-and-hero gods -- Kyne, Shor, Tsun, and Stuhn, with Talos above.\n" +
    "Nine Divines: the Imperial pantheon kept as a Nord -- Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, and Kynareth (Kyne's tamed face), with Talos above.",
    "Old Ways",
    "Nine Divines");

// Nord per-path confirm tail: baseline IS locked in V1, so this does NOT promise
// the choice can change -- only that the PATRON within the baseline is still emergent.
var nordConfirmTail =
    "The path you choose now sets which gods can claim you. Walk it?\n\n" +
    "Which of them becomes your patron is still shaped by how you live.";

var nordOldWaysConfirm = EnsureMessage(
    mod, index, allocator,
    "PDV_MSG_Confirm_Nord_OldWays",
    "Nord - Old Ways",
    "Nord - Old Ways\n\n" +
    "The Old Ways keep the ancestral Nord gods: Kyne's storm and hunt, Shor's hall, " +
    "Tsun's shield-trial, and Stuhn's honor in victory. Talos walks with you either way.\n\n" +
    nordConfirmTail,
    "Walk this path",
    "Choose again");

var nordNineDivinesConfirm = EnsureMessage(
    mod, index, allocator,
    "PDV_MSG_Confirm_Nord_NineDivines",
    "Nord - Nine Divines",
    "Nord - Nine Divines\n\n" +
    "The Nine Divines keep the Imperial pantheon as a Nord holds it: Mara, Arkay, " +
    "Stendarr, Zenithar, Dibella, Julianos, and Kynareth, the tamed face of Kyne. " +
    "Talos walks with you either way.\n\n" +
    nordConfirmTail,
    "Walk this path",
    "Choose again");
```

Add to the `WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[] {...})` list:
```csharp
ObjectProp("PDV_MSG_StartupNordChoice", nordChoice.FormKey),
ObjectProp("PDV_MSG_Confirm_Nord_OldWays", nordOldWaysConfirm.FormKey),
ObjectProp("PDV_MSG_Confirm_Nord_NineDivines", nordNineDivinesConfirm.FormKey),
```

Run it (dry run first):
```
dotnet run --project tools\pdv-startup-author -- --dry-run
dotnet run --project tools\pdv-startup-author
```
The tool auto-backs up the ESP to `...\Devotion\Backups\startup\` and prints a
JSON report (expect `"Status": "PASS"`).

**ESP lock gotcha:** if the write fails with "used by another process" and no
Skyrim/xEdit is running, houseCARL-mcp holds a Mutagen overlay lock. Re-point
houseCARL to the DoD instance, run the author, then re-point back to Anvil.

## 7. Build, verify, prove

1. `node .\tools\pdv_compile.mjs` -- expect 0/0.
2. `node .\tools\pdv_verify.mjs` -- expect FAIL=0. (No verifier contract change
   expected; if a startup-coverage check flags Nord, reconcile the manifest in
   the same pass, do not silence it.)
3. Author the ESP records (Section 6).
4. Launch Skyrim fresh and smoke (Section 8). `coc` is fine for startup (the
   pop-up is driven by `EnsureUnifiedStartupChoice`, not a location-change
   trigger).

## 8. In-game acceptance checklist

New Nord game:
- [ ] Startup shows the **two-screen** flow: select (Old Ways / Nine Divines) then
      the matching per-path confirm. "Choose again" returns to select.
- [ ] Picking **Old Ways** -> `GetNordPantheonBaselineState()==0`; only Kyne / Shor /
      Tsun / Stuhn are offer-eligible; Old Ways reward family is the one that syncs.
- [ ] Picking **Nine Divines** -> state==1; only the 8 Divines + Talos eligible;
      Divines reward family syncs; Old Ways family is cleared.
- [ ] Patron state reads **Broad worship** (not "Unsettled") immediately after the
      choice; MCM mode line reads "Broad Old Ways" / "Broad Nine Divines".
- [ ] `PDV.Nord.SetupComplete == 1`.

Existing Nord save upgraded to this build:
- [ ] No re-prompt (these saves already have `PDV.Startup.UnifiedChoiceComplete==1`,
      which short-circuits `EnsureUnifiedStartupChoice` before the choice path).
      They keep their current (Old Ways default) baseline. The MCM debug toggle is
      the V1 path to switch.

Regression:
- [ ] Breton / Bosmer / Redguard / Orc startup still behave exactly as before.

## 9. Migration semantics (why existing saves are safe)

`EnsureUnifiedStartupChoice` returns early when
`PDV.Startup.UnifiedChoiceComplete == 1` (~`:11187`). Every existing save has
already completed the old Nord info-only startup and set that flag, so it never
reaches the new choice and silently keeps the Old Ways default. Only brand-new
games (flag unset) get the choice. `HasExplicitStartupState(ORIGIN_NORD)` guards
against a double-apply if a partially-initialized save reaches the explicit path.
No baseline is ever overwritten on an in-progress save -> no orphaned piety.

## 10. Out of scope (do NOT build here)

- Organic mid-game drift / lynchpin realign-offers -> V2 dossier.
- The broad-worship **surfacing** gaps (pantheon-wide tier-up notices, dawn
  digest, Book of Days entry pipeline, broad Standing label pinned to 0). Tracked
  separately; not part of this gate.
- Any change to `SyncNordRewardFamily` / `IsNordOfferEligibleDeity` reward or
  offer logic. The hard-exclusive behavior is already correct.
