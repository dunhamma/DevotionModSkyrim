# Signal End-to-End Wiring Gate — Codex Handoff (2026-06-23)

**Mission:** Build `tools/pdv_signal_e2e_gate.mjs` — a **read-only, fail-closed** gate that proves
each PDV signal surface is wired **manifest ↔ live-ESP ↔ Papyrus ↔ piety-sink**, so a surface can
**never be marked "complete / ready / approved / wired" without proof.** This is the standing
anti-false-complete discipline. It does **not** author content; it judges it.

**Why:** Two audits found the same rot — content marked ready that doesn't fire end-to-end. The
signal-floor audit (`tools/pdv_signal_floor_audit.mjs`) trusts the **manifest**; the P2 handoff
(`PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md`) read the **live ESP** and found **23 of 39
`PDV_FLST_P2_*Sources` FormLists are empty shells** (steps 1–5 wired, step 6 never done). They agree
today, but nothing **enforces** it. This gate enforces it.

## Reuse, do NOT rebuild

The verifiers already exist in pieces; the gate is an **orchestrator** that runs them and reconciles
their outputs into one ledger. Do not reimplement any of these:
- **P2 receiver author** (`tools/pdv-phase20-p2-receiver-author`) five read-only modes:
  `--check-formlists`, `--check-alias-properties`, `--check-source-fill`, `--check-route-entries`,
  `--check-exact-stage-gates`. Invoke via
  `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- <mode>`.
- **Completeness audit** (`tools/pdv_completeness_audit.mjs`) — already computes handler→piety-sink
  **depth-2 reachability** (does a `Handle*` reach `AwardCuratedSignal`/`AwardPiety`/`ApplyDeityReaction`/
  `Record*Scaled`/`AddCommitmentSignal` directly or via one hop). Consume its source-fact output.
- **Manifest** `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json` — `sourceProperties`,
  `sourceFillEntries`, `routeEntries` (with `reviewStatus`), `questStageGate`.

## The 6-step chain the gate asserts (per signal surface = per `PDV_FLST_P2_*Sources` + its route/handler)

1. **Shell** — FLST exists (`--check-formlists`).
2. **Alias property** on `PDV_PlayerEvents` (`--check-alias-properties`).
3. **Registration** — `RegisterQuestStageList(<FormList>)` present (static parse of `PDV_PlayerEvents.psc`).
4. **Route branch** — `ShouldRouteP2Source(...)` or `ShouldRouteP2QuestStage(...)` for this FormList
   exists and calls the right EventBus route (`--check-route-entries` + static parse).
5. **Handler reaches a piety sink** — the EventBus route's manager `Handle*` reaches a piety/relation
   increment with an anti-farm guard (consume completeness-audit reachability + grep the handler for
   `ConsumeDailyRepeatMultiplier` / a day-key).
6. **Populated in the LIVE ESP** — the FLST actually contains records (`--check-source-fill`), AND the
   manifest `sourceFillEntries` for it match the ESP (no drift), AND any quest-stage route is
   `approved-live-source-fill` (NOT `approved-static-route-only`).

## Output

`references/authoring/PDV_SignalE2EGateLedger.md` + `.csv`. Per surface, one row with a column per
step (PASS/FAIL/`SKIP`), a `verdict` (GREEN iff steps 1–6 all PASS; RED otherwise), and a
`failing_step` note. Plus a summary (counts) and a RED list grouped by failing step. **Exit code 1 if
any surface is RED** (fail-closed) so it can gate CI / pre-commit.

## Server-down degradation (REQUIRED)

The Anvil MCP / houseCARL server may be down (currently is, `127.0.0.1:27016`). Steps that need the
live ESP (`--check-source-fill`, `--check-formlists`, `--check-alias-properties`, the manifest↔ESP
reconcile) must degrade to `SKIP` (status `UNKNOWN-server-down`), NOT crash and NOT silently PASS. The
static layers (registration, route branch, handler reachability, route `reviewStatus`, manifest parse)
ALWAYS run. A surface with any `SKIP` is `INCOMPLETE`, never GREEN. Print a one-line banner when the
server is down. Add `node tools/pdv_mcp_check.mjs` (or a socket probe of 27016) as the liveness gate.

## Acceptance (prove before hand-back)

- Run on the current tree. Expect **RED for the 23 empty-shell `*Sources` FormLists** (step 6 fail),
  RED/INCOMPLETE for static-only quest-stage routes (Nord MQ104/MQ304, Redguard MS08), and the gate's
  exit code is 1.
- A known-good surface (e.g. a populated FormList with a live route + reachable handler, like
  `BretonHiddenArtSources` book sources → `RouteBretonHiddenArtExposure` → handler) reads GREEN (or
  INCOMPLETE only because of server-down ESP `SKIP`, never falsely GREEN).
- No existing file is modified except the two new ledger outputs and the new tool.

## Hand-back

Deliver: `tools/pdv_signal_e2e_gate.mjs`, the generated ledger (`.md`/`.csv`), a 10-line README block
at the top of the tool explaining each column + the GREEN/RED/INCOMPLETE rule, and a one-paragraph
note confirming it **invokes** (not reimplements) the five `--check-*` modes + the completeness audit.
Claude reviews the ledger against the floor audit before this is accepted.

## Model / cost

Well-specified orchestration → build with **Sonnet** (or Codex). Reserve Opus for reviewing the
hand-back. Plain ES-module JS, `node:fs` + `child_process` only, no external deps.

## Files
- New: `tools/pdv_signal_e2e_gate.mjs`, `references/authoring/PDV_SignalE2EGateLedger.{md,csv}`
- Reuse: `tools/pdv-phase20-p2-receiver-author/*`, `tools/pdv_completeness_audit.mjs`,
  `tools/pdv_mcp_check.mjs`, `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`,
  `live-source/Scripts/Source/PDV_PlayerEvents.psc` (static parse).
