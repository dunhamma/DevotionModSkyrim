# PDV 2.0 — session handoff: FAVOR pilot complete, GATE 0.5 green (2026-08-18)

**Branch:** `feature/v3-big-update` · **Mod folder:** `Devotion-V3Dev` · **Kind:** LIVING.
**Plan of record:** `~/.claude/plans/modular-mixing-lampson.md`. Supersedes the "Next: FAVOR"
section of `handoff/PDV_2_0_Rebuild_SessionHandoff_2026-08-18.md` — FAVOR is now DONE.

## Headline
The Phase-0.5 pilot is complete. **RULES + FAVOR are both extracted and BOTH parity tiers
are green** (static: compile 0/0 + byte-parity; runtime: in-game smoke passed). Per the plan,
**GATE 0.5 is satisfied → Phase 1 fan-out is authorized.**

## What landed this session (commits on `feature/v3-big-update`)
- `3be80b2e` **feat(v3): extract FAVOR module** — 33 fns + 42 props moved to
  `PDV_ContextualFavorRuntime` (extends Quest), Manager backref, retained callers rewired to
  `FavorRuntime.X`. Static parity: moved=27, removed=0, added=0; every changed body prefix-only.
- `f01d1ada` **refactor(migration): not-save-safe sweep steps 2-3** — AncestorSpine_T1 runtime
  descope (grant-fact: selector returns None for Redguard = never granted); Part B
  (ReadZeroReserved `.Encoding`, ArgonianHist stamp body, PlayerEvents book-read `.Seen`);
  Part C (write-only startup keys). Part D (Prisma dead-path) DEFERRED.
- `a653006a` **fix(gate): reconcile substrate-pacing audit** — dropped the stale pin on the
  removed legacy migration; full verifier back to FAIL=0.
- `044f48d0` **docs(v3): FAVOR runtime-smoke runbook** (`references/authoring/PDV_2_0_FAVOR_RuntimeSmoke_Runbook.md`).

## Deploy + ESP wiring (on disk; dev ESP is not git-tracked, by design)
- Mirrored 102 live-source `.psc` → `Devotion-V3Dev/Scripts/Source`; recompiled all `.pex`
  (incl. the 2 new modules). Full verifier FAIL=0.
- **`Devotion.esp` wired in-place** (backup: `Devotion.esp.bak-favor-wiring-2026-08-18`):
  host QUST `PDV_ContextualFavorRuntime` `071791` (StartGameEnabled), script attached, 16 Spell
  fills + `Manager`→`00C325`; manager `FavorRuntime`→`071791`. SEQ regenerated + deployed.
  Integrity: 0 dangling / 0 missing masters; masters Skyrim/Dawnguard/HearthFires/Dragonborn OK.

## Runtime smoke result (owner-in-loop, fresh Altmer)
PASS. Papyrus log (`18:16`–`18:17`): `Contextual favor applied: Orthodox costly enforcement (MCM)`
then `Contextual favor cleared (MCM)`. **Zero None-object faults naming `FavorRuntime`, the
module, `GetActiveDeity`, or `GetPlayerMcmFavorLine`** — the backref wiring is live. Favor line
rendered `Altmer`; toast fired; clear worked; cooldown gated.
- Two owner-observed items confirmed **expected / parity-consistent, NOT regressions**: toast
  deity = `none` (fresh Altmer has no patron; `GetActiveDeity()` correctly returned None, same as
  the inline `_activeDeity` read); the favor spell shows in Active Effects with no magnitude (a
  property of the SPELL record, untouched by the move).

## Open item (small)
- **Orphan VMAD props on the manager**: `Devotion.esp` `00C325` still lists the 16 old
  `PDV_SPEL_Favor_*` script properties (the recompiled manager no longer declares them → 16 benign
  `cannot be initialized` warnings per load). Removal was attempted (indices
  0,2,3,5,6,9,11,16,19,20,21,23,24,26,28,29 — high-to-low) but BLOCKED because SkyrimSE was still
  running (file lock). **Retry the `bulk_apply` Remove once the game is closed**; keep `FavorRuntime`
  ([524]) and every non-Favor prop. Cosmetic only — does not affect the pilot verdict.

## NEXT — Phase 1 fan-out (post-pilot, per the plan's dependency spine)
Order: (3) finish QUESTREACTION delegator routing → (4) **invert the gain-pipeline multiplier
contract** (prerequisite for LEDGER) → (5) LEDGER → (6) OriginRuntimeBase → (7) the 10-way race
adapter fan-out (worktree-isolated) → (8) DAEDRIC (+ externalize `GetPrinceEventTypes`) → (9)
PRISMA → (10) RecognitionRuntime → (11) MANAGER remainder. Each lane's DoD: validity-compile 0/0
(isolated) + static parity + gate-regen (G6 resolver); runtime + deployed PEX batched at Stage
Gate B, not per-lane. Manager is 27,740 lines now; Phase 1 is where the big reductions land.

## Deviations / gotchas learned this session (do not re-derive)
- `pdv_compile --all` masks its exit code behind a wrapper echo AND only compiles the frozen
  release-manifest set — it does NOT build newly-extracted modules. Compile new modules with
  targeted `--script --skip-verify`, and read the verifier verdict from the exit code, not a grep.
- The FAVOR spec undercounted `Trace` in TryActivate (5 not 3) and missed `StripAllPdvSpells` as a
  second reader of the 16 Spell props — the compiler surfaced both. Grep the WHOLE manager for a
  moved property, never trust a single-reader claim.
- MO2 state: `Devotion-V3Dev` ENABLED / 1.5 `Devotion` DISABLED in profile 'Devotion Dev' (owner
  toggled). Flip back when the 1.5 line is needed elsewhere.

## Do NOT
- Touch `mods/Devotion` (1.5 line) or extract from the v1 region map.
- Run deploy-dependent gates or refresh deployed PEX per-lane (batch at Gate B).
- Commit the dev `Devotion.esp` or `_parity_*.json` (gitignored / not tracked).
