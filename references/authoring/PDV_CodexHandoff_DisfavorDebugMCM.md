# Codex Handoff - Debug MCM: dislikes & disfavor stings

**Created:** 2026-07-07
**Priority:** HIGH - test-harness enabler. Build BEFORE the race felt-proof
sittings; it turns the slowest part of every sitting (proving dislikes + the 7
disfavor domain stings) from in-world transgressions into MCM clicks.
**Owner:** Codex (headless). You just built the disfavor runtime, so you own
the entrypoints this wires to.
**Scope:** ~4 debug buttons on the MCM Debug/State page + any small manager
debug helpers they need. No gameplay/economy change; debug-only.

---

## Why

The MCM debug page can prime boons (Target piety + Apply), neglect (Prime
neglect eligible + Run neglect pass), curse, focus, and substrate - but there
is NO way to fire a generic likes/dislikes transgression. "Apply curated
signal" only covers P2 curated signals, not the dislike events
(murder-defenseless 304, raise-undead 365, steal-item 362, etc.). So proving
the 33 dislikes + 7 disfavor domain stings currently requires actually
performing each act in-world. This packet adds the debug buttons to fire them.

The tester does NOT use the console (`cqf`); all debug is MCM-driven. Wire
every new debug affordance as MCM buttons.

---

## The disfavor runtime you built (entrypoints to wire to)

In `live-source/Scripts/Source/PDV__ManagerQuest.psc`:

- `AwardPietyFromLikesDislikes(PDV_DeityBase deity, Float amount, Int eventType, String reason)` (~1399) - the real dispatch; a negative amount here triggers `ApplyDisfavorSting`.
- `ApplyDisfavorSting(PDV_DeityBase deity, Float appliedAmount, String sourceTag)` (~10557) - band from `abs(appliedAmount)`, domain from `DomainForDeity`, respects standing/cap/repeat.
- `HasDisfavorStanding(PDV_DeityBase deity)` (~10640), `DomainForDeity(PDV_DeityBase deity)` (~10667), `CountActiveDisfavorStings()`, `IsDisfavorRepeatSuppressed` (~10650), `MarkDisfavorRepeatUsed` (~10655).
- Constants (~554-566): `DISFAVOR_DOMAIN_*` (1-7), `DISFAVOR_LIGHT_MIN_DELTA` 0.5, `DISFAVOR_SHARP_MIN_DELTA` 1.0, `DISFAVOR_*_DURATION_DAYS`, `DISFAVOR_MAX_ACTIVE_DOMAINS` 3.
- 14 spell properties `PDV_SPEL_Disfavor_<Domain>_<Light|Sharp>`.
- Raw per-deity delta for an event lives in StorageUtil `PDV.LD.<eventType>.D` (written by `WriteLD`, read by `PDV_DeityBase.ScoreFromTable`).

The MCM already has: selected-deity state (`GetSelectedDeity`), `Target piety`
+ `Apply target piety` (sets standing), and the curated-signal slider pattern
(`_oidPendingSignalType` / `_oidApplyCuratedSignal`) to copy for the event-ID
slider.

---

## Manager debug helpers to add (thin, debug-only)

Add these to `PDV__ManagerQuest.psc` so the MCM stays a thin caller:

1. `Function DebugFireDislike(PDV_DeityBase deity, Int eventType)` - read the raw
   delta `StorageUtil.GetFloatValue(deity as Form, "PDV.LD." + eventType + ".D")`;
   if `0.0`, trace "no dislike row" and return; clear the per-day repeat key for
   (deity, domain, eventType) so repeat testing is not suppressed; call
   `AwardPietyFromLikesDislikes(deity, delta, eventType, "debug_fire_dislike")`.
   This fires the real loss + sting path.
2. `Function DebugApplyDomainSting(Int domainValue, Bool sharp)` - directly
   `Game.GetPlayer().AddSpell(<the matching PDV_SPEL_Disfavor_* property>, False)`
   and register its expiry the same way `ApplyDisfavorSting` does, so the
   eyeball check uses the real spell + real expiry.
3. `Function DebugBurstAntiStack()` - fire distinct-domain stings across 4
   different domains in sequence (e.g. via `DebugApplyDomainSting` on domains
   1,2,4,5) so the tester can confirm the cap holds at 3 and the 4th is
   suppressed.
4. `String Function GetActiveDisfavorSummary()` - one-line readout: for each
   active domain, its name + remaining game-hours (from the stored expiry keys);
   "none" when empty.
5. `Function ClearAllDisfavorStings()` - remove all active disfavor spells +
   clear their expiry/active keys (reuse whatever expiry-removal `ApplyDisfavorSting`
   registers).

Keep these guarded to the debug page (they are only called from the MCM Debug
handlers); no organic caller.

---

## MCM buttons (in `PDV_MCM.psc`)

Add a new section on the State/Debug page (near the piety setters, since the
tester sets standing then fires). Follow the exact existing pattern: an
`Int _oid... = -1` per control, `AddTextOption`/`AddSliderOption` in the page
build, an `OnOptionSelect` branch each, and label helpers.

1. **Dislike event ID** (slider) + **Fire dislike vs selected deity** (button)
   - slider `_oidDisfavorEventId` over the dislike event IDs (reuse the
     curated-signal slider pattern; a cycle over the known dislike IDs is fine).
   - button calls `PDV_Manager.DebugFireDislike(GetSelectedDeity(), _pendingDisfavorEventId)`.
   - label shows the selected deity + event label (reuse `EventLabel` from
     `PDV_EventTypes`). Reminder in the button hint: set Target piety >= 25 first
     so the standing gate passes (or note it fires loss-only below standing).
2. **Anti-stack burst (4 domains)** - calls `DebugBurstAntiStack()`; after, show
   `GetActiveDisfavorSummary()` in a Notification/Message so the tester sees the
   cap held at 3.
3. **Show active disfavor** - Message with `GetActiveDisfavorSummary()`.
   **Clear active disfavor** - calls `ClearAllDisfavorStings()`.
4. **Domain sting: cycle domain** (`_oidDisfavorDomainCycle`, cycles 1-7 with a
   name label) + **cycle band** (Light/Sharp toggle) + **Apply domain sting** -
   calls `DebugApplyDomainSting(domain, sharp)` to eyeball the raw MGEF
   magnitude/text/duration.

---

## Build + verify

- Recompile `PDV_MCM` AND `PDV__ManagerQuest` (MCM must be recompiled after any
  manager recompile so the new properties/functions resolve). Deploy to MO2,
  keep live-source and MO2 in sync.
- Compile-clean + `pdv_verify.mjs` FAIL=0.
- Optional: extend `pdv_dislike_consequence_audit.mjs` with a debug-wiring check
  (the new manager helpers + MCM OIDs exist).
- Manual smoke (records into the tester's flow, not a gate): select Arkay, set
  Target piety 25, Fire dislike 365 -> see the piety loss + the DeathAncestors
  sting in Active Effects; Anti-stack burst -> summary shows 3 active, 4th
  suppressed; Clear -> summary "none"; Apply domain sting Sharp -> the raw MGEF
  shows at the sharp magnitude.

## Guardrails

- Debug-only; no organic caller, no economy/dispatch change.
- ASCII-safe copy (`pdv-player-copy`, ascii guard). Snapshot the untracked live
  manager before editing; sync live-source -> MO2.
- Do not edit the toolchain scripts (`pdv_compile`/`pdv_verify`/`pdv_author`).
