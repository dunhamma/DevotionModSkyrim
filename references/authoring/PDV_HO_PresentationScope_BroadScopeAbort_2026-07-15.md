# PDV Handoff - Presentation Scope and BROAD_SCOPE_ABORT

Created: 2026-07-15

Status: the scope/interface tranche and follow-up Breton acknowledgement
correction are compiled and deployed. The Breton three-book card, Imperial
broad-scope book-plus-quest card, Altmer three-book presentation regression,
and controlled standalone-root card pass in runtime and player-facing smoke.
The broad-scratch accounting readout now also passes. No further in-game
regression card is required for this scoped fix.

## Scope

Two related but distinct failure classes were reviewed after the Breton Hidden
Art three-book test:

1. A successful P2 source route could award practice/piety but lose both its
   transient Prisma toast and Book of Days chronicle entry while race-startup
   quiet presentation was active.
2. `[PDV][BROAD_SCOPE_ABORT]` appears during ordinary book and quest-stage
   routes, proving that nested receivers are opening competing broad-pantheon
   scope identities for one Logical Devotional Act.

Do not merge the two fixes. Presentation governs player acknowledgement;
broad-event scope governs the ADR-0001 strongest-applied-delta aggregation.

## Implementation Result (2026-07-15)

The planned source tranche is now applied in both the live Anvil source tree
and `live-source` mirror:

- `SurfaceP2BookReadNotice` validates `po3_book` provenance and uses the
  paired toast/chronicle delivery with setup visibility.
- `SurfaceP2AmbientProgressNotice` is now used only by the Altmer and Breton
  sleep paths and respects setup quiet presentation.
- `SurfaceP2Acknowledgement` owns the paired delivery details, so producers
  no longer carry the quiet-policy boolean.
- Follow-up runtime diagnosis found that `HandleBretonHiddenArtExposure` gated
  acknowledgement on `practiceAwarded`. That is wrong: the practice cap may
  reduce mechanics, but an approved unique P2 book still needs its own player
  acknowledgement. The handler now always calls `SurfaceP2BookReadNotice`; the
  Prisma audit and Breton runtime checker both encode the three-book contract.
- `PDV_PlayerEvents`, `PDV_EventBus`, `PDV_ActionRouter`, and
  `PDV__ManagerQuest` now propagate a supplied Logical Devotional Act identity
  through nested book, harvest, P2 source, P2 quest-stage, generic-action, and
  quest-reaction paths. `JoinBroadPantheonEvent` refuses a mismatched identity
  without clearing the active root scope.
- `tools/pdv_prisma_ui_audit.mjs` now guards the book-versus-ambient interface;
  `tools/pdv_broad_pantheon_audit.mjs` now guards parent identity propagation
  for the known book and quest nested routes.

`PDV__ManagerQuest`, `PDV_PlayerEvents`, `PDV_EventBus`, `PDV_ActionRouter`,
and `PDV_MCM` compiled with 0 errors and 0 warnings. After the follow-up
correction, Manager and MCM were recompiled while Skyrim was closed. The
manager and MCM PEX freshness checks now pass. `pdv_verify.mjs` reports
`FAIL=0, WARN=1, TODO=1, PASS=4138, INFO=62`. The broad-pantheon audit passes.
The Prisma audit's new P2/PEX checks pass; its unrelated reason-bearing
substrate-copy assertion remains open.

## Evidence

### P2 presentation family

- The live `PDV__ManagerQuest.ShowP2BookNotice(...)` helper is the single
  producer used by the P2 book-facing race handlers (Altmer, Argonian, Breton,
  Dunmer, Imperial, Nord, Orc, and Redguard).
- The reported Breton log proves all three hidden-art routes completed and
  awarded piety. The first book was visible, while the next two had no toast
  and no Book of Days entry. This rules out piety clamp/cap suppression.
- The compiled repair makes a player book acknowledgement call both
  `SendPrismaToast(..., True, True)` and
  `AppendBookOfDaysEntry(..., True)`. The final `True` is the current
  `allowDuringRaceSetup` escape hatch.
- `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` and
  `node .\tools\pdv_compile.mjs --script PDV_MCM` completed with 0 errors and
  0 warnings before this handoff. The P2 toast/chronicle and PEX freshness
  checks in `node .\tools\pdv_prisma_ui_audit.mjs` passed; do not treat that
  static result as manual UI proof.

### P2 interface drift found by the wider search

`ShowP2BookNotice` currently also has two synthetic sleep callers:

- `HandleAltmerSleepDream` sends `po3_book_altmer_sleep_dream`.
- `HandleBretonSleepRest` sends `po3_book_breton_sleep_reflection`.

Those are progress notices, not book reads. They should retain normal quiet
presentation behavior. The current function name and string-token gate make
that distinction invisible at the caller, which is the shallow interface that
allowed a book-specific policy to be applied too broadly.

### BROAD_SCOPE_ABORT reproduction from the live log

The current Papyrus log includes all of these observed collisions:

```text
[BROAD_SCOPE_ABORT] discarded stalled logical event book_972299 before likes_dislikes_342_...
[BROAD_SCOPE_ABORT] discarded stalled logical event book_909238 before likes_dislikes_342_...
[BROAD_SCOPE_ABORT] discarded stalled logical event book_518915 before likes_dislikes_342_...
[BROAD_SCOPE_ABORT] discarded stalled logical event quest_210731_800 before p2_quest_210731_25
```

The first three are deterministic same-stack nesting, not evidence that a
different Papyrus stack was merely slow:

1. `PDV_PlayerEvents.OnBookRead` opens `book_<FormID>`.
2. `RouteGenericBookRead` reaches the action router.
3. `BeginLikesDislikesSurface` immediately opens a different
   `likes_dislikes_<event>_<time>` scope.
4. `BeginBroadPantheonEvent` waits for its own caller to flush the outer scope.
   That caller cannot resume while it is waiting, so the two-second timeout
   clears the outer scope and emits `BROAD_SCOPE_ABORT`.

The quest collision follows the same pattern:

1. `PDV_PlayerEvents.OnQuestStageChange` opens `quest_<QuestID>_<Stage>`.
2. `RouteP2ImmersiveQuestStage` opens a second
   `p2_quest_<QuestID>_<Stage>` scope before the outer scope flushes.

The existing `pdv_broad_pantheon_audit.mjs` passes because it verifies that a
timeout exists, not that nested receivers preserve the caller's logical-event
identity. Its current PASS is therefore source-contract coverage, not proof
that these runtime aborts are safe.

## Recommended Architecture

### 1. Deepen player acknowledgement into two explicit interfaces

Keep one private implementation in `PDV__ManagerQuest`, but replace the
meaningful policy boolean at normal call sites with two named interfaces:

```text
SurfaceP2BookReadNotice(sourceReason, titleText, messageText)
SurfaceP2AmbientProgressNotice(titleText, messageText)
```

`SurfaceP2BookReadNotice` must require real `po3_book` provenance and always
write both toast and chronicle despite a quiet setup scope. It owns the
`P2 book notice surfaced:` trace.

`SurfaceP2AmbientProgressNotice` must use the same toast/chronicle formatting
but respect quiet presentation. Move only the Altmer sleep-dream and Breton
sleep-reflection calls to it. All actual book callers stay on the first
interface.

The private implementation may retain the boolean because it is no longer an
interface that every producer must understand. This creates locality: source
producers state what happened (book read versus ambient progress), while the
module owns the quiet-presentation rule and paired toast/chronicle delivery.

### 2. Pass one explicit Logical Devotional Act identity through nested routes

Do not make `BeginBroadPantheonEvent` silently absorb arbitrary different IDs:
that would merge genuinely concurrent acts and violate ADR-0001. Instead,
preserve the outer identity explicitly:

- Add manager-level `JoinBroadPantheonEvent(logicalEventId)` and
  `LeaveBroadPantheonEvent(logicalEventId)` helpers. Joining must succeed only
  when the active ID exactly matches; on mismatch it must trace a new
  `[PDV][BROAD_SCOPE_MISMATCH]` marker and return false without clearing the
  current scope.
- Let root ingress create the ID exactly once: book, harvest, and quest-stage
  events in `PDV_PlayerEvents`; standalone router actions may remain roots.
- Add an optional `logicalEventId` parameter to nested receiver entry points
  (P2 source, P2 quest-stage, generic book/action, quest reaction, and
  likes/dislikes surface). Nested work joins and leaves the supplied identity;
  it never mints `p2_quest_*` or `likes_dislikes_*` inside a live outer act.
- Retain `BeginBroadPantheonEvent`'s timeout only for a genuinely independent
  root stack. Its abort must never be the normal control flow for nested work.

This is the correct seam: the Logical Devotional Act module hides aggregation
and nesting mechanics behind one identity. It gives callers leverage (all
deity fan-out remains one strongest-delta event) and gives maintainers locality
(the ownership rule is verified in one place rather than guessed from several
generated IDs).

## Required Implementation Order

1. Completed: refactor the two P2 notice interfaces in both live source and
   tracked mirror:

   ```text
   D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc
   C:\Users\Admin\Documents\Devotion Mod Project\live-source\Scripts\Source\PDV__ManagerQuest.psc
   ```

2. Completed: extend `tools/pdv_prisma_ui_audit.mjs` to fail unless:
   - the book interface writes both toast and chronicle with setup visibility;
   - the two sleep callers use the ambient interface; and
   - no direct caller outside that private implementation passes the setup
     bypass boolean.
3. Completed: implement explicit event-ID propagation across:

   ```text
   PDV_PlayerEvents.psc
   PDV_EventBus.psc
   PDV_ActionRouter.psc
   PDV__ManagerQuest.psc
   ```

4. Completed: extend `tools/pdv_broad_pantheon_audit.mjs` with a static fixture
   for both known paths: `OnBookRead` must not open an unrelated
   `likes_dislikes_*` scope, and `OnQuestStageChange` must not open an
   unrelated `p2_quest_*` scope. The old timeout-presence assertion is not a
   sufficient regression test.
5. Completed after the follow-up acknowledgement correction: Skyrim was closed,
   `PDV__ManagerQuest` and `PDV_MCM` compiled, and the static gates were run.
   Execute the manual cards below from a fresh main-menu/QASmoke save.

## Verification Cards

### Presentation

Use the Breton three-book packet first. Pass only if each accepted book shows
one toast, one distinct Book of Days entry, and one of these exact traces:
`P2 book notice surfaced: Hagraven lore`, `P2 book notice surfaced: A witch's
note`, and `P2 book notice surfaced: Reach-mad whispers`. The runtime checker
now requires all three markers. Then test one Altmer, Argonian, Orc,
Redguard, Dunmer, Imperial, and Nord P2 book source. Separately test the two
sleep notices during normal play and during a startup/setup action: they may
surface normally but must remain quiet while setup is active.

### Broad scope

Use a broad-eligible origin (Imperial or Nord) on a fresh save:

1. Read one ordinary lore book and one P2 book.
2. Trigger a watched quest stage that has both P2 and quest-reaction handling.
3. Trigger one standalone routed action (not nested beneath a book or quest).
4. Search the fresh log for `BROAD_SCOPE_ABORT` and `BROAD_SCOPE_MISMATCH`.
   Both must be absent for the accepted cards.
5. Capture the broad scratch delta and per-deity deltas. Each Logical
   Devotional Act must contribute at most one strongest signed pool delta,
   per ADR-0001.

Run:

```powershell
node .\tools\pdv_broad_pantheon_audit.mjs
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager
```

## Proof State

- Authority: ADR-0001 defines one strongest signed contribution per Logical
  Devotional Act; this handoff defines the missing identity-propagation and
  notice-provenance contract.
- Readback/static: source mirrors match the live source. The P2 acknowledgement
  regression check passes, the manager/MCM PEX files are fresh, the broad audit
  passes, and the verifier reports no failures.
- Runtime-route: the 2026-07-15 fresh `Papyrus.0.log` records all three
  accepted Breton routes and all three acknowledgement traces: Hagraven lore,
  A witch's note, and Reach-mad whispers. The later Imperial card records
  `RouteImperialTalosPressure complete: 141`,
  `RouteImperialCivicService complete: 140`, and
  `RouteQuestReaction complete: stage 190`. A repeat read records both
  `Generic book read repeat skipped: 970829` and
  `P2 immersive source repeat skipped: imperial_public_talos`. The fresh log
  contains no `BROAD_SCOPE_ABORT` or `BROAD_SCOPE_MISMATCH` marker. The
  Altmer regression then records `P2 book notice surfaced:` plus the exact
  Auri-El, Magnus, and Xarxes route completions; the focused Altmer runtime
  checker passes. The standalone MCM `MQ302 300` root records
  `QuestReaction: 284963|300 applied 4 cells` and
  `SignalFloorSmoke quest routed: MQ302 300 key 284963|300 cells 4`; the
  fresh log still has neither broad-scope marker. After `Return to broad
  worship` plus an Imperial pool reset, the repeat `MQ302 300` root awards
  Mara, Stendarr, and Akatosh `+4` each; the manual pool readout is
  `active=TRUE`, `scratch=4.000000`, and `lastEvent=quest_284963|300`.
  That is the required single strongest-positive pool contribution.
- Manual/player surface: tester confirmed three distinct toasts and Book of
  Days entries for the Breton card. For Imperial, the Talos book produced two
  distinct-lane toasts and the quest produced one combined acknowledgement;
  the Book of Days shows all three entries. The repeat book read produced no
  player-facing acknowledgement, as required by the once-per-source rule.
  The Altmer card produced all three P2 toast/Book-of-Days acknowledgements;
  two books also surfaced an accepted, distinct generic-book-lane toast.
  The controlled standalone-root card produced one combined acknowledgement.
  The active-pool readout confirms its one `+4` scratch contribution.
  This closes the scoped presentation/logical-event regression only; it does
  not authorize a broader beta or broad-pool readiness claim.

Next required step: resume the independent 1.0 co-test queue only if desired;
this presentation/scope tranche needs no further game action.
