# PDV Architecture v2 - Migration Target

Last revised: 2026-05-16 (v2.7 - Phase 4 and 6 closeout proof)
Status: **Phase 4/5/6 proven** - Origin/bootstrap, stance, the MCM dev slice, and the coupled Talos + Auri-El hostile-path slice are now framework-owned, verifier-clean, and proven in game. Remaining follow-up is separate ReShade environment investigation plus later architecture phases.

---

## 1. Why this migration

> **Authoritative update (2026-05-11):**
> Phase 2 is complete for the Kyne proof slice. `PDV_DeityBase.psc`, `PDV_Deity_Kyne.psc`, and `PDV__ManagerQuest.psc` compile successfully, CK wiring is complete, `PDV_FLST_AllDeities` contains Kyne, and runtime verification succeeded in game.
>
> Confirmed in game:
> - patron activation updates `PDV_GLO_ActiveDeityIndex`
> - active piety and tier mirrors track the active patron correctly
> - `ProcessDawn()` clamps daily scratch to `+/-5`
> - persistent piety updates correctly after dawn processing
> - tier threshold crossing from `0` to `1` occurs at piety `10`
>
> The validated Phase 2 debug harness is poll-based inside `PDV__ManagerQuest` and driven by `SetPQV` plus a brief wait with the console closed. The earlier CK stage-fragment harness should be treated as superseded for this setup.
>
> **Phase 3 preflight update (2026-05-11):**
> The ActionRouter route has been tightened after checking CK/Papyrus behavior. Story Manager starts quests and then calls quest script events such as `OnStoryKillActor`; Papyrus does not "subscribe" a persistent quest to a Story Manager node directly. Phase 3 should therefore use a small Story Manager receiver quest for the Kill Actor event, and let that receiver call the persistent `PDV_ActionRouter` service. This avoids CK stage fragments, keeps the router persistent, and keeps Story Manager quest lifecycle isolated.
>
> **Phase 3 complete (2026-05-14):**
> `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` compile cleanly. CK wiring: `PDV_ActionRouter` quest (Start Game Enabled, priority 60), `PDV__SM_KillActor` receiver (not Start Game Enabled), Kill Actor Story Manager node with `Shares Event` checked, `Hours Until Reset = 0`. SEQ generated. **All four tests passed:** (1) hostile bandit (event 2, +0.5 routed and consolidated), (2) hostile wolf (event 1, -3.0 routed and consolidated with clamping), (3) neutral animal skip (correctly rejected via "not an Actor"), (4) rapid dual kills (both routed, accumulated to -2.5, consolidated at dawn with clamp to 0). Ready for Phase 4.
>
> **Race architecture update (2026-05-13):**
> The detailed per-race theology interrogation, curse interpretations, quest/faction weighting, and pre-matrix reward/system contract are now locked in `references/PDV_RaceArchitecture_DesignReference.md`, with supporting reference wording synced in the `references/tamriel-*.html` lore files. Until Sections 10-12 of this document are fully consolidated, treat the race architecture reference as the current source of truth for race-specific architecture wherever the two disagree.
>
> **Phase 4 matrix update (2026-05-13):**
> The first implementation-facing matrix set now exists under `references/phase4/`: scaffold, race signal matrix, stance matrix, Daedric race-by-Prince matrix, and cross-validation note. Treat those files as the current working source for signal-family granularity, stance seeding, and Daedric race-response crosswalks until Sections 10-12 are fully rewritten to absorb them.
>
> **Phase 4 script/tooling update (2026-05-14):**
> `PDV__MainQuest.psc`, `PDV_Origin.psc`, `PDV__ManagerQuest.psc`, `PDV_DeityBase.psc`, and `PDV_Deity_Kyne.psc` now compile cleanly with the Phase 4 framework changes in place. The compiler/verifier were updated to include the bootstrap/origin scripts and to fail or warn on the still-missing ESP surface: `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, Kyne stance values, and Kyne boon assignments. Treat the current phase state as **scripts/tooling complete, CK/ESP proof slice pending**.
>
> **Coupled Talos + Auri-El update (2026-05-14):**
> `PDV_Deity_Talos.psc` and `PDV_Deity_AuriEl.psc` now compile cleanly as the first hostile-path follow-on slice. `PDV_Origin.psc` was generalized from a Kyne-only helper into a small multi-deity seed table, and `PDV__ManagerQuest.psc` now exposes `AwardCuratedSignal()` / `AwardCuratedSignalByIndex()` for curated devotional state signals. Rivalry now keys off the written stance-adjusted gain. The verifier was extended to require Talos/Auri-El records, FormList membership, stance rows, Talos rivalry wiring, and deity boon assignments once the CK layer is built.
>
> **Framework merge-back update (2026-05-16):**
> The temporary manager/MCM overlay patches have been merged back into `PlayerDevotion_Framework.esp` and unticked in the `Devotion Dev` profile. The framework ESP now directly owns `PDV__ManagerQuest.PDV_GLO_PatronDeity` and the `PDV_MCM` script attachment/properties. Talos/Auri-El quest records, FormList membership, origin references, stance rows, rivalry wiring, and boon assignments are verifier-visible. Current verifier state is `FAIL=0, WARN=0, TODO=0`; remaining output is informational only.
>
> **Hybrid boon policy update (2026-05-14):**
> The race-level boon policy is now locked in `references/PDV_RaceArchitecture_DesignReference.md` as an asymmetric hybrid model. Every race gets one foreground devotional layer, but only structurally layered religions keep a true persistent substrate. `Nord`, `Imperial`, `Breton`, and `Bosmer` should usually rely on privileges, contextual favors, and state tracks rather than a second passive boon layer. `Altmer`, `Redguard`, and `Orc` keep only light persistent layers. `Dunmer`, `Khajiit`, and `Argonian` keep the strongest substrates. Balance rule: most races should never feel like they have more than two meaningful always-on boon families at once.

### Current state (v1)

Two-quest split - `PDV__MainQuest` (RunOnce bootstrap) and `PDV__ManagerQuest` (persistent runtime). The manager owns one global, `PDV_GLO_DevotionLevel`, and three buckets (`CombatBucket`, `SocialBucket`, `LifestyleBucket`). An hourly `OnUpdateGameTime` averages the buckets at the dawn window (5-6 in-game) and applies the shift to the global, clamped to +/-5 per day, 0-100 absolute.

### Why v1 doesn't scale

The mod brief calls for Wintersun-comparable deity breadth (~25-35 deities), a three-tier devotion system, origin-based gain modifiers, and per-deity scoring rubrics. The v1 model has structural ceilings against every one of those:

One global cannot represent per-deity piety. A Talos kill-bonus and a Mara charity-bonus collapsing into the same number is not a scoring bug - it's an architecture bug. The three buckets are global and identical for every deity, so there's no way to express "Mara cares about Social, not Combat" without forking the manager. There's no event-capture layer yet - the buckets exist but nothing fills them, which means the most expensive design decision (how do actions become piety?) is still entirely deferred. There's no tier mechanism, origin system, or MCM. And adding a second deity currently requires duplicating quest infrastructure rather than instantiating data.

### Target state (v2)

Deity becomes a first-class Quest, not a value. The manager becomes a dispatcher and helper API rather than a calculator. An `ActionRouter` quest sits between Story Manager events and deities, fanning each event to whichever deities care about it. Per-deity piety lives in a `StorageUtil` map keyed by deity FormID - that's the source of truth. A small set of mirror GlobalVariables shadows the *active patron's* current values so vanilla CK Conditions (dialog gating, shrine activator usability, magic effect filters, perk requirements) can read them natively without scripting glue at the call site. Origin is set once at first load and read by deities as a multiplier. MCM auto-generates panels by iterating a deity FormList. Pure Papyrus, with PapyrusUtil as a soft dependency.

---

## 2. File inventory

| File | Status | Notes |
|------|--------|-------|
| `PDV__MainQuest.psc` | Keep - Phase 4 script complete | Bootstrap, RunOnce. Live implementation now hard-checks PapyrusUtil and defers origin capture to the player-alias ingress instead of forcing `PDV_Origin.InitializeOrigin()` directly from `OnInit()`. |
| `PDV__ManagerQuest.psc` | Refactor - Phase 4 script/framework wired | Owns the per-deity ledger, dawn consolidation, mirror refresh, stance-aware scratch writes, rivalry plumbing, poll-based debug harness, and framework-owned patron global property. |
| `PDV_MasterQuest.psc` | ~~Delete~~ **Done 2026-05-10** | Pre-rename ancestor. ESP record removed via xEdit; `.psc` and `.pex` deleted. |
| `PDV_ActionRouter.psc` | New - wired/tested | Persistent fan-out service called by Story Manager receiver quests; fans actions to deities. CK quest/property wiring complete; hostile bandit/wolf routes verified. |
| `PDV__SM_KillActor.psc` | New - wired/tested | Non-Start-Game-Enabled Story Manager receiver for the Kill Actor event; calls `PDV_ActionRouter` from `OnStoryKillActor`. CK quest/Story Manager wiring complete; hostile receiver path verified. |
| `PDV_DeityBase.psc` | New - Phase 4 refactor complete | Base class all `PDV_Deity_<X>` scripts extend. Now carries race-keyed stance data, rivalry metadata, and patron-only cumulative boon sync. |
| `PDV_Deity_Kyne.psc` | New - Phase 4 proof slice script complete | First concrete deity. Template for all others; expects Nord-native / everyone-else-foreign stance wiring plus boon records in CK. |
| `PDV_Deity_Talos.psc` | New - coupled slice script complete | First hostile-path proof deity. Uses curated Talos-facing defiance signals and one-way Altmer rivalry to Auri-El. |
| `PDV_Deity_AuriEl.psc` | New - coupled slice script complete | Minimum viable Altmer foundation deity and real Talos rivalry target. |
| `PDV_Origin.psc` | New - script complete | One-shot race detection, sets origin global, seeds Kyne proof slice, and now treats the first Nord read as provisional so placeholder new-game race state does not lock too early. |
| `PDV_MCM.psc` | New - framework wired | SkyUI `Status` + `Debug` dev MCM, iterates `PDV_FLST_AllDeities`, attached directly to `PDV_MCM` in the framework ESP. |
| `PDV_PlayerEvents.psc` | New - V3 ingress live | Player-alias script on `PDV__ManagerQuest` for sleep/load and other non-kill pilot signals that Story Manager cannot reach cleanly. |

---

## 3. Quest topology

```
PDV__MainQuest          (bootstrap, runs once at game start)
  +- stage 10: init StorageUtil, verify PapyrusUtil, register deities
  +- stage 20: stop self

PDV__ManagerQuest       (Start-Game-Enabled, persistent)
  +- owns: PDV_FLST_AllDeities (FormList)
  +- owns: PDV_GLO_OriginRace, PDV_GLO_PatronDeity (the player's chosen patron)
  +- exposes: AwardPiety, RecomputeTier, GetTier, GetPiety, etc.
  +- optional dawn tick (decay only - keep scaffolding, drop averaging)

PDV_ActionRouter        (Start-Game-Enabled, persistent service)
  +- called by Story Manager receiver quests
  +- on event -> iterate PDV_FLST_AllDeities -> call deity.ScoreAction(event, payload)

PDV__SM_KillActor       (Story Manager-started receiver; not Start-Game-Enabled)
  +- receives Kill Actor event via OnStoryKillActor(victim, killer, location, crime, relationship)
  +- calls PDV_ActionRouter.HandleStoryKillActor(...)
  +- stops/resets itself after dispatch so later kills can start it again

PDV_Deity_Kyne          (Start-Game-Enabled, persistent)
  +- extends PDV_DeityBase
  +- owns: own piety (via StorageUtil), tier thresholds, rubric weights, boon list
  +- implements: OnAction(eventType, payload) -> translates to piety delta
  +- implements: OnTierChange(oldTier, newTier) -> grants/removes boon abilities

PDV_MCM                 (SkyUI menu)
  +- generates panels by iterating PDV_FLST_AllDeities

PDV_Origin              (utility quest, called by player-alias ingress)
  +- reads player race -> sets PDV_GLO_OriginRace once after the live race is stable
  +- treats the first Nord read as provisional if startup race resolution still looks placeholder
  +- seeds Kyne proof-slice starting piety
```

The two persistent quests (`ManagerQuest`, `ActionRouter`) plus N persistent `PDV_Deity_<X>` quests stay running for the life of the save. The bootstrap (`MainQuest`) and origin (`PDV_Origin`) are RunOnce.

---

## 4. Data model

### StorageUtil keys (PapyrusUtil)

All keyed by deity FormID using `StorageUtil.SetFloatValue(deityForm, key, value)`:

| Key | Range | Purpose |
|-----|-------|---------|
| `PDV.Piety` | 0-200 | Current piety. Drives tier. |
| `PDV.PietyToday` | unbounded | Daily scratch. Reset at dawn. |
| `PDV.Tier` | 0-3 | 0=None, 1=Seeker, 2=Devoted, 3=Champion. |
| `PDV.LastTierChange` | game time | For decay grace period and MCM display. |

Why StorageUtil for the per-deity store: one iterable map vs. ~120 declared global records (4 keys - 30 deities). Survives adding a deity in v1.4 without an ESP edit. Mass operations (reset all piety on patron change, daily consolidation loop) become one helper call instead of 30 hand-coded lines. PapyrusUtil is the de facto modding standard and almost always already installed in any modded profile.

### GlobalVariables - system-level

| Global | Purpose |
|--------|---------|
| `PDV_GLO_OriginRace` | 0=Nord, 1=Imperial, 2=Breton, 3=Altmer, 4=Bosmer, 5=Dunmer, 6=Khajiit, 7=Argonian, 8=Orsimer, 9=Redguard. Set once. See Section 12. |
| `PDV_GLO_PatronDeity` | FormID of player's chosen patron. 0 = none. |
| `PDV_GLO_DebugLevel` | 0-3, controls `Debug.Trace` verbosity. MCM-toggleable. |

The old `PDV_GLO_DevotionLevel` becomes dead and can be removed once StorageUtil migration is verified.

### GlobalVariables - active-patron mirrors

These shadow the current patron's StorageUtil values. Refreshed by `ManagerQuest.RefreshPatronMirrors()` on any piety mutation to the active patron, and on patron switch. Their entire job is to be readable by vanilla CK Conditions - they should never be the source of truth, only a cache.

| Global | Purpose |
|--------|---------|
| `PDV_GLO_ActivePiety` | Active patron's current `PDV.Piety`. For "Piety > 50" condition checks in dialog, perks, magic effects. |
| `PDV_GLO_ActiveTier` | Active patron's current tier (0-3). The most-used condition value - gates tier-locked content. |
| `PDV_GLO_ActiveDeityIndex` | Stable int from the deity's `DeityIndex` property. For condition-side `==` matching against a specific deity (e.g. "is patron Kyne"). |

Add more mirrors only when a specific condition need surfaces. Each mirror is sync overhead; resist the urge to mirror every StorageUtil key by reflex.

### Mirror refresh contract

`ManagerQuest.RefreshPatronMirrors()` reads the active patron's persistent StorageUtil values into the three mirror globals. Called from:

- `ProcessDawn()` - after active-patron persistent piety changes.
- `RecomputeTier(deity)` - if `deity == activePatron` and the stored tier changed.
- `OnPatronStart(newDeity)` - refresh wholesale, including `PDV_GLO_ActiveDeityIndex`.
- `OnPatronEnd()` - zero out all three mirrors.

Total glue: ~30 lines on the manager. Cheap.

### FormLists

| FormList | Contents |
|----------|----------|
| `PDV_FLST_AllDeities` | Every `PDV_Deity_<X>` Quest form. Iteration source. |
| `PDV_FLST_NordicDeities` | Subset eligible for Nordic-origin starting piety. |
| `PDV_FLST_ForeignDeities` | Subset for non-Nordic origins. (Many deities live in both.) |

---

## 5. The Deity quest template

This is the contract every concrete `PDV_Deity_<X>` honors. Code is illustrative - properties go on the Quest in CK, function bodies live in the per-deity script.

### Properties (set in CK)

```papyrus
Scriptname PDV_DeityBase extends Quest

; -- Identity --
String   Property DeityName Auto                 ; "Kyne"
String   Property DeityDomain Auto               ; "Storms, Hunt, Warriors' Spirit"
Int      Property DeityIndex Auto                ; stable int for MCM ordering

; -- Tier thresholds (default 25/50/85, override per-deity) --
Float    Property ThresholdSeeker = 25.0 Auto
Float    Property ThresholdDevoted = 50.0 Auto
Float    Property ThresholdChampion = 85.0 Auto

; -- Origin multipliers --
Float    Property GainMult_Nordic = 1.0 Auto
Float    Property GainMult_Imperial = 1.0 Auto
Float    Property GainMult_Mer = 1.0 Auto
Float    Property GainMult_Beast = 1.0 Auto
Float    Property GainMult_Foreign = 1.0 Auto

; -- Rubric weights (which actions matter, which sign) --
Float    Property Weight_Combat = 0.0 Auto       ; +1.0 if Talos, -0.5 if Stendarr-vs-mortals
Float    Property Weight_Social = 0.0 Auto
Float    Property Weight_Lifestyle = 0.0 Auto

; -- Boons (per-tier abilities) --
Spell    Property Boon_Seeker Auto
Spell    Property Boon_Devoted Auto
Spell    Property Boon_Champion Auto
```

### Contract (functions every deity inherits)

```papyrus
; Called by ActionRouter. Returns the piety delta this deity wants to apply.
Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; Default: return 0.0. Concrete deities override.
EndFunction

; Called by ManagerQuest at dawn after PietyToday is consolidated.
Function OnTierChange(Int oldTier, Int newTier)
    ; Default: grant new boon, remove old boon. Concrete may add VFX/dialog.
EndFunction

; Called by ManagerQuest when player picks/changes patron.
Function OnPatronStart()
EndFunction

Function OnPatronEnd()
EndFunction
```

### Concrete deity example (Kyne sketch)

```papyrus
Scriptname PDV_Deity_Kyne extends PDV_DeityBase

; In CK: set DeityName="Kyne", thresholds, GainMult_Nordic=1.25, etc.

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    if eventType == PDV_EventTypes.KILLED_HOSTILE_BEAST
        return -3.0   ; Kyne's beasts. Hunting prey is fine, slaughter is not.
    elseif eventType == PDV_EventTypes.KILLED_HOSTILE_HUMANOID_IN_COMBAT
        return +0.5   ; warriors' spirit
    elseif eventType == PDV_EventTypes.SHOUTED
        return +0.25  ; voice of Kyne
    elseif eventType == PDV_EventTypes.SLEPT_OUTDOORS
        return +0.5
    endif
    return 0.0
EndFunction
```

Adding a new deity is now: duplicate the script, change the rubric, set CK properties, append to `PDV_FLST_AllDeities`. No quest infrastructure to redo.

---

## 6. Event flow examples

### Player kills a bandit chief

1. Story Manager processes the Kill Actor Event node.
2. A non-Start-Game-Enabled receiver quest, `PDV__SM_KillActor`, starts and receives `OnStoryKillActor(victim, killer, location, crime, relationship)`.
3. The receiver immediately calls `PDV_ActionRouter.HandleStoryKillActor(...)`, then stops/resets itself.
4. Router guards the payload: killer must be the player for the first slice, victim and killer must cast to Actor, and hostility evidence must be present.
5. Router classifies: `KILLED_HOSTILE_HUMANOID_IN_COMBAT`.
6. Router iterates `PDV_FLST_AllDeities`. For each: `delta = deity.ScoreAction(eventType, killer, victim) * OriginMult`.
7. Router calls `ManagerQuest.AwardPiety(deity, delta)`.
8. Manager writes `StorageUtil.AdjustFloatValue(deity, "PDV.PietyToday", delta)`.
9. Mirrors do not change yet. The active patron's `PDV_GLO_ActivePiety` continues to reflect persistent `PDV.Piety` until dawn consolidation.

That's the full hot path. No persistent listeners on the player. No bucket math. Just: event -> score -> write -> mirror.

### Dawn tick (the surviving fragment of v1)

1. Manager's `OnUpdateGameTime` fires hourly. Between 5-6 game-hours, `ProcessDawn` runs.
2. For each deity in `PDV_FLST_AllDeities`:
   - Read `PietyToday`, clamp to +/-5, apply to `Piety` (0-200 absolute).
   - Reset `PietyToday` to 0.
   - Recompute tier from new `Piety`. If changed, fire `deity.OnTierChange(old, new)`.
3. Optional: apply small daily decay if no `PietyToday` activity for N days. Defer until v0.4.

So `ProcessDawn` shrinks dramatically - it's now a loop that consolidates per-deity scratch into per-deity persistent. No averaging, no global.

### Tier transition (Seeker -> Devoted on Kyne)

1. Dawn resolves Kyne's piety from 49.6 to 51.2.
2. Manager calls `RecomputeTier(Kyne)`. Old=1, new=2.
3. Manager calls `Kyne.OnTierChange(1, 2)`.
4. Default implementation: `Player.RemoveSpell(Boon_Seeker); Player.AddSpell(Boon_Devoted)`.
5. If Kyne is active patron, `RefreshPatronMirrors()` writes `PDV_GLO_ActiveTier = 2`. Any dialog or perk gated on tier = 2 immediately becomes available.
6. Optional override: Kyne plays a thunder VFX, Notification "Kyne marks you as Devoted."

---

## 7. Origin system

`PDV_Origin` now resolves from the player-alias ingress path rather than being forced immediately by `PDV__MainQuest.OnInit()`. It reads the player's current race, normalizes vanilla vampire race variants back to their birth-race index, and writes `PDV_GLO_OriginRace` once the live race is stable. If the only visible race is a temporary beast-form race such as `WerewolfBeastRace` or Dawnguard's Vampire Lord race, initialization defers rather than permanently writing a fallback. The live implementation also treats the first Nord read as provisional so Skyrim's temporary startup placeholder does not incorrectly bake `0` before Khajiit and other new-game races settle. Fixed thereafter - no recomputation on race-change mods (re-run only via MCM debug).

Each deity reads the global at action-scoring time and looks up the player's *stance* toward that deity (See Section 12.2) - `NATIVE / FOREIGN / TABOO / HOSTILE`. Stance drives the gain multiplier and any side-effects (rivalry penalties, NPC reactions). This replaces the simpler per-origin float multipliers from earlier drafts.

Starting piety: MainQuest seeds `Piety` per deity based on origin race. A Nord starts with Piety=10 on each of the Nordic-pantheon Eight + Talos, Piety=0 on most Daedra. A Khajiit starts at Piety=10 on Riddle'Thar, Alkosh, Azurah, Khenarthi, Lorkhaj, plus the moons; Piety=0 elsewhere. A stronghold-Orc starts with Piety=15 on Malacath only - every other deity is functionally locked until a cultural break event. Starting values live as a CK table on `PDV_Origin` keyed by `(race, deity)`.

---

## 8. MCM scope (v0.5+)

Single config quest, panels generated by iterating `PDV_FLST_AllDeities`:

- *Status* page: current piety, tier, and active patron state, per deity. Read-only.
- *Debug* page: development-only patron override, piety/scratch forcing, piety-map inspection, dawn pass trigger, deity reset, and debug level.

This first slice is explicitly a development surface, not the final player-facing devotion UX. Real patron commitment remains an in-world threshold-event concept rather than an MCM setting.

---

### Validated debug harness

The original testing plan assumed a CK quest-stage fragment would call into `PDV__ManagerQuest`. In the Anvil CKPE setup used by this project, fragment binding proved unreliable. The validated implementation instead keeps the test harness inside `PDV__ManagerQuest` itself:

- `DebugCommand`
- `DebugIndex`
- `DebugValue`
- `RunDebugCommand()`
- `DebugClearActiveDeity()`
- `DebugResetDeityByIndex()`
- `DebugForceSetPietyByIndex()`
- `DebugForceSetPietyTodayByIndex()`
- `DebugGetPietyMapString()`
- `OnUpdate()` polling every 1 second

In-game testing uses `SetPQV` to queue one command at a time, then requires the console to be closed for 2-3 seconds so Papyrus updates can fire. This is the current source-of-truth workflow for Phase 2 runtime verification.

## 9. Migration phases

Built so each phase ends in a runnable mod. Don't merge a phase that breaks the existing save.

### Phase 0 - Cleanup - **Complete 2026-05-10**

- ~~Delete `PDV_MasterQuest.psc` and its `.pex`. Confirm no ESP property still names it.~~ Done. ESP record removed via xEdit; orphan `.psc` and `.pex` deleted.
- ~~Verify the rename to `PDV__ManagerQuest` is clean - no orphan property references.~~ Done. Text audit clean; only historical comment in `PDV__ManagerQuest.psc:12` remains, which is intentional.
- ~~Add this document to the project root.~~ Done.

### Phase 1 - Data model swap - **Complete 2026-05-11**

- ~~Add PapyrusUtil as a master.~~ Done - StorageUtil API calls in place.
- ~~Declare the three mirror globals in CK: `PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`.~~ Done. Verified in-game with `GetGlobalValue`.
- ~~Strip `CombatBucket / SocialBucket / LifestyleBucket` and `PDV_GLO_DevotionLevel` from `PDV__ManagerQuest`.~~ Done. All bucket references removed.
- ~~Replace with thin helper API: `AwardPiety`, `GetPiety`, `RecomputeTier`, `GetTier`, `RefreshPatronMirrors`.~~ Done. API complete.
- ~~Wire `RefreshPatronMirrors` into `AwardPiety` and `RecomputeTier`.~~ Done.
- `ProcessDawn` FormList iteration loop added in Phase 2 (see below). Single-deity consolidation stub was confirmed working in Phase 1.
- Tested: mirror globals read back correctly at 0.0 on new save; `PDV_GLO_ActiveTier` and `PDV_GLO_ActivePiety` confirmed via console.

### Phase 2 - Deity-as-Quest - **Complete and verified 2026-05-11**

- ~~Create `PDV_DeityBase.psc` (the contract).~~ Done. Source at `Scripts\Source\PDV_DeityBase.psc`.
- ~~Create `PDV_Deity_Kyne.psc` extending it. Migrate the Kyne-specific scoring into `ScoreAction`.~~ Done. Kyne rubric implemented (beast kill -3, humanoid +0.5, shout +0.25, outdoor sleep +0.5).
- ~~Refactor `ProcessDawn` to iterate the FormList.~~ Done. Loop now consolidates `PDV.PietyToday` into persistent `PDV.Piety`, recomputes tier per deity, and fires `OnTierChange`.
- ~~Refactor manager API to per-deity StorageUtil state.~~ Done on disk. `AwardPiety`, `GetPiety`, `GetTier`, `RecomputeTier`, and `SetActiveDeity` now operate on deity quest arguments rather than one in-memory ledger.
- ~~Compile all three scripts; create `PDV_Deity_Kyne` quest form; create `PDV_FLST_AllDeities`; wire manager globals/FormList.~~ Done.
- ~~Verify runtime behavior in game.~~ Done. Live event capture remains Phase 3.

**Phase 2 completion update (2026-05-11):**

- CK compile and wiring are complete for the Kyne proof slice.
- `PDV_Deity_Kyne` quest exists and is attached correctly.
- `PDV_FLST_AllDeities` exists and contains Kyne.
- `PDV__ManagerQuest` required globals and FormList properties are assigned.
- Runtime verification succeeded in game:
  - patron activation updates `PDV_GLO_ActiveDeityIndex`
  - active mirror globals track the patron correctly
  - `ProcessDawn()` clamps daily scratch to `+/-5`
  - persistent piety updates correctly after dawn processing
  - tier threshold crossing from `0` to `1` occurs at piety `10`
- The validated test path is the manager's poll-based `SetPQV` harness, not CK quest fragments.

### Phase 3 - ActionRouter + first Story Manager node

Status: complete; CK wiring and in-game verification passed 2026-05-14.

Primary CK/Papyrus findings:

- Story Manager starts quests from event nodes; it does not directly subscribe an already-running persistent quest to an event stream.
- `OnStoryKillActor` is a Quest script event called when that quest is started by a Kill Actor Story Manager event. It carries victim, killer, location, crime status, and relationship rank.
- Story Manager nodes added by PDV must have `Shares Event` checked. Without it, PDV can consume the event and block later nodes from vanilla or other mods.
- `RegisterForUpdate` is not appropriate for production action capture. The existing 1-second `RegisterForSingleUpdate` loop remains a debug harness only.
- `IsHostileToActor()` must never be called with `None`; CK documentation flags that as crash-risk. Guard all casts before using it.

Corrected topology:

- Create `PDV_ActionRouter` as a Start-Game-Enabled persistent service quest. It owns no canonical piety state.
- Create `PDV__SM_KillActor` as a non-Start-Game-Enabled Story Manager receiver quest for the Kill Actor event.
- Attach `PDV__SM_KillActor.psc` to the receiver quest. It implements `OnStoryKillActor(...)`, calls `PDV_ActionRouter.HandleStoryKillActor(...)`, then stops/resets the receiver quest.
- Keep Story Manager fragments out of Phase 3 unless the quest event path fails in CKPE. Phase 2 already proved fragment binding is a bad default for this setup.

Router script surface:

```papyrus
Scriptname PDV_ActionRouter extends Quest

PDV__ManagerQuest Property PDV_Manager Auto
FormList Property PDV_FLST_AllDeities Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
Actor Property PlayerRef Auto
Keyword Property ActorTypeNPC Auto
Keyword Property ActorTypeAnimal Auto
Keyword Property ActorTypeCreature Auto ; fallback/diagnostic only

Int Property EVT_NONE = 0 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_BEAST = 1 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2 AutoReadOnly

Function HandleStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, Int aiCrimeStatus, Int aiRelationshipRank)
EndFunction

Function RouteAction(Int eventType, Form actorRef, Form targetRef)
EndFunction
```

Classification for the first vertical slice:

- Only direct player kills count. Follower kills, summons, traps, poison delayed attribution, and environmental kills are out of scope until the first slice is stable.
- Victim classification should use CK-wired `Keyword` properties (`ActorTypeNPC`, `ActorTypeAnimal`) checked against the victim actor/base, not `HasKeywordString()`.
- Hostility should require evidence. First pass: accept `aiRelationshipRank <= -2`, or a guarded `victimActor.IsHostileToActor(PlayerRef)` if that still returns true inside the event.
- If hostility evidence is absent, route `EVT_NONE` and trace at debug level 2+ rather than guessing.
- Wolf/bear/sabre cat should route to `EVT_KILLED_HOSTILE_BEAST` for Kyne's `-3.0`.
- Bandit/hostile humanoid should route to `EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT` for Kyne's `+0.5`.

Storage and mirror boundaries:

- `PDV_ActionRouter` calls `PDV_Manager.AwardPiety(deity, delta)` only.
- `AwardPiety` writes daytime scratch to `PDV.PietyToday` only.
- No Phase 3 event should update `PDV.Piety`, `PDV.Tier`, or mirror globals directly.
- Persistent piety, tier recompute, `OnTierChange`, and active-patron mirrors remain dawn-owned through `ProcessDawn()`.

Implementation checklist:

- ~~Create and compile `PDV_ActionRouter.psc`.~~ Done. Source and `.pex` exist.
- ~~Create and compile `PDV__SM_KillActor.psc`.~~ Done. Source and `.pex` exist.
- ~~Create CK quest `PDV_ActionRouter`; Start Game Enabled checked; assign manager, FormList, debug global, PlayerRef, and actor-type keyword properties.~~ Done.
- ~~Create CK quest `PDV__SM_KillActor`; Start Game Enabled unchecked; attach receiver script; assign `PDV_ActionRouter` property.~~ Done.
- ~~Add `PDV__SM_KillActor` under the Kill Actor Story Manager event node with `Shares Event` checked and no reset cooldown.~~ Done.
- Prefer CK node conditions for player-killer filtering if the event-data target UI is clear; keep the same guard in Papyrus regardless.
- ~~Generate/update SEQ because Phase 3 adds the new Start Game Enabled `PDV_ActionRouter` quest.~~ Done. SEQ lives under `Devotion\Seq`.

Test plan:

- ~~Compile both Phase 3 scripts cleanly with the known SSE import chain.~~ Done.
- ~~Confirm `SQV PDV_ActionRouter` shows the router running after game load.~~ Done during runtime validation.
- ~~Confirm `SQV PDV__SM_KillActor` is normally stopped, then starts/stops around a kill event.~~ Done during runtime validation.
- ~~With Kyne active, kill one hostile bandit. Confirm `PDV.PietyToday` receives `+0.5` and persistent mirror globals do not change before dawn.~~ Runtime log verified `event 2`, Kyne `+0.5` scratch.
- ~~Run `ProcessDawn()` through the existing debug harness. Confirm persistent piety increases by `+0.5` and mirrors update only after dawn.~~ Runtime log verified `0.0 -> 0.5`.
- ~~Reset Kyne, kill one hostile wolf. Confirm `PDV.PietyToday` receives `-3.0`, then dawn applies the clamped result.~~ Runtime test passed for `event 1`, Kyne `-3.0` scratch.
- ~~Kill a non-hostile animal or neutral NPC in a controlled test. Confirm the router either ignores it or traces a deliberate "not hostile" skip; do not silently score it.~~ Runtime test passed; neutral kill was rejected with no piety change.
- ~~Kill two valid targets quickly. Confirm the receiver quest restarts cleanly and the router records two separate scratch changes.~~ Runtime test passed; bandit + wolf accumulated to `-2.5` before dawn and consolidated with clamp.

Known risks to verify in CK/in game:

- `OnStoryKillActor` does not work on actors with the Simple Actor flag. This is acceptable for the first slice but should be noted if a test actor refuses to fire.
- `IsHostileToActor()` after death may not be reliable. If it fails, prefer event relationship rank and/or CK node conditions rather than widening the event to all kills.
- `ActorTypeAnimal` versus `ActorTypeCreature` classification needs live validation on wolf, bear, sabre cat, bandit, draugr, and summoned creature before the rubric expands.
- Receiver quest stop/reset behavior passed the first rapid-kill test, but keep an eye on it if later event volume or additional receiver quests are added.
- Do not add follower-kill attribution until the player-only path is proven. It changes the theology/UX question and increases event ambiguity.

### Phase 4 - Origin + stance + tier transitions

- Create `PDV_Origin`. Run from MainQuest stage 10. Race-keyed (`PDV_GLO_OriginRace`).
- Implement stance taxonomy on `PDV_DeityBase` per Section 12.2 (replaces the earlier `GainMult_<Origin>` floats).
- Implement rivalry ledger per Section 12.3 (call site: `AwardPiety`, after stance check).
- Add `OnTierChange` boon-grant logic in `PDV_DeityBase`.
- Author Kyne's three boon spells in CK.
- Seed Kyne's stance row across all 10 races (NATIVE for Nord, FOREIGN for most others, TABOO/HOSTILE for none - Kyne is non-controversial).
- Test: Nord starts Kyne piety higher than Altmer; tier transitions grant/revoke spells correctly; stance lookup returns expected values for all 10 races.

### Phase 5 - MCM

- Implement `PDV_MCM` per scope above. Script/tooling/framework attachment are present.
- Current proof status: `PlayerDevotion` registers in SkyUI and the `Status` + `Debug` pages work on the live Kyne/Talos/Auri-El roster.
- Environment caveat: the successful smoke path currently requires `ReShade64.dll` disabled in the Anvil Stock Game while the native conflict is investigated separately.
- Persistence confidence is now covered through the broader Phase 4/6 closeout passes; the first development-facing slice is functionally proven.

### Phase 6 - Second deity (Talos)

- Coupled slice: `PDV_Deity_Talos.psc` plus `PDV_Deity_AuriEl.psc`.
- Talos proves hostile-path rivalry against a real Auri-El ledger target.
- Keep first-pass Talos signals curated and CK/state driven rather than broad event-router expansion.
- This is the proof that the architecture pays back its complexity under ideological conflict, not just deity duplication.
- Current proof status: Altmer bootstrap seeds Auri-El correctly, Talos starts unseeded, curated Talos defiance signals can be applied through the debug surface, rivalry drains Auri-El while Talos rises across dawn consolidation, Talos reaches Seeker at the expected threshold, patron-only boon removal still works on swap, and the proven Talos state survives save/load.

### Phase 7+ - Remaining deities, ritual quests, tier-3 questlines

Out of scope for this migration document.

---

## 10. Open decisions deferred

Things this plan doesn't pin down - flag for future revisit:

- **Boon revocation on patron-change.** Resolved for the Phase 4 proof slice: swapping patron immediately strips the old patron's live boon spells. Stored piety/tier remain.
- **Boon-grant policy.** Resolved for the Phase 4 proof slice: deity boon spells are patron-only, but cumulative by tier for the active patron. Later race substrate implementation should follow the locked asymmetric hybrid boon policy in `references/PDV_RaceArchitecture_DesignReference.md`.
- **Decay model.** Linear daily decay if untouched? Decay only past Devoted? Decay disabled at Champion? All viable; defer until Phase 1 is in saves and the feel is testable.
- **Storage migration.** When v1 saves are loaded into v2 mod, what happens to the old `PDV_GLO_DevotionLevel`? Probably ignored - Kyne piety reseeds from origin. Document this as a save-game gotcha.
- **Failure mode if PapyrusUtil missing.** Hard fail with notification, or fall back to N globals? Recommend hard fail - PapyrusUtil is universal in modded Skyrim.

### Contested lore items affecting stance assignments

These are flagged for explicit decision before locking the Section 12.4 matrix into CK data. All have multiple in-world sources disagreeing:

- **Trinimac as a worshipable Orsimer deity.** Mainline games treat Trinimac as either dead/consumed or a marginal heretic position. ESO leans heavily on Trinimac-revivalist factions. **(ESO low canon - flag.)** Decision: include Trinimac as a parallel Orc devotion (with Orsimer stance NATIVE, Altmer stance HOSTILE for the original betrayal), exclude entirely, or include as a tier-3 unlock for Orcs who break with Malacath orthodoxy.
- **Talos's divinity.** The Thalmor's official position is that Tiber Septim's apotheosis was illegitimate; in-universe scholarship is genuinely contested across reliable narrators. PDV treats Talos as functionally a deity for game purposes, but Altmer stance should be `HOSTILE` (theological enemy, not just culturally foreign).
- **Hircine's status for Bosmer.** Whether Wood Elf reverence of Hircine is "Daedra worship" or "Y'ffre-adjacent Wild Hunt veneration" varies by source. *Pocket Guide to the Empire 3rd Edition* leans the latter; some in-game books call it the former. Recommend treating as `NATIVE` for Bosmer and noting the disagreement in the deity description.
- **Malacath's classification.** Daedric Prince per Imperial taxonomy, but multiple in-world reliable narrators argue this is post-Trinimac propaganda and that Malacath functions as the Orsimer ancestor-god. Architecture-wise this is a labeling question; affects whether rivalries between Malacath and Aedric pantheons fire.
- **Lorkhan/Shor/Sep/Lorkhaj equivalence.** Treating these as the same entity (with race-coded valence) is the standard fan reading and is reasonably supported in Mythic Dawn Commentaries and the Anuad. But `STANCE` per race differs sharply: Nord NATIVE (Shor), Khajiit POSITIVE (Lorkhaj as creator), Altmer HOSTILE (deceiver), Redguard HOSTILE (Sep as villain). Worth deciding whether they're one form with race-coded stance or separate entities for gameplay simplicity.

---

## 11. SKSE/dependency stance

- **Hard masters:** Skyrim.esm, Update.esm, Dawnguard, Hearthfires, Dragonborn.
- **Hard soft-dependency:** PapyrusUtil SE/AE (for StorageUtil).
- **Hard soft-dependency:** SkyUI (for MCM).
- **No DLL dependencies authored by this mod.** Everything is Papyrus.
- **Optional:** PO3 Papyrus Extender if/when a future event source needs it. Not required to ship v1.

This keeps the mod deployable on any modded Skyrim profile without an Address Library matrix or SE-vs-AE-vs-VR build problem.

---

## 12. Race-conditional religion

Supersession note (2026-05-13): this section is still the older stance-model draft. Use `references/PDV_RaceArchitecture_DesignReference.md` as the current source of truth for the locked race architectures, curse behavior, and quest-choice weighting until this section is rewritten to match.

The earlier draft treated origin as a multiplier problem - every race could accrue piety on every deity, just at different rates. Logic-checking against TES religious lore showed that this is wrong on inspection: an Altmer worshipping Talos isn't merely *slow*, the worship is theologically anathema; an Argonian doesn't have a "pantheon" in the same sense other races do; a stronghold-Orc has functionally one deity, not thirty at low gain. This section adds the data layer needed to model that.

### 12.1 Origin model - race-keyed

Replace the earlier 5-bucket `OriginGroup` (Nordic / Imperial / Mer / Beast / Other) with a 10-bucket race-keyed `OriginRace`. The five-bucket version conflated religiously incompatible races: "Mer" lumped Altmer (Aedric-orthodox, anti-Lorkhan) with Bosmer (Y'ffre-Hircine syncretists) and Dunmer (Daedric Reclamations, anti-Aedric); "Beast" lumped Khajiit (broadly polytheistic) with Argonians (Hist-only). Race-keyed is one extra global and ten classifications instead of five - cheap.

```papyrus
; Constants on PDV_Origin
Int Property RACE_NORD      = 0 AutoReadOnly
Int Property RACE_IMPERIAL  = 1 AutoReadOnly
Int Property RACE_BRETON    = 2 AutoReadOnly
Int Property RACE_ALTMER    = 3 AutoReadOnly
Int Property RACE_BOSMER    = 4 AutoReadOnly
Int Property RACE_DUNMER    = 5 AutoReadOnly
Int Property RACE_KHAJIIT   = 6 AutoReadOnly
Int Property RACE_ARGONIAN  = 7 AutoReadOnly
Int Property RACE_ORSIMER   = 8 AutoReadOnly
Int Property RACE_REDGUARD  = 9 AutoReadOnly
```

`PDV_Origin.DetectAndSet()` now runs from the player-alias ingress path after bootstrap instead of being forced directly at MainQuest stage 10. It reads the player's current race, matches normal vanilla races through CK-wired properties, normalizes the ten vanilla `*RaceVampire` records to the same base indexes, and writes the int to `PDV_GLO_OriginRace`. Temporary transformation races such as `WerewolfBeastRace` and Dawnguard's Vampire Lord race return `RACE_UNKNOWN` so bootstrap can defer rather than baking the wrong origin. The live implementation also treats the first Nord read as provisional to avoid Skyrim's placeholder startup race being locked as the permanent origin. Custom races without a known mapping default to `RACE_IMPERIAL` with a debug trace flag - this is the most religiously syncretic baseline, least likely to feel wrong.

### 12.2 Stance taxonomy

Each `(deity, race)` pair carries a stance value. Four stances:

| Stance | Code | Gain mult | Side effects |
|--------|------|-----------|--------------|
| `NATIVE` | 0 | 1.0x | None. The deity is part of the race's cultural pantheon. |
| `FOREIGN` | 1 | 0.5x | None. Accessible but unusual for the race. |
| `TABOO` | 2 | 0.75x | Optional NPC reaction trigger; faction reputation drift if implemented. Worship works, but it's culturally costly. |
| `HOSTILE` | 3 | 1.0x | **Triggers the rivalry ledger.** Worshipping this deity actively erodes piety on a defined rival deity (the player's "natural" deity for this domain). Lockable behind a discoverable cultural-break event. |

Stance lives on the `PDV_DeityBase` quest as a 10-element array (one per race), set in CK on each concrete deity:

```papyrus
; PDV_DeityBase
Int[] Property StancePerRace Auto   ; length 10, indexed by RACE_<X>

Int Function GetStanceForPlayer()
    Int race = PDV_GLO_OriginRace.GetValueInt()
    return StancePerRace[race]
EndFunction

Float Function GetGainMultiplier(Int stance)
    if stance == 0      ; NATIVE
        return 1.0
    elseif stance == 1  ; FOREIGN
        return 0.5
    elseif stance == 2  ; TABOO
        return 0.75
    else                ; HOSTILE
        return 1.0
    endif
EndFunction
```

This replaces the earlier `GainMult_Nordic / GainMult_Imperial / GainMult_Mer / GainMult_Beast / GainMult_Foreign` properties - those go away. The stance table subsumes them with more expressive power.

### 12.3 Rivalry ledger

When piety accrues on a deity that is `HOSTILE` to the player's race, a *rival* deity loses piety in proportion. Implements the cross-pantheon hostility the multiplier model can't express.

Each deity carries a list of `(rival_deity, multiplier)` pairs. When `AwardPiety(deity, delta)` writes a positive delta and the player's stance is `HOSTILE`, the manager iterates the rival list and calls `AwardPiety(rival, -delta * mult)` on each.

```papyrus
; PDV_DeityBase
Form[]  Property RivalDeities Auto      ; FormIDs of rival Deity quests
Float[] Property RivalMultipliers Auto  ; parallel array, same length
```

Concrete examples this models that the earlier architecture couldn't:

An Altmer player's bandit-kill awards Talos +0.5 (Talos's `HOSTILE` stance for Altmer fires). Talos's rival list contains `(Auri-El, 1.0)`. Auri-El loses 0.5 piety. Long-term, an Altmer cannot drift into Talos worship without cratering their relationship with Auri-El. Lore-faithful.

A Nord player accepts a daedric sword in a Boethiah quest - Boethiah piety rises, Boethiah's rival list contains `(Stendarr, 0.5)` and `(Talos, 0.3)`. Both Aedric piety values drift down. The Nord can still pursue Boethiah, but the cost is visible in the Aedric ledger.

An Orsimer player who breaks with Malacath orthodoxy and pursues Boethiah pays double - Boethiah is `HOSTILE` for Orsimer (the consumer of Trinimac myth), Malacath's rival list includes `(Boethiah, 1.0)`, *and* Boethiah's rival list includes `(Malacath, 1.0)`. The bidirectional rivalry is the deepest in the system.

Rivalry firing is gated by stance - `NATIVE` and `FOREIGN` worship doesn't trigger rivals. Only `HOSTILE` does. `TABOO` is a softer state that uses NPC reactions instead of piety penalties. This keeps the rivalry ledger from over-firing - most worship is just worship, not war.

### 12.4 Default stance matrix

Starting point for the per-deity-per-race assignments. Each race's row lists notable assignments; deities not listed default to `FOREIGN`. The matrix lives as design source-of-truth here; the implementation reads from CK properties on each Deity quest.

**Nord (RACE_NORD = 0)**
- `NATIVE`: Akatosh, Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Zenithar, Talos, Shor (= Lorkhan), Tsun, Stuhn, Ysmir, Orkey
- `TABOO`: Boethiah, Mehrunes Dagon, Molag Bal, Mephala, Namira, Peryite, Vaermina, Clavicus Vile
- `HOSTILE`: None mainstream - Nordic religion is shame-coded toward Daedra rather than rival-coded.
- *Notes:* Hircine has Nordic cult traditions (the Companions/Glenmoril) - keep `FOREIGN` rather than `NATIVE` to preserve the cult-not-mainstream framing. The Old Way / dragon priest cults are too narrow for race-level stance; defer to faction overlays.

**Imperial (RACE_IMPERIAL = 1)**
- `NATIVE`: Akatosh, Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Zenithar
- `FOREIGN`: Talos (officially banned post-WGC, but private worship is widespread in 4E Skyrim - this is a 4E-specific quirk worth flagging in the deity description)
- `TABOO`: Mehrunes Dagon, Molag Bal, Boethiah (the formally illegal three under Imperial law)
- `HOSTILE`: None - even the banned Daedra are illegal-not-anathema. Imperial religion is structurally tolerant.

**Breton (RACE_BRETON = 2)**
- `NATIVE`: Akatosh, Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Zenithar, Magnus, Y'ffre/Jephre, Phynaster
- `FOREIGN->NATIVE` (open Daedra): Hermaeus Mora, Sheogorath, Azura - witch-cult worship is normalized in High Rock, not heretical
- `HOSTILE`: Sheor (= Lorkhan in Breton mythology, framed as the villain). This affects Talos stance secondarily - Bretons accept Talos as Tiber-Septim-the-Emperor more than as Lorkhan-shard, so Talos stays `NATIVE` but the underlying Lorkhan-figure is `HOSTILE`. Worth a Decisions Log entry resolving the inconsistency.

**Altmer (RACE_ALTMER = 3)**
- `NATIVE`: Auri-El (Akatosh), Phynaster, Syrabane, Magnus, Xarxes, Jephre, Stendarr (less prominent but Aedric-aligned)
- `FOREIGN`: Most other Aedra in their non-Altmer forms (Mara, Kynareth, etc. - accessible but Altmer worship Auri-El's domain through Auri-El)
- `TABOO`: Most Daedric Princes
- `HOSTILE`: **Talos** (Lorkhan-shard, theological enemy), **Lorkhan/Shor** in any form, **Boethiah** (the betrayer who consumed Trinimac), **Trinimac** (contested - Trinimac being worshipable AT ALL is the open lore question; if included, HOSTILE for Altmer is the betrayal-narrative-faithful stance)

**Bosmer (RACE_BOSMER = 4)**
- `NATIVE`: Y'ffre/Jephre (primary), Auri-El, Jone & Jode, Z'en, Baan Dar
- `NATIVE` (positive Daedra): **Hircine** (Wild Hunt veneration - flag the lore disagreement; PGE3 frames as Y'ffre-adjacent, other sources frame as Daedric)
- `FOREIGN`: Eight Divines (Imperial contact, syncretized over time)
- `HOSTILE`: None - Bosmer are pragmatic syncretists; even Mephala has assassin-cult traditions that don't trigger broader hostility

**Dunmer (RACE_DUNMER = 5)**
- `NATIVE`: Azura, Boethiah, Mephala (the Reclamations / Three Good Daedra)
- `NATIVE` (faction-conditional): Almalexia, Sotha Sil, Vivec - Tribunal Temple traditionalists; default Dunmer in Skyrim's 4E setting is post-Tribunal Reclamation, so these can default to `FOREIGN` and shift to `NATIVE` if a faction-tag system is added later
- `TABOO`: Molag Bal, Mehrunes Dagon, Malacath, Sheogorath (the Four Corners - propitiated, not worshipped)
- `FOREIGN` (alien): Eight Divines, Talos, Yokudan/Khajiiti pantheons
- `HOSTILE`: None default - Dunmer religious culture is alien-to but not hostile-toward Aedric worship in mainstream framing. Could be argued for HOSTILE on Aedric if you want stronger cultural friction.

**Khajiit (RACE_KHAJIIT = 6)**
- `NATIVE`: Riddle'Thar (cosmic principle), Alkosh, Azurah, Khenarthi, Lorkhaj, Magrus, Mafala, Hermorah, Jone & Jode (the moons - central to Khajiit identity, lunar phase determines furstock)
- `NATIVE` (Daedra-aligned forms): Hircine (Rajhin myth), Mafala (= Mephala), Hermorah (= Hermaeus Mora) - Khajiiti cosmology integrates Daedra rather than excluding them
- `FOREIGN`: Eight Divines (Imperial contact)
- `HOSTILE`: None - Khajiiti religion is one of the most inclusive in TES

**Argonian (RACE_ARGONIAN = 7)**
- `NATIVE`: **Hist** (sentient cosmic substrate, not a deity in the polytheistic sense - see lore notes), **Sithis** (the unmade, primal force)
- `FOREIGN`: All other deities, including the entire Aedric pantheon and most Daedra
- `HOSTILE`: None mainstream
- *Notes:* Argonians are the genuinely alien case. The Hist isn't iterated like other deities - it's a single foundational devotion, not a multi-deity worship pattern. Architecturally this is fine (`PDV_FLST_AllDeities` still iterates, Hist just returns `NATIVE` for Argonian and `FOREIGN/locked` for everyone else), but the *gameplay feel* should reflect that an Argonian's religious life is structurally narrower than other races'. MCM presentation for Argonian players should hide or de-emphasize the Aedric/Daedric pantheons by default. Argonians outside Black Marsh sometimes adopt Aedric worship as documented assimilation - this is opt-in via in-game choice, not default.

**Orsimer (RACE_ORSIMER = 8)**
- `NATIVE`: **Malacath / Mauloch** (the Orsimer god - stronghold-raised Orcs are functionally mono-focused on him)
- `FOREIGN` (city-Orc syncretism): Eight Divines - represents assimilated Orcs who broke with stronghold culture
- `TABOO`: Most Daedric Princes other than Malacath
- `HOSTILE`: **Boethiah** (consumer of Trinimac in the betrayal myth - bidirectional rivalry with Malacath), **Auri-El** (in Trinimac myth, Auri-El allowed the betrayal - softer hostility)
- *Notes:* Stronghold-vs-city distinction matters here and isn't currently modeled. For v1, treat all Orsimer as stronghold-raised by default; defer city-Orc syncretism to faction overlays.

**Redguard (RACE_REDGUARD = 9)**
- `NATIVE`: Satakal (Worldskin), Ruptga (Tall Papa), Tu'whacca (= Arkay), Zeht (= Zenithar), Morwha (= Mara), Tava (= Kynareth), HoonDing (Make-Way), Diagna
- `FOREIGN`: Eight Divines (Forebears more syncretic than Crowns; default to `FOREIGN` for both, can be tightened if faction split is added)
- `HOSTILE`: **Sep** (Lorkhan-as-villain, banished serpent), **Malooc** (banished serpent god - the goblin gods category). If you treat Lorkhan = Sep = Shor as one entity, Redguard stance toward that entity is `HOSTILE` and conflicts with Nord `NATIVE` - this is exactly the kind of cross-race lore tension the system is built for.

### 12.5 Implementation cost

Adding Section 12 doesn't change the bones of v2 - it adds data and a small amount of glue. Concretely:

- One additional global (`PDV_GLO_OriginRace` replaces `PDV_GLO_OriginGroup`).
- One stance array (10 ints) per Deity quest. Set in CK, costs about a minute of clicking per deity.
- One rival list (parallel Form[] / Float[] arrays) per Deity quest. Most deities have 0-2 rivals; only a handful (Talos, Boethiah, Lorkhan-figures) have more.
- Maybe 50 lines of additional Papyrus on `PDV_DeityBase` for `GetStanceForPlayer()`, `GetGainMultiplier(stance)`, and rivalry-fire logic in `AwardPiety`.
- The default stance matrix above, encoded as CK property values across all deity quests.

Build cost grows with deity count, but each deity is independent of every other - adding deity #18 doesn't make deity #5 harder to maintain. Phase 4 is the natural home for this work.

---

## 13. Revisions

### v1.12 - 2026-06-11 - Highest-tier-only reward consolidation (all races)

Reward tier sets no longer stack additively. Every race's focused tier family
(`Sync<Race>RewardFamily`) and every substrate triad
(`PDV_SubstrateBase.SyncSubstrateBoonsToTier`) now grants ONLY the highest
qualifying tier/slot, whose record carries the cumulative magnitude of all the
tiers below it (rebalanced via `tools/pdv_cumulative_rebalance.mjs`, 38
families; descriptions regenerated via `tools/pdv_reward_desc_regen.mjs`).
Total power is unchanged; the Active Effects list shows ~3 named bonuses per
active family instead of the full per-tier stack. Two-tier broad sets remain
additive by design (already <=3 effects). New invariant for reward authoring:
**a tier spell's magnitudes are CUMULATIVE totals, not per-tier deltas** - any
future tier added to a family must carry the summed value. Argonian
consolidation runtime-validated; other races machine-proven (compile +
readback), per-race smoke pending. Same session: Argonian gameplay-variety
tranche (posture dreams, bed-of-choice declaration + Rooted Rest, Shadowscale
veil, Waters That Remember, permanent Hist Adaptation rite) - see the AGENTS
Decisions Log 2026-06-11 entries.

### v1.11 - 2026-05-16 - Origin race normalization

`PDV_Origin` now treats vanilla vampire races as variants of the player's permanent cultural origin, not as separate origins. Temporary beast-form races now defer one-shot origin initialization rather than baking the Imperial fallback while the player is transformed. Compile and verifier passed with `FAIL=0, WARN=0, TODO=0`.

### v1.10 - 2026-05-14 - Phase 3 CK wiring and hostile kill routes verified

Created and wired the Phase 3 CK records: `PDV_ActionRouter` as the Start Game Enabled service quest, `PDV__SM_KillActor` as the non-Start-Game-Enabled Story Manager receiver, and a Kill Actor Story Manager node with `Shares Event` checked. Generated SEQ into the Devotion mod and enabled Papyrus logging in the Devotion Dev profile.

Runtime logs verified the first live action-capture path: Kyne activation, hostile bandit kill routing as `event 2` with `+0.5` daily scratch, manual dawn consolidation from `0.0` to `0.5`, and hostile wolf kill routing as `event 1` with `-3.0` daily scratch. Remaining Phase 3 edge tests are neutral-kill skip behavior and rapid-kill receiver reset/cumulative scratch behavior.

### v1.9 - 2026-05-13 - Phase 4 matrix artifacts added

No implementation or phase checkbox changed in this revision. The purpose of
this pass was to turn the locked race-architecture work into an
implementation-facing Phase 4 design set without pretending the Phase 4 scripts
or CK records already exist.

Added the following working artifacts under `references/phase4/`:

- `PDV_Phase4_MatrixScaffold.md`
- `PDV_RaceSignalMatrix.csv`
- `PDV_StanceMatrix.csv`
- `PDV_DaedricRacePrinceMatrix.csv`
- `PDV_MatrixCrossValidation.md`

These files capture the first-release signal families, the per-race stance
seeding assumptions, the Prince-first Daedric race-response crosswalk, and the
intentional places where the stance taxonomy and Daedric response taxonomy
differ without actually conflicting. They should be treated as the current
implementation-facing Phase 4 reference until this document's older Sections
10-12 are fully consolidated and rewritten against the locked race file.

### v2.0 - 2026-05-14 - Phase 3 complete: ActionRouter kill event slice operational

Phase 3 kill event capture, routing, and daily consolidation now fully tested and operational. Story Manager Kill Actor event flows to `PDV__SM_KillActor` receiver, which calls `PDV_ActionRouter` to fan kills across `PDV_FLST_AllDeities`. Each deity's `ScoreAction(event, payload)` returns a piety delta, written to daily scratch via `AwardPiety()`. Dawn consolidation clamps to Ãƒâ€šÃ‚Â±5, updates persistent piety, recomputes tiers, and refreshes mirrors. All four test scenarios passed: hostile humanoid (event 2, +0.5), hostile animal (event 1, -3.0), neutral rejection (correctly skipped), and rapid dual kills (both routed, accumulated correctly, consolidated with clamp). `PDV_ActionRouter.psc` and `PDV__SM_KillActor.psc` compile cleanly. CK wiring complete (quest creation, Story Manager node, SEQ generation). Ready to move to Phase 4 (origin system, boon grants, stance taxonomy).

### v1.8 - 2026-05-13 - Race architecture reference synced

No implementation or phase status changed in this revision. The purpose of this pass was to prevent documentation drift after the dedicated race-architecture grill and lore reconciliation work completed in `references/PDV_RaceArchitecture_DesignReference.md`.

Locked outcomes now live there for Imperial, Khajiit, Bosmer, Redguard, Orc, and Argonian, including curse behavior and the rule that clear quest and faction choices should usually outweigh ambient behavior when they express a race's theology. The same file now also owns the pre-matrix reward/system contract: passive cumulative tier blessings, passive contextual favors, religious privileges, cost classes, cadence, anti-farm rules, standalone dependency posture, and compatibility annotations. Supporting wording in the local `references/tamriel-*.html` files was also synced.

This document's older race-specific stance material in Sections 10-12 remains useful as an architecture draft, but should be treated as partially superseded where it conflicts with the grill-session reference until a full Phase 4 consolidation pass rewrites it.

### v1.7 - 2026-05-11 - Phase 3 scripts compiled

Implemented the Phase 3 Papyrus slice on disk. `PDV_ActionRouter.psc` now validates direct player kill events, requires hostility evidence, classifies `ActorTypeNPC` and `ActorTypeAnimal`, fans scoring to `PDV_FLST_AllDeities`, and writes only through `PDV__ManagerQuest.AwardPiety()`. `PDV__SM_KillActor.psc` now handles `OnStoryKillActor(...)`, forwards to the router, then stops/resets.

Compile results: both new scripts compile cleanly to `.pex` in the Devotion mod. CK record work and hostile bandit/wolf runtime tests were completed in v1.10; neutral and rapid-kill edge tests remain.

### v1.6 - 2026-05-11 - Phase 3 preflight route corrected

Interrogated the planned Phase 3 route against CK/Papyrus source behavior before implementation. The important correction is that `PDV_ActionRouter` remains a persistent service quest, while Story Manager starts a small receiver quest (`PDV__SM_KillActor`) that handles `OnStoryKillActor`, calls the router, and then stops/resets. This avoids treating Story Manager as a direct subscription API and avoids CK stage fragments, which were unreliable during Phase 2.

Locked Phase 3 boundaries:
- first slice is player-only Kill Actor capture
- router writes only through `PDV__ManagerQuest.AwardPiety()`
- event actions write only to `PDV.PietyToday`
- persistent piety, tier recompute, mirrors, and `OnTierChange` remain dawn-owned
- `Shares Event` is required on PDV Story Manager nodes for compatibility
- actor classification uses CK-wired keyword properties rather than SKSE string keyword lookup
- hostility checks must guard `None` before calling `IsHostileToActor()`

### v1.5 - 2026-05-11 - Phase 2 verified in game

Phase 2 is now complete for the Kyne proof slice. `PDV_DeityBase.psc`, `PDV_Deity_Kyne.psc`, and `PDV__ManagerQuest.psc` compile successfully, CK wiring is complete, `PDV_FLST_AllDeities` contains Kyne, and runtime verification succeeded in game.

Confirmed behaviors:
- patron activation updates `PDV_GLO_ActiveDeityIndex`
- active piety and tier mirrors track the active patron correctly
- `ProcessDawn()` clamps daily scratch to `+/-5`
- persistent piety updates correctly after dawn processing
- tier threshold crossing from `0` to `1` occurs at piety `10`

Implementation note: the original stage-fragment harness path was abandoned in this setup because CKPE fragment binding was unreliable. The current validated debug harness is poll-based inside `PDV__ManagerQuest` and driven by `SetPQV` plus a brief wait with the console closed.

### v1.4 - 2026-05-11 - Phase 1 complete; Phase 2 scripts delivered

Phase 1 confirmed complete: mirror globals (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) declared in CK and verified in-game via `GetGlobalValue`. `PDV__ManagerQuest` fully refactored - buckets removed, `AwardPiety`/`GetPiety`/`RecomputeTier`/`RefreshPatronMirrors` API live.

Phase 2 scripts delivered: `PDV_DeityBase.psc` (base class contract), `PDV_Deity_Kyne.psc` (first concrete deity, Kyne rubric implemented), `PDV__ManagerQuest.psc` updated with `PDV_FLST_AllDeities` FormList property and `ProcessDawn` loop scaffold. CK wiring (compile, quest form creation, FormList wiring) is the remaining Phase 2 work. Historical walkthrough in `archive/completed-phase-docs-2026-05-16/PDV_Phase2_CK_Steps.md`.

Data model fix: corrected `PDV.Piety` range from `0-100` (stale from v1.0 draft) to `0-200`. Scripts, `AGENTS.md`, and this document now agree. The old `0-100` range in Section 4 was a leftover from the pre-Phase-1 draft and was never reflected in the implemented scripts.

### v1.3 - 2026-05-10 - Phase 0 cleanup complete

`PDV_MasterQuest` Quest record and `PDV_DevotionLevel` Global removed from `PlayerDevotion_Framework.esp` via xEdit. Orphan files `PDV_MasterQuest.psc` and `Scripts/PDV_MasterQuest.pex` deleted from disk. ESP binary audit clean. v1 dawn-tick logic is now offline; the workspace is at a blank script slate, ready for Phase 1.

Notes for next session: `PDV__MainQuest.psc:12` still carries the historical "Renamed from PDV_MasterQuest" comment - kept as audit trail. The `Scripts/` folder is empty and will repopulate as Phase 1 scripts compile. The ESP currently has no PDV-namespaced records at all; Phase 1 will start populating it with the new MainQuest, ManagerQuest, and the mirror globals.

### v1.2 - 2026-05-09 - Race-conditional religion added

Added Section 12 (Race-conditional religion) and refactored Sections 4, 7, 9, and 10 to reflect race-keyed origins, stance taxonomy, and the rivalry ledger.

Decision: replace the 5-bucket `OriginGroup` taxonomy (Nordic / Imperial / Mer / Beast / Other) with a 10-bucket race-keyed `OriginRace` global. Add a four-stance taxonomy (`NATIVE / FOREIGN / TABOO / HOSTILE`) per `(deity, race)` pair, replacing the earlier per-origin float multipliers. Add a rivalry ledger so worship of culturally hostile deities erodes piety on the player's "natural" deities - modeling cross-pantheon hostility (Altmer/Talos, Orsimer/Boethiah, Redguard/Sep) that the multiplier model couldn't express.

Rationale: logic-checking the multi-deity worship behavior against TES religious lore showed that race-conditional religion isn't a multiplier problem - it's a topology problem. "Mer" lumped Altmer + Bosmer + Dunmer into one bucket despite the three having radically different religious cultures. "Beast" lumped Khajiit (broadly polytheistic) with Argonians (Hist-only). The multiplier model couldn't express active hostility (Altmer worshipping Talos should *cost* piety with Auri-El, not merely accrue Talos slowly). Stance + rivalry adds the expressive power needed without changing the bones of v2.

Cost: one additional global, one int-array of length 10 per Deity quest, one rival list (Form[]/Float[] parallel arrays) per Deity quest, ~50 lines of Papyrus on `PDV_DeityBase`, plus the design work of populating the Section 12.4 default stance matrix across all deities. Build cost grows linearly with deity count and is independent per deity. Slotted into Phase 4.

Open lore items flagged in Section 10 contested-lore subsection - Trinimac canon status, Talos-Altmer framing, Hircine-Bosmer classification, Malacath-as-Daedra-or-Aedra, and Lorkhan/Shor/Sep/Lorkhaj equivalence vs. separation. These need resolution before the Section 12.4 matrix is locked into CK data, but the *architecture* doesn't depend on which way each is decided.

### v1.1 - 2026-05-09 - Hybrid storage adopted

Changed Sections 1, 4, 6, and 9 to reflect a hybrid storage model rather than StorageUtil-pure.

Decision: StorageUtil is the source of truth for all per-deity values. A small set of GlobalVariables (`PDV_GLO_ActivePiety`, `ActiveTier`, `ActiveDeityIndex`) mirrors the active patron's current values for the sole purpose of being readable by vanilla CK Conditions. Mirrors are refreshed by `ManagerQuest.RefreshPatronMirrors()` on patron change and on any piety/tier mutation to the active patron.

Rationale: pure-StorageUtil is structurally cleaner but forces a Papyrus wrapper at every condition-driven content boundary (dialog gates, perk reqs, magic effect filters, shrine usability checks). At the deity-count and tier-gating density this mod targets, that glue cost adds up faster than the ~30 lines of mirror-refresh logic. Hybrid keeps StorageUtil's iteration/scaling wins while preserving Globals' first-class condition support.

Cost: ~30 lines of refresh glue on the manager. Three additional global records in the ESP. Discipline required: never read mirrors as truth; always write through `AwardPiety` / `RecomputeTier`, not directly to the mirror globals.

### v1.0 - 2026-05-09 - Initial draft

Created from the v1 codebase review. Established Deity-as-Quest abstraction, ActionRouter pattern, StorageUtil per-deity store, six-phase migration plan.

### v2.3 - 2026-05-15 - Phase 4 CK pass status and CK stability note

This revision records the live CK status after the first substantial Phase 4 ESP wiring pass. The framework side of the proof slice is now mostly present in `PlayerDevotion_Framework.esp`: `PDV_GLO_OriginRace`, `PDV_GLO_PatronDeity`, `PDV__MainQuest`, `PDV_Origin`, Kyne's stance row, and Kyne's three boon assignments are all verifier-visible in the live plugin. The remaining true Phase 4 hard fail is the missing `PDV_GLO_PatronDeity` property assignment on `PDV__ManagerQuest`.

The other current verifier failures are not additional Phase 4 design misses; they are Phase 6 spillover because the script/tooling surface already treats `PDV_Deity_Talos`, `PDV_Deity_AuriEl`, and the related `PDV_Origin` properties as expected follow-on records. Current warnings are an older-than-ESP `PlayerDevotion_Framework.seq` and one unnamed `MGEF` record in the ESP that appears to be orphan residue rather than an intended boon record.

Implementation note: Creation Kit stability, not architecture ambiguity, is now the main blocker. CK repeatedly hung while opening `PDV__ManagerQuest`. Separately, repeated fatal errors revealed a broken SkyUI source-store chain, so a dedicated shim mod was introduced for the `Devotion Dev` profile to expose `SKI_QuestBase.psc`, `SKI_ConfigBase.psc`, and `SKI_ConfigManager.psc` under `Source\Scripts\` for CK lookup. This repair is part of the documented dev environment, not a change to PDV runtime architecture.

### v2.4 - 2026-05-16 - Overlay merge-back and Phase 5/6 framework wiring

The temporary `PDV_ManagerPatronWirePatch.esp` and `PDV_MCMWirePatch.esp` rescue overlays have been merged back into `PlayerDevotion_Framework.esp` through xEdit and unticked in the `Devotion Dev` profile. The framework record for `PDV__ManagerQuest` now has exactly one real `PDV__ManagerQuest` VMAD script entry with the required globals/FormList, including `PDV_GLO_PatronDeity`; the blank local-script residue is gone. The framework record for `PDV_MCM` now has the `PDV_MCM` script and required manager/FormList/global properties directly assigned.

The same integration pass brought the Talos/Auri-El proof slice into the framework far enough for verifier `FAIL=0, WARN=0, TODO=0`: quest records exist, `PDV_FLST_AllDeities` contains Kyne/Talos/Auri-El, `PDV_Origin` references Talos and Auri-El, stance rows are assigned, rivalry wiring is visible, and boon spells are wired. Remaining work is CK smoke-open and in-game proof rather than verifier cleanup.

### v2.5 - 2026-05-16 - Origin race normalization and verifier-clean wrap-up

`PDV_Origin` now normalizes vanilla `*RaceVampire` records to the player's permanent cultural origin and defers initialization when only a temporary beast-form race is visible. The discarded exploratory `PDV_OriginRaceNormalizationPatch.esp` was removed from the Devotion mod and no longer appears in the Anvil MO2 MCP plugin view. Final wrap-up verifier run: `FAIL=0, WARN=0, TODO=0`.

### v2.6 - 2026-05-16 - Phase 5 in-game proof and ReShade environment split

The first MCM slice is now proven in game on the live three-deity roster. `PlayerDevotion` registers in SkyUI, the `Status` page iterates Kyne/Talos/Auri-El correctly after the cursor-fill layout fix, and the `Debug` page can swap the active patron to Auri-El through the manager helper path.

That smoke test also split PDV logic from an external native crash source. Repeated CTDs while opening MCM were traced to stacks dominated by `ReShade64.dll`, `WS2_32.dll`, and `webio.dll`, while Papyrus showed no matching PDV MCM fault. For now, treat ReShade as a separate environment investigation and keep it out of the architecture success criteria for Phase 5.

### v2.7 - 2026-05-16 - Phase 4 and Phase 6 closeout proof

Phase 4 and the coupled Talos/Auri-El Phase 6 slice are now proven in game end to end. The closeout passes covered clean-start origin bootstrap, seeded ledger expectations, patron-only boon grant/removal, rivalry-driven hostile-path transfer across dawn consolidation, and save/load sanity on the proven final state.

The same test pass exposed one real workflow gap: curated hostile-path signals were not reachable through the previously proven MCM/console debug surface. Rather than rely on an unproven `cqf` path, the manager and MCM were extended with a surfaced curated-signal debug helper so future hostile-path smoke tests can use the same sanctioned tooling path as the rest of PDV.

