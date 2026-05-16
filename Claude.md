# CLAUDE.md - PlayerDevotion (PDV) Mod Project

## How Claude Works In This Repo

Codex is the primary coding agent. `AGENTS.md` is the canonical living context
doc for current build status, architecture decisions, project file map, and
decision history. Claude defers to it.

### Rules For Claude Sessions

1. Read `AGENTS.md` at the start of every session for current project state.
2. Do not rely on this file for build status; it is only a Claude entrypoint.
3. Do not overwrite or update `AGENTS.md` unless the user explicitly asks.
4. Do not edit toolchain scripts (`tools/pdv_compile.mjs`,
   `tools/pdv_verify.mjs`, `tools/pdv_author.mjs`) unless asked.
5. Do not touch skill files (`pdv-doc-sync.skill`, `pdv-papyrus-ck.skill`,
   `skills/`) unless asked.
6. Before writing or modifying `.psc` files, read the Papyrus guidance in
   `AGENTS.md` and `references/PAPYRUS_KNOWLEDGE_INTAKE.md`.
7. Prefer scoped changes. Avoid unrelated doc rewrites or broad cleanup.

---

## Where To Find What

| Need | Go to |
|------|-------|
| Current build status, file map, decisions | `AGENTS.md` |
| Operating rules and doc hygiene | `PDV_STANDARDS.md` |
| Dev environment, tooling, naming conventions | `PDV_MOD_SETUP.md` |
| Proven v2 architecture baseline | `PDV_Architecture_v2.md` |
| Forward v3 roadmap and architecture | `PDV_Architecture_v3.md` |
| External beta tester expectations | `PDV_BetaTesterBrief.md` |
| Papyrus API/source guidance | `references/PAPYRUS_KNOWLEDGE_INTAKE.md` |
| Race theology and reward contract | `references/PDV_RaceArchitecture_DesignReference.md` |
| Phase 4 matrices | `references/phase4/` |
| In-game console commands | `PDV_SkyrimConsoleReference.md` |
| Archived phase walkthroughs | `archive/completed-phase-docs-2026-05-16/README.md` |

---

## Project Snapshot

PlayerDevotion is a Skyrim Special Edition mod that tracks religious devotion
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
- `CLAUDE.md` is Claude's entrypoint and should stay small.
- Shared docs and scripts can be edited when the user asks, but changes should
  be reflected in the canonical docs when they alter architecture, status, or
  workflow.
