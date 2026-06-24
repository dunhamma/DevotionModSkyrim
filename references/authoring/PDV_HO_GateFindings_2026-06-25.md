# HO_GateFindings — Ledger-coverage + anti-farm fixes (Codex Handoff, 2026-06-25)

**Queue A (serialized on `PDV__ManagerQuest.psc`; dispatch after A1).** From the two audit gates
committed `18cd16a`. Each gate is the acceptance check for its fix — run it to confirm CLEAN.

## Fix 1 — Ledger coverage: make Daedric + quest-reaction piety land in the Ledger
The in-game Ledger ("what feeds your gods", `GetDashboardJson` ~1918) renders per-god DRIVERS from
`PDV.Driver.Reasons`/`PDV.Driver.Deltas`, recorded ONLY on the `AwardPietyInternal` path (~8679, the
6-capped ring at ~8744-8750). `node tools/pdv_ledger_coverage_audit.mjs` found **22 earn-time sites
that bypass it** (`PDV_LedgerCoverageLedger.md`) — owner rule: the Ledger must monitor ALL data points.

- **Daedric (18 sites):** `AdjustStoredPiety` → `SetStoredPiety` (`PDV_DaedricPathBase`) → raw
  StorageUtil, NO driver. Entry points: `HandleDaedricPrinceSignal:2539`, `HandleDaedricShrinePrayer:2583`,
  `RouteActionToOpenPaths:7399` (PrinceV2 deepen), per-path `RecordControlledSignal`/`RecordHuntRiteScaled`
  (the 17 `PDV_DaedricPath_*.psc:38` + Hircine:55/66). **FIX: record a driver inside `SetStoredPiety`**
  — it's the single chokepoint all 18 funnel through. Append reason+delta to `PDV.Driver.*` on the PATH
  form, 6-capped exactly like `AwardPietyInternal` (reuse its driver helper if it takes a `Form`; else
  mirror the ring). This makes ALL Daedric piety — incl. the pre-pact "watching" Prince from A2 — show,
  sortable by god + reaction, in the Ledger.
- **Quest-reaction:** `ApplyQuestReactionPiety:1593` writes `PDV.PietyToday` directly, NO driver →
  quest-driven piety is Ledger-invisible. **FIX:** have it record a driver (reason = the quest/act,
  signed delta) on the deity form, same helper.
- **DeclineChampionOffer (`PDV_DaedricPathBase:171`):** sets `PDV.Piety` outside the funnel (minor) —
  record a driver there too, or route it through the standard path.

ACCEPTANCE: `node tools/pdv_ledger_coverage_audit.mjs` → CLEAN (0 UNTRACKED). The 14 substrate
`Record*Scaled` writers are a SEPARATE channel (favor/buff metric, not deity piety) — the audit lists
them but does NOT count them as bypasses; leave them unless a design pass says otherwise.
SAVE-SAFE: pure StorageUtil driver writes + existing helpers — no new property; safe on existing saves.

## Fix 2 — Anti-farm: cap `HandleDunmerReclamationFocus`
`node tools/pdv_antifarm_sweep_audit.mjs` flagged it as the one genuine **UNCAPPED-GAIN**:
`AwardDunmerReclamationFocusSignal` awards POSITIVE piety (Azura `SIGNAL_THRESHOLD_RITE` +1.5 /
Boethiah `RIGHTEOUS_STRUGGLE` / Mephala `SECRET_KEPT`) with only a non-limiting `ReclamationFocusCount++`
— repeatable unbounded within a day from `PDV_EventBus.RouteDunmerReclamationFocus` (EVT 130).
**FIX:** gate the AWARD with `ConsumeOncePerDaySignal` (or a per-focus day-key, like the sibling
`TryAwardDunmerTwilightWindowSignal` already uses) before `AwardDunmerReclamationFocusSignal`, so the
+1.5 rite is once-per-dawn. **Keep the focus-switch (`SetState`/the `ShowP2BookNotice`) ungated** — only
cap the piety pulse.

ACCEPTANCE: `node tools/pdv_antifarm_sweep_audit.mjs` → no UNCAPPED-GAIN.
NOTE: the 11 uncapped PENALTY-only handlers it lists are friction-pacing review, NOT this fix — leave them.

## ⚠️ Serialize on the manager. Verify
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → BOTH gates CLEAN → `pdv_signal_e2e_gate` 0 RED →
`pdv_integrity_harness` PASS. Verify-current-state first (grep the cited line numbers — they may have
shifted as A1 lands first).
