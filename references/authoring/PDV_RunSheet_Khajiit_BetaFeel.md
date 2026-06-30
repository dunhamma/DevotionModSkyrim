# PDV In-Game Run-Sheet -- Khajiit Regression

Status: compact final-regression sheet. Created 2026-06-27.
Companion: `PDV_Khajiit_BetaFeelPacket.md`.

Khajiit has current beta-feel evidence. This sheet checks the late regression surface: focus emergence, lunar books, Champion presentation, and Prisma.

## Preflight

```text
set PDV_GLO_OriginRace to 6
set PDV_GLO_DebugLevel to 2
```

Disable `Devotion - Living Deities Test`. Use a disposable save.

## Regression Steps

1. Champion presentation:
   - MCM Debug -> `Khajiit focus -> Rajhin` or `Khajiit focus -> Alkosh`.
   - `Selected deity` -> same focus.
   - Target piety `85`.
   - Click `Apply target piety`.
   - Click `Run dawn pass`.
   - Confirm Champion notice appears after dawn, Active Effects shows the matching Champion blessing, and Survey shows the same focus.

2. Lunar book route:
   - Read approved Khajiit lunar books from the existing packet.
   - Expected marker:

```text
RouteKhajiitLunarSubstrate complete: po3_book_khajiit_lunar
```

3. Edge route spot-check:
   - Rajhin: undetected notable pickpocket should log `RouteKhajiitRajhinElegantTheft complete`.
   - Alkosh: learn a word-wall word, then `Run dawn pass`; expected `Khajiit Alkosh word-of-power drip awarded`.
   - Baan Dar: under Champion, the low-health save should fire once/day below 20% Health.

4. Wrong-origin:

```text
set PDV_GLO_OriginRace to 0
```

Repeat one lunar source from a clean save. Expected: no Khajiit focus/substrate movement. Reset to origin 6.

5. Generic silence:
   - Moon-sugar use.
   - Fast travel loop.
   - Generic inn sleep.
   - Generic theft.
   - Generic combat.
   - Ordinary night stealth.
   - Generic dragon spam.

6. UI and stack:
   - Survey names Lunar Lattice, road-home cadence, active focus, standing, and recent event.
   - Pattern summary shows one active focus, not a universal stack.
   - Prisma shift toast appears for focus change where enabled; no forced full panel.
   - Devotion panel opens manually, Chronicle and Ledger are nonblank, ESC closes.

7. Shared Daedric inn-sleep proof:
   - This is cross-race backend smoke, not Khajiit-native proof. It may be recorded once per build and referenced from the other race sheets.
   - MCM Debug -> `Debug: Daedric & Curse`; use `Selected Prince` to choose Sanguine or Namira. Select `Reset Prince path`, then `Force Seeker`.
   - Sleep in a non-inn bed. Expected: no `PrinceV2: <Prince> event 314 deepen -0.25`, and `Show Prince summary` does not drop from sleep.
   - Sleep in an inn. Expected: `PrinceV2: <Prince> event 315 deepen -0.25`, and the summary piety drops by the inn-sleep dislike.
   - Positive control: choose Vaermina, Peryite, or Azura, `Reset Prince path`, `Force Seeker`, then sleep in a non-inn bed. Expected: `event 314` still gives the positive sleep credit.
   - Record the Papyrus `PrinceV2` lines and before/after `Show Prince summary` piety.

8. Save/load:
   - Save after Champion presentation.
   - Reload.
   - Survey and Active Effects remain consistent.

## Checker

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit --strict-manager
```

The older `--race khajiit` QASmoke checker is not the organic/book-route gate.

| Check | Status | Note |
|---|---|---|
| Champion presentation | | |
| Lunar books | | |
| Rajhin/Alkosh/Baan Dar spot-check | | |
| Wrong-origin silence | | |
| Generic-source silence | | |
| Survey/Active Effects | | |
| Shared Daedric inn-sleep proof | | |
| Prisma toast/panel/Ledger | | |
| Save/load | | |
