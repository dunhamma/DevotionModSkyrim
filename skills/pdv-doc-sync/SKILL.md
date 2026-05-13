---
name: pdv-doc-sync
description: >
  End-of-session documentation sync for the PlayerDevotion (PDV) Skyrim SSE
  mod project. Use after meaningful implementation, CK wiring, compile/test
  work, or explicit requests to update/sync project docs. Reads AGENTS.md,
  PDV_Architecture_v2.md, PDV_MOD_SETUP.md, phase docs, and the actual
  Devotion .psc/.pex files to keep project status and decisions consistent.
---

# PDV Doc Sync

Use this skill when PDV work changes implementation state, CK wiring status,
test results, architecture decisions, or phase progress.

## Sources Of Truth

Documentation root:
- `C:\Users\Admin\Documents\Devotion Mod Project`

Canonical living docs:
- `AGENTS.md` - cross-session context, current status, decisions log
- `PDV_Architecture_v2.md` - architecture, phase plan, revision log
- `PDV_MOD_SETUP.md` - tooling, paths, build order, troubleshooting
- `PDV_Phase*_*.md` - phase-specific instructions/status
- `PDV_STANDARDS.md` - operating rules; read when needed, edit only if a rule changes

Implementation truth:
- `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\*.psc`
- `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\*.pex`

Do not use `CLAUDE.md` as canonical. This project now treats `AGENTS.md` as
the living context source.

## Workflow

1. Read `AGENTS.md`, then inspect the relevant phase docs and architecture
   sections for the current phase.
2. Inspect the actual `.psc` and `.pex` files before changing status claims.
   Scripts and compile outputs are the verification layer.
3. Update all living docs that would otherwise drift:
   - build status checkboxes
   - phase summaries and CK/test instructions
   - architecture header/status and revision log
   - decisions/session learnings in `AGENTS.md`
   - tooling/build notes in `PDV_MOD_SETUP.md`
4. Keep archive docs frozen.
5. Report files changed and any residual code or CK wiring risks.

## Status Semantics

- `[x]` means scripts exist, compile, CK wiring is complete, and in-game testing
  confirmed the behavior.
- `[~]` means partially complete, for example scripts compile but CK wiring or
  in-game verification remains.
- `[ ]` means not started.

## Current PDV Defaults

- Source of truth for piety is StorageUtil, keyed by deity form.
- Runtime action capture writes only `PDV.PietyToday`.
- Persistent piety, tier recompute, mirrors, and `OnTierChange` are dawn-owned.
- Phase 3 uses `PDV_ActionRouter` plus Story Manager receiver quests.
- CKPE/MO2 paths and compile import chain live in `AGENTS.md` and
  `PDV_MOD_SETUP.md`; check them before writing compile instructions.
