# HO: Daedric Surfacing -- Survey + Book of Days (Codex Handoff, 2026-06-25)

Queue: A2. Decision: D2 (per-race Survey + Book-of-Days must surface Daedric worship like patrons).

## VERIFY-CURRENT-STATE FIRST (do this before authoring anything)

Multiple items in this queue were found ALREADY-BUILT this session. The D2 gap
as originally stated -- "per-race Survey has ZERO Daedric refs; Book of Days
never logs Daedric worship" -- is, as of commit `ab193cb` (2026-06-22, "Unify
patron deities + Daedric Princes: data-layer exclusivity + full surfacing"),
SUBSTANTIALLY RESOLVED. Grep the live manager and confirm the seams below
still exist before you touch them. If they are intact, the only work left is the
two narrow residual seams in the "Remaining gap" section -- and a coding agent
must NOT re-add the surfacing that is already present.

Ground-truth greps (run against
live-source/Scripts/Source/PDV__ManagerQuest.psc):

- `git log -1 -L 15217,15229:.../PDV__ManagerQuest.psc` -> should show `ab193cb`.
- Survey short-circuit: `GetSurveyDevotionText` (~line 15217).
- MCM summary short-circuit: `GetPlayerMcmSummaryLine` (~line 15301).
- Book-of-Days tier-up: `ShowDaedricMilestonePresentation` (~line 12064).
- Pact resolver + tier guard: `GetActiveDaedricPactPath` (~line 2715).

## What is ALREADY wired (do NOT rebuild)

1. Survey Devotion (per-race, ALL races). `GetSurveyDevotionText()`
   (live ~line 15217) short-circuits BEFORE the per-race switch:
   ```
   PDV_DaedricPathBase pactPath = GetActiveDaedricPactPath()
   if pactPath
       return AppendRecentDevotionEvents(GetDaedricSurveyText(pactPath))
   endIf
   ```
   `GetDaedricSurveyText` (~line 2752) returns
   `"<Prince> holds your pact. Standing: <PublicTierBand>."` -- mirrors how a
   patron is banded (`GetPublicTierBand`). PLACEHOLDER copy by design (user
   rewrites post-beta).

2. MCM one-line summary. `GetPlayerMcmSummaryLine()` (~line 15301) has the
   same short-circuit (~line 15308): `<Prince> | Pact | <CurrentStandingLabel>`.

3. Book of Days, organic tier-up. `ShowDaedricMilestonePresentation`
   (~line 12064) now calls `AppendBookOfDaysEntry` at its tail (~line 12097):
   ```
   AppendBookOfDaysEntry(princeName + " names you " + tierLabel + ".",
       Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName,
       newTier >= TIER_CHAMPION)
   ```
   Tone `"tier.reach"`, symbol falls through to `"daedric"`, Champion pinned --
   exactly the patron tier-up shape.

4. Book of Days, other Daedric beats already logged:
   - `SurfaceDaedricLapse` (~line 2769): tone `"neglect.drop"`, symbol
     `"daedric"`.
   - `SurfaceSwitchSeverance` (~line 2758): patron<->Prince severance, tone
     `"reorientation"`.

## Remaining gap (the only authoring work, if confirmed)

The surfacing above is gated on an ACTIVE PACT with tier > TIER_NONE. See
`GetActiveDaedricPactPath` (~line 2724): `path.GetStoredTier() > TIER_NONE`.
Two real seams remain:

### Seam 1 -- pre-pact "dabbler" has no Survey/Book-of-Days surface

A player building Daedric piety who has NOT yet crossed into a tier>0 pact
(no `PDV.Daedric.ActivePact` form, or tier still 0) gets the normal per-race
Survey line with ZERO Daedric reference, even though piety is accruing. The
per-race getters themselves carry no Daedric ref (confirm: `GetNordSurveyBaseText`
~15444, `GetAltmerSurveyText` ~15618, `GetKhajiitSurveyText` ~15677 -- none
mention Daedric). This is consistent with the inverse-Kyne "native default has
no off-pantheon refs" pattern, so it may be CORRECT-BY-DESIGN. Adjudicate with
the user before building: does a sub-tier-1 Daedric dabbler deserve a Survey
hint, or is silence-until-pact intended?

If a surface IS wanted: add a fallback AFTER the active-pact short-circuit and
BEFORE the per-race switch in `GetSurveyDevotionText` (insert just after the
`if pactPath ... endIf` block, ~line 15229). Reuse the existing top-path
helper rather than re-deriving:
- `GetTopDaedricPath()` family lives near ~line 7307 (`GetDaedricPathCount`,
  loop over `GetDaedricPathAtListIndex`, pick max `GetStoredPiety`). Grep for
  the existing top-path accumulator at ~7307-7330 and REUSE it; do not write a
  second scan.
- Fallback line (PLACEHOLDER): if a top Daedric path exists with piety > 0 but
  tier == TIER_NONE, append e.g. `"<Prince> stirs at the edge of your devotion."`
  Keep it additive (do not replace the race line) so a dabbler still sees their
  native standing.

### Seam 2 -- no Book-of-Days entry on first pact ACTIVATION

`ShowDaedricMilestonePresentation` logs on TIER CHANGE, and
`ProcessPendingDaedricActivation` (~line 2804) / `SurfaceSwitchSeverance` log
the patron->prince SEVERANCE, but a clean first activation into a Prince pact
(no prior patron to sever) may only toast, not journal. Confirm by tracing
`ProcessPendingDaedricActivation`: if `GetPatronState() != PATRON_STATE_ACTIVE`
(no patron to sever) the `SurfaceSwitchSeverance` AppendBookOfDaysEntry branch
is skipped. If so, add a single `AppendBookOfDaysEntry` at the activation site
(~line 2815, inside `ProcessPendingDaedricActivation` after the pointer-still-
live check) with tone `"reorientation"`, symbol `"daedric"`, pinned true:
PLACEHOLDER `"<Prince> claims your devotion."`. Guard against double-logging
when a tier-up fires in the same tick (the milestone presentation already
logs tier.reach).

## Serialize note

This is a MANAGER-TOUCHING change (`PDV__ManagerQuest.psc`). SERIALIZE: the
live manager is the high-contention file (and is the untracked/snapshot-risk
script per the restore-boundary memory). Coordinate with Codex before editing;
do not interleave with another concurrent manager edit. Keep all new copy
PLACEHOLDER and ASCII-only (the .psc commit hook rejects non-ASCII).

## Verify

1. `node tools/pdv_compile.mjs` -> expect 0 errors / 0 warnings.
2. `node tools/pdv_verify.mjs` -> expect FAIL=0.
3. `node tools/pdv_signal_e2e_gate.mjs` -> expect 0 RED.
4. `node tools/pdv_integrity_harness.mjs` -> expect PASS.

If after the verify-first grep you find both seams are already covered (e.g. a
later commit added the dabbler line / activation journal), STOP -- record the
finding, do not author, and mark D2 closed in the gap ledger. The bulk of D2
shipped in `ab193cb`; this handoff exists mainly to prove that and to scope the
two narrow residuals.
