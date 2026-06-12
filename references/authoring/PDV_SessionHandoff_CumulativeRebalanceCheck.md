# Session Handoff - Cumulative Rebalance Idempotency Check

**Created:** 2026-06-12
**From:** Daedric-pact-redesign session (Claude)
**To:** reward-spec / cumulative-rebalance session
**Why:** the rebalance tool is non-idempotent if re-run over already-stamped specs. This handoff records the guard and the resolved wording decision.

## Verified

1. **Stamp present, all 9 races.** Every non-Argonian `PDV_*RewardRecords.spec.json` carries `cumulativeRebalanceApplied` = "2026-06-11 highest-tier-only guard applied; magnitudes are current absolute tier values, do not re-run". Argonian is on the separate variety-batch track.
2. **Guard refuses re-application.** `node tools/pdv_cumulative_rebalance.mjs --dry` prints `SKIPPED -- stamped absolute tier values` for all 9 stamped specs. No `--force` escape exists.
3. **No broad retune in this session.** Current magnitudes are preserved. Future tuning should edit the absolute tier values in the spec by hand, then regenerate/read back the affected descriptions and records.
4. **Daedric side is unaffected.** The Daedric pact rebalance sets absolute magnitudes and rebuilds effects each run, so it is idempotent by construction. No stamp/guard is needed there.

## Closeout

The committed magnitudes are treated as current absolute tier values. The older "cumulative totals" wording was misleading and has been replaced; no magnitude rewrite is implied by this handoff.
