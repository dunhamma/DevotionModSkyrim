# PDV In-Game Run-Sheet -- Bosmer Regression

Status: compact final-regression sheet. Created 2026-06-27.
Companion: `PDV_BetaTestPacket_Bosmer.md`.

Bosmer has current packet evidence. This sheet is a final regression pass that keeps DA05 route proof separate from the generic QASmoke checker.

## Preflight

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

Disable `Devotion - Living Deities Test`. Use a disposable save.

## Regression Steps

### 1. DA05 Route, Accepted Branch

Use a save where DA05 can accept the stage. Seed the Old Contract path and piety through MCM if you need visible threshold movement.

```text
setstage DA05 100
```

Expected markers:

```text
RouteBosmerYffre complete: 0 source po3_queststage_bosmer_da05_kill
RouteBosmerPactPositive complete:
RouteDaedricPrinceSignal complete: 200 index 15
```

Mercy branch, separate clean save:

```text
setstage DA05 105
```

Expected:

```text
RouteBosmerYffre complete: 1 source po3_queststage_bosmer_da05_mercy
```

Do not use `pdv_phase20_runtime_check.mjs --race bosmer` as DA05 proof; that checker covers the eight QASmoke proof activators.

### 2. DA05 Log Backstop

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "RouteBosmerYffre|po3_queststage_bosmer_da05|RouteBosmerPactPositive|RouteDaedricPrinceSignal" -Context 1,1
```

### 3. Wrong-Origin

```text
set PDV_GLO_OriginRace to 6
setstage DA05 100
```

Expected: no new `RouteBosmerYffre` line after the wrong-origin stage. Reset to origin 4.

### 4. Generic Silence

Try generic kindness, trade, theft, forest travel, hunting, plant harvesting, and random bandit kills. Expected: no path movement unless the route is a curated Bosmer source.

### 5. UI and Stack

- Survey names active path, standing, Pact pressure, and recent event.
- Active Effects show only one Bosmer path family at a time.
- Neglect check: drop the path scoring deity to <=10, click `Run dawn pass`, and confirm the corrected StaminaRateMult -5 behavior feels like a light bite rather than a pin.
- Prisma/top-left surfaces as toast/fallback only; no forced full panel.
- Devotion panel opens manually, Ledger shows the accepted source row, ESC closes.

### 6. Save/load

Save after the accepted branch and visible stack. Reload. Survey and Active Effects remain consistent.

## Optional QASmoke Regression

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Expected: eight QASmoke route markers only. This is not the DA05 proof.

| Check | Status | Note |
|---|---|---|
| DA05 stage 100 | | |
| DA05 stage 105 or prior proof accepted | | |
| Wrong-origin silence | | |
| Generic-source silence | | |
| Survey/Active Effects/neglect | | |
| Prisma toast/panel/Ledger | | |
| Save/load | | |

