# PDV Combined Session Bug Report - 2026-07-14 (v2, adjudicated 2026-07-15)

> **v2 NOTICE - PART D IS THE AUTHORITY.** On 2026-07-15 all claims below (plus
> `references/authoring/PDV_PlayerStateBugs_2026-07-14.md` and the bug claims in
> `PDV_RaceGuide_NexusFinalPass_2026-07-14.md`) were reconciled against current main
> (post `0ff53544` guide rewrite + `5f9ce950` pantheon presentation), adversarially
> audited with direct houseCARL ESP reads, and ruled on by the owner. **PART D holds the
> verdict matrix, the executed fixes, and the rulings.** Parts A-C are the historical
> record; where a Part A/B claim conflicts with Part D, Part D wins. In particular,
> Part A's "rename to Seeker" premise was INVERTED by newer canon and its queued ESP
> write was abandoned - do not resume it.

Two bugs found in parallel sessions on 2026-07-14. They are filed together because
**they are the same failure mode wearing different clothes** - see PART C.

| | Bug | Scope | Status (v2) |
|---|---|---|---|
| **PART A** | Player-facing tier-name drift (blessing records) | `Devotion.esp` SPEL/MGEF Name fields; reward spec JSONs; Papyrus tier-label helpers | SUPERSEDED by Part D: canon bands are Distant/Observant/Faithful; 6-record band write EXECUTED with readback 2026-07-15; label-helper residue queued to the scoped pass. |
| **PART B** | Curated-signal dispatch - 37 signals that can never fire | `PDV_Deity_*.psc`, `PDV__ManagerQuest.psc`, `tools/pdv_reserved_signals.json` | ADJUDICATED: 21 cut / 8 wire-now / 8 wire-later, all owner-ruled; ledger annotated with decision/owner/expires; execution handoff written. |
| **PART C** | The shared root pattern + the work they both block on | - | Still the right lens; the scoped-pass handoff now exists (`references/authoring/PDV_HO_ScopedManagerPass_2026-07-15.md`). |
| **PART D** | Reconciliation + adversarial-audit verdicts (2026-07-15) | everything above + `PDV_PlayerStateBugs_2026-07-14.md` | **CURRENT AUTHORITY.** |

**Neither bug is what its originating premise said it was, and in both cases acting on
that premise would have shipped a regression.** That is not a coincidence; it is the
finding.

---

# PART A - Player-Facing Tier-Name Drift (Blessing Records)

**Date:** 2026-07-14
**Scope:** `Devotion.esp` SPEL/MGEF Name (FULL) fields; per-race reward spec JSONs; live Papyrus tier-label helpers
**Status:** Source (specs) FIXED. ESP write QUEUED, BLOCKED on ESP lock. Two decisions open.
**Evidence basis:** direct `housecarl_*` reads of the live `Devotion.esp` (Anvil instance) + live-source `.psc` grep. No runtime/in-game proof claimed.

---

## 0. TL;DR for the reviewer

The originating ticket described this as "8 blessing spells still carry retired design-sheet tier names (Observant/Faithful); rename them to the shipped Seeker/Devoted/Champion."

**That premise is false and acting on it would have shipped a regression.**

PDV runs **two parallel player-facing tier ladders**. `Faithful` is not retired vocabulary - it is the live, shipped name of the **broad-worship lane's** top rung. The genuine bug is smaller, different, and sits almost entirely in the **T1** row.

| Ticket claimed | Actually true |
|---|---|
| 8 drifted records | **12** drifted records |
| `Imperial_Civic_T1` already fixed in ESP ("- Seeker") | ESP says **"- Observant"** - not fixed |
| Specs carry the retired names; ESP is ahead | **Specs are mostly RIGHT; the ESP drifted.** Every spec already encodes T1=Seeker / T2=Faithful |
| Rename all `- Faithful` -> `- Devoted` | Would **mislabel** a maxed broad worshipper as mid-ladder |

---

## 1. Root cause: there are TWO ladders, not one

### Patron lane (a focused active patron)
`None -> Seeker (25) -> Devoted (50) -> Champion (85)`
Source: shipped UI `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js`, `thresholds` array.

### Broad-worship lane (`PATRON_STATE_BROAD`, no focused patron)
`Seeker (25) -> Faithful (50)` - and it **stops at Faithful. It never reaches a T3/Champion.**

```papyrus
; PDV__ManagerQuest.psc:627-628
Float Property BROAD_PANTHEON_SEEKER_THRESHOLD   = 25.0 AutoReadOnly
Float Property BROAD_PANTHEON_FAITHFUL_THRESHOLD = 50.0 AutoReadOnly
```

Five independent shipped surfaces agree the broad 50-gate is called **Faithful**:

1. `app.js:1280` - the broad gauge is literally `[{ label: "Seeker", value: 25 }, { label: "Faithful", value: 50 }]`
2. `PDV__ManagerQuest.psc:14115-14119` - the grant sites pass the display names `"The Divines' Regard - Faithful"`, `"Old Ways - Faithful"`, `"Faith of the Holds - Faithful"`
3. `PDV_DiegeticDirector.psc:360` - `"You reached Faithful. The pantheon turns to look."`
4. The manager's own gate variables are named `imperialFaithful` / `oldWaysFaithful` / `nineFaithful`
5. `PDV_RedguardRewardRecords.spec.json` states the intent outright:
   > `"threshold": "broad-worship state, capped at Faithful (broad lane stops here; never reaches T3)"`

**Consequence of the ticket's proposed fix:** broad standing caps at 50. `Devoted` is the *middle* rung of the patron ladder (cap 85). Renaming the broad T2 rewards to `- Devoted` would tell a player who has **maxed** the broad lane that they are mid-ladder, implying a Champion rung they can never reach on that lane - while the gauge rendering beside it still reads "Faithful". This is the regression the fix would have introduced.

**Why the trap is easy to fall into:** both ladders share the same T1 word (`Seeker`) *and* the same 50-point gate value. A single-ladder mental model looks correct right up until it silently relabels the broad lane.

---

## 2. The actual bug: the T1 row

Five T1 spells contradict **their own magic effects**. The player sees the SPEL name in the magic menu and the MGEF name in Active Effects - so a single reward currently presents under two different tier words.

| # | FormID | EditorID | SPEL Name (live) | its own MGEF says | Correct |
|---|---|---|---|---|---|
| 1 | `071071` | `PDV_Bless_Imperial_Civic_T1` | `The Divines' Regard - Observant` | `- Seeker` (0710B8, 071568) | `- Seeker` |
| 2 | `071073` | `PDV_Bless_Nord_OldWays_T1` | `Old Ways - Observant` | `- Seeker` (0711B3) | `- Seeker` |
| 3 | `0716C4` | `PDV_Bless_Nord_NineDivines_T1` | `Faith of the Holds - Observant` | (untiered) | `- Seeker` |
| 4 | `07106F` | `PDV_Bless_Dunmer_Reclamation_T1` | `Reclamation Communion - Faithful` | `- Faithful` (071156) | `- Seeker` |
| 5 | `071069` | `PDV_Bless_Argonian_Hist_T1` | `Hist Communion - Faithful` | (untiered) | `- Seeker` |

Rows 4-5 are the nastiest: a **Seeker-tier (25 piety) blessing tells the player they are "Faithful"** - wrong on *either* ladder.

Corroboration that `Seeker` is right for broad T1: the threshold constant is named `SEEKER`; the grant sites pass `"The Divines' Regard - Seeker"` / `"Old Ways - Seeker"` (`PDV__ManagerQuest.psc:14114-14118`); the T1 MGEFs already say `- Seeker`; and every spec already says `- Seeker`.

### Records CORRECTLY named - do not touch
All broad-lane T2 records reading `- Faithful` are **correct as shipped**: `0710BB` Imperial_Civic_T2, `0711B6` Nord_OldWays_T2, `0716C5` Nord_NineDivines_T2, `0711E7` Bosmer_Yffre_T2, `07112D` Orc_Malacath_T2, `071196` Redguard_AncestorSpine_T2, `071211` Breton_Tradition_T2, plus their 12 matching MGEFs.

Also **not** a bug: MGEF *Descriptions* using "the faithful" as ordinary prose ("The Code-Keeper steadies the faithful", "A faithful citizen of the Empire"). That is flavor, not a tier claim. Same for the MESG "outcast-faithful" (`07137D`, Namira). Leave all of it.

---

## 3. Dead copy (retired records)

Hard-wired `False` in the manager - never granted, so no player ever reads these names. Included in the queued write for re-author safety only; **zero gameplay effect**.

| FormID | EditorID | Retired at | Name now | Queued |
|---|---|---|---|---|
| `071069` | `PDV_Bless_Argonian_Hist_T1` | `ManagerQuest:15383` | `Hist Communion - Faithful` | `- Seeker` |
| `071114` | `PDV_Bless_Argonian_Hist_T2` | `ManagerQuest:15384` | `Hist Communion - Devoted` | `- Faithful` |
| `071113` | `PDV_MGEF_Argonian_Hist_T2_ResistDisease` | (same family) | `Hist Communion - Devoted` | `- Faithful` |
| `071211` | `PDV_Bless_Breton_Tradition_T2` | `ManagerQuest:14301` | `Tradition's Footing - Faithful` | (already correct) |

Note the Argonian spec was *internally contradictory*: `"tierCap": "Faithful"` alongside `"displayName": "... - Devoted"`. The queued change resolves it in the direction its own `tierCap` states.

---

## 4. Work completed this session

### 4a. Specs reconciled (DONE, committed to worktree)

The specs were the *reliable* side - only 5 fields were wrong. JSON re-validated, ASCII-clean. Zero `Observant` now remains in any spec.

```
references/authoring/PDV_ArgonianRewardRecords.spec.json | 4 ++--
references/authoring/PDV_DunmerRewardRecords.spec.json   | 2 +-
references/authoring/PDV_RedguardRewardRecords.spec.json | 4 ++--
```

| File | Before | After | Why |
|---|---|---|---|
| Dunmer:137 | `Reclamation Communion - Faithful` | `Reclamation Communion - Seeker` | T1 entry carried a T2 word |
| Argonian:171 | `Retired Argonian Relation - Faithful` | `Hist Communion - Seeker` | wrong tier word **and** base name diverged from ESP |
| Argonian:190 | `Retired Argonian Relation - Devoted` | `Hist Communion - Faithful` | resolves the `tierCap` contradiction; aligns base name |
| Redguard:158 | `Ancestor Spine - Seeker` | `Ancestors' Regard - Seeker` | **base-name drift**: a re-author would have RENAMED the shipped spell |
| Redguard:174 | `Ancestor Spine - Faithful` | `Ancestors' Regard - Faithful` | same |

The Redguard rows are worth calling out separately: the tier word was fine, but the *base* name in the spec (`Ancestor Spine`) never matched the shipped ESP (`Ancestors' Regard`). A re-author would have silently renamed a live, player-visible spell. That is a latent bug the ticket did not know about.

### 4b. ESP write - QUEUED, NOT APPLIED

**Blocked: Skyrim is running.** Identified precisely via the Windows Restart Manager rather than guessed:

```
PID 26356 : SkyrimSE  ->  D:\Wabbajack\modlists\Anvil\Stock Game\SkyrimSE.exe
StartTime : 2026-07-14 10:44 PM  (up 29 min at time of check)
```

houseCARL refused cleanly: `IOException: The process cannot access the file ... the existing file is untouched`. **Nothing was written to the plugin.** The game was not killed (owner presumed mid-smoke-test).

- Backup taken: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp.bak-tiernames-2026-07-14` (637,461 bytes, byte-identical)
- Queued: one `housecarl_bulk_apply`, `target=Devotion.esp`, `in_place=true`, **8 operations, `Name` field only** - no effects, no magnitudes, no FormIDs, no conditions.
- Verification plan: direct `housecarl_read_record` readback of all 8 Names. That readback IS the proof (per `AGENTS.md` houseCARL rule). No bridge/adapter/proof-ledger.

**Queued operations:**

| FormID | Type | Name -> |
|---|---|---|
| `071071` | SPEL | `The Divines' Regard - Seeker` |
| `071073` | SPEL | `Old Ways - Seeker` |
| `0716C4` | SPEL | `Faith of the Holds - Seeker` |
| `07106F` | SPEL | `Reclamation Communion - Seeker` |
| `071069` | SPEL | `Hist Communion - Seeker` |
| `071156` | MGEF | `Reclamation Communion - Seeker` |
| `071114` | SPEL | `Hist Communion - Faithful` |
| `071113` | MGEF | `Hist Communion - Faithful` |

**To resume:** close Skyrim, then re-run the single `bulk_apply` + readback. No other prerequisite. Records are Name-only, so no recompile and no new save is required for these 8.

---

## 5. OPEN DECISION 1 - Dunmer `Reclamation_T2` (`071159`)

A **live** broad-lane reward named `- Devoted` while its six sibling broad-T2s all say `- Faithful`.

- Grant site `PDV__ManagerQuest.psc:14831` - `broadReclamationFaithful = isDunmer && GetPatronState() == PATRON_STATE_BROAD && ReclamationFocusCount >= 6`. That is unambiguously the broad lane, `Faithful` gate.
- But `PDV_DunmerRewardRecords.spec.json:151` **deliberately** declares `"tierCap": "Devoted"` and `:154` `"displayName": "Reclamation Communion - Devoted"`. Spec and ESP are *self-consistent*.

So this is either **(a)** an intentional Dunmer exception to the broad-lane cap, or **(b)** the last piece of this bug. I did **not** touch it - changing a live player-facing name against an explicit spec declaration is not a call to make silently.

Affected if changed: SPEL `071159`, MGEF `071157`, MGEF `071158` (all read `Reclamation Communion - Devoted`), plus spec `:151` `tierCap` and `:154` `displayName`.

**Recommendation:** align to `- Faithful`. The broad lane demonstrably caps at 50 for Dunmer exactly as for the other six races, and a lone "Devoted" on a lane with no Champion rung is the same player-facing lie the T1 bug tells.

## 6. OPEN DECISION 2 - three conflicting tier vocabularies in the live scripts

The Papyrus tier-label helpers do not agree with each other or with `app.js`:

| Location | tier 1 -> | tier 2 -> |
|---|---|---|
| `app.js` (shipped UI) | `Seeker` | `Devoted` / broad `Faithful` |
| `PDV_DiegeticDirector.psc:497, 510` | **`Faithful`** | `Devoted` |
| `PDV__ManagerQuest.psc:15716-15718` (`GetBroadLaneStandingLabel`) | **`Observant`** | `Faithful` |
| `PDV__ManagerQuest.psc:15736-15745` (`GetBroadLaneNextThresholdText`) | **`Observant`** at 3 acts / 25 pts | `Faithful` |
| `PDV__ManagerQuest.psc:14114-14118` (grant-site labels) | `Seeker` | `Faithful` |

`PDV_DiegeticDirector.psc:497` mapping tier 1 to `"Faithful"` is the sharpest contradiction: `app.js` maps tier 1 to `"Seeker"`.

Under the two-ladder model the broad helpers should return `Seeker` / `Faithful`, and `Observant` should disappear entirely from player-facing strings. (`GreenPactCompliance` at `ManagerQuest:23373` also returns `"Observant"`, but that is a **different axis** - the Green Pact band Apostate/Lapsed/Observant/Strict - and is **not** in scope. Do not sweep it.)

**Deliberately deferred, not forgotten.** This means editing `PDV__ManagerQuest.psc`, which is (a) flagged as the file parallel Codex `commit -a` sweeps silently revert, and (b) requires a recompile the owner cannot run mid-smoke-test. It wants its own scoped pass with a fresh-save proof, not a bundle into a Name-only ESP fix.

---

## 7. Proof boundary

- **Proven by direct houseCARL read of the live ESP:** every Name value quoted in sections 1-3.
- **Proven by live-source grep:** every `.psc` line/gate cited.
- **Applied and verified:** the 5 spec `displayName` edits (JSON parse + ASCII check).
- **NOT proven:** nothing in this report has in-game runtime proof. The 8 queued ESP edits are **not yet written**. No claim is made that any of this is player-verified.
- **Verification owed on resume:** `housecarl_read_record` readback of the 8 changed Names; optionally one in-game glance at a broad-lane T1 blessing in Active Effects to confirm the SPEL and MGEF finally agree.

## 8. Suggested triage labels

`bug` / `player-facing-copy` / `blocked-on-owner` / `needs-decision`

---
---

# PART B - Curated-Signal Dispatch: 37 Signals That Can Never Fire

**Date:** 2026-07-14
**Scope:** `live-source/Scripts/Source/PDV_Deity_*.psc`, `PDV__ManagerQuest.psc`, `tools/pdv_reserved_signals.json`, `PDV_STANDARDS.md`
**Status:** Audit COMPLETE. Prevention rules LANDED. **No signal code touched** - the wire/cut list awaits owner rulings.
**Evidence basis:** git pickaxe over all history (`-G` on deity-bound dispatch patterns), live-source grep, CSV/matrix/contract-ledger reads. No runtime/in-game proof claimed.
**Full forensics:** `references/authoring/PDV_CuratedSignalDispatch_Forensics_2026-07-14.md` (section 9 is the authoritative decision list).

---

## B0. TL;DR for the reviewer

37 curated deity signals are **declared + scored + (usually) phrased, but never dispatched**.
No caller of `AwardCuratedSignal[Scaled]` exists for any of them, so their piety can never
fire. `node tools/pdv_signal_e2e_gate.mjs --dispatch-coverage-only` reports
`123 declared+scored / 86 dispatched / 37 undispatched` - and **PASSes**, because all 37 are
parked in `tools/pdv_reserved_signals.json`.

The originating premise was "several of these (Shor, Leki, Talos) *were* wired, so something
dropped them."

**Half true, and the half that's false is instructive.**

| Premise claimed | Actually true |
|---|---|
| Shor / Leki / Talos were all wired and got dropped | **Shor and Talos yes** (via `SIGNAL_ANCESTOR_SPINE`, removed 2026-07-14 by `652a5fe3`). **Leki never was.** |
| One bug | **Two.** 5 REGRESSIONS (had a caller, lost it) + 32 OMISSIONS (never had one). |
| All 37 are 3-of-4 layers | **6 are 2-of-4** - Syrabane x5 and `Zen.CIVIC_SERVICE` have no display phrase either. |
| The 37 are a to-do list | The reserved ledger is a **silencer**: 33 -> 37 in 8 days (6 burned by wiring, 10 added by parking). |

**Why Leki "feels" wired:** `PDV_Boethiah.SIGNAL_HONORABLE_DUEL` - the *same signal name* - has a
real dispatch (`HandleBoethiahHonorableDuel`, fed by brawl victories). A duel signal genuinely
does fire in play. It is never Leki's. Leki's const (2602) and Boethiah's (2002) also sit in
colliding ID ranges with Syrabane's (2001-2005).

---

## B1. Root cause: three of four layers are free, the fourth is a design

A curated signal has four layers:

| # | Layer | Lives in | Cost |
|---|-------|----------|------|
| 1 | `Int Property SIGNAL_X = N AutoReadOnly` | `PDV_Deity_<God>.psc` | trivial |
| 2 | `ScoreCuratedSignal` DELTA branch | **same file** | trivial |
| 3 | `HumanizeCuratedSignalReason` phrase | `PDV__ManagerQuest.psc` | trivial |
| 4 | **A real caller of `AwardCuratedSignal[Scaled]`** | a detector across `PDV_PlayerEvents` / `PDV_ActionRouter` / `PDV_EventBus` / manager | **design work** |

Layers 1 and 2 are not merely cheap - **they are the same file, and that file IS the
deliverable.** A task of the form "design God X's signal set" *produces* `PDV_Deity_X.psc`.
Declaring and scoring is what finishing that task looks like. Layer 4 is a second task nobody
opened.

Caught in the act: commit `9840ec4c` ("test(signal-floor): close co-test smoke evidence")
added **five Syrabane constants, five DELTA branches, and zero callers.**

The design/build split institutionalised it. `PDV_SessionHandoff_DeitySignalRemap_2026-07-08.md`
spends ~270 lines on section 2 "Per-race locked design" (the const/score/phrase spec) and
**16 lines** on section 3 "Build backlog" (the detectors) - six bullets, no owner, no date, no
status marker. Half of it is still open.

And because the design pass never touches the detector layer, it cannot discover that a signal
is **unbuildable**: `IsCombatSessionOrigin` covers origins 4-8 only, so **Nord, Imperial, Breton,
Altmer and Redguard get no combat session at all.** Every combat-flavoured signal specced for
Shor, Tsun, Stuhn, Leki and Talos was undeliverable the day it was written.

The project already has a name for this - **"phantom declarations"** (`7368c87f`: *"Every counted
type now fires in-game; no phantom declarations"*). **This is the eighth recurrence of the class
since June**, and the 2026-07-08 wired-vs-stub review already tagged Leki's duel, Malacath's
exile-return and Tu'whacca's vampire-reentry as `[INERT]`. The response to that review was a
design pass that produced five more.

---

## B2. The 5 REGRESSIONS (proven, with commits)

Method: deity-bound pickaxe over every tracked `.psc` in all history -
`git log --all -G"AwardCuratedSignal[A-Za-z]*\(PDV_<God>, PDV_<God>\.<SIGNAL>"`.

| Signal | Wired by | Killed by |
|---|---|---|
| `PDV_Shor.SIGNAL_ANCESTOR_SPINE` (3 call sites) | `12fa6aef` 2026-06-24 "Build Nord ancestor spine parity" | **`652a5fe3` 2026-07-14** "pantheon parity and substrate pacing" |
| `PDV_Talos.SIGNAL_ANCESTOR_SPINE` | `0c833597` 2026-06-24 "Build Imperial spine parity" | **`652a5fe3`** |
| `PDV_AuriEl.SIGNAL_ANCESTOR_SPINE` | `000c868d` 2026-06-24 "Build Altmer spine parity" | **`652a5fe3`** |
| `PDV_Magnus.SIGNAL_ANCESTOR_SPINE` | `22dfa0c5` 2026-06-24 "Build Breton spine parity" | **`7368c87f`** 2026-07-12 |
| `PDV_Julianos.SIGNAL_LAWFUL_ORDER` | present since >= `cd9ed5e7` 2026-06-07 | **`69905e9c`** 2026-07-12 "Prepare Breton two-axis smoke pass" (re-pointed in place to `PDV_Mara.SIGNAL_MERCY`) |

**Every one of the 5 removals was intentional and defensible.** The defect is that each left the
const, the score branch and the phrase behind - so a deliberate design change silently
manufactured five new "known gaps." Confirmed lossless: the spine acts were **converted, not
deleted**. `HandleSubstrateActionEvent` now routes a Nord hearth/sleep act to
`RecordAncestralRestScaled` -> substrate **metric** -> tier -> Prisma journal row, awarding **no
deity piety by design** (`PDV_SubstratePacingContracts.json`: `"pietyNeutral": true`).

## B3. The 32 OMISSIONS

Never had a deity-bound dispatch in any tracked commit. Most arrived pre-formed in baseline
*imports* of the untracked MO2 tree (`d551d219`, `6bd9b123`) - **so git cannot show the authoring
moment, and no diff ever showed a signal being added without a caller.** That blind spot is part
of the bug.

Two blind spots no gate currently checks:
- **Phrase coverage** - 6 of the 37 have no `HumanizeCuratedSignalReason` arm.
- **Reachability** - the 7 `SIGNAL_CIVIC_SERVICE` consts are **unreachable by construction**:
  `AwardImperialCivicFamilySignal` is a 5-arm branch and each arm emits that god's *domain*
  signal (`Mara.MERCY`, `Stendarr.LAWFUL_ORDER`, `Zenithar.HONEST_WORK`, `Arkay.DEATH_DUTY`).
  Only Akatosh's arm emits `CIVIC_SERVICE`. Dibella, Julianos and Kynareth have **no arm at all**.

---

## B4. Decision list

> **This list is the CORRECTED one.** A first pass produced a wire/cut table from a code-only
> reading; an adversarial re-check against the current architecture killed three of its cuts. See
> PART C - the failure was identical to the one PART A's ticket walked into.

**CUT - confirmed safe (13)**

| Signals | Why it holds |
|---|---|
| 4x `SIGNAL_ANCESTOR_SPINE` (Shor, Talos, AuriEl, Magnus) | Acts converted to substrate metric (B2). Dead code. **Also fix `PDV_SpineStackRegistry.csv`** - its Imperial/Altmer/Nord rows still claim these lanes are live. Leave the Dunmer/Redguard rows alone; those are wired. |
| 7x `SIGNAL_CIVIC_SERVICE` | **Strongest cut.** Unreachable by construction, and it is the project's own written recommendation, 7x over, since 2026-07-06. |
| `Julianos.SIGNAL_LAWFUL_ORDER` | Its ledger condition ("remove IF study credit stays on the likes/dislikes path") **verified met**: Julianos has CSV rows 340/341/342 (+0.5, cap 3) and 344. Stendarr owns `LAWFUL_ORDER` in the civic router. |
| `Shor.SIGNAL_HONORABLE_BATTLE` | `Nord.md:58` ("fair kills please Shor, Tsun and Stuhn") is **already kept** by the CSV for all three, with caps (0.5/cap3, 0.75/cap2, 0.5/cap3). Wiring it would double-pay a kept promise. |

**DO NOT CUT - first-pass errors (8)**

| Signals | Why the cut must not land |
|---|---|
| **5x Syrabane** | **`PDV_BetaContract.csv` BC-0153, status `BETA`**, contracts exactly this lane (ward absorb +15%, post-ward spell cost -10%, College recognition). The five signals are its scaffolding. Syrabane is a fully built, offer-eligible patron (T1/T2/T3 blessings, formal offer, medallion, roster-locked). Cutting = the only offer-eligible patron in the mod with **zero** curated lanes. |
| **2x Stuhn** (`MERCY_GRANTED`, `JUST_SPOILS`) | The **2026-07-13 pantheon-parity lock** (`PDV_TargetEndStates_1.0.md:618,649`) - one week *newer* than the ledger note - promotes Shor/Tsun/Stuhn to *focusable Old Ways patrons with their own offer, rewards and neglect*. Stuhn's dispatch is 1/3. |
| `Trinimac.FALLEN_GOD_ORTHODOXY` | The ledger says it verbatim: *"Rare-by-design frequency, **but must fire**."* The live lane is **Altmer** (Thalmor Orthodox Champion, `TargetEndStates:818`), not the Orc anti-promise. Dispatch is 0/2. |

**CUT - needs an explicit "we are not shipping this beat" ruling (8)**

`Shor.SOVNGARDE_VALOR`, `Tsun.ENDURANCE_VIGIL`, `Sithis.VOID_MILESTONE`, `Akatosh.COVENANT_MILESTONE`,
`Xarxes.RECORD_KEEPING`, `Xarxes.LEDGER_RESTORED`, `Magnus.ARCANE_RECOVERY`, `Dibella.GRACE`.

Mechanically safe, and the double-credit evidence holds (MQ304 pays Shor **+S** and Tsun **+C**;
DB11 pays Sithis **+C milestone**; Xarxes/Magnus already take paid CSV book/tome rows). **But these
are deferrals with named hooks, not vestigial duplicates** - cutting is a decision to abandon those
beats, not hygiene.

**WIRE - safe (6)**

`Tuwhacca.VAMPIRE_REENTRY` (one-shot latch; its flag `PDV.Redguard.VampireReentryNeeded` is written
twice and read **zero** times - cheapest real win), `Malacath.EXILE_RETURN` (one-shot latch),
`Magnus.SHARED_PACT_MEMORY` + `Xarxes.SHARED_PACT_MEMORY` (one dawn function; named Bosmer/Dunmer
parity gap), `Trinimac.ALTMER_ORTHODOX_PRESSURE`, `Leki.HONORABLE_DUEL` (Leki has **no kill row in
the CSV at all** - a combat-honour god with zero combat income, so this promise is genuinely unkept;
needs `IsCombatSessionOrigin` widened to Redguard).

**WIRE - blocked pending ruling (2)**

| Signal | Blocker |
|---|---|
| `Tsun.ADVERSITY_SURVIVED` (+2.5) | **ADR-0001 broad-pool amplification** - see B5. |
| `Talos.PROTECT_WORSHIPPER` (+4.0) | `PDV_TargetEndStates_1.0.md:690`: *"Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence."* A Thalmor-kill detector sits directly on the forbidden surface. |

---

## B5. The pacing finding (and a correction worth reading)

**You cannot blow the daily cap.** `PIETY_DAILY_MAX_DELTA = 4.3` is a **hard clamp** applied at dawn
*after* all signals accumulate (`ClampValue(pietyToday * GAIN_RATE_SCALE 1.32, -cap, cap)`,
`PDV__ManagerQuest.psc:588,592,11277`). Raw delta is not the risk. An earlier draft of this audit
claimed otherwise; that claim is **retracted**.

**The real risk is the broad-pantheon pool.** `AwardPietyInternal` (`:12337`) **auto-opens a
broad-pantheon event scope** when none is open, then calls `AccumulateBroadPantheonDelta`. So every
curated award on a pool-eligible deity (Kyne, Shor, Tsun, Stuhn, Talos, Mara, Arkay, Dibella + the
Imperial Eight) feeds the broad pool, which keeps the **strongest applied delta per logical event**
(ADR-0001).

Precisely: combat **already** feeds the Nord Old Ways pool today (`AwardPietyFromLikesDislikes`
routes through the same `AwardPietyInternal`), contributing `max(Shor 0.5, Tsun 0.75, Stuhn 0.5) =
0.75` per kill. Wiring `Tsun.ADVERSITY_SURVIVED` at 2.5 would raise that to ~2.5 - roughly **3.3x** -
converting ordinary fighting into Old Ways devotional standing. That is an **amplification of an
existing channel, not a novel leak**, but it is a doctrine call for ADR-0001 and it is the
highest-leverage decision in this bug.

---

## B6. Work completed this session

**Landed:**
- `references/authoring/PDV_CuratedSignalDispatch_Forensics_2026-07-14.md` - full forensics; section 9 is the authoritative decision list; the superseded first-pass reasoning is retained and marked RETRACTED where it was wrong.
- `PDV_STANDARDS.md` **§2.7 "Phantom declarations"** - the four-layer rule, grep-checkable in a pre-commit hook: *no commit may add `Int Property SIGNAL_X` without an `AwardCuratedSignal` call site in the same commit*, plus the mirror rule for removals.
- `PDV_STANDARDS.md` **§5.2 "Reserved ledgers are debt, not documentation"** - non-increasing ledger; entries carry `decision`/`owner`/`expires`; `retired` becomes a first-class terminal state distinct from `reserved`; *"a ledger reason is a snapshot, not an authority - re-check it against the newest design lock"*; *"before cutting, grep the contract ledgers."*
- `PDV_STANDARDS.md` **§5.1 amendment** - a gate citation is void if the gate passes *because* of a waiver covering the thing being claimed.

**NOT done, deliberately:** no signal was wired, no const deleted, no copy rewritten.

## B7. Mandatory implementation conditions (any cut)

1. **Delete the matching `tools/pdv_reserved_signals.json` entry in the SAME commit.** The gate FAILs
   on a stale entry (its README: *"now dispatched **or no longer declared** - also FAILs"*).
2. **Cut scope = `SIGNAL_*` const + `ScoreCuratedSignal` branch + display phrase. LEAVE the `DELTA_*`
   `Auto` floats.** `SIGNAL_*` is `AutoReadOnly` (compile-time const, not save-baked, free to delete);
   `DELTA_*` is `Auto` (save-persisted) - removing it buys nothing but Papyrus log noise.
   Deletion order: phrase -> score branch -> const (else the compile breaks).
3. **Fix `references/authoring/PDV_SpineStackRegistry.csv`** - stale since `652a5fe3`.
4. Run `pdv_signal_e2e_gate --strict-curated-signal-dispatch` **and**
   `pdv_deity_signal_remap_adversary_check` before and after.

## B8. OPEN DECISIONS (5)

1. **ADR-0001 / broad pool.** Should a curated signal on a pool-eligible deity feed the broad pantheon
   pool at all? Today it does, automatically. Governs `Tsun` and every future Nord/Imperial signature
   signal. **Highest leverage.**
2. **Talos.** Is there an authored-defiance (quest-stage) route for "protect a Talos worshipper", or
   does `Nord.md:60` / `Imperial.md:60` copy get softened to match `TargetEndStates:690`?
3. **The 8 "abandon the beat" cuts.** Explicit yes/no. Design calls, not hygiene.
4. **Spine doctrine parity.** Malacath, Tu'whacca and Azura *still* pulse deity piety from
   substrate-ish contexts while Nord/Imperial/Altmer/Breton no longer do. Authentic god lanes, or is
   pantheon parity half-applied?
5. **Leki.** Build the duel detector to the `Redguard.md:58` spec (no sneak opener, no follower assist,
   one-handed, fought to the end), or soften the copy?

## B9. Proof boundary

- **Proven by git pickaxe over all history:** every regression/omission classification in B2-B3.
- **Proven by live-source grep:** every `.psc` line, gate, threshold and constant cited.
- **Proven by data reads:** CSV rows, quest-matrix rows, `PDV_BetaContract.csv` BC-0153,
  `PDV_TargetEndStates_1.0.md` locks.
- **NOT proven:** nothing here has in-game runtime proof. No signal was wired; no piety was observed
  firing. The decision list is a *recommendation*, not a verified change.

## B10. Suggested triage labels

`bug` / `dead-code` / `player-facing-copy` / `needs-decision` / `prevention-landed`

---
---

# PART C - What the two bugs have in common

These were found independently, by different sessions, in different subsystems. They are the
same bug.

### 1. Both originating premises were FALSE, and acting on either would have shipped a regression

- **PART A:** the ticket said "8 records carry retired names; rename `Faithful` -> `Devoted`."
  Acting on it would have told a **maxed** broad worshipper they were mid-ladder.
- **PART B:** the first-pass audit said "cut Syrabane's 5, Stuhn's 2, Trinimac's 1 - they're dead
  code." Acting on it would have **deleted the scaffolding for beta contract BC-0153** and stripped
  a Champion-eligible patron down to one lane.

In both cases the premise was internally coherent and confidently argued. In both cases the
disconfirming evidence lived in a file the premise never opened.

### 2. Both are "two parallel systems, one mental model"

- **PART A:** two tier ladders - patron (`Seeker/Devoted/Champion`, cap 85) and broad
  (`Seeker/Faithful`, cap 50). They share the T1 word *and* the 50-point gate, so a single-ladder
  model looks right until it silently relabels the broad lane.
- **PART B:** two piety lanes - curated signals, and the likes/dislikes CSV + quest-reaction matrix.
  I nearly wired `Shor.HONORABLE_BATTLE` to keep a promise the **CSV already keeps** (Shor, Tsun
  *and* Stuhn all take capped piety per humanoid kill). That would have double-paid every kill.

**The generalisable rule: before you change a player-facing artifact, enumerate every lane, ladder
or channel that artifact participates in.** Both bugs are what happens when you enumerate one.

### 3. In both, the NEWER authority wins - and the older note is the trap

- **PART A:** the specs were *right* and the ESP had drifted - the opposite of what the ticket assumed.
- **PART B:** the reserved-ledger note (2026-07-06) deferred Stuhn as low-priority "Wave 3"; the
  pantheon-parity lock (2026-07-13) **promoted** Stuhn to a focusable patron. Acting on the older note
  would have amputated the god.

Ledger and spec entries go stale **in both directions**. A "cut" can become contracted content; a
"wire" can become dead. This is now `PDV_STANDARDS.md` §5.2 rule 6.

### 4. They block on the SAME scoped pass - schedule them together

This is the practical payoff of filing them jointly.

- **PART A OPEN DECISION 2** needs `PDV__ManagerQuest.psc` edits to
  `GetBroadLaneStandingLabel` / `GetBroadLaneNextThresholdText` (broad-lane **labels** - currently
  returning the retired word `Observant`).
- **PART B** needs `PDV__ManagerQuest.psc` edits to the `HumanizeCuratedSignalReason` phrases (cuts)
  and to the broad-pool award path (B5, broad-lane **income**).

Both touch the broad-pantheon code in the same file. Both are deferred for the same two reasons PART
A already documented: `PDV__ManagerQuest.psc` is the file a parallel Codex `commit -a` sweep silently
reverts, and both need a recompile the owner cannot run mid-smoke-test.

**Recommendation: one scoped `PDV__ManagerQuest.psc` pass that closes PART A decision 2 and PART B's
confirmed cuts together**, with a single recompile and a single fresh-save proof - rather than two
passes that each risk clobbering the other's edits to the same file.

### 5. Prevention landed this session

`PDV_STANDARDS.md` gained §2.7 (phantom declarations - the four-layer rule), §5.2 (reserved ledgers
are debt, with the "newer authority" and "grep the contract ledgers" rules), and a §5.1 amendment (a
gate citation is void if the gate passes by waiver). §2.7's core rule is deliberately
`grep`-checkable in a pre-commit hook: **the previous seven responses to this bug class were prose,
and prose got waived.**

---
---

# PART D - Reconciliation + Adversarial-Audit Verdicts (2026-07-15) - CURRENT AUTHORITY

Method: every claim in Parts A/B, `PDV_PlayerStateBugs_2026-07-14.md`, and
`PDV_RaceGuide_NexusFinalPass_2026-07-14.md` was (1) re-verified against current main
(post `0ff53544` + `5f9ce950`), (2) adversarially checked against the newest authorities
(BroadPantheonContracts playerFacingBands, BetaContract BC-0153, the 2026-07-13
pantheon-parity lock, AGENTS.md 07-14 ratifications), and (3) settled at the RECORD level
with direct houseCARL reads where docs conflicted. Owner ruled on every open branch
(grill, 2026-07-15). Proof boundary: static + ESP-readback; the runtime half is the six
RC1-RC6 cards appended to `PDV_1_0_CoTest_Runbook_2026-07-10.md`.

## D1. Verdict matrix

| # | Claim (source) | Verdict | Evidence / action |
|---|---|---|---|
| 1 | Broad T1 blessings should read "- Seeker" (Part A) | **PREMISE-INVERTED (stale)** | `5f9ce950` ratified `playerFacingBands {0:Distant, 25:Observant, 50:Faithful}`; "Seeker" is internal/patron-ladder only. 071071/071073/0716C4 were already CORRECT as "- Observant". The queued 8-op write was abandoned. |
| 2 | Remaining tier-word drift on broad records | **TRUE-BUG - FIXED 2026-07-15** | Full 241-spell sweep found 6 live offenders Part A never saw in full: Bosmer/Breton/Orc/Redguard broad T1 "- Seeker" + Dunmer T1 "- Faithful"/T2 "- Devoted". All 6 renamed in-place (backup `Devotion.esp.bak-bandnames-2026-07-15`), houseCARL load-order readback clean, naming audit PASS 241/392/0. Specs realigned in 6 JSONs (uniqueness-asserted, re-parsed, ASCII-clean). |
| 3 | Dunmer Reclamation "Devoted" exception (Part A Decision 1) | **RULED + EXECUTED** | Owner: broad bands everywhere. T1 -> "- Observant", T2 -> "- Faithful"; spec `tierCap` Devoted -> Faithful. |
| 4 | Three conflicting tier vocabularies (Part A Decision 2) | **PARTIALLY RESOLVED; residue queued** | Canon now fixed (broad: Distant/Observant/Faithful; patron: Seeker/Devoted/Champion). `PDV_DiegeticDirector.psc:497,510` still returns "Faithful" for tier 1 -> scoped pass. Gate gap recorded: NO audit validates SPEL tier words (naming audit covers child MGEFs only). |
| 5 | The 37 undispatched curated signals (Part B) | **ADJUDICATED: 21 cut / 8 wire-now / 8 wire-later** | All 37 `pdv_reserved_signals.json` entries annotated with decision/owner/expires (gate PASS, staleLedger empty). Execution: `PDV_HO_ScopedManagerPass_2026-07-15.md`. Leki + Malacath owner-ruled KEEP-WIRE despite guide copy cut (restore copy on landing). Talos PROTECT_WORSHIPPER ruled WIRE via authored rescue routes; `TargetEndStates` :690 wording amended (rescue-with-Thalmor-kills = favor; plain killing != favor). Tsun ADVERSITY_SURVIVED wires only with a RARE detector - curated->pool feeding is ruled INTENDED, rarity is the guard. |
| 6 | Altmer crisis never resolves (PlayerStateBugs #1, CONFIRMED) | **TRUE-BUG (HIGH)** | Re-verified on current main: `ResolveAltmerCrisis` has zero callers incl. MCM; `SCARRED_RESOLVED` unreachable; "Coherence restored" toast can never fire. Every main-quest Altmer loses the discipline blessing permanently. Fix designed in scoped-pass handoff section 4. Runtime card RC1. |
| 7 | Redguard "permanent neglect" (NexusFinalPass #5, "most serious find") | **REFUTED - PREMISE-ERROR** | The three sect P2 lists are populated (Crown/Forebear from MS08 "In My Time Of Need"; Ash'abah from DA11Intro) and organically registered (`PDV_PlayerEvents.psc:1041-1043`). |
| 8 | Redguard neglect "resetters all curated and rare" (PlayerStateBugs #2) | **ALSO WRONG - NOT-A-BUG** | Neither doc found the third lane: qualifying ancestral-rest SLEEP stamps the sect clock (`RecordRedguardAncestralRest` -> `RecordRedguardAncestorSpinePulse` -> `RecordRedguardSectSignal`, once/day), plus repeatable named-undead burden + crypt clears. Neglect binds only after 5 days of NO practice at all; penalty is -3 ResistMagic. Working as intended. RC6 proves the feel. |
| 9 | All five Khajiit Champion signatures missing (PlayerStateBugs #3) | **PARTLY TRUE (4 of 5)** | ESP VMAD reads: `PDV_MGEF_Khajiit_BaanDar_T3_AvoidDeath` "Baan Dar Remembers" EXISTS with `PDV_T3DailyLowHealthSaveEffect` fully propertied (the spec is STALE - the ESP is ahead of it). Khenarthi/Azurah/Rajhin/Alkosh T3s are genuinely stat-only. Note the LOCKED one-save-per-race rule: Baan Dar carries Khajiit's save, so the other four signatures need non-save mechanics if built. Design decision -> issue list. |
| 10 | Nord Shor last-stand save "gone" (PlayerStateBugs #4 / NexusFinalPass #6) | **REFUTED - PREMISE-ERROR** | `PDV_MGEF_Nord_Shor_T3_AvoidDeath` "Shor Remembers" on the live ESP with the save script, 20% trigger, flat HealSpell (Requiem-proofed), full Prisma properties. RC3 proves the fire. |
| 11 | Orc stronghold forge dev-only + HearthHeld double-dead (PlayerStateBugs #5) | **TRUE-BUG** | `HandleOrcStrongholdForge` reachable only from dev objects; craft chain never stamps the life-mode clock; `PDV_SPEL_OrcHearthHeld` synced-False only AND its MGEF confirmed `StaminaRateMult` (Requiem-inert) at the ESP. Fix in scoped-pass section 4. |
| 12 | Altmer orthodox track one-way (PlayerStateBugs #6) | **TRUE-BUG (design)** | All organic movers negative (-5/-20/-25); the positive keys (+15/+20) exist in the lookup table with NO emitter anywhere. Owner input on wire-vs-document requested in scoped-pass section 4. |
| 13 | Breton twin champion boons identical (PlayerStateBugs #7) | **TRUE-BUG (spec + ESP)** | Both = Fortify Magicka +40 / Magic Resist +15, 2 effects each at the ESP. Both claim "copy of the Imperial [God] T3 verbatim" - check the Imperial source records during the fix; the duplication may originate upstream. |
| 14 | Nord dialogue chains absent (AGENTS.md 07-14, in audit scope by ruling) | **REVERSED 2026-07-15: INTENDED (V1 removal)** | The absence is real (houseCARL: ZERO `PDV_DIAL_Nord_*`, ZERO Nord DLBR) but it is the PLANNED V1 build action: `PDV_V2_Backlog.md:34` - "First V2 step is actually a V1 removal: disable/remove these DLBR/DIAL/INFO records from the V1 release ESP. Re-add voiced in V2." Owner confirmed the quartet is the V2-scoped NPC recognition class (Section 21.3 voiced-content non-goal). The ACTUAL defect is stale gate expectations: `pdv_verify.mjs` `PHASE18_NORD_DIALOGUE_CONTRACTS` still asserts the removed records (20 false strict failures) and the AGENTS 07-14 note mislabeled this "pre-existing debt". Fix = descope the verify contracts to V2-expected-absent (rule-5 toolchain edit; needs explicit owner sign-off, requested in the fix plan). |
| 15 | Breton Hidden-Art credits the wrong god (guide claim, fixed by 0ff53544) | **FIXED + CODE-VERIFIED** | Guide now says Magnus; code confirmed: `HandleBretonHiddenArtExposure` awards `PDV_Magnus.SIGNAL_DISCIPLINED_STUDY`. RC5 covers deployed-pex freshness. |
| 16 | "19 never-granted records, owner-confirmed 2026-07-14" (PlayerStateBugs dismissal) | **DISMISSAL STANDS; CITATION CORRECTED** | No such AGENTS.md entry exists. The actual authorities: `PDV_Architecture_v3.md:1577` (ADR-0005 focused T1 = save-compatible artifacts, never granted) + `PDV_DeityBase.psc:410`. Do not "fix" the 19 records. |
| 17 | Spine-parity asymmetry (forensics 3a, unresolvable from evidence) | **RULED: AUTHENTIC LANES** | Malacath/Tu'whacca/Azura pulses are act-specific god lanes, not passive substrate. Ratified in AGENTS.md so no future session "finishes" the parity. |

## D2. Executed this session (all proven)

1. Six-record ESP band write, in place, with per-record houseCARL readback + fresh backup.
2. Six spec JSONs realigned (uniqueness asserts, JSON re-parse, ASCII check).
3. `pdv_active_effect_naming_audit` PASS (241/392/0); `pdv_signal_e2e_gate --dispatch-coverage-only` PASS (123/86/37, staleLedger empty) - before AND after.
4. All 37 reserved-ledger entries annotated (21 cut / 16 wire) with owner + expiry.
5. AGENTS.md: five 2026-07-15 Decisions Log entries (bands, pool-feeding, Talos rescue, spine-authenticity, ledger disposition). `PDV_TargetEndStates_1.0.md` :690 amended.
6. RC1-RC6 runtime cards appended to the co-test runbook (PS-A sitting).
7. `PDV_HO_ScopedManagerPass_2026-07-15.md` written: the single bundled .psc pass (21 cuts, 8 wires with detectors + caps, DiegeticDirector labels, Altmer crisis exit, Orc forge, twin boons, alignment mover).

## D3. Proposed GitHub issues (TRUE-BUG verdicts only - awaiting owner approval, NOT filed)

1. **Altmer: crisis has no exit; discipline blessing permanently lost after Dragon Rising** (high; D1#6)
2. **Orc: stronghold forge path dev-only; HearthHeld never granted + Requiem-inert** (D1#11)
3. **Altmer: orthodox alignment track has no positive organic mover** (design; D1#12 - owner ruled 2026-07-15: small rite mover)
4. **Breton + Imperial: Akatosh's Endurance and Julianos's Insight are identical capstones at BOTH layers** (D1#13 - 2026-07-15 ESP reads prove the duplication originates in the Imperial T3 records; 4 spells affected)
5. **Khajiit: 4 of 5 Champion signature moments are stat-only records** (design; owner ruled 2026-07-15: defer to a design session)

~~6. Nord dialogue chains~~ - **WITHDRAWN 2026-07-15**: reversed to INTENDED (planned V1
removal per `PDV_V2_Backlog.md:34`); the residual fix is descoping the stale
`pdv_verify.mjs` Phase 18 contracts, tracked in the fix plan, not an issue.

Label: `needs-triage`. Repo: `dunhamma/DevotionModSkyrim`. Each issue body should cite its D1 row and the relevant runtime card. Fix designs for all five live in `references/authoring/PDV_HO_ScopedManagerPass_2026-07-15.md` (v2, the true-bug fix plan).

**Owner ruling 2026-07-15: filing is HELD until after the fix pass lands.** This D3 list
is the internal tracker of record meanwhile; re-present for filing at fix-pass closeout
(likely reduced to whatever survives the pass unfixed).

**FIX-PASS CLOSEOUT (2026-07-15, later same day): issues 1-4 are FIXED at source/record
level** (Altmer crisis exit wired; Orc forge routed + HearthHeld granted/converted;
alignment rite mover landed; boons differentiated at both layers) — each still owes its
RC runtime card before the issue would close as verified. Issue 5 (Khajiit signatures)
remains the only open design item. NEW candidates surfaced by the pass, pre-existing and
stash-proven not-this-pass: (a) 14 stale spine-source verify contracts, (b) the remap
adversary breton-hidden-art-champion assert. Recommended issue list if filing now:
Khajiit signatures + the two stale-gate-contract items.
