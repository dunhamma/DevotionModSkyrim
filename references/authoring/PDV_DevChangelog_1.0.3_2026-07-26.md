# Devotion 1.0.3 — dev changelog (2026-07-26)

Terse technical companion to `CHANGELOG.md`. Finding IDs are DrHeisen's audit of
1.0.2 (`A1`–`D7`); group numbers are his fix plan. Everything below was
verify-then-ported into our live source — no `.psc`/`.pex` copied.

## Records (ESP, ships in zip — no git diff)

- `Recover` added to `0715CB` / `0715CD` (`PDV_MGEF_RedguardRemember_Road|Rest`,
  PeakValueModifier). 1.0.3's first sweep was ValueModifier-only.
- MESG format fixes: `0714E1/E2/E3` (`%s` is invalid in MESG — sentence removed,
  not escaped), `0714FF` (`+8%` → `+8%%`).
- **A3 RESOLVED + APPLIED.** Rule: `Detrimental` supplies the penalty, so stored
  magnitude must be **positive**. All 22 `Detrimental` MGEFs' carrying SPELs are
  now positive:
  - 14 `PDV_SPEL_Disfavor_*` (7 domains × Light/Sharp) — flipped by owner.
  - 7 `PDV_SPEL_Neglect_{Kyne -8→8, Tsun -15→15, Shor/Stuhn/Talos/Arkay/Dibella
    -5→5}` + `PDV_Bless_Redguard_Spine_AshAbah` `Effects[2]` `-5→5` (mixed boon:
    Effects[0]=10, [1]=20 untouched) — flipped here.
  - **Left negative deliberately** — 60 SPELs on the non-`Detrimental` convention
    (negative magnitude, no flag), verified disjoint from the Detrimental set:
    9 race neglects (Redguard/Imperial/Orc/Dunmer/Altmer/Bosmer/Breton/
    ArgonianHist/KhajiitLunar), 45 `PDV_Price_Daedric_*`, 4 Breton `CreedLoss`.
  - ⚠ Test trap: the packet's corrected Gate 1 uses **WarHonor**, which was
    already positive pre-flip — it cannot detect this class. Kyne or Talos
    neglect is the discriminating case.

## Data / codegen

- `PDV_DeityLikesDislikes.csv` actor `azurah` → `azura` (B1). The generator keys
  on runtime `DeityName`; the trailing `h` made `LoadRowsForDeity`'s branch dead
  (12 rows + stance matrix never loaded). Regenerated + spliced.
  `LIKES_DISLIKES_VERSION` 16 → 17; `EXPECTED_LIKES_DISLIKES_VERSION` in
  `pdv_verify.mjs` bumped to match. Stance branch dual-checks `"Azura"||"Azurah"`.
  Papyrus `==` is case-insensitive — casing was never the bug.

## Papyrus — correctness

| ID | Symbol / file | Change |
|---|---|---|
| B3 | `PDV_PlayerEvents.KickstartDevotionLifecycle` → `PDV__ManagerQuest.KickstartIfStalled` | Alias `OnPlayerLoadGame` re-arms the 1s poll + QR worker. Quest scripts never get `OnPlayerLoadGame`; one lost tick was permanent. |
| B16 | `StripAllPdvSpells` | + `RemoveAltmerDisciplineSpells`, `RemoveRedguardRememberSpells`, new `StripAllDaedricPactSpells()` (walks paths → `StripPactSpells`). Malacath price is `SpeedMult`. |
| B4 | 5 rites in manager | `pressed < 0` early-out. `EvaluateBosmerForcedReckoning` was force-severing the Old Contract on a non-shown menu. Sleep rites return `False` (no dream suppression). |
| B7 | `PDV_DeityBase` | `ScoreRepeatableAction` split → `PeekRepeatableAction` (no writes, incl. stale-day reset) + `CommitRepeatableAction`; queue resolved in `AwardPietyInternal` / `RouteActionToOpenPaths`. Signature unchanged → 34 deity scripts untouched. |
| B14 | `PDV_ShrinePrayerEffect`, `PDV_EventSignalActivator`, `PDV_EventSignalEffect` | `RouteSignal()` → `Bool`; day key stamped only on a dispatched route; `!bus.PDV_Manager` guard. No `PDV_EventBus` override. |
| B13 | manager, `PDV_PlayerEvents`, `PDV_T3DailyLowHealthSaveEffect` | ~26 daily stamps → 06:00 devotional day (`GetDevotionalDayStamp`, zero-reserved `+2`). Day-0 false blocks fixed. Journal dates / N-day windows deliberately left on wall clock. |
| B13 | `PDV_T3DailyLowHealthSaveEffect` | `ConfirmSaveLanded()` (`WaitMenuMode(0.25)` + `!IsDead()` + health > 0) before spending the charge. |
| B12 | `HandleOrcCodeHolds` | Daily cap + toast. Audit's "`Cast()` the spells" is wrong — both are `ConstantEffect` abilities; `Cast()` is a no-op. |
| B2 | `PDV_ActionRouter.HandleStoryKillActor` | `aiRelationshipRank > -2 && !IsHostileKill(...)`. Hostile Justiciar patrols have rank 0. |
| B8 | `RegisterQuestReactionFaucetEvents` | `RegisterForHitEventEx` moved above the `JsonExists` early-out. Missing matrix was killing all hit detection → all near-death payloads. |
| B5 | `PDV_MCM.OnPageReset` | `ResetAllOptionIds()` as first statement; **generated from our own 169 declarations**, not copied. Stale oids could reach destructive debug handlers. |
| B17 | `PDV_MCM` | `SIGNAL_TYPE_MAX` 999 → 3200 (real ids 101–3102). |
| D5 | `PDV_MCM.RunCurseStateSmoke` | + `PDV__ManagerQuest.ResyncCurseStateMirror` — service owns curse state, manager owns the None-keyed `PDV.Curse.State` mirror the Redguard gate + director read. |
| A3 | `RemoveQueuedQuestReactionJob` | `ClearAllPrefix("PDV.QR.Job.<id>.")` (trailing dot load-bearing) + one-time `RunAuthoriaQuestReactionKeySweep` gated on empty queue. |
| D7 | `OnItemAdded` | Khajiit pickpocket bus null-guard. |
| D2 | `PDV_Deity_AuriEl.ScoreCuratedSignal` | Returns `DELTA_*` properties instead of literals 1.0/3.0. |
| B9 | `StartBardPerformancePoll` | `PDV_BardLastRouteRealTime = -100.0` on load. `GetCurrentRealTime()` is session-relative but the stamp persists. |

**A2 (seed-once) NOT ported — does not reproduce.** Our live `PDV_Origin` already
diverges from 1.0.2: unknown-race 5-poll deferral (`UNKNOWN_RACE_DEFER_*`) plus a
recapture floor-seed (`SeedDeity(..., isRecapture)`) that raises but never lowers
piety. Their seed-once guard would block that deliberate late-resolution raise.
Flag to DrHeisen.

## Papyrus — perf

- **C2** `PDV_PlayerEvents`: `CacheQuestReactionFaucetForms()` resolves 21 lists
  once at registration into parallel `Form[]`/`String[]` (cap 128, truncation
  traced). `HasQuestReactionRuntimeForm` **deleted**. Added
  `IsCachedQuestReactionFaucetForm` early-out on object/book routers.
  `RouteQuestReactionBlockedHitFaucet` uses `GetActorRef()` not `Game.GetPlayer()`.
  Was ~16 × per-equip re-resolve, each entry a `GetModByName` linear plugin scan.
- **C4** `PDV_DeityBase`: per-deity participating-event `Int[]` cache
  (`Reset`/`Note`/`Seal`), **fails open** unless sealed after a full rebuild.
  Key-prefix build moved below both gates. Rebuilt by the version bump above.
- **C1** `NormalizePublicDeityDisplayText`: 44 `ReplaceText` passes → 1 (Orkey,
  Nord Old Ways only). 43 were no-ops (case-insensitive `==`). Dead
  journal-title repair loop deleted. Side effect: "the Hist" prose no longer
  mis-capitalised.
- **C3** bard poll two-state 5s live / 15s idle after 2 quiet ticks.
- **D1** `PDV__SM_KillActor` trace gated behind `PDV_Router.GetDebugLevel() >= 3`,
  level check **before** string build. `ProcessDawn` roster warning latched
  once-per-session; `ExportDevotionReport` gated.
- Cadences: `OnUpdate` menu early-out (re-arm **before** the return), reconcile
  split 10s/30s, context probes 1s → 3s. Master poll and QR worker 0.1s unchanged.

## Cuts / renumber (design calls, 2026-07-26)

Doctrine: **wire by default; cut only if truly empty or demonstrably superseded.**

- `PDV_SacredPlace` → declaration-only stub (5 bound props). Superseded, not
  unwired: `TryArgonianBedOfChoiceSleep` / `TryDeclareRestCell` / Khajiit
  road-homes all live. MCM smoke hook + `GetFirstSacredPlace` + `"; Sacred="`
  removed. 3 quest records left inert. Drops 9 unbound-array findings.
- 21 `PDV_Bless_Nord_<god>` props + strip calls **cut** — verified the SPEL
  records **do not exist** in the ESP.
- 30 dead DELTA/substrate knobs cut, each verified unread in-file + unbound.
- 17 write-only `PDV.Daedric.<Prince>.Renounced` writes cut (all inside
  `DebugRenouncePath()`).
- `PDV_Deity_Syrabane` SIGNAL 2001–2005 → **3110–3114** (collided with Boethiah;
  must stay < `SIGNAL_TYPE_MAX` 3200). Award sites remain unwritten → 1.0.4.

## Reverted from their patch — do not re-apply

- **7.1 broad-pantheon containment.** Their `BROAD_SCOPE_CONTAIN` rewrite of
  `BeginBroadPantheonEvent` folds a concurrent act into the live event as nested
  depth → newcomer's deltas judged against the **first** act's pool. Violates
  `pdv_broad_pantheon_audit` `source.concurrent-event-serialization` (serialize +
  fail closed via `BROAD_SCOPE_ABORT`). Spin-wait restored with a comment. Their
  C5 "confirmed gone" is moot for us.
- **`DELTA_ANCESTOR_SPINE` cut** on AuriEl/Magnus/Shor/Talos — `pdv_verify`
  asserts the declarations and the 1.0.4 Altmer Spine wire will read them.
- **`dayKey`/`countKey`/`lastFireKey` inlining** in `PDV_DeityBase` — Phase 7
  audit pins those names. Restored (also less string churn).

## Not adopted

- Automatic once-per-save stat repair. MCM-only by owner decision:
  `GetAuthoriaResidueSummary()` (read-only) + confirm-gated
  `RunAuthoriaActorValueRepair(True, True)`. `QueueAuthoriaSaveRepair` and
  `_authoriaRepairPending` removed; `PrepareForUninstall` still repairs first.
  PO3 `GetActorValueModifier(player, 0, av)` = permanent slot. Record-enum ≠
  runtime AV name for 8 values (`ResistMagic`→`MagicResist`, etc.).
- Green Pact food-branch cut — **1.0.4 wires meat + insect instead**; fungi/egg
  stay neutral. Shipped `PDV_GreenPact_KID.ini` has 0 non-comment lines.
- B18 SM receiver `Stop()`/`Reset()` split — 0.1s defer is the issue #17 CTD fix.

## Gates

`pdv_compile` 0/0 on 49 changed scripts · `pdv_verify` **FAIL=0** (PASS 4119,
1 benign SEQ-mtime WARN) · package gates pass · zip `Devotion-1.0.3-20260726.zip`
sha256 `604C4280…`, 216 entries, 7.6 MB, no excluded files.

**Open:** the `Detrimental` sign check (smoke Gate 1) decides whether the ~21
magnitude flips need a respin. Two classification probes (brawl → assault route,
hostile-animal kill classification) are observation-only, results → 1.0.4.
