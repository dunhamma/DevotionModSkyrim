# Claude.md - Devotion (PDV) Mod Project

## How Claude Works In This Repo

Codex is the primary coding agent. `AGENTS.md` is the canonical living context
doc for current build status, architecture decisions, project file map, and
decision history. Claude defers to it.

### Rules For Claude Sessions

1. Read `AGENTS.md` at the start of every session for current project state.
2. Do not rely on this file for build status; it is only a Claude entrypoint.
3. Do not overwrite or update `AGENTS.md` unless the user explicitly asks.
4. All Skyrim plugin reads, writes, and verification go through the
   `housecarl_*` MCP tools directly. The legacy bridge tooling is retired --
   see "Skyrim Plugin Work" below.
5. Do not edit toolchain scripts (`tools/pdv_compile.mjs`,
   `tools/pdv_verify.mjs`) unless asked.
6. Do not touch skill files (`pdv-doc-sync.skill`, `pdv-papyrus-ck.skill`,
   `skills/`) unless asked.
7. Before writing or modifying `.psc` files, read the Papyrus guidance in
   `AGENTS.md` and `references/PAPYRUS_KNOWLEDGE_INTAKE.md`.
8. Prefer scoped changes. Avoid unrelated doc rewrites or broad cleanup.

---

## Skyrim Plugin Work

For **all** plugin work -- reading records, resolving load-order winners,
creating or editing records, patching, merging, verification -- call the
`housecarl_*` MCP tools directly. Do not route through, re-implement, or build
a local wrapper, adapter, capability matrix, or authoring helper.

houseCARL is both the writer and the reader. Verification is a direct
`housecarl_read_record` / `housecarl_cross_plugin_query` readback after the
write. That readback **is** the proof -- there is no adapter or proof-ledger
step in between.

The retired layer is gone from disk (`tools/pdv_author.mjs`, `tools/creation-*`,
and every `tools/pdv-*-author` helper; preserved only in
`tools/pdv-authoring-trees-retired-2026-07-13.zip`). Do not resurrect it, extend
it, or copy its dry-run/backup/proof-ledger pattern into new work. If a doc
still tells you to run one of those helpers, the doc is stale -- treat this rule
as authoritative and flag the drift.

If a task looks blocked by a houseCARL limitation, **reproduce it with a direct
`housecarl_*` call on the current version first** and read the actual error. Do
not trust a locally recorded "known issue" without reproducing it; only a
reproduced, current-version failure is real.

The one sanctioned programmatic path is the read-only gate scripts
(`tools/pdv_housecarl_p2_readback.mjs`, `tools/pdv_pantheon_*_readback.mjs`,
via `tools/lib/pdv_housecarl_stdio.mjs`). They speak houseCARL's own MCP
protocol for deterministic CI-style gates. They are not a bridge, and they never
write.

---

## Where To Find What

| Need | Go to |
|------|-------|
| Current build status, file map, decisions | `AGENTS.md` |
| Operating rules and doc hygiene | `PDV_STANDARDS.md` |
| Which ledgers are committed vs regenerated on demand | `PDV_STANDARDS.md` section 5.3 |
| Dev environment, tooling, naming conventions | `PDV_MOD_SETUP.md` |
| Proven v2 architecture baseline | `PDV_Architecture_v2.md` |
| Forward v3 roadmap and architecture | `PDV_Architecture_v3.md` |
| 1.0 product target and per-race acceptance state | `PDV_TargetEndStates_1.0.md` |
| Papyrus API/source guidance | `references/PAPYRUS_KNOWLEDGE_INTAKE.md` |
| Race theology and reward contract | `references/PDV_RaceArchitecture_DesignReference.md` |
| Phase 4 matrices | `references/phase4/` |
| In-game console commands | `PDV_SkyrimConsoleReference.md` |
| Archived phase walkthroughs | `archive/completed-phase-docs-2026-05-16/README.md` |

---

## Project Snapshot

Devotion is a Skyrim Special Edition mod that tracks religious devotion
through the player's race, actions, patron commitments, and religious context.
Per-deity piety lives in StorageUtil; mirror globals exist only for CK
Condition reads.

As of the current canonical docs, the v2 Phase 4/5/6 baseline is proven in
game. `PDV_Architecture_v3.md` owns the forward plan: V3 Preflight, Structural
Skeleton, Pattern Proving, Technical Beta, Content-Feel Beta, and content-rich
1.0 launch readiness.

Do not copy status details from this file into work. Read `AGENTS.md` and the
relevant architecture doc instead.

---

## Coexistence With Codex

- `AGENTS.md` is Codex's canonical project context.
- `Claude.md` is Claude's entrypoint and should stay small.
- Shared docs and scripts can be edited when the user asks, but changes should
  be reflected in the canonical docs when they alter architecture, status, or
  workflow.
