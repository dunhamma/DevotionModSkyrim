# Retired: CKRA / legacy houseCARL bridge artifacts (archived 2026-07-14)

**Do not cite anything in this folder as a description of houseCARL's capabilities.**

These files are the frozen output of the retired CKRA bridge layer. They are kept
for forensics and history only. They are archived out of the agent-readable doc
paths on purpose: their contents are **false** as a description of the current
tooling, and a future agent that greps them will reach the wrong conclusion.

## Why this is dangerous, specifically

`generated/capability-matrix.skyrimse.json` declares:

```
"supported": 1
"research_only": 116
```

That describes the **retired bridge**, not houseCARL. houseCARL reads and writes
**every record type Mutagen models, by construction**. There is no partial-coverage
matrix, and there is nothing to maintain here.

## What replaced it

All Skyrim plugin reads, writes, and verification go through the `housecarl_*` MCP
tools directly. Verification is a `housecarl_read_record` /
`housecarl_cross_plugin_query` readback after the write -- that readback is the proof.
No adapter, no output-scraping layer, no proof-ledger pipeline in between.

The authoritative rule, including the full list of stale beliefs not to re-derive,
lives in `AGENTS.md` under **"houseCARL v1.7+ Direct Plugin Work Rule"**.

## Contents

- `generated/capability-matrix.skyrimse.*` -- retired-bridge capability matrix (false; see above)
- `generated/platform-v1-*`, `generated/platform-v2-*` -- proof-ledger / promotion-candidate output
- `fixtures/` -- CKRA-era proof fixtures: `ckpe`, `creation-fill-spike-v1`, `dialogue-v1`,
  `payload-v1`, `platform-v1`, `platform-v2-operation-expansion`, `promotion-candidate`

The retired Mutagen/CKPE authoring helper trees themselves (`pdv_author.mjs`,
`creation-authoring`, `creation-merge-runner`, all `pdv-*-author`) are preserved
separately in `tools/pdv-authoring-trees-retired-2026-07-13.zip`.

If a task looks blocked by a houseCARL limitation, reproduce it with a direct
`housecarl_*` call on the current version and read the actual error. A limitation
recorded in this folder is not evidence.
