# Rivalry expansion (Slice B) -- B0 finding: bigger than VMAD authoring

**Verdict: do NOT wire `RivalDeities[]` on Boethiah/Molag Bal/Malacath as scoped.
It would be inert.** B0 traced the actual rivalry trigger path against live
source and found the plan's premise (rivalry = `RivalDeities[]` VMAD authoring)
is incomplete.

## How rivalry actually fires (live trace)
`ApplyRivalryPenalties` is called from exactly one place: `AwardPietyInternal`,
guarded by `allowRivalry && appliedAmount > 0 && stance == STANCE_HOSTILE`
(`PDV__ManagerQuest.psc`). The only path that reaches it for a HOSTILE deity is:

```
AwardCuratedSignal(deity, signalType, ctx)
  -> deity.ScoreCuratedSignal(signalType)   ; must return nonzero
  -> AwardPiety(deity, delta)
  -> AwardPietyInternal(deity, delta, True)  ; stance HOSTILE -> rivalry
  -> ApplyRivalryPenalties(deity, amount)    ; drains deity.RivalDeities[]
```

**The two other gain paths do NOT trigger rivalry:**
- **Quest-reaction** (`ApplyQuestReactionPiety`) writes piety with
  `StorageUtil.AdjustFloatValue(...)` directly (line 1004) -- it never calls
  `AwardPietyInternal`. So Boethiah's Calling (DA02), House of Horrors (DA10),
  and The Cursed Tribe (DA06) -- all quest-matrix rows -- gain their deity piety
  **without ever invoking rivalry.**
- **Generic faucet** (`EventBus.RouteActionWithAttribution -> ScoreAction`):
  every deity's `ScoreAction` gates on `IsRaceNativeForPlayer()` first and
  returns 0 for a non-native (hence HOSTILE) player, so a hostile deity scores 0
  here and rivalry never fires.

## Why only Talos works today
Talos has a bespoke hostile-defiance pipeline that nothing else has:
`PDV_EventSignalActivator` (shrine activator) / MCM -> `RouteTalosShrineDefiance`
(`PDV_EventBus`) -> `HandleTalosShrineDefiance` (manager) -> `AwardCuratedSignal(
Talos, SIGNAL_SHRINE_DEFIANCE)` -> `PDV_Deity_Talos.ScoreCuratedSignal` returns
3.0/4.0/5.0 -> `AwardPietyInternal` (stance HOSTILE for Altmer) -> drains
`Talos.RivalDeities = [Auri-El]`. This is real content infrastructure, per deity.

## What a real rivalry expansion costs (per pair)
1. A hostile-gain **curated-signal path**: a `ScoreCuratedSignal` implementation
   returning a delta for a defiance signal, AND a signal SOURCE
   (activator / EventBus route / manager handler / quest hook) that calls
   `AwardCuratedSignal(source, signal)` for the hostile race -- the Talos
   infrastructure replicated. (Rerouting the existing quest-matrix detection
   through `AwardCuratedSignal` risks double-counting; needs care.)
2. For **Molag Bal**: a new `PDV_Deity_MolagBal` deity face first (it exists only
   as `PDV_DaedricPath_Molag`; `RivalDeities[]` lives on `PDV_DeityBase`) -- the
   same greenfield as the Hircine deity-face pattern.
3. Then the `RivalDeities[]` VMAD (the only part the original plan covered) +
   in-game balance proof.

That is per-deity Papyrus + CK content, not a half-day VMAD slice -- closer to
forward/engine work than a V1 quick-win.

## Recommendation
- **Defer Slice B.** The lore decision (Boethiah->Auri-El, Molag Bal->Tu'whacca,
  Malacath->HoonDing, Boethiah->Malacath) stays valid and recorded for whenever
  the hostile-gain infrastructure is built; the wiring itself is trivial once a
  source has a curated-signal defiance path.
- The shipped Talos->Auri-El rivalry remains the one proven instance; V1 already
  has it. No inert wiring was added.

## Tools left ready (unused, no inert ESP written)
The `ObjectListProp` helper and override-ESP pattern are documented in the plan
and trivially addable to a future author tool when a real pair is build-ready.
No `Devotion - Rivalry Expansion` mod was created.
