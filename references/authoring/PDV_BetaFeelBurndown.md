# PDV Beta-Feel Burndown

**Created:** 2026-06-14
**Status:** Living beta-feel burndown report
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`,
`PDV_BetaFeelReleaseGate.md`, `PDV_InGameTestingNeeded_Runbook.md`, and the
2026-06-14 build-batch handoffs.

## Purpose

This report consolidates the current beta-feel burn from the all-race audit
burndown, the build-batch handoffs, the pre-beta gate ledger, and current
read-only rechecks. It is not a release claim.

Proof boundaries:

- **Machine/readback proof** means the source, ESP, manifest, or verifier can
  see the intended state.
- **Runtime route proof** means Papyrus log markers show the route fired.
- **Manual beta-feel proof** means the tester recorded Survey/status clarity,
  rejected-source silence, stack/Active Effects behavior, and feel notes.

Do not convert one proof type into another. The external beta-feel claim still
requires all ten races plus all sixteen Skyrim-present Daedric Princes in the
readiness evidence.

## Current Snapshot

As of the 2026-07-05 AEST Dunmer closeout, plus the same-day post-closeout
quest-expansion and reachability-gate work (see "Since Dunmer Closeout" below):

| Area | Current state | Evidence |
| --- | --- | --- |
| Daedric Princes | **Pass** for current beta-display gate | `node .\tools\pdv_daedric_beta_gate.mjs` -> `PASS=16` |
| Strict beta-readiness audit | **Pass** | `node .\tools\pdv_beta_readiness_audit.mjs --strict --json` -> `STRICT_GATE_PASS`, `PASS=31`, `WARN=1`, `INFO=2`, blockers `[]` |
| Race beta-feel packets | **10 pass for current manual/runtime packets** | Dunmer manual slots were evidence-recorded 2026-07-05 after in-game closeout; strict audit now reads all ten race slots as recorded |
| Default framework verifier | **Clean; PickLock contract drift reconciled** | `node .\tools\pdv_verify.mjs --json` on 2026-07-05 after the PickLock contract fix -> `FAIL=0, WARN=2, PASS=3512, INFO=68`; `PDV__SM_PickLockNode` now expects retained parent `Devotion.esp:071618` and checks `PDV__SM_PickLockEvent` as a `LockPick` SMEN root under `Skyrim.esm:00005B`. Warnings remain medallion glyph fallback plus SEQ older than the ESP. |
| Content verifier | **Clean** | `node .\tools\pdv_content_verify.mjs` -> `FAIL=0, WARN=0, PASS=1080, INFO=4` |
| Khajiit focused P2 route | **Route-proof pass** | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit` -> PASS |
| Live manager compile | **Clean** | `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` -> `1 succeeded, 0 failed`; bundled verifier stayed `FAIL=0, WARN=2, TODO=0, PASS=3038, INFO=43` |
| Consolidated record-wave readback | **Clean** | `--check-rewards --rewards-spec PDV_ConsolidatedBuildPass_RecordWave.spec.json` -> PASS; Redguard curse-state message-body drift is closed |
| Per-race reward-spec readback | **10/10 pass** | All ten `PDV_*RewardRecords.spec.json` files pass `tools\pdv-phase20-race-author --check-rewards`, including Imperial Concordat track modifiers |
| Nord/Imperial felt-neglect ESP batch | **Machine/readback pass; runtime smoke pending** | `tools\pdv-neglect-esp-author --check` verifies Kyne/Imperial MGEF conversions, four Nord patron neglect spells, and manager VMAD properties; `pdv_verify --strict-neglect-decay` source-gates the lapse-aware runtime |
| Imperial/Nord Talos creed runtime | **Compile pass; debug smoke pending** | Shared `PDV__ManagerQuest.HandleTalosBetrayal` applies focused-Talos `-2/-3` losses with MCM Debug buttons; Imperial also moves raw Concordat standing toward compliance. Organic betrayal detection remains follow-on |
| Integrity harness | **Pass** | `node .\tools\pdv_integrity_harness.mjs` -> `signal_e2e_gate`, `deity_chain`, and `eligibility_reward_coverage` all PASS |
| Requiem penalty conversion | **Backend/readback pass; feltness smoke pending** | `node .\tools\pdv_requiem_penalty_audit.mjs` -> `PASS=44`; Argonian/Breton Health penalties and Imperial preservation still need in-game Active Effects and HP-bar proof |
| Book of Days package sync | **Closed for packaging preflight** | `pdv_book_of_days_audit.mjs` now passes with repo/live `index.html`, `styles.css`, `app.js`, and font hashes matched; `.gitattributes` keeps the two hash-sensitive text assets LF-normalized |

The earlier recheck debt for Redguard curse-state message bodies and Imperial
Concordat track naming is closed. This does not promote any runtime/manual race
packet: it only restores the machine/readback baseline.

## Since Dunmer Closeout (2026-07-05)

These landed after the snapshot table above was first written and are counted as
machine/readback-clean, runtime-smoke-pending. They add depth to the beta build
without reopening any closed race packet.

| Item | Proof boundary | Notes |
| --- | --- | --- |
| Quest-matrix expansion (40-50 quests/deity) | **In-game proven (Sitting 1, 2026-07-05)** | 832 matrix cells / 118 keys / 90 watched quests live; 7 meta-faucet lanes wired; Section A passed across all 8 setstage-able origins incl. the Akatosh/Xarxes wheel; see `PDV_SessionHandoff_2026-07-05_MegaPacketSitting1.md` |
| `EVT_STEAL_ITEM` (362) SM wiring | **In-game proven both sentiment sides (Sitting 1)** | Dunmer like-side (Mephala +0.5/Boethiah +0.25) and Imperial dislike-side (Zenithar -1.0) both fired; retires the last 362 pending flag |
| Foreign-award reachability gate | **In-game proven both directions (Sitting 1)** | Native pantheons score full; off-roster `FOREIGN`/`TOLERATED` gods skip-trace with no piety / no Ledger row (Xarxes full + Akatosh skip under Altmer, inverse under Imperial); reduced `0.4x` applies only to roster-listed tolerated/foreign + Daedric-path faces |
| Dunmer ancestral urn rebuild | In-game proven (Dunmer packet) | Rebuilt as usable MISC item (click-to-pray via OnEquipped), fixing the book-menu CTD; Remiros HD assets bundled self-contained |
| Book of Days + Prisma hardening | **Universal Prisma U1-U9 in-game PASS (2026-07-06); C2 residual beats pending** | Path/gauge rendering fix, cover presentation refresh, escape/hotkey close contract centralized, deity-text normalization; remaining C2 beats are Altmer band, Khajiit Champion pin, Redguard sect Champion toast |
| Redguard orphan VMAD property cleanup | Readback clean; runtime log check pending | Four stale `PDV_Notif_Redguard_*_NeglectTexture` properties stripped from `PDV__ManagerQuest [00C325]`; property count `419 -> 415`; backup `Backups\orphan-vmad-cleanup\Devotion.esp.20260705-170936.bak` |

## Mega Packet Prisma checkpoint (2026-07-05 evening -> 2026-07-06)

The Universal Prisma sheet (U1-U9) is now in-game PASS. The run went slowly because
it caught real player-facing bugs and forced several fix-and-redeploy loops; that is
the packet doing its job. Do not burn down the whole megapacket-smoke estimate from
this alone, because C2 still has three short per-origin beats and Prince V2/Requiem
remain separate. Caught and fixed during the Prisma pass:

| Item | Proof boundary | Notes |
| --- | --- | --- |
| Panel movement filter missed losses | Fixed + merged (72b8b076) | Roster gods with only NEGATIVE recent movement were invisible; panel filter now ORs `HasRecentPietyMovement` (7-day Week ring + driver days), per the owner "Ledger monitors ALL data points" rule |
| Debug patron override/clear left stale rewards | Fixed (aa59daf4) | Override/clear now resync reward spells immediately |
| Imperial lane stripped reused Nord Divine reward spells | Fixed (2af9ba9d) + lint (57509902) | `SyncImperialRewards` granted-then-stripped cross-lane reused SPELs same pass; new `pdv_reward_runtime_order_lint.mjs` guards the class |
| Nord Old Ways roster: Orkey + Dibella | Built + in-game smoke PASS (829bbbfa, 7d40afe7) | Arkay-as-Orkey display override + Dibella offers/rewards/display; Orkey MESG 07161B + SEQ refresh |
| Orkey/Dibella Old Ways neglect | Machine/readback pass; manual Active Effects smoke pending | `PDV_SPEL_Neglect_Arkay` / `PDV_MGEF_Neglect_Arkay` displays as "Orkey's Neglect" with `ResistMagic -5`; `PDV_SPEL_Neglect_Dibella` / `PDV_MGEF_Neglect_Dibella` displays as "Dibella's Neglect" with `Restoration -5`; manager VMAD props and `SyncNordPatronNeglectSpells()` wiring are filled |
| Curated driver copy | Fixed + in-game re-verified (c8a4aa34) | Curated rows name the actual trigger, e.g. "defiant prayer at a Talos shrine", rather than generic "a devotional rite" |
| Watching Prince dashboard/Book of Days | Fixed + in-game re-verified (692396bb, 2f75a860) | Pre-pact Princes show a distinct Watching badge and a named watching-onset Book of Days line |
| Quest-reaction surfacing aggregation | Fixed + in-game re-verified | Quest fires now emit one aggregate toast plus one Book of Days line, not a burst per matrix cell |

Filed from the same pass and still open: `task_387bfc95` slider cap >=1000,
and `task_7dab1ebb` Hircine renounce over-fire/copy. `task_e6904bb3`
Orkey/Dibella neglect debuff is implemented and machine/readback closed, with
manual Active Effects smoke pending. `task_8c27e440` Refuse-goes-quiet is implemented and
machine-gated; manual smoke still needs to confirm no toast/sound/wash and the
pinned refusal chronicle.

Still owed for Sitting-1 Prisma: C2 beat 3 Altmer alignment band, C2 beat 5 Khajiit
Champion pin survives pruning, and C2 beat 6 Redguard per-sect Champion toast. After
that, continue Prince V2 (Section F), C3 only if Prisma changed again, and the
Authoria Requiem felt sweep as separate proof lanes.

## Burned Down

These items are no longer counted as open beta-feel blockers.

| Done item | Proof boundary | Notes |
| --- | --- | --- |
| 9 pure-script HIGH friction/state-gate items | Runtime smoke + compile/readback from build-batch handoff | Orc life-mode gate/evaluator, Redguard HoonDing cap/sect/Ash'abah gates, Breton tradition setup lock, Nord non-Kyne eligibility, Imperial vampire halt, Dunmer curse posture, Argonian near-water Hist, Altmer Lorkhan penalty, Breton WitchcraftExposure decay |
| Neglect vanilla fallback | Runtime smoke | Top-left `Debug.Notification` fallback closes the no-Prisma neglect surfacing floor |
| All-10-race Survey narrator rewrite | Compile/readback from handoff | The raw enum/dev-language Survey surface is no longer an open item in the burn; runtime spot checks remain part of each race packet |
| Nord non-Kyne offer eligibility | Runtime smoke | Offers now fire for non-Kyne pantheon gods; record/copy conformance is tracked separately |
| Khajiit current beta-feel packet | Runtime route + manual/tester evidence | Rajhin edge, Alkosh word-of-power dawn drip, lunar book route, rejection sweep, Survey/status, reward/stack evidence, and optional checks are recorded; final-world placement remains separate |
| Altmer current beta-feel packet | Manual/runtime packet evidence | Current packet is Pass; final-world placement and future verifier hardening remain separate |
| Bosmer current beta-feel packet | Manual/runtime packet evidence plus final Bosmer readback refresh | DA05 accepted branches, rejection sweep, Survey/status, reward stack, Songs of the Green, and Baan Dar Gap passed for the current packet; 2026-06-16 live readback refreshed Baan Dar Gap to SpeedMult +40 for 15s; final-world placement remains separate |
| 16-Prince Daedric beta-display gate | Runtime/manual ledger gate | `pdv_daedric_beta_gate` passes all 16 Princes |
| Likes/dislikes enrichment/codegen landed and source-gated | Compile/readback clean | `pdv_verify` now asserts v8/v3 constants, exact 315-row deity and 160-row Prince generated bodies, and all 31 CSV event IDs in the clear superset. Runtime/new-save reload proof remains open; pending event rows stay inert until routers exist |
| Nord/Imperial felt-neglect ESP batch | Machine/readback clean | Kyne neglect now uses `ResistFrost -8`, Imperial civic neglect uses `ResistDisease -5`, and Nord Shor/Tsun/Stuhn/Talos per-patron neglect spells exist and are wired. Runtime Active Effects/stack proof remains part of the upcoming smoke pass |
| Imperial/Nord Talos betrayal debug path | Compile clean | `PDV_MCM` exposes `Talos betrayal -2/-3`; manager gates on focused Talos, origin, anti-repeat, and Imperial raw Concordat eligibility. Runtime smoke and organic detection are still separate |
| Altmer `PDV_RepTrack_ThalmorAlignment` first record bridge | Consolidated record-wave readback passes | Source routing for the six actions and manual/new-save behavior proof remain open |
| Breton creed-loss spell records and persistent band routing | Breton reward-spec readback passes; handoff claims manager compile/readback | Breach-source quest routing, threshold notifications, recovery routes, and in-game Active Effects proof remain open |
| Altmer/Imperial/Dunmer track emitters wired (2026-06-14) | Compile/readback clean | Altmer ThalmorAlignment now live (banned-texts -5, consort -25, Thalmor-kill -20); Imperial Stormcloak-defiance now lands -20 via the point table + Thalmor-Justiciar-kill -10; Dunmer DLC2 outdoor-shrine twilight prayer. ~6 no-clean-hook actions (arrest/report/help-escape/Thalmor-mission/Orc-oath-break/Redguard-Dawnguard-cure) documented as deferred in `PDV_NextBuildPass_RecordSpec.md` sec.10. **Route-proven 2026-06-14** (Papyrus log): Altmer banned-texts/consort/kill -> raw -75; Imperial defiance -20; Imperial Thalmor-kill -10 (open kill, after a rank-gate fix). Only the Dunmer DLC2 Solstheim shrine remains unobserved (needs Solstheim); full manual beta-feel separate |
| Imperial current beta-feel packet | Manual/runtime packet evidence | Imperial V1 slots 1-7 passed in game on 2026-07-04: assets, Survey/status, stack, formal offer accept/refuse/cadence, broad Tier-2 cap, Talos book pressure, Concordat raw/reorientation, Talos offer gate, civic-service Ledger/Book-of-Days route, wrong-origin rejection, generic-source silence, and final feel. Final-world placement remains separate |
| Dunmer current beta-feel packet | Manual/runtime packet evidence | Dunmer slots 1-8 plus shared Daedric inn-sleep proof passed in game on 2026-07-05: assets, wrong-origin rejection, generic-hook rejection, ash-prayer, Ancestral Hearth home/move-home, Reclamation focus, Good Daedra temple prayer, DA01 Black Star deviation price, Survey/status, stack snapshots, Prisma surfaces, and manual feel. Final-world placement remains separate |
| Mega Packet Sitting 1 (Anvil) | Runtime route + manual evidence (2026-07-05/06) | Section A quest-expansion smoke across 8 origins, E1 day-to-day sweep CSV-exact (craft/knowledge/sleep/transgressions incl. 360/361/362/364/365/368), mechanics confirmed (attribution filter, anti-farm daily cap, dawn bank, race-gate-by-dropout). 4 end-to-end wiring bugs found and fixed+proven same day: 341 OnItemRemoved, 360 menu-hook fallback (SM LockPick dead), 365 caster-side OnSpellCast, 361/364 aiCrime gate. Universal Prisma U1-U9 also PASS; C2 remaining is only Altmer band, Khajiit Champion pin, and Redguard sect Champion toast. |

## Immediate Recheck Debt

These are small but high-priority because they keep the burndown honest.

| Priority | Item | Size | Why it matters |
| --- | --- | --- | --- |
| Closed 2026-06-14 | Redguard curse-state MESG body drift in `PDV_ConsolidatedBuildPass_RecordWave.spec.json` | S | Consolidated record-wave `--check-rewards` now passes |
| Closed 2026-06-14 | Imperial reward-spec track naming/readback | S | All ten per-race reward specs now pass |
| Closed 2026-06-14 | Focused gate bundle rerun | S | Manager compile, consolidated record-wave check, all ten reward-spec checks, default `pdv_verify`, content verifier, and Daedric beta gate all pass |

## Critical Path To Beta-Feel

### 1. Manual Race Evidence -- CLOSED as the long pole

This was the long pole and it is now down. The default machine gates are strong;
after the Dunmer closeout, all ten current race packets have manual/runtime
evidence recorded and the strict beta-readiness audit passes from the current
ledgers. The residual runtime long pole is now the **1.0 Mega Test Packet**
(`PDV_MegaPacket_OneOh_2026-07-02.md`): four sittings covering quest-expansion
smoke (Section A), day-to-day signal sweep (E), Prisma render checks (C), Prince
V2 path-deepening (F), and the Requiem felt sweep (D, Authoria-only). None of
these reopen a closed race packet unless they surface a regression.

| Race | Current state | Remaining proof |
| --- | --- | --- |
| Altmer | Pass | No blocker for current packet; final-world placement separate |
| Khajiit | Pass | No blocker for current packet; final-world placement separate |
| Bosmer | Pass | No blocker for current packet; final-world placement separate |
| Argonian | Pass | No blocker for current packet; final-world placement separate |
| Orc | Pass | No blocker for current packet; final-world placement separate |
| Redguard | Pass | manual/runtime packet 2026-06-19 (8/8 dims); non-blocking follow-ups: vampire earn-halt (content), HoonDing/Leki day-to-day leak fix APPLIED 2026-06-19 (regen+compile+verifier clean; awaiting in-game reconfirm), Arkay shrine cosmetic; final-world placement separate |
| Breton | Pass | No blocker for current packet; final-world placement separate |
| Dunmer | Pass | Current Dunmer packet passed 2026-07-05; final-world placement separate |
| Imperial | Pass | Current Imperial V1 packet passed 2026-07-04; final-world placement separate |
| Nord | Pass | No blocker for current packet; final-world placement separate |

### 2. Build/Depth Work Still On The Feel Path

These remain worth tracking because they affect whether the manual packets feel
complete or merely technically routed.

| Bucket | Remaining work | Size |
| --- | --- | --- |
| Cross-race small-signal texture | Static source gate is closed for v8/v3 generated bodies; still prove expanded likes/dislikes rows on a new save and decide whether pending event rows need router work before beta | L |
| Pre-beta scaling and anti-farm | Per-race magnitude/ceiling pass after rejected hooks and stack snapshots; includes Altmer daily floor, project-wide piety-pulse caps, Imperial Concordat table, and Daedric price recheck | L |
| Next ESP/code depth pass | Orc Witnessed, Redguard Far Shores, Argonian Sithis T3/curse/creed-loss, Dunmer Grey Quarter/twilight/layer weight, Imperial secondary modifiers/point table, Breton breach routing/restoration, Altmer action routing | XL |
| Record-bound copy conformance | First consolidated voice-conformance record wave is readback-clean; remaining curse/champion/neglect copy outside that first wave still needs a later conformance/promote pass | M |
| Beta packet trims | Apply the safe packet reductions after the proof order is settled; this improves tester throughput but does not replace evidence | S |

## Off The Beta Path

These should not be allowed to inflate the current beta-feel burn:

- D1 diegetic transition surfacing and the larger `PDV_Notif_*` transition set.
- Daedric 16-Prince final-world placement.
- Ledger-gated world buildout not required for current beta packets, such as
  Altmer "The Return Made Daily" and wider Redguard Far Shores placement.
- V2 voiced dialogue and broad NPC recognition.
- Phase 21 compatibility rebaseline and external mod integration.
- Broad completeness-ledger `GAP-REVIEW` rows that are naming drift, false
  positives, or correct-by-design native-race Daedric behavior.

## Recommended Next Sequence

1. Finish the three remaining Sitting-1 Prisma C2 beats: Altmer alignment band,
   Khajiit Champion pin pruning survival, and Redguard per-sect Champion toast.
2. Preserve the strict beta-readiness pass (`STRICT_GATE_PASS`, `PASS=31`,
   `WARN=1`, `INFO=2`, blockers `[]`) in the next-session handoff and ignore
   older `Dunmer:7` audit output unless a fresh gate contradicts it.
3. Prove the Requiem penalty feltness add-on under a Requiem load: Active
   Effects, `player.getav Health`, HP-bar/manual feel notes, and Imperial
   disease-resistance preservation.
4. Prove the expanded likes/dislikes rows on a new save, including the version
   bump reload behavior; keep pending event rows classified as inert unless
   their routers are implemented.
5. Do the magnitude/anti-farm scaling pass only after rejected hooks and stack
   snapshots are recorded for the race being tuned.
6. Continue later ESP/source tranches from `PDV_NextBuildPass_RecordSpec.md`
   only where they have exact source authority; keep quest-stage/source routing
   separate from manual acceptance proof.
7. Keep D1 diegetic surfacing, final-world placement, V2 dialogue, and
   compatibility work off the beta-feel path unless the release scope changes.

## Current Gate Bundle

Use this bundle after any cleanup that could affect the burn:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_compile.mjs --script PDV_MCM
dotnet run --project .\tools\pdv-neglect-esp-author\PdvNeglectEspAuthor.csproj -- --check
dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec .\references\authoring\PDV_ConsolidatedBuildPass_RecordWave.spec.json
Get-ChildItem .\references\authoring -Filter 'PDV_*RewardRecords.spec.json' | Sort-Object Name | ForEach-Object {
  dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec $_.FullName
}
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --strict-neglect-decay
node .\tools\pdv_deity_chain_audit.mjs --json
node .\tools\pdv_eligibility_reward_coverage_audit.mjs --json
node .\tools\pdv_integrity_harness.mjs
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_daedric_beta_gate.mjs
```

For Khajiit P2 route refresh:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit
```
