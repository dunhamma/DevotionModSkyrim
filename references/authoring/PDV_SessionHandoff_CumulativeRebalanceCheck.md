# Session Handoff — Cumulative Rebalance Idempotency Check

**Created:** 2026-06-12
**From:** Daedric-pact-redesign session (Claude)
**To:** the reward-spec / cumulative-rebalance session (owns `tools/pdv_cumulative_rebalance.mjs` + the 10 `PDV_*RewardRecords.spec.json`)
**Why:** you flagged that the rebalance tool was non-idempotent (a 2nd `--write` would double every magnitude across all 9 races) and added an applied-stamp guard. This handoff records the independent verification I ran and one open question for you. I changed nothing in the reward specs/tool.

## Verified (closed)

1. **Stamp present, all 9 races.** Every `PDV_*RewardRecords.spec.json` (Altmer, Bosmer, Breton, Dunmer, Imperial, Khajiit, Nord, Orc, Redguard) carries `cumulativeRebalanceApplied` = "2026-06-11 highest-tier-only consolidation; magnitudes are cumulative totals, do not re-run". (Argonian not stamped — it's on the separate variety-batch track.)
2. **Guard refuses re-application.** `node tools/pdv_cumulative_rebalance.mjs --dry` → all 9 print `SKIPPED -- already cumulative; a re-run would double magnitudes`. No `--force` escape. A second `--write` cannot double anything.
3. **No doubling in committed data.** Spot-checked the value you cited — Orc City Restoration is committed `5 / 13 / 23` (T1/T2/T3). A doubled value would be ~`64-82`; the hazard did NOT materialize. The committed numbers are intact.
4. **Daedric side is unaffected.** The Daedric pact rebalance (`spellPacket()` in `pdv_generate_daedric_contract.mjs` → contract → `pdv-daedric-author` `ConfigureSpell`) sets ABSOLUTE magnitudes and rebuilds effects each run, so it is idempotent by construction (Boethiah Champion = 35, not 70). No stamp/guard needed there. Memory: `rebalance-tool-idempotency`.

## Open question for you (your model, not mine to adjudicate)

The committed magnitudes read as **per-tier increments** (`5/13/23`, T3 player text "+23"), but the stamp says **"magnitudes are cumulative totals"** and the tool comment says City Restoration `5/13/23` *re-sums to* `5/18/41`. Those disagree:

- If the specs are meant to hold **per-tier increments** (engine stacks T1+T2+T3 spells at Champion → effective 41), then the stamp wording "cumulative totals" is misleading — reconcile the marker text so a future editor doesn't hand-tune the wrong representation.
- If the specs are meant to hold **cumulative totals** (highest-tier-only consolidation, T3 = 41), then the consolidation does not appear to have been written into the spec data — only the stamp was applied. Worth confirming the ESP/grant layer actually reflects the consolidated values.

Either way it is the **opposite of doubled**, so it does not touch the idempotency hazard — purely a representation/labeling consistency check.

## Suggested next step

Confirm the intended representation (increment vs. cumulative total), then either fix the stamp wording or re-apply the consolidation to the spec data. Future magnitude tuning is by-hand edits per your rule.
