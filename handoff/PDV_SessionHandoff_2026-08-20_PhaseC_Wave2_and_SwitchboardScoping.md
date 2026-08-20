# Session handoff -- 2026-08-20: Phase C wave 2 + reward/neglect switchboard lane done

Resume pointer for the 2.0 rebuild, continuing from
`PDV_SessionHandoff_2026-08-20_PhaseC_Wave1_Validated.md`. All work committed on
**`feature/v3-origin-extraction`** (nothing pushed). HEAD is `1fe0ff28`.

## What shipped this session (5 gated commits)

| Commit | Step | Change | Gate |
|---|---|---|---|
| `85b69aa5` | 2a | 21 provably-safe base bodies emptied | compile 0/0 · parity changed=21, removed=0 |
| `5538a907` | 2b | 3 read-only base bodies emptied | compile 0/0 · parity changed=3, removed=0 |
| `6d7d46d2` | docs | wave-2 + switchboard scoping handoff | -- |
| `f50a743f` | switchboard slice 1 | reward/neglect per-cycle loop (ledger+manager) | ledger + manager compile 0/0 |
| `1fe0ff28` | switchboard slice 2 | removed 27 dead reward/neglect base decls (-490 lines) | base+Altmer compile 0/0 · parity removed=27, changed=0 |

**Phase C tally: 266 of 605 neutralized** (100 deleted [73 wave-1 + 27 slice-2] + 166 emptied [142 wave-1 + 24 wave-2]).

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

## Switchboard pass -- reward/neglect lane MIGRATED (owner chose "keep it in")

Owner ruling: cleanliness is the priority this round, so the reward/neglect lane was
migrated (not left as residue). Done in two gated slices (`f50a743f`, `1fe0ff28`):

- **Slice 1:** `SyncFirstTierRaceRewardRuntime` (+ the stray `DebugSeedArgonian` caller) now
  loop over `PDV_FLST_OriginAdapters` calling the generic `SyncRaceRewards()` +
  `SyncNeglectSpells()` per adapter, replacing 20 hardcoded per-lane calls. The bound (player)
  adapter grants its lane; every other adapter's Sync runs the isX=false path and STRIPS its
  lane -- preserving the one-race-active invariant every cycle, as before.
- **Slice 2:** removed the 27 now-dead per-lane base declarations (9 rewards + 9 neglect +
  9 `IsXNeglected`). `SyncKhajiitEmphasisRewards` EXCLUDED -- still called by base
  `SyncKhajiitRuntimeState`. The impl lives on in each adapter.

Why it stays behavior-preserving (the foreign strip is re-routed through the adapters, not lost):
- Non-bound adapters ARE Manager-wired -- houseCARL ESP readback of Altmer `071797` + Nord
  `071794` both show `Manager -> 00C325` filled -- so `foreignAdapter.SyncRaceRewards()` runs.
- Adapter `SyncAltmerRewards` is byte-identical to the base and computes `isAltmer` dynamically,
  so the foreign-strip path is identical to today's base-dispatch strip.
- Nord edge: its `SyncNeglectSpells()` re-affirms Kyne/patron neglect already set at dawn
  (`RunDawnApplySpellAndNeglectLayers`); `IsKyneNeglectActive() == IsNeglectFlagActive(Kyne)`
  and the helpers are idempotent/self-clearing, so the extra per-cycle sync converges the same.

The base still declares the generic dispatch surface (`IsRaceLaneNeglected`, `SyncRaceRewards`,
`SyncNeglectSpells`, `IsOfferEligibleDeity`, `HandleContextualSignal`, `GetOriginDetailLabel`,
`GetSurveyFragment`, ...); base defaults inert. Coverage is non-uniform but INTENTIONAL:
`SyncRaceRewards`/`SyncNeglectSpells` = all 10; `IsRaceLaneNeglected` = all but Nord;
`IsOfferEligibleDeity` = only the 6 offer races (Argonian/Bosmer/Khajiit/Orc have no per-lane
offer method -> base False is correct).

**PENDING -- race-change runtime test (owner-gated):** become race A, gain a blessing, `setrace`
B, confirm A's blessings drop and B's appear. This is the real gate for the reward lane; the
same sitting can spot-check waves 2a/2b. `Devotion-V3Dev` is stale vs HEAD -- redeploy first.
Dead helper subtrees left behind (`SyncAltmerRewardFamily`, `SyncAltmerAncestorSubstrate`, ...)
are a follow-up dead-code sweep.

## Also required for ANY declaration removal (the general rule)

To remove a per-lane base declaration, ALL its external callers must first be migrated to the
generic (not just one). Example: `IsNordOfferEligibleDeity` has 5 callers
(UsesFormalCommitmentOffersForDeity, IsGenericLikesDislikesDeityReachable,
IsQuestReactionDeityReachable, DebugSetNordPantheonBaseline x2), not 1. Removal is the parity
REMOVED category -- run with `--allow-removed` and treat each as an intentional retire.

## Next slices

1. **IsOfferEligibleDeity lane** (IN PROGRESS -- next): migrate the callers of the 6 per-lane
   `IsXOfferEligibleDeity` to the generic `OriginRuntime.IsOfferEligibleDeity(deity)`, then remove
   the 6 base declarations (bodies already emptied in wave 2a). Verify every caller first --
   `IsNordOfferEligibleDeity` has 5 (UsesFormalCommitmentOffersForDeity,
   IsGenericLikesDislikesDeityReachable, IsQuestReactionDeityReachable, DebugSetNordPantheonBaseline x2).
2. **Presentation lane** (`ShowOriginNotification`/`ShowOriginMessage`, `GetSurveyFragment`,
   `GetOriginDetailLabel/Value`) -- generics exist; check caller counts.
3. ~~Reward/neglect lane~~ -- DONE (`f50a743f`, `1fe0ff28`).

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
