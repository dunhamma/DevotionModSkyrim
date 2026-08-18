# PDV 2.0 GATE 0.5 runtime tier — FAVOR + LEDGER co-run checklist

STATUS: LIVING (authored 2026-08-18). Both host quests are wired on the SAME `Devotion.esp`
and both are StartGameEnabled + in the regenerated SEQ, so ONE new game exercises both. Run
the two runbooks together in a single session; this checklist is the merged order.

Full detail per module: `PDV_2_0_FAVOR_RuntimeSmoke_Runbook.md`,
`PDV_2_0_LEDGER_RuntimeSmoke_Runbook.md`. This is the ordering, not a replacement.

## Preconditions (both modules)
- MO2 Anvil, profile 'Devotion Dev'; `Devotion-V3Dev` ENABLED, 1.5 `Devotion` DISABLED.
- Host quests wired: `PDV_ContextualFavorRuntime` `0x04071791`, `PDV_DevotionLedger`
  `0x04071792`; SEQ (`Devotion-V3Dev/SEQ/Devotion.seq`) lists both (44 SGE quests).
- **NEW GAME required** (new SGE quests never started on an old save).
- One **fresh Altmer** covers both: its favor lane is eligible from origin (FAVOR needs no
  patron) AND it can commit to a Divine patron (LEDGER). Any race works if you re-pick a
  FAVOR lane eligible for it.

## Merged order (fewest resets; dawn LAST because it advances time)
1. **Setup once** — new game -> free movement -> `set PDV_GLO_DebugLevel to 3` -> open MCM.
   Confirm both host quests run: `sqv PDV_ContextualFavorRuntime`, `sqv PDV_DevotionLedger`.
2. **FAVOR liveness** — Player tab "Favor" line renders (non-blank).
3. **FAVOR round-trip** — Debug "Contextual favor": Cycle lane -> Cycle family ->
   Trigger (toast + spell + line change) -> Clear (spell gone) -> (optional) cooldown re-trigger.
4. **LEDGER liveness** — Player tab "Patron"/"Standing" render; Debug "Active piety" shows a number.
5. **LEDGER direct write** — Debug "Apply target piety" -> Active piety + `PDV_GLO_Active*`
   globals move (`getglobalvalue PDV_GLO_ActivePiety`).
6. **LEDGER accrual** — commit to a patron -> do ONE liked deed -> Active piety rises
   (the `Manager.LedgerRuntime.AwardPietyFromLikesDislikes` round-trip).
7. **LEDGER dawn (LAST)** — sleep past 06:00 -> scratch consolidates into committed piety + tier.

## Shared failure tell
One Papyrus log (`.../Logs/Script/Papyrus.0.log`). A None-ref fault names either
`FavorRuntime` or `LedgerRuntime` -> tells you exactly which module's wiring is inert
without ambiguity. A clean run with both round-trips = GATE 0.5 runtime tier green for
FAVOR and LEDGER together.

## Cleanup
`set PDV_GLO_DebugLevel to 0`. Flip the MO2 toggle back when you want the 1.5 line active.
