# PDV In-Game Run-Sheet -- Argonian Regression

Status: compact final-regression sheet. Created 2026-06-27.
Companion: `PDV_BetaTestPacket_Argonian.md`.

Argonian has current beta-feel evidence. Run this as a fast regression pass for Hist source routing, near-water/readable stack behavior, Void/People surfaces, and Prisma.

## Preflight

```text
set PDV_GLO_OriginRace to 7
set PDV_GLO_DebugLevel to 2
```

Disable `Devotion - Living Deities Test`. Use a disposable save.

## Regression Steps

1. Hist accepted books:

```text
player.additem 0001AFD7 1
player.additem 0001ACE7 1
player.additem 0001AFFC 1
player.additem 0001ACE8 1
```

Read the books. Expected marker:

```text
RouteArgonianHistMaintenanceSource complete: po3_book_argonian_hist
```

2. Hist Sap and near-water feel:

```text
player.additem 000AED90 1
```

Drink the sap, then compare dry area vs near-water state. If using the current Hist potion artifact, verify the intended top-left/Prisma feedback and Active Effects. Under Requiem, the HP bar/regen feel is the manual proof.

3. Wrong-origin:

```text
set PDV_GLO_OriginRace to 6
player.additem 0001AFD7 1
```

Read the book. Expected: no Argonian state movement. Reset to origin 7.

4. Generic silence:
   - Swim loops.
   - Same-bed sleep loops.
   - Generic murder or stealth.
   - Generic alchemy.
   - Random swamp travel.

Expected: no new Hist/People/Void state unless the source is explicitly curated.

5. UI and stack:
   - Survey names Hist, People, Void, posture, bed-of-choice, and recent event.
   - Active Effects stack is legible; note if composite values still feel heavy.
   - Prisma/top-left surfaces as toast/fallback only; no forced full panel.
   - Devotion panel opens manually, Ledger shows Hist source row, ESC closes.

6. Shared Daedric inn-sleep proof:
   - This is cross-race backend smoke, not Argonian-native proof. It may be recorded once per build and referenced from the other race sheets.
   - MCM Debug -> `Debug: Daedric & Curse`; use `Selected Prince` to choose Sanguine or Namira. Select `Reset Prince path`, then `Force Seeker`.
   - Sleep in a non-inn bed. Expected: no `PrinceV2: <Prince> event 314 deepen -0.25`, and `Show Prince summary` does not drop from sleep.
   - Sleep in an inn. Expected: `PrinceV2: <Prince> event 315 deepen -0.25`, and the summary piety drops by the inn-sleep dislike.
   - Positive control: choose Vaermina, Peryite, or Azura, `Reset Prince path`, `Force Seeker`, then sleep in a non-inn bed. Expected: `event 314` still gives the positive sleep credit.
   - Record the Papyrus `PrinceV2` lines and before/after `Show Prince summary` piety.

7. Save/load:
   - Save after a Hist route and visible stack.
   - Reload.
   - Survey and Active Effects remain consistent.

## Checker

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race argonian --strict-manager
```

| Check | Status | Note |
|---|---|---|
| Hist book route | | |
| Hist Sap / near-water feel | | |
| Wrong-origin silence | | |
| Generic-source silence | | |
| Survey/Active Effects | | |
| Shared Daedric inn-sleep proof | | |
| Prisma toast/panel/Ledger | | |
| Save/load | | |
