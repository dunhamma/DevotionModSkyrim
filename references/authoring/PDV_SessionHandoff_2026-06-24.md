# PDV Session Handoff — 2026-06-24 (next-session pickup)

## TL;DR — where we are

A long signal-surface session. The recurring bug class — **"declared/designed but not wired
end-to-end"** (silent in Papyrus across DESIGN→DECLARATION→WIRING→PROOF) — got turned from a
manual discovery into **machine-checkable gates**. State now:
- **Signal-floor + e2e gate live.** Codex's per-race quest-source fan-out fills landed and were
  reviewed → gate **GREEN 6→26**, floor **PASS 0→5** (`wired_end_to_end`). Fills are live-ESP-verified.
- **Two dead-wire bugs fixed** (Imperial registration; Nord sky-road / Kyne curated-signal).
- **Ancestral-spine parity audit done** → **NOT at parity**; a mechanism-agnostic **Spine Stack
  Score** model is defined.
- **Cross-cutting-audit doctrine** established (now a Standing Rule) + a recommended next workstream:
  the **PDV Integrity & Audit Harness**.

## Recommended next session: build the PDV Integrity & Audit Harness

Consolidate the three ad-hoc tools (floor audit, e2e gate, curated-parity) **+** the Spine Stack
Score into **one re-runnable suite** with a shared registry and generated ledgers, so future
cross-cutting questions are answered by re-running the harness, not a fresh investigation. Add the
deterministic checks we now know we need, and bake in the **houseCARL ESP-reality proof layer**.
- **New checks to add:** dead-declaration (declared property/notif, zero call sites — e.g. Nord
  `AncestorsQuiet`, Orc `Watchers`); design↔code traceability (each race-sheet promise → wiring →
  proof status); specced-but-unemitted-minus (e.g. Redguard `DEATH_DUTY_ABANDONMENT`); curated-signal
  parity (the 71-ref Kyne-pattern detector — handoff exists, not yet built); the Spine Stack Score.
- **houseCARL proof layer:** the harness's bottom layer reads the live records (true load-order
  winner, VMAD values, spell→MGEF wiring, FormList contents) via houseCARL, gated by `pdv_mcp_check`
  liveness, **SKIP-not-PASS** when down. (This session's audits were mostly static-source; houseCARL
  spot-check confirmed zero drift, but the harness must make it standard — see Standing Rule.)
- **First customer:** the spine-parity build (below).
- **Do it gate-first** — build the verifier before authoring under it. That's the lesson that got us here.

## Open items (prioritized)

1. **3 undone Codex handoff deliverables** (all authored, ready to hand to Codex):
   - **Build the curated-signal parity check** into the gate — `references/authoring/PDV_SignalE2EGate_CuratedParity_Handoff_2026-06-23.md` (do first; cheap, no server; would auto-catch Kyne/RedguardSpine-class gaps).
   - **Green Way env-shell fill** — `references/authoring/PDV_GreenWayEnvShell_Handoff_2026-06-23.md` (harvest/weather/book → floor 2/5→5/5; hooks already wired; needs server for ESP fill).
   - **Thin-Prince Part D faucets** — `references/authoring/PDV_PrinceFaucets_Handoff_2026-06-23.md` (build the designed faucets + design Molag Bal's).
2. **RedguardSpine design question** (owner ruling needed): `HandleRedguardAncestorSpine` feeds the **sect-direction track** but awards **no deity piety**. Tu'whacca is fed separately by death-duty acts (`SIGNAL_DEATH_DUTY`), so it's not starved — but a Yokudan-spine source gives 0 ancestor piety. **Fix (award a small Tu'whacca/Satakal pulse) vs intended (sect-weighting only)?** Folds into the broader spine-parity build.
3. **8 static-only-route gate REDs** (Altmer, Bosmer Yffre, Dunmer Azura/Boethiah, Nord OldWays/HircineArkay, Orc): books work but quest-stage routes are `approved-static-route-only`. **Promote those routes (verify stages) or accept partial-wiring** — and decide if the gate should grade per-type vs per-surface.
4. **Green Way fray in-game proof** (MCM, not cqf): tap **Breton → Green Way Fray Test**, advance ~2 in-game days, confirm Survey/label read **frayed** (<30). Negative check: a non-Green Breton and a Betrayed-fork Breton must NOT fray.
5. **2 gate calibrations** (small): run the completeness check **without `--skip-esp`** (kills a false FAIL — the full audit PASSes); reconcile the **ArgonianHist route-name drift** (`RouteArgonianHistMaintenance` in the manifest vs `RouteArgonianHistMaintenanceSource` in code — a false RED).
6. **Ancestral-spine parity build** (the big content workstream, gated by the Spine Stack Score): worst-first — **Nord** (give it an ancestral spine at all), then the 6 patron-gated MODERATE races (add an unconditional band-keyed boon + a spine-owned piety pulse), modelling all on the **Argonian Hist two-ledger template** (substrate metric + honest deity pulse). **Dunmer is cheapest** (already has a substrate). Plus: a distinct ancestral LD category per culture, wire the specced minuses, dispatch-or-delete the dead diegetic declarations. Full detail + the parity model in `references/authoring/PDV_AncestralSpine_ParityAudit_2026-06-24.md`.

## The standing tools/artifacts

| Artifact | Path | Run |
|---|---|---|
| Signal-floor audit + registry | `tools/pdv_signal_floor_audit.mjs`, `references/authoring/PDV_SignalFloorRegistry.csv` | `node tools/pdv_signal_floor_audit.mjs` → `PDV_SignalFloorLedger.{md,csv}` |
| E2E wiring gate | `tools/pdv_signal_e2e_gate.mjs` | `node tools/pdv_signal_e2e_gate.mjs` → `PDV_SignalE2EGateLedger.{md,csv}` (exit 1 on RED) |
| Ancestral-spine audit + Spine Stack Score model | `references/authoring/PDV_AncestralSpine_ParityAudit_2026-06-24.md` | (doc; score not yet a tool) |
| Completeness / paired-equity audits | `tools/pdv_completeness_audit.mjs`, `tools/pdv_paired_equity_audit.mjs` | `node tools/...` |
| ESP-reality proof | houseCARL MCP (`housecarl_read_record`, `_batch_record_detail`, `_cross_plugin_query`, `_conflict_chain`) | needs the Anvil MCP server up; `node tools/pdv_mcp_check.mjs` |

## Gotchas for the next session

- **houseCARL is the ESP-reality layer** — static source can be confidently WRONG vs the ESP (the Requiem spell→MGEF burn). Use it for the proof layer; it also shows load-order conflict winners a source audit can't see. Confirmed houseCARL on the **Anvil / Devotion Dev** profile this session; Devotion.esp active; the P2 FormLists are `winner=Devotion.esp` (no overrides).
- **Live source is the canonical, partly-untracked dir** (the repo `live-source/` is a junction). Edit live, commit scoped. A mod restore can revert untracked live-only edits.
- **Gated curation discipline (DO NOT bypass):** each populated quest-stage source needs `approved-for-fill` + `approvedStages` + houseCARL `stageReadbackEvidence` + `rejectedStageContext` + `duplicateGuard`. The fill tool refuses unapproved entries.
- **Testing is MCM-driven, not cqf.** Wire debug actions as MCM buttons.
- **Deterministic → script/gate; judgment → agent swarm.** Don't run a 1.2M-token swarm for an exact cross-reference.
- **Codex is the primary coding agent** — bulk coding/curation/fills go to Codex via the handoff docs; Claude owns design/gate-spec + reviews each hand-back against the gate (acceptance = gate GREEN for that surface).

## Verification (per change)

`node tools/pdv_compile.mjs --script <name>` (0/0) → `node tools/pdv_verify.mjs` (FAIL=0) → `node
tools/pdv_signal_e2e_gate.mjs` (no new RED) → `node tools/pdv_signal_floor_audit.mjs` (PASS count) →
houseCARL record-readback for the ESP layer. Recompile the quest matrix if it's touched; bump
`LIKES_DISLIKES_VERSION` if the LD CSV is touched.

## Commits this session

`cd3f9a3` Green Way fraying loss-path · `59df7dc` signal-floor audit · `c9db841` (Codex) e2e gate ·
`7b5e081` (Codex) floor harden to wired_end_to_end · `37c915e` Imperial registration fix · `f8c3451`
Nord sky-road / Kyne curated-signal · `44662de` + `cf5a712` Codex handoff batch · `b0310f7` Codex
quest-source fan-out fills (reviewed) · `6ca050b` ancestral-spine parity audit. Memory:
[[cross-cutting-audit-doctrine]], [[green-way-signals-deferred-by-semantic-pass]],
[[rich-daytoday-deities-missing-curated-milestone-piety]].
