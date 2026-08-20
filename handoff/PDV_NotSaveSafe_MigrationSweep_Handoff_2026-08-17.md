# Not-save-safe migration sweep — deferred work handoff (2026-08-17)

**For:** Codex · **Branch:** `feature/v3-big-update` (PR #82) · **Kind:** ARCHIVE-on-completion handoff.
**Anchor plan:** `references/authoring/PDV_NotSaveSafe_MigrationSweep_Plan.md` (LIVING).

## What was done this session (no-compile, audit/contract/doc only)

The Part A pure-legacy migration removal shipped in #79 (`39fb7aa4`, `af7e668e`) had left
three gates enforcing the retired design, failing `pdv_verify` on `feature/v3-big-update`.
Reconciled to green (audits re-run, exit 0):

- `tools/pdv_broad_pantheon_audit.mjs` — deleted 6 obsolete migration assertions; re-anchored
  2 frozen-counter (negative-only) and 4 relocated-invariant checks to
  `ApplyBroadPantheonEventResult` / `AwardPietyInternal`. No invariant weakened.
- `references/authoring/PDV_BroadPantheonContracts.json` — removed the 3 `migration` blocks
  (paired with the removed `contract.*` reads).
- `tools/pdv_substrate_pacing_audit.mjs` — re-anchored `source.khajiit-moon-power-slot` to the
  surviving `AddSpell`/`RemoveSpell` + `!EquipSpell` (no-force-select) invariant.

Verified: `broad`, `broad --self-test`, `substrate` all exit 0; `git diff --check` clean.
Full `pdv_verify` exit-0 (reads live MO2) NOT re-confirmed — MO2 MCP server was down. Re-run
once MO2 is up as the pre-merge gate.

## Deferred — needs manager `.psc` edits + Papyrus/CK compile + MO2 deploy

These were explicitly out of scope this session (no-compile). Each is authorized by the
anchor plan's not-save-safe premise.

### (b1) Part B live removals still in the manager
- **`RepairBookOfDaysJournalText`** — `live-source/Scripts/Source/PDV__ManagerQuest.psc:23892`
  (`Int repairVersion = 3` at :23893; helper `ShouldPruneDeferredAltmerJournalLine` :23945;
  callers ~:999/:1101). Plan flags a 3rd call site in the live `BuildJournalPayloadJson`
  render path — remove with care.
- **`AncestorSpine_T1` legacy strip** — live force-remove at
  `PDV__ManagerQuest.psc:18217` (`SyncRaceRewardSpell(..., PDV_Bless_Redguard_AncestorSpine_T1,
  False, ...)`); behaviour at ~:17097/:17906. **CAUTION: keep the reward spell**
  `PDV_Bless_Redguard_AncestorSpine_T1` — it is the fixed broad-T1 manager property (:418,
  `GetFirstTierRaceRewardSpellForOrigin`) and is legitimately asserted by `pdv_verify.mjs:4749`,
  `PDV_Phase20_RewardRecordContracts.json`, `PDV_RedguardRewardRecords.spec.json`,
  `PDV_FeltEffectRegistry.json`. Remove ONLY the strip loop, not the reward records.

### (b2) Coupled contracts to fix ALONGSIDE the (b1) removals
- **`tools/pdv_prisma_ui_audit.mjs:881-887`** (`verifyAltmerCurrentRosterContract`,
  `...migration-missing`) hard-requires `RepairBookOfDaysJournalText`'s body
  (`Int repairVersion = 3`, `ShouldPruneDeferredAltmerJournalLine`). It PASSES today (function
  still live) but will FAIL the moment (b1) removes the function — reconcile them together.
- **`references/authoring/PDV_SubstratePacingContracts.json`** — migration language the
  substrate-pacing audit reads: `:23` (`legacy +1 stamps migrate once`), `:40`
  (`directPositiveWriteExceptions: ["versioned migration", ...]`), `:178` (the removed
  `MigrateLegacyCompositeMetricOnce` / `CulturalMetricMigrationVersion` seed), `:293`/`:297`
  (compatibility/migration records). Not green-blocking today; retire when the matching
  Part B/encoding removals land.

### (b3) Other plan rows to verify/cut (per anchor plan Part A/B tables)
- Breton Tradition T1/T2 force-remove (`~:17094-95`), `ReadZeroReservedDevotionalDayStamp`
  `.Encoding<2` +1 branch, `EnsureHistMaintenanceStampEncoding`, `PlayerEvents` book-read
  legacy branch. Verify exact lines before cutting; some are init-bearing (keep init).

## Guardrail — do NOT treat as save-migration (already vetted, keep)
`LIKES_DISLIKES_VERSION` / `PRINCE_LD_VERSION` table loaders, `FRAMEWORK_SCHEMA_VERSION`,
Khajiit/Altmer JSON-asset version constants, `AUTHORIA_REPAIR_VERSION`,
`ShouldSyncLegacyPatronBoons` / `ClearLegacyTalosBoons` — fresh-save mechanisms, not migrations.

## Category C gaps: none
All four relocated broad-pantheon invariants were positively confirmed present in the manager
before re-anchoring — no suspected real functionality gap to file.
