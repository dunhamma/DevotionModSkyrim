# HO: Daedric Surfacing -- Survey + Book of Days (Codex Handoff, 2026-06-25)

> **D2 CLOSED 2026-06-29 (verify-first pass).** All residual seams are built in
> the live manager and machine-accepted (commit `3153d8e`, adversarial pass R1-R5
> PASS): Seam 1.2 pre-pact notice (`ProcessPendingDaedricPrePactNotices`, "The
> world tilts toward <Prince>", once-fire guard), Seam 1.3 Ledger `watching` tag
> (`AppendDashboardGod(watchingPath, "watching")` + systems list), Seam 2
> first-pact activation journal (`ProcessPendingDaedricActivation`, "<Prince>
> claims your devotion"), and the Fix-1 driver hook (`pdv_ledger_coverage_audit`
> CLEAN, 0 untracked, daedric driver hook YES). Per this handoff's own rule, no
> authoring was performed. Remaining work is RUNTIME/MANUAL proof only
> (play-gated): observe the pre-pact Book-of-Days entry, the Ledger `watching`
> branch, Survey staying silent pre-pact (by design), and no double-log on
> first-pact activation. Placeholder copy -> final narrator-voice is the separate
> post-beta writing pass.

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

### Seam 1 -- pre-pact "dabbler" surfacing -- OWNER RULING 2026-06-25 (RESOLVED)

A player building Daedric piety who has NOT yet crossed into a tier>0 pact gets
ZERO Daedric reference on most surfaces today. Ruling resolves three DISTINCT
surfaces:

1. **Survey: NO Daedric reference -- BY DESIGN. Nothing to build here.** Do NOT
   add a dabbler line to the per-race Survey getters; silence-until-pact is
   intended (inverse-Kyne "native default has no off-pantheon refs"). The per-race
   getters stay Daedric-free pre-pact. (Drop the earlier "if a surface is wanted"
   Survey-fallback idea -- it is explicitly NOT wanted.)

2. **Book of Days (Chronicle, page 0): ADD a "a Prince takes notice" entry.** When
   a pre-pact Prince's accruing attention crosses a threshold, write ONE
   `AppendBookOfDaysEntry` -- a fun "the world tilts toward <Prince>" beat.
   Threshold: a top Daedric path (`GetTopDaedricPath()` ~7307; max `GetStoredPiety`,
   tier == TIER_NONE) whose stored piety crosses a tunable bar (e.g. >= half the
   tier-1 pact threshold). ONCE-fire per Prince per accrual window (a StorageUtil
   per-path "noticed" flag, reset on pact OR on decay back below the bar) so it
   does not restate every dawn. Tone = a Daedric pressure/temptation key;
   PLACEHOLDER copy ok.

3. **Ledger (page 1, "what feeds your gods" = `GetDashboardJson` ~1918): TRACK the
   pre-pact Prince.** This is "the bigger tracker that monitors all data points."
   Today `GetDashboardJson` lists ONLY the active pact (~1926) + pantheon deities
   with piety>0, so a pre-pact Prince accruing stored piety is INVISIBLE there.
   Add a branch: if a top Daedric path has stored piety > 0 but no active pact,
   append it via `AppendDashboardGod` with a new system tag (e.g. "watching") so it
   shows in the Ledger, sortable by god + reaction. Its `GetDeityDriversJson`
   drivers then explain "what feeds" the watching Prince -- which DEPENDS ON the
   Daedric driver fix. `SetStoredPiety` records NO driver today (confirmed by
   `pdv_ledger_coverage_audit` -- 18 bypass sites), so do **`HO_GateFindings_2026-06-25.md`
   Fix 1** (record a driver in `SetStoredPiety`) FIRST -- then this watching-Prince
   Ledger branch works and the new system tag has drivers to show.

**STANDING RULE (owner, 2026-06-25): the Ledger MUST monitor ALL data points.**
Every piety/signal award -- patron, pantheon, Prince, pre-pact, substrate, curated,
LD -- must record a driver (`PDV.Driver.Reasons`/`PDV.Driver.Deltas`) on its target
form so it appears, sortable by god + reaction, in the Ledger. Treat "did this
signal land in the Ledger?" as a wiring-acceptance check for EVERY new signal
(applies to all Phase-1 handoffs: under-floor, 6f, CC, Notoriety).

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
