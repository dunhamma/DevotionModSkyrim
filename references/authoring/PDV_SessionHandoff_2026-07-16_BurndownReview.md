# PDV Session Handoff -- Burndown Review Setup (2026-07-16)

Purpose: spin up a 1.0 burndown-review session fast. Paste/point a fresh session
at this file; it has the current numbers, the refresh commands, what remains, and
the gotchas that otherwise waste the first 20 minutes.

---

## 0. TL;DR

- **Felt-family: 93/151 (62%), 58 pending** -- the long pole.
- **PS-A pantheon/substrate adversarial lane: 12/12 cards DONE** (30/30 buckets).
- **Experience Mode smoke: 2/2 DONE.**
- **All 9 machine gates green** on a bridge-live `--run` (integrity needs the bridge).
- Remaining to 1.0 is in-game evidence + packaging. Estimate ~5-6 sessions.

---

## 1. Refresh the burndown (do this first)

The generated `PDV_1_0_EndStateBurndown.md/.json` are **gitignored / regenerable**
(policy: PDV_STANDARDS 5.3). Do NOT git-add them. Regenerate on demand:

```powershell
node .\tools\pdv_1_0_endstate_gate.mjs            # read-mode, fast
node .\tools\pdv_1_0_endstate_gate.mjs --run      # re-execute machine gates (needs bridge for integrity)
```

For a clean machine-green read you need the Anvil MCP bridge up:
open `D:\Wabbajack\modlists\Anvil\Anvil.exe`, then MO2 Tools > Start/Stop MCP Server
(127.0.0.1:27016), then `--run`. Headless is fine for everything EXCEPT
`C-AUDIT-INTEGRITY` (signal_e2e needs the bridge to confirm dispatch).

Narrative burndown (hand-maintained): `references/authoring/PDV_BetaFeelBurndown.md`.
Ship truth is the contract gate; where they disagree, the gate wins.

---

## 2. Current snapshot (2026-07-16)

| Lane | State |
| --- | --- |
| C-FELT-FAMILY | 58/151 open (93 done, 62%) -- LONG POLE |
| PS-A adversarial (C-RUNTIME-PANTHEON-SUBSTRATE) | 12/12 cards, 30/30 buckets -- DONE |
| C-EXPMODE-SMOKE | 2/2 -- DONE |
| C-PACING-SIGNOFF | 1/10 (Imperial only) -- folds into felt sittings |
| C-REQUIEM-TRACKB | 0/4 -- Authoria sweeps; M/S->Fortify build done, runnable |
| C-DISLIKE-DEBUFF-TUNING | 0/1 -- anti-stack legibility under Requiem |
| C-COMPAT-ARR | 0/1 -- maintainer-accepted packet |
| C-COMPAT-BORDELLO | 0/6 slots = **2 build-targets** (DoD-base + JOJ-base, shared removal set), ~1 session |
| mainQuestFullCoverageRuntime | 5 pending -- newer slot group, confirm scope with Codex |
| Machine gates (9) | green on bridge-live --run; C-PLACEMENT-FINAL folds into race sittings |

---

## 3. What's left + rough estimate (~5-6 sessions)

- **Felt-family sweep** (58 families, 8 race sittings) -- ~2-3 sessions. THE work.
- **Requiem Track B** (Authoria instance) -- ~1 session.
- **ARR compat** packet -- ~1.5 sessions (no game).
- **Bordello compat** -- ~1 session (2 build-targets, 6 sign-offs).
- Pacing sign-offs (9), placement hooks, dislike tuning -- fold into the above.

---

## 4. Felt-family sittings (the operator checklist)

Location: co-test runbook, section **`## Felt-Family Race Sittings (deduplicated plan)`**
(search the header -- line number drifts as Codex edits the runbook).
Regenerated 2026-07-15, optimized: shows only the 58 remaining, neglect-first flow,
tiny stragglers flagged. Sittings (descending): Altmer 11, Orc 10, Dunmer 9,
Argonian 8, Redguard 8, Bosmer 5, Breton 4, Khajiit 3 (quick).

Cross-cutting is nearly spent: **53/58 are locked to one origin**; only 5 shared
families cross-cut (already deduplicated -- prove once). Treat the 58 as ~8
independent per-race jobs.

Per-sitting flow that matters: prime **neglect-eligible FIRST**, work everything
else while a dawn passes, advance one dawn, read the neglect debuff LAST.

To regenerate when the ledger drifts (new families authored / batch recorded):
the generator captures `--sitting <Race>` per race, dedup-assigns shared
families, filters to pending, groups neglect-last. Ask the session to
"regenerate the felt sittings" -- it is a one-command refresh.

---

## 5. Living widgets (for the review visuals)

Two charts, kept living: build-arc + projection-to-1.0. Regenerate identically per
`references/authoring/PDV_LivingWidgets_Handoff_2026-06-24.md` (Widget 1 = daily
commit bars + milestones; Widget 2 = horizontal remaining-effort bars, single-axis).
Refresh data from git (`git log ... | uniq -c`) and the ledgers, then `show_widget`.
Current: ~793+ commits over a 60+-day span; felt 62%; PS-A done.

---

## 6. Recent context / fixes (last 2 days)

- `ed1a36df` -- Altmer enchant substrate toast-suppression fix (mid-menu skill-increase
  was stealing the daily credit from the post-menu enchant-item event 331). Root cause
  (menu-eaten toast) inferred from log, CONFIRMED in-game 2026-07-15 (granted marker).
- `47f79d4a` -- enchant heritage flavor reworded; closed PS-A10 organic route.
- `4d9124d7` -- felt-family sittings regenerated from live ledger, optimized.
- `7528f5d4` -- broad pantheon audit event-ownership fix.
- `e2af2307` -- Altmer vampire curse chronicled in Book of Days.

---

## 7. Gotchas (these trip up a fresh session)

- **EndStateBurndown.md/.json are gitignored** -- regenerable reports; NEVER git-add.
  If a session tries to commit them, that is the drift, not progress.
- **Integrity gate is stamp-only** -- it flips RED on ANY headless harness run
  (needs the bridge). `? GREEN / 0 RED` = bridge down, not a regression.
- **git <-> MO2 source split** -- `pdv_compile` compiles the MO2 copy and REFUSES on
  drift; after editing `live-source`, sync git->MO2 (`cp`) before compiling.
- **Parallel Codex session is active** -- it edits the manager, the runbook, and the
  evidence ledgers continuously. Before committing any shared file: re-read it,
  verify the diff is ONLY yours (additive), and stage that file explicitly. The
  runbook line numbers drift between commits -- search headers, do not bookmark lines.
- **Felt/PS ledgers are living** -- the runbook checklist is a snapshot; the ledger is
  the authority. Regenerate the felt sittings when the pending set moves.
- **Machine "green" reflects live-source + live ESP** -- deploy/recompile to MO2
  before an in-game sitting or you test the old build.

---

## 8. Key files

| Need | File |
| --- | --- |
| Ship gate (authority) | `references/authoring/PDV_1_0_EndStateContract.json` + `pdv_1_0_endstate_gate.mjs` |
| Narrative burndown | `references/authoring/PDV_BetaFeelBurndown.md` |
| Felt evidence (authority) | `references/authoring/PDV_FeltFamilyEvidenceLedger.json` |
| Operator checklist | `references/authoring/PDV_1_0_CoTest_Runbook_2026-07-10.md` |
| Widget regen | `references/authoring/PDV_LivingWidgets_Handoff_2026-06-24.md` |
| Manual sign-offs | `references/authoring/PDV_1_0_ManualSignoffLedger.json` |
| Pacing sign-offs | `references/authoring/PDV_PacingSignoffLedger.json` |
