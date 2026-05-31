# PDV Pre-Beta Race Acceptance Rubric

**Created:** 2026-05-31
**Status:** Required internal validation rubric before external race playfeel testing
**Owner:** Companion to `PDV_PreBetaRaceScalingSpine.md`, `PDV_RaceRewardBudgetLedger.md`, `PDV_RaceImplementationCostingBacklog.md`, and `PDV_Phase20_NoInGameProof_Gates.json`

## Purpose

This rubric defines what "pre-beta gameplay scaling complete" means for one
race. QASmoke route proof only proves that a marker reaches the intended
EventBus and manager path. It does not prove that ordinary play is paced,
legible, non-farmable, or culturally specific.

Use this rubric before increasing reward magnitude, asking external testers to
judge race feel, or calling a race ready for Content-Feel Beta.

## Required Verdicts

Each race packet must end with one verdict.

| Verdict | Meaning | Allowed Next Step |
|---|---|---|
| `Pass` | The race has enough normal-play evidence, rejected-hook protection, status clarity, stack safety, and reward floor to be judged by external testers. | External playfeel testing or stronger reward tuning may begin. |
| `Conditional` | The race is close, but one named criterion is thin and has a low-risk follow-up. | Fix the named condition before external testing. |
| `Fail` | The race still reads as missing systems, generic activity scoring, hidden counters, reward noise, or overstack. | Continue internal scaling only. |

`Conditional` is not a public beta state. It is a short internal handoff only.

## No-In-Game Statuses

When a session intentionally avoids Skyrim runtime proof, use the structured
status packet in `PDV_Phase20_NoInGameProof_Gates.json`. These statuses are not
acceptance verdicts.

| Status | Meaning | Allowed Next Step |
|---|---|---|
| `Planning-Ready` | The race has a complete paper contract, but source/readback or runtime evidence is still thin. | Continue manifest, copy, verifier, or hook-contract work. |
| `Readback-Ready` | Source, manifests, and record/readback gates are coherent enough for manual/runtime proof later. | Prepare final placement contracts or runtime/manual check packets. |
| `CK-Ready` | The next step is manual CK/xEdit authoring with a named record contract. | Author manually, then run readback. |
| `Runtime-Deferred` | No further paper proof can replace the missing in-game/manual evidence. | Wait for manual/runtime proof. |

The no-game packet must keep the race verdict at
`Fail - runtime/manual proof deferred`. Do not convert no-game readiness into
`Pass` or `Conditional`.

## Minimum Evidence Set

Every race must provide these artifacts before a `Pass` verdict.

```text
Race:
Lane type:
Expected build tested:
Edge build tested:
Normal-session route:
Accepted hooks proven:
Rejected hooks proven:
Anti-farm result:
Survey/status result:
Final placement result:
Reward floor result:
Reward ceiling result:
Stack snapshot:
Manual feel note:
Verifier commands:
Runtime commands:
Verdict:
Blocking follow-up:
No-in-game status:
Next automatable action:
Deferred manual proof:
```

## Acceptance Criteria

### 1. Normal-Session Route

The packet must define one short normal-session route that does not rely on
QASmoke, debug menus, or contrived marker spam.

Pass requires:

- At least one ordinary-session positive loop is proven or ready for runtime
  proof: travel/rest/community/ritual/study/duty/craft/service/quest context,
  whichever fits the race.
- The loop includes a starting state, qualifying act, expected state change,
  player-facing readout, and cooldown or cadence rule.
- The loop is something a target player might actually do in a roleplay run.

Fail examples:

- Only QASmoke markers prove the route.
- The route is a single repeated activation.
- The act could belong to any race without explanation.

### 2. Rejected-Hook Coverage

Each race must prove that ordinary generic behavior stays silent where it
should. The goal is not to reject all generic behavior everywhere; it is to
prove the race does not become a passive faucet.

Minimum set:

- Test at least six rejected-hook families for P0/P1 buildout lanes.
- Test at least four rejected-hook families for P2 audit-only lanes.
- Include every family named in the race packet's `Rejected generic hooks`.

Common families:

- Travel or fast travel.
- Sleep or repeated same-bed rest.
- Combat or generic kill count.
- Theft or generic crime.
- Crafting or raw skill gain.
- Faction membership without qualifying conduct.
- Shrine attendance without the authored ritual.
- Repeat activation or same-location spam.

Pass requires:

- Rejected behavior produces no piety, focus movement, substrate movement,
  favor, privilege, or state transition beyond explicitly allowed flavor.
- If a generic behavior is admitted, its reason, cap, and mode are documented.

### 3. Anti-Farm Cadence

Every accepted hook must name its anti-farm rule.

Pass requires at least one of:

- Same-day throttle.
- Once-per-day or once-per-window cap.
- Distinct location, anchor, target, or quest-context requirement.
- Quality/value/context filter.
- Major-event cooldown.
- One-active-favor family cap.

Fail examples:

- Raw count loops.
- Same-object repeat loops.
- Fast travel or sleep loops that advance indefinitely.
- Generic combat or crafting becoming the best route.

### 4. Survey And Status Legibility

Survey Devotion or the MCM Player page must explain what changed and why in
player-facing terms.

Pass requires:

- The readout names the race-specific state in fiction-facing language.
- The readout explains the current pressure or favor without route IDs,
  internal counters, or debug labels.
- A player can answer: "What changed?", "Why did it change?", and "What should
  I try next?"
- Curse, scar, Daedric, or stigma pressure appears when relevant and does not
  silently replace native identity.

Fail examples:

- The readout is only numeric.
- The readout says a state changed but not why.
- The readout implies multiple exclusive paths are active at once.

### 5. Final Placement

Final placement is separate from QASmoke. A race cannot pass by proving only
debug-room activators.

Pass requires:

- At least one positive proof surface has a plausible normal-world placement
  plan or live placement.
- At least one pressure, rejection, recovery, or status surface has a plausible
  normal-world placement plan or live placement where relevant.
- Placement notes explain why the location, actor, object, or quest context is
  culturally meaningful.

Manual CK work can remain pending if the exact object is CK-owned, but the
placement contract must be precise enough for implementation.

### 6. Reward Floor

The race must have a satisfying early or ordinary-session experience even
before rare Champion moments.

Pass requires:

- One non-edge build has a visible maintenance, recognition, recovery, or
  favor loop.
- The loop is not combat-only unless the race intentionally centers combat and
  still has a non-combat status or recognition surface.
- The reward can be modest, but it must feel authored.

Fail examples:

- The race is mechanically quiet until Champion.
- The only visible loop is a debug or QASmoke route.
- The only strong route is a curse, Daedric deviation, or faction outlier.

### 7. Reward Ceiling And Stack Snapshot

The packet must prove the race does not overstack into the best generic build.

Pass requires a stack snapshot containing:

- Active passive boons.
- Active contextual favors.
- Active privilege or recognition surfaces.
- Substrate/state layers.
- Prices, stigma, neglect, rupture, scar, or recovery effects.
- Curse or Daedric modifiers.
- Mode/path/focus/sect/tradition state.

The snapshot must name what is allowed to stack and what is capped, softened,
suppressed, or converted into interpretation.

Default ceiling:

- No race should feel like it has more than two loud always-on boon families.
- Persistent substrates should mostly carry identity, maintenance, recovery,
  or interpretation.
- One active contextual favor family is the normal loud temporary reward.
- Broad lanes must stay softer than focused patron/path rewards.

### 8. Expected And Edge Builds

Every race must be checked against one expected build and one edge build.

Examples:

- Altmer expected: Auri-El scholar/mage. Edge: Exiled vampire or Talos/Lorkhan
  pressure run.
- Khajiit expected: road-home Khenarthi/Azurah traveler. Edge: Rajhin thief or
  Alkosh dragon/order run.
- Argonian expected: Hist/People community survivor. Edge: Sithis-threshold
  assassin or vampire rupture run.
- Nord expected: broad Old Ways into Kyne/Talos. Edge: Hircine/werewolf stack.
- Breton expected: one chosen tradition. Edge: Hidden Art plus Daedric rupture.

Pass requires:

- The expected build has a satisfying reward floor.
- The edge build does not erase native race identity.
- Survey/status remains legible in both.

### 9. Manual Feel Note

Manual feel is accepted only after verifier/readback checks are clean.

The note must answer:

- Did the race feel authored rather than generic?
- Was the strongest loop too quiet, too noisy, too strong, or too chore-like?
- Did rejected hooks stay silent enough to trust the system?
- Did the status surface explain the state without debug knowledge?
- Did the reward floor give enough texture before rare payoffs?

## External Tester Gate

Do not ask external testers to judge race playfeel until the race has:

1. `Pass` on this rubric or a named `Conditional` with the fix already scoped.
2. Clean source/readback/verifier result for the relevant slice.
3. Runtime route proof for any route claimed live.
4. Final placement plan separate from QASmoke.
5. Survey/status readout that explains the current state.
6. At least one expected build and one edge build recorded.

## Current First Use

Apply this rubric first to Altmer. Nord remains the control/reference for what
a fully felt race can look like, but Nord is P2 audit-only for ceiling and
over-trigger checks, not a buildout target.

After Altmer, apply the same rubric to Khajiit as the first contrast and
Argonian as the second contrast before promoting Orc, Redguard, or Bosmer P1
packets.
