# PDV Beta Test Packet - Dunmer

Created: 2026-06-06
Status: ready to run - Azura and Boethiah book packet; deviation-price edge pending
Mode: console-assisted beta-feel packet

This packet starts Dunmer beta-feel proof from the approved Reclamation book
source families. It does not prove portable ash-prayer, home rite,
deviation-price, curse pressure, or generic Daedric rejection by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 5
set PDV_GLO_DebugLevel to 2
```

Origin index `5` is Dunmer.

## Expected Build - Reclamation Focus

Add the approved Azura and Boethiah books:

```text
player.additem 0001B245 1
player.additem 0001ACE9 1
player.additem 0001B233 1
player.additem 00032E72 1
```

Read each book normally from inventory:

- `0001B245` - `Book4RareInvocationofAzura`.
- `0001ACE9` - `Book3ValuableAzuraandtheBox`.
- `0001B233` - `Book4RareBoethiahsGlory`.
- `00032E72` - `DA02BookBoethiahsProving`.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains ancestor layer, active Reclamation focus, private
  posture, and deviation/curse price state without generic Daedric scoring.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer --strict-manager
```

Expected log markers:

```text
RouteDunmerReclamationFocus complete: 130 focus 0
RouteDunmerReclamationFocus complete: 130 focus 1
```

## Edge Build - Deviation Price

Current live status: pending. DA01/DA02 quest-stage and sacrifice outcomes are
blocked until exact-stage metadata is approved. Do not count generic crime,
cruelty, twilight, magic, shrine visits, or Daedric contact as proof.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 4
player.additem 0001B245 1
```

Expected: no Dunmer manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 5
```

Try generic Daedric contact, theft, murder, ash proximity, shrine visits, or tomb
travel. Expected: no native Dunmer layer movement unless the exact source owns
the route.

## Evidence To Bring Back

```text
Dunmer expected build: PASS/FAIL
Dunmer deviation edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

