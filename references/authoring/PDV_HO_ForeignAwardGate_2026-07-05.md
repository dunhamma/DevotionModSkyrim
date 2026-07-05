# Handoff: Foreign quest-award reachability gate + dead-write audit (2026-07-05)

Branch: `worktree-foreign-award-gate` (isolated worktree; NOT merged, NOT deployed to MO2).
Commits: `99a1bfbc` (reachability gate), `020eb96f` (dawn-loop skip).
Owner ratified the direction in-session ("do both": handoff + implement); merge/deploy remains
the explicit go decision below.

## 1. What prompted this

Owner question during mega-packet testing: why does a quest reaction award piety to gods
outside the player race's available roster ("the player will never see it")? Audit confirmed
the owner's instinct: those awards are dead state.

## 2. Audit trace (all consumers of a FOREIGN/TOLERATED quest award)

| Consumer | Gate | Sees foreign piety? |
|---|---|---|
| Dashboard/pantheon panel | `IsDashboardDeityInOriginRoster` hardcoded per-origin allowlist | NO -- never rendered |
| Recent-driver ring (`RecordDeityDriver`) | surfaced only through the dashboard | NO (dead write) |
| Formal commitment offer | `UsesFormalCommitmentOffersForDeity` -> each race check returns False for other origins | NO -- can never become a candidate |
| Commitment signal-days | consumed only by the offer path | NO (dead write) |
| Tier (`PDV.Tier`) | shown only via dashboard | NO |
| Prisma toast / mirror globals | `deity == _activeDeity` | NO -- foreign never active |
| Broad-lane lapse stamp `PDV.Devotion.LastActTime` | GLOBAL, set on any positive award | **YES -- the one real effect, and it was a leak** (comment says "pantheon act"; foreign gods bumped it) |

Also found: foreign awards were double-scaled (`stanceMult.FOREIGN` 0.4 in `ApplyDeityReaction`
x `GetEffectiveGainMultiplier` in `RunGainPipeline`), so the effective foreign rate was
~0.2-0.3x, not the nominal 0.4x.

No "visible-but-foreign" case exists that would justify the 0.4x tier for deity faces: the only
explicit FOREIGN stance assignment in the manager is Talos, and every race where Talos is
FOREIGN also excludes him from its dashboard roster.

## 3. What was built (worktree, compile 0/0, verify FAIL=0 WARN=1 known-glyph)

### 3a. Reachability gate -- `ApplyDeityReaction` (`99a1bfbc`)
FOREIGN/TOLERATED awards are skipped (trace at DebugLevel 2:
`QuestReaction skipped unreachable foreign deity`) unless the deity is reachable:

- `IsQuestReactionDeityReachable(deity)` = Daedric path base (always; pre-pact paths render as
  "watching", pacts as patron -- path piety has a live consumer) OR
  `IsDashboardDeityInOriginRoster(deity, origin)`.
- Preserved unchanged: TABOO/HOSTILE -> stigma, CURSE routing, NATIVE full value, and
  roster-listed deities with a TOLERATED/FOREIGN stance (visible-but-foreign keeps 0.4x).
- Side effect fixed: foreign awards no longer bump the broad-lane `PDV.Devotion.LastActTime`.
- Scoring/display/offers now agree with `ScoreFromTable`'s existing hard race-gate (the other
  three systems already gated; the quest path was the odd one out).

### 3b. Dawn-loop skip -- `RunDawnConsolidateScratch` (`020eb96f`)
The dawn loop rewrote `PDV.Piety`, rotated the 7-slot Week ring, and recomputed tier for EVERY
deity every dawn. Now skips the body for a non-roster deity with zero scratch AND zero standing.
Backward compatible: pre-gate foreign piety on old saves (piety > 0) still consolidates until it
reaches 0 / stays as-is; roster gods keep zero-day ring pushes so the Weekly sparkline timeline
stays aligned.

## 4. Behavior changes a tester will notice (post-deploy)

- Meta lanes for off-roster deity faces go SILENT instead of awarding 0.4x: e.g. the 10th-quest
  wheel under Imperial fires Akatosh only (Xarxes skipped, trace line at DebugLevel 2); under
  Altmer fires Xarxes only. Z'en gold wage: Bosmer only. Khenarthi outdoors: Khajiit only.
  Azura lanes: Dunmer/Khajiit deity-face (other origins engage Azura via the PATH per the
  dual-face design). Nocturnal lanes: unchanged (path base, always reachable).
- Quest cells for off-roster gods (e.g. Dibella on a Bosmer) no longer award.
- **Mega packet edits needed at intake** (`PDV_MegaPacket_OneOh_2026-07-02.md`, on main):
  Section A preamble + A1/A2/A5 notes still describe the 0.4x foreign fire; after deploy those
  arms are silent-with-trace. The current packet matches the currently-deployed build, so do
  NOT edit until this branch deploys.
- New negative smoke row to add: fire a probe under an origin foreign to one of its cell gods
  and confirm the DebugLevel-2 skip trace + no Ledger driver row for that god.

## 5. Deploy sequence (after the current testing sitting ONLY)

1. Merge `worktree-foreign-award-gate` -> main.
2. Sync live-source -> MO2 (`repo-source-drift` rule), `node .\tools\pdv_compile.mjs`
   (0/0 expected), `node .\tools\pdv_verify.mjs --json` (FAIL=0 WARN=1).
3. Rerun `node .\tools\pdv_beta_readiness_audit.mjs --strict --json` -> expect STRICT_GATE_PASS.
4. Update mega packet Section A wording per section 4 above; add the skip-trace negative row.
5. Fresh-save spot-check: Imperial wheel (Akatosh yes / Xarxes skip trace), one foreign cell
   skip, one Nocturnal lane (path still fires).

No save migration needed: no VMAD/property changes; orphaned pre-gate foreign StorageUtil keys
are harmless (and the dawn skip stops touching the zero ones).

## 6. Follow-ups from the broader dead-write audit (subagent, main-loop verified)

| # | Finding | Status | Disposition |
|---|---|---|---|
| 1 | Dawn loop writes Week ring/piety/tier for all deities | VERIFIED (no early-out existed) | FIXED in `020eb96f` |
| 2 | `ApplyRivalryPenalties` can write negative piety + driver-ring entries to non-roster rivals via CK `RivalDeities` arrays | PLAUSIBLE, not verified -- trigger is rare (HOSTILE god gaining positive piety; quest HOSTILE routes to stigma, so mainly shrine prayer to a hostile god) and cross-roster rival membership is CK data not yet checked | Data check: dump `RivalDeities` per deity via houseCARL; if cross-roster rivals exist, apply the same roster gate before the rival `AwardPietyInternal` |
| 3 | `forbidden_knowledge` faucet keys unbounded-ish (`PDV.QuestReaction.Faucet.<deity>.<tag>.<formid>.Seen`) | VERIFIED intentional once-ever guard, cardinality ~20-100 | No action |
| 4 | Verified SAFE: `ScoreFromTable` race-gate, Khajiit bridge origin guard, offer qualification guards, `PDV.Meta.Done.*` (~90 keys), Daedric Week loop (paths are by-design multirace) | -- | No action |

## 7. Proof boundary

Everything here is machine/readback proof (compile 0/0 isolated; verifier unchanged). The
in-game skip-trace + wheel behavior rows in section 5 are the route proof and remain OPEN until
run on a post-deploy save. Do not intake this as a strict-gate change without step 3 + 5.
