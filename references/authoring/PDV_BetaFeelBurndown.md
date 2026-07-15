# PDV Beta-Feel Burndown

**Created:** 2026-06-14
**Status:** Living beta-feel burndown report
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`,
`PDV_BetaFeelReleaseGate.md`, `PDV_InGameTestingNeeded_Runbook.md`, and the
2026-06-14 build-batch handoffs.

## 1.0 Gate

Beta-feel is not the ship bar. The binary 1.0 ship gate is
`references/authoring/PDV_1_0_EndStateContract.json`; run
`node .\tools\pdv_1_0_endstate_gate.mjs` to regenerate
`references/authoring/PDV_1_0_EndStateBurndown.md`, which cross-checks every
contract criterion against recorded evidence. Items this report calls
"non-blocking" may still be 1.0 ship gates there (placement, Requiem Track B,
pacing, felt-effect proof, Experience Mode, compatibility).

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

## Authority Note (2026-07-09, updated 2026-07-15)

Ship truth lives in `PDV_1_0_EndStateContract.json` plus a fresh gate run
(`node .\tools\pdv_1_0_endstate_gate.mjs`). The generated
`PDV_1_0_EndStateBurndown.md` is that run's on-demand rendering; as of
2026-07-15 it is no longer committed (regenerate it with the gate command --
see PDV_STANDARDS.md section 5.3). This document remains the narrative
beta-feel burn; where the two disagree, the contract gate wins.

2026-07-10 co-test note: use
`references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md` as the single
operator sheet during live tester/Codex sessions. A current read-mode gate run
reported **1 PASS / 1 STALE / 16 RED** because source/deployed drift voided
older machine proofs. Re-green with `pdv_1_0_endstate_gate.mjs --run` before
spending live play time as 1.0 evidence; then record results in the structured
ledgers named by the generated burndown.

### Contract-era snapshot (as of 2026-07-09, post `--run` re-green)

Gate rollup after `node .\tools\pdv_1_0_endstate_gate.mjs --run` with the Anvil
MCP bridge live: **9 PASS / 1 STALE / 8 RED** (was 1 PASS / 1 STALE / 16 RED in
read-mode before the re-green). The remap wiring (5f245de) and the tranche-10
signal-floor commit (6147991) had drift-voided every machine PASS; the `--run`
re-executed each gate tool and re-greened all nine machine gates: C-PRINCE-GATE,
C-AUDIT-BETA-STRICT, C-AUDIT-VERIFY, C-AUDIT-CONTENT, **C-AUDIT-INTEGRITY**,
C-EXPMODE-BUILD, C-PACING-SIM, C-FELT-TRACE, C-DISLIKE-DEBUFF-BUILD.

**C-AUDIT-INTEGRITY closed 2026-07-09 when the Anvil MCP bridge came up.** Its
`signal_e2e_gate` sub-check needs the live bridge (`127.0.0.1:27016`) to confirm
the 39 curated/reserved signal surfaces dispatch; headless it had been down
(`ECONNREFUSED`) leaving them `INCOMPLETE`. With the bridge live the gate reads
**39 GREEN / 0 RED, mcp PASS, parity PASS**, and the full harness is PASS
(deity_chain, eligibility-reward 153/0, signal_floor, spine, specced_minus,
completeness all OK). No code change was needed -- it was purely proof-pending
on the runtime.

No machine gate is red. The two non-green machine rows are both non-substantive:
- **C-PLACEMENT-FINAL (RED)** -- known/expected; in-world hook proofs re-scoped
  2026-07-07 (a9e73e0) to fold into the per-race sittings.
- **C-RACE-RUBRIC (STALE)** -- race-sheet drift from the remap decisions
  (1631351 edited the race sheets); re-observes when a race ledger is re-run.

Caveat: the gate flags `live-vs-deployed-drift` -- the git live-source manager is
ahead of the MO2 deployed `.pex`. The machine green reflects live-source + live
ESP records; recompile/deploy to MO2 before in-game smoke to mirror this state.

The substantive open work is the **evidence-gate slots** (all in-game/packaging,
none machine-greenable):

Counts current as of 2026-07-14.

| Lane | Open | Notes |
| --- | --- | --- |
| C-FELT-FAMILY | 58/151 | One-per-family in-game felt proof; **93 done (62%)** — 43 retro + 50 fresh (Nord/Imperial 13 each, Khajiit 10, Breton 10, + cross-cutting). **Owner ruling 2026-07-14 (keep-as-done + note drift, supersedes the earlier "invalidated" note):** the 07-13 regen->Fortify conversion changed the effect records on ~61 already-done families; they STAY proven (still felt, now as pool-MAX), but their recorded notes describe the pre-conversion regen effect. The converted effects' Requiem-feltness is re-proven by C-REQUIEM-TRACKB, which doubles as the re-confirm. |
| PS-A pantheon/substrate adversarial | 0/12 cards (0/30 buckets) | **NEW 2026-07-14 lane.** Independent refutation closed 4 backend defects (broad-scratch self-decay, Argonian bed day-bounding, Sacred Water/Sleeping Tree Sap shared Hist clock, Nord Survey live-pool). Backend/static all PASS (verifier 4145/0/0, signal E2E 39/39, broad 95/95, substrate-pacing 116/116, Prisma 114/114). Runtime-route + manual/display evidence owed per card into `PDV_PantheonSubstrateRuntimeEvidenceLedger.json`; authority = runbook §Pantheon/substrate addendum. |
| C-PACING-SIGNOFF | 9/10 | Dated per-race play-sitting sign-offs (Imperial recorded); fold into felt-family sittings |
| C-EXPMODE-SMOKE | **PASS (2/2)** | Pilgrim + Wayfarer in-game smoke recorded |
| C-REQUIEM-TRACKB | 4 open | Authoria sweeps; **build now complete** — the project-wide M/S regen->Fortify conversion shipped 07-13 (3777608e + Daedric/neglect/near-death), so Track B is runnable and re-proves the 61 converted felt families |
| C-DISLIKE-DEBUFF-TUNING | 1/1 | 32-source disfavor anti-stack legibility under Requiem |
| C-COMPAT-ARR | 1/1 | Maintainer-accepted evidence packet |
| C-COMPAT-BORDELLO | 6 slots = **2 build-targets** | DoD-base + JOJ-base share the religion-removal set; ~1 session of packaging, gate still records 6 sign-offs (owner 2026-07-12) |
| C-PLACEMENT-FINAL | gate FAIL | In-world hook proofs; re-scoped 07-07 (a9e73e0), folds into race sittings |

### The gap arc (2026-07-06 -> 2026-07-14): every gap became a gate

The recurring failure class ("declared but not wired end-to-end") kept being
found by the owner's own review passes -- and each discovery was converted into
a permanent machine gate rather than a one-off fix:

| Found | Gap | Systemic response |
| --- | --- | --- |
| 07-06/07 | Dislikes scored piety but had no felt consequence | Dislike-consequence packet: 14 domain sting spells + registry hash + `C-DISLIKE-DEBUFF-*` gates (01bdacf, 80aff22) |
| 07-07 | Prose end-states unverifiable; "done" claims drifted | 1.0 End-State Contract + `pdv_1_0_endstate_gate.mjs` with drift-voiding evidence (23d266f) |
| 07-08 | Wired-vs-stub review: curated "signature" fork lanes are dev-only stubs across all 10 races; guides lead with acts that never fire organically; neglect timers unresettable through the named acts; 4 copy inversions | 10 guides tagged `[WIRED]/[QUEST]/[PARTIAL]/[STUB]/[INERT]` + `_WiredVsStub_ReviewSummary.md`; deity signal remap designed + locked (ddb81ce, 1631351) |
| 07-09 | (response lands) | Signal remap WIRED: manager +184 lines, 27 new CSV rows, remap smoke runbook + wiring-gap deep-dive shipped (5f245de); in-game smoke owed |
| 07-13 | Magicka/Stamina (and Health) regen rewards are INERT under Requiem (Requiem zeroes regen) — a project-wide feltness gap: boons/prices/neglect/near-death "felt" nothing | Project-wide regen->Fortify-pool conversion: 9 races always-on regen + Daedric Prince boons/prices + race neglect/creed-loss penalties + Argonian Sithis near-death (3777608e, 90e5d3e7, 612dfe52, 361cd5e5, c452d9cf); C-REQUIEM-TRACKB re-proves |
| 07-14 | Independent call-graph + presentation refutation found 4 backend bypasses (broad-scratch self-decay, Argonian bed day-bounding, Sacred Water/Sap shared Hist clock, Nord Survey frozen counter) | Backend fixes landed (all static/readback PASS) + a 12-card PS-A adversarial runtime lane (0/30 buckets) authored to close them with runtime/manual proof |

The felt-trace exhaustive gate (441/441 PASS pre-drift) and curated-signal
parity (107/107) both hold; the remap re-green is repo-side work, not a
regression.

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
| Requiem penalty conversion | **Backend/readback pass; feltness smoke pending** | `node .\tools\pdv_requiem_penalty_audit.mjs` -> `PASS=44`; Argonian/Breton Health penalties and Imperial preservation still need in-game Active Effects and HP-bar proof. **(2026-07-13)** the M/S regen debuffs (Altmer/Dunmer Magicka, Bosmer/Khajiit Stamina, Breton `DruidicForkBetrayal`) are now negative Fortify pool and also need Active-Effects proof (Maximum Magicka/Stamina bar ceiling DROPS); the positive M/S reward boons converted to Fortify pool owe feltness proof too (see `PDV_RequiemSmokeTest_Tracker.md` Sweep C). |
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
| Quest-matrix/signal-floor expansion | **Backend/static smoke ready; runtime/manual smoke pending** | The pre-remap 832-cell packet is still the in-game-proven baseline for Section A. The current source/live-runtime matrix is now 1071 cells / 169 quest keys / 135 watched quests / 45 deity names / 26 faucet acts, with LD v15 folded into compiled manager source. `PDV_SignalFloorSmokeLedger.md` is backend PASS at 142 PASS / 12 runtime OPEN, and Debug MCM now exposes controlled `Signal-floor smoke` routes for the representative set. These controlled routes are not organic proof; Book of Days, Survey/status, Prisma/toast, duplicate suppression, wrong-origin silence, save/load, and manual feel remain open until in-game smoke records them. |
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
| Nord Old Ways roster: Orkey + Dibella | Built + in-game smoke PASS (829bbbfa, 7d40afe7); Orkey reward display fix readback PASS 2026-07-11 | Arkay-as-Orkey display override + Dibella offers/rewards/display; Orkey MESG 07161B + SEQ refresh. 2026-07-11 fix split Old Ways Orkey rewards to `PDV_Bless_Nord_Arkay_T1/T2/T3` so Active Effects say Orkey while Nine Divines Arkay keeps the Imperial Arkay records |
| Orkey/Dibella Old Ways neglect | Manual Active Effects smoke PASS (2026-07-06) | `PDV_SPEL_Neglect_Arkay` / `PDV_MGEF_Neglect_Arkay` displays as "Orkey's Neglect" with `ResistMagic -5`; `PDV_SPEL_Neglect_Dibella` / `PDV_MGEF_Neglect_Dibella` displays as "Dibella's Neglect" with `Restoration -5`. Confirmed in Active Effects on a Nord Old Ways save (fresh launch) via the new modal-free `Prime neglect eligible` MCM row (sets deity active + piety 0, then `Run neglect pass`). Note: `Prime decay eligible` does NOT flag neglect -- it sets piety 20 (above the piety<=10 floor) and a lapse stamp on the exact grace boundary, so neither flagging path fires; neglect is a separate system from decay |
| Curated driver copy | Fixed + in-game re-verified (c8a4aa34) | Curated rows name the actual trigger, e.g. "defiant prayer at a Talos shrine", rather than generic "a devotional rite" |
| Watching Prince dashboard/Book of Days | Fixed + in-game re-verified (692396bb, 2f75a860) | Pre-pact Princes show a distinct Watching badge and a named watching-onset Book of Days line |
| Quest-reaction surfacing aggregation | Fixed + in-game re-verified | Quest fires now emit one aggregate toast plus one Book of Days line, not a burst per matrix cell |

Filed from the same pass and still open: `task_387bfc95` slider cap >=1000,
and `task_7dab1ebb` Hircine renounce over-fire/copy. **Closed 2026-07-06:**
`task_e6904bb3` Orkey/Dibella neglect debuff manual Active Effects smoke PASSED
(Orkey Magic Resistance -5%, Dibella Restoration -5) via the new modal-free
`Prime neglect eligible` button (commit `cad3d07`); `task_8c27e440` Refuse
correction manual smoke PASSED (refusal toast + pinned chronicle, no screen wash
or D1 sound; Accept keeps its toast + sound; the offer-present wash is intended
and separate).

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
| Breton | Pass with 1.0 felt-proof follow-up paused | Prior beta packet had no blocker; current 1.0 co-test Breton felt-family pass is paused for architecture review of Knight's Road reward anchoring before runtime evidence continues; final-world placement separate |
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
   disease-resistance preservation. **(2026-07-13)** also cover the M/S
   Fortify-pool rewards and the negative-Fortify M/S penalties: `player.getav
   Magicka`/`Stamina` + Magicka/Stamina bar-MAX movement (rise for boons, drop for
   penalties). Cross-ref `PDV_RequiemSmokeTest_Tracker.md` Sweep C.
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
