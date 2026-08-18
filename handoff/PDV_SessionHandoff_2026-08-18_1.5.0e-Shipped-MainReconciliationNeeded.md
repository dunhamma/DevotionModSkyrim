# Handoff 2026-08-18 -- 1.5.0e shipped; hotfix<->main reconciliation needed

## Status: 1.5.0e is SHIPPED and DONE

- GitHub **Latest** full release `v1.5.0e` (promoted from prerelease), zip asset attached:
  `Devotion-FOMOD-1.5.0e-20260817.zip` (769 entries, 9.4 MB, player-facing scan clean).
- Branch `hotfix/1.5.0e-daedric-consent-kid` @ `da762400`, pushed. **PR #96** open vs `main`.
- Fixes (3 bugs): KID water->Sanguine leak; Hircine/Zenithar vendor-keyword leaks (both lanes
  disabled); Daedric pact consent + rate-limit + Book-of-Days patron display.
- Dev ESP is not git-tracked (ships in zip). release-proof refreshed to the consent-edited ESP
  (contested set + critical winners unchanged).

## DO NOT naive-merge PR #96 -- main has diverged ~20 commits in parallel

Merge-base is `eaa4868d` (old). Since then `origin/main` gained Codex's 1.5 work: Daedric deeds
(b615e49b, 81b5f67e prince boon/price), Triumvirate compat + EVT_350, migration Part-A removals
(MigrateDaedricPactsIfNeeded, MigrateBroadPantheonPools, 4 trace-only), startup fixes, quest
coverage. PR #96 is CONFLICTING/DIRTY.

**Overlapping files (heavy conflict surface):** `live-source/Scripts/Source/PDV__ManagerQuest.psc`
(both sides large edits), `PDV_MCM.psc`, all 3 Prisma view files (`app.js`/`index.html`/`styles.css`),
`CHANGELOG.md` + `dist/release-meta/CHANGELOG.txt`. The 3 QuestStageAdapter files
(FreeformRiften02/03, Staada) were ADDED by main -- that's why the hotfix manifest was short (233->236).

## Reconciliation plan (deliberate, next session -- not on phone)

1. Rebase `hotfix/1.5.0e-...` onto current `origin/main` (or merge main into it). Resolve
   `PDV__ManagerQuest.psc` 3-way carefully -- main's Daedric-deeds/prince work vs the consent stack.
   Both must survive. Watch for silent revert of main's work.
2. **KID fix -- pick ONE implementation (currently TWO exist):**
   - main worktree has an UNCOMMITTED competing fix (Codex): Sanguine excludes by FormID
     `-0x07AA96~SunHelmSurvival.esp` on `*Mead` only ("only leaking record, verified vs live LO").
   - hotfix shipped (718fc43d): name exclusion `-Bottle of Water` on all 4 alcohol lines.
   - Owner's earlier concern (waterskins / other water items) favors the broad NAME approach; the
     FormID approach is SunHelm-specific and would miss others. Decide, then unify. Zenithar/Hircine
     disable is identical on both sides.
3. **PRESERVE the uncommitted main-worktree change first** (`mod-data/PDV_ItemRecognition_KID.ini`,
   on branch `main`) before any rebase/checkout there -- it is Codex's WIP and a checkout would drop it.
   It was left untouched this session.
4. Re-run `pdv_verify` + repackage only if the reconciled source changes what ships (1.5.0e is already
   out; next 1.5-line build is **1.5.1**, NOT 1.5.0f -- lettered scheme retired).

## Recurring issue filed
Spinoff chip: live-vs-canonical drift guard for Prisma + manifest payload (the .psc path has a compile
drift guard; Prisma/manifest have none, so drift only surfaces at package time as a gate cascade).
