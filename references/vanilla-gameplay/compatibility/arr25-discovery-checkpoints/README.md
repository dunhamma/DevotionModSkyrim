# ARR 2.5 discovery checkpoints

`pdv_arr25_discovery_checkpoint.mjs --init` creates one CSV plus JSON status
file for every immutable batch in `PDV_ARR25_DiscoveryBatches_2026-08-06.json`.
They are factual-reader scratch evidence, not inventory rows and not semantic
approval.

Each CSV row is keyed by `input_id` plus `evidence_id`; the initial mandatory
`PLUGIN` row is the per-plugin sentinel. Change it to `PLUGIN-NO-ROWS`,
`PLUGIN-SUMMARY`, or `PLUGIN-ERROR` after reading, then add one row per QUST or
non-quest signal (`evidence_kind=QUST` or `SIGNAL`). This permits several
factual records per plugin without collapsing them into prose.

The worklist identity fields are immutable. QUST rows must classify expansion
shape as `new-definition`, `vanilla-override-extra-stages` (and list the added
stage numbers), or `existing-stage-edits-only`. Readers may fill factual record
fields, evidence, signal counts, and provisional triage/reason. Leave
`primary_review_status` as `UNREVIEWED`; only the primary agent may change it
after theology and cross-generation review.

The adjacent JSON records retry-safe operational state. Use `--increment-attempt`
for every renewed reader pass, `--complete INPUT_ID` only after that CSV row has
`reader_status=read`, and keep the exact direct-reader error in `--error`. A batch
is `complete` only after every input is read and `lastError` is clear.

Examples:

```powershell
node tools/pdv_arr25_discovery_checkpoint.mjs --init
node tools/pdv_arr25_discovery_checkpoint.mjs --batch A001 --status in_progress --increment-attempt
node tools/pdv_arr25_discovery_checkpoint.mjs --check --batch A001
```
