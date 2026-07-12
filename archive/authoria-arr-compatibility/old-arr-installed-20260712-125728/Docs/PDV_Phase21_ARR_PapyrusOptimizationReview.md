# PDV Phase 21 ARR - Papyrus Optimization Review

Status: review complete; no broken contract found; release-hardening follow-ups
open. Date: 2026-06-14.

This review was run after the ARR local package/readback pass. It is a Papyrus
cost review, not runtime proof.

## Verdict

No reviewed script has a broken event contract or obvious leak introduced by the
ARR package path. The current ARR shrine slice remains event-driven: the
Dragonborn Good Daedra route uses `PDV_DunmerShrinePrayerEffect.OnEffectStart`
and a single EventBus dispatch, not polling.

## Clean For This Slice

- `PDV_DunmerShrinePrayerEffect.psc`: one-shot `OnEffectStart`, single route
  call, no polling.
- `PDV_EventBus.psc`: route layer stays thin for the shrine path.
- `PDV_EventSignalActivator.psc` and `PDV_EventSignalEffect.psc`: gated route
  surfaces, no new ARR-specific cost.
- `PDV_T3DailyLowHealthSaveEffect.psc`: bounded single-update pattern.
- `PDV_MCM.psc`, `PDV_DeityBase.psc`, and `PDV_CurseState.psc`: no ARR-blocking
  issue found in this review.

## Release-Hardening Follow-Ups

These are pre-existing suboptimal cost patterns. They should be addressed before
a ready/public support claim, but they do not invalidate the local ARR shrine
readback package.

| Script | Trigger | Classification | Required follow-up |
|---|---|---|---|
| `PDV__ManagerQuest.psc` lines 618-686 | perpetual quest `OnUpdate` every 1 second | suboptimal | Re-arm only when timed work is pending; move slow maintenance to a slower cadence. |
| `PDV__ManagerQuest.psc` lines 2353-2375, 2421-2428, 2777-2797, 2843-2855 | sleep/rite interaction events | suboptimal | Replace `Utility.Wait(0.5)` menu delays with a one-shot deferred menu or remove the delay if no engine timing proof requires it. |
| `PDV_PlayerEvents.psc` lines 1096-1210 | book/object/magic-effect faucet callbacks | suboptimal | Cache parsed/resolved quest-reaction source sets instead of re-reading JSON and resolving forms on each event. |
| `PDV_DaedricPathBase.psc` lines 339-354, 108-111, 431-440 | every Daedric piety write | suboptimal | Strip/sync pact spells only on actual active-pact transitions; cache player reference inside clear/sync helpers if retained. |

## Acceptance Boundary

The ARR local package can be handed off as `patch-packaging` evidence, with
runtime/manual smoke pending. It must not be promoted to ready release or public
support until the release-hardening follow-ups are triaged or explicitly waived
and the ARR runtime smoke passes.
