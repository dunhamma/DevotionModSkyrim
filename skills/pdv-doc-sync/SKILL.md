---
name: pdv-doc-sync
description: >
  End-of-session documentation sync for the PlayerDevotion (PDV) Skyrim SSE
  mod project. Use after meaningful implementation, CK wiring, compile/test
  work, or explicit requests to update/sync project docs. Reads AGENTS.md,
  PDV_Architecture_v2.md, PDV_MOD_SETUP.md, phase docs, and the actual
  Devotion .psc/.pex files to keep project status, decisions, and durable
  session learnings consistent.
---

# PDV Doc Sync

Use this skill when PDV work changes implementation state, CK wiring status,
test results, architecture decisions, or phase progress.

This skill also serves as the project's end-of-session learning capture. It
should convert important chat takeaways into durable project memory instead of
leaving them stranded in conversation history.

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
4. Perform a session learnings capture pass:
   - identify what was newly learned in the session, not just what files changed
   - keep only durable learnings: workflows, constraints, gotchas, verified
     behavior, architecture decisions, tool quirks, and repeatable debugging
     knowledge
   - do not record ephemeral chat noise, speculative brainstorming, or
     unverified hypotheses unless they hardened into a real decision
   - place each learning in the narrowest durable home:
     - `AGENTS.md` for cross-session state, decisions, and session notes
     - `PDV_MOD_SETUP.md` for environment, build, CK, MO2, compiler, and tool
       workflow knowledge
     - `PDV_Architecture_v2.md` for system behavior, invariants, and design
       decisions
     - `PDV_Phase*_*.md` for phase-specific CK steps, testing flow, and
       verification notes
     - `PDV_STANDARDS.md` only when a true project rule changed
   - if a learning came from investigation rather than code changes, still
     record it if it would save future re-discovery
5. Keep archive docs frozen.
6. Report files changed, what learnings were captured, and any residual code or
   CK wiring risks.

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

## Learning Capture Heuristics

Promote a session takeaway into docs when it is:

- a verified workflow that should become the default next time
- a constraint or limitation that changes how future work should be done
- a debugging result that rules in or rules out a class of failure
- a terminology or architecture clarification that future sessions will rely on
- a toolchain or CK/MO2 quirk that would otherwise be rediscovered the hard way

Leave it out when it is:

- a temporary hypothesis that was not verified
- conversational framing with no project impact
- duplicate wording already captured cleanly elsewhere

## End-Of-Session Output

When this skill runs, the final report should explicitly include:

- which docs were updated
- which durable learnings were captured
- any important learnings intentionally not recorded because they were still
  provisional
- what remains unresolved
