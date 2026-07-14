# Handoff: The Scoped ManagerQuest Pass (owner-ruled 2026-07-15)

**One pass, one recompile, one fresh-save proof.** Every item below touches
`live-source/Scripts/Source/PDV__ManagerQuest.psc` (or its immediate siblings), which is
the file parallel `commit -a` sweeps silently revert -- so this work is bundled
deliberately and MUST NOT be split across concurrent sessions. Verify additive-only
diffs before committing.

Authority: `handoff/PDV_TierNameDrift_BugReport_2026-07-14.md` Part D (verdict matrix),
`references/authoring/PDV_CuratedSignalDispatch_Forensics_2026-07-14.md` section 9,
AGENTS.md Decisions Log 2026-07-15 entries, and the annotated
`tools/pdv_reserved_signals.json` (every entry now carries decision/owner/expires).

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

## 4. Other TRUE-BUG fixes queued to this pass (from Part D verdicts)

- **Altmer crisis exit** (HIGH): give `ResolveAltmerCrisis` (~:9615) an organic caller --
  design intent is that reasserting orthodoxy after a crisis is the rewarded beat; hang it
  on the same P2/quest-stage layer that OPENS the crisis. Zero callers today, incl. MCM.
- **Orc forge**: route organic smithing at a stronghold forge into
  `HandleOrcStrongholdForge` (today only dev objects reach it), so quality work stamps the
  life-mode clock. Fix `PDV_SPEL_OrcHearthHeld` while there: never granted (synced False,
  ~:16071) AND its MGEF is Requiem-inert `StaminaRateMult` (ESP-verified) -- grant it from
  the hearth path and convert the effect per the flat-Fortify doctrine.
- **Altmer positive alignment mover**: the lookup table has `arrest_talos_worshipper` +15
  and `complete_thalmor_mission` +20 with NO emitter anywhere. Either wire emitters
  (quest-stage) or accept one-way drift as design and document it. Owner input wanted.
- **Breton twin boons**: `Champion_Akatosh` and `Champion_Julianos` are byte-identical
  (Fortify Magicka +40 / Magic Resist +15). Differentiate one. Check the IMPERIAL source
  records first -- both Breton records claim "copy of the Imperial [God] T3 verbatim", so
  the duplication may originate upstream.

## 5. Proof gates for this pass

`pdv_compile` for every touched script (+ `PDV_MCM` if the manager recompiles);
`pdv_signal_e2e_gate --dispatch-coverage-only` (ledger burns must land with their code);
`pdv_deity_signal_remap_adversary_check`; `pdv_verify --json`; fresh-save smoke for at
least one cut (phrase gone), one wire (fires + caps), and the DiegeticDirector label.
