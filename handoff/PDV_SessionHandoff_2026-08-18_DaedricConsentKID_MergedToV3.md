# Session handoff — Daedric-consent + KID hotfix merged into feature/v3-big-update

**Date:** 2026-08-18
**Branch:** `feature/v3-big-update` (V3 worktree)
**Merge commit:** `252eb0ea` (parents `81dd2965` V3 tip + `b77c87ae` hotfix fix-range tip)
**Status:** git merge DONE + compile-verified. NOT pushed. Devotion-V3Dev NOT touched (owner decision).

This is a pointer to state at the time of writing, not a live status source. Re-derive
before relying on it.

## What was merged

Merged the five *fix* commits of `hotfix/1.5.0e-daedric-consent-kid` (up to `b77c87ae`)
into `feature/v3-big-update`. Deliberately EXCLUDED the two 1.5.x release-bookkeeping
commits above them:

- `da762400` release(1.5.0e): `PDV_BUILD_VERSION=1.5.0e`, CHANGELOG "prerelease e",
  regenerated housecarl proof (Devotion Dev profile ESP), manifest 233->236, and a
  toast-size Prisma canonical sync that V3 already carries.
- `3ef4721a` docs(handoff).

Reason: V3 ships as 2.0.0 with its own numbering; 1.5.x is a separate maintenance line,
so none of that bookkeeping belongs on the V3 branch. Owner ratified "fix commits only."

Fix commits merged (merge-base `eaa4868`):

| Commit | What |
|---|---|
| `718fc43d` | KID: exclude survival water from Sanguine; disable never-approved Zenithar trade-good + Hircine trophy lanes (vendor-keyword leaks). |
| `978e89fb` | Daedric pact consent gate, formal offer, rate-limits, migration. |
| `ebfea449` | MCM consent debug harness (Sanguine subject). |
| `409609b7` | Prince offers integrated into the formal offer system. |
| `b77c87ae` | Book of Days shows the Prince as patron after a consent-accepted pact. |

Files changed: 19 `.psc` (`PDV__ManagerQuest`, `PDV_MCM`, `PDV_DaedricPathBase`, 16
`PDV_DaedricPath_*`) + `mod-data/PDV_ItemRecognition_KID.ini`.

## Conflict resolution (against V3's refactored manager)

Only `PDV__ManagerQuest.psc` conflicted (4 hunks); everything else auto-merged.

- **OnInit / OnUpdate:** added only `MigrateDaedricConsentIfNeeded()`. Did NOT re-add the
  incoming `MigrateDaedricPactsIfNeeded()` / `MigrateBroadPantheonPools()` — both were
  removed on V3 (Part A migration sweep, `af7e668e` / `39fb7aa4`). Calling them would not
  compile.
- **`MigrateDaedricPactsIfNeeded` body + its "Hard-switch migration" doc comment:** dropped
  (the function is gone on V3; the comment was already orphaned there and would have
  mis-capped the consent migration).
- **`SetPrismaToastLargeEnabled`:** kept V3's `PDV_DevotionRules.BoolToInt(...)` over the
  incoming bare `BoolToInt` (RULES-module extraction).
- **Re-homing (only edit beyond conflict markers):** qualified 3 consent-harness
  `FormatTwoDecimals(...)` call sites to `PDV_DevotionRules.FormatTwoDecimals(...)`. V3
  extracted `FormatTwoDecimals` into `PDV_DevotionRules` as a Global; the bare form failed
  to compile (6 errors at lines 20459 / 20520 / 20538). Caught by the compile gate, fixed,
  re-verified.

Note: `PDV_MCM` auto-merged cleanly — V3 already had the toast-size option and the
"(experimental)" recognition wording; only the consent debug block is new.

## Compile gate (live re-run, exit 0)

All 19 affected scripts compiled `0 error(s), 0 warning(s)` via `pdv_compile.mjs` with
`PDV_COMPILE_SOURCE_ROOT`/`PDV_TRACKED_SOURCE_ROOT` = git `live-source/Scripts/Source`,
output to a scratch dir (no mod folder written). This proves the merged source compiles;
it is NOT a full `pdv_verify` and does not deploy.

## Minor known-cosmetic (not fixed, flagged)

Two merged manager comments still reference the now-removed `MigrateDaedricPactsIfNeeded`
as design rationale (line ~645 "owned by MigrateDaedricPactsIfNeeded"; the consent-migration
comment "so it never fights MigrateDaedricPactsIfNeeded"). Harmless, left to avoid scope
creep; fix if doing a doc pass.

## DEFERRED — Devotion-V3Dev is divergent; do NOT blind-deploy

Owner decision this session: do not touch Devotion-V3Dev. Findings that drove it:

- **KID already fixed there, differently and arguably better:** V3Dev excludes SunHelm
  water by FormID (`-0x07AA96~SunHelmSurvival.esp`, "verified against the live load order");
  the hotfix/git version uses a name match (`-Bottle of Water`). Overwriting would regress
  precision.
- **Consent partially present:** V3Dev's `PDV_DaedricPathBase` already carries the consent
  latch, but the manager wiring, per-path `GetCommitmentOfferMessage` overrides, and the MCM
  harness are ABSENT — mid-development.
- **Different manager lineage:** V3Dev's deployed manager has 0 references to
  `PDV_DevotionRules` (git branch depends on it) and is missing that file entirely; it also
  lacks the Part A migration removal. git is ahead on the RULES refactor; V3Dev is behind.
- **Active today:** `PDV_MCM.pex` (09:56) and `PDV__ManagerQuest.pex` (07:44) were compiled
  2026-08-18 — concurrent work in that un-versioned folder.

Reconciling V3Dev is a two-lineage merge, not a recompile. Whoever owns V3Dev should decide
whether its local FormID-KID and partial consent work flow back to git, and only then deploy
the remaining consent pieces + resolve the `PDV_DevotionRules` divergence + compile there.

## DEFERRED — ESP-side consent MESG records (not in git)

The hotfix reworded 16 Daedric Prince `_Commitment` MESG records (Prince-name header,
em-dash wording, 3-button Accept/Wait/Refuse offer). These live in `Devotion.esp`, not git.
The consent offer's `Show()` branches on a 3-button choice, so the MESG rewording is
functionally required for the in-game flow. Applying it to V3Dev's `Devotion.esp` needs
houseCARL against the "Devotion V3 Dev" profile (a shared, global MO2 toggle) and is
deferred with the V3Dev deploy above.

## Next actions (owner)

1. Decide push of `feature/v3-big-update` (merge `252eb0ea`). Not pushed pending confirmation.
2. Reconcile Devotion-V3Dev deliberately (see divergence above) before any deploy/playtest of
   the consent feature there.
3. Apply the 16 `_Commitment` MESG consent records to the V3-line ESP when V3Dev deploy is
   scheduled.
