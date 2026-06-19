# PDV Beta-Feel Burndown

**Created:** 2026-06-14
**Status:** Living beta-feel burndown report
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`,
`PDV_BetaFeelReleaseGate.md`, `PDV_InGameTestingNeeded_Runbook.md`, and the
2026-06-14 build-batch handoffs.

## Purpose

This report consolidates the current beta-feel burn from the 9-race audit
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

As of the 2026-06-14 17:29 AEST local recheck:

| Area | Current state | Evidence |
| --- | --- | --- |
| Daedric Princes | **Pass** for current beta-display gate | `node .\tools\pdv_daedric_beta_gate.mjs` -> `PASS=16` |
| Race beta-feel packets | **8 pass, 2 still fail/deferred** | `PDV_PreBetaRaceGateLedger.md`: Altmer, Khajiit, Bosmer, Nord, Argonian, Orc, Breton, and Redguard Pass; Dunmer and Imperial remain Fail/deferred (count reconciled 2026-06-19) |
| Default framework verifier | **Machine-clean with known warnings** | `node .\tools\pdv_verify.mjs` -> `FAIL=0, WARN=2, TODO=0, PASS=3038, INFO=43`; includes small-signal v8/v3 exact-body source gate |
| Content verifier | **Clean** | `node .\tools\pdv_content_verify.mjs` -> `FAIL=0, WARN=0, PASS=1080, INFO=4` |
| Khajiit focused P2 route | **Route-proof pass** | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit` -> PASS |
| Live manager compile | **Clean** | `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` -> `1 succeeded, 0 failed`; bundled verifier stayed `FAIL=0, WARN=2, TODO=0, PASS=3038, INFO=43` |
| Consolidated record-wave readback | **Clean** | `--check-rewards --rewards-spec PDV_ConsolidatedBuildPass_RecordWave.spec.json` -> PASS; Redguard curse-state message-body drift is closed |
| Per-race reward-spec readback | **10/10 pass** | All ten `PDV_*RewardRecords.spec.json` files pass `tools\pdv-phase20-race-author --check-rewards`, including Imperial Concordat track modifiers |

The earlier recheck debt for Redguard curse-state message bodies and Imperial
Concordat track naming is closed. This does not promote any runtime/manual race
packet: it only restores the machine/readback baseline.

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
| Altmer `PDV_RepTrack_ThalmorAlignment` first record bridge | Consolidated record-wave readback passes | Source routing for the six actions and manual/new-save behavior proof remain open |
| Breton creed-loss spell records and persistent band routing | Breton reward-spec readback passes; handoff claims manager compile/readback | Breach-source quest routing, threshold notifications, recovery routes, and in-game Active Effects proof remain open |
| Altmer/Imperial/Dunmer track emitters wired (2026-06-14) | Compile/readback clean | Altmer ThalmorAlignment now live (banned-texts -5, consort -25, Thalmor-kill -20); Imperial Stormcloak-defiance now lands -20 via the point table + Thalmor-Justiciar-kill -10; Dunmer DLC2 outdoor-shrine twilight prayer. ~6 no-clean-hook actions (arrest/report/help-escape/Thalmor-mission/Orc-oath-break/Redguard-Dawnguard-cure) documented as deferred in `PDV_NextBuildPass_RecordSpec.md` sec.10. **Route-proven 2026-06-14** (Papyrus log): Altmer banned-texts/consort/kill -> raw -75; Imperial defiance -20; Imperial Thalmor-kill -10 (open kill, after a rank-gate fix). Only the Dunmer DLC2 Solstheim shrine remains unobserved (needs Solstheim); full manual beta-feel separate |

## Immediate Recheck Debt

These are small but high-priority because they keep the burndown honest.

| Priority | Item | Size | Why it matters |
| --- | --- | --- | --- |
| Closed 2026-06-14 | Redguard curse-state MESG body drift in `PDV_ConsolidatedBuildPass_RecordWave.spec.json` | S | Consolidated record-wave `--check-rewards` now passes |
| Closed 2026-06-14 | Imperial reward-spec track naming/readback | S | All ten per-race reward specs now pass |
| Closed 2026-06-14 | Focused gate bundle rerun | S | Manager compile, consolidated record-wave check, all ten reward-spec checks, default `pdv_verify`, content verifier, and Daedric beta gate all pass |

## Critical Path To Beta-Feel

### 1. Manual Race Evidence

This is the long pole. The default machine gates are strong; the release claim is
blocked by manual/runtime evidence for the seven non-passing races.

| Race | Current state | Remaining proof |
| --- | --- | --- |
| Altmer | Pass | No blocker for current packet; final-world placement separate |
| Khajiit | Pass | No blocker for current packet; final-world placement separate |
| Bosmer | Pass | No blocker for current packet; final-world placement separate |
| Argonian | Pass | No blocker for current packet; final-world placement separate |
| Orc | Pass | No blocker for current packet; final-world placement separate |
| Redguard | Pass | manual/runtime packet 2026-06-19 (8/8 dims); non-blocking follow-ups: vampire earn-halt (content), HoonDing/Leki day-to-day leak fix APPLIED 2026-06-19 (regen+compile+verifier clean; awaiting in-game reconfirm), Arkay shrine cosmetic; final-world placement separate |
| Breton | Pass | No blocker for current packet; final-world placement separate |
| Dunmer | Fail | Ancestor/Reclamation stack audit, rejected generic Daedric behavior, Survey display, immersive hook proof, asset status |
| Imperial | Fail | Civic Survey display, faction/attendance rejection, public/private Talos stack, immersive hook proof, asset status |
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

1. Run the eight remaining race packets in the pre-beta ledger order, recording
   manual/runtime evidence in `PDV_Phase20_ManualEvidenceLedger.json` and
   `PDV_PreBetaRaceGateLedger.md`.
2. Prove the expanded likes/dislikes rows on a new save, including the version
   bump reload behavior; keep pending event rows classified as inert unless
   their routers are implemented.
3. Do the magnitude/anti-farm scaling pass only after rejected hooks and stack
   snapshots are recorded for the race being tuned.
4. Continue later ESP/source tranches from `PDV_NextBuildPass_RecordSpec.md`
   only where they have exact source authority; keep quest-stage/source routing
   separate from manual acceptance proof.
5. Keep D1 diegetic surfacing, final-world placement, V2 dialogue, and
   compatibility work off the beta-feel path unless the release scope changes.

## Current Gate Bundle

Use this bundle after any cleanup that could affect the burn:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec .\references\authoring\PDV_ConsolidatedBuildPass_RecordWave.spec.json
Get-ChildItem .\references\authoring -Filter 'PDV_*RewardRecords.spec.json' | Sort-Object Name | ForEach-Object {
  dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec $_.FullName
}
node .\tools\pdv_verify.mjs
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_daedric_beta_gate.mjs
```

For Khajiit P2 route refresh:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit
```
