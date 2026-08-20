# PDV 2.0 FAVOR Module Extraction Spec

STATUS: LIVING (authored 2026-08-18). Buildable extraction plan for the FAVOR module.

## 0. Scope and approach

Extract the 33 FAVOR functions and 42 FAVOR properties out of
`PDV__ManagerQuest.psc` into a new host-instance script
`PDV_ContextualFavorRuntime extends Quest`. The module is a QUST-host instance
script (not Global). It talks back to the manager through a single
`PDV__ManagerQuest Property Manager` backref.

Decided sequencing:

1. NOW (this class of session): move the CODE. The module compiles but is inert
   until its host QUST exists and its `Manager` backref plus the 16 Spell fills
   are set. Manager gains a `PDV_ContextualFavorRuntime Property FavorRuntime`
   and all retained call sites rewire to `FavorRuntime.X`.
2. LATER (batched houseCARL session): create the host QUST record, attach the
   script, fill the 16 Spell properties, and fill `Manager.FavorRuntime`. See
   Section 7.

Two source facts to carry into the edit:

- The RegionMap line numbers for FAVOR have DRIFTED from live source (RegionMap
  puts `EvaluateKyneContextualFavorFamily` at 18344; live source has it at
  18286). Locate every function by NAME, not by RegionMap line. Live-source
  locations are in Section 3.
- `_activeDeity` (live-source line 846) is a bare script VARIABLE, not a
  Property. Two FAVOR functions read it. The extraction therefore REQUIRES a new
  manager accessor. See Section 4 and the hard-to-move flags in Section 8.

All references below are to
`live-source/Scripts/Source/PDV__ManagerQuest.psc` unless stated otherwise.

## 1. Counts (headline)

- Manager functions FAVOR calls (distinct): 11 (Section 4).
- Manager properties/vars FAVOR reads (distinct): 9 (Section 4), one of which
  (`_activeDeity`) is a variable and needs a new getter.
- RULES helpers FAVOR calls: 2 (`ClampInt`, `FormatTwoDecimals`) - already
  `PDV_DevotionRules.X`-qualified, move verbatim.
- FAVOR properties to move: 42 = 16 filled `Spell Auto` (need CK fills later) +
  26 `AutoReadOnly` constants (no fill; move verbatim).
- External call sites (outside the manager): 3, all in
  `live-source/Scripts/Source/PDV_MCM.psc`. External property references: 0.
- Manager-retained internal call sites of FAVOR functions: ~43 invocations
  across ~39 lines (Section 6) - these rewire to `FavorRuntime.X`.

## 2. Module skeleton

```papyrus
Scriptname PDV_ContextualFavorRuntime extends Quest

; --- Backref to the manager (filled in the deferred houseCARL session) ---
PDV__ManagerQuest Property Manager Auto

; --- 16 filled Spell properties (need CK fills later; unfilled = inert) ---
Spell Property PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery Auto
Spell Property PDV_SPEL_Favor_Kyne_StormRoadGrace Auto
Spell Property PDV_SPEL_Favor_Kyne_GuidedHunt Auto
Spell Property PDV_SPEL_Favor_Kyne_WindMarkedPassage Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet Auto
Spell Property PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft Auto
Spell Property PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine Auto
Spell Property PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness Auto
Spell Property PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement Auto

; --- 26 AutoReadOnly constants (move verbatim; no fill) ---
Int Property FAVOR_LANE_NONE = 0 AutoReadOnly
Int Property FAVOR_LANE_KYNE = 1 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_OLD_WAYS = 2 AutoReadOnly
Int Property FAVOR_LANE_NORD_BROAD_NINE_DIVINES = 3 AutoReadOnly
Int Property FAVOR_LANE_ALTMER = 4 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_OPEN_SKY_REST = 1 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_STORM_ROAD = 2 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_GUIDED_HUNT = 3 AutoReadOnly
Int Property FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE = 4 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_SKY_ROAD = 11 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL = 12 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD = 13 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET = 14 AutoReadOnly
Int Property FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE = 15 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_ROAD_GRACE = 21 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY = 22 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_PROPER_DEATH = 23 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_HONEST_WORK = 24 AutoReadOnly
Int Property FAVOR_FAMILY_NINE_TALOS_PRESSURE = 25 AutoReadOnly
Int Property FAVOR_FAMILY_ALTMER_DAWN_STEADINESS = 31 AutoReadOnly
Int Property FAVOR_FAMILY_ALTMER_ORTHODOX_COST = 32 AutoReadOnly
Float Property FAVOR_DURATION_MOMENTARY_DAYS = 0.001 AutoReadOnly
Float Property FAVOR_DURATION_AFTER_ACT_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_DURATION_ENVIRONMENTAL_DAYS = 0.125 AutoReadOnly
Float Property FAVOR_FAMILY_MOMENTARY_COOLDOWN_DAYS = 0.02 AutoReadOnly
Float Property FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS = 0.5 AutoReadOnly

; ... the 33 functions from Section 3 follow, with the rewirings from Section 5 ...
```

Notes:

- Types referenced across the boundary (`PDV__ManagerQuest`, `PDV_Deity_Kyne`,
  `PDV_DeityBase`, `Spell`, `Actor`) resolve by script name in the same
  namespace; no imports required.
- `StorageUtil.*`, `Utility.*`, `Game.*`, `Debug.*`, and `playerRef.*` calls are
  Papyrus/SKSE globals or instance methods on locals; they move unchanged. The
  StorageUtil keys (e.g. `"PDV.Favor.ActiveLane"`, `"PDV.Favor.DebugFamily"`,
  `"PDV.KyneFavor.ActiveCount"`) are plain strings, unbound to any script, so
  they read/write the same slots after the move - no key migration.

## 3. The 33 FAVOR functions (live-source locations)

Block A (contiguous, 18286-18701):
EvaluateKyneContextualFavorFamily 18286; UpdateContextualFavorRuntime 18290;
SyncKyneFavorDebugState 18304; TryActivateContextualFavor 18313;
SendContextualFavorToast 18360; EnsureActiveFavorApplied 18380;
ClearActiveFavor 18398; IsFavorActive 18418; IsActiveFavorExpired 18422;
IsActiveFavorStillEligible 18431; IsEligibleForFavorLane 18439;
ResolveEligibleFavorLane 18443; IsFavorFamilyOnCooldown 18488;
GetFavorLastTriggerKey 18497; GetActiveFavorLane 18501; GetActiveFavorFamily
18505; GetFavorDurationDays 18509; GetFavorCooldownDays 18521;
IsValidFavorFamilyForLane 18529; GetFavorSpell 18543; GetFavorSpellEditorId
18589; GetContextualFavorLaneLabel 18635; GetContextualFavorFamilyLabel 18649;
GetFavorSurfacingLabel 18695.

CAUTION: `GetNordPantheonBaselineState` (18478) sits INSIDE block A's line span
but is NOT a FAVOR function - it stays in the manager. Do not sweep it out by
line range; move by name.

Block B (19465-19606), NON-contiguous - manager `Debug*` functions are
interleaved and STAY behind: GetSelectedContextualFavorLane 19465;
SetSelectedContextualFavorLane 19475; GetSelectedContextualFavorFamily 19483;
GetFirstFavorFamilyForLane 19493; GetNextFavorFamilyForLane 19505;
GetSelectedContextualFavorLaneLabel 19600; GetSelectedContextualFavorFamilyLabel
19604. (Left behind between them: DebugCycleContextualFavorLane 19534,
DebugCycleContextualFavorFamily 19543, DebugTriggerSelectedContextualFavor
19549, DebugExpireActiveFavor 19553, DebugPrimeRaceLaneNeglect 19565.)

Singletons: GetPlayerMcmFavorLine 25141; GetContextualFavorSummary 26384.

## 4. What FAVOR depends on from the manager

### 4a. Manager functions FAVOR calls (11 distinct)

All are instance functions (not Global) on `PDV__ManagerQuest`, so each becomes
`Manager.X(...)`.

| Manager fn | live-source def | called by FAVOR fn(s) |
| --- | --- | --- |
| Trace(Int,String) | 26773 | TryActivateContextualFavor, ClearActiveFavor |
| IsP2BookNoticeReason(String) | 4340 | TryActivateContextualFavor |
| RequestPanelRefresh() | 3136 | TryActivateContextualFavor, ClearActiveFavor |
| SendPrismaEventToast(String,PDV_DeityBase,String,String,String) | 3108 | SendContextualFavorToast |
| IsNordVampireSuppressed() | 24818 | ResolveEligibleFavorLane, GetPlayerMcmFavorLine |
| GetPatronState() | 5178 | ResolveEligibleFavorLane |
| GetTier(PDV_DeityBase) | 4692 | ResolveEligibleFavorLane |
| GetPlayerOriginRaceIndex() | 24747 | ResolveEligibleFavorLane |
| IsAltmerFavorSuppressedByCurse() | 10469 | ResolveEligibleFavorLane |
| GetNordPantheonBaselineState() | 18478 | ResolveEligibleFavorLane |
| IsValidAltmerSourceFavorFamily(Int) | 11424 | IsValidFavorFamilyForLane |

### 4b. Manager properties/vars FAVOR reads (9 distinct)

| Symbol | kind / live-source | access after move |
| --- | --- | --- |
| _activeDeity | script VARIABLE, line 846 | needs new getter - see below |
| PDV_Kyne | `PDV_Deity_Kyne Property PDV_Kyne Auto`, line 48 | Manager.PDV_Kyne |
| PATRON_STATE_ACTIVE | Int AutoReadOnly, 612 | Manager.PATRON_STATE_ACTIVE |
| PATRON_STATE_BROAD | Int AutoReadOnly, 611 | Manager.PATRON_STATE_BROAD |
| TIER_CHAMPION | Int AutoReadOnly, 598 | Manager.TIER_CHAMPION |
| ORIGIN_ALTMER | Int AutoReadOnly, 690 | Manager.ORIGIN_ALTMER |
| ORIGIN_NORD | Int AutoReadOnly, 687 | Manager.ORIGIN_NORD |
| NORD_BASELINE_OLD_WAYS | Int AutoReadOnly, 728 | Manager.NORD_BASELINE_OLD_WAYS |
| NORD_BASELINE_NINE_DIVINES | Int AutoReadOnly, 729 | Manager.NORD_BASELINE_NINE_DIVINES |

`AutoReadOnly` properties are still real properties on the manager script, so
`Manager.PATRON_STATE_ACTIVE` etc. compile and resolve fine across the boundary.

REQUIRED MANAGER CODE CHANGE (not an ESP change): add a public getter so the two
FAVOR functions that read `_activeDeity` can reach it:

```papyrus
PDV_DeityBase Function GetActiveDeity()
    return _activeDeity
EndFunction
```

Both FAVOR read-sites only READ `_activeDeity`, so a getter is sufficient; a full
property conversion of `_activeDeity` is unnecessary and riskier (it is written
in many manager sites). FAVOR then uses `Manager.GetActiveDeity()`.

## 5. Per-function rewiring table

Only calls that CHANGE are listed. "bare FAVOR calls" (to other functions in the
33) and RULES calls (`PDV_DevotionRules.X`, already qualified) stay as-is;
Papyrus/SKSE globals stay as-is. Functions not listed here (25 of 33) need NO
rewiring - they touch only FAVOR members, FAVOR constants, RULES, and globals.

| FAVOR function | rewirings needed |
| --- | --- |
| TryActivateContextualFavor | `Manager.Trace(...)` x3; `Manager.IsP2BookNoticeReason(reason)` x2; `Manager.RequestPanelRefresh()` |
| SendContextualFavorToast | `Manager.GetActiveDeity()` (replaces read of `_activeDeity`); `Manager.PDV_Kyne`; `Manager.SendPrismaEventToast(...)` |
| ClearActiveFavor | `Manager.Trace(...)`; `Manager.RequestPanelRefresh()` |
| ResolveEligibleFavorLane | `Manager.IsNordVampireSuppressed()`; `Manager.GetPatronState()`; `Manager.GetActiveDeity()`; `Manager.PDV_Kyne`; `Manager.GetTier(Manager.PDV_Kyne)`; `Manager.PATRON_STATE_ACTIVE`; `Manager.TIER_CHAMPION`; `Manager.GetPlayerOriginRaceIndex()`; `Manager.ORIGIN_ALTMER`; `Manager.IsAltmerFavorSuppressedByCurse()`; `Manager.PATRON_STATE_BROAD`; `Manager.ORIGIN_NORD`; `Manager.GetNordPantheonBaselineState()`; `Manager.NORD_BASELINE_OLD_WAYS`; `Manager.NORD_BASELINE_NINE_DIVINES` |
| IsValidFavorFamilyForLane | `Manager.IsValidAltmerSourceFavorFamily(familyValue)` |
| GetPlayerMcmFavorLine | `Manager.IsNordVampireSuppressed()` |

RULES calls that ride along unchanged (already `PDV_DevotionRules.X`):
`SetSelectedContextualFavorLane` -> `PDV_DevotionRules.ClampInt(...)`;
`GetContextualFavorSummary` -> `PDV_DevotionRules.FormatTwoDecimals(...)`. Both
are confirmed `Global` functions in
`live-source/Scripts/Source/PDV_DevotionRules.psc` (ClampInt @280,
FormatTwoDecimals @226), callable from any script.

## 6. Property migration list (the 42)

### 6a. 16 filled Spell properties -> need CK fills later (Section 7)

Read only by `GetFavorSpell` (18543-18587). No other manager-retained code and
no external script reads the `PDV_SPEL_Favor_*` properties, so ownership is
clean - they leave the manager entirely.

PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery, PDV_SPEL_Favor_Kyne_StormRoadGrace,
PDV_SPEL_Favor_Kyne_GuidedHunt, PDV_SPEL_Favor_Kyne_WindMarkedPassage,
PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance,
PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal,
PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense,
PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet,
PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance,
PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace,
PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty,
PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy,
PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft,
PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine,
PDV_SPEL_Favor_Altmer_Shared_DawnSteadiness,
PDV_SPEL_Favor_Altmer_Orthodox_CostlyEnforcement.

### 6b. 26 AutoReadOnly constants -> move verbatim, NO fill

5 lanes + 16 families (Int) + 5 durations/cooldowns (Float), values inline in the
Section 2 skeleton. Because they are compile-time constants with inline
initializers, they carry their values in the source and need no CK step.

IMPORTANT: these constants are also referenced by manager-retained code
(Section 6c) - after the move those references become `FavorRuntime.FAVOR_*`.

### 6c. Manager-retained references to FAVOR constants (rewire to FavorRuntime.*)

Concentrated in the Altmer source-favor block and a couple of resets:
- 10864, 10865 (HandleAltmerDawnSteadiness): FAVOR_FAMILY_ALTMER_DAWN_STEADINESS,
  FAVOR_LANE_ALTMER
- 10899, 10900 (HandleAltmerOrthodoxCostlyEnforcement):
  FAVOR_FAMILY_ALTMER_ORTHODOX_COST, FAVOR_LANE_ALTMER
- 11418, 11421 (RecordAltmerSourceFavor): FAVOR_LANE_ALTMER
- 11425, 11429, 11431 (IsValidAltmerSourceFavorFamily - the manager-retained fn
  that FAVOR calls): FAVOR_FAMILY_ALTMER_DAWN_STEADINESS,
  FAVOR_FAMILY_ALTMER_ORTHODOX_COST
- 11580 (an Altmer summary line): FAVOR_LANE_ALTMER
- 19616 (a reset): FAVOR_LANE_KYNE
- 25391 (an Altmer surfacing read): FAVOR_LANE_ALTMER

Note the bidirectional coupling: `IsValidAltmerSourceFavorFamily` stays in the
manager, is CALLED BY FAVOR's `IsValidFavorFamilyForLane`, and itself now reads
`FavorRuntime.FAVOR_FAMILY_ALTMER_*`. This is fine (no cycle at load - both are
resolved by property backref), but flag it in review.

## 7. External and manager-retained rewiring (reverse dependency, item #5)

Because manager-retained code and PDV_MCM call FAVOR functions and read FAVOR
constants, the manager MUST declare:

```papyrus
PDV_ContextualFavorRuntime Property FavorRuntime Auto
```

and every retained call site rewires `X(...)` -> `FavorRuntime.X(...)`, plus the
constant references in 6c rewire to `FavorRuntime.FAVOR_*`.

### 7a. Manager-retained internal callers (~43 invocations, ~39 lines)

UpdateContextualFavorRuntime: 998, 1037, 13405, 13416, 13437, 19618, 19708,
27931. ClearActiveFavor: 5150, 5171, 10858, 10893, 19554, 21500, 21510, 21589,
21684. TryActivateContextualFavor: 10865, 10900, 19550, 23112. IsFavorActive:
4040. GetActiveFavorLane: 4041. GetActiveFavorFamily: 4042.
GetContextualFavorLaneLabel: 4043. GetContextualFavorFamilyLabel: 4043, 11421,
11580. GetPlayerMcmFavorLine: 4145, 24893. GetFavorSurfacingLabel: 11418, 25391.
GetSelectedContextualFavorLane: 19535, 19544, 19550. SetSelectedContextualFavorLane:
19540, 19616. GetSelectedContextualFavorFamily: 19545, 19550.
GetNextFavorFamilyForLane: 19545. GetContextualFavorSummary: 26175, 26204, 26402.

These retained callers live mostly in: the daily/dawn tick paths (998, 1037,
13405-13437, 27931), patron-state transitions (5150, 5171), the Altmer
source-favor and vampire/werewolf suppression paths (10858-10900, 21500-21684),
the MCM `Debug*` shims (19535-19554), a reset (19616-19618, 19708), the
race-signal dispatch (23112), and the summary/report builders (4040-4145,
24893, 26175-26402).

### 7b. External callers - PDV_MCM.psc (3 sites, 0 property refs)

- L1898: `PDV_Manager.GetPlayerMcmFavorLine()`
- L3643: `manager.GetSelectedContextualFavorLaneLabel()`
- L3652: `manager.GetSelectedContextualFavorFamilyLabel()`

Recommended rewire: reach through the manager's new property rather than adding a
new MCM property/fill - `PDV_Manager.FavorRuntime.GetPlayerMcmFavorLine()` and
`manager.FavorRuntime.GetSelectedContextualFavor...Label()`. (Alternative: give
PDV_MCM its own `PDV_ContextualFavorRuntime Property FavorRuntime Auto` and fill
it - one more CK fill. Prefer reach-through.)

NOT rewired: PDV_MCM L3526-L3532 call `manager.DebugCycleContextualFavorLane()`,
`DebugCycleContextualFavorFamily()`, `DebugTriggerSelectedContextualFavor()`,
`DebugExpireActiveFavor()` - these are manager-retained `Debug*` shims (they stay
on the manager and internally forward to `FavorRuntime.*`), so PDV_MCM's calls to
them are unchanged.

`PDV_MCM.psc` reads NONE of the 42 FAVOR properties directly (its
`_oidFavorLaneCycle` / `_oidFavorFamilyCycle` and `GetFavorLaneOptionLabel` /
`GetFavorFamilyOptionLabel` are local MCM members, unrelated to the FAVOR set).

## 8. Hard-to-move flags

1. ResolveEligibleFavorLane (18443) - HEAVY manager coupling: 6 distinct manager
   function calls + `_activeDeity` + `PDV_Kyne` + 7 manager constants in one
   ~34-line body. It is the single most-coupled FAVOR function. It compiles inert
   fine through the `Manager` backref, but it is the function most likely to
   expose an ordering or None-backref fault at first live run; test it first once
   the QUST host exists.

2. SendContextualFavorToast (18360) - depends on the new `GetActiveDeity()`
   accessor AND on `Manager.SendPrismaEventToast(...)` (the Prisma toast bridge).
   The `_activeDeity` read cannot be satisfied without the manager code change in
   Section 4b; do not extract FAVOR without landing that getter in the same
   change.

3. _activeDeity accessor (cross-cutting) - the getter in Section 4b is a
   prerequisite, not optional. Without it, ResolveEligibleFavorLane and
   SendContextualFavorToast will not compile in the new script.

4. IsValidAltmerSourceFavorFamily bidirectional coupling (Section 6c) - manager
   retains it, FAVOR calls it, and it reads FAVOR constants. No load cycle, but
   review it as a pair with IsValidFavorFamilyForLane.

The remaining 4 coupled functions (TryActivateContextualFavor, ClearActiveFavor,
IsValidFavorFamilyForLane, GetPlayerMcmFavorLine) are light: 1-3 straightforward
`Manager.X()` rewirings each, no `_activeDeity`.

## 9. DEFERRED - ESP / CK work (batched houseCARL session)

The module is INERT until all of the following land. None are part of the
code-extraction change; they are the batched ESP session.

1. Create the host QUST record for `PDV_ContextualFavorRuntime` (start-game
   enabled, as the other PDV manager-side quests) and attach the compiled script
   as a quest script. Per project convention, remember SGE + SEQ if the host
   quest is start-game-enabled (EnsureQuest omits SGE).
2. Fill the 16 `Spell` properties on the host instance (Section 6a) with the same
   SPEL forms currently filled on `PDV__ManagerQuest`. The 26 `AutoReadOnly`
   constants need no fill.
3. Fill `Manager.FavorRuntime` (on the `PDV__ManagerQuest` instance) to point at
   the new host quest instance.
4. Fill the module's `Manager` backref to point at the `PDV__ManagerQuest`
   instance.
5. (Only if the reach-through in 7b is rejected) fill PDV_MCM's own
   `FavorRuntime` property.

Until steps 1-4 are done, `Manager` and `FavorRuntime` are None; every FAVOR
call from retained code no-ops or returns default, and the module's own
`Manager.X()` calls would fault only if invoked - which nothing does yet. That is
the intended inert state.

## 10. Extraction outcome + spec corrections (2026-08-18)

Code extraction DONE on `feature/v3-big-update` (post the 1.5.0e merge `65ca5c89`).
33 fns + 42 props moved to `PDV_ContextualFavorRuntime.psc`; manager + module + MCM
compile 0 err / 0 warn (isolated); static parity vs a fresh pre-extraction baseline =
**moved=27, changed=13 FAVOR-side + retained callers, removed=0, added=0**, and an
independent check confirmed **every changed body differs ONLY by `Manager.` /
`FavorRuntime.` prefixing** (0 non-prefix diffs). ESP/CK steps in Section 9 still deferred.

Two facts in this spec were wrong and the compiler/parity surfaced them - corrected here,
both handled:

1. **Section 5 undercounts `Trace` in `TryActivateContextualFavor`.** It says "Manager.Trace
   x3"; the body has **5** `Trace(` calls (all rewired to `Manager.Trace`). Rewiring is by
   token, not by the stated count, so this was automatically correct - but the count is wrong.
2. **Section 6a's ownership claim is wrong.** It states the 16 `PDV_SPEL_Favor_*` props are
   "read only by `GetFavorSpell`... no other manager-retained code." The manager-retained
   teardown **`StripAllPdvSpells(Actor)`** also references all 16 (to strip them from the
   player). Those 16 references were rewired to `FavorRuntime.PDV_SPEL_Favor_*` (reach-through);
   the props still leave the manager entirely. Any future module extraction must grep the
   whole manager for a moved property, not trust a single-reader claim.
