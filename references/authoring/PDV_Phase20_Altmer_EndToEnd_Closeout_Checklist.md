# PDV Phase 20 Altmer End-to-End Closeout Runbook

**Created:** 2026-06-06
**Status:** First single-race end-to-end pre-beta closeout walkthrough
**Owner:** Operational companion to the canonical contracts in
`references/authoring/PDV_Phase20_NoInGameProof_Gates.json` (Altmer
`immersiveHookContracts` + `devProofContracts`),
`references/authoring/PDV_Phase20AltmerImplementationCosting.manifest.json`,
`PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceAcceptanceRubric.md`, and
`PDV_Phase20_PreBetaManualChecks_Runbook.md`.

## Why this file exists

The gates packet already specifies *what* the real Altmer hooks are
(`immersiveHookContracts`) and keeps the QASmoke ACTI shims as
`devProofContracts`. This runbook does not redefine that — it is the
**execution sheet** that drives Altmer from `Fail - runtime/manual proof
deferred` to a `Pass` verdict once, so the per-race wall-clock cost stops being
a guess. The most important output is the **Time Log** at the bottom: it
converts the beta-feel date estimate from a range into a measured number.

The contracts are the spec. This sheet is the order of operations plus the
clock.

## Altmer real hooks (from `immersiveHookContracts`)

| signalId | hookClass | routeTarget | QASmoke shim |
|---|---|---|---|
| `altmer-dawn-study-coherence` | voluntary-devotional-surface-or-context | `RouteAltmerDawnSteadiness()` | `PDV_REFR_AltmerDawnSteadinessSignal` |
| `altmer-lorkhan-crisis-pressure` | curated-quest-stage-state-context | `RouteAltmerLorkhanPressure(tier, sourceId)` / `RouteAltmerCrisisSource(crisis, sourceId)` | `PDV_REFR_AltmerLorkhanPressureSignal` |
| `altmer-orthodox-costly-enforcement` | curated-quest-stage-dialogue-or-faction-context | `RouteAltmerOrthodoxCostlyEnforcement()` | `PDV_REFR_AltmerOrthodoxCostlyEnforcementSignal` |

Key contract facts to honor (do not re-derive — read the contract):

- **Dawn/study** is the one *voluntary* surface: `PDV_EventSignalActivator` is
  allowed only for authored study/dawn objects; otherwise use player-alias
  time/location context + curated study/shrine FormLists. Anti-farm: one
  accepted signal/day.
- **Lorkhan crisis pressure** has **no visible pressure object** — it is
  published from curated quest-stage/state context via PO3 `QuestStageChange`
  or CK quest-stage/script-event fragments (Main Quest, Sovngarde/Shor,
  Companions, marriage/homestead, Talos/Thalmor, curse milestones). Anti-farm:
  one-shot marker per crisis source + pressure cap/cooldown.
- **Orthodox costly enforcement** comes from curated quest-stage/faction/
  alignment readback, never ambient dialogue parsing. Anti-farm: one active
  orthodox-cost family.
- All three: `newMeshRequired: false` — no new art; vanilla/PO3 sources only.

For the **first** closeout, prove **one** crisis source rather than all of
them. Recommended: a self-contained curated milestone such as the marriage /
homestead beat — it fires once, is easy to reach on a test save, and exercises
the one-shot crisis path end to end. The other crisis sources then clone it.

## Step 0 — Preflight gates (automated, green before any Skyrim)

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
```

- [ ] Content verify clean
- [ ] Strict Altmer + race-costing verifier clean (record the PASS/WARN/INFO baseline)
- [ ] Runtime checker lists the Altmer routes

## Step A — Author the three real hooks (CK/Codex — the real cost)

Author against the three `immersiveHookContracts`, not the proof ACTIs. Keep the
`devProofContracts` (QASmoke shims) in place as the regression harness.

- [ ] Back up `Devotion.esp` (timestamped).
- [ ] **Dawn/study (voluntary):** wire the authored study/dawn surface (or
  player-alias dawn/location context + curated FormList) to
  `RouteAltmerDawnSteadiness()`; enforce one-accepted-signal/day.
- [ ] **Crisis pressure (passive, no object):** wire the chosen curated crisis
  source (recommend marriage/homestead first) via PO3 `QuestStageChange` or a
  CK quest-stage fragment to `RouteAltmerCrisisSource(...)` /
  `RouteAltmerLorkhanPressure(...)`, with a save-persistent one-shot marker per
  source.
- [ ] **Orthodox cost (passive):** wire one curated quest-stage/faction source
  to `RouteAltmerOrthodoxCostlyEnforcement()`; no ambient dialogue parsing.
- [ ] Compile touched source; refresh SEQ.
- [ ] Re-run Step 0 gates; confirm still green.

## Step B — Positive runtime proof (the quick test)

Archive the old Papyrus log, then on a fresh **Altmer** save (Auri-El/Magnus
scholar):

- [ ] Use the **real** dawn/study hook (not QASmoke); confirm
  `RouteAltmerDawnSteadiness` fires and a favor is recorded.
- [ ] Reach the chosen **crisis** milestone naturally; confirm the crisis route
  fires **passively**, state moves, and the surface message shows once.
- [ ] Trigger the **orthodox-cost** source; confirm its route fires.
- [ ] Re-trigger each: confirm the one-shot/anti-farm guards hold across
  save/load.
- [ ] `node .\tools\pdv_phase20_runtime_check.mjs --race altmer` passes (and
  `--strict-manager`).

## Step C — Negative / rejected-hook sweep (play normally)

Each must stay **silent** (`rejectedContext` from the contracts):

- [ ] Ordinary travel, ordinary friendships, settlement play
- [ ] Generic spellcasting, generic College membership
- [ ] Generic helping, generic anti-Thalmor violence
- [ ] Repeated Dragonborn identity (no re-fire after the first crisis)
- [ ] Generic Daedric contact, vampire power route
- [ ] **Wrong-origin:** repeat an accepted hook on a non-Altmer save — silent
  except debug rejection.

Any ordinary action that scores is an anti-farm failure → fix the gate,
recompile, re-test. Log it.

## Step D — Survey / status legibility

- [ ] After a real accepted hook, Survey Devotion / MCM Player page explains
  crisis, pressure, last favor, alignment, scar/recovery, and curse posture in
  fiction terms.
- [ ] `MarriageBeat` reads as Marriage / Mortal Continuity, not anti-Mara.
- [ ] No route IDs, raw counters, or debug labels in player copy.

## Step E — Edge build

- [ ] Exiled vampire: curse state surfaces as capped/halted, not a stronger build.
- [ ] Werewolf: hard-halt path fires.
- [ ] Cured-vampire scar recognition surfaces.

## Step F — Stack snapshot + feel call

- [ ] Record all simultaneously-active layers: Auri-El foundation, secondary
  focus, active favor, crisis state, pressure source, ThalmorAlignment,
  vampire/werewolf/scar, Daedric modifiers.
- [ ] Reward floor: coherent dawn/study play trends net-positive without
  perfect play.
- [ ] Reward ceiling: Auri-El + one secondary focus + one active favor does not
  over-stack; ThalmorAlignment modifies access/pressure, not a third boon engine.
- [ ] Feel call: can the player say why the crisis/favor happened, why ordinary
  life stayed silent, and whether recovery felt possible? Authored religion, not
  homework?

If balance is off → tune magnitudes, recompile, repeat from Step B. **Count
each tuning pass in the Time Log** — that iteration count decides the
project-wide beta date.

## Step G — Record the verdict

- [ ] Update the Altmer block in `PDV_PreBetaRaceGateLedger.md` to `Pass`,
  `Conditional` (one named condition), or keep `Fail` with the blocker.
- [ ] Update the matching Altmer evidence slots in
  `PDV_Phase20_ManualEvidenceLedger.json` with real proof notes.
- [ ] If `Pass`: Altmer is cleared for external playfeel testing.

## Time Log (the actual deliverable)

```text
Step A (author 3 real hooks, CK):   ____ min
Step B (positive runtime proof):    ____ min
Step C (negative sweep):            ____ min
Step D (Survey legibility):         ____ min
Step E (edge build):                ____ min
Step F (stack + feel):              ____ min
Tuning passes needed:               ____ (count)   total ____ min
------------------------------------------------
TOTAL Altmer closeout:              ____ min / ____ hrs
```

## Issues Log

```text
(record anything that fired when it shouldn't, any copy that read as debug,
any reward that felt too loud, and how it was fixed)
```
