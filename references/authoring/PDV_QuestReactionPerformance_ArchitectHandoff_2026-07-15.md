# PDV Quest-Reaction Performance -- Architect Handoff

## Decision requested

Review the bounded Papyrus quest-reaction delivery design after a real
modlist-pressure test showed a player-visible delay before the first final
toast. Decide whether the current two-cell worker remains the right
architecture, and whether the new cheap-skip optimisation is an acceptable
implementation of its work budget or should be replaced by queue-time
compaction.

This is not a request to widen the queue budget or change Papyrus INI values.
The goal remains safe coexistence with heavily scripted modlists.

## User-visible symptom

The MCM **Quest Reaction Performance Sweep** enqueues four manager-only
logical outcomes in FIFO order:

1. `210731|150` -- MQ101
2. `148154|160` -- MQ105
3. `207142|200` -- MQ106 / Syrabane (45 matrix cells)
4. `221587|220` -- MQ206

The tester first reported an apparent 5-7 second wait. A later run took about
20 seconds for the first `A deed weighed` toast to appear. This is transaction
completion time, not evidence of a slow Prisma render: the player-facing toast
and Book of Days beat deliberately emit only when a logical job finalises.

The relevant pre-fix run showed:

| Log time | Marker | Meaning |
| --- | --- | --- |
| 11:25:38-39 | four `ENQUEUE` markers | Sweep entered FIFO correctly. |
| 11:25:45 | `START qr_1` | First job started. |
| 11:26:03 | `COMPLETE qr_1 elapsed=23.167007` | First final toast was delayed by about 23 seconds. |
| 11:26:03 | `START qr_2` | FIFO advanced normally. |

The Papyrus log also contains `VM is freezing...` at startup. It has not been
causally attributed to PDV and must remain a separate observation; it makes
that run unsuitable as final runtime acceptance evidence. The game was closed
before the latest Manager PEX could be exercised, so there is not yet a
post-change runtime result.

## Architecture already implemented

`PDV__ManagerQuest.ApplyQuestReaction` is ingress-only. It snapshots a matrix
reaction into a StorageUtil-backed FIFO (128 pending-job cap; exact-key
coalescing) and returns. `PDV_QuestReactionWorker` is an SGE quest with a
CK-wired Manager property. While work exists it re-arms with
`RegisterForSingleUpdate(0.1)` and calls Manager-owned bounded slices.

The Manager owns all cell application and finalisation. One logical job emits
one broad-pantheon aggregate, at most one curse refresh, one Breton reward
sync where required, one panel refresh, and one final toast/Book of Days beat.
The queue carries enough state to resume after save/load and emits lifecycle
markers: `ENQUEUE`, `COALESCE`, `OVERFLOW`, `START`, `COMPLETE`, and `RESUME`.

The MCM Debug page exposes read-only queue status and the controlled sweep.
It does not call `setstage`; normal quest-stage behavior must be proven
separately through a reachable safe source.

## Mitigations applied after the slow runs

1. **Deferred curse refresh.** A queued CURSE cell now sets a transaction flag;
   `HandleCurseStateRefresh` runs once in finalisation rather than once per
   curse row.
2. **Trace demotion.** Per-cell unreachable and quest-reaction Daedric stigma
   traces now require debug level 3. Queue lifecycle markers remain level 1.
3. **Cheap-skip path.** `ProcessQuestReactionQueueSlice` advances matrix rows
   which cannot produce work without spending one of the two *applied-cell*
   slots. It skips missing-deity/zero-value cells and unreachable
   TABOO/HOSTILE/FOREIGN/TOLERATED rows. CURSE and reachable rows always go
   through normal application.

The latest source is in:

- `live-source/Scripts/Source/PDV__ManagerQuest.psc`
- `live-source/Scripts/Source/PDV_DaedricPathBase.psc`
- `live-source/Scripts/Source/PDV_QuestReactionWorker.psc`
- `tools/pdv_quest_reaction_performance_audit.mjs`

The live MO2 PEXes were compiled after those changes:

- `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV__ManagerQuest.pex`
  -- 2026-07-15 23:28:46
- `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_MCM.pex`
  -- 2026-07-15 23:29:02

The tester has now closed Skyrim. A full relaunch is required; MO2 refresh
only makes changed files visible for the next launch and cannot replace a PEX
already loaded in a running VM.

## Evidence currently available

Static and bytecode freshness gates pass after the latest compile:

```powershell
node .\tools\pdv_quest_reaction_performance_audit.mjs --json
node .\tools\pdv_prisma_ui_audit.mjs
node .\tools\pdv_book_of_days_audit.mjs
```

The performance audit verifies the queue cap, no queue-path waits, no
cross-update broad-pantheon scope, bounded normal/meta work, deferred
finalisation, single final surface pass, save/load resume, ingress-only routes,
and the cheap-skip safety rules. Prisma audit passed 121 checks; Book of Days
audit passed 126 checks with no warnings.

This is static/compile proof only. It does not establish wall-clock latency or
rule out an interaction with the broader modlist VM load.

## Architectural tension to resolve

The original contract said "at most two cells every 0.1 seconds." The
cheap-skip implementation preserves that limit for cells that can invoke a
deity path, but it can scan more than two cheap rows in a single update. With
the current 45-cell MQ106 matrix this is small; nevertheless it changes the
literal meaning of the budget and should be consciously accepted or replaced.

There are two viable paths:

### A. Keep applied-work budgeting (current implementation)

Treat only a row capable of a deity-path call as work. The current test matrix
is fixed and small, and skipping unreachable/no-op rows avoids burning 0.1 s
ticks on work that has no state or player-facing effect. Keep a hard row-scan
ceiling if future matrices can grow materially beyond current size.

### B. Compact at ingress (recommended if strict boundedness is required)

Resolve matrix rows once when snapshotting a job, store only runnable rows plus
explicit metadata, and retain an exact count of skipped rows for diagnostics.
The worker then processes a strict maximum of two persisted runnable rows per
update. This gives the architect a clean, literal work bound and makes the
completion duration depend on meaningful reactions rather than matrix width.
It costs more queue snapshot work and requires careful save/load serialization.

Neither option should make a full 45-row synchronous fan-out acceptable.

## Recommended next proof loop

1. Start Skyrim from MO2 after F5, using the fresh PEXes. Use a disposable
   save and set the normal PDV debug level used by the harness.
2. Run exactly one MCM performance sweep. Do not use `setstage` for this
   controlled proof. Reopen Book of Days if it was already open; its overlay
   payload is not live-refreshed while open.
3. Run the runtime checker from the repo:

```powershell
node .\tools\pdv_quest_reaction_runtime_check.mjs --expected-sequence '210731|150,148154|160,207142|200,221587|220'
```

4. Capture Papyrus profiling for the same run. The comparison should separate:
   synchronous stage ingress, worker `OnUpdate`, Manager cell application,
   metadata processing, and finalisation.
5. If `qr_1` still takes materially longer than the intended 2-3 seconds,
   add aggregate, job-level timing fields only (runnable/cheap-skipped/meta
   counts and finalisation duration). Do not restore per-cell traces at normal
   debug levels.

## Acceptance boundary

Do not call this issue resolved until a fresh-process sweep has all four
`COMPLETE` markers in FIFO order, no `BROAD_SCOPE_ABORT`, no queue overflow,
one final toast and matching Book of Days entry per completed logical job, and
no VM freeze attributable to PDV. MQ106 must also be proven through one
organic, safe quest-stage route after the controlled sweep.

Current state: implementation and static gates are green; runtime performance
after the latest changes remains unproven.

---

## Architect decision (2026-07-16)

**Direction: optimize, proof-gated.** The bounded two-cell worker stays. The
cheap-skip stays. **Option B (ingress compaction) is rejected** -- it relocates
the resolve burst to the quest-fire instant (the busiest thread-moment for
modlist coexistence) and adds save/load serialization risk, while the real cost
can be removed in place.

### Root-cause refinement

The per-cell cost that made a 45-cell job's cheap-skip pass a synchronous burst
was **deity resolution**: `GetQuestReactionDeity` ran `GetDeityByName`, an
`O(deities)` `FormList` scan (`GetAt` + cast + string-compare per element), plus
a Daedric-path `FormList` scan on a name miss -- once per cell, twice for a
runnable cell (cheap-skip check, then `ApplyDeityReaction`). The name->deity
mapping is static for the session, so this is fully cacheable.

### Tier 1 applied (audit-neutral, no contract change)

`GetQuestReactionDeity` now reads/writes a `StorageUtil` form cache keyed by
name (`PDV.QR.DeityCache.<name>`), populated on first successful resolve; only
non-None results are cached so a not-yet-loaded form re-scans until it hits.
`GetDeityByName` is unchanged (other callers unaffected). No change to
`CELLS_PER_TICK`, `TICK_SECONDS`, `MAX_PENDING`, the slice loop, or the
cheap-skip helper -- the redundant second lookup on a runnable cell is now a
cache hit, so no structural change to the skip/apply split was needed. This
preserves the full quest-reaction content: **172 quest-stage entries, 1,978
reaction cells, 45 deities, ~44 quests-per-deity** (25 universal 45-cell quests
= 57% of all cells). Descope was rejected for 1.0 because cutting the universal
fan-outs would drop quests-per-deity 44 -> 19 and gut thin Daedra
(Sanguine 27->2, Namira 28->3, The Hist 29->4) to avoid a solvable scan.

### Static / bytecode evidence (2026-07-16)

- Compile: `PDV__ManagerQuest` and `PDV_MCM` both `0 error(s), 0 warning(s)`.
- `pdv_quest_reaction_performance_audit.mjs`: PASS (34/0) -- change is
  audit-neutral, the two-cell contract is intact.
- `pdv_prisma_ui_audit.mjs`: 121 checks PASS; content-derived cache key
  unchanged -> **no bridge/view rewiring and no cache-bust required** (the cache
  returns the same deity object, so display name/symbol payloads are identical).
- `pdv_book_of_days_audit.mjs`: PASS 126/0.
- `pdv_signal_e2e_gate.mjs`: PASS (112 ok, 0 failures); live MCP portion SKIP
  (bridge offline), not a failure.

This is static/compile proof only. It does not establish wall-clock latency.

### Runtime proof still owed (blocks "resolved")

Caching removes per-cell compute and the cheap-skip scan burst, but it does
**not** reduce tick count -- latency for a devout player with many reachable
deities is still `ceil(runnable/2)` worker updates, which land ~1 s apart under
a heavy VM. Run the proof loop below; if `qr_1` is still materially above the
2-3 s target, the cause is tick-count-bound and the fix is **Tier 2** (raise
`QUEST_REACTION_QUEUE_CELLS_PER_TICK` 2 -> ~6 plus a hard per-tick row-scan
ceiling), which changes the reserved two-cell contract and its audit constants
and therefore needs owner sign-off.

Proof loop (unchanged from "Recommended next proof loop" above):

1. Fresh Skyrim launch from MO2 on a disposable save after F5, using the fresh
   `PDV__ManagerQuest.pex` / `PDV_MCM.pex` compiled 2026-07-16.
2. Run exactly one MCM **Quest Reaction Performance Sweep** (do not `setstage`).
   Reopen Book of Days if it was already open.
3. `node .\tools\pdv_quest_reaction_runtime_check.mjs --expected-sequence '210731|150,148154|160,207142|200,221587|220'`
4. Accept only against the Acceptance boundary above, plus `qr_1 elapsed`
   materially below the prior ~23 s (target 2-3 s). Prove MQ106 through one
   organic safe quest-stage route after the controlled sweep.

Current state: Tier 1 shipped and static/Prisma/BoD/signal gates are green;
runtime latency remains unproven and is the sole remaining gate.
