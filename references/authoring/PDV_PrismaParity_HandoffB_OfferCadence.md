# Handoff B (remaining) -- Offer-Cadence Simplification (Codex)

## Context
The formal-offer scale-out STRUCTURE (records, race dispatch, eligibility refactor, `DispatchDiegeticCue`,
quiet-emergence `onset` wiring) is already landed + committed; `pdv_formal_offer_check` PASS. This is the
one remaining offer-system change from the cadence ruling, made after the original handoff. It is a
self-contained, no-stop manager pass. Owner ruling:

- **One offer per qualification.** A deity offers ONCE when it first crosses the threshold; no timer re-offer.
- **Refuse is terminal per-deity** -- that god never offers again, even after a deep lapse-and-rebuild.
- **Re-offer only on genuine re-qualification** -- piety falls below the threshold and climbs back.

This is what makes the locked refuse copy ("{patron} will not ask again", wired later in Unit D) true. The
change DELETES the escalating-cooldown / `DeclineCount` machinery -- net simpler.

## Current state (verified live, line numbers current)
`live-source/Scripts/Source/PDV__ManagerQuest.psc`:
- `IsEligibleForFormalCommitmentOffer` (12683) gates on `IsCommitmentOfferOnCooldown(deity)` (12692).
- `ShowFormalCommitmentOffer` (12499) shows the offer, then branches 0/1/2 to Accept/Decline/Refuse.
- `DebugDeclinePendingCommitment` (12824) calls `ApplyCommitmentDeclineCooldown` (12898).
- `DebugRefusePendingCommitment` (12835) calls `ApplyCommitmentRefuseCooldown` (12914) + sets the GLOBAL
  `PDV.Commitment.Rupture` (12842) -- which nothing in eligibility reads, so refuse is NOT terminal today.
- Cooldown machinery: `IsCommitmentOfferOnCooldown` (12869), `GetCommitmentOfferCooldownUntil` (12873),
  `GetCommitmentOfferCooldownRemaining` (12881), `GetCommitmentDeclineCount` (12890),
  `ApplyCommitmentDeclineCooldown` (12898), `ApplyCommitmentRefuseCooldown` (12914),
  `ClearCommitmentOfferCooldown` (12923). Keys: `PDV.Commitment.OfferCooldownUntil`, `PDV.Commitment.DeclineCount`.

## The work
New per-deity StorageUtil keys (keyed on `deity as Form`): `PDV.Commitment.Offered` (Int 0/1),
`PDV.Commitment.Refused` (Int 0/1). Add two helpers:
```
Bool Function IsCommitmentOffered(PDV_DeityBase deity)
    if !deity
        return False
    endIf
    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Offered") == 1
EndFunction

Bool Function IsCommitmentRefused(PDV_DeityBase deity)
    if !deity
        return False
    endIf
    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Refused") == 1
EndFunction
```

1. **Set the one-shot guard at show time.** In `ShowFormalCommitmentOffer` (12499), right before
   `offerMessage.Show()`, set `StorageUtil.SetIntValue(deity as Form, "PDV.Commitment.Offered", 1)`. (Set
   once when presented, so it holds regardless of Accept/Not-yet/Refuse.)
2. **Eligibility reads the guards, not the cooldown.** In `IsEligibleForFormalCommitmentOffer` (12683),
   REPLACE the `IsCommitmentOfferOnCooldown` block (12692-12694) with:
   ```
   if IsCommitmentRefused(deity)
       return False
   endIf
   if IsCommitmentOffered(deity)
       return False
   endIf
   ```
3. **Decline = no cooldown.** In `DebugDeclinePendingCommitment` (12824), DROP the
   `ApplyCommitmentDeclineCooldown(pendingDeity)` call (the offered guard already prevents re-offer); keep `ClearPendingCommitment()`.
4. **Refuse = per-deity terminal.** In `DebugRefusePendingCommitment` (12835), REPLACE
   `ApplyCommitmentRefuseCooldown(pendingDeity)` with
   `StorageUtil.SetIntValue(pendingDeity as Form, "PDV.Commitment.Refused", 1)`. Keep the global
   `PDV.Commitment.Rupture` set (the debug/UI transient state reads it) and `ClearPendingCommitment()`.
5. **Re-qualification clears the offered guard.** In `RunDawnProcessCommitmentOffers` (8864), before
   evaluating, iterate the offer-eligible deities and, for any with `GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD`,
   clear `PDV.Commitment.Offered` (set 0). Leave `Refused` set (permanent). This makes lapse+rebuild re-offer.
6. **Delete the cooldown machinery** -- `IsCommitmentOfferOnCooldown`, `GetCommitmentOfferCooldownUntil`,
   `GetCommitmentOfferCooldownRemaining`, `GetCommitmentDeclineCount`, `ApplyCommitmentDeclineCooldown`,
   `ApplyCommitmentRefuseCooldown`, `ClearCommitmentOfferCooldown`, and the `OfferCooldownUntil` / `DeclineCount`
   keys. **Update callers first:** `DebugAcceptPendingCommitment` (calls `ClearCommitmentOfferCooldown`) and
   `DebugResetCommitmentStateByIndex` (resets `OfferCooldownUntil` + `DeclineCount`) should instead clear the
   per-deity `Offered` + `Refused` keys; remove/repoint any MCM or debug readout of cooldown-remaining.

## Behavioral note (flag to owner)
A player who picks "Not yet" while staying ABOVE the threshold will not be re-offered unless they lapse and
rebuild -- that is the intended "re-offer only on re-qualification" rule, but if the formal offer is the only
commit path, a still-qualified "Not yet" player is locked out until a lapse. Confirm that's acceptable in playtest.

## Acceptance
No dedicated gate (the formal-offer gate checks structure, not cadence). Sync live-source -> MO2, then:
`pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> `pdv_formal_offer_check` still PASS -> `pdv_integrity_harness` PASS.
In-game (owner): offer fires once at threshold; "Not yet" + stay-qualified = no re-offer; lapse below + rebuild
= re-offer; refuse = never again for that god. The locked "will not ask again" copy is wired separately (Unit D).
