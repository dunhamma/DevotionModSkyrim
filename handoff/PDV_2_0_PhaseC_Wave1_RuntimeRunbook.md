# Phase C wave 1 -- runtime validation runbook

**Date:** 2026-08-19 - **Kind:** LIVING (Gate B check for the empty-body dedup mechanism)

## What this proves

Wave 1 emptied 142 A-tier base duplicate bodies in `PDV_OriginRuntimeBase`, keeping their
declarations. The safety claim is: **the empty base stub never executes, because every call
site is race-gated -- a non-owning race never reaches it, and the owning race hits the adapter
override instead.** Compile 0/0 and static parity prove this is STRUCTURALLY sound. This test
proves it BEHAVIOURALLY.

**Why a normal error-watch is not enough:** if the claim is wrong for some function, a non-R
player would hit the empty stub and get a **silent type default** (empty string / 0 / False)
-- no crash, no Papyrus error. So the test must *observe behaviour*, not just watch the log.

## Preconditions

- MO2 profile **Devotion Dev**, mod folder **Devotion-V3Dev** enabled (the 2.0 config).
- **New game / fresh save** -- the rebuild is new-game-only; an old save will not exercise it.
- Deployed build: all 116 `.pex` recompiled from the wave-1 source (done by the deploy step).
- Papyrus logging on (`Papyrus.0.log`), for the sweep in step 4.

## The test -- one non-owning-race playthrough (start with NORD)

Nord is a good first race: it exercises the broad-pantheon path and leaves the nine other
races' emptied functions (Altmer/Argonian/Bosmer/Breton/Dunmer/Imperial/Khajiit/Orc/Redguard)
as the "non-owning" set that must stay dormant.

1. **Start** a new game as a **Nord**. Get through the intro to where Devotion initialises
   (RaceMenu committed, first load door). Open the **MCM** -> confirm the Status page shows a
   Nord character with the Nord broad-lane content (NOT blank, NOT another race's text).
2. **Worship / piety:** pray at a shrine (or use the MCM debug piety button). Confirm piety
   accrues and the Book of Days / dashboard reflects it. Pick a patron; confirm tier-up
   messaging fires.
3. **Quest reaction:** trigger any quest-reaction event (the debug "Submit quest stage" MCM
   button is the fastest). Confirm a reaction toast + Book entry appear and piety moves --
   this exercises the whole QUESTREACTION subsystem that moved in Phase B.
4. **Curse state (the highest-value check):** become a **vampire or werewolf** as the Nord.
   Confirm the curse onset messaging + state behave normally. This is the key cross-race
   check: the emptied `Apply<OtherRace>CurseHandlers` stubs must stay dormant while the Nord
   curse path runs. Watch that NO wrong-race curse text appears.
5. **Dawn:** wait/sleep through a dawn (06:00). Confirm the daily processing (decay, neglect,
   spell sync) runs without the character's features going blank.

## What would FALSIFY the safety (stop and report)

- Any race feature the Nord SHOULD have shows blank / default / "None" where it had content.
- A curse, dawn, or quest-reaction event does nothing when it should act.
- Book of Days / MCM shows an empty label where a computed value belongs.
- Papyrus log shows a call on a `None` OriginRuntime, or an error naming any of the emptied
  functions (list: `handoff/../scratchpad/emptied_wave1.txt`).

## Papyrus log sweep (step 4 support)

After the session, search `Papyrus.0.log` for: `OriginRuntime`, `None`, `error`, and any
emptied function name. A clean log + the behavioural checks above passing = wave 1 validated,
and the empty-body mechanism is cleared for the remaining waves (B-tier + the 116 review-set).

## After Nord passes

Repeat the core loop (steps 1-3) once as a **second race with rich content** -- Khajiit
(moon/focus) or Breton (tradition) -- to exercise a different owning-race adapter against the
emptied set. Two clean races is enough to clear the mechanism.
