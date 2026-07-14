# True-Bug Fix Plan + Scoped ManagerQuest Pass (owner-ruled 2026-07-15, v2)

**v2 (2026-07-15 late):** upgraded from a signal-work handoff into the full TRUE-BUG fix
plan after the owner ruled on the remaining design branches: Altmer alignment gets a
small rite mover; Khajiit signature moments defer to a design session; the Nord dialogue
quartet was RE-CLASSIFIED as a planned V1 removal (`PDV_V2_Backlog.md:34`) -- its fix is
a gate descope, not dialogue authoring. Twin-boon duplication proven to originate in the
IMPERIAL T3 records (4 spells affected, not 2).

**One pass, one recompile, one fresh-save proof.** Every `.psc` item below touches
`live-source/Scripts/Source/PDV__ManagerQuest.psc` (or its immediate siblings), which is
the file parallel `commit -a` sweeps silently revert -- so this work is bundled
deliberately and MUST NOT be split across concurrent sessions. Verify additive-only
diffs before committing.

Authority: `handoff/PDV_TierNameDrift_BugReport_2026-07-14.md` Part D (verdict matrix),
`references/authoring/PDV_CuratedSignalDispatch_Forensics_2026-07-14.md` section 9,
AGENTS.md Decisions Log 2026-07-15 entries, and the annotated
`tools/pdv_reserved_signals.json` (every entry now carries decision/owner/expires).

## 0. Phase order (execute top to bottom)

| Phase | Contents | Touches | Gate |
|---|---|---|---|
| P0 | Preflight: sync live-source vs git, read race-sheet boon intents, confirm Skyrim closed | nothing | additive-only diff check |
| P1 | Record-only fixes: twin boons (Imperial + Breton, 4 spells), HearthHeld MGEF conversion | Devotion.esp + specs | houseCARL readback + naming audit |
| P2 | The bundled .psc pass: 21 cuts, 8 wires, true-bug wiring (sections 1-4) | PDV__ManagerQuest.psc + deity scripts + PlayerEvents/EventBus/DiegeticDirector | **Papyrus protocol (section 6)** then compile + gates |
| P3 | Gate descope: Phase 18 Nord dialogue contracts -> V2-expected-absent | `tools/pdv_verify.mjs` (**rule-5: needs explicit owner sign-off**) | strict gate goes 20-failures -> clean without asserting removed content |
| P4 | Proof + closeout: fresh-save smoke cards, ledger burns verified, doc-sync, issue updates | docs | full `pdv_verify --json` |

## 1. The 21 signal CUTS (decision: cut, expires 2026-07-31)

For each: delete the `HumanizeCuratedSignalReason`/`CuratedSignalDriverReason` phrase arm
FIRST (manager), then the `ScoreCuratedSignal` branch, then the `Int Property SIGNAL_X`
const (deity script). **LEAVE the `Float Property DELTA_X Auto` in place** (save-persisted;
deleting buys only log noise). **Delete the signal's `pdv_reserved_signals.json` entry in
the SAME commit** -- the gate FAILs on a stale "no longer declared" entry.

4 spine: Shor/Talos/AuriEl/Magnus `SIGNAL_ANCESTOR_SPINE`.
7 civic: Arkay/Dibella/Julianos/Kynareth/Mara/Stendarr/Zenithar `SIGNAL_CIVIC_SERVICE`.
2 redundant: `Julianos.SIGNAL_LAWFUL_ORDER`, `Shor.SIGNAL_HONORABLE_BATTLE`.
8 owner-ruled beat cuts: `Shor.SOVNGARDE_VALOR`, `Tsun.ENDURANCE_VIGIL`,
`Sithis.VOID_MILESTONE`, `Akatosh.COVENANT_MILESTONE`, `Xarxes.RECORD_KEEPING`,
`Xarxes.LEDGER_RESTORED`, `Magnus.ARCANE_RECOVERY`, `Dibella.GRACE`.

## 2. The 8 near-term WIRES (decision: wire, expires 2026-08-15)

Template = the Boethiah chain (`HandleBoethiahHonorableDuel`, detect->register->bus->
handle->score). **An authored delta is a proposal**: re-check each against the pacing
model; every wire carries an explicit cap.

| Signal | Detector | Cap | Notes |
|---|---|---|---|
| Tuwhacca.VAMPIRE_REENTRY (+4.0) | `OnVampirismStateChanged` cure edge reads the EXISTING `PDV.Redguard.VampireReentryNeeded` flag (written at ~19419/19435, read nowhere) | one-shot StorageUtil latch per cure (Blood-Kin precedent `97ac3065`) | cheapest wire in the set |
| Magnus.SHARED_PACT_MEMORY (+1.0) | new dawn function in `ProcessDawn` chain (template: `RunDawnAwardAltmerAuriElDawn`) | dawn = 1/day inherent | one function serves both |
| Xarxes.SHARED_PACT_MEMORY (+1.0) | same dawn function | same | |
| Trinimac.ALTMER_ORTHODOX_PRESSURE (+1.5) | hook the existing `RouteAltmerOrthodox*` pressure routes | `ConsumeOncePerDaySignal` | rare-by-design |
| Leki.HONORABLE_DUEL (+3.0) | fair-fight conjunction (no sneak opener, hostile, victim level >= player; cf. Dunmer inline at `PDV_PlayerEvents.psc:733`) | `ConsumeDailyRepeatMultiplier` | **prereq: widen `IsCombatSessionOrigin` to Redguard (9)**; restore guide copy (owner-ruled keep) |
| Malacath.EXILE_RETURN (+3.0) | LEGION_EXILE life-mode + `GetOrcStrongholdHoldId` on `HandleStoryChangeLocation` | one-shot latch per burden | restore guide copy |
| Talos.PROTECT_WORSHIPPER (+4.0) | **authored rescue quest-stage route ONLY** (extend `RouteCuratedMilestoneQuestStage`; MS08 already in the Crown/Forebear P2 lists -- pick rescue-outcome stages) | one-shot latch per quest | per 2026-07-15 ruling: rescue-with-Thalmor-kills = favor; plain killing != favor. TargetEndStates amended |
| Tsun.ADVERSITY_SURVIVED (+2.5) | **RARE detector only**: near-fatal reversal (`PDV_CombatNearFatalFlag` machinery in `ResolveCombatSession`), NOT ordinary hard fights | weekly cap (existing near-fatal cap) | pool-feeding is intended; rarity IS the guard. Prereq: widen `IsCombatSessionOrigin` to Nord (0) |

Deferred wires (do NOT build here): 5x Syrabane (owner BC-0153), 2x Stuhn
(pantheon-parity focusable-patron build), Trinimac.FALLEN_GOD_ORTHODOXY (Orthodox
Champion lane). Their annotated entries expire 2026-08-31.

## 3. Vocabulary label fixes (Part A residue)

- `PDV_DiegeticDirector.psc:497,510`: tier-1 arm returns "Faithful" -> must return
  band vocabulary consistent with `GetBroadLaneStandingLabel` ("Observant" at tier 1).
- Sweep the manager's broad-lane label helpers for any remaining "Seeker" player-facing
  string (canon: Seeker is patron-ladder + internal only).
- Do NOT touch `GreenPactCompliance`'s "Observant" (different axis: Green Pact bands).

## 4. TRUE-BUG fix designs (owner-ruled where noted)

### 4a. Altmer crisis exit (HIGH -- D1#6)

`ResolveAltmerCrisis(Bool reassertOrthodoxy, String reason)` (~:9615) has zero callers;
states: NONE=0, DISSONANT=1, QUESTIONING=2, REASSERTING=3, SCARRED_RESOLVED=4;
`IsAltmerDisciplineCoherent` accepts only NONE/SCARRED_RESOLVED. Design (StateTrack
evidence-gate pattern, per the established evidence-days + transition-lockout doctrine):

- **Orthodox exit**: while crisis is DISSONANT/QUESTIONING, each of the EXISTING rite
  handlers (`HandleAltmerDawnSteadiness`, `HandleAltmerOrthodoxCostlyEnforcement`, and
  the orthodox-affirmation prayer route) marks an evidence-day
  (`PDV.Altmer.CrisisEvidenceDay` day-stamped, day+1 encoding per the StorageUtil
  day-key-zero rule). At **3 distinct evidence-days** -> `ResolveAltmerCrisis(true, ...)`
  -> REASSERTING. REASSERTING holds a **2-day transition lockout**, then a dawn check
  promotes to SCARRED_RESOLVED (coherence returns; the shipped-but-unreachable
  "Coherence restored" toast finally fires).
- **Heterodox exit**: at dawn, if crisis has been open **7+ days** AND ThalmorAlignment
  is below the heterodox threshold, `ResolveAltmerCrisis(false, ...)` -> straight
  SCARRED_RESOLVED (the Altmer who lived through it without reasserting; scarred, coherent).
- Evidence counters cleared on resolve; day counts are owner-tunable constants.
- Runtime proof: RC1 flips from bug-repro to fix-proof (blessing strips on MQ104 s160,
  returns after 3 rite-days + lockout).

### 4b. Orc forge + HearthHeld (D1#11)

- **Forge**: in `HandleStoryCraftItem` (ActionRouter ~:208), when the event classifies as
  `EVT_SMITH_ITEM` AND `GetOrcStrongholdHoldId(akLocation) != -1` AND origin is Orc,
  additionally route `RouteOrcStrongholdForge` -> `HandleOrcStrongholdForge` (existing,
  currently dev-only) so quality work at a stronghold forge earns AND stamps the
  life-mode clock. Once-per-day cap via the handler's existing anti-farm.
- **HearthHeld**: P1 converts `PDV_MGEF_OrcHearthHeld_StaminaRate` from Requiem-inert
  `StaminaRateMult +5` to a flat Fortify Stamina pool per the project-wide conversion
  doctrine (records lane); P2 then wires the grant -- `SyncRaceRewardSpell(...)` True
  condition = stronghold life-mode + hearth-return state (mirror the Code-Held spine
  grant shape). Spec + `effectName` updated with the record.

### 4c. Altmer alignment small rite mover (D1#12 -- owner ruled 2026-07-15)

`HandleAltmerDawnSteadiness` and `HandleAltmerOrthodoxCostlyEnforcement` each grant
**+2 ThalmorAlignment, shared once-per-day cap** (`ConsumeOncePerDaySignal
"PDV.Signal.AltmerAlignmentRite"`), so deliberate orthodox practice can HOLD the
position the track punishes. The dead lookup keys `arrest_talos_worshipper` (+15) and
`complete_thalmor_mission` (+20) are DELETED (no vanilla surface; unreachable). Net
drift stays negative for a player who consorts with Daedra and reads banned texts --
asceticism preserved, trap removed.

### 4d. Twin boons -- fix at the IMPERIAL layer first (D1#13, upstream-proven)

ESP reads (2026-07-15): `PDV_Bless_Imperial_Akatosh_T3` and `PDV_Bless_Imperial_Julianos_T3`
are ALREADY identical (both Fortify Magicka 40 via `*_T3_Magicka` + Magic Resistance 15),
and the Breton `Champion_Akatosh`/`Champion_Julianos` copy them verbatim. Four spells, one
duplication. Fix in P1 (records lane):

- **Julianos's Insight keeps** Fortify Magicka 40 + Magic Resistance 15 (insight = magicka; fits).
- **Akatosh's Endurance is re-authored to its name**: read
  `race-sheets/PDV_RaceDesign_Imperial.md` for the authored intent; if the sheet is
  silent, propose Fortify Health +30 + Fortify Stamina +30 + Magic Resistance 10
  (endurance identity, comparable budget) for owner sign-off BEFORE the write.
- Apply identically to the Imperial record and its Breton copy; update both specs +
  `playerFacingText`; regenerate guide tables (`pdv_guide_tables_gen.mjs`) since the
  Nexus articles print these numbers.

### 4e. Phase 18 Nord dialogue gate descope (D1#14 REVERSED -- planned V1 removal)

NOT a dialogue-authoring task. `PDV_V2_Backlog.md:34` records the quartet's removal as
the planned V1 build action. Fix: move `PHASE18_NORD_DIALOGUE_CONTRACTS` in
`tools/pdv_verify.mjs` to a V2-expected-absent posture (assert the records are ABSENT
from the V1 ESP, keep the contract data for V2 re-authoring). **Rule-5 toolchain edit:
requires explicit owner sign-off before execution.** Also update the AGENTS 07-14
"pre-existing debt" phrasing (correction entry already logged 2026-07-15).

### 4f. Deferred by owner ruling (do NOT build here)

- **Khajiit signature moments** (Khenarthi/Azurah/Rajhin/Alkosh): design session first;
  each needs a bespoke non-save mechanic (Baan Dar holds Khajiit's one allowed save).
  Issue #5 stays open with a design card.
- Syrabane x5 / Stuhn x2 / Trinimac orthodoxy wires (section 2 note).

## 5. Proof gates for this pass

`pdv_compile` for every touched script (+ `PDV_MCM` if the manager recompiles);
`pdv_signal_e2e_gate --dispatch-coverage-only` (ledger burns must land with their code);
`pdv_deity_signal_remap_adversary_check`; `pdv_active_effect_naming_audit` (P1 records);
`pdv_verify --json`; fresh-save smoke for at least one cut (phrase gone), one wire
(fires + caps), the DiegeticDirector label, RC1 (crisis exit), and the Orc forge earn.

## 6. Papyrus protocol (owner instruction: "use papyrus optimize after iterating")

Ordering per touched script, no exceptions:

1. **Before ANY .psc read or edit**: load `housecarl:papyrus-reference` (verify every
   function signature you call -- a copied call is not a verified call) and
   `pdv-papyrus-ck` (compile/deploy guardrails; `pdv_compile.mjs`, never
   `mo2_compile_script`).
2. **Iterate**: implement the section 1-4 changes; keep edits additive-only in
   `PDV__ManagerQuest.psc`; ASCII-only per standards.
3. **After iterating, BEFORE compiling**: load `housecarl:papyrus-optimization` and
   review every touched script, scoped to the changed functions plus any event handler
   they hang off. Specific hot spots this pass creates:
   - the new crisis evidence-day checks run inside dawn + rite handlers -- no
     `Game.GetPlayer()` in loops, cache the actor;
   - `HandleStoryCraftItem` gains an Orc branch -- it fires on EVERY craft event for
     every race; the origin gate must be the FIRST check and cheap;
   - the 8 new wire handlers must not add `RegisterForUpdate` loops or uncached
     `GetFormFromFile` calls -- follow the Boethiah template exactly;
   - the 21 cuts REMOVE code -- confirm no orphaned helper survives as dead weight.
   Classify each finding broken/suboptimal/clean and fix before compile.
4. **Compile + deploy** via `pdv_compile.mjs`; recompile `PDV_MCM` if the manager
   recompiled (pex-freshness rule); then the section 5 gates; then fresh-save smoke.
