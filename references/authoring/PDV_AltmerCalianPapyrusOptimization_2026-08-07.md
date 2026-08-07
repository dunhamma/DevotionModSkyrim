# Altmer calian / ambient / practice-line -- Papyrus performance review (2026-08-07)

Scope: the functions changed between `817dd39b` and `HEAD` in the Altmer lane, harvested by
`tools/pdv_hygiene_harvest.mjs` (75 changed functions; the Khajiit ones are covered by
`PDV_KhajiitPapyrusOptimization_2026-08-06.md` and are not re-reviewed here).

**Source read: the LIVE MO2 tree**, not the repo mirror. On the day of this review the mirror was
stale on 19 files by up to seven weeks, so a mirror-based review would have described a fiction.

**Report only.** No fixes applied; anything actioned becomes its own packet.

## Triggers first (this sets every severity below)

| Path | Trigger | Effective frequency |
|---|---|---|
| `RunDawnChampionAmbient` chain | `ProcessDawn()` from the `OnUpdate` day-rollover arm | **once per devotional day** |
| `HandleAltmerPracticeFocus` -> spine -> line pool | `OnEquipped` on the calian (player click) | player-initiated, and the once-per-day signal short-circuits repeats |
| `LoadRowsForDeity` | `EnsureLikesDislikesTable` behind a `PDV.LD.Version` equality gate | **one-shot per version bump** |
| `RoutePractice` | `OnEquipped` on the MISC | same as the calian click |

The manager's `OnUpdate` is a `RegisterForSingleUpdate(1.0)` chain with a menu early-out whose
re-arm sits **inside** the early-out. That is the correct idiom, and the comment records that a
return which skipped the re-arm previously killed the chain for a whole playthrough. Nothing in
this change set introduces polling.

## Verdicts

### GREEN -- leave alone

- **`RunDawnChampionAmbient` / `RunDawnChampionDeityAmbient` / `RunDawnAltmerHeritageAmbient` /
  `ShowChampionAmbientForDeity`.** Once per day, a handful of StorageUtil reads and at most one
  `Message.Show()`. `ShowChampionAmbientForDeity` returns False for a deity with no records so the
  cadence stamp is not spent on a surfacing that did not happen -- correct, and it costs nothing.
- **`LoadRowsForDeity` (417 lines, ~380 `WriteLD` calls).** The size is irrelevant because
  `EnsureLikesDislikesTable` returns early when the stored version already matches. Verified at
  the call site, not assumed. One-shot per `LIKES_DISLIKES_VERSION` bump.
- **`HandleAltmerPracticeFocus`.** Early-outs are ordered cheapest-first: origin, then curse, then
  the once-per-day signal, before any substrate or JSON work. Textbook guard ordering.
- **`EnsureAltmerPracticeFocus`.** `GetItemCount` + `AddItem` on an init path, now with a
  StorageUtil one-shot so the granted line cannot re-fire on a re-grant.
- **`SendPrismaSubstrateProgress`.** The new `altmer-heritage` branch adds one toast call and
  deliberately does not fall through to the generic path (which would double-log the Book entry).

### AMBER -- real, but low severity on this trigger

**1. `IsAltmerPracticeLineJsonValid` re-validates the whole pool on every pick.**
Each call runs `JsonUtil.Load` + `IsGood` + a version read + a `PathCount`, then a 20-iteration
loop doing two `GetPathStringValue` calls per entry. `PickAltmerPracticeIndex` then scans up to 20
more ids to find the exclusion, and the caller reads a title and body. That is roughly **65
JsonUtil native calls per calian use**.

Severity is held to amber *only* because the trigger is once-per-devotional-day, not because the
call count is acceptable in the abstract. Chasing this harder would be optimising off the hot path.

*Fix if actioned:* cache validity in a script bool plus a cached id list, invalidated on
`OnPlayerLoadGame`. Roughly 65 native calls become 2 after the first use per session.

*Open question, not asserted:* whether `JsonUtil.Load` re-reads from disk or returns a cached
handle on repeat calls. The verdict above does not depend on the answer (the `GetPathStringValue`
volume dominates either way), but the fix's payoff does. Confirm via `papyrus-reference` before
sizing it. **The Khajiit moon-observation picker has exactly the same shape**, so whatever is
decided should apply to both or neither.

**2. `RoutePractice` holds its thread ~4.2 s (`Utility.Wait(0.2)` + `Utility.Wait(4.0)`).**
Normally amber-to-red, but three things hold it at amber: the trigger is a rare player click; the
`_practiceBusy` flag prevents re-entry; and the wait is *deliberate and documented* -- `OnEquipped`
fires while the inventory menu is still open, and the wait resumes only once the game unpauses so
the sound and idle land in-world rather than inside the menu.

The thread held is the MISC object's own script, not the manager's, so nothing else is blocked.
Converting to a `RegisterForSingleUpdate` chain would free it, at the cost of complexity, for no
measurable gain at this frequency. **Recommend: note, do not fix.**

**3. `GetAltmerHeritageSourceLine`'s `practice_focus` arm is now unreachable.**
`AppendAltmerHeritageVoice` intercepts `practice_focus` and delegates to `AppendAltmerPracticeEntry`
before it would ever reach the source-line resolver, so the arm at `:11823` -- and therefore
`GetAltmerPracticeLine` itself, which nothing else calls -- can no longer fire in the live flow.

This is a leftover from my own change earlier today, not pre-existing debt. It is harmless
(defensive fallback) but it is genuine dead code, and it is a *second* place the pool can be drawn
from with its own `LastId` write -- so if it ever became reachable again it would create the
toast/Book divergence the single-pick design exists to prevent. Carried into the dead-code verdict
table rather than fixed here.

## Cross-check against the review checklist

Event contracts valid (no invented signatures); no `RegisterForUpdate` introduced; no unmatched
`Add*`/`Register*`; no property pointed at a placed reference; no `Game.GetPlayer()` in a loop; no
hot-path `Debug.Trace` (the new traces sit behind `Trace(2, ...)` on once-per-day paths); guards
present before expensive work on every new entry point.
