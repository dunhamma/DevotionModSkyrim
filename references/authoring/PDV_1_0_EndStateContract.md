# PDV 1.0 End State Contract
**Created:** 2026-07-07
**Status:** Gate authority for 1.0 ship readiness
**Machine contract:** `PDV_1_0_EndStateContract.json` (this md is the human companion; the JSON is what the gate tool reads)
**Gate tool:** `node .\tools\pdv_1_0_endstate_gate.mjs` (read mode) / `--run` (execute machine gates live)
**Output:** `PDV_1_0_EndStateBurndown.md` / `.json` - the single cross-check of contract vs recorded testing evidence

## What this is

`PDV_TargetEndStates_1.0.md` owns the product feel and design acceptance
language. This contract owns the binary ship gate: 1.0 is done when every
non-post-1.0 criterion below is PASS in the generated burndown, and not
before. Criteria edits happen in the JSON (the gate tool implements only the
small pass-rule vocabulary, so contract edits never require tool edits).

## Criteria

| Id | Gate | Kind | Evidence |
|---|---|---|---|
| C-RACE-RUBRIC | 10 races pass the Pre-Beta Acceptance Rubric | evidence | PDV_PreBetaRaceGateLedger.md verdicts |
| C-PRINCE-GATE | 16 Princes pass the Daedric beta-display gate | machine | pdv_daedric_beta_gate.mjs |
| C-AUDIT-BETA-STRICT | Strict beta-readiness audit clean | machine | pdv_beta_readiness_audit.mjs --strict |
| C-AUDIT-SUBSTRATE-PACING | Shared substrate 7/19-day pacing contract passes | machine | pdv_substrate_pacing_audit.mjs --json |
| C-AUDIT-BROAD-PANTHEON | Imperial and Nord broad-pantheon parity contract passes | machine | pdv_broad_pantheon_audit.mjs --json |
| C-AUDIT-VERIFY | Framework verifier FAIL=0 | machine | pdv_verify.mjs (via --run stamp) |
| C-AUDIT-CONTENT | Content verifier clean | machine | pdv_content_verify.mjs (via --run stamp) |
| C-AUDIT-INTEGRITY | Integrity harness gates pass | machine | PDV_IntegrityHarnessLedger.md |
| C-EXPMODE-BUILD | Experience Mode built | machine | not-built placeholder; closes via --strict-experience-mode |
| C-EXPMODE-SMOKE | Two-mode runtime smoke | human | PDV_1_0_ManualSignoffLedger.json |
| C-COMPAT-ARR | ARR package accepted | human | PDV_1_0_ManualSignoffLedger.json |
| C-COMPAT-BORDELLO | 6 lists patch-packaged | human | PDV_1_0_ManualSignoffLedger.json |
| C-PLACEMENT-FINAL | In-world hook proof + ref classification (re-scoped: hooks bind to existing world context, no placed objects) | machine | pdv_placement_gate.mjs + PDV_InWorldHookProofLedger.json |
| C-REQUIEM-TRACKB | Requiem felt sweeps A/B1/B2 | human | PDV_1_0_ManualSignoffLedger.json |
| C-PACING-SIM | Piety economy in band for all races | machine | pdv_pacing_sim.mjs |
| C-PACING-SIGNOFF | 10 dated per-race pacing sign-offs | human | PDV_PacingSignoffLedger.json |
| C-FELT-TRACE | Every declared felt effect machine-traced end to end | machine | pdv_felt_trace_audit.mjs |
| C-FELT-FAMILY | One in-game felt proof per lane x class family | human | PDV_FeltFamilyEvidenceLedger.json |
| C-DISLIKE-DEBUFF-BUILD | Minor felt domain sting on every deity dislike lane | machine | not-built; closes via pdv_dislike_consequence_audit.mjs (build per the V2 handoff) |
| C-DISLIKE-DEBUFF-TUNING | Anti-stack / Requiem-felt tuning sign-off | human | PDV_1_0_ManualSignoffLedger.json |
| C-1-0 | Rollup: everything above | rollup | generated burndown |

## Drift doctrine

Every criterion names its freshness sources (content files hashed into
`PDV_1_0_FreshnessStamps.json` when the criterion is observed PASS).

- **Machine criteria FAIL on drift**: if a source hash changes, the previous
  machine observation is void and the criterion goes RED until re-run.
- **Human criteria go STALE on drift**: the sign-off stays PASS but the
  burndown flags it STALE; re-observe when convenient, mandatory before ship
  with `--strict-stale`.
- The gate also compares the git live-source manager against the MO2 deployed
  copy and emits a `live-vs-deployed-drift` finding when they differ.

## Felt proof bar (agreed 2026-07-07)

- Debug-primed proof is ACCEPTED for family slots: prime patron/piety/pact
  state via the debug MCM, then observe the live effect. Organic routes are
  already machine-proven by the trace and e2e gates.
- Price/dislike families prove by LOSS SURFACING: one displeasing act, then a
  visible toast, Book of Days beat, or panel Ledger row.
- Neglect, creed-loss, Prince price, and curse families prove by FELT
  MECHANIC: the debuff observed in Active Effects plus a feel note.
- Minor debuff consequences for deity dislike lanes (shared domain-sting
  overlay) were pulled INTO V1 as tracked gates on 2026-07-07
  (C-DISLIKE-DEBUFF-BUILD + C-DISLIKE-DEBUFF-TUNING). The per-domain stings
  prove through C-FELT-FAMILY during the race sittings once built; the build
  is headless Codex work sequenced before the sittings. Handoff:
  PDV_CodexHandoff_DislikeConsequence_V2.md.

## Explicitly post-1.0 (recorded so audits stop nagging)

WS-3 branding, FP-049 journal polish, Mega Test Packet Sittings D and F as
standalone items (Sitting D's Requiem content is gated by C-REQUIEM-TRACKB),
voiced dialogue / recognition V2, Bosmer Green Pact per-item tag layer, and
Jyggalag. See `post10Exclusions` in the JSON for rationales.

## How to run

- `node .\tools\pdv_1_0_endstate_gate.mjs` - fast read of committed ledgers +
  stamps; writes the burndown.
- `node .\tools\pdv_1_0_endstate_gate.mjs --run` - additionally executes the
  machine-gate tools (needs the houseCARL bridge for ESP-backed checks; those
  report SKIP, never PASS, when the bridge is down).
- `node .\tools\pdv_1_0_endstate_gate.mjs --strict-stale` - release-day mode:
  STALE human evidence blocks too.
- `node .\tools\pdv_1_0_endstate_gate.mjs --self-test` - fixture-based self test.
