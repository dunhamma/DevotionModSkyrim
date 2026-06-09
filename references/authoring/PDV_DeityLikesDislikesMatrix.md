# PDV Deity Likes/Dislikes Matrix - Day-to-Day Signal Design

**Created:** 2026-06-08
**Status:** Schema/policy LOCKED + source foundation BUILT. Event IDs (300+), dawn-aligned
anti-farm, data-driven base `ScoreAction`, full CSV loader, Kyne/Talos/Shor migration, hybrid
PO3/Story Manager routing source, receiver QUST shells, generic faucet FormLists, router/player-alias
properties, six vanilla-rooted Story Manager `Shares Event` nodes, and verifier coverage are
compiled/readback-clean. Remaining: Trespass event-root proof plus in-game runtime proof (section10).
**Owner:** Companion to `PDV_RacePietyRateAudit.md`, `PDV_RaceEffectReviewLedger.md`, and
`references/phase4/PDV_RaceSignalMatrix.csv`
**Trigger:** Confirmed 2026-06-08 that the day-to-day "small-signal" approval/disapproval layer is
wired for only the Nord pantheon (3 of 48 divine actors). This doc designs the shared like/dislike
layer so every god scores that race's authentic daily behavior, per the unified model.

---

## 1. The model this implements

One unified concept: **every god (and Prince) holds a likes/dislikes table.** Every scored act -
combat included - is one row in that table. Acts **earn or lose** piety by approval/disapproval.
Two magnitude tiers feed the same capped pool:

- **Small signals** = day-to-day acts (kill, pray, rest, study, craft, steal, travel...). Small +/-
  deltas, **anti-farmed** so repetition is restrained.
- **Large signals** = the defined milestone beats (quest stages, path transitions, crisis beats).
  Large +/- deltas. **These already exist** as the `ScoreCuratedSignal` layer (31/32 race deities).

This doc covers the **missing small-signal layer only.**

## 2. What is already proven vs. what is new

**Proven end-to-end by Nord/Kyne (do not re-pilot):** act fires -> `PDV_ActionRouter.RouteAction`
classifies and fans to every `deity.ScoreAction()` over `PDV_FLST_AllDeities` -> deity returns a
signed delta -> `ScoreRepeatableAction(evt, delta, dailyCap, cooldownDays)` applies anti-farm ->
`AwardPiety` -> capped pool -> tier -> boon. Earn/lose, daily cap, cooldown, and the `0.7^n`
`ConsumeDailyRepeatMultiplier` decay are all validated against kills.

**New (the only real engineering):**
1. **Action vocabulary** - today the router classifier emits ~2 generic acts (beast-kill,
   humanoid-kill) + shouts. Most daily behavior has no event to fire.
2. **Detection receivers** - one thin Story Manager receiver per new act, on the
   `PDV__SM_KillActor` pattern (lifecycle glue -> router; no scoring in the receiver).
3. **The like/dislike tables themselves** - content for ~48 actors.

**Not new:** the scoring math, anti-farm, routing, tiering. Reuse as-is.

## 3. Grounding constants (from live source)

| Constant | Value | Source |
|---|---|---|
| `PIETY_DAILY_MAX_DELTA` | 4.3 / deity / day | `PDV__ManagerQuest.RunDawnConsolidateScratch` |
| `GAIN_RATE_SCALE` | 1.32 | same |
| Tiers | 25 / 50 / 85 | `PDV_DeityBase` (Seeker/Devoted/Champion) |
| `PIETY_MAX` | 200 | `PDV_DeityBase` |
| Anti-farm helper | `ScoreRepeatableAction(eventType, delta, dailyCap, cooldownDays)` | `PDV_DeityBase:242` |
| Repeat decay | `0.7^n` per same-signal repeat | `ConsumeDailyRepeatMultiplier` (manager) |
| Stance gain mult | NATIVE 1.0 / FOREIGN 0.5 / TABOO 0.75 | `PDV_DeityBase.GetGainMultiplier` |

**Pacing guardrail (from project memory):** day-to-day deltas must stay **small** so normal play
(1-2 acts/day) does NOT cap the 4.3/day pool - capping should require dedicated, varied practice.
Keep most day-to-day likes at **0.25-0.5**; reserve >=1.0 for genuinely strong theological acts.

> **Prerequisite (wired + happy-path proven):** `ProcessDawn` (banks `PietyToday -> Piety`) auto-fires
> at **~06:00 (dawn)** in the `OnUpdate` 1s tick (`PDV__ManagerQuest.psc` ~500-516:
> `(GetCurrentGameTime() - 0.25) as Int` vs stored `PDV.DawnAuto.LastDay` -> `ProcessDawn()`). Test 1
> PASSED in-game 2026-06-08 (Tu'whacca 24->27.96, -> Seeker, single fire). `RunDawnNotify` now also
> emits a vanilla `Debug.Notification` on consolidation (was Prisma-only). Remaining edge to confirm:
> a multi-day sleep/fast-travel jump fires it **once** (not per skipped day) - relevant only when
> per-day decay across skips matters.

---

## 4. Day-to-day event vocabulary (proposed ID block 300+)

New generic acts, race-agnostic, scoreable by any actor. Existing IDs 1 (beast-kill), 2
(humanoid-kill), 40 (shout) are retained and folded into the Combat group. Detection column names
the engine hook; feasibility legend in section9.

### 4.1 Combat - by victim type (extends existing kill classifier)
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 1 | kill-hostile-beast | existing Kill Actor node + victim keyword | CLEAN (built) |
| 2 | kill-hostile-humanoid | existing Kill Actor node | CLEAN (built) |
| 300 | kill-undead | Kill Actor + `ActorTypeUndead` keyword | CLEAN |
| 301 | kill-daedra | Kill Actor + `ActorTypeDaedra` keyword | CLEAN |
| 302 | kill-dragon | Kill Actor + `ActorTypeDragon` keyword | CLEAN |
| 303 | kill-animal-noncombat | Kill Actor + non-hostile/crime status | MODERATE |
| 304 | murder-defenseless | Assault/Kill Actor + crime status > 0 | CLEAN |

### 4.2 Devotional / observance
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 310 | pray-at-shrine | activation of shrine ACTI / blessing MagicEffect apply | MODERATE |
| 311 | take-blessing | blessing spell added (known blessing forms) | MODERATE |
| 312 | shout-to-open-sky | shout cast + exterior + no combat | MODERATE |
| 313 | rest-under-open-sky | `OnSleepStart` + `!IsInInterior` | CLEAN |
| 314 | sleep-in-bed | `OnSleepStart` (interior/owned) | CLEAN |

### 4.3 Labor / craft (one Story Manager node covers all benches)
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 330 | smith-item | Craft Item node + smithing bench keyword | CLEAN |
| 331 | enchant-item | Craft Item node + enchanter keyword | CLEAN |
| 332 | brew-potion | Craft Item node + alchemy keyword | CLEAN |
| 333 | cook-meal | Craft Item node + cookpot keyword | CLEAN |
| 334 | harvest-ingredient | `OnItemAdded` from flora activation | MODERATE |
| 335 | mine-ore / chop-wood | `OnItemAdded` ore/firewood (heuristic) | MODERATE |

### 4.4 Knowledge
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 340 | read-skill-book | Book Read node (skill book) | CLEAN |
| 341 | read-spell-tome | Book Read node + spell learned | CLEAN |
| 342 | read-lore-book | Book Read node (non-skill) | CLEAN |
| 343 | learn-word-of-power | `OnStoryNewVoicePower` node | CLEAN |
| 344 | increase-skill | `OnStoryIncreaseSkill` node | CLEAN |
| 345 | discover-new-location | Change Location node (first visit) | CLEAN |

### 4.5 Civic / charity / order
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 350 | heal-or-cure-npc | Restoration cast on non-hostile (MagicEffect) | MODERATE |
| 351 | clear-bounty / serve-time | `OnStoryServedTime` node / crime-gold delta | CLEAN |
| 352 | give-gold-charity | gift dialogue to beggar | HARD |
| 353 | free-captive | quest/activation specific | HARD |
| 354 | persuade-success | speech challenge | HARD |

### 4.6 Transgression (the "dislikes" surface)
| ID | Event | Detection | Feasibility |
|---|---|---|---|
| 360 | pick-owned-lock | `OnStoryPickLock` node (owned) | CLEAN |
| 361 | trespass | `OnStoryTrespass` node | CLEAN |
| 362 | steal-item | `OnItemAdded` stolen flag / theft | MODERATE |
| 363 | pickpocket | pickpocket success (no clean SM node) | MODERATE |
| 364 | assault-innocent | `OnStoryAssaultActor` node | CLEAN |
| 365 | raise-undead | Reanimate MagicEffect cast | MODERATE |
| 366 | vampire-feed | feed perk/event | MODERATE |
| 367 | cannibalize-corpse | Namira ritual / specific | HARD |
| 368 | accept-daedric-artifact | `OnItemAdded` in artifact FormList | CLEAN |
| 369 | desecrate-shrine | shrine-specific hostile act | HARD |

**Coverage takeaway:** ~22 of ~33 acts are CLEAN or MODERATE via existing Story Manager node types
- the same infrastructure class as the proven kill receiver. The HARD few (eat/charity/persuade/
cannibalize/desecrate) should be **deferred or dropped**, not blocked on.

---

## 5. Likes/dislikes table schema

One row per **(actor x event)**. This is the authoring unit. The base class does the rest.

| Column | Meaning |
|---|---|
| `actor` | deity or `Daedric:<Prince>` |
| `eventType` | ID from section4 |
| `sentiment` | `+` like / `-` dislike |
| `magnitudeTier` | small / medium / large (-> delta band, section6) |
| `baseDelta` | signed float (sentiment x tier value) |
| `dailyCap` | int, per-deity per-event (0 = uncapped; default per section6) |
| `cooldownDays` | float (0 = none) |
| `stanceGate` | optional - e.g. NATIVE-only, or apply TABOO mult |
| `conditionTag` | optional - victim keyword, location type, owned-flag |
| `notes` | lore rationale / review flag |

## 6. Magnitude & anti-farm policy defaults

| Tier | Like delta | Dislike delta | Default dailyCap | Default cooldownDays |
|---|---|---|---|---|
| small (ambient daily act) | +0.25 ... +0.5 | -0.25 ... -0.5 | 2-3 | 0 (rely on `0.7^n` decay) |
| medium (deliberate devotional act) | +0.75 ... +1.0 | -0.75 ... -1.0 | 1-2 | 0.5 |
| large (rare/strong act) | +1.5 ... +2.0 | -1.5 ... -2.0 | 1 | 1.0 |

**Rules:**
- A single varied day (3-4 distinct small likes) should land well under 4.3, leaving headroom; the
  cap is reached only by **breadth of practice**, never one spammed act (`0.7^n` guarantees this).
- Disapproval is real loss, but floor day-to-day dislikes so a careless act doesn't erase days of
  devotion in one go - large losses belong to the curated-beat layer (creed violations), not here.
- **Symmetric daily-loss clamp (locked 2026-06-08):** net piety LOSS from day-to-day dislikes is
  clamped to **-4.3 / deity / day**, mirroring `PIETY_DAILY_MAX_DELTA`. Ambient disapproval can
  sting a day's progress but cannot cascade into a multi-day collapse; deliberate creed violations
  (curated layer) are the only path to large single-event loss.
- Stance still multiplies: a FOREIGN-stance god pays 0.5x - keep that for off-race worship.

## 7. Starter matrix (clean-detection acts, lore-anchored)

A first authoring wave restricted to **CLEAN-detection events** so the initial build carries no
detection risk. Deltas are conservative day-to-day values. `S/M/L` = magnitude tier.

### Nine Divines / civic pantheon (Imperial, Breton)
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| Arkay | kill-undead (300) | + | S | +0.5 | guardian of the cycle; undead are abomination |
| Arkay | raise-undead (365) | - | M | -1.0 | necromancy is the core sin |
| Arkay | sleep-in-bed (314) | + | S | +0.25 | rest in the natural order |
| Stendarr | kill-undead (300) | + | S | +0.5 | mercy includes wrath on undeath |
| Stendarr | kill-daedra (301) | + | S | +0.5 | Vigilant theology |
| Stendarr | assault-innocent (364) | - | M | -1.0 | cruelty to the weak |
| Stendarr | accept-daedric-artifact (368) | - | M | -1.0 | consorting with Princes |
| Mara | heal-or-cure-npc (350) | + | M | +0.75 | compassion made act |
| Mara | murder-defenseless (304) | - | M | -1.0 | violation of love/kinship |
| Zenithar | smith-item (330) | + | S | +0.5 | honest labor |
| Zenithar | craft (331/332/333) | + | S | +0.25 | honest craft (any bench) |
| Zenithar | steal-item (362) | - | M | -0.75 | theft is the antithesis of fair trade |
| Julianos | read-skill/lore-book (340/342) | + | S | +0.5 | pursuit of knowledge |
| Julianos | increase-skill (344) | + | S | +0.5 | mastery as worship |
| Akatosh | learn-word-of-power (343) | + | M | +0.75 | dragon-tongue, his domain |
| Akatosh | discover-new-location (345) | + | S | +0.25 | endurance through the world |
| Dibella | read-lore-book (342) | + | S | +0.25 | appreciation of created beauty |
| Kynareth | rest-under-open-sky (313) | + | S | +0.5 | sky and wilds |
| Kynareth | discover-new-location (345) | + | S | +0.5 | the traveler's goddess |

### Nord pantheon (already has combat table - adds non-combat breadth)
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| Kyne | learn-word-of-power (343) | + | M | +1.0 | the Voice is Kyne's gift to Men |
| Kyne | rest-under-open-sky (313) | + | S | +0.5 | storm-mother's sky |
| Talos | learn-word-of-power (343) | + | M | +1.0 | Tongue-emperor |
| Shor | kill-hostile-humanoid (2) | + | S | +0.25 | honorable battle (already in ScoreAction) |

### Altmer
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| AuriEl | increase-skill (344) | + | S | +0.5 | disciplined self-perfection |
| AuriEl | sleep-in-bed (314) | + | S | +0.25 | ordered dawn-to-dusk practice |
| Magnus | read-spell-tome (341) | + | M | +0.75 | the architect of magic |
| Magnus | enchant-item (331) | + | S | +0.5 | applied magicka |
| Xarxes | read-lore-book (342) | + | M | +0.75 | scribe of ages, lineage |
| Trinimac | kill-daedra (301) | + | M | +0.75 | the unbroken warrior-god |
| Trinimac | accept-daedric-artifact (368) | - | M | -1.0 | betrayal toward Boethiah's path |

### Khajiit / Bosmer / others (sample)
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| Khenarthi | discover-new-location (345) | + | S | +0.5 | winds and the open road |
| Khenarthi | rest-under-open-sky (313) | + | S | +0.5 | road-home cadence (complements substrate) |
| Rajhin | pick-owned-lock (360) | + | S | +0.5 | the trickster-thief |
| Baan Dar | pick-owned-lock (360) | + | S | +0.25 | the Bandit God |
| Zenithar->Z'en | smith/craft (330-333) | + | S | +0.5 | agriculture/labor/exchange |
| Malacath | smith-item (330) | + | M | +0.75 | the forge as devotion |

### Accepted Daedric patrons - V1, full deity treatment (per section8.1)
These are `PDV_Deity_*` actors (NATIVE/accepted stance), scored exactly like Aedra. (Malacath's
forge row above belongs to this set too.)
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| Azura (Dunmer/Khajiit) | rest-under-open-sky (313) | + | S | +0.5 | dawn/dusk observance under the moons |
| Boethiah (Dunmer) | kill-hostile-humanoid (2) | + | S | +0.25 | victory of the worthy through struggle |
| Boethiah (Dunmer) | increase-skill (344) | + | S | +0.25 | self-betterment by trial |
| Mephala (Dunmer) | pick-owned-lock (360) | + | S | +0.5 | intrusion into the hidden; secrets |
| Malacath (Orc) | kill-hostile-humanoid (2) | + | S | +0.25 | strength proven in open fight |

### Transgressive Daedric Princes (V2 REFERENCE ONLY - excluded from V1 per section8.2; routes commitment signal, not piety)
| Actor | Event | +/- | Tier | delta | Note |
|---|---|---|---|---|---|
| Daedric:Namira | kill-undead (300) | - | S | -0.5 | undeath/decay is hers; destroying it displeases |
| Daedric:Namira | cannibalize (367) | + | L | +2.0 | HARD detection - defer |
| Daedric:Nocturnal | pick-owned-lock (360) | + | S | +0.5 | the shadow-thief |
| Daedric:Hermaeus Mora | read-lore-book (342) | + | M | +1.0 | forbidden knowledge |
| Daedric:Hermaeus Mora | discover-new-location (345) | + | S | +0.5 | all things sought and known |
| Daedric:Meridia | kill-undead (300) | + | M | +1.0 | her singular hatred |
| Daedric:Meridia | raise-undead (365) | - | L | -2.0 | the defiling of life-force |
| Daedric:Hircine | kill-hostile-beast (1) | + | S | +0.5 | the hunt (coordinate with curse rows) |

*This is ~50 representative rows. The full matrix is ~400-600 rows across 48 actors; the remainder
is mechanical fill once the schema and section6 policy are ratified.*

## 8. Daedric Prince integration - REVISED 2026-06-08: by theology, not by pantheon

The discriminator is **not** "is this a Daedric Prince?" but "is this Prince worshipped through the
**accepted-patron face** or the **transgressive-cult face**?" The codebase already carries both:
each accepted Prince exists as a `PDV_Deity_*` actor (stance data, `ScoreCuratedSignal` table, tier
boons) **and** as a `PDV_DaedricPath_*` actor (commitment-signal gate + race-scaled stigma via
`GetStigmaModifierForRace`).

### 8.1 Accepted-patron face (`PDV_Deity_*`) - IN the V1 matrix, full deity treatment
A Prince that a race's own tradition accepts as patron is a **deity for all intents and purposes**:
full day-to-day like/dislike table, NATIVE/accepted stance, tier boons. Already-wired patrons:
- **Dunmer -> Azura, Boethiah, Mephala** (the Reclamations / Good Daedra)
- **Orc -> Malacath** (hero-god)
- **Khajiit -> Azurah** (Azura's lunar face)

These get authored day-to-day rows exactly like Aedra (section7 now includes them). They keep
`IsAedric = False`, so the engine still treats them as Daedric for **rivalry, exclusivity, and
balance invariants** - accepted for *worship/progression* without erasing Daedric nature for
theology/conflict logic.

### 8.2 Transgressive-cult face (`PDV_DaedricPath_*`) - excluded from the V1 ambient faucet
A race reaching for a Prince **its own tradition stigmatizes** uses the path model, which stays
deliberate by design - the commitment-signal threshold + stigma exist to make transgressive devotion
costly and *chosen*, never accrued from ambient acts (a stray lockpick must not drift a Nord toward
Molag Bal). These keep their existing model; **no day-to-day faucet in V1.**

### 8.3 The status is race-relative - and lore-exact
The same Prince can be accepted for one race and transgressive for another, resolved by which face
that race routes to (+ `GetStigmaModifierForRace`):
- **Malacath:** accepted hero-god for **Orc** (`PDV_Deity_`); House-of-Troubles for **Dunmer** (`PDV_DaedricPath_`).
- **Good Daedra** (Azura/Boethiah/Mephala) accepted for Dunmer; **Bad Daedra / House of Troubles**
  (Mehrunes Dagon, Molag Bal, Sheogorath, and Malacath-for-Dunmer) remain path-only.

### 8.4 V2 (deferred)
For a *transgressive* Prince to react to an ambient act, it routes a **commitment signal**
(`AddCommitmentSignal(...)`), **not** piety, and **only on an already-open path** - ambient behavior
can deepen a chosen commitment but never initiate one. Hircine and Molag Bal acts **must** coordinate
with curse-state rows and not double-fire curse transitions (existing rule). The section7 transgressive
Prince rows are **V2 reference only**; the accepted-patron rows are **V1**.

## 9. Detection-feasibility legend

- **CLEAN** - an existing CK Story Manager event node or a single reliable Papyrus event already
  carries the signal (same class as the proven `PDV__SM_KillActor`). Lowest risk.
- **MODERATE** - detectable, but needs a heuristic, a victim/keyword check, a MagicEffect hook, or
  an `OnItemAdded` filter. Build after the CLEAN wave.
- **HARD** - no clean vanilla signal (eat, charity, persuade, cannibalize, desecrate). Defer or drop
  for V1; do not block the matrix on these.

## 10. Implementation plan (progress 2026-06-08)

1. **`ProcessDawn` auto-trigger - DONE.** Wired + runtime-proven (Test 1 + Test 3 pass); moved to
   ~06:00 dawn. See `PDV_ProcessDawn_AutoTrigger_TestPacket.md`.
2. **Data-driven `ScoreAction` - engine + loader + Kyne migration DONE (compiled); in-game regression TODO.**
   - DONE (compiled): `PDV_DeityBase.ScoreAction` returns `ScoreFromTable(eventType)`, reading
     `PDV.LD.<eventType>.{D,C,O}` (delta / dailyCap / cooldown) off the deity form via
     `ScoreRepeatableAction`. Additive - returns 0.0 until keys load.
   - DONE (compiled): anti-farm day boundary aligned to dawn via `DAWN_DAY_OFFSET` (0.25) +
     `GetDevotionDayIndex()`. Keep `0.25` in sync with the manager dawn trigger.
   - DONE (compiled): **loader** in `PDV__ManagerQuest` - `EnsureLikesDislikesTable()` (version-gated
     via `LIKES_DISLIKES_VERSION`, called from `OnInit` + the 10s slow tick so existing saves reload)
     -> `LoadLikesDislikesTable()` iterates `PDV_FLST_AllDeities`, resolves each by `DeityName`, and
     `WriteLD`s the `PDV.LD.*` keys. **v0 hand-authored from the CSV; productionize via a generator
     tool before scaling to 48 actors.**
   - DONE (compiled): **Kyne migrated** - events 1-4 now data-driven (`ScoreFromTable`); the shout
     (40) keeps its property-based call + `targetRef as Shout` guard (Phase 7 verifier invariant).
   - DONE (compiled 2026-06-08): **CRITICAL MASKING FIX** - all 29 thin-shell concrete deity scripts
     had their OWN `Float Function ScoreAction(...) return 0.0` stub that **masked** the new
     data-driven base (Papyrus dispatches to the most-derived override). So the table loaded but only
     Kyne/Talos/Shor (real overrides) read it. Bulk-patched all 29 stubs to
     `return ScoreFromTable(eventType)`. **LESSON: any future generated deity ships with this stub
     and must delegate, or its table rows are dead.** Surfaced when a Dunmer humanoid kill scored
     Kyne (override, FOREIGN 0.25) but NOT Boethiah/Malacath (stubbed 0.0).
   - **DONE - in-game regression PASSED 2026-06-08:** migrated Kyne scored identically - humanoid
     kill raw +0.5 (banked 10.00 -> 10.66 = +0.5x1.32), beast kill raw -3.0 (banked 10.66 -> 6.70
     = -3.0x1.32), exact. Nord test (stance NATIVE x1.0, applied=raw). The loader, `PDV.LD.*` table,
     `ScoreFromTable`, anti-farm, and dawn banking are all proven end-to-end. **The data-driven
     faucet architecture is validated.**
3. **Full likes/dislikes content - DONE 2026-06-09 (compiled).** All 32 deities authored (subagent
   fan-out, lore-grounded) in `PDV_DeityLikesDislikes.csv` (~173 rows). A generator
   (`tools/pdv_likesdislikes_gen.mjs`) emits the Papyrus `LoadRowsForDeity` from the CSV (no more
   hand-transcription). Talos + Shor migrated (non-override events -> `ScoreFromTable`).
   `LIKES_DISLIKES_VERSION` bumped to 3. Re-run the generator + bump the version whenever the CSV changes.
4. **Combat-by-victim detection - SOURCE/ESP DONE 2026-06-09 (compiled/readback-clean).**
   `PDV_ActionRouter.ClassifyKillVictim` emits `kill-undead/daedra/dragon` (300/301/302) by victim
   keyword. `HandleStoryKillActor` also preserves hostile kills and adds non-hostile direct-player
   `303/304` routing. Router keyword/FormList/bench properties are filled in the source ESP.
5. **Hybrid generic receiver source/ESP - DONE 2026-06-09 (compiled/readback-clean except Trespass SM root).** Book/sleep/harvest/artifact/effect
   cases are PO3-owned in `PDV_PlayerEvents`; Craft Item, New Voice Power, Increase Skill, Change
   Location, Pick Lock, Trespass, and Assault Actor have thin `PDV__SM_*` receiver scripts plus
   `PDV_ActionRouter.HandleStory*` handlers. Receiver QUSTs, `PDV_Router`, generic FormLists, and
   router/player-alias properties are wired in the source ESP. Six vanilla-rooted `Shares Event`
   Story Manager nodes are readback-clean; Trespass remains blocked because installed `Skyrim.esm`
   has no local `TrespassActorEvent` SMEN root.
6. **TODO - Trespass root + in-game proof:** default verifier is `FAIL=0` with one TODO for
   `PDV__SM_Trespass`. `--strict-phase3` fails only that blocker. After the Trespass event root is
   proven/wired, run `--strict-phase3`, then runtime smoke every routed event and capture
   `[PDV] EventBus: <deity> event <id> delta <x>` markers.

## 11. Settled decisions (LOCKED 2026-06-08)

1. **Data-driven lookup - LOCKED.** The matrix is authored as a tracked **CSV (source of truth)** and
   materialized into the runtime via the existing author-tool pattern (the
   `pdv-phase20-*-author` idiom that writes records/props), not hand-written ladders. Base
   `ScoreAction(evt,...)` does an **O(1) per-deity StorageUtil lookup** of `(self, evt)` ->
   `(delta, dailyCap, cooldown)` -> `ScoreRepeatableAction`. Concrete deity scripts override **only**
   for conditional logic (Kyne victim-branching, Hircine hunt). Preserves the thin-shell architecture
   and the project's manifest-driven convention. Kyne table-rewrite is the sole regression gate.
2. **Prince handling by theology - LOCKED** (see section8, revised). **Accepted-patron faces**
   (`PDV_Deity_*`: Dunmer Reclamations, Orc Malacath, Khajiit Azurah) are **deities for all intents
   and purposes - IN the V1 matrix** with full day-to-day tables (NATIVE stance, `IsAedric=False`
   preserved for rivalry/balance). **Transgressive-cult faces** (`PDV_DaedricPath_*`, stigmatized
   race) stay on the commitment-signal + stigma model, **excluded from the V1 ambient faucet**;
   status is race-relative (Malacath = Orc patron vs. Dunmer House-of-Troubles). V2 may route ambient
   acts to `AddCommitmentSignal` (not piety) on already-open paths only.
3. **HARD-detection acts dropped - LOCKED.** eat / charity / persuade / cannibalize / desecrate are
   **not** in the day-to-day matrix. Cover the concept via a clean proxy where identity needs it:
   - Mara compassion -> `heal-or-cure-npc` (350).
   - Namira/cannibalism -> stays in the **curated Daedric quest layer**, not the day-to-day faucet.
   Re-open an individual HARD act only if a reliable detection hook is later found.
4. **Disapproval stays small - LOCKED.** Day-to-day dislikes live in the -0.25...-1.0 band; large
   punitive losses remain in the creed-violation curated layer. Net daily ambient loss clamped to
   **-4.3 / deity / day** (section6).
5. **section6 band values - LOCKED** as written (small/medium/large delta + cap + cooldown defaults), now
   including the symmetric daily-loss clamp.

6. **Race-eligibility gate on the generic faucet - LOCKED + implemented 2026-06-08.** Generic
   day-to-day acts (kills + the 300+ vocabulary) only score deities **NATIVE to the player's race**;
   FOREIGN/TABOO/HOSTILE score 0. This reproduces the curated-signal layer's race-scoping (which is
   achieved there by targeted dispatch, NOT a global stance=0 rule - the stance system only *halves*
   foreign, so the generic fan-out leaked before this gate). Rule: **all race-native deities score**
   (e.g. a Dunmer's theft pleases all three Reclamations Azura/Boethiah/Mephala, not just the active
   patron); the active-patron tier is where exclusivity matters. Implemented as `IsRaceNativeForPlayer()`
   (`GetStanceForPlayer() == STANCE_NATIVE`) gating `PDV_DeityBase.ScoreFromTable` + the Kyne/Talos/Shor
   overrides. Verified stance values: Nord->Kyne `stance 0` (NATIVE, scores), Dunmer->Kyne/Shor `stance 1`
   (FOREIGN, zeroed); stance matrix confirms Dunmer->Reclamations = NATIVE. Cross-pantheon worship still
   flows through the Daedric path (stigma) and curated signals, untouched.
   - **STANCE-WIRING DEPENDENCY found + fixed 2026-06-09:** the gate exposed that the ~26 thin-shell
     deities shipped with UNWIRED `Stance_<Race>` (all default FOREIGN=1), which also halved native
     curated signals. Fixed from `references/phase4/PDV_StanceMatrix.csv` via (a) `tools/pdv-stance-author`
     (C# Mutagen ESP VMAD write, all 32 deities, backed up) for new games, and (b) a runtime migration
     (`PDV__ManagerQuest.ApplyStancesForDeity`, version-gated) for existing/mid-playthrough saves --
     needed because VMAD prop values bake into the save at first init and never re-read. Confirmed
     in-game: Dunmer->Boethiah scores 0.25 at stance 0 (full, not halved); Malacath gated at stance 2
     (TABOO); Kyne/Shor gated (FOREIGN). See `deity-stance-wiring` memory.

### Remaining inputs before CK closeout
- Prove/wire `PDV__SM_Trespass` to a valid Trespass Story Manager event root. Installed
  `Skyrim.esm` readback does not contain a local `TrespassActorEvent` SMEN root.
- Run `node .\tools\pdv_verify.mjs --strict-phase3 --json` after Trespass wiring, then perform runtime smoke.
