# Curated-Signal Dispatch Forensics -- 37 Undispatched Signals

Date: 2026-07-14
Scope: AUDIT ONLY. No signals were wired, no copy rewritten, no toolchain touched.
Gate baseline: `node tools/pdv_signal_e2e_gate.mjs --dispatch-coverage-only`
-> 123 declared+scored, 86 dispatched, 37 undispatched, all 37 parked in
`tools/pdv_reserved_signals.json`, gate PASSes.

---

## 1. Headline

**5 of the 37 were genuinely wired and got removed. The other 32 were never wired.
The owner's memory is right about Shor and Talos, and wrong about Leki -- and there
is a specific, non-obvious reason why Leki *feels* wired.**

The 37 are not one bug. They are two failure modes that a single green gate is
currently hiding:

| Class | Count | What happened |
|---|---|---|
| **REGRESSION** -- had a real dispatch, lost it | **5** | Deliberate refactors (substrate retirement, Breton two-axis) removed the caller and left the const + score branch + display phrase behind as dead code. |
| **OMISSION** -- never had a dispatch, ever | **32** | Authored as declaration + score branch (+ usually a phrase) with no trigger. The project's own term for this is **"phantom declarations."** |

> ## STOP -- READ SECTION 9 BEFORE IMPLEMENTING
>
> The wire/cut table in section 5 was written from the signal layer outward and has been
> **superseded**. An adversarial re-check against the current architecture (ADR-0001,
> `PDV_BetaContract.csv`, the 2026-07-13 pantheon-parity lock) found that **three of the
> proposed cuts would delete scaffolding for contracted 1.0/beta content**, and that the
> pacing risk I flagged was the wrong risk entirely.
>
> **Section 9 is the authoritative decision list.** Section 5 is kept as the record of how
> the first pass reasoned, and where it went wrong.

**Final split: 13 CUT confirmed, 8 CUT needing a ruling, 8 KEEP (do not cut), 6 WIRE safe,
2 WIRE blocked.** See section 9e.

---

## 2. What git can and cannot see (read this before trusting any history claim)

`live-source/` enters git history at `d551d219` (2026-06-15, "Add final-polish-look
baseline") and `6bd9b123` (2026-06-21, "Track live Papyrus source in the live-source
mirror (85 .psc)"). Both are **baseline imports of the untracked MO2 live tree**, not
authoring commits.

Consequence: for ~30 of the 37, the declaration + score branch **arrived pre-formed,
already dispatch-less, in an import**. Git cannot show the moment they were authored,
because the authoring happened outside the repo.

```
Shor    SIGNAL_HONORABLE_BATTLE      d551d219  2026-06-15  Add final-polish-look baseline
Stuhn   SIGNAL_MERCY_GRANTED         d551d219  2026-06-15  Add final-polish-look baseline
Tsun    SIGNAL_ADVERSITY_SURVIVED    d551d219  2026-06-15  Add final-polish-look baseline
Leki    SIGNAL_HONORABLE_DUEL        d551d219  2026-06-15  Add final-polish-look baseline
Xarxes  SIGNAL_RECORD_KEEPING        d551d219  2026-06-15  Add final-polish-look baseline
Dibella SIGNAL_GRACE                 d551d219  2026-06-15  Add final-polish-look baseline
Sithis  SIGNAL_VOID_MILESTONE        d551d219  2026-06-15  Add final-polish-look baseline
Akatosh SIGNAL_COVENANT_MILESTONE    d551d219  2026-06-15  Add final-polish-look baseline
Malacath SIGNAL_EXILE_RETURN         d551d219  2026-06-15  Add final-polish-look baseline
Trinimac SIGNAL_FALLEN_GOD_ORTHODOXY d551d219  2026-06-15  Add final-polish-look baseline
Arkay   SIGNAL_CIVIC_SERVICE         d551d219  2026-06-15  Add final-polish-look baseline
Talos   SIGNAL_PROTECT_WORSHIPPER    4f4fdc37  2026-05-30  add phase 18 nord beta handoff package
```

**This blind spot IS part of the bug.** The class was undetectable by code review of
diffs, because no diff ever showed a signal being added without a caller. This is the
same split-toolchain drift recorded in `AGENTS.md` (git live-source vs the MO2 copy).

Syrabane is the one exception -- authored **inside** git -- and it is therefore the
reproducible specimen. See section 4.

---

## 3. The 5 REGRESSIONS (proven, with commits)

Method: deity-bound pickaxe over every tracked `.psc` in all history:
`git log --all -G"AwardCuratedSignal[A-Za-z]*\(PDV_<God>, PDV_<God>\.<SIGNAL>"`.
A hit means a real caller existed in some commit.

| Signal | Wired by | Killed by | Why |
|---|---|---|---|
| `PDV_Shor.SIGNAL_ANCESTOR_SPINE` | `12fa6aef` 2026-06-24 "Build Nord ancestor spine parity" (3 call sites), refined `194e8c0e` | **`652a5fe3` 2026-07-14 "feat: implement pantheon parity and substrate pacing"** | Substrate credit ruled deity-neutral; Nord hearth/sky acts no longer pulse Shor. |
| `PDV_Talos.SIGNAL_ANCESTOR_SPINE` | `0c833597` 2026-06-24 "Build Imperial spine parity" | **`652a5fe3` 2026-07-14** | Same ruling; Imperial civic substrate no longer grants a universal Talos pulse. |
| `PDV_AuriEl.SIGNAL_ANCESTOR_SPINE` | `000c868d` 2026-06-24 "Build Altmer spine parity" | **`652a5fe3` 2026-07-14** | Same ruling. |
| `PDV_Magnus.SIGNAL_ANCESTOR_SPINE` | `22dfa0c5` 2026-06-24 "Build Breton spine parity" | **`7368c87f` 2026-07-12 "Green Way passes the signal floor"** | Breton ancestor-substrate retired. |
| `PDV_Julianos.SIGNAL_LAWFUL_ORDER` | present since at least `cd9ed5e7` 2026-06-07 | **`69905e9c` 2026-07-12 "Prepare Breton two-axis smoke pass"** | The hearth-cover sleep handler was re-pointed: `AwardCuratedSignalScaled(PDV_Julianos, ...LAWFUL_ORDER...)` was **replaced in place** by `AwardCuratedSignalScaled(PDV_Mara, ...SIGNAL_MERCY...)`. |

Exact removal evidence from `652a5fe3` (manager diff, removed lines):

```
3x  AwardCuratedSignalScaled(PDV_Shor,   PDV_Shor.SIGNAL_ANCESTOR_SPINE,   None, multiplier)
1x  AwardCuratedSignalScaled(PDV_Talos,  PDV_Talos.SIGNAL_ANCESTOR_SPINE,  None, multiplier)
1x  AwardCuratedSignalScaled(PDV_AuriEl, PDV_AuriEl.SIGNAL_ANCESTOR_SPINE, None, multiplier)
```

**Every one of the 5 removals was intentional and defensible on design grounds.**
The defect is not the removal -- it is that **the const, the score branch, and the
display phrase were all left behind**, so the signals still count as "declared +
scored" and had to be parked in the reserved ledger to keep the gate green. A
deliberate design change silently manufactured 5 new "known gaps."

### 3a. Open question the spine ruling raises

The 07-13/07-14 ruling ("substrate credit is deity-neutral") was applied to **4 of 7**
race spines. Three still pulse a deity from substrate today:

```
PDV__ManagerQuest.psc:8214   AwardCuratedSignalScaled(PDV_Malacath, ...ANCESTOR_SPINE...)  (Orc)
PDV__ManagerQuest.psc:8963   AwardCuratedSignalScaled(PDV_Tuwhacca, ...ANCESTOR_SPINE...)  (Redguard)
PDV__ManagerQuest.psc:20501  AwardCuratedSignalScaled(PDV_Azura,    ...ANCESTOR_SPINE...)  (Dunmer)
```

These sit in `GetOrcLifeModeSubstrateToken`, `IsRedguardAshAbahBurden` and
`GetDunmerTwilightWindowLabel` -- arguably authentic god lanes rather than passive
substrate, which would make them correct. **But it is worth an explicit ruling**: either
they are authentic (document why) or "pantheon parity" is half-applied and Orc/Redguard/
Dunmer are still taking deity piety from a substrate that Nord/Imperial/Altmer/Breton
no longer do. Right now the codebase does not say which.

---

## 4. The 32 OMISSIONS: the "phantom declaration" mechanism

### 4a. The Phase20 hypothesis is DISPROVEN

`references/authoring/PDV_Phase20_ExpandedSignalArchitecture.md` contains **zero
occurrences** of `AwardCuratedSignal`, `ScoreCuratedSignal`, `HumanizeCuratedSignalReason`,
or any `SIGNAL_*` token. It never touches the curated-signal layer at all -- its unit of
work is a `PDV_FLST_P2_*Sources` FormList. Worse for the hypothesis, its own 4-step recipe
(`:218-223`) **explicitly includes the trigger step** ("Receiver branches in
`PDV_PlayerEvents.psc` for quest-stage routing") and gates on it with a `receiver-needed`
status (`:44-45`). Phase20 is the one doc in the tree that *does* insist on a receiver.

It is not the culprit.

### 4b. The actual mechanism, caught in the act

`9840ec4c` (2026-07-11), titled **"test(signal-floor): close co-test smoke evidence"**,
added Syrabane's entire lane:

```
LAYER 1 -- consts:            + Int Property SIGNAL_PROTECTIVE_WARDING     = 2001 AutoReadOnly
                              + Int Property SIGNAL_APPRENTICE_AID         = 2002 AutoReadOnly
                              + Int Property SIGNAL_CURSE_DISEASE_WARDING  = 2003 AutoReadOnly
                              + Int Property SIGNAL_ANTI_MAGE_SURVIVAL     = 2004 AutoReadOnly
                              + Int Property SIGNAL_MAGICAL_CONTAINMENT    = 2005 AutoReadOnly
LAYER 2 -- score branches:    + if signalType == SIGNAL_PROTECTIVE_WARDING
                              +     return DELTA_PROTECTIVE_WARDING          (... x5)
LAYER 3 -- display phrase:      NONE
LAYER 4 -- dispatch:            NONE   <-- zero AwardCuratedSignal(PDV_Syrabane, ...) anywhere
```

The deliverable was "this deity/lane has signals." **Signal existence was demonstrated by
declaring one.** A commit whose stated purpose was *closing signal-floor smoke evidence*
shipped five unfireable signals -- and the floor went green.

The project already diagnosed this class one day later and even named it. `7368c87f`
(2026-07-12) commit body:

> "Close the last real gap for breton_green_way (was wired 2/5). Every counted type now
> fires in-game; **no phantom declarations**."

That fix was applied to **one lane** (Breton Green Way). Syrabane's five, added the day
before, were never revisited -- they were parked in the reserved ledger on 07-12 instead.

### 4c. Correction to a stated premise: 6 of the 37 are 2-of-4 layers, not 3-of-4

The brief assumed all 37 have a display phrase in `HumanizeCuratedSignalReason`. They do
not. These six have **no phrase at all** -- they are declaration + score branch only:

```
PDV_Syrabane.SIGNAL_PROTECTIVE_WARDING
PDV_Syrabane.SIGNAL_APPRENTICE_AID
PDV_Syrabane.SIGNAL_CURSE_DISEASE_WARDING
PDV_Syrabane.SIGNAL_ANTI_MAGE_SURVIVAL
PDV_Syrabane.SIGNAL_MAGICAL_CONTAINMENT
PDV_Zen.SIGNAL_CIVIC_SERVICE
```

This matters: if one of these were ever dispatched, it would fire with **no driver-row
phrase**, and per the curated-signal driver-reason wiring (`HumanizeCuratedSignalReason`
is the sole phrase source) it would surface as an unvoiced or fallback row. So "wire it"
is strictly more expensive for these six than for the other 31. **No current gate checks
phrase coverage.**

### 4d. Why the owner remembers Shor, Leki, and Talos as wired

Three independent reasons, and all three are reasonable mistakes:

1. **Shor and Talos genuinely WERE wired** -- via `SIGNAL_ANCESTOR_SPINE`, from 2026-06-24
   until `652a5fe3` on 2026-07-14 (two commits before HEAD). "Shor was wired" is a true
   memory attached to the wrong signal.
2. **Leki's signal fires in play -- as Boethiah's.** `PDV_Boethiah.SIGNAL_HONORABLE_DUEL`
   has a real dispatch (`HandleBoethiahHonorableDuel`, `PDV__ManagerQuest.psc:7399`, fed by
   `DGIntimidateQuest` stage 100 = brawl victory). Same signal *name*. A duel signal really
   does appear in the Ledger; it is just never Leki's. Compounding this: Syrabane's consts
   (2001-2005) **numerically collide** with Boethiah's (2001-2005). Safe today only because
   dispatch is deity-scoped -- but a trap for any future generic signal router.
3. **All three have display phrases.** Grepping the manager for `PDV_Shor.SIGNAL_HONORABLE_BATTLE`
   or `PDV_Leki.SIGNAL_HONORABLE_DUEL` returns real hits -- inside `HumanizeCuratedSignalReason`.
   The signal looks wired from the manager side. It is display-only.

---

## 5. Per-signal wire-or-cut table

Deltas and guide quotes read from `live-source/Scripts/Source/PDV_Deity_*.psc` and
`docs/player-guides/races/*.md`. Cost is engineering cost against **existing** infra
(see section 6 for what exists).

### 5a. WIRE (9)

| Deity.Signal | Delta | Player promise | Natural trigger (existing infra) | Cost |
|---|---|---|---|---|
| **Tuwhacca.VAMPIRE_REENTRY** | +4.0 | `Redguard.md:211` "you must return through Tu'whacca first, before any other god... The return is itself a devotional sequence, not just a timer running out." | **Half-built already.** `OnVampirismStateChanged` (`PDV_PlayerEvents.psc:271`) fires and sets `PDV.Redguard.VampireReentryNeeded`. The flag is **set-never-read**. Read it on cure, award, clear. | **LOW** -- cheapest real win in the set. |
| **Magnus.SHARED_PACT_MEMORY** | +1.0 | `Breton.md:96` "each qualifying act also gives a small shared pulse to Magnus through the mixed-inheritance layer" | Dawn pulse. `RunDawnAwardAltmerAuriElDawn` (`PDV__ManagerQuest.psc:11236`, awards at `:11247`) is the exact template; Bosmer/Dunmer/Boethiah/Mephala already do this. Add one function to the `ProcessDawn` chain. | **LOW** |
| **Xarxes.SHARED_PACT_MEMORY** | +1.0 | none | Same function as above -- the ledger's own "Altmer lane lacks the ancestor-memory dawn pulse that Bosmer/Dunmer wire" parity gap. Ship with Magnus's or not at all. | **LOW** (shared) |
| **Tsun.ADVERSITY_SURVIVED** | +2.5 | `Nord.md:25` "god of trials and adversity" (blurb) | **Best value/cost ratio.** `ResolveCombatSession` (`PDV_PlayerEvents.psc:659`) *already computes* near-fatal reversal and outnumbered-win (>=3 kills OR level delta >=5, gated on low-health, daily-capped). That is literally "adversity survived." Blocker: `IsCombatSessionOrigin` (`:878`) is `4||5||6||7||8` -- **Nord is origin 0**, so no session opens. Widen the predicate, add one call. | **LOW-MED** |
| **Trinimac.ALTMER_ORTHODOX_PRESSURE** | +1.5 | `Altmer.md:55` "Hold coherent under pressure" (self-tagged STUB) | The `RouteAltmerAlignmentSignal` / ThalmorAlignment Concordat routes already exist. Hook the existing pressure routes. Trinimac currently has **zero** curated dispatch. | **LOW-MED** |
| **Talos.PROTECT_WORSHIPPER** | +4.0 | `Nord.md:60` "Helping a Talos worshipper... among the strongest Nord deeds"; `Imperial.md:60` "help a Talos worshipper escape the Thalmor" | Thalmor faction resolver exists (`PDV_ActionRouter.psc:188 GetThalmorFaction`, `:195 RouteThalmorUnprovokedKill`). `HandleStoryKillActor` carries victim+killer+location+crime+relationship. Cleanest honest version is a quest-stage hook via `RouteCuratedMilestoneQuestStage` (`PDV_PlayerEvents.psc:1227`) on the Thalmor/Talos quests. | **MED** |
| **Leki.HONORABLE_DUEL** | +3.0 | `Redguard.md:58` "**Win honorable single combat** (Crown / Leki) - no sneak opener, no follower assist, fought through to the end with a one-handed weapon." | The fair-fight conjunction exists inline for Dunmer (`PDV_PlayerEvents.psc:733`: not sneaking, hostile victim, victim level >= player). Reusable. Blocker: **Redguard is origin 9**, also outside `IsCombatSessionOrigin`. Note the copy's promise is *very* specific (one-handed, no follower assist) -- either wire it to that spec or soften the copy. | **MED** |
| **Malacath.EXILE_RETURN** | +3.0 | `Orc.md:160` "for an Exile, as a burden you carried home." (`Orc.md:101` already self-flags: "pure STUB - no caller anywhere") | LEGION_EXILE life-mode + `GetOrcStrongholdHoldId(Location)` (`:8391`) + `HandleStoryChangeLocation` fan-out. Trigger: return to a stronghold in LEGION_EXILE mode carrying a marked burden. Orc (origin 8) already has combat sessions. | **MED** |

~~Shor.HONORABLE_BATTLE~~ — **moved to CUT in Revision 2.** See section 9a.

### 5b. CUT (28)

**B1. The 5 regressions -- delete the dead code, do not restore (5)**

| Deity.Signal | Why CUT |
|---|---|
| Shor.ANCESTOR_SPINE | The 07-13 deity-neutral-substrate ruling is correct and `Nord.md:177` *already says so*: "They do not create a universal Shor award." Copy is right; code is stale. |
| Talos.ANCESTOR_SPINE | No player-facing promise -- "ancestor"/"spine" appear **zero times** in `Imperial.md`. |
| AuriEl.ANCESTOR_SPINE | No piety promise; `Altmer.md:60-61` promises only substrate advance. (Its score branch returns a hardcoded `1.0`; the declared `DELTA_ANCESTOR_SPINE` property is already dead.) |
| Magnus.ANCESTOR_SPINE | **Worse than unwired -- actively retired.** `AwardBretonAncestorSpinePulse` (`PDV__ManagerQuest.psc:19998`) is a no-op that strips legacy boons and traces "Retired Breton ancestor spine signal ignored". But `Breton.md:96` **still promises players** "sleeping can fire an ancestral-dream pulse." **Live copy/code contradiction -- fix the copy.** |
| Julianos.LAWFUL_ORDER | Stendarr owns lawful-order in the civic family (`Imperial.md:93` documents this, and the dispatch is live at `:20599`). Julianos does not need a second one; he has 11 CSV rows + 23 matrix rows. **But see the doc bug in 7b.** |

**B2. Quest-matrix already pays for these acts -- wiring would double-credit (4)**

The reserved ledger's own reason for these is "decide curated vs quest-reaction ownership
before wiring (avoid double-credit)." **That decision is already made in practice** -- the
matrix pays. Verified rows in `references/authoring/PDV_QuestReactionMatrix_Full.csv`:

| Deity.Signal | Delta | The matrix already pays |
|---|---|---|
| Shor.SOVNGARDE_VALOR | +4.0 | `MQ304,Sovngarde,200,...,Shor,+,S,small` -- and `MQ305,Dragonslayer,200,...,Shor,+,C,milestone` |
| Tsun.ENDURANCE_VIGIL | +4.0 | `MQ304,Sovngarde,200,...,Tsun,+,C,small`; `MQ305,...,Tsun,+,C,milestone` |
| Sithis.VOID_MILESTONE | +4.0 | `DB11,Hail Sithis!,200,...,Sithis,+,C,milestone` (and `SIGNAL_VOID_THRESHOLD` +2.0 *is* wired at `:7781`) |
| Akatosh.COVENANT_MILESTONE | **+5.0** | Akatosh has 33 matrix rows. No copy backs this signal -- "covenant" appears **zero times** in `Imperial.md`. Largest orphaned delta in the set, with no promise attached. |

If any of these beats should feel bigger, **raise the matrix row's magnitude** -- a CSV
edit, zero Papyrus, zero double-credit risk.

**B3. Syrabane's entire lane (5)**

> **RETRACTED -- THIS ENTIRE SUBSECTION IS WRONG. DO NOT ACT ON IT.** Syrabane is a fully built,
> offer-eligible patron and these five signals are the scaffolding for beta contract **BC-0153**.
> See section 9e. The reasoning below is preserved only to show how a code-only reading reached a
> confidently false conclusion: every "zero" it cites is true of the *code*, and every one of them
> is irrelevant, because the lane is contracted in a ledger the code does not mention.

`SIGNAL_PROTECTIVE_WARDING` +1.8, `SIGNAL_APPRENTICE_AID` +1.8, `SIGNAL_CURSE_DISEASE_WARDING`
+2.0, `SIGNAL_ANTI_MAGE_SURVIVAL` +1.8, `SIGNAL_MAGICAL_CONTAINMENT` +2.2 (9.6 piety authored).

~~The clearest cut in the audit. Syrabane is a **phantom deity**:~~

- **0** mentions across all of `docs/` -- no player has ever been promised anything.
- **0** likes/dislikes CSV rows (the only deity of the 21 with none).
- **0** curated dispatches.
- **0** display phrases (2-of-4 layers).
- **0** ward detection infrastructure of any kind -- no ward hook, no spell-school hook,
  no concentration hook. These are 100% new detection, the most expensive class in the set.
- Its consts collide numerically with Boethiah's.

Its only earning path is 18 quest-matrix rows, which still work. Cut all five; if Altmer
ever needs a warding lane, design it deliberately then.

**B4. The 7 vestigial SIGNAL_CIVIC_SERVICE -- unreachable by construction (7)**

Arkay, Dibella, Julianos, Kynareth, Mara, Stendarr, Zenithar. All 7 are **real** +2.0 DELTA
branches (not no-ops). They are dead for a structural reason, not an authoring one.

`AwardImperialCivicFamilySignal` (`PDV__ManagerQuest.psc:20588-20610`) is a 5-arm branch on
`familyId`, and **each arm emits that god's DOMAIN signal, not CIVIC_SERVICE**:

| familyId | routes to |
|---|---|
| 1 PUBLIC_SERVICE | `PDV_Akatosh.SIGNAL_CIVIC_SERVICE` <- **the only CIVIC_SERVICE emission that exists** |
| 2 MERCY | `PDV_Mara.SIGNAL_MERCY` (not Mara's CIVIC_SERVICE) |
| 3 LAWFUL_ORDER | `PDV_Stendarr.SIGNAL_LAWFUL_ORDER` (not Stendarr's CIVIC_SERVICE) |
| 4 HONEST_WORK | `PDV_Zenithar.SIGNAL_HONEST_WORK` |
| 5 DEATH_DUTY | `PDV_Arkay.SIGNAL_DEATH_DUTY` |

Dibella, Julianos and Kynareth have **no arm at all**. So the router can never emit
`SIGNAL_CIVIC_SERVICE` for any of the seven. They are not "unwired" -- they are
**unreachable**, and no trigger could reach them without rewriting the router.

`Imperial.md:46-49` already tells players these "do NOT fire from generic civic acts."
**This is a pure dead-code deletion: 7 of 37 gone with zero design decisions required.**
Start here.

**B5. Redundant with an already-wired lane (5)**

| Deity.Signal | Delta | Why CUT |
|---|---|---|
| Xarxes.RECORD_KEEPING | +1.8 | The `Altmer.md:52` bullet that sounds like this actually routes to the **wired** `SIGNAL_LINEAGE_HONORED` (+2.2). Wiring it to `OnBookRead` would double-pay book reads. |
| Xarxes.LEDGER_RESTORED | +3.0 | No gain promise. Closest copy (`Altmer.md:190`) is a Champion *readback*, not an earnable act. |
| Magnus.ARCANE_RECOVERY | +3.0 | No copy promise. The act it describes (`Altmer.md:109`, "Recovered lost arcane knowledge", DA04) **already fires through the quest matrix**. |
| Dibella.GRACE | +3.0 | Blurb only (`Imperial.md:25`); no gain bullet anywhere describes an act of grace. A Dibella charity MGEF faucet is already registered (`faucetEffectForms.Dibella.charity`), so grace-adjacent acts already pay. |
| ~~Trinimac.FALLEN_GOD_ORTHODOXY~~ | +1.5 | **RETRACTED -- see 9e.** I read `Orc.md:17`'s anti-promise and missed that the live lane is **Altmer** (the planned Thalmor Orthodox Champion, `TargetEndStates:818`), and that the reserved ledger says of this exact signal: *"Rare-by-design frequency, but must fire."* |

**B6. No trigger exists and none is worth building (2)**

> **RETRACTED -- see section 9e.** The 2026-07-13 pantheon-parity lock promoted Stuhn to a
> *focusable Old Ways patron with its own offer, rewards, and neglect*. Its live dispatch is 1/3;
> cutting both of these would leave a Champion-eligible patron with a single lane. The detection
> difficulty below is real, but it is an argument for a *better trigger*, not for amputating the god.

| Deity.Signal | Delta | ~~Why CUT~~ (retracted) |
|---|---|---|
| Stuhn.MERCY_GRANTED | +2.5 | "Spare a beaten foe" has **no detectable event** in Skyrim (no yield/surrender state to hook). Mercy already reaches play through the quest matrix (DA07/DA16). |
| Stuhn.JUST_SPOILS | +1.5 | No natural organic trigger at all. |

Caveat for the owner, not a blocker: **two Nord Champion capstones are named after these
dead signals** -- "Just Spoils, Honored Bonds" (`Nord.md:203`) and "The Shield-Thane's
Trial" (`Nord.md:202`, Tsun `ENDURANCE_VIGIL`). Capstone *names* are reward flavor, not
earn promises, so cutting is honest -- but if the names are load-bearing to you, that is a
reason to reconsider `ADVERSITY_SURVIVED` (already in WIRE) rather than these.

---

## 6. Wiring-cost reference (what already exists)

The unit of cost is the **5-step Boethiah chain**, the canonical good dispatch:

```papyrus
; PDV__ManagerQuest.psc:7399
Function HandleBoethiahHonorableDuel(String reason)
    if !PDV_Boethiah || !IsQuestReactionDeityReachable(PDV_Boethiah)
        return
    endIf
    Float multiplier = ConsumeDailyRepeatMultiplier("PDV.Signal.BoethiahHonorableDuel")
    if multiplier <= 0.0
        Trace(2, "Boethiah honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    AwardCuratedSignalScaled(PDV_Boethiah, PDV_Boethiah.SIGNAL_HONORABLE_DUEL, None, multiplier)
    SurfaceReservedSignal(PDV_Boethiah, "Duel honored", "marks a trial honorably won.")
    Trace(2, "Boethiah honorable-duel routed (" + reason + ")")
EndFunction
```

1. **Detect** -- `PDV_PlayerEvents.psc:1241` (`RouteCuratedMilestoneQuestStage`)
2. **Register** -- `:1213 RegisterCuratedSignalQuestSources()`
3. **Bus** -- `PDV_EventBus.psc:412` (pure passthrough, ~10 lines)
4. **Handle** -- the manager function above
5. **Score** -- the deity's `ScoreCuratedSignal` branch

Key facts that change cost estimates:

- **`AwardCuratedSignal*` has NO internal anti-farm cap.** Its only internal gate is
  `delta == 0.0`. All anti-farm is **caller-side** via `ConsumeDailyRepeatMultiplier`
  (`:24372`, a soft `0.7^n` decay that never returns <= 0) or `ConsumeOncePerDaySignal`
  (`:24396`, a true once-per-day boolean). Every wire in 5a must add its own cap.
- **A quest-matrix ROW CANNOT award a curated signal.** The matrix vocabulary
  (deity/valence/intensity/magnitude/tag) has no signal column; `ApplyQuestReaction` ->
  `ApplyDeityReaction` -> `ApplyQuestReactionPiety` awards **generic piety only**. Curated
  quest signals are hard-coded in `RouteCuratedMilestoneQuestStage` (`PDV_PlayerEvents.psc:1227`).
  That function is the extension point.
- **Near-zero-detection paths that already exist:** `RouteP2ImmersiveSource` (book/spell/
  harvest/weather -- add a FormList + one `if` block); `PDV_EventSignalEffect.psc` (a
  CK-fillable MGEF dispatcher with built-in origin + once-per-day gates); the `ProcessDawn`
  chain (for dawn pulses).
- **`IsCombatSessionOrigin` (`PDV_PlayerEvents.psc:878`) = origins 4,5,6,7,8** (Bosmer,
  Dunmer, Khajiit, Argonian, Orc). **Nord=0, Imperial=1, Breton=2, Altmer=3, Redguard=9 get
  no combat session at all.** Every combat-conditioned wire in 5a (Shor, Tsun, Leki) needs
  this predicate widened first. That is the single highest-leverage prerequisite in the set.
- **No ward events, no crime-gold/bounty hook, no faction-rank hook exist anywhere.**

---

## 7. Collateral findings (not part of the 37, found en route)

**7a. `Breton.md:96` promises a retired feature.** It tells players "sleeping can fire an
ancestral-dream pulse" to Magnus. `AwardBretonAncestorSpinePulse` (`:19998`) is a no-op that
traces "Retired Breton ancestor spine signal ignored". Live copy/code contradiction.

**7b. `Breton.md:80` is factually wrong.** It claims Hidden-Art book reads award
"Julianos SIGNAL_LAWFUL_ORDER +3.0". The handler (`HandleBretonHiddenArtExposure`,
`:20217-20243`) awards **`Magnus.SIGNAL_DISCIPLINED_STUDY`**. This is a stale WIRED claim
inside a doc whose entire purpose is proof-boundary tagging -- worth a sweep for siblings.

**7c. `GetImperialCivicFamilyFromSource` (`:20556`) is fragile.** It does first-match
substring matching on the reason string with bare tokens `law` and `work` -- so a reason
containing "lawless" or "network" mis-buckets, and a reason mentioning both mercy and law
silently takes the mercy arm.

**7d. Signal-ID collision.** Syrabane 2001-2005 vs Boethiah 2001/2002/2003/2005. Harmless
while dispatch is deity-scoped; a silent cross-award the moment anyone builds a generic
signal router. Cutting Syrabane (B3) resolves it.

---

## 8. Prevention: is the reserved ledger a to-do list or a silencer?

**It is a silencer. The data is not ambiguous.**

`tools/pdv_reserved_signals.json` entry count, every commit of its life:

```
4fcae1c3  2026-07-07  33 entries  feat(audit): registry-driven curated-signal dispatch gate
15fa8f89  2026-07-12  28 entries  feat(signals): dispatch 4 reserved curated signals   <- -5 BURNED
13dc31e9  2026-07-12  35 entries  chore(gates): document 7 main-drift dispatch gaps    <- +7 PARKED
652a5fe3  2026-07-14  38 entries  feat: implement pantheon parity and substrate pacing <- +3 PARKED
97ac3065  2026-07-14  37 entries  fix(orc): dispatch the Blood-Kin curated signal      <- -1 BURNED
```

In 8 days: **6 entries burned by actually wiring a signal; 10 entries added by parking a new
gap. Net +4.** The file's own `_README` says "shrink toward empty by 1.0." It has grown every
week of its existence. Meanwhile the gate reports PASS, every time, by construction.

The mechanism is a ratchet: any refactor that removes a dispatch (section 3) or any authoring
pass that declares a signal without one (section 4) can be closed out **by adding a line to the
ledger**, which is cheaper than wiring or cutting. The ledger converts a hard failure into a
green build plus a paragraph of prose. That is precisely the "declared but not wired end-to-end"
failure class the project's own audit doctrine names -- except here the gate that should catch it
has been handed the mute button.

Note also that the gate is blind to two things entirely: **phrase coverage** (6 of the 37 have no
display phrase -- section 4c) and **reachability** (the 7 CIVIC_SERVICE consts cannot be emitted by
their own router -- section B4). Both are "declared + scored" and both pass.

### What the 1.0 gate should require

1. **The ledger must be non-increasing.** A commit that adds a reserved entry without removing one
   FAILs. This alone would have forced the 07-12 and 07-14 refactors to cut-or-wire in the same
   commit that orphaned the signal, instead of parking it.
2. **Entries must be decisions, not descriptions.** Replace the free-text `reason` with a required
   `decision: "wire" | "cut"`, an `owner`, and an `expires` date. A `wire` entry past its expiry
   FAILs. A `cut` entry is a work order for a deletion, not a permanent resident. "Wave 3" is not a
   date.
3. **Refactor-orphan detection.** If a commit removes the last `AwardCuratedSignal*` call site for a
   signal, FAIL unless the same commit also removes the const + score branch + phrase. Deliberate
   removals should not be able to manufacture new known-gaps.
4. **Extend coverage to the two blind spots.** Add a phrase-coverage check (declared+scored+dispatched
   must have a `HumanizeCuratedSignalReason` arm) and a reachability check (every declared signal must
   be *emittable* by some router, not merely un-dispatched).
5. **At 1.0 the ledger must be EMPTY**, with the gate defaulting to FAIL on any entry. Per the project's
   own default-fail ruling (`pdv_verify.mjs:1357`): "an opt-in flag nobody passes is how the dead-signal
   class hid."
6. **Dispatch is not proof of firing.** Even after wiring, a signal can be silently eaten (cf. the
   day-key-zero bug that ate every first-day P2 route, and FormList index drift). Anything moved from
   `wire` to done needs an in-game trace or Book-of-Days row, not just a call site.

**Suggested burn order** (fastest debt reduction first): the 7 CIVIC_SERVICE (pure deletion, no design
call) -> the 5 Syrabane (pure deletion, resolves the ID collision too) -> the 5 regression consts +
the `Breton.md:96` copy fix -> the 4 milestone cuts -> then the 9 wires, starting with
Tuwhacca.VAMPIRE_REENTRY (a set-never-read flag) and the `IsCombatSessionOrigin` widening that unblocks
three of the others.

Executing the cuts takes the ledger from 37 to 8 without wiring a single signal.

---

## 9. Revision 2 -- premise challenge against the current architecture

The section-5 table was built from the signal layer outward. This section stress-tests it
against the architecture that *caused* the removals (ADR-0001/0004/0005, the substrate
conversion in `652a5fe3`, the v3.94 remap addendum). Two recommendations changed. The rest
hardened.

### 9a. Corrections to the first pass

**(1) `Shor.SIGNAL_HONORABLE_BATTLE`: WIRE -> CUT.** `Nord.md:58` promises "Killing a worthy,
armed foe in fair combat pleases Shor, Tsun, and Stuhn." That promise is **already kept**, in
the likes/dislikes CSV, for all three named gods, with anti-farm caps already set:

```
Shor,  2, kill-hostile-humanoid, +, small,  0.5, dailyCap 3
Tsun,  2, kill-hostile-humanoid, +, medium, 0.75, dailyCap 2
Stuhn, 2, kill-hostile-humanoid, +, small,  0.5, dailyCap 3
```

The curated signal is not a missing feature. It is a redundant second implementation of a paid
act, and wiring it at +2.0 with only soft decay would have double-paid every kill and blown the
pacing model. **This is the single most important correction in the audit** -- it is the exact
mistake the audit was written to prevent, and I nearly made it.

**(2) Syrabane is NOT a phantom deity.** The first pass called it "a deity with no reason to
exist as-shipped." That was wrong. `PDV_Architecture_v3.md` (v3.94 addendum) states plainly:

> "Syrabane is an Altmer roster-visible focus with eight approved College/**warding**/plague/
> hostile magic rows... Altmer Syrabane/Trinimac and Breton active-tradition formal offers are
> eligible at source/readback level."

Syrabane has a full built reward family (`PDV_Bless_Altmer_Syrabane_T1/T2/T3`), a formal patron
offer (`PDV_Msg_Altmer_Syrabane_Offer`), a `SyncAltmerRewardFamily` call, and 18 quest-matrix
rows. It is a takeable patron with a working warding theme.

**The CUT still stands, and is now better-founded:** the eight approved matrix rows *already*
cover College / warding / plague / hostile-magic. The five curated signals are a second,
unfireable, unvoiced implementation of the same theme. Cutting them removes a redundant lane,
not a deity. (It also resolves the 2001-2005 ID collision with Boethiah.)

### 9b. VERIFIED: the spine removals were a currency conversion, not a loss

The four `ANCESTOR_SPINE` cuts are safe, and I confirmed *why* rather than trusting the ledger's
prose. `HandleSubstrateActionEvent` (`PDV__ManagerQuest.psc`) is the post-`652a5fe3` path. A Nord
open-sky rest or hearth meal now runs:

```papyrus
PDV_NordAncestorSubstrate.RecordAncestralRestScaled(1.0, "open_sky_rest_" + reason)
SendPrismaSubstrateProgress("ancestor", tierBefore, ...GetSubstrateTier(), ...GetMetric() - metricBefore,
                            "The open sky kept the old practice.", "journal", GetNordAncestorLayerLabel())
```

It moves a substrate **metric**, advances a substrate **tier**, and surfaces a Prisma journal
progress row. It awards **no deity piety at all**. Identical shape for Imperial civic (craft),
Altmer heritage (enchantment) and Argonian practice (cooked meal).

So the acts still pay -- in the substrate currency, with their own visible progression. The spine
signals were **converted, not deleted**. Cutting the leftover consts is lossless to the player.
This is consistent with the substrate doctrine that the metric channel is not a piety pulse and
sits outside anti-farm.

### 9c. Save-safety: what a "CUT" may and may not delete

ADR-0004 ("legacy EditorIDs, script/property names, and StorageUtil keys may retain compatibility
vocabulary") and ADR-0005 ("focused T1 records remain save-compatible artifacts but are never
granted") establish a project doctrine of **retaining dead artifacts for save continuity**. A cut
must respect it. The two property flavours behave differently:

| Declaration | Flavour | Save-baked? | Safe to delete? |
|---|---|---|---|
| `Int Property SIGNAL_X = 2001 AutoReadOnly` | compile-time const, **not** in VMAD | No | **Yes -- free.** |
| `Float Property DELTA_X = 1.8 Auto` | VMAD-baked, persisted on the save | **Yes** | Deleting orphans the saved property and needs a VMAD pass. |

**Therefore the minimal, zero-risk cut is:**

1. delete the `HumanizeCuratedSignalReason` arm (manager) -- **must go first**, or the const
   deletion breaks the compile;
2. delete the `ScoreCuratedSignal` branch (deity script);
3. delete the `Int Property SIGNAL_X ... AutoReadOnly` const (deity script);
4. **LEAVE the `Float Property DELTA_X ... Auto` in place.** It becomes an unused property --
   harmless, compiles clean, no VMAD churn, no re-bake, fully save-safe.

That is enough to drop the signal out of the gate's declared set (it keys on `Int Property SIGNAL_X`)
and out of the reserved ledger. Edit sites are confined to 2 files (deity script + manager); nothing
in `PDV_MCM.psc` or `PDV_EventBus.psc` references any of the 37. Syrabane's five touch **one** file.

### 9d. Pacing: my first-pass risk model was WRONG -- and it hid the real risk

**Correction. You cannot blow the daily cap. It is structurally impossible.**
`PIETY_DAILY_MAX_DELTA = 4.3 AutoReadOnly` and `GAIN_RATE_SCALE = 1.32` (`PDV__ManagerQuest.psc:588,592`),
and dawn consolidation applies a **hard clamp** *after* all signals have accumulated into `PietyToday`:

```papyrus
Float scaledToday = pietyToday * GAIN_RATE_SCALE          ; x1.32
Float dailyCap = PIETY_DAILY_MAX_DELTA                     ; 4.3
Float clampedToday = ClampValue(scaledToday, -dailyCap, dailyCap)
```

A spammed +4.0 signal converges (via `0.7^n` decay) to ~13.3 raw and is clamped to 4.3 anyway. So the
"~87 piety of unbalanced delta" framing in the first pass was **alarmist and wrong** -- raw delta is
simply not the thing to fear. Retract it.

**The real risk is the broad-pantheon pool, and I did not model it.**
`AwardPietyInternal` (`:12337`) **auto-opens a broad-pantheon event scope when none is open**:

```papyrus
Bool ownsBroadEvent = _broadPantheonEventDepth == 0
if ownsBroadEvent
    BeginBroadPantheonEvent(eventLabel + "_auto_" + _broadPantheonSelfEventSequence)
endIf
...
Float appliedAmount = RunGainPipeline(deity, amount, stance)
AccumulateBroadPantheonDelta(deity, appliedAmount)
```

So **every curated award on a pool-eligible deity feeds the broad pool.** `IsDeityEligibleForBroadPantheon`
covers **Kyne, Shor, Tsun, Stuhn, Talos, Mara, Arkay, Dibella** and the Imperial Eight. Per ADR-0001,
`AccumulateBroadPantheonDelta` keeps the **strongest applied positive delta per logical event**
(`appliedDelta > _broadPantheonBestPositive`), not the sum.

Two precision notes the adversarial pass slightly overstated, and which matter for the ruling:

- Combat **already** feeds the Nord Old Ways pool today: `AwardPietyFromLikesDislikes` (`:1532`) routes
  through the same `AwardPietyInternal`, and Shor/Tsun/Stuhn all have `kill-hostile-humanoid` CSV rows.
  So a combat-triggered curated signal is **not a novel leak** -- it is an *amplification* of an existing
  channel.
- Because the pool takes the per-event **max**, the amplification is measurable: today a humanoid kill
  contributes `max(Shor 0.5, Tsun 0.75, Stuhn 0.5) = 0.75` to the pool. Wiring `Tsun.ADVERSITY_SURVIVED`
  at 2.5 would raise the per-combat-event pool contribution to ~2.5 -- roughly **3.3x** -- turning
  ordinary fighting into Old Ways devotional standing at a materially faster rate.

That is a **doctrine question for ADR-0001**, not a cap question, and it is the thing to actually decide.

### 9e. FINAL decision list (supersedes section 5)

**CUT -- confirmed, safe to execute (13)**

| Signals | Why it holds |
|---|---|
| 4x `SIGNAL_ANCESTOR_SPINE` (Shor, Talos, AuriEl, Magnus) | Acts converted to substrate **metric** (9b), verified in code and in `PDV_SubstratePacingContracts.json` (`"pietyNeutral": true`). Dead code. **Also fix `PDV_SpineStackRegistry.csv`** -- its Imperial/Altmer/Nord rows still claim these lanes are live. Leave the Dunmer(Azura)/Redguard(Tu'whacca) rows alone; those are wired. |
| 7x `SIGNAL_CIVIC_SERVICE` | **Strongest cut in the audit.** Unreachable by construction, and it is the *project's own written recommendation*, seven times over, since 2026-07-06. Superseded by the broad pool + civic substrate, both built. No planned lane references them. |
| `Julianos.SIGNAL_LAWFUL_ORDER` | The ledger set a condition -- "REMOVE **if** Julianos study credit stays on the likes/dislikes path." **Condition verified met:** Julianos has CSV rows 340/341/342 (book/tome/lore, +0.5, cap 3) and 344. Stendarr owns `LAWFUL_ORDER` in the civic router. Fix `Breton.md:80` (names the wrong god) and `Breton.md:96` (promises a retired pulse). |
| `Shor.SIGNAL_HONORABLE_BATTLE` | `Nord.md:58` is **already kept** by the CSV for all three named gods (Shor 0.5/cap3, Tsun 0.75/cap2, Stuhn 0.5/cap3). Wiring it would double-pay *and* amplify the Old Ways pool (9d). |

**DO NOT CUT -- these were errors in the first pass (8)**

| Signals | Why the cut must not land |
|---|---|
| **5x Syrabane** (`PROTECTIVE_WARDING`, `APPRENTICE_AID`, `CURSE_DISEASE_WARDING`, `ANTI_MAGE_SURVIVAL`, `MAGICAL_CONTAINMENT`) | **`PDV_BetaContract.csv` BC-0153, status `BETA`**, contracts exactly this lane: *"ward spells absorb 15% more; after protective spell cast, next non-protection spell cost -10%; magic-using enemies deal 15% less at Champion; College/magical-institution recognition privilege."* The five signals are its scaffolding. Syrabane is also a fully built, offer-eligible patron (T1/T2/T3 blessings, formal offer, medallion, Prisma glyph, roster-locked in `PDV_DeityCoverageMatrix.json`). Cutting would make it **the only offer-eligible patron in the mod with zero curated lanes** -- a player could commit to Syrabane and find that warding does nothing. **Reclassify: reserved, `decision: wire`, owner BC-0153.** |
| **2x Stuhn** (`MERCY_GRANTED`, `JUST_SPOILS`) | The **2026-07-13 pantheon-parity lock** (`PDV_TargetEndStates_1.0.md:618,649`) -- the *newest* authority in the repo, one week newer than the ledger note I acted on -- states: *"Shor, Tsun, and Stuhn are focusable Old Ways patrons in their own right (each with its own offer, rewards, and neglect). A Nord's Champion can land on any of them."* Stuhn's live dispatch is **1/3**. Cutting both leaves a Champion-eligible patron with one lane. |
| `Trinimac.FALLEN_GOD_ORTHODOXY` | The reserved ledger says it verbatim: *"Rare-by-design frequency, **but must fire**."* I cut it on the strength of an `Orc.md:17` anti-promise -- but the live lane is **Altmer**, not Orc: `PDV_TargetEndStates_1.0.md:818` plans the *Thalmor Orthodox Champion (Trinimac/Auri-El)*. Trinimac's dispatch is **0/2**. |

**CUT -- needs an explicit "we are not shipping this beat" ruling (8)**

`Shor.SOVNGARDE_VALOR`, `Tsun.ENDURANCE_VIGIL`, `Sithis.VOID_MILESTONE`, `Akatosh.COVENANT_MILESTONE`,
`Xarxes.RECORD_KEEPING`, `Xarxes.LEDGER_RESTORED`, `Magnus.ARCANE_RECOVERY`, `Dibella.GRACE`.

These are mechanically safe to cut and the double-credit evidence holds (MQ304 pays Shor **+S** and Tsun
**+C**; DB11 pays Sithis **+C milestone**; Xarxes/Magnus already take paid CSV book/tome rows). **But they
are deferrals with named hooks, not vestigial duplicates** -- cutting them is a decision to abandon those
beats, not dead-code hygiene. Note the 4.3 clamp already absorbs most milestone double-credit, which
weakens *both* the double-credit fear and the case for wiring. Dibella's ledger note is pointed:
*"Currently only patron-civic-favor fires for her."*

**WIRE -- safe to proceed (6)**

| Signal | Cap to use |
|---|---|
| `Tuwhacca.VAMPIRE_REENTRY` (+4.0) | **One-shot StorageUtil latch** (precedent `97ac3065` Blood-Kin), not the repeat multiplier. Flag `PDV.Redguard.VampireReentryNeeded` is written twice and read **zero** times -- verified. Tu'whacca is in no broad pool. |
| `Malacath.EXILE_RETURN` (+3.0) | One-shot latch. Malacath is in no broad pool. |
| `Magnus.SHARED_PACT_MEMORY` (+1.0) | Dawn pulse, 1/day. Named Bosmer/Dunmer parity gap. |
| `Xarxes.SHARED_PACT_MEMORY` (+1.0) | Same dawn function. |
| `Trinimac.ALTMER_ORTHODOX_PRESSURE` (+1.5) | Rare-by-design; not pool-eligible. Serves the planned Orthodox Champion. |
| `Leki.HONORABLE_DUEL` (+3.0) | `ConsumeDailyRepeatMultiplier`. Leki is in **no** broad pool, and has **no kill row in the CSV at all** -- a combat-honour god with zero combat income, so the promise is genuinely unkept. Requires widening `IsCombatSessionOrigin` to Redguard (origin 9). |

**WIRE -- blocked pending a ruling (2)**

| Signal | Blocker |
|---|---|
| `Tsun.ADVERSITY_SURVIVED` (+2.5) | **ADR-0001 pool amplification.** The ledger's own detector spec is "hard-fight-at-disadvantage / long-ordeal" -- which fires on ordinary combat. Tsun is pool-eligible (NordOldWays), so this raises the per-combat-event pool contribution ~3.3x (9d). Needs either a genuinely rare detector or a pool-suppressed award path. |
| `Talos.PROTECT_WORSHIPPER` (+4.0) | **`PDV_TargetEndStates_1.0.md:690`**: *"Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence."* My proposed Thalmor-kill detector sits **directly on the forbidden surface**. Needs an authored-defiance route (quest-stage), not a combat/faction hook. |

### 9f. Mandatory implementation conditions (any cut)

1. **Delete the matching `tools/pdv_reserved_signals.json` entry in the SAME commit.** The gate FAILs on
   a stale entry -- its own README: *"a stale entry -- now dispatched **or no longer declared** -- also
   FAILs."* Non-negotiable.
2. **Cut scope = `SIGNAL_*` const + `ScoreCuratedSignal` branch + the display phrase. LEAVE the
   `DELTA_*` `Auto` floats** (9c). They are save-persisted; removing them buys nothing but Papyrus log
   noise.
3. **Fix `references/authoring/PDV_SpineStackRegistry.csv`** -- the Imperial/Altmer/Nord rows still assert
   a double-route through `Talos`/`Auri-El`/`Shor SIGNAL_ANCESTOR_SPINE`, stale since `652a5fe3`.
4. Run `pdv_signal_e2e_gate --strict-curated-signal-dispatch` **and**
   `pdv_deity_signal_remap_adversary_check` before and after.

### 9g. Rulings needed before anyone touches code

1. **ADR-0001 / broad pool.** Should a curated signal on a pool-eligible deity feed the broad pantheon
   pool at all? Today it does, automatically, via `AwardPietyInternal`. This governs `Tsun` and any future
   Nord/Imperial signature signal, and it is the single highest-leverage decision in the audit.
2. **Talos.** Is there an authored-defiance route (quest-stage) for "protect a Talos worshipper", or does
   `Nord.md:60` / `Imperial.md:60` copy get softened to match `TargetEndStates:690`?
3. **The 8 "abandon the beat" cuts.** Explicit yes/no. These are design calls, not hygiene.
4. **Spine doctrine parity.** Malacath, Tu'whacca and Azura still pulse deity piety from substrate-ish
   contexts while Nord/Imperial/Altmer/Breton no longer do (section 3a). Authentic god lanes, or is
   pantheon parity half-applied?
5. **Leki.** Build the detector to the `Redguard.md:58` spec (no sneak opener, no follower assist,
   one-handed, fought to the end), or soften the copy?
