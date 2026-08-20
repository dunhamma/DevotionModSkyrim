# Session handoff -- 2026-08-20: Phase C wave 2 done + switchboard pass scoped

Resume pointer for the 2.0 rebuild, continuing from
`PDV_SessionHandoff_2026-08-20_PhaseC_Wave1_Validated.md`. All work committed on
**`feature/v3-origin-extraction`** (nothing pushed). HEAD is `5538a907`.

## What shipped this session (2 gated commits)

| Commit | Wave | Emptied | Gate |
|---|---|---|---|
| `85b69aa5` | 2a | 21 provably-safe base duplicate bodies | isolated compile 0/0 · parity changed=21, removed=0 |
| `5538a907` | 2b | 3 read-only base duplicate bodies | isolated compile 0/0 · parity changed=3, removed=0 |

**Phase C tally: 239 of 605 neutralized** (73 deleted + 142 wave-1 + 24 wave-2).

Per-change gates (kept in separate buckets): isolated compile of `PDV_OriginRuntimeBase`
against the WORKTREE source into a scratch output = `0 error(s), 0 warning(s), succeeded`
(the bundled verifier FAILs are the documented default-to-1.5-folder trap -- it audits
`D:/.../Devotion/` not V3; unrelated). Static parity (`pdv_parity_snapshot.mjs --compare`
vs HEAD) = CHANGED is exactly the emptied set, removed=0/added=0. Each emptied fn was
verified to have a race-adapter override and NO `Parent.<fn>` delegation before editing.

Runtime spot-check for 2a+2b is OWNER-GATED and still pending. Low priority: 2a is the same
class Wave 1 already runtime-validated (returns type default for non-owner-race), 2b is 3
panel-gated read-only labels. `Devotion-V3Dev` is now STALE vs HEAD -- a redeploy (sync base
+ recompile into `Devotion-V3Dev\Scripts`) is needed before any runtime check.

## The empty-body method: safety rule + the ceiling it hit

Empty-body safety rule (STRICTER than the 08-19 cast audit -- also accounts for INTERNAL
base callers): a base body is empty-safe iff it already returns the type default with no
side effects for a NON-owner-race player. Then it is either never run (owner dispatches to
the adapter) or returns the same default, so internal base callers are unaffected too.

**Ceiling finding (important -- refines the wave-1 handoff's estimate):** most read-only
C-tier is NOT empty-safe. `DebugGetPatternProvingSummary` / `DebugGetPatternSummarySection`
(PDV__ManagerQuest) call every race's `Get*Summary` UNCONDITIONALLY for any player -- the
debug MCM readout depends on the non-default cross-race values. That also taints maps reached
through a summary (`GetKhajiitLunarSummary`->`GetKhajiitFocusLabel`, `GetOrcSummary`->
`GetOrcLifeModeLabel`, `GetRedguardSummary`->`GetRedguardSectLabel`) and the Khajiit lunar
maps / `GetArgonianCulturalPracticeLabel` (called by internal base substrate/award fns incl.
`SendPrismaSubstrateProgress`). Of the 39 read-only C, only 3 were empty-safe. The 77
side-effecting will mostly be the same. Conclusion: **empty-body is near its ceiling for the
C-tier; the remaining ~300 declarations are load-bearing and only removable by the switchboard
pass.** (memory: [[phase-c-empty-body-ceiling]])

## Switchboard pass -- SCOPED, blocked on ONE owner decision

Owner chose the switchboard/virtual-routing pass as the next step. Scoping result:

**It is partly BUILT.** The base already declares a generic dispatch surface and adapters
already override it: `IsRaceLaneNeglected`, `SyncRaceRewards`, `SyncNeglectSpells`,
`IsOfferEligibleDeity`, `GetFormalCommitmentOfferMessage`, `ShowOriginNotification`,
`HandleContextualSignal(signalId,...)`, `HandleContextualQuery`, `GetOriginDetailLabel(key)`,
`GetOriginStateValue`, `GetSurveyFragment`, etc. Base defaults are inert (False/0/""/None).
The generic overrides cleanly delegate to the per-lane methods (e.g. Altmer
`SyncNeglectSpells()` -> `SyncAltmerNeglectSpell(IsAltmerCoherenceNeglected())`).

Coverage is non-uniform but INTENTIONAL where checked: `SyncRaceRewards`/`SyncNeglectSpells`
= all 10; `IsRaceLaneNeglected` = all but Nord; `IsOfferEligibleDeity` = only the 6 offer
races (Argonian/Bosmer/Khajiit/Orc legitimately have no per-lane offer method -> base False
is correct).

**The blocker (found by reading the actual caller):** `SyncFirstTierRaceRewardRuntime`
(PDV_DevotionLedger.psc:3557) is NOT a race switch -- it calls EVERY race's
`SyncXRewards(playerRef)` + `SyncXNeglectSpell(IsXNeglected())` UNCONDITIONALLY. Those base
methods do NOT self-gate by race (`SyncAltmerRewards` only guards `!playerRef`); internally
they compute `isAltmer` and, for a NON-owner, `ClearSubstrateBoons()` + strip every T1/T2/T3
spell (SyncRaceRewardSpell with isActive=False). So the unconditional cross-race calls are
LOAD-BEARING defensive cleanup: keep exactly one race's rewards active and all others stripped
every sync cycle.

Therefore the generic `SyncRaceRewards()` (player-lane only) is NOT a drop-in replacement --
collapsing to it drops the foreign-reward stripping (observable on race-change / save
migration / console-granted edge cases). Same for the neglect-spell lane.

**Owner decision required before executing this lane:** should the cross-race defensive strip
(a) move to a dedicated race-change / one-shot `StripForeignRaceRewards` hook so
`SyncFirstTierRaceRewardRuntime` can call the player-only generics, or (b) stay as-is (then
this lane's per-lane declarations CANNOT be removed and stay until a different design)? This
is an architecture call, not a mechanical refactor.

## Also required for ANY declaration removal (the general rule)

To remove a per-lane base declaration, ALL its external callers must first be migrated to the
generic (not just one). Example: `IsNordOfferEligibleDeity` has 5 callers
(UsesFormalCommitmentOffersForDeity, IsGenericLikesDislikesDeityReachable,
IsQuestReactionDeityReachable, DebugSetNordPantheonBaseline x2), not 1. Removal is the parity
REMOVED category -- run with `--allow-removed` and treat each as an intentional retire.

## Suggested next slices (once the strip decision is made)

1. **IsOfferEligibleDeity lane** (cleanest, lowest churn): migrate the ~handful of callers of
   the 6 per-lane `IsXOfferEligibleDeity` to the generic `OriginRuntime.IsOfferEligibleDeity(deity)`,
   then remove the 6 base declarations (bodies already emptied in wave 2a). Verify every caller
   first (Nord has 5).
2. **Presentation lane** (`ShowOriginNotification`/`ShowOriginMessage`, `GetSurveyFragment`,
   `GetOriginDetailLabel/Value`) -- generics exist; check caller counts.
3. **Reward/neglect lane** -- ONLY after the strip decision above.

## Open bugs / debt (carried from wave-1 handoff, still open)

- Talos lowercase in a QUEST-REACTION BoD line (display-only, pre-existing; needs the exact
  BoD line text to trace).
- Stale manager-QUST property fills (~34 fills / ~198 warnings) -- Phase-6 cleanup.
- `GetQrQueueNeedsBretonRewardSync` dead getter -- dead-code sweep.
- MCM Status page redundancy -- backlogged to the MCM rebuild.

## Environment

- Branch chain unpushed; HEAD `5538a907`. houseCARL instance pointer unchanged this session
  (was D:/Wabbajack/modlists/Anvil, profile Devotion Dev -- NOT touched; no houseCARL calls made).
- Isolated compile recipe (no MO2 disturbance): set `PDV_COMPILE_SOURCE_ROOT` to the worktree
  `live-source/Scripts/Source`, `PDV_COMPILE_OUTPUT_ROOT` to a scratch dir, then
  `node tools/pdv_compile.mjs --script <Name>`. Read the compile block (lines 1-11), ignore
  the bundled verifier's 1.5-folder FAILs.
- Parity: `git show HEAD:live-source/.../PDV_OriginRuntimeBase.psc > golden.psc`, snapshot
  golden + current, `--compare`. Working tree is CRLF, index is LF (autocrlf + eol=lf) --
  edit scripts must preserve CRLF on write (the emptying script detects and reuses the newline).
