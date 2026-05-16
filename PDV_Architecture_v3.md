# PDV Architecture v3 - Forward Plan

Last revised: 2026-05-16 (v3.3 - V3 kickoff decisions)
Status: **Planning.** v2 (Phases 0-6) is closed. v3 is the architecture target for everything past the coupled Talos/Auri-El hostile-path proof slice.

---

## 1. Scope and relationship to v2

`PDV_Architecture_v2.md` documented the migration from the original v1 codebase (one global, three buckets) to the current per-deity StorageUtil model. By the close of v2 the following are real and verifier-clean:

- Per-deity piety in StorageUtil, three mirror globals for the active patron.
- Deity-as-Quest pattern with `PDV_DeityBase` and concrete `PDV_Deity_<X>` quests.
- `PDV_ActionRouter` + `PDV__SM_KillActor` Story Manager kill-event capture.
- Dawn consolidation via `PDV__ManagerQuest.ProcessDawn()`, clamped to plus/minus 5 per day.
- Origin race detection (with vampire-race normalization and beast-form deferral).
- Stance taxonomy (`NATIVE / FOREIGN / TABOO / HOSTILE`) on `PDV_DeityBase`, with stance-aware multipliers in `AwardPiety`.
- Rivalry ledger fired from the stance-adjusted gain (not raw delta).
- Patron-only, cumulative-by-tier boon assignment.
- `PDV_MCM` dev surface (Status + Debug only), framework-attached.
- Curated-signal helpers (`AwardCuratedSignal*`) for CK-driven devotional events.
- Local toolchain: `pdv_compile.mjs`, `pdv_verify.mjs`, `pdv_author.mjs`.

v3 plans everything past that point: signal expansion, the per-race overlay subsystems the locked race architecture requires, Daedric path architecture, curse-state handling, neglect, decay, the player-facing UX surface, the content authoring pipeline, mod compatibility, and the path to a 1.0 release.

v3 is **forward-only**. It does not restate v2 internals. Where v3 references a v2 mechanism (the manager API, the dawn loop, stance multipliers, etc.) it links back rather than duplicating the contract.

---

## 2. Invariants carried forward from v2

These are non-negotiable. Every v3 subsystem must respect them.

1. **StorageUtil is the source of truth.** Per-deity values live under deity FormID with the `PDV.` key prefix. Mirror globals are write-only caches, refreshed only by `AwardPiety` / `RecomputeTier` / patron-switch handlers.
2. **The dawn loop owns consolidation.** Runtime events write to `PDV.PietyToday` (scratch) only. Persistent piety, tier recompute, `OnTierChange`, and mirror refresh fire from `ProcessDawn()`. No runtime event path may write `PDV.Piety`, `PDV.Tier`, or mirror globals directly.
3. **Story Manager nodes share events.** Every PDV-added Story Manager node has `Shares Event` checked. PDV does not consume events vanilla or other mods need.
4. **Deity quests are persistent and uniform.** All `PDV_Deity_<X>` extend `PDV_DeityBase`, are Start-Game-Enabled, and are member of `PDV_FLST_AllDeities`. Adding a deity is a script + properties + FormList membership change, not a quest-infrastructure rewrite.
5. **One backend per StorageUtil key.** If JContainers is ever introduced, no PDV key uses two backends. Writers and readers must match.
6. **Player-facing strings are ASCII.** No curly quotes, em dashes, ellipses, bullets, or multibyte punctuation in MCM, dialogue, notifications, books, or message boxes.
7. **The framework ESP keeps `Skyrim.esm` as the first master.** Overlay patches authored via `pdv_author.mjs` must preserve this. Manually inserting `Skyrim.esm` into an existing patch without remapping FormIDs is destructive.
8. **PapyrusUtil is a hard runtime dependency.** Missing PapyrusUtil should hard-fail with a player-visible message, not silently fall back.
9. **Race architecture preservation.** The locked race architectures in `references/PDV_RaceArchitecture_DesignReference.md` are authoritative. v3 subsystems must not flatten races into a uniform patron model.
10. **The hybrid boon policy is asymmetric.** Not every race gets a persistent substrate; structurally layered religions (Dunmer, Khajiit, Argonian) do, others lean on privileges and contextual favors. Most races should never feel like they have more than two meaningful always-on boon families at once.

---

## 3. Outstanding from Phases 4-6

These items were live or deferred when v2 was closed. v3 inherits them.

### 3.1 Resolved by policy, needs naming consistency

- **Boon revocation on patron-change.** Resolved for the proof slice: live boon spells are stripped on swap, persistent piety/tier are retained. v3 must apply the same rule to contextual favors and (where present) substrate layers - patron-foreground revokes on swap, substrate persists with origin.

### 3.2 Architecturally deferred

- **Decay model.** Not implemented. Linear daily decay if no recent `PietyToday` activity is the leading candidate. v3 owns this - see Section 14.
- **Storage migration.** v1 saves loading into v2/v3 mods: `PDV_GLO_DevotionLevel` is dead, Kyne piety reseeds from origin. Treat as a save-game gotcha rather than a migration path. v3 should document this in the mod page changelog when 1.0 ships.
- **PapyrusUtil missing-failure behavior.** Locked: add a visible hard-fail guard to `PDV__MainQuest.OnInit()` before any partial state writes. Missing PapyrusUtil should show a player-visible message, trace the dependency failure, and abort PDV bootstrap.
- **Custom-race fallback.** Locked: `PDV_Origin` may keep defaulting unknown races to `RACE_IMPERIAL`, but v3 must surface this as both a one-time first-load notice and an MCM/status diagnostic. A later custom-race soft-compat hook remains post-1.0 unless a concrete patch target appears sooner.
- **Curse-state module.** Werewolf and Vampire interpretation layers are designed (see race architecture reference) but not built. v3 owns this - see Section 12.

### 3.3 Contested lore items (must be decided before content lock)

Carried forward from v2 § 10. Each affects stance and rivalry data, not architecture shape:

- **Trinimac as worshipable.** Locked: include as an Altmer-native specialist worship target for martial virtue, civilisational defence, and Thalmor Orthodox play. For Orcs, Trinimac remains `TABOO` fringe pressure only, not a normal Orc core path or fourth Orc lane. Scaffold in Structural Skeleton, but make content-ready only when the Thalmor Orthodox Altmer lane is being built.
- **Talos-Altmer.** Locked: `HOSTILE`. Theological enemy, not just culturally foreign.
- **Hircine for Bosmer.** Locked: `NATIVE`, with the lore disagreement noted in the deity description. Reading is Y'ffre-adjacent Wild Hunt veneration.
- **Malacath classification.** Locked: dual-coded. Malacath is a Daedric Prince for non-Orsimer taxonomy and an Orsimer ancestor/core god as Mauloch/Malacath for Orc handling. Stigma and rivalry logic branch by race rather than forcing one universal label.
- **Lorkhan-family equivalence.** Locked: do not collapse `Shor`, `Sep`, `Lorkhaj`, and `Lorkhan` into one row. Keep culturally specific records where theology and rivalry differ, and note family resemblance in description text.

### 3.4 Environment / tooling (not architecture)

- **ReShade native conflict.** Crash signature was external (`ReShade64.dll` + `WS2_32.dll` + `webio.dll`). Workaround: rename `ReShade64.dll` in the Anvil Stock Game folder before launch. Not a v3 architectural concern.
- **SkyUI source-store fragility.** Mitigated by the dedicated CK header shim mod at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\`. Document only.

---

## 4. v3 subsystem map

The v3 architecture adds the following subsystems on top of the v2 core. Each gets its own section below.

| Section | Subsystem | Builds on |
|---|---|---|
| 5 | Signal expansion | `PDV_ActionRouter`, Story Manager receivers, curated-signal helpers |
| 6 | Reputation track | New `PDV_ReputationTrack` reusable script |
| 7 | State track | New `PDV_StateTrack` lightweight per-race quest helpers |
| 8 | Race substrate layer | New origin-gated quest pattern, parallel to deity quests |
| 9 | Privilege subsystem | CK Conditions on the existing mirror globals + new state-track globals |
| 10 | Contextual favor subsystem | Magic effects with stacked conditional triggers, family-capped |
| 11 | Daedric path architecture | New `PDV_DaedricPath_<X>` quest pattern with boon/price/stigma |
| 12 | Patron commitment mechanism | Threshold offer events written through the manager |
| 13 | Curse-state overlay | New `PDV_CurseState` overlay quest, weight-modifier helper API |
| 14 | Neglect subsystem | Tier downgrade + privilege/favor removal; small thematic effects |
| 15 | Decay model | New `ProcessDawn` step; per-deity floor and grace logic |
| 16 | Player-facing UI | MCM evolution + status spell + notification policy |
| 17 | Content authoring pipeline | Template scripts, `pdv_author.mjs` scope, verifier coverage |
| 18 | ESP module structure | Framework-monolithic through 1.0; race ESP split deferred |
| 19 | Performance budget | Pantheon-scale FormList iteration, dawn cost ceiling |
| 20 | Mod compatibility | Soft-compat targets, signal cross-routing, optional patch ESPs |

---

## 5. Signal expansion (Phase 7)

Currently the only live signal source is hostile kill events. The locked race architecture needs roughly the following signal families: shrine visits, sleep (location-typed), shouts, dialogue/quest resolutions, faction joins, marriage, donations, theft, mercy/persecution choices, and craft/labor events.

### 5.1 Three signal-source patterns

Every v3 signal flows through one of three patterns and writes only through `PDV__ManagerQuest.AwardPiety()` or `AwardCuratedSignal()`:

| Pattern | Use when | Receiver | Cost |
|---|---|---|---|
| Story Manager receiver | The event is in the vanilla SM tree (Kill Actor, Add Item, Increase Skill, Change Location, etc.) | New `PDV__SM_<Event>` non-Start-Game-Enabled quest, calls router | A (cheap) |
| Player alias event | The event needs player-attached hooks (`OnSleepStart`, `OnObjectEquipped`, `OnPlayerLoadGame`) | `PDV_PlayerEvents` alias script (deferred build from v2) | A (cheap) |
| Curated CK signal | The event is a quest-stage outcome, dialogue choice, faction-join, or other CK-author-driven moment | Direct `AwardCuratedSignal()` from a CK fragment or dialogue script fragment | A-B |

`PDV_ActionRouter` continues to fan to all deities. New event types extend the `EVT_*` integer enum on the router. The router itself stays slim; per-deity scoring lives in each `ScoreAction()`.

### 5.2 Event type enum growth

Current enum (v2):

```
EVT_NONE = 0
EVT_KILLED_HOSTILE_BEAST = 1
EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2
```

Reserved ranges for v3 (final integers locked when each phase ships):

```
1-9     Combat events           (kills, combat resolution)
10-19   Travel/location         (sleep outdoor, location-type entry, hold travel)
20-29   Social                  (marriage, charity, theft, mercy, persecution)
30-39   Devotional surfaces     (shrine use, ritual, prayer, donation)
40-49   Magic/voice             (shouts, school-of-magic use)
50-59   Craft/labor             (smithing, alchemy, enchanting where lore-relevant)
60-69   Faction/quest           (faction join, allegiance, quest-stage outcomes)
70-79   Curse                   (lycanthrope/vampire state transitions)
80-89   Daedric                 (Prince-quest milestones, oath/break events)
```

Adding an event type is: append to the constants block on `PDV_ActionRouter`, add a Story Manager receiver or alias handler if the source needs one, update each deity's `ScoreAction()` rubric that cares, and append to the verifier's expected-record set.

### 5.3 Anti-farm enforcement

Every repeatable signal must carry an anti-farm rule (per the race-architecture pre-matrix requirements). v3 enforces this at three layers:

- **Per-event daily cap** in `ScoreAction()`. Read `StorageUtil.GetIntValue(deity, "PDV.Daily.<EventType>")`, gate further awards, reset at dawn.
- **Diminishing returns** for cheap repeatable signals (shrine use, sleep). Each fire scales the next by 0.7x within the day.
- **Cooldown windows** via `StorageUtil.SetFloatValue(deity, "PDV.LastFire.<EventType>", Utility.GetCurrentGameTime())` for context-sensitive signals (mercy/persecution, theft) where bursting would be exploitative.

Caps and cooldowns are deity-side, not router-side, so different deities can rate-limit the same event family differently.

### 5.4 Outstanding signal-architecture decisions

- **Follower kill attribution.** Locked for Preflight: EventBus payloads should carry attribution type for direct player, follower, summon/charmed, trap, and environmental kills, but only direct-player kills score until a later signal phase gives indirect kills explicit devotional meaning.
- **Trap and environmental kills.** Same payload family as follower/summon attribution. Do not score them in Preflight; test real Story Manager behavior before any reduced-attribution scoring lands.
- **Crime events.** Story Manager has crime nodes (`OnStoryCrimeGold`, `OnStoryArrest`). These are first-class signals for Imperial Concordat Standing and Argonian community standing, but should land with Phase 8's reputation track so the events immediately adjust a real track instead of routing as empty signal scaffolding.

---

## 6. Reputation track subsystem (Phase 8)

Two locked race-architecture pieces - Imperial `ConcordatStanding` and Breton `WitchcraftExposure` - share an identical shape: a -100..+100 (or 0..100) integer with named thresholds that lock-in until sustained behavior reverses them. v3 abstracts this into one reusable component.

### 6.1 Pattern

```papyrus
Scriptname PDV_ReputationTrack extends Quest

; -- Identity (set in CK per instance) --
String   Property TrackName Auto                 ; "ConcordatStanding"
GlobalVariable Property StorageBacking Auto      ; e.g. PDV_GLO_ConcordatStanding
Int      Property MinValue = -100 AutoReadOnly
Int      Property MaxValue = 100 AutoReadOnly

; -- Threshold table (parallel arrays, set in CK) --
Int[]    Property ThresholdValues Auto           ; e.g. [-51, -11, 11, 51]
String[] Property ThresholdLabels Auto           ; e.g. ["OpenDefiant", "PrivateDefiant", "Uncommitted", "PublicCompliant", "ConcordatEnforcer"]

; -- Lock-in (per § 10.2 of race ref) --
Bool     Property LockInOnCross = True Auto      ; threshold must be crossed by sustained behavior
Int      Property LockInGraceDays = 3 Auto       ; days at the destination before the new state sticks
```

### 6.2 API surface

```papyrus
Int   Function GetValue()                            ; current backing value
Int   Function GetStateIndex()                       ; resolved threshold band
String Function GetStateLabel()                      ; resolved state name
Bool  Function CanAdvance(Int adjustment)            ; respects lock-in grace
Function Adjust(Int adjustment, String reason)       ; writes through, traces
Function ForceSet(Int newValue, String reason)       ; admin/debug only
```

Both `ConcordatStanding` and `WitchcraftExposure` instantiate this quest with different threshold tables and labels. The track stores its current value in a dedicated `PDV_GLO_<TrackName>` global so vanilla CK Conditions can read it natively. Lock-in state is in StorageUtil under `PDV.Track.<TrackName>.LastCross` and `PDV.Track.<TrackName>.LockInUntil`.

### 6.3 Where adjustments come from

- **Curated signals from CK dialogue/quest fragments.** Most reputation track adjustments are quest-resolution moments; the points-per-action tables in the race architecture reference (e.g. "Find and activate hidden Talos shrine: -15") become dialogue/quest-script `Adjust(-15, "shrine_activate")` calls.
- **Story Manager receivers** for non-curated events like "kill Thalmor Justiciar unprovoked" (a `PDV__SM_KillActor` victim-faction check).
- **Player alias events** for sleep, marriage, faction-join hooks.

Reputation tracks **do not** modify piety directly. They modify *stance multipliers* indirectly via Section 6.4.

### 6.4 Track-modified stance multipliers

The race architecture's Concordat table shifts Talos-devotion gain by state (×1.5 for Open Defiant, ×0.5 for Concordat Enforcer). This composes with the v2 stance multiplier.

v3 extends `PDV_DeityBase` with an optional track-multiplier hook:

```papyrus
; PDV_DeityBase additions
PDV_ReputationTrack Property GainModifyingTrack Auto    ; nullable
Float[] Property GainMultiplierPerTrackState Auto       ; parallel to track's threshold bands

Float Function GetEffectiveGainMultiplier()
    Float stanceMult = GetGainMultiplier(GetStanceForPlayer())
    Float trackMult = 1.0
    if GainModifyingTrack
        trackMult = GainMultiplierPerTrackState[GainModifyingTrack.GetStateIndex()]
    endif
    return stanceMult * trackMult
EndFunction
```

`PDV__ManagerQuest.AwardPiety` reads `deity.GetEffectiveGainMultiplier()` instead of the bare stance multiplier. Deities without a `GainModifyingTrack` see no behavioral change.

### 6.5 Naming

- `PDV_RepTrack_<Name>` for the quest record. `PDV_RepTrack_Concordat`, `PDV_RepTrack_WitchcraftExposure`.
- `PDV_GLO_<TrackName>` for the backing global. `PDV_GLO_ConcordatStanding`, `PDV_GLO_WitchcraftExposure`.
- `PDV_GLO__<TrackName>_LockInUntil` for the internal lock-in cache global (write-only mirror; canonical state in StorageUtil).

---

## 7. State track subsystem (Phase 9)

Reputation tracks are continuous integers with thresholds. State tracks are categorical enums: "which Bosmer path is active," "which Orc life-mode," "Imperial Concordat resolved state" (a coarser readout of the rep track), "broad vs primary worship state."

State tracks differ from reputation tracks in that they:

- Have no continuous backing value, just a current category integer.
- Often persist for the life of the character (Bosmer path), or until a major life event (Orc Stronghold → City → Exile).
- Are usually set by a one-time threshold event, not by accumulating points.

### 7.1 Pattern

```papyrus
Scriptname PDV_StateTrack extends Quest

String   Property TrackName Auto                 ; "BosmerPath"
GlobalVariable Property StateGlobal Auto         ; PDV_GLO_BosmerPath
Int      Property UnsetSentinel = -1 AutoReadOnly
String[] Property StateLabels Auto               ; ["OldContract", "LivingStory", "Exchange", "BanditRoad"]
Bool     Property AllowsTransition = True Auto   ; some tracks lock once set
```

API mirrors the reputation track: `GetState()`, `GetStateLabel()`, `SetState(Int, String reason)`, `ResetForDebug()`.

### 7.2 Where state tracks come from

- **Setup quests** at character start (Bosmer four-path choice via MCM or first-run dialogue).
- **Threshold events** during play (Orc Stronghold-to-City transition triggered by sustained outside-stronghold residency, or a story event).
- **Quest resolutions** (Imperial Concordat "Open Defiant" reached via sustained track threshold).

### 7.3 How state tracks feed scoring

State tracks unlock or restrict eligible deities (Bosmer `OldContract` makes `Y'ffre` strongly NATIVE-foreground; `BanditRoad` makes `Baan Dar` the foreground deity; the other three Bosmer paths each foreground a different deity).

v3 adds an optional `EligibleStateTrack` + `EligibleStateValues` filter on `PDV_DeityBase`:

```papyrus
; PDV_DeityBase additions
PDV_StateTrack Property EligibleStateTrack Auto       ; nullable
Int[] Property EligibleStateValues Auto               ; deity is selectable as foreground only in these states

Bool Function IsEligibleForPlayer()
    if EligibleStateTrack == None
        return True   ; no gating
    endif
    Int currentState = EligibleStateTrack.GetState()
    Int i = 0
    while i < EligibleStateValues.Length
        if EligibleStateValues[i] == currentState
            return True
        endif
        i += 1
    endwhile
    return False
EndFunction
```

The patron-commitment mechanism (Section 12) reads `IsEligibleForPlayer()` before offering a deity as foreground. Ineligible deities can still accumulate piety in the background but cannot become foreground patron.

### 7.4 State tracks needed for first release

| Track | States | Owner race | Notes |
|---|---|---|---|
| `PDV_State_BosmerPath` | OldContract, LivingStory, Exchange, BanditRoad | Bosmer | Set at character setup or first-run quest |
| `PDV_State_OrcLifeMode` | Stronghold, City, Exile | Orc | Default Stronghold; transition via threshold events |
| `PDV_State_ImperialWorship` | Broad, Primary | Imperial | Promoted by Concordat-rep + piety-threshold |
| `PDV_State_NordWorship` | OldWays, NineDivines, Broad, Primary | Nord | Setup choice + commitment event |
| `PDV_State_BretonTradition` | Divine, Druidic, Witchcraft, Mixed | Breton | Soft preferences set during play |
| `PDV_State_RedguardSect` | Crown, Forebear, AshAbah | Redguard | Faction-driven |
| `PDV_State_DunmerPath` | Ancestor, GoodDaedra, TribunalRemnant | Dunmer | Default Ancestor; promoted by sustained worship |

### 7.5 Naming

- `PDV_State_<RaceOrDomain><Track>` for the quest record.
- `PDV_GLO_State_<TrackName>` for the backing global.

---

## 8. Race substrate layer (Phase 10)

The locked hybrid boon policy gives a *persistent substrate* only to races whose theology is structurally layered. v3 implements this as a parallel-to-deity quest pattern.

### 8.1 The substrate quest pattern

A substrate quest is structurally similar to a deity quest but:

- It is **origin-gated**, not patron-gated. It runs (and its boons are live) whenever `PDV_GLO_OriginRace` matches.
- It does **not** appear in `PDV_FLST_AllDeities` and does not participate in the rivalry ledger.
- It is **always active** for matching origin; there is no "Set Substrate Active" the way patrons work.
- It can have its own tier table driven by an aggregate substrate metric, not per-deity piety.

```papyrus
Scriptname PDV_SubstrateBase extends Quest

String   Property SubstrateName Auto             ; "KhajiitLunar"
Int      Property RequiredOriginRace Auto        ; RACE_KHAJIIT
String   Property StorageKeyPrefix Auto          ; "PDV.Substrate.KhajiitLunar"

Spell    Property Substrate_Always Auto          ; the always-on layer
Spell    Property Substrate_Mid Auto             ; activates at a metric threshold
Spell    Property Substrate_High Auto            ; activates at a higher threshold

Float    Property MidThreshold = 25.0 Auto
Float    Property HighThreshold = 75.0 Auto

Function OnInit()
    RegisterForSubstrateEvents()
EndFunction

Function RegisterForSubstrateEvents()
    ; Override per concrete substrate
EndFunction

Function RecomputeSubstrateTier()
    ; Read aggregate metric from StorageUtil
    ; Add/remove tier spells accordingly
EndFunction
```

### 8.2 Substrates needed for first release

| Substrate | Origin | What it tracks | Aggregate metric |
|---|---|---|---|
| `PDV_Substrate_KhajiitLunar` | Khajiit | Lunar phase observance + furstock identity | Moon-observance count, modulated by furstock |
| `PDV_Substrate_DunmerAncestor` | Dunmer | Ash-shrine maintenance, ancestor invocation | Ancestor-event count, decays with neglect |
| `PDV_Substrate_ArgonianHist` | Argonian | Distance-from-Black-Marsh + community contact | Hist-connection metric, biased to "diminishing distance from Hist" semantics |

For 1.0, strong persistent substrates are limited to Khajiit, Dunmer, and Argonian. Altmer orthodoxy, Redguard ancestor reverence, and Orc life-mode standing express identity through privileges, contextual favors, and state tracks first; promote one to a full substrate quest only if playtest feedback proves the lighter pattern insufficient.

### 8.3 Storage

Substrates use their own StorageUtil key prefix to avoid colliding with deity keys:

```
PDV.Substrate.<Name>.Metric     ; aggregate metric (0-100)
PDV.Substrate.<Name>.LastEvent  ; game time of last substrate event
PDV.Substrate.<Name>.Tier       ; current substrate tier 0-3
```

No mirror globals for substrate. CK Conditions that need substrate state read from the dedicated substrate globals when needed.

### 8.4 Interaction with patron boons

Substrate boons and patron boons coexist. Family caps (Section 10.3) prevent stacking abuse. For balance, treat substrate boons as the "always quiet" layer and patron boons as the "louder" foreground layer.

---

## 9. Privilege subsystem (Phase 11)

Privileges are mostly *access* effects: dialogue gates, shrine options, faction reactions, recognition. They don't need new magic effects; they need consistent CK Conditions on existing records and a stable naming convention so they're discoverable.

### 9.1 Privilege families

Each family is a label, not a separate subsystem. They share infrastructure (mirror globals + state-track globals + StorageUtil keys read via Papyrus-condition `GetVMQuestVariable`).

| Family | Surface | CK gate |
|---|---|---|
| Shrine privilege | Activator scripts on shrines | `PDV_GLO_ActiveTier >= 2` + `PDV_GLO_ActiveDeityIndex == N` |
| Restoration privilege | Dialogue topics with priests, ritual quests | Multi-condition: tier + state-track + piety |
| Dialogue privilege | NPC dialogue topics across the world | Tier + origin race + optional state-track |
| Recognition privilege | NPC faction stance / "Hello" topic preference | Tier + state-track + faction membership |
| Threshold privilege | One-time unlocks (e.g. Greybeards recognition for high Kynareth Nord) | Piety high-water mark in StorageUtil |

### 9.2 Naming

- `PDV_Privilege_<Domain>_<Description>` for dialogue topics and unique records.
- `PDV_Cond_<Reason>` as a comment label on CK Condition stacks for searchability (not a record EditorID; CK Conditions don't have names, this is a convention for human-readable design docs).

### 9.3 The "one mirror global, many privileges" pattern

The three v2 mirror globals (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) plus the new state-track globals are read by potentially hundreds of CK Condition stacks. v3 does not add new mirror globals for every privilege class - that's the trap v1 fell into. Instead, privileges compose from the existing globals plus condition stacks.

Where a privilege genuinely needs a value not surfaced by the mirrors (e.g. "highest piety this character has ever reached on Kynareth"), use a dedicated additional global behind the same write-only-cache discipline. Add the global only when the condition is needed by content; don't speculatively pre-mirror.

### 9.4 Privilege pilot and shrine discipline

- **Greybeards-Kynareth recognition.** A Nord with high Kynareth tier could get a unique greeting from Arngeir. This requires editing a vanilla dialogue topic with a `Shares Dialogue` discipline. v3 should pilot this with the Kyne content as a "does the privilege pattern hold up?" test.
- **Shrine activator overlays.** PDV does not replace vanilla shrine activator scripts for 1.0. Shrine extensions use overlay receiver quests, aliases, or new nearby activator references so shrine-modifying mods remain easier to coexist with.

---

## 10. Contextual favor subsystem (Phase 12)

Contextual favors are passive conditional magic effects (e.g. "Frost resistance +25% while outdoors in Eastmarch and Kyne is your patron at Devoted or higher"). They are the main carrier of race-specific identity per the locked hybrid boon policy.

### 10.1 Pattern

Each favor is a single Magic Effect on a permanent ability spell that all foreground patrons grant when active. The ability holds N magic effects; each effect's CK Conditions gate when it fires.

```
PDV_Favor_<Patron>_<Description>          Magic Effect
PDV_Ability_<Patron>_ContextualFavors     Spell (granted as patron foreground ability)
```

The ability is patron-only and tier-gated (most contextual favors unlock at Tier 2 Devoted; some at Tier 3 Champion).

### 10.2 Favor count target

The race-architecture pre-matrix requirements call for 3-5 contextual favors per path. v3 enforces this as a soft cap; the verifier should warn if a patron's contextual-favor list exceeds 5.

### 10.3 Family caps (anti-stack)

Multiple favors from the same effect family (e.g. "frost resistance," "shout cooldown reduction") should not stack into burst power. v3 enforces this via:

- **Keyword tagging.** Each `PDV_Favor_*` magic effect carries one or more `PDV_FavorFamily_<Name>` keywords (e.g. `PDV_FavorFamily_FrostResist`, `PDV_FavorFamily_ShoutCooldown`).
- **Cap enforcement.** Cross-deity favors within the same family use the same numerical value rather than additively stacking. Implementation: prefer "Set Value" / "Max Of" archetypes over "Mod Value" archetypes where Skyrim's magic effect resolution allows.

This is design discipline more than a script feature. The verifier should detect "multiple PDV_FavorFamily_X effects with Mod Value archetype" as a balance warning.

### 10.4 Authoring overhead

Each favor is: one magic effect, one entry in the patron's ContextualFavors ability spell, a family keyword, and a CK Condition stack. A typical patron has 3-5 favors. Across 25-35 deities that's roughly 100-150 favor effects in v1.0 - manageable in CK without templating, but a candidate for `pdv_author.mjs` expansion later.

---

## 11. Daedric path architecture (Phase 13)

Daedric paths run on the same tier spine as Aedric devotion but use a different contract grammar - per the race architecture Daedric matrix, every Daedric path has a `boon / price / stigma` triple and is mostly event-driven rather than ambient-accumulating.

### 11.1 Pattern

`PDV_DaedricPath_<Prince>` quests are siblings of `PDV_Deity_<X>` quests but with extended properties:

```papyrus
Scriptname PDV_DaedricPathBase extends PDV_DeityBase

; -- Contract layer --
Spell    Property Price_Seeker Auto              ; the cost of accepting the boon at this tier
Spell    Property Price_Devoted Auto
Spell    Property Price_Champion Auto

; -- Stigma layer --
Float    Property StigmaPerEvent = 1.0 Auto      ; passive social stigma accrued per devotional act
GlobalVariable Property StigmaGlobal Auto        ; cumulative stigma readout

; -- Commitment gate --
Int      Property CommitmentSignalsRequired = 3 Auto    ; how many distinct Prince-aligned events before path is open
```

### 11.2 Boon/price/stigma resolution

- **Boon.** Same as Aedric: `Boon_Seeker`, `Boon_Devoted`, `Boon_Champion` spells granted by tier.
- **Price.** A parallel spell that applies a thematic drawback when the boon is active. Examples: Hircine boon (Wild Hunt favor) + price (NPC hostility from civilized factions); Boethiah boon (deception strength) + price (oath-bond difficulty with companions).
- **Stigma.** A cumulative social-readability metric. Each Daedric devotional act adds stigma; high stigma manifests as NPC reactions, dialogue gates, faction wariness. Stigma decays slowly with abstention.

### 11.3 Commitment gating

Unlike Aedric deities, Daedric paths require *commitment signals* before they begin awarding piety. A new Khajiit cannot accidentally accrue Boethiah piety by killing a bandit - that signal does not count for Boethiah until the player has performed N (default 3) distinct Boethiah-coded acts (an oath-break, an assassination on Boethiah's "Bait", a deception quest resolution, etc.).

Implementation: each Daedric path tracks `PDV.Daedric.<Prince>.CommitmentSignals` in StorageUtil. Until that counter exceeds `CommitmentSignalsRequired`, `ScoreAction()` returns 0 and the path's contract is not engaged. Once committed, `ScoreAction()` resolves normally.

### 11.4 Per-race response

The Daedric matrix encodes per-race response as `<State>; <Stigma/Friction>; <Exit>` cells. v3 stores these on `PDV_DaedricPathBase`:

```papyrus
Int[]    Property StateByRace Auto       ; Native / Legible / Tolerated / Taboo / Hostile / Curse (length 10)
Float[]  Property StigmaModByRace Auto   ; multiplier on StigmaPerEvent per race
Int[]    Property ExitDifficultyByRace Auto  ; 0=easy, 3=structurally hard
```

Native-integrated exceptions (Azura/Azurah for Khajiit, Boethra for Dunmer, Mafala for Dunmer, Malacath/Mauloch for Orsimer) override the standard Daedric contract: stigma is zero or near-zero for the integrated race, and these paths behave more like Aedric deities for that race.

### 11.5 Naming

- `PDV_DaedricPath_<Prince>` for the quest. `PDV_DaedricPath_Boethiah`, `PDV_DaedricPath_Hircine`.
- `PDV_DaedricPathBase` for the base class.
- `PDV_FLST_AllDaedricPaths` parallel to `PDV_FLST_AllDeities`. Some deities (Malacath, Azura/Azurah) appear in both lists with race-specific routing - decide at content-author time.

### 11.6 Outstanding Daedric decisions

- **Should Daedric paths share `PDV_FLST_AllDeities`?** Mixing them simplifies the action router (one fan-out path) but complicates MCM (Daedric paths display differently). Recommendation: mix in the FormList, branch in MCM display logic.
- **Stigma decay model.** Linear with abstention? Triggered by specific cleansing rites? Defer to content-author phase.
- **Cross-Prince hostility.** Some Princes are canonically hostile (Boethiah vs. Malacath, Meridia vs. all undead-friendly Princes). Should this fire the rivalry ledger? Recommendation: yes, but with smaller multipliers than Aedric-Daedric rivalries (0.3 typical vs. 1.0 for Talos/Auri-El).

---

## 12. Patron commitment mechanism (Phase 14)

The race-architecture reference describes patron commitment in v1 bucket-threshold terms ("sustained CombatBucket >= +7 for 3 consecutive days triggers Shor's offer"). The bucket system was removed in v2. v3 reimplements commitment using per-deity piety thresholds and a per-race candidate filter.

### 12.1 Commitment trigger

Dawn-tick consolidation already runs per-deity. Add a post-consolidation pass:

```papyrus
Function ProcessCommitmentOffers()
    ; Only if no current patron, or current patron is "broad worship" sentinel
    if PDV_GLO_PatronDeity.GetValue() != 0 && !IsBroadWorshipSentinel()
        return
    endif
    ; Find candidates: deities whose persistent piety crossed an offer threshold
    ; AND who are eligible by state-track filter
    ; AND whose offer hasn't been declined-and-cooled-down
    ; Fire the first qualifying offer; queue others
EndFunction
```

### 12.2 Offer threshold

Per-deity property on `PDV_DeityBase`:

```papyrus
Float Property CommitmentOfferThreshold = 20.0 Auto      ; piety required to fire the offer
Int   Property OfferDeclineCooldownDays = 7 Auto         ; min days before re-offering after decline
```

Most deities use the default 20.0. Multi-domain deities (Mara, Talos) can require a higher threshold or a combined check across multiple `PDV.Piety.<*>` reads.

### 12.3 Offer presentation

The offer is an in-world threshold event, not an MCM toggle. Per the locked Nord/Imperial designs:

- **Notification + dialogue topic.** A traveling priest, a dream sequence, a shrine epiphany. Content-author-driven.
- **Player choice: Accept / Not Yet / Refuse.**
  - Accept: 70% of current `PDV.Piety` carries over to the new patron's foreground state, patron is set, foreground boon spells are granted.
  - Not Yet: patron remains unset, offer cools down per `OfferDeclineCooldownDays`, piety stays.
  - Refuse: stronger response. Piety on this deity drops by a fraction; cooldown is longer.

### 12.4 Multi-offer ordering

If multiple deities qualify simultaneously, queue offers in DeityIndex order. Only one offer fires per dawn cycle. Player resolves before the next dawn surfaces another candidate.

### 12.5 "Broad worship" as a first-class state

Per the locked Nord/Imperial/Breton designs, broad worship is a real state, not just "no patron set." v3 introduces:

- `PDV_GLO_PatronState` stores the explicit patron state: unset, broad worship, or active patron. `PDV_GLO_PatronDeity` remains an active-target cache only when the state is active; do not overload it with broad-worship sentinels.
- Broad worship is selected via the same setup choice that sets a state track (Section 7.4).
- Under broad worship, scoring is dampened and capped at Tier 2 for 1.0 unless later race content proves a narrower exception is needed.
- Commitment offers still fire from under broad worship; accepting transitions out of broad.

### 12.6 Commitment offer defaults

- **Broad-worship Tier cap.** Broad worship defaults to Tier 2 for 1.0. Per-race exceptions are content-author decisions only if playtest feedback shows the default breaks a specific culture.
- **Offer choices.** Commitment offers use `Accept / Not Yet / Refuse` for 1.0. A stronger `Renounce` path is deferred past 1.0 unless content later needs a distinct rupture mechanic.

---

## 13. Curse-state overlay (Phase 15)

Werewolf and Vampire transitions shift theological weights per race. The race architecture reference specifies these weights per-race; v3 implements them as a single overlay quest with per-race weight tables.

### 13.1 Pattern

```papyrus
Scriptname PDV_CurseState extends Quest

Int Property CURSE_NONE = 0 AutoReadOnly
Int Property CURSE_WEREWOLF = 1 AutoReadOnly
Int Property CURSE_VAMPIRE = 2 AutoReadOnly

GlobalVariable Property CurseStateGlobal Auto    ; PDV_GLO_CurseState

; -- Detection hooks --
Event OnPlayerLoadGame()
    RecomputeCurseState()
EndEvent

Function RecomputeCurseState()
    Actor player = Game.GetPlayer()
    Int newState = CURSE_NONE
    if player.HasKeyword(WerewolfRaceKW) || player.GetRace() == WerewolfBeastRace
        newState = CURSE_WEREWOLF
    elseif player.HasKeyword(VampireKW) || PlayerIsVampire()
        newState = CURSE_VAMPIRE
    endif
    if newState != CurseStateGlobal.GetValueInt()
        OnCurseStateChange(CurseStateGlobal.GetValueInt(), newState)
        CurseStateGlobal.SetValueInt(newState)
    endif
EndFunction
```

### 13.2 Per-race per-deity weight modifier

`PDV_DeityBase` extends with a curse-modifier table:

```papyrus
; Length 30: 10 races x 3 curse states (None/Werewolf/Vampire)
Float[] Property GainMultByRaceAndCurse Auto

Float Function GetCurseModifier()
    Int race = PDV_GLO_OriginRace.GetValueInt()
    Int curse = PDV_GLO_CurseState.GetValueInt()
    return GainMultByRaceAndCurse[race * 3 + curse]
EndFunction
```

`PDV__ManagerQuest.AwardPiety` composes curse modifier with stance multiplier and (if present) reputation track multiplier.

### 13.3 Curse-state transitions

When the player becomes a werewolf or vampire:

- `OnCurseStateChange(oldState, newState)` fires per deity (iterate `PDV_FLST_AllDeities`).
- Deities can implement transition reactions: e.g. Vampire Imperial collapses Divine devotion entirely per the locked race file; this fires as a one-time `PDV.Piety.<Divine>` reduction with a notification.
- The cure path is structurally the reverse: piety doesn't fully restore on cure, but the multiplier reactivates.

### 13.4 Curse-state restoration path

The race architecture reference flags restoration paths as content-author concerns. v3 architecturally supports them via:

- **Threshold quest stages** in race-specific restoration quests (post-1.0 content).
- **Rededication rituals** that can write `PDV.Piety` directly via curated signals.
- **Tier downgrade on transition** so the player has measurable lost ground to recover.

### 13.5 Curse decisions

- **Source of Werewolf detection.** Companions-quest-specific keyword? Race check? v3 should test on a vanilla Companions run first.
- **Hybrid Necromancer / Daedric overlap.** Curse state modifies multipliers, eligibility pressure, and interpretation. It does not auto-open Daedric paths; Hircine, Molag Bal, or other curse-adjacent paths still require commitment signals before real progression.

---

## 14. Neglect subsystem (Phase 16)

Neglect per the race architecture reference is mostly **loss of access**, not large debuffs. Tier downgrade is the main "you lost it" feedback; secondary thematic effects are small.

### 14.1 What neglect looks like

- **Tier downgrade.** Piety drops below a threshold → tier decreases → boons revoke and contextual-favor ability spell is removed → privileges (which were CK-condition-gated on tier) silently stop working.
- **Optional small thematic effect.** Per the race reference: "The Hist's silence weighs on you, far from Black Marsh. Health regeneration slowed." A single small magic effect, tier-locked, applied only when neglect is "active" (a specific neglected state, not just low piety).

### 14.2 Where neglect lives

Neglect is not a separate quest; it is a property of each deity:

```papyrus
; PDV_DeityBase additions
Spell Property NeglectEffect Auto                ; nullable; small thematic effect
Float Property NeglectActivePietyMax = 10.0 Auto ; below this, neglect effect is granted

Function ApplyNeglectIfWarranted()
    Float piety = StorageUtil.GetFloatValue(self, "PDV.Piety")
    if piety < NeglectActivePietyMax && NeglectEffect != None
        Game.GetPlayer().AddSpell(NeglectEffect, false)
    else
        Game.GetPlayer().RemoveSpell(NeglectEffect)
    endif
EndFunction
```

Called from `ProcessDawn()` per deity, after `RecomputeTier()`.

### 14.3 Per-race neglect

Some races have race-wide neglect effects (Argonian Hist absence) that are not tied to a single deity. These belong on the race substrate quest (Section 8), not on a deity.

### 14.4 Outstanding neglect decisions

- **Stacked neglect effects.** A player ignoring all deities could theoretically get 30+ small neglect effects active. v3 should cap active neglect effects at 3 (the 3 lowest-piety eligible deities) to avoid the "death by a thousand cuts" failure mode.
- **Neglect vs. broad worship.** Under broad worship, no individual deity is "neglected" in the foreground sense. v3 should treat broad-worship sentinel as suppressing per-deity neglect effects across the board.

---

## 15. Decay model (Phase 17)

Decay was deferred in v2. v3 implements per-deity linear decay with a tier-floor.

### 15.1 Mechanism

Daily, at dawn, after `PietyToday` is consolidated:

```papyrus
Function ApplyDecay()
    Float lastEventGameTime = StorageUtil.GetFloatValue(self, "PDV.LastEventGameTime")
    Float now = Utility.GetCurrentGameTime()
    Float graceDays = 3.0
    if (now - lastEventGameTime) < graceDays
        return   ; grace period - no decay
    endif
    Float currentPiety = StorageUtil.GetFloatValue(self, "PDV.Piety")
    Float decayRate = GetDecayRatePerDay()       ; e.g. -0.5
    Float floor = GetDecayFloor()                ; tier-locked floor
    Float newPiety = Math.Max(currentPiety + decayRate, floor)
    StorageUtil.SetFloatValue(self, "PDV.Piety", newPiety)
EndFunction
```

(Note: Papyrus lacks `Math.Max` per project Papyrus guidance. Implementation will use an explicit conditional.)

### 15.2 Decay floors

Per the locked design, Champion tier should not decay below Devoted threshold; that's the "Champion is hard-earned, hard to lose" promise.

```papyrus
Float Function GetDecayFloor()
    Int tier = StorageUtil.GetIntValue(self, "PDV.Tier")
    if tier >= 3
        return ThresholdDevoted    ; Champion floor at Devoted threshold
    elseif tier >= 2
        return ThresholdSeeker     ; Devoted floor at Seeker threshold
    elseif tier >= 1
        return 0.0                 ; Seeker can decay to None
    endif
    return 0.0
EndFunction
```

### 15.3 Decay rate

Default `0.5` piety per day after the grace period. Per-deity tunable. Curse states can multiply decay rate (e.g. Vampire Imperial Divine devotion decays at 5x normal rate per the locked file). Reputation tracks can also modify (Concordat Enforcer state decays Talos faster).

### 15.4 Decay vs broad worship

Under broad worship, decay applies to all deities at a reduced rate (0.2x default). Under primary patron, decay applies to non-patron deities at normal rate.

---

## 16. Player-facing UI (Phase 18)

The Phase 5 dev MCM is explicitly not the player surface. v3 builds the player surface on top of the dev MCM and adds in-world feedback.

### 16.1 MCM evolution

Two-tab structure:

- **Player tab.** Patron name, tier, days at tier, eligible deities for offer, broad-worship toggle, declined-offer cooldowns. Most state read-only; one or two player-facing toggles (e.g. "Show piety values numerically" preference).
- **Dev tab.** Existing Status + Debug pages. Gated behind a player-visible "Developer options" toggle.

### 16.2 In-world feedback

- **Status spell or lesser power.** "Survey Devotion." Cast it, get a `MessageBox` with current patron + tier + days-at-tier + recent piety direction. Per the description-discipline rules, thematic language for normal play; numeric values only in MCM.
- **Notifications.** Three levels per the race-architecture reference:
  - **Quiet** (no notification): routine ambient drift.
  - **Medium** (Notification): tier change, neglect threshold crossed.
  - **Loud** (MessageBox): commitment offer, refuse-and-rupture, curse-state transition, restoration rite completion.

### 16.3 Dialogue privileges as UI

Most race-coded UI lives in NPC reactions (Section 9). v3 should target ~30-50 race-coded dialogue topics for 1.0, focused on patron NPCs (priests, faction leaders, named characters with clear theological alignment).

### 16.4 UI defaults

- **Thematic by default.** Player-facing status uses thematic language first, with numeric values behind a debug/advanced MCM preference for power users.
- **In-world patron switching.** Switching from one patron to another mid-game is a theological act. The player path is an in-world threshold commitment offer from the new patron; MCM patron swap remains dev-only for testing.

---

## 17. Content authoring pipeline (Phase 19)

By 1.0 there will be 25-35 deities, 10 race substrates (some empty), 2 reputation tracks, 6-8 state tracks, ~100-150 contextual favor effects, and many dialogue topics. The pipeline matters.

### 17.1 Add-a-deity workflow

1. Duplicate the most-similar proven concrete deity script (Kyne for Aedric-ambient, Talos for Aedric-hostile, first proven Prince script for Daedric).
2. Edit name, domain, stance row, rivalry list (if any), and `ScoreAction()` rubric.
3. Compile via `node tools\pdv_compile.mjs --script PDV_Deity_<X>`.
4. In CK: create the quest record, Start-Game-Enabled, attach script, fill properties (boon spells, gain modifier track if any, eligibility state track if any).
5. Add to `PDV_FLST_AllDeities` (and `PDV_FLST_AllDaedricPaths` if Daedric).
6. Generate SEQ if the quest is new and Start-Game-Enabled.
7. Update verifier expected-records.
8. In-game smoke test on a clean save.

This is mostly the same pipeline as Phase 6's Talos/Auri-El work. The big lever for reducing per-deity friction is matrix-driven `pdv_author.mjs` overlay-patch generation and one excellent proven pattern per subsystem; v3 expands `pdv_author.mjs` to support:

- Stance row authoring (already partially supported).
- Rivalry array authoring (currently manual CK).
- Contextual-favor ability spell + magic effect record creation (currently fully manual).
- FormList membership (already supported).

### 17.2 Add-a-substrate workflow

1. Create `PDV_Substrate_<Name>.psc` extending `PDV_SubstrateBase`. Implement `RegisterForSubstrateEvents()` and aggregate-metric scoring.
2. Compile.
3. In CK: create substrate quest, Start-Game-Enabled, attach script, set `RequiredOriginRace`, fill substrate boon spells.
4. Origin bootstrap (`PDV_Origin`) does not need updating - substrates self-register via their `OnInit()` and gate on `RequiredOriginRace`.
5. Verifier check: substrate quest exists, has expected properties.

### 17.3 Add-a-track workflow

Reputation track: create `PDV_RepTrack_<Name>` quest, attach `PDV_ReputationTrack` script, fill threshold table. Add `PDV_GLO_<TrackName>` global. Add reputation-track adjustments to relevant dialogue/quest fragments.

State track: same shape with `PDV_StateTrack` script.

### 17.4 Verifier coverage

The verifier needs to scale. v3 expectations:

- Per-deity: record exists, in FormList, script attached, stance row length 10, gain multipliers length 4, boon spells assigned (warn if Tier 3 unassigned, fail if Tier 1/2 missing for non-stub deities).
- Per-substrate: record exists, script attached, origin gate set, boon spells assigned per declared tiers.
- Per-track: record exists, backing global exists, threshold-array / state-array lengths match labels.
- Cross-record: rivalry FormIDs all resolve to records in `PDV_FLST_AllDeities`; eligibility-state-track FormIDs resolve to existing state tracks.

### 17.5 Pipeline defaults

- **Templating vs. duplication.** Do not add an abstract `PDV_Deity_Template.psc` for 1.0. Build one excellent concrete pattern per subsystem, then clone the closest concrete script; revisit only if script-side deity creation routinely takes more than 30 minutes before CK work.
- **MCM display order.** Use `PDV_FLST_AllDeities` order as the default display order, with an optional manual override property for special cases such as "Akatosh first."

---

## 18. ESP module structure (decision)

The v2 design and the `AGENTS.md` ESP Structure section both diagram a future per-race ESP split (`PDV_Nord.esp`, `PDV_Imperial.esp`, etc.). v3 keeps the framework ESP monolithic through 1.0 and revisits a split only if a Section 18.2 trigger hits.

### 18.1 Rationale

- **Cross-race rivalry.** Talos `HOSTILE` for Altmer means `PDV_Deity_Talos.RivalDeities` must reference `PDV_Deity_AuriEl`. Separating these into per-race ESPs forces cross-ESP FormID references, which complicates load-order discipline and overlay-patch authoring.
- **Shared stance matrix.** The 10x30 stance grid lives partly on each deity quest. Per-race ESPs would not own *their* deities cleanly - Mara is in both the Nord and Imperial pantheons, not one or the other.
- **Shared contextual-favor families.** A favor family ("frost resistance") shared across patron deities needs one Keyword record. Cross-ESP keyword sharing works but adds friction.
- **One verifier target.** The verifier currently reads one ESP. Adding multi-ESP awareness is doable but not free.

### 18.2 When to split

Split per-race ESPs only if one or more of the following hits:

- The framework ESP approaches Skyrim's load-order or record-count practical limits (very unlikely at 25-35 deities and supporting records).
- A specific race module has so much dialogue or quest content that it deserves its own load-order slot for compatibility patching.
- A community contributor wants to author a race module independently.

### 18.3 Optional compatibility ESPs

Mod compatibility patches (Requiem, Sacrosanct, etc.) live in their own ESPs (Section 20). That is unrelated to the per-race split question.

---

## 19. Performance budget

At 25-35 deities, the v2 architecture's hot paths scale linearly with deity count. v3 sets explicit budgets so we know when to optimize.

### 19.1 Targets

| Path | Cost shape | Budget |
|---|---|---|
| Kill event route | O(N) FormList iteration, each calling `ScoreAction()` | < 5ms total |
| Dawn consolidation | O(N) per-deity scratch-to-persistent + tier recompute + decay + neglect | < 50ms total |
| MCM Status page render | O(N) per-deity readout | < 100ms render |
| Patron switch | O(N) for old-boon revoke + new-boon grant + mirror refresh | < 30ms |

### 19.2 Mitigations available before any code change

- **Stance early-out.** If a deity's stance for the player's race is `FOREIGN` with no possibility of HOSTILE-driven rivalry, `ScoreAction()` can return 0 early without running the rubric. Many deities will be FOREIGN for any given race - this skips most of the per-deity work.
- **Decay batching.** Apply decay only when `Utility.GetCurrentGameTime() - lastDecayPass > 1.0`, not every dawn-tick check.
- **Lazy contextual-favor recompute.** Don't re-apply contextual-favor abilities on every tier change; only on patron-switch and tier-crossing.

### 19.3 Performance instrumentation

- **Papyrus stack depth.** Iterating 35 deities and calling `ScoreAction()` on each is well within Papyrus limits but should be measured. Add optional `ProcessDawn()` stack-depth benchmarking around Phase 12, after contextual favors create the first realistic per-deity workload.
- **StorageUtil read costs.** Reading `PDV.Piety` for 35 deities at dawn is 35 floats. Trivial. Reading per-event-type daily caps in the same loop adds N x M reads. Still fine, but worth measuring before adding more StorageUtil keys per deity.

---

## 20. Mod compatibility (Phase 20)

Compatibility targets from the project brief: Requiem, Sacrosanct, Growl, Vigilant, Pilgrim, Wintersun. v3 plans compatibility as optional patch ESPs rather than built-in framework awareness.

### 20.1 Compat patch pattern

Each compat patch is a separate ESP with `Skyrim.esm` + `PlayerDevotion_Framework.esp` + the target mod as masters. The patch typically does one or more of:

- **Stance row override.** A Requiem-aware build might shift specific deity stance rows to align with Requiem's harder cultural assumptions.
- **Signal cross-routing.** Sacrosanct's vampire mechanics fire different events than vanilla; a compat patch wires a `PDV__SM_SacrosanctFeed` receiver to translate those into PDV signals.
- **Boon adjustment.** Requiem's stat economy is different from vanilla; a compat patch swaps the framework's small contextual-favor magic effects for Requiem-tuned values.

### 20.2 Per-target compat posture

| Target | Posture | Notes |
|---|---|---|
| Wintersun | Soft compat. Both mods can run; deity overlap is acknowledged via stance text rather than blocked. | Wintersun is the closest existing analogue. Document that PDV and Wintersun model devotion differently and can coexist for users who want both. |
| Requiem | Patch ESP. Stance and contextual-favor adjustments for Requiem-tuned values. | The biggest single-mod compat lift. Defer to post-1.0 unless a strong reason emerges. |
| Sacrosanct | Patch ESP. Vampire-state cross-routing. | Important for the curse-state subsystem (Section 13). |
| Growl | Patch ESP. Werewolf-state cross-routing. | Companion to Sacrosanct on the werewolf side. |
| Vigilant | Light compat. Vigilant's content already pressures Daedric stigma; ensure PDV's Daedric stigma doesn't double-fire. | Mostly a stigma-cadence question. |
| Pilgrim | Soft compat. Pilgrim adds shrine mechanics that PDV's privilege subsystem must respect rather than override. | Shrine-activator override discipline matters here. |

### 20.3 Survival overlap

Per the race-architecture pre-matrix requirements, every signal row has a survival-overlap field. v3 should:

- Treat Survival Mode as the default reference; signals that overlap survival (sleep outdoor, exposure) should be detectable but not duplicated.
- Provide a soft-compat patch for Frostfall and similar mods if it turns out vanilla Survival Mode coverage is too thin.

### 20.4 Compatibility decisions

- **Compat patch authoring tool.** Should `pdv_author.mjs` learn to author compat-patch ESPs? Probably yes, but only after the v3 core subsystems are stable.
- **Wintersun coexistence.** PDV documents Wintersun as parallel-but-divergent coexistence for 1.0. Do not detect Wintersun, suppress features, or build active integration unless a later compatibility phase proves a concrete need.

---

## 21. Forward phase plan

Each phase ends in a runnable mod. Phase ordering is sequenced for value-per-phase and to allow each phase to be tested before the next builds on it.

The roadmap gates in Section 25 now sit in front of this phase sequence. V3
Preflight and the Structural Skeleton pass must complete before Phase 7 signal
expansion begins. Pattern Proving is the first content-bearing wave: build one
excellent reusable example per subsystem, then clone.

| Phase | Subsystem | Dependencies | Acceptance |
|---|---|---|---|
| **V3 Preflight** | Architecture hardening | Proven v2 Phase 4/5/6 baseline | WorshipTarget base, service split, patron state, EventBus/EventTypes, dawn order, gain pipeline, schema hooks, and verifier hard-fails are compile/verifier/smoke clean |
| **V3 Structural Skeleton** | Full 1.0 structural scaffold | V3 Preflight | Dev-only scaffold targets/tracks/substrates are inert, hidden from player surfaces, and verifier-visible |
| **V3 Pattern Proving** | One excellent reusable pattern per subsystem | Structural Skeleton | One EventBus signal family, rep track, state track, substrate, contextual favor family, Daedric price/stigma path, commitment offer, and neglect/decay path are proven |
| **7** | Signal expansion (sleep, shrine, shout, social) | V3 Preflight + EventBus pattern | New events routed; per-target rubric updates; signal policy anti-farm caps functional |
| **8** | Reputation track + first instance (Concordat Standing) | Phase 7 | Track adjusts via dialogue/SM fragments; stance-mult composes with track-mult; verifier covers |
| **9** | State track + first instance (Bosmer Path or Imperial Worship) | Phase 8 | State persists, eligibility filtering works in commitment offers |
| **10** | Race substrate (Khajiit lunar OR Argonian Hist as first pilot) | Phase 9 | Substrate boons granted by origin only; substrate metric tracked; separate from patron piety |
| **11** | Privilege subsystem first wave (shrine + dialogue privileges for Kyne/Mara) | Phase 8/9 | CK conditions read mirror globals + track globals; dialogue topics gate cleanly |
| **12** | Contextual favor subsystem (Kyne foreground favor set) | Phase 11 | 3-5 conditional magic effects per patron; family caps prevent stacking |
| **13** | Daedric path architecture + first Prince (Boethiah pilot) | Phase 11 | Boon/price/stigma triple works; commitment gating works; stigma readout via global |
| **14** | Patron commitment mechanism (in-world offer + accept/decline/refuse) | Phase 9/11 | Offers fire from dawn pass; threshold gate works; 70% carry-over on accept |
| **15** | Curse-state overlay (Werewolf first, Vampire second) | Phase 14 | Curse multiplier composes correctly; transition events fire per-deity reactions |
| **16** | Neglect subsystem (per-deity neglect effects, max 3 active) | Phase 14 | Neglect spells apply/remove at dawn; broad-worship suppresses |
| **17** | Decay model (linear with tier-floor + grace) | Phase 14 | Decay applies at dawn; floors respected; curse/track modifiers compose |
| **18** | Player-facing UI (player MCM tab, status spell, notification policy) | Phase 14 | Thematic display default; numeric override behind toggle |
| **19** | Content authoring pipeline expansion (`pdv_author.mjs` scope + verifier coverage) | Parallel | Add-a-deity workflow time roughly halved vs. Phase 6 |
| **20** | Mod compatibility first patch (Sacrosanct for vampire cross-routing) | Phase 15 | Sacrosanct feed events translate to PDV signals; no double-fire |
| **21** | 1.0 content lock + polish | All above | Pantheon at 25-35 deities, all 10 races have at least one foreground option, all locked race architectures honored |

V3 Preflight and Structural Skeleton are acceleration gates: they make the
system safe to scale before broad content lands. Phases 7-9 then widen what the
system can see and react to. Phases 10-12 are the per-race overlay layer. Phase
13 brings Daedric paths online. Phases 14-17 turn the system from "tracks
piety" into "feels like a relationship." Phase 18 is the player handoff.
Phases 19-21 are scaling and polish.

### 21.1 What "1.0" means

For content-rich 1.0:

- All 10 races have at least one foreground patron path that respects their locked architecture.
- All 9 Divines + Talos are implemented as content-ready deities. The Aedric pantheon is lore-complete; Old Ways (Shor, Tsun, Stuhn, Ysmir, Orkey) are at least structurally scaffolded and dev-only unless authored.
- 8-12 Daedric paths are content-ready. The remaining Princes may be structurally scaffolded, but scaffolded paths stay dev-only.
- Curse states (Werewolf + Vampire) are functional.
- Patron commitment, decay, and neglect are all live.
- Player-facing UI is thematic-by-default.
- Sacrosanct compat patch ships alongside.
- No regression of any v2 invariant.

### 21.2 Explicit non-goals for 1.0

- No original multi-stage questlines. Per the race-architecture pre-matrix requirements, the first release uses existing gameplay loops and CK-gated interactions, not bespoke quest arcs. Light authored moments such as commitment offers, shrine/ritual interactions, dialogue recognition, and notifications are in scope.
- No hard Survival/Requiem dependency.
- No DLL plugins authored by PDV.
- No replacement of vanilla shrine activator scripts. (Use overlay receiver quests instead.)

---

## 22. Risk register

| Risk | Severity | Mitigation |
|---|---|---|
| Save-baked script state breaks when adding properties to `PDV_DeityBase` | High | Test all new properties from a clean save before declaring complete; document the "new game required for upgrade" expectation in the mod page changelog |
| StorageUtil key collisions as substrate and curse-state layers add new keys | Medium | Strict prefix discipline: `PDV.Substrate.<Name>.<Key>`, `PDV.Curse.<Key>`, `PDV.Track.<Name>.<Key>`. Verifier flags duplicate prefixes |
| Story Manager event ordering breaks with high-deity-count rivalry | Medium | Stress test in Phase 13 (Daedric paths with cross-Prince rivalry); keep rivalry firing in `AwardPiety` synchronous, not deferred |
| Performance at 35 deities x N signals exceeds budget | Medium | Stance early-out (Section 19.2); benchmark in Phase 12; only iterate FormList when at least one deity has a non-FOREIGN stance for the event's race-condition |
| SkyUI header chain fragility (already observed) | Low (mitigated) | Maintain the dedicated `PDV - SkyUI CK Headers` shim mod; document in `PDV_MOD_SETUP.md` |
| Contested-lore stance assignments cause community pushback at 1.0 | Low | Document the contested-lore decisions in the public mod page; flag stance text per item; the architecture supports overriding stance via compat patches |
| Werewolf/Vampire detection edge cases (Dawnguard VL race, vanilla beast race, modded curse states) | Medium | Defer-on-unknown rather than baking false state; Section 13.1 already specifies this for transient races |
| `pdv_author.mjs` writes a patch that violates "Skyrim.esm first master" | Low (mitigated) | Tool already warns; document the manual remap path; verifier flags violations |
| Wintersun coexistence confuses players | Low | Document explicitly; the systems can coexist with thematic confusion only |
| Custom-race players see "Imperial fallback" without context | Low | Surface in MCM diagnostic; consider a player-visible "your race is treated as Imperial for devotion purposes - this can be overridden by a custom race patch" notification at first load |

---

## 23. Open architectural decisions deferred past 1.0

These are intentionally not solved in v3.

- **Per-race ESP split.** Stays monolithic through 1.0; revisit only on need (Section 18.2).
- **JContainers escalation.** StorageUtil is enough through 1.0. If post-1.0 features require nested structures (e.g. a complex stigma history per Daedric path with timestamp arrays), revisit. JContainers stays out of the v1.0 dependency tree.
- **PO3 Papyrus Extender adoption.** Same: only if a specific event source requires it.
- **Custom race authoring support.** A custom-race patch shape ("here's how a custom race plugin tells PDV which devotional identity it should be") is plausible post-1.0.
- **Multi-character cross-save patron memory.** Each save is independent; cross-save persistence is not architecturally interesting.
- **Localization.** All player-facing strings are ASCII English. A second-pass localization effort post-1.0 is in scope; the architecture supports it via string-table externalization, which would be a minor refactor.

---

## 24. Open Decisions Tracker

Mobile-friendly worklist of every architectural decision still open in v3.
Each entry is sized for phone scrolling. Decision IDs (`D-NN`) are stable:
reference them in chat as "decide D-10 as (b)" or "defer D-17."

Numbering gaps are intentional. When a decision lands, remove it from this
open tracker and resolve it by rewriting the relevant v3 section, adding an
entry to `AGENTS.md` Decisions Log, or moving the item to Section 23 if it is
deferred past 1.0.

### Before Pattern Proving / privilege pilot

#### D-10  Greybeards-Kynareth privilege pilot  (§9.4)

- **Question:** Pilot the privilege pattern by editing a vanilla dialogue topic (Arngeir greeting under high Kynareth tier)?
- **Options:**
  - (a) Yes, with `Shares Dialogue` discipline.
  - (b) No, only add new topics; never edit vanilla.
- **Recommendation:** (a). One pilot proves whether the pattern holds before scaling.

### Before Daedric path implementation

#### D-12  Daedric in shared FormList  (§11.6)

- **Question:** Mix `PDV_DaedricPath_*` into `PDV_FLST_AllDeities` or keep them separate?
- **Options:**
  - (a) Mix into shared FormList; branch in MCM display.
  - (b) Separate `PDV_FLST_AllDaedricPaths`; iterate both lists in router/dawn.
- **Recommendation:** (a). One fan-out path simplifies the router; MCM-side branching is cheap.

#### D-13  Stigma decay model  (§11.6)

- **Question:** How does Daedric stigma fade?
- **Options:**
  - (a) Linear decay with abstention.
  - (b) Triggered by specific cleansing rites only.
  - (c) Both: slow linear baseline + faster rite-triggered drops.
- **Recommendation:** (c). Defer specifics to content-author phase; lock the model now.

#### D-14  Cross-Prince hostility multipliers  (§11.6)

- **Question:** Fire rivalry ledger for canonical Prince-vs-Prince hostility (Boethiah/Malacath, Meridia/undead-Princes)?
- **Options:**
  - (a) Yes, at full Aedric-Daedric multiplier (1.0).
  - (b) Yes, at reduced multiplier (0.3 typical).
  - (c) No, treat as stigma-only.
- **Recommendation:** (b). Real consequence without making Daedric play exhaustingly self-cancelling.

### Before neglect/decay implementation

#### D-17  Werewolf detection source  (§13.5)

- **Question:** How does `PDV_CurseState` detect Werewolf state?
- **Options:**
  - (a) Companions-quest-specific keyword (`PlayerWerewolfFaction` or quest stage).
  - (b) Active race check (`WerewolfBeastRace`).
  - (c) Both, OR-combined.
- **Recommendation:** (c). Race check catches transformed state; faction check catches "afflicted but not currently transformed."

#### D-19  Stacked neglect cap  (§14.4)

- **Question:** Cap simultaneously-active neglect effects?
- **Options:**
  - (a) Cap at 3 (lowest-piety eligible deities).
  - (b) Cap at 5.
  - (c) No cap.
- **Recommendation:** (a). Avoids the "death by a thousand cuts" failure mode at full-pantheon scale.

#### D-20  Neglect under broad worship  (§14.4)

- **Question:** Do per-deity neglect effects apply during broad worship?
- **Options:**
  - (a) Suppress all per-deity neglect under broad worship.
  - (b) Apply normally.
  - (c) Apply only to deities the player explicitly disqualified (e.g. via curse).
- **Recommendation:** (a). Broad worship is conceptually "acknowledged by all, dedicated to none" - neglect doesn't apply.

#### D-21  Decay rate default  (§15.3)

- **Question:** Default linear decay rate per day after grace period?
- **Options:**
  - (a) 0.5 piety/day.
  - (b) 0.25 piety/day (slower, more forgiving).
  - (c) 1.0 piety/day (faster, more pressure).
- **Recommendation:** (a). Roughly 50 days from Tier 2 floor to None without activity - feels appropriate for long-running characters.

#### D-22  Grace period default  (§15.1)

- **Question:** Days of no activity before decay starts?
- **Options:**
  - (a) 3 days.
  - (b) 7 days.
  - (c) 1 day.
- **Recommendation:** (a). Balances "you can take a week off without consequence" against "you can't just stop forever."

#### D-23  Decay under broad worship  (§15.4)

- **Question:** Decay rate multiplier under broad worship?
- **Options:**
  - (a) 0.2x normal (default).
  - (b) Same as primary worship (1.0x).
  - (c) No decay under broad worship.
- **Recommendation:** (a). Broad worship should accrue slower and decay slower - the relationship is shallower in both directions.

### Before authoring/perf tooling expansion

#### D-30  StorageUtil read budget  (§19.3)

- **Question:** Add per-deity StorageUtil read count to verifier output?
- **Options:**
  - (a) Yes, as informational metric.
  - (b) Yes, with a soft cap (warn above N reads per `ScoreAction()` call).
  - (c) No.
- **Recommendation:** (a). Visibility is cheap; capping prematurely is constraining.

#### D-31  pdv_author.mjs compat-patch scope  (§20.4)

- **Question:** Should `pdv_author.mjs` learn to author compat-patch ESPs (Requiem, Sacrosanct, etc.)?
- **Options:**
  - (a) Yes, after v3 core subsystems are stable (post-Phase 17).
  - (b) Yes, immediately.
  - (c) No, keep compat patches manual.
- **Recommendation:** (a). The tool's scope should follow proven need; compat patches are first manual, then templated when patterns emerge.

---

## 25. Roadmap to beta and launch

This section is the high-level release roadmap. It is intentionally less
detailed than the subsystem sections above: it names the gates and readiness
bars that future phase plans must satisfy. Architecture truth stays in this
document. External tester messaging lives in `PDV_BetaTesterBrief.md` and must
defer to this section when the two disagree.

### 25.1 Roadmap posture

- **Structural completeness comes before content completeness.** v3 may scaffold the full 1.0 shape early, but incomplete scaffolds stay dev-only until content-ready.
- **V3 Preflight comes before Phase 7.** Signal expansion should not begin until the hardening work below is compile-clean, verifier-clean, and smoke-tested.
- **Beta has two gates.** Technical Beta proves system stability for trusted testers; Content-Feel Beta proves the religious roleplay feel.
- **Launch target is content-rich 1.0.** Public launch waits for broad authored religious texture, not merely a stable narrow core.

### 25.2 V3 Preflight

Purpose: harden the architecture before scaling.

Must complete:

- `PDV_WorshipTargetBase` shared concept for Aedric/cultural deities and Daedric paths, with optional no-op capability hooks rather than mandatory uniform behavior.
- Manager split into internal services with a staged clean API behind an outward facade for existing callers.
- `PDV_GLO_PatronState` for unset, broad worship, and active patron state, with `PDV_GLO_PatronDeity` kept as the active-target cache only.
- `PDV_EventBus` plus a central `PDV_EventTypes` quest/script owner for event IDs. The existing direct-player kill route is the first EventBus canary and must preserve v2 scoring behavior.
- Dawn pass order as named pipeline slots: consolidate scratch, apply decay, recompute tiers, apply spell/neglect layers, process commitment offers, notify. Preflight may leave future subsystem slots no-op.
- Gain pipeline that composes stance, reputation, curse, Daedric stigma, and future modifiers in one place. Preflight moves existing stance math into this pipeline and leaves future modifiers no-op.
- Minimal schema/version hooks that record the current framework schema version and trace mismatches. Do not add a full save-migration registry in Preflight.
- Verifier hard-fail rules for core invariants.

Exit gate:

- Active scripts compile cleanly.
- Verifier reports no hard failures or unexpected TODOs.
- MCM, patron switch, origin seed, dawn pass, and Talos/Auri-El rivalry smoke tests pass on a clean start.

### 25.3 Structural Skeleton

Purpose: make the final 1.0 architecture visible to tools without making
unfinished content player-visible.

Must complete:

- Full 1.0 worship-target scaffold, dev-only by default.
- Strong substrate scaffolds for Khajiit, Dunmer, and Argonian.
- Reputation-track and state-track scaffolds.
- Matrix-driven CK authoring support where feasible, especially stance rows, FormList membership, rivalry wiring, and verifier expectations.
- Canonical visibility state on worship targets (`DevOnly`, `ContentReady`, `PlayerVisible`) plus FormList indexes for authoring/dev inspection. The visibility state is the source of truth; FormLists are operational indexes.
- Verifier states for structural-ready, content-ready, and player-visible records, including hard-fails for visibility/FormList contradictions.

Exit gate:

- Scaffolded targets are inert and hidden from player UI, commitment offers, shrine/dialogue surfaces, and normal gameplay.
- Dev UI and verifier can inspect scaffolded targets.
- No scaffold target can affect gameplay accidentally.

### 25.4 Pattern Proving

Purpose: build one excellent pattern per subsystem before cloning it across
the roster.

Must complete:

- One expanded EventBus signal family.
- One reputation track.
- One state track.
- One strong substrate.
- One contextual favor family.
- One Daedric price/stigma path.
- One commitment offer flow.
- One neglect/decay path.

Exit gate:

- Each pattern is playable, verifier-covered, documented, and reusable.
- Each pattern has one clean in-game proof path that future clones can repeat.

### 25.5 Technical Beta

Audience: small trusted testers.

Ready when:

- Install/update path is documented.
- Core systems are stable on clean starts.
- MCM/status surfaces are readable.
- No known hard verifier failures remain.
- At least several worship paths are content-ready.
- Testers can report bugs against normal play, not console-only flows.

Tester expectation:

- Systems are real.
- Content breadth is incomplete.
- Balance and roleplay texture are still under active tuning.

### 25.6 Content-Feel Beta

Audience: trusted roleplay testers.

Ready when:

- Every race has at least one credible, race-aware foreground path.
- Strong substrates feel distinct for Khajiit, Dunmer, and Argonian.
- Commitment, neglect, decay, curse-state, and UI are live.
- Enough dialogue, shrine, notification, and recognition texture exists to judge religious feel.
- Dev-only scaffolds remain hidden from player-facing surfaces.

Tester expectation:

- Testers should evaluate whether devotion feels meaningful, legible, and lore-grounded, not just whether the systems function.

### 25.7 Content-rich 1.0 launch

Ready when:

- All 10 races have satisfying authored devotional play.
- Major Aedric, Nordic, and Daedric paths are not merely scaffolded.
- Player-facing text is polished and ASCII-safe.
- Light authored moments are present: commitment offers, shrine/ritual interactions, dialogue recognition, and notifications.
- No original multi-stage questlines are required for 1.0.
- Compatibility posture is documented.
- External beta feedback has been addressed or explicitly deferred.

### 25.8 External beta brief

`PDV_BetaTesterBrief.md` is the external-facing tester communication doc. It
explains what testers should expect, how to report issues, and what each beta
gate means in player terms. It is not architecture authority. If it conflicts
with this document, update the brief to match v3.

---

## 26. Revisions

### v3.3 - 2026-05-16 - V3 kickoff decisions

Resolved D-01 through D-08 and tightened the Preflight/Skeleton contracts.
Trinimac is an Altmer-native specialist worship target tied to martial virtue,
civilisational defence, and Thalmor Orthodox play. It should be scaffolded in
the Structural Skeleton, but should become content-ready only when that Altmer
lane is being built. For Orcs, Trinimac stays `TABOO` fringe pressure only, not
a normal Orc core path or fourth Orc lane. Malacath is dual-coded by race, and
Shor/Sep/Lorkhaj/Lorkhan remain separate cultural records.

Preflight now uses staged service APIs behind the manager facade, a central
EventBus/EventTypes owner with the existing kill route as canary, explicit
patron state instead of overloaded `PDV_GLO_PatronDeity` sentinels, named
dawn/gain pipeline slots, and minimal schema-version tracing without a save
migration registry. Indirect kill attribution is payload-only until a later
signal phase assigns devotional meaning. Crime events move to Phase 8 with the
first reputation track. Structural Skeleton visibility uses a canonical target
visibility enum plus FormList indexes, with verifier hard-fails for leaks.

### v3.2 - 2026-05-16 - Section 24 decision cleanup

Resolved the decisions already answered by the v3 roadmap and acceleration
tradeoffs, then removed them from the open tracker. The locked defaults are:
strong substrates only for Khajiit, Dunmer, and Argonian; shrine overlays rather
than vanilla activator replacement; Tier 2 broad-worship cap; three-option
commitment offers; curse states as multiplier/pressure overlays rather than
Daedric unlocks; thematic UI by default; in-world patron switching; concrete
script cloning over an abstract template; FormList-driven MCM ordering;
monolithic framework ESP through 1.0; Phase 12 stack-depth benchmarking; and
documented Wintersun coexistence.

### v3.1 - 2026-05-16 - Roadmap, beta, and launch gates

Added the high-level roadmap from V3 Preflight through Structural Skeleton,
Pattern Proving, Technical Beta, Content-Feel Beta, and content-rich 1.0
launch. This revision locks the split between structural completeness and
content completeness, keeps unfinished scaffolds dev-only, and identifies
`PDV_BetaTesterBrief.md` as external tester communication rather than
architecture authority.

### v3.0 - 2026-05-16 - Initial forward-architecture draft

Created as the planning target for everything past v2's Phase 6 hostile-path slice. Phases 4 and 6 are closed; only their architectural carry-forward items appear in Section 3.

The v3 doc carries the v2 invariants forward (Section 2), surfaces the open items inherited from Phases 4-6 (Section 3), lays out the subsystem map (Section 4) and forward phase plan (Section 21), and ends with a mobile-friendly Open Decisions Tracker (Section 24) sized for working through one item at a time.

Detail level: architectural + named records. Concrete EditorIDs, script shapes, property names, and StorageUtil key prefixes are specified where the contract is load-bearing. Implementation specifics (rubric tuning, exact threshold integers, content text) are deferred to the per-phase CK Steps documents that will accompany each phase as it's built.

Major design adds in v3 vs. v2:

- Reputation track and state track as reusable subsystem patterns (Sections 6-7), absorbing the locked Imperial Concordat Standing and Breton WitchcraftExposure mechanics from the race architecture reference.
- Race substrate quest pattern (Section 8) as the architectural home for the asymmetric hybrid boon policy.
- Privilege and contextual-favor subsystems as named layers (Sections 9-10) so they are tracked and verifier-covered rather than implicit.
- Daedric path architecture as a sibling of deity quests with a boon/price/stigma contract grammar (Section 11).
- Patron commitment mechanism that replaces the v1 bucket-threshold gating with piety-threshold gating composable with state-track eligibility (Section 12).
- Curse-state overlay (Section 13), neglect subsystem (Section 14), and decay model (Section 15) given concrete shape rather than left deferred.
- Mod compatibility as patch ESPs (Section 20).
- Risk register and explicit performance budget.

No phase status changes. v3 does not advance the build; it plans it.
