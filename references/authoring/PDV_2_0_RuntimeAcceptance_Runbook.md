# PDV 2.0 Runtime Acceptance Runbook

Status: LIVING merge-gate authority for `feature/v3-big-update`.

This runbook replaces "smoke test" as a vague completion claim. The module cards remain useful
setup detail, but this file plus `PDV_2_0_RuntimeAcceptance.manifest.json`, the evidence ledger,
and `tools/pdv_v3_runtime_acceptance.mjs` decide whether Gate 1, Gate 2, or the final regression is
closed.

## Proof boundary

Gate 1 evaluates the claim that the extracted 2.0 modules still behave correctly through the
existing MCM driver. Gate 2 evaluates the later MCM revamp. The final gate evaluates the combined
branch. Static/readback evidence cannot fill a runtime-route, player-surface, save/load, or manual
slot. A Papyrus marker cannot fill a visual slot. An unsafe fault-injection run cannot count as
ordinary-gameplay proof.

The 2.0 rebuild is new-game-only. Start each named fresh-game session from the main menu after
relaunching Skyrim; a running game does not hot-swap PEX files.

## Evidence tool

Run from `.claude/worktrees/v3-origin-extraction`:

```powershell
$env:PDV_DEVOTION_ROOT = 'D:/Wabbajack/modlists/Anvil/mods/Devotion-V3Dev'
node .\tools\pdv_v3_runtime_acceptance.mjs --start --commit (git rev-parse HEAD)
node .\tools\pdv_v3_runtime_acceptance.mjs --summary
node .\tools\pdv_v3_runtime_acceptance.mjs --check --gate gate1 --log 'C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log'
```

Record one observation only after performing it:

```powershell
node .\tools\pdv_v3_runtime_acceptance.mjs --record --case nord_core --slot dawn --status pass --note 'Dawn consolidated scratch piety once; Standing and Active piety matched.' --artifact 'Papyrus.0.log'
```

Use `fail` for a reproduced defect, `blocked` for a missing dependency or unavailable environment,
and `not_required` only when the manifest slot genuinely does not apply. `blocked` does not pass a
gate. Every PASS records the tested commit and a concrete observation; do not bulk-promote slots.

## Gate 1 preflight

1. Confirm the worktree is on `feature/v3-big-update`, clean apart from named regenerable scratch,
   and `origin/main` remains an ancestor.
2. Confirm MO2 instance/profile `Anvil` / `Devotion Dev`; enable `Devotion-V3Dev`, disable public
   `Devotion`, and confirm active `Devotion.esp` resolves a V3-only record such as
   `PDV_OriginRuntime_Altmer`.
3. Run the current compile/verifier/readback stack with `PDV_DEVOTION_ROOT` set to V3Dev. Require
   zero FAIL/WARN/TODO, current SEQ membership, and fresh PEX pairs. Record live results rather than
   copying counts from a handoff.
4. Move old Papyrus logs aside, relaunch Skyrim, and start the evidence run. The log used at close
   must be newer than the ledger start time.
5. Set `PDV_GLO_DebugLevel` to `3`, close and reopen MCM, and verify the developer pages appear
   without a save/load workaround. If they do not, stop and record a defect before testing through
   stale pages.

## Session A: fresh Nord core

1. Start a Nord and complete origin initialization. Status must identify Nord and show nonblank
   broad-pantheon state.
2. On `Debug: State & Rewards`, apply target piety to the selected authorized deity. Confirm Active
   piety, Standing, patron mirrors, tier toast, Active Effects, and Book of Days agree.
3. Commit to a patron and perform one real liked deed. Confirm organic accrual, one toast, and one
   Book entry. Controlled piety seeding does not fill the organic slot.
4. Sleep through 06:00. Confirm daily scratch consolidates exactly once and the final standing
   survives save/load.
5. Prime Kyne at low piety, run neglect, and confirm only the contracted Kyne neglect family applies.
   Recover above the gate, rerun reconciliation, and confirm the effect is removed.
6. Submit one controlled Quest Reaction and trigger organic MQ102 stage 160. Each logical act must
   finish once with no duplicate Book entry.
7. Open Survey and the Prisma panel. Confirm correct patron/today/status content and no blank `None`
   field.
8. `culture_bar`: open the Book of Days. Below Standing, confirm a second gauge with the Nord
   ancestor posture label (forgotten/remembered/honored family), pips at even thirds, and a fill
   consistent with the ancestor substrate seeded state. The bar must stay present while a patron is
   committed. (Added 2026-08-26; if Session A already ran, bank this during the final regression.)

## Session B: fresh Khajiit thick adapter

1. Status identifies Khajiit; open all developer pages and reject blank/default-wide values.
2. Run moon observance, cycle lunar posture, seed lunar metric 25, and read the budget.
3. Use Observe the Moons outdoors at night. Wait for the delayed completion and reject a stale-token
   marker or silent no-op.
4. Sleep outdoors and confirm the road-home/outdoor-rest route fires once.
5. `culture_bar`: with the lunar metric seeded to 25 (step 2), open the Book of Days. Below
   Standing, the culture gauge must show the lunar tier label and its fill must sit exactly ON the
   second pip (25 is the mid threshold; the gauges use segment geometry, so 25/75 renders at the
   2/3 mark, not at one third). Raise the metric past 25 and confirm the second pip renders filled.
6. Save/load on the final state and reconfirm lunar/focus state plus player surfaces, including the
   culture gauge value and posture label.

## Session C: fresh Imperial thin adapter

1. Status identifies Imperial; open all developer pages.
2. Apply Concordat defiance and compliance separately. Confirm raw pressure moves in the correct
   direction and committed state changes only at its contracted boundary.
3. Run Talos shrine defiance. Confirm Talos piety and Imperial Concordat pressure both move.
4. Exercise one eligible formal offer and save/load the decision state.
5. `culture_bar`: open the Book of Days at each Concordat posture touched above. The civic culture
   gauge (Civic Steadiness/Discipline/Exemplar label) must be present and unchanged by Concordat
   moves alone -- the culture lane is independent of both the deity instrument and the Concordat
   track. Confirm a civic act, not a Concordat move, is what moves the bar.

## Session D: Altmer regression

1. Grant Auri-El Champion reward, then switch the debug patron to Magnus and grant the same tier.
   Auri-El's reward must leave before Magnus's applies.
2. Activate an eligible Altmer contextual Favor; confirm toast, Player-page line, and Active Effect.
   Clear it, then retry the same family to prove cooldown behavior.
3. Set Broad worship, select Auri-El, apply 50 piety, seed commitment days, and evaluate. The offer
   must be eligible and must name its deity once owner-approved record copy exists.
4. Repeat with Baan Dar. No Altmer formal offer may surface. A tier-reach toast caused by controlled
   piety is classified separately and is not an offer failure.
5. Check Auri-El, Talos, Tu'whacca, Z'en, and Baan Dar public casing anywhere they surface.
6. `culture_bar`: open the Book of Days before and after the Auri-El -> Magnus reward swap. The
   heritage culture gauge (Ordered/Disciplined/Exemplar Heritage label) must be identical across
   the swap -- patron and reward changes must not move or hide the culture lane.

## Session E: race-change reconciliation

1. On a Nord, activate one Nord reward and one Nord neglect effect; save.
2. `player.setrace HighElfRace`, then `MCM -> Settings -> Re-detect origin -> Run now`; sleep through
   reconciliation. Confirm Altmer binding and removal of every unauthorized Nord deity, reward,
   neglect, and mirror.
3. Activate an Altmer reward, change to Khajiit, rerun detection/reconciliation, and prove the same
   prior-race cleanup.
4. Save/load the Khajiit state and confirm no stripped effect returns and no reward double-dips.
5. `culture_bar_switch`: open the Book of Days after each rebind. The culture gauge must re-label
   and re-scale to the new race (Nord ancestor -> Altmer heritage -> Khajiit lunar) with no stale
   posture text and no carried-over fill from the prior race's metric.

## Cross-session presentation and recognition

- One accepted logical act produces exactly one Prisma toast and one source Book entry. A distinct
  tier/milestone may add one Chronicle entry; it does not add a second toast.
- Core reactions omit a source label. Compatibility reactions show the owning option's player name,
  never a plugin filename or internal key.
- With recognition disabled, identity/band changes are silent. Enable friendly and hostile
  recognition and observe one transition of each kind, then disable and reconfirm silence after
  save/load.
- `gauge_sync`: in the Book of Days, the Standing gauge and the culture gauge share one visual
  geometry -- pips at even positions on both tracks, no raw numeral on either, and a posture label
  (existing vocabulary only, never the word "Spine") on the culture gauge. A race whose culture
  payload is empty hides the culture row entirely rather than showing an empty track.

## Compatibility and package acceptance

1. Run the generated package self-test/check and individual-option simulations.
2. On profiles containing their dependencies, exercise AFDI, Once We Were Here, War's Folly,
   Whispers of the Depths, and Daedric Shrines AIO once each.
3. Exercise at least one positive and one negative data-only source.
4. Every accepted compatibility act must preserve the source label through one toast and one Book
   entry. Missing dependencies are `blocked`, not silently `not_required`; public support remains
   open until the corresponding slot passes.

## Performance capture

Capture two fresh ten-minute windows with the same character and logging level:

1. Idle: stand in an unloaded test-safe interior without opening MCM or firing gameplay events.
2. Active: run the fixed Nord sequence of piety write, one organic liked deed, one controlled Quest
   Reaction, one organic Quest Reaction, neglect reconciliation, and dawn.

Require the existing Quest Reaction checker thresholds, no stack dump, no queue overflow, no
`BROAD_SCOPE_ABORT`, and no repeated PDV missing-property or None-reference warning. Record both logs
and the checker output.

## Gate 2 and final gate

Gate 2 starts only after Gate 1 passes. It covers the four shipped MCM pages, immediate developer
page refresh, native ST controls, Experience Mode state/mirror behavior, all three accessibility
controls, localization, cache keys, compile freshness, VMAD, embedded 1080p/4K presentation, and
save/load persistence. The MCM is compiled after the manager.

After Gate 2, rerun the final manifest's critical regression: bootstrap, Nord reward/neglect/dawn,
Altmer negative offer, race-change cleanup, Quest Reaction resume, presentation cardinality,
recognition-off silence, performance, compile/verifier/package gates, and direct readback. Only the
final gate authorizes the PR merge claim.

## Return packet

- `PDV_2_0_RuntimeAcceptanceLedger.json`
- fresh `Papyrus.0.log` for each named session, kept under distinct filenames
- runtime checker JSON outputs
- screenshots for Active Effects, MCM/Survey, toast, Chronicle, Book, panel, recognition, and later
  MCM accessibility states
- exact notes for any `fail` or `blocked` slot
