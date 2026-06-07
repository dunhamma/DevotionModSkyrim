# PDV Phase 20 No-In-Game-Proof Workplan

**Created:** 2026-05-31
**Status:** Planning and implementation queue for Phase 20 work that can proceed before more Skyrim runtime proof
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceScalingSpine.md`, `PDV_PreBetaRaceAcceptanceRubric.md`, `PDV_Phase20_NoInGameProof_Gates.json`, `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_Phase20_PreBetaManualChecks_Runbook.md`, and `PDV_Phase20_BetaReadinessRemainder.md`

## Purpose

This packet defines the rest of Phase 20 work that can move forward without
opening Skyrim for live in-game proof.

It does not replace the manual pre-beta gate. It exists so the project can keep
making useful progress through architecture, manifests, source scaffolds,
readback checks, verifier gates, content handoff packets, and CK-ready runbooks
while runtime feel proof is deferred.

## Active Lanes

The current V1 content-authoring lanes are:

1. Final-world placement contracts.
2. Rejected-hook coverage.
3. Stack snapshot templates and expected/edge build plans.
4. P2 audit-only lanes.

Recognition/dialogue is V2 only and does not belong in this pass.

The current safe source-fill handoff lives in
`PDV_Phase20_BetaReadinessRemainder.md`. It records what the P2 book-fill
tranche proves and what remains before beta readiness.

## Boundary

Allowed in this pass:

- Manifest and ledger updates.
- Static source checks.
- Mutagen/readback checks.
- Narrow authoring-helper plans or helper implementation where the owner is
  clear and reversible.
- Survey/status source and content copy planning.
- Final-world placement contracts that name intended object, cell/location
  family, cultural reason, and stop condition.
- Stack snapshot templates and expected/edge build plans.
- CAT-6 pilot prep before CK/runtime proof. The first CAT-6 pilot may be
  record/readback-proven, but still does not count as runtime reward
  distribution or holistic effect approval.
- Recognition/dialogue is V2 only and stays out of the V1 content tree.
- Daedric proof-path closeout after D-15..D-18 lock: Batch 0 static proof,
  per-Prince CAT-6 target selection/readback, and runtime/display stop
  conditions.

Not allowed in this pass:

- Marking any race `Pass` in the pre-beta acceptance ledger.
- Claiming final placement because QASmoke proof exists.
- Claiming runtime feel, anti-farm feel, or Survey display proof without a fresh
  in-game/manual result.
- Generated dialogue authoring.
- Broad reward magnitude increases before stack/ceiling packets are complete.
- Broad Daedric runtime promotion before per-Prince D-18/CAT-6 proof, readback,
  runtime/display proof, and stack/Survey legibility are recorded.

Use `Planning-Ready`, `Readback-Ready`, `CK-Ready`, or `Runtime-Deferred`
instead of `Pass` when in-game proof is intentionally out of scope.

## Current Automated Baseline

```text
Content verifier:
node .\tools\pdv_content_verify.mjs
Expected current result: FAIL=0, WARN=0, PASS=1079, INFO=4

Strict Phase 20 source/readback gate:
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
Expected current result: PASS=2827, WARN=2, INFO=29

P2 source-fill readback:
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
Expected current result: Status=PASS, 30 approved P2 source entries across 14 groups, including Altmer MQ104 in `PDV_FLST_P2_AltmerLorkhanPenalties`.

P2 exact-stage quest gate:
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
Expected current result: Status=PASS, 1 approved quest-stage source entry with exact-stage metadata.

P2 FormList and alias-property readback:
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-formlists
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-alias-properties
Expected current result: Status=PASS, all 34 P2 FormLists and alias properties read back.

Route-marker list:
node .\tools\pdv_phase20_runtime_check.mjs --list
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --list
Expected current result: all Phase 20 proof races and P2 book source markers list.

P2 book-source runtime proof:
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager
Expected current result before manual in-game proof: FAIL, because no accepted P2 book-read markers are recorded in the live Papyrus log yet.

Proof placement readback:
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
Expected current result: Status=PASS, 30 proof references mapped.
```

The remaining verifier warning is the existing unnamed CK-authored INFO record
class in `PlayerDevotion_Framework.esp`.

## No-In-Game Definition Of Done

This pass is complete when all of the following are true:

1. Every race has a `Runtime-Deferred` packet in the gate ledger with an
   expected build, edge build, normal-session route, rejected-hook families,
   Survey/status requirement, final placement contract, reward floor, reward
   ceiling, and stack snapshot.
2. Every P0/P1 race has at least one normal-play hook plan that names the
   intended signal source, the accepted route, the rejected generic behaviors,
   and the anti-farm rule.
3. Every P2 race has an audit-only stack/ceiling packet with no new reward
   volume requested.
4. The verifier checks the source/readback parts that can be checked without
   Skyrim: manifest row IDs, all-race Survey source branches, proof record
   readback, state-track labels, manager properties, and the narrow CAT-6
   pilot record where relevant.
5. CAT-6 has one target-record owner decision for the first pilot, proves that
   one target by readback, or remains explicitly blocked as
   `target-record-needed`.
6. `PDV_Phase20_PreBetaManualChecks_Runbook.md` is ready to receive manual
   evidence later, with no missing race sections.
7. `PDV_Phase20_ManualEvidenceLedger.json` has a pending evidence intake packet
   for every race so future manual proof can be recorded without changing the
   no-game verdict by accident.

Current implementation note: `PDV_Phase20_NoInGameProof_Gates.json` is the
structured form of this definition of done. The strict Phase 20 race-costing
verifier reads it so no-game status, hook contracts, placement contracts,
stack snapshots, CAT-6 target-record state, and Daedric proof-path blockers cannot
silently drift from the prose ledgers.
`PDV_Phase20_ManualEvidenceLedger.json` is the structured manual-proof intake
file. The verifier checks that it exists and stays pending until evidence is
actually recorded.

## Work Waves

## Current Implementation State

Wave 1 is implemented: the gate ledger now records no-in-game status, deferred
manual proof, and the next automatable action for each race.

Wave 2 is implemented in structured form: `PDV_Phase20_NoInGameProof_Gates.json`
records the normal-session route, accepted hook families, rejected hook
families, and anti-farm rules for all ten races.

Wave 3 is implemented: the strict Phase 20 race-costing verifier now reads the
structured gate and checks race coverage, rejected-hook depth, anti-farm rules,
stack snapshots, placement contracts, CAT-6 target-record state, recognition
packet prep, and Daedric proof-path status.

Wave 4 is implemented as CK-ready contracts, not live placement: every P0/P1
race has two final-world placement contracts, while P2 audit lanes intentionally
have none.

Wave 5 is implemented as no-game stack snapshots: every race has expected and
edge build stack notes, P2 races stay audit-only, and the structured gate blocks
accidental P2 placement/reward expansion.

Wave 6 is implemented as source/status requirements: every race has a
Survey/status requirement and debug-only boundary, but no race receives a
`Pass` until the readout is manually checked in game.

Wave 7 is implemented through the first pilot record/readback proof: CAT-6 now
records the first Khajiit candidate as a live pilot-provisional framework
`SPEL` with two night-gated `MGEF` effects, keeps the Bosmer fallback absent,
and preserves the pilot under the later all-race reward contract. Reward
records and first-tier grant ownership now live in
`PDV_Phase20_RewardRecordContracts.json`; runtime/manual proof is still
required before treating the reward as felt gameplay.

Wave 8 is now V2-only: recognition/dialogue is deferred out of the V1 content
tree and will not be pursued until voice files are available.

Wave 9 is implemented as proof-path tracking: D-15..D-18 are locked and Batch 0
static D-18 proof is complete, but Daedric runtime promotion remains blocked
until per-Prince CAT-6 promotion/readback, runtime or display proof, and
race-stack legibility are recorded.

Manual evidence intake is implemented as a structured pending ledger:
`PDV_Phase20_ManualEvidenceLedger.json` names the expected wrong-origin,
generic-hook, Survey/status, final-placement, stack-snapshot, and manual-feel
checks for all ten races. The verifier keeps those slots pending until runtime
or manual proof is actually performed.

### Wave 1 - Gate Ledger Hardening

Goal: make the ledger a complete source of truth for pre-runtime status.

Outputs:

- Add a `No-in-game status` field to every race packet.
- Convert every current `Fail - internal scaling only` into a more precise
  pair: `Verdict: Fail - runtime/manual proof deferred` and `No-in-game status:
  Planning-Ready` or `Readback-Ready`.
- Add one `Next automatable action` line per race.
- Add one `Deferred manual proof` line per race.

Owner files:

- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `references/authoring/PDV_PreBetaRaceAcceptanceRubric.md`

Stop condition:

- Do not claim a race is ready for external testing. This wave only clarifies
  what can be done before Skyrim proof resumes.

### Wave 2 - Normal-Play Hook Contracts

Goal: turn each race's next hook into a buildable contract without proving it
in game.

Outputs:

- Altmer: authored crisis/Lorkhan/dawn/study hook contract with ordinary-life
  rejection list.
- Khajiit: moon fallback, two-anchor road-home, and Baan Dar/Rajhin/Alkosh
  anti-chore contract.
- Argonian: Hist/People water/rest/bed/community contract before Void depth.
- Orc: Stronghold/City/Legion quality and service filters.
- Redguard: Crown/Forebear/Ash'abah/Far Shores/HoonDing cap contract.
- Bosmer: Old Contract/Living Story/Exchange/Bandit Road non-hunter parity
  contract.
- Breton, Dunmer, Imperial, Nord: audit-only hook rejection and stack/ceiling
  contract.

Owner files:

- `references/authoring/PDV_RaceImplementationCostingBacklog.md`
- The six Phase 20 race implementation-costing manifests.
- `references/authoring/PDV_PreBetaRaceGateLedger.md`

Stop condition:

- If a hook needs an unproven Papyrus API, CK graph mutation, or list-specific
  reference, park it as `manual/CK proof needed` instead of treating it as a
  normal-play candidate.

### Wave 3 - Static Verifier Expansion

Goal: make the no-game gates fail when docs/manifests/source drift.

Candidate checks:

- Gate ledger contains all ten races and the required no-in-game fields.
- All P0/P1 packets name at least six rejected-hook families.
- All P2 packets name at least four rejected-hook families.
- All ten races have Survey/MCM source branches.
- CAT-6 first candidate and fallback report target-record availability; the
  Khajiit first candidate also proves spell text, magic-effect text, effect
  shape, night conditions, and reward-contract-owned grant wiring.
- Final-placement contracts exist separately from QASmoke proof records.
- P2 packets do not request new reward volume.

Owner files:

- `tools/pdv_verify.mjs`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `references/authoring/PDV_CAT6PromotionPilot.md`

Stop condition:

- Do not make the verifier parse prose in brittle ways if a structured manifest
  field would be cheaper. Add structured fields to manifests first when the
  check needs stable data.

### Wave 4 - Final-World Placement Contracts

Goal: finish placement planning without CK placement or Skyrim proof.

Each P0/P1 race gets:

- Surface EditorID plan.
- Intended object type.
- Target cell/location family.
- Cultural reason.
- Positive or pressure/recovery classification.
- Wrong-origin expectation.
- QASmoke proof record it relates to, if any.
- CK/manual stop condition.

First placement concepts:

| Race | Positive surface | Pressure/recovery/status surface |
|---|---|---|
| Altmer | Dawn/study surface near scholarship or Auri-El practice | Crisis/Lorkhan pressure surface tied to authored quest context |
| Khajiit | Road-home/moon/caravan surface | Focus-specific Baan Dar/Rajhin/Alkosh surface |
| Argonian | Hist/water/rest surface | People/community or death-rite surface |
| Orc | Stronghold/quality craft surface | City dignity or Legion/Exile service surface |
| Redguard | Crown/Forebear sect surface | Ash'abah/Far Shores death-duty surface |
| Bosmer | Living Story or Exchange non-hunter surface | Bandit Road reversal or Pact-lapse surface |

Owner files:

- New or existing placement contract section in
  `references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md`
- Per-race Phase 20 proof-placement runbooks where useful

Stop condition:

- Do not place records or mark placement live in this wave. The deliverable is a
  CK-ready contract.

### Wave 5 - Stack Snapshot And Ceiling Audit

Goal: make reward ceilings inspectable before adding more content volume.

Outputs:

- One expected stack and one edge stack per race.
- Allowed loud layers.
- Suppressed, softened, or interpretation-only layers.
- Active contextual favor cap.
- Curse/Daedric modifier note.
- P2 "no new reward volume" confirmation.

Owner files:

- `references/authoring/PDV_RaceRewardBudgetLedger.md`
- `references/authoring/PDV_RacePlaystyleCoverageLedger.md`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`

Stop condition:

- If a stack cannot be explained without current god/Daedric content, write the
  missing content dependency instead of guessing final reward behavior.

### Wave 6 - Survey And Status Copy Lock Prep

Goal: prepare the copy handoff without requiring runtime display proof.

Outputs:

- Per-race Survey copy intent: what the player should understand in one read.
- Debug-only terms list: route IDs, raw counters, internal enum names, and
  implementation labels that must not appear in player-facing copy.
- Copy dependencies on gods/Daedrics content.
- Static source checks where stable.

Owner files:

- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `race-sheets/PDV_RaceContent_Manifest.md`
- `tools/pdv_verify.mjs`

Stop condition:

- Runtime display remains manual. This wave can make copy ready and source
  branches present; it cannot prove menu layout, message timing, or player feel.

### Wave 7 - CAT-6 First Pilot Prep

Goal: keep CAT-6 to a single named implementation boundary and one
record/readback-proven pilot.

Current state:

- `PDV_Bless_Khajiit_Lunar_T1` source row exists.
- `PDV_Bless_Khajiit_Lunar_T1` target `SPEL` EditorID is present in the live
  framework ESP as a pilot-provisional CAT-6 record.
- `PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen` and
  `PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist` read back as the two
  pilot-provisional magic effects.
- Both effects are gated to `GetCurrentTime >= 19 OR <= 7`; the source row
  says "At night" to match that implementation.
- `PDV_Bless_Bosmer_Exchange_T1` fallback source row exists.
- `PDV_Bless_Bosmer_Exchange_T1` target `SPEL` EditorID is also absent.

Next no-game actions:

1. Keep the first pilot away from Daedric stigma and dialogue.
2. Treat `PDV_Phase20_RewardRecordContracts.json` as the grant owner for the
   Khajiit Tier 1 record and all other race Tier 1 rewards.
3. Run runtime/manual checks before claiming Active Effects display, save/load,
   Survey clarity, balance feel, or beta readiness.
4. Keep future Daedric CAT-6 promotion separate from race T1 rewards.

Owner files:

- `references/authoring/PDV_CAT6PromotionPilot.md`
- `tools/pdv_verify.mjs`
- New narrow helper only if the ownership boundary is explicit.

Stop condition:

- No broad string promotion. No dialogue. No Daedric stigma or curse-access row
  for the first pilot.

### Wave 8 - Recognition Deferred To V2

Goal: keep V1 free of dialogue feedback and leave recognition for a later
voice-backed pass.

Current status:

- Recognition/dialogue is not part of the V1 content tree.
- Survey/status remains the only allowed feedback lane for now.
- The recognition packet stays parked as a V2 planning artifact.

Next no-game actions:

1. Do not schedule V1 dialogue writing or voice-backed line authoring.
2. Keep the recognition packet frozen until V2 voice assets exist.
3. Revisit only if the V2 scope explicitly reopens recognition.

Owner file:

- `references/authoring/PDV_RecognitionDialogueScalePacket.md`

Stop condition:

- Leave this wave untouched while V1 reward and placement work continues.

### Wave 9 - Daedric Phase-20 Proof-Path Closeout

Goal: close the Daedric proof path after the D-15..D-18 decision locks before
runtime promotion begins.

No-game proof work still useful now:

- Keep `PDV_DaedricBatch0_D18ProofLedger.md` as the static D-18 proof pattern
  for Azura / Azurah, Vaermina, Meridia, and Molag Bal.
- Select the first Batch 0 CAT-6 target and prove exact target-record readback
  before any runtime promotion claim.
- Keep Hircine and Molag Bal curse-access rows no-double-fire with race
  `CurseState` rows.
- Keep cross-Prince hostility and exit residue language Survey/status-legible
  without silently overwriting race identity.

Owner files:

- `PDV_Architecture_v3.md`
- `references/phase4/PDV_DaedricRacePrinceMatrix.csv`
- `race-sheets/PDV_DaedricContent_Manifest.md`
- `references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md`
- `references/authoring/PDV_DaedricBatch0_D18ProofLedger.md`
- `references/authoring/PDV_CAT6PromotionPilot.md`

Stop condition:

- Do not promote Daedric runtime rows until the Prince has D-18 static proof,
  CAT-6 target-record promotion/readback, runtime or display proof, and
  stack/Survey legibility evidence.

## Recommended Order

1. Wave 1: harden the gate ledger.
2. Wave 3: add the lowest-risk verifier checks for ledger/source drift.
3. Wave 2: write hook contracts for Altmer, Khajiit, and Argonian first.
4. Wave 5: write P2 stack/ceiling audit packets before any new P2 rewards.
5. Wave 4: write CK-ready final placement contracts for P0/P1.
6. Wave 6: prepare Survey/status copy lock notes.
7. Wave 7: keep the CAT-6 pilot preserved under the all-race reward contract
   and run runtime/manual proof before claiming reward feel.
8. Wave 9: close the Daedric proof path before any Prince runtime promotion.

## Parallelization Plan

Use subagents or separate workstreams only with disjoint file ownership:

| Workstream | Scope | Files |
|---|---|---|
| A | Altmer/Khajiit/Argonian hook contracts | `PDV_RaceImplementationCostingBacklog.md`, three manifests |
| B | Orc/Redguard/Bosmer hook contracts | `PDV_RaceImplementationCostingBacklog.md`, three manifests |
| C | P2 stack/ceiling audit | `PDV_RaceRewardBudgetLedger.md`, `PDV_RacePlaystyleCoverageLedger.md` |
| D | Verifier/check design | `tools/pdv_verify.mjs` |
| E | V2-only recognition deferred | `PDV_RecognitionDialogueScalePacket.md` |

One primary agent should own final integration into
`PDV_PreBetaRaceGateLedger.md` to avoid conflicting verdict language.

## Verification Commands

Run these after any no-game Phase 20 planning or source/readback update:

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
git diff --check
```

If a `.psc` file changes, also run the targeted compile:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
```

## Content Notes For The User

Useful now:

- Final-world placement concepts for Altmer, Khajiit, Argonian, Orc, Redguard,
  and Bosmer. One positive surface and one pressure/recovery/status surface per
  race is enough.
- Survey/status tone preferences for all ten races, especially the P2 audit
  races where current source can explain state but final copy still needs taste.
- Reward follow-up: use `references/authoring/PDV_RaceEffectReviewLedger.md`
  and `references/authoring/PDV_Phase20_RewardRecordContracts.json` together
  when tuning magnitudes or changing grant/removal behavior; current automated
  proof does not replace runtime/manual reward feel proof.
- Daedric proof path: first Batch 0 CAT-6 target, readback requirements,
  runtime/display proof route, and stack/Survey interaction with race identity.

Not needed yet:

- Full final god/Daedric prose for every reward.
- External tester instructions.
- Numeric reward tuning beyond ceiling/floor budgets.

## Next Work Hook

The remaining Phase 20 work is decision-bound or runtime/manual:

1. Fill the manual evidence ledger during in-game checks; do not mark any race
   `Conditional` or `Pass` before those slots have proof notes.
2. Close the next Daedric CAT-6/readback/runtime/display proof packet before
   any Daedric runtime promotion.
