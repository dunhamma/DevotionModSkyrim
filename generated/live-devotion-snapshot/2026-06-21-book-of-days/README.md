# 2026-06-21 Book of Days + Devotion dashboard snapshot

POST-edit snapshot of the live untracked manager source after the Book of Days
writer + per-race chronicle + Devotion feedback dashboard implementation. Captured
here because the canonical `.psc` lives in the untracked live dir (disappearance
risk); this preserves the Papyrus backend in git alongside the tracked UI files.

What this build added (manager-side):
- Book of Days writer: `AppendBookOfDaysEntry` / `PruneBookOfDays` /
  `RemoveBookOfDaysEntryAt` (day-window 21d, hard ceiling 60, headline-pinned
  exempt, same-day+tone+line de-dupe, new parallel `PDV.Diegetic.Journal.Pinned`
  list).
- `SurfaceTransition` reworked with additive `repeatable` + `headline` params
  (existing 5 callers unchanged) and now feeds the writer via
  `ResolveTransitionJournalLine` / `TransitionToneKey` / `ResolveTransitionJournalSymbol`.
- New tones `reorientation` / `dawn.digest` / `drift.warn` in
  `JournalToneToTitle` / `JournalToneToValence`.
- Patron tier reaches now journal (band-scoped guard; Champion pinned).
- Dawn pass `RunDawnBookOfDays` (prune + per-race mode-change snapshot-diff via
  `EmitBookOfDaysStateChange` + named-acts digest).
- Attribution: `reason` param on `AwardPiety` / `AwardPietyInternal`; per-deity
  driver ring (`RecordDeityDriver`, cap 6); `IsDashboardTrackedDeity`;
  `HumanizeDriverReason`.
- Per-god rollup `GetGodRollupState` (gaining/steady/starving/neglected).
- Dashboard payload `GetDashboardJson` / `AppendDashboardGod` /
  `GetDeityDriversJson` added to the existing `PushDevotionPanel` JSON (no new
  SendJson call).

Gates at capture: manager compile 0/0, pdv_verify FAIL=0 (PASS=3057),
pdv_prisma_ui_audit PASS (13). In-game proof pending.

Captured file:
- D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc
