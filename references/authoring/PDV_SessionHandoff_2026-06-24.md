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
6. **Ancestral-spine parity build** (the big content workstream). **The Spine Stack Score is now BUILT** (`tools/pdv_spine_stack_score.mjs` + `PDV_SpineStackRegistry.csv` → `PDV_SpineStackScoreLedger.{md,csv}`; Argonian=100%, <70%=target; re-run to gate/measure the build). **Worst-first ranking (2026-06-24):** Nord 20% · Imperial 30% · Altmer 30% · Breton 36.7% · Orc 36.7% · Redguard 53.3% · Dunmer 63.3% (the 7 parity targets); Bosmer 73.3% / Khajiit 86.7% / Argonian 100% pass.
   - **6a — Core build (per target, Argonian two-ledger template):** an unconditional band-keyed boon + a spine-owned piety pulse. Start **Nord** (no spine at all); **Dunmer is cheapest** (already has `PDV_Substrate_DunmerAncestor`). Redguard's spine pulse (`SIGNAL_ANCESTOR_SPINE`) already landed this session.
   - **6b — Dead diegetic (dispatch-or-delete):** the Score's deterministic check found **8** declared-but-never-dispatched notifs — Nord `PDV_Notif_Nord_General_AncestorsQuiet`, `PDV_Notif_Nord_Kyne_ChampionAmbient_Storm`; Orc `PDV_Notif_Orc_Witnessed_TheWatchers_{Stronghold,City,LegionExile}`, `PDV_Notif_Orc_HearthHeld_{Declare,Return,MissedCadence}` (the last 3 newly surfaced, NOT in the manual audit).
   - **6c — Specced-but-unemitted minuses (gap #4):** `tools/pdv_specced_minus_audit.mjs` (BUILT) found **18** (ledger `PDV_SpeccedMinusLedger.md`). **TRIAGE DECIDED 2026-06-24** (`PDV_MinusTriage_Decision_2026-06-24.md`): **(A)** per-race spine minuses (Hist×3, Tuwhacca DEATH_DUTY_ABANDONMENT) → wire on the spine pulse in their race builds; **(B)** Daedric (Boethiah TREACHERY, Mephala SECRET_BETRAYED, Malacath×3) → RESOLVED -- wire 3 (Malacath CURSE_CODE_RUPTURE/werewolf, Mephala SECRET_BETRAYED/clumsy-crime, Malacath BROKEN_FAITH_KIN/desertion) + remove 2 (Boethiah TREACHERY, Malacath SELF_ERASURE) via `PDV_DaedricMinus_Wire_Handoff_2026-06-24.md`; **(C)** the **9 pantheon-creed** (Arkay/Magnus/Stendarr/Trinimac/Xarxes) → **REMOVE the dead specs** (no in-game action triggers them; Arkay/Stendarr keep working LD dislikes, Magnus/Trinimac/Xarxes accept pure-positive) — handoff `PDV_MinusRemoval_PantheonCreed_Handoff_2026-06-24.md`. Score `minus_stack` recalibrates after A+B are wired (it's over-credited until then).
   - **6d — Distinct ancestral LD category per culture (gap #1):** Saxhleel/Yokudan/Orsimer… (currently routes through the shared per-deity table with generic verbs).
   - **6e — Renewable maintenance channels (Score dim 4 / gap #6):** sleep/dream + prayer/home for Nord/Breton/Altmer/Redguard/Orc. The Score counts `renewable ×1`; a boon+pulse-ONLY build leaves these races sub-parity on this dim — build it explicitly per target.
   - **6f — Variety-tranche / effect-review (gap #7) — CROSS-LINK:** Altmer/Redguard/Orc variety tranches are blocked "Pending" in `references/authoring/PDV_RaceEffectReviewLedger.md`; its "substrate baseline / broad lane" floor IS this build's unconditional boon. **Same races, one body of work** — do them together, not as two disconnected docs (duplicate-or-skip risk).
   - **6g — Book-of-Days bespoke voice (gap #8):** Imperial/Altmer on the generic fallback (the Score's `text_voice` dim; NOT covered by FinalPolish FP-049, which is the skin).
   - **Burndown reconciliation:** `PDV_BetaFeelBurndown.md` lists Nord/Altmer/Orc/Breton/Redguard as **Pass** — that's the beta-feel-PACKET bar, a DIFFERENT bar than the always-active spine layer (THIN/MODERATE here). Track spine parity via the Score, not the burndown.
   - Full qualitative detail + the parity model in `references/authoring/PDV_AncestralSpine_ParityAudit_2026-06-24.md`.

## The standing tools/artifacts

| Artifact | Path | Run |
|---|---|---|
| Signal-floor audit + registry | `tools/pdv_signal_floor_audit.mjs`, `references/authoring/PDV_SignalFloorRegistry.csv` | `node tools/pdv_signal_floor_audit.mjs` → `PDV_SignalFloorLedger.{md,csv}` |
| E2E wiring gate | `tools/pdv_signal_e2e_gate.mjs` | `node tools/pdv_signal_e2e_gate.mjs` → `PDV_SignalE2EGateLedger.{md,csv}` (exit 1 on RED) |
| Ancestral-spine Spine Stack Score (BUILT 2026-06-24) | `tools/pdv_spine_stack_score.mjs`, `references/authoring/PDV_SpineStackRegistry.csv` | `node tools/pdv_spine_stack_score.mjs` → `PDV_SpineStackScoreLedger.{md,csv}` (Argonian=100%, <70%=target) |
| Ancestral-spine qualitative audit | `references/authoring/PDV_AncestralSpine_ParityAudit_2026-06-24.md` | (doc; verdict + parity model) |
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
