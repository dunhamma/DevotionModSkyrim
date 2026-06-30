# PDV In-Game Run-Sheet -- Altmer Regression

Status: compact final-regression sheet. Created 2026-06-27.
Companion: `PDV_BetaTestPacket_Altmer.md`.

Altmer already has current beta-feel evidence. Run this only as a final regression check after late changes.

## Preflight

```text
set PDV_GLO_OriginRace to 3
set PDV_GLO_DebugLevel to 2
```

Disable `Devotion - Living Deities Test`. Use a disposable save.

## Regression Steps

1. Accepted book route:

```text
player.additem 0001AF94 1
player.additem 0001ACFE 1
player.additem 0001AD09 1
```

Read the books. Expected markers:

```text
RouteAltmerAurielFoundation complete: po3_book_altmer_auriel
RouteAltmerMagnusScholarship complete: po3_book_altmer_magnus
RouteAltmerXarxesLineage complete: po3_book_altmer_xarxes
```

2. Edge route, if the save has not consumed it:

```text
setstage MQ104 160
```

Expected markers:

```text
RouteAltmerLorkhanPressure complete: 50 tier 2
RouteAltmerLorkhanPenalty complete: po3_queststage_altmer_mq104
RouteAltmerCrisisSource complete: 51 source 1
```

3. Wrong-origin:

```text
set PDV_GLO_OriginRace to 0
player.additem 0001AD06 1
```

Read `0001AD06`. Expected: no Altmer state movement. Reset to origin 3.

4. UI and stack:
   - Survey names Auri-El foundation, standing, and recent source.
   - Active Effects still show the expected visible Altmer layer when legitimately eligible; prior accepted snapshot was `Altmer: Dawn Steadiness`.
   - Prisma/top-left surfaces as toast/fallback only; no forced full panel.
   - Devotion panel opens manually, Ledger shows the book driver row, ESC closes.

5. Shared Daedric inn-sleep proof:
   - This is cross-race backend smoke, not Altmer-native proof. It may be recorded once per build and referenced from the other race sheets.
   - MCM Debug -> `Debug: Daedric & Curse`; use `Selected Prince` to choose Sanguine or Namira. Select `Reset Prince path`, then `Force Seeker`.
   - Sleep in a non-inn bed. Expected: no `PrinceV2: <Prince> event 314 deepen -0.25`, and `Show Prince summary` does not drop from sleep.
   - Sleep in an inn. Expected: `PrinceV2: <Prince> event 315 deepen -0.25`, and the summary piety drops by the inn-sleep dislike.
   - Positive control: choose Vaermina, Peryite, or Azura, `Reset Prince path`, `Force Seeker`, then sleep in a non-inn bed. Expected: `event 314` still gives the positive sleep credit.
   - Record the Papyrus `PrinceV2` lines and before/after `Show Prince summary` piety.

6. Save/load:
   - Save after the accepted route.
   - Reload.
   - Survey and Active Effects remain consistent.

## Checker

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race altmer --strict-manager
```

| Check | Status | Note |
|---|---|---|
| Book route | | |
| MQ104 edge or prior proof accepted | | |
| Wrong-origin silence | | |
| Survey/Active Effects | | |
| Shared Daedric inn-sleep proof | | |
| Prisma toast/panel/Ledger | | |
| Save/load | | |
