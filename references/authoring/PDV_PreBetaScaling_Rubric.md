# PDV Pre-Beta Gameplay Scaling Rubric

**Created:** 2026-05-31
**Status:** Acceptance rubric. Defines the concrete bar for "this race feels
done" so the Phase 20 pre-beta scaling lane stops being judged by feel alone.
**Owner docs it serves:**
`references/authoring/PDV_RaceGameplayBalanceAudit.md` (the lenses this rubric
scores), `references/authoring/PDV_RaceImplementationCostingBacklog.md` (the
per-race work this rubric grades), `PDV_TargetEndStates_1.0.md` Section 25.6
Content-Feel Beta gate, and
`references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` (which proves
routes only and explicitly defers feel to this lane).
**Why this exists:** Every Phase 20 race slice is now QASmoke route-proven but
blocked on "pre-beta gameplay scaling," which had no defined acceptance bar. The
runbook says feel is "best judged after scaling" without saying what scaled
looks like. This rubric is that bar, so all ten races are judged consistently
and the 20B/20D estimate becomes a countable per-race pass.

> Route proof (QASmoke) answers "does the signal reach the route." This rubric
> answers "does the race feel like a religion in normal play." They are
> different proofs and route proof does not imply this one.

---

## How to use this

Each race is scored against the ten dimensions below. A race is **Beta-Ready**
when it passes every **P0** dimension and is at least `Acceptable` on every
**P1** dimension. A race that fails any P0 dimension is **Not Ready** regardless
of how rich it is elsewhere - this is what stops a hook-rich race shipping with
silent gaps or a farm loop.

Score each dimension `Pass` / `Acceptable` / `Fail` with a one-line evidence
note (the save, the trigger, the readout observed). Record per-race scorecards
at the bottom of this file as races are scaled.

Proof must be **normal play**, not QASmoke activators: the trigger fires from a
real world object, quest beat, or behavior the way a player would hit it.

---

## The ten dimensions

### P0-1: Foreground path credibility
**Bar:** At least one race-aware foreground path is playable end to end in
normal play - a player of this race can find it, engage it, reach a tier-up,
and understand what they committed to, without the console or QASmoke.
**Prove by:** One clean save, normal play, reaching at least Tier 2 (or the
race's commitment beat) on the race's signature lane.
**Verifier tie-in:** none direct; this is the Section 25.6 "credible race-aware
foreground path" requirement.

### P0-2: Reward wealth and tuning
**Bar:** The signature lane has a positive reward loop whose magnitude is set
(not the placeholder default) and feels worth noticing without being a
must-maintain chore. Reward is more than a hidden counter moving.
**Prove by:** The reward applies, is felt in play, and a one-line note records
the tuned magnitude versus the Nord control race.
**Verifier tie-in:** reward budget recorded in
`PDV_RaceRewardBudgetLedger.md` immersion matrix.

### P0-3: Immersion proof (diegetic meaning)
**Bar:** The race's `immersionProof` block is proven in normal play, not just
asserted in the manifest. All four fields hold:
`signaturePromise`, `diegeticTriggerMeaning`, `feedbackSurface`,
`rejectedGenericBehavior`, plus the normal-session-feel statement.
**Prove by:** Walk the strongest reward loop and confirm the player can name
the diegetic reason it fired and see the feedback that taught them.
**Verifier tie-in:** `node tools/pdv_verify.mjs --strict-phase20-race-costing`
enforces the `immersionProof` block exists; this dimension proves it is *true*
in play.

### P0-4: Rejected-hook coverage (negative proof)
**Bar:** Every behavior listed in the race's `rejectedGenericBehavior` is
tested and confirmed **inert** - generic kills, raw skill gain, ordinary city
presence, faction membership alone, MCM-only mode selection, etc. do not award
the race's favor.
**Prove by:** Trigger each rejected behavior on a clean save and confirm zero
favor movement. This is the check that the lane is culturally specific, not a
generic stat hook in costume.
**Verifier tie-in:** rejected hooks are listed per manifest; proof is runtime.

### P0-5: Anti-farm
**Bar:** No repeatable loop produces unbounded favor. Cooldowns, daily caps,
per-signal anti-repeat, and one-active-favor behavior are proven to hold under
deliberate repetition.
**Prove by:** Repeat the strongest positive trigger back to back and confirm the
cap/cooldown engages (e.g., Bandit Road reversal 7-day cooldown, one-active
favor suppression, road-home same-anchor rejection).
**Verifier tie-in:** anti-farm rules are in the costing manifests; proof is
runtime.

### P1-6: Status / Survey legibility
**Bar:** The player can read their current religious state in plain
player-facing language via the Player page and Survey Devotion, without exact
piety numbers. State changes are explainable.
**Prove by:** Open Survey/Player page in each major state the race can be in and
confirm the readout is correct and legible.
**Verifier tie-in:** Phase 18 status surface; runtime readback.

### P1-7: Neglect and recovery texture
**Bar:** When devotion decays, the neglect reads as something thematic and
specific (the Section "neglect texture" target), and recovery is possible and
legible - not a stat silently sliding with no story.
**Prove by:** Let the lane lapse past grace, observe the neglect texture line,
then recover and confirm the recovery reads.
**Verifier tie-in:** Phase 16/17 neglect+decay; runtime.

### P1-8: World placement
**Bar:** The race's triggers are attached to real world objects, quest beats,
or behaviors - not QASmoke activators. The player encounters them in the world.
**Prove by:** Hit the trigger in its real world location with no QASmoke
involvement.
**Verifier tie-in:** placement check; this is the step beyond the QASmoke
runbook.

### P1-9: Firing density (spam check)
**Bar:** In a steady session the race stays quiet: marked surfaces `<1 per 2h`,
noted `<2 per h`, quiet surfaces are passive. The race does not read as a second
hunger meter (Section 25.6 / 25.7).
**Prove by:** A steady-play session log against the manifest firing-density
sanity targets (the Boethiah Section 6.9 shape, applied per race).
**Verifier tie-in:** firing-density sanity in the manifests; runtime sample.

### P1-10: Curse-state interaction (where applicable)
**Bar:** Where the race has curse-state rules (vampire/werewolf suppression,
scar, exile), the interaction is correct, recoverable where intended, and
visible in status. Not applicable races score `N/A`.
**Prove by:** Enter and exit the relevant curse state and confirm suppression,
scar, and recovery behave per the race row.
**Verifier tie-in:** Phase 15 curse overlay; runtime.

---

## Definition of done (per race)

> The race feels like a distinct religion in ordinary play: a player who picks
> this race can find and engage its signature lane, understands why the gods
> respond, is rewarded in a way that is worth noticing but never a chore,
> cannot farm it, sees their state in plain language, feels neglect as
> something thematic, and meets all of it through the world rather than a debug
> menu - all P0 = Pass, all P1 >= Acceptable.

---

## Scaling spine (recommended order)

Per the 2026-05-31 audit closeout, scale in an order that builds a reference
frame, not alphabetically:

1. **Altmer** - first, because its crisis/Lorkhan/favor packet is furthest
   wired and its main risk (punitive pacing) is exactly what this rubric's
   P0-2/P0-4/P1-9 catch.
2. **Nord** - as the **control / reference race** for "a fully felt race." Nord
   is the deepest pilot; scoring it first gives every other race a Pass-bar to
   compare reward magnitude (P0-2) and density (P1-9) against.
3. **First contrast race** - Khajiit or Argonian, to prove the rubric holds for
   a substrate race that feels deliberately different from Nord.
4. Remaining P1 races (Orc, Redguard, Bosmer non-hunter), then the P2
   stack/ceiling races (Breton, Dunmer, Imperial) whose risk is over-stacking
   rather than thinness - for those, P0-5 (anti-farm) and P1-9 (density) are the
   load-bearing dimensions.

Score Nord and Altmer first so the rest of the roster is graded against a real
reference rather than in the abstract.

---

## Relationship to the beta gates

- A race passing this rubric clears its share of the **Content-Feel Beta** gate
  (Section 25.6): credible foreground path, distinct feel, testable obligations,
  live commitment/neglect/decay/curse/UI, quiet recoverable loop.
- **Technical Beta** (Section 25.5) does **not** require this rubric - it
  requires system stability and readable surfaces, which the engine already
  has. This rubric is specifically the Content-Feel bar.
- External beta should not be opened for a race until it is Beta-Ready here,
  per the runbook's "do not ask testers to judge absence as experience."

---

## Per-race scorecards

Fill in as races are scaled. Template:

```
### <Race> - scaled <date>
| Dim | Score | Evidence |
|---|---|---|
| P0-1 Foreground path |  |  |
| P0-2 Reward wealth/tuning |  |  |
| P0-3 Immersion proof |  |  |
| P0-4 Rejected-hook coverage |  |  |
| P0-5 Anti-farm |  |  |
| P1-6 Status/Survey legibility |  |  |
| P1-7 Neglect/recovery texture |  |  |
| P1-8 World placement |  |  |
| P1-9 Firing density |  |  |
| P1-10 Curse-state interaction |  |  |
Result: Not Ready / Beta-Ready
```

(No race scored yet - all ten are QASmoke route-proven but pre-scaling.)
