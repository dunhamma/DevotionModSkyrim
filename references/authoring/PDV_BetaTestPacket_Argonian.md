# PDV Beta Test Packet - Argonian

Created: 2026-06-06
Status: ready to run - Hist book packet; People/Void edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Argonian beta-feel proof from the approved Hist book source
family. It does not prove People/community, bed-of-choice, Void/Sithis, or curse
edge behavior by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 7
set PDV_GLO_DebugLevel to 2
```

Origin index `7` is Argonian.

## Expected Build - Hist Memory

Add the approved Argonian Account books:

```text
player.additem 0001AFD7 1
player.additem 0001ACE7 1
player.additem 0001AFFC 1
player.additem 0001ACE8 1
```

Read each book normally from inventory:

- `0001AFD7` - `Book0ArgonianAccountBook1`.
- `0001ACE7` - `Book3ValuableArgonianAccountBook2`.
- `0001AFFC` - `Book0ArgonianAccountBook3`.
- `0001ACE8` - `Book3ValuableArgonianAccountBook4`.

Expected in game:

- Top-left notifications only, unless a separately proven toast surface is in
  focus.
- No forced full Prisma panel.
- Survey Devotion explains Hist memory, People floor, Void posture, and
  bed-of-choice state without route IDs or raw debug values.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race argonian --strict-manager
```

Expected log marker:

```text
RouteArgonianHistMaintenanceSource complete: po3_book_argonian_hist
```

## Edge Build - Void Or Curse Pressure

Current live status: pending. Do not use generic murder, one Dark Brotherhood
join, swimming loops, or same-bed sleep loops as proof. Void/Sithis and
People/community need exact approved sources before full pass evidence.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 6
player.additem 0001AFD7 1
```

Expected: no Argonian manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 7
```

Try generic swimming, same-bed sleep, stealth, murder, alchemy, or swamp travel.
Expected: no Hist, People, Void, or bed-of-choice movement.

## Evidence To Bring Back

```text
Argonian expected build: PASS/FAIL
Argonian Void/curse edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

