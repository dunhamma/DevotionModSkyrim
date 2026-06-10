# PDV Contract-Coverage Completeness Audit - Plan

Status: PHASES 0-3 SWEEP COMPLETE (2026-06-10). Standards rule live
(PDV_STANDARDS.md 5.1). Contract: `PDV_BetaContract.csv` = 765 rows
(706 BETA / 59 FUTURE), inputs frozen at SHA a69bad36. Gate:
`tools/pdv_completeness_audit.mjs` (data + source-reachability + ESP scan
via the Mutagen bridge + runtime-status carry). First sweep:
PASS=267, GAP=33 (hard, structured-authority), GAP-REVIEW=130 (prose
authority - may be proposed names), NEEDS-MANUAL=276, FUTURE=59.
Headline finds: Daedric response MESGs missing for each Prince's NATIVE
race(s) (Azura lacks Dunmer+Khajiit, Malacath lacks Orc - generator
pattern); Breton creed-loss spell set unauthored; Redguard sect/token
notif set unauthored; Sync{Orc,Redguard}NeglectSpell absent in manager
(records exist, never synced); spec-vs-ESP naming drift class
(PDV_State_* vs PDV_StateTrack_*, 26 near-miss annotations).
Next: Phase 4 - user triage of the gap ledger, then fix slices.
Owner: Claude (shared tooling with Codex per user direction)

## 1. Problem

Five times the backend was declared "scaled out" and a gap was later found:
BaanDar SGE flag, deity stance bake, ScoreAction Nord-only skew, ProcessDawn
trigger, Kyne Part B profile / Clavicus name drop (2026-06-10). Common cause:
every gap was an ABSENCE. The verification stack (`pdv_verify`, content verify,
per-race --check helpers) is artifact-anchored - it proves what exists is
well-formed, and cannot flag what was never authored. Completeness claims are
made per-component by the component's author and share the author's blind spot.

Missing boundary: **contracted vs authored** (alongside the existing
readback-proven vs runtime-proven proof boundary).

## 2. Locked decisions (user, 2026-06-10)

| Decision | Ruling |
|---|---|
| Baseline | **Content-Feel Beta bar + player-reachability rule.** Gate tier = Architecture v3 section 25.6 criteria + "anything a beta player can reach and commit to (focusable patron, offered path/mode/sect, curse entry) must have live signal access, reward gating, and surfacing." 1.0-roster texture (full per-pairing authored handling, per-Prince polish) = FUTURE tier, tracked not gating. |
| Authority order | AGENTS.md Decisions Log + Architecture v3 LOCKED sections > PDV_TargetEndStates_1.0.md > race sheets > rubrics/ledgers > older phase docs. No clear winner -> ADJUDICATE lane, batched to user; never silently resolved. |
| Verification depth | Three machine layers per cell: (1) repo data/docs, (2) static .psc source reachability, (3) ESP readback. Runtime stays the user's manual smoke lane; the ledger carries per-cell runtime-proof status from existing ledgers. |
| Fix policy | **Ledger-first.** Complete the whole sweep before fixing; exception = pure silent-drop bugs (one-line name/dead-cell fixes) land inline. Fixes then ship as scoped slices per cluster, each re-running the gate. |
| Tool ownership | Sibling tool `tools/pdv_completeness_audit.mjs` driven by checked-in contract data; both Claude and Codex may use/update tools flexibly (user). Contract-as-data so scope changes never require tool edits. |
| Process rule | PDV_STANDARDS.md gains: "A completeness / scaled-out claim must cite the machine gate that proves it, or it is an opinion." + Decisions Log entry. |
| Extraction execution | Parallel multi-agent workflow fan-out (user opt-in 2026-06-10). |

## 3. Quantified baseline (from the docs)

Beta tier (gates):
- Every race >=1 credible foreground path; every REACHABLE patron/path/mode has
  a live economy (reachability rule).
- Per race: >=1 normal-session positive loop; >=6 rejected-hook families
  (P0/P1) / >=4 (P2); anti-farm rule per accepted hook; Survey/status legible;
  reward floor; stack snapshot <=2 loud always-on boon families; expected +
  edge build. (PDV_PreBetaRaceAcceptanceRubric.md)
- ~3.3 piety/day per god reachable in normal play (8/15/26-day calendar);
  sanctioned exceptions only: Orc mode multipliers, Argonian leaky floor,
  Daedric rite calendars. (PDV_SignalDensityAudit.md)
- Commitment/neglect/decay/curse/UI live; named race obligations testable;
  non-voiced surfaces only.

FUTURE tier (tracked, non-gating): full race x god/Prince pairing texture, V2
dialogue, final-world placement, Experience Mode, CAT-6 broad promotion,
per-Prince runtime/display polish.

## 4. Phases

### Phase 0 - Standards rule (15 min, main loop)
Add the gate-citation rule to PDV_STANDARDS.md + AGENTS.md Decisions Log entry
ratifying this plan. Do first so the rule governs the audit itself.

### Phase 1 - Contract extraction (1 session, WORKFLOW fan-out)
One orchestrated workflow:
- ~7 parallel extraction agents (Sonnet), one per doc cluster:
  1. Race sheets (race-sheets/PDV_RaceDesign_*.md, 10 files)
  2. Deity roster + rulings (Phase2 rulings R1-R8, DeityCoverageMatrix.json,
     reward spec JSONs)
  3. Signals (QuestReactionMatrix.md Parts A-E, SignalDensityAudit,
     RaceSignalMatrix, faucet CSVs)
  4. Rewards/boons (RaceRewardBudgetLedger, CapstoneSignatures,
     RaceContractTemplate)
  5. Daedric (DaedricRacePrinceMatrix, D-15..D-18 locks, Daedric ledgers,
     20C system)
  6. Surfacing/UX (section 16.7 transition contract, Survey/status, toast,
     MCM, neglect)
  7. Locks/descopes (AGENTS Decisions Log, Architecture v3 locked sections,
     TargetEndStates V1/V2 scope) - this agent produces the DESCOPE list the
     merge uses to demote rows to FUTURE.
- Each agent returns structured rows (schema below) with verbatim authority
  citations (file + section/line).
- Barrier: dedup/conflict-merge (genuinely needs all rows), apply authority
  order, mark conflicts ADJUDICATE.
- Fable (main loop) synthesizes -> `references/authoring/PDV_BetaContract.csv`.

Contract row schema:
`surface, race, target (deity/path/mode), requirement, tier (BETA|FUTURE),
authority (doc+section), verify_layer (data|source|esp|runtime-status),
check_hint, status (UNVERIFIED|ADJUDICATE)`

Expected volume: ~400-700 rows. ADJUDICATE batch goes to user in ONE review
pass (capped; if >40 conflicts, precedence rules are wrong - stop and fix).

### Phase 2 - Gate tool (1 session, main loop, no fan-out)
`tools/pdv_completeness_audit.mjs` (sibling to pdv_paired_equity_audit.mjs,
same waiver/exit-code conventions):
- Layer 1 data checks: contract row -> repo artifact (CSV cell, Part B
  profile, doc section, FormList membership in spec JSONs).
- Layer 2 source reachability (static .psc analysis over the live Source dir):
  - Every per-race Handle*/Route* handler reaches AwardCuratedSignal /
    AwardPiety / Record*Scaled (kills the telemetry-stub class).
  - Every SIGNAL_* constant has >=1 call site.
  - Every reachable patron's deity record is fed by >=1 channel (matrix cell,
    faucet, curated, ambient, substrate) - generalizes the equity audit's
    verdict column to the full contract.
  - Quest watch list covers every contracted quest beat.
- Layer 3 ESP readback: orchestrate existing per-race `--check` helpers +
  pdv-stance-author/pdv-daedric-author checks; targeted houseCARL reads for
  cells no helper covers (SGE flags, VMAD props, FLST membership).
- Output: `PDV_CompletenessGapLedger.md` + `.csv` with severity
  (BLOCKS-BETA | DEGRADES | FUTURE | WAIVED | ADJUDICATE) and per-cell
  runtime-proof status copied from PDV_PreBetaRaceGateLedger /
  Phase20 manual evidence ledgers (read, never duplicated).
- Exit 1 on unwaived BLOCKS-BETA. Waivers:
  `references/authoring/PDV_CompletenessWaivers.csv` (cell, reason).

### Phase 3 - Sweep + triage (1 session)
Run the gate, triage the ledger, inline-fix only silent-drop-class finds.
Deliverable: prioritized gap ledger for user review.

### Phase 4 - User review (your pass, batched)
One sitting: adjudicate ADJUDICATE rows, confirm/blast severities, approve the
fix-slice plan. Ledger then LOCKED as the work queue.

### Phase 5 - Fix slices (N sessions, split by nature)
- Data-layer gaps (tranches, profiles, CSVs): Claude sessions.
- Source-wiring gaps (handler double-routing, signal wiring): Claude with
  pdv-papyrus-ck skill; compile 0/0 per slice.
- ESP/record gaps (VMAD, FLSTs, SGE): authoring tools; Claude or Codex
  (Codex preferred for new authoring-tool modes).
Each slice: fix -> compile -> completeness gate re-run -> pdv_verify ->
scoped commit. No slice claims completion without citing the gate (the new
standards rule).

### Phase 6 - Smoke on a gated surface (your lane)
Only after the gate passes at BLOCKS-BETA=0 do you spend in-game hours.
Runtime results feed the existing gate ledgers; the completeness ledger picks
them up read-only.

## 5. Model / executor assignments

| Work | Executor | Why |
|---|---|---|
| Doc-cluster extraction (7x) | **Sonnet** subagents | High-volume doc distillation into structured rows; judgment is in the schema + authority order, not the reading. Cheapest adequate tier. |
| Dedup/merge, conflict precedence, contract synthesis | **Fable 5** (main loop) | Carries the grilled context + authority rulings; the error-prone judgment step. |
| Gate tool authoring + static-analysis design | **Fable 5** (main loop) | Toolchain conventions, equity-audit patterns, protected-file rules live here. |
| Mechanical cross-checks (counts, name resolution, FLST membership) | **Scripts (no model)** | Every cheap task here is better done by node script than by any model - deterministic and rerunnable. |
| ManagerQuest (~9k lines) reachability map | **Script first**, Sonnet Explore agent only for ambiguous wiring | Grep-able patterns cover ~90%; agent reads only the residue. |
| ESP readback residue | houseCARL (main loop) | Already proven this session (dunHunterQST). |
| ESP/record fix slices, new authoring-tool modes | **Codex** preferred | It owns the authoring toolchain; matches existing division of labor. |
| Adjudication, severity, scope calls | **User** | Authority of last resort per locked decision. |
| Opus/Haiku | **Not used** | No task here fits: extraction is Sonnet-adequate, judgment work stays in the main loop, mechanical work is scripted. |

## 6. Historical-gap validation (does the design catch the class?)

| Past gap | Caught by |
|---|---|
| BaanDar missing SGE | Layer 3 ESP (SGE check per deity QUST, already a verify check - contract makes it per-reachable-target) |
| Stance never baked | Layer 3 ESP (VMAD stance props per shared deity) |
| ScoreAction Nord-only skew | Layer 2 (every reachable patron fed by >=1 channel) + contract rows from RaceSignalMatrix |
| ProcessDawn no trigger | Runtime class - gate carries runtime-proof status so the absence is VISIBLE in the ledger instead of assumed |
| Kyne Part B / Clavicus drop | Layer 1 (profile presence) + Layer 2 (name resolution) - already live in the equity audit; completeness gate inherits |
| Telemetry-stub handlers (known open) | Layer 2 reachability - expected to be finding #1 of the sweep |

## 7. Risks / guards

- **Doc drift mid-audit:** freeze contract inputs at Phase 1 start (record git
  SHA in the contract header); doc edits during the sweep re-run extraction
  for that cluster only.
- **Contract noise (over-extraction):** the descope agent (cluster 7) runs in
  the same workflow so FUTURE demotion happens at merge, not in your review.
  ADJUDICATE cap of ~40 rows; beyond that, precedence rules get fixed first.
- **Double bookkeeping:** the gate READS existing ledgers
  (PreBetaRaceGateLedger, Phase20 evidence, equity waivers); it never
  duplicates their content. One fact, one home.
- **Game-folder dependency:** Layer 3 requires the Anvil instance; gate
  degrades to Layers 1-2 with an explicit SKIPPED notice (never silent).
- **Protected files:** `pdv_verify.mjs` untouched unless explicitly asked;
  the completeness gate stays a sibling (user has authorized flexible tool
  updates, but absorption into pdv_verify is Codex's call).

## 8. Estimated shape

- Phase 0: minutes. Phase 1: one workflow session (heaviest token spend).
- Phase 2: one focused session. Phase 3: one session.
- Phase 4: one user sitting. Phase 5: unknown until the ledger exists -
  the whole point is we don't currently know if it's six small holes or a
  structural one. Phase 6: your existing smoke runbooks, now against a
  provably complete surface.
