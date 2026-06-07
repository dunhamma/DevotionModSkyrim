# PDV Beta Test Packet - Nord

Created: 2026-06-06
Status: ready to run - Old Ways and Hircine/Arkay book packet; dense-hook edge audit pending
Mode: console-assisted beta-feel packet

This packet starts Nord beta-feel proof from the approved Old Ways and
Hircine/Arkay book source families. It does not prove Kyne/Talos context,
werewolf stack behavior, dense generic hook rejection, or broad/focused reward
cap by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 0
set PDV_GLO_DebugLevel to 2
```

Origin index `0` is Nord.

## Expected Build - Old Ways

Add the approved Nord Old Ways books:

```text
player.additem 000ED161 1
player.additem 000ED02F 1
player.additem 000E2FC6 1
```

Read each book normally from inventory:

- `000ED161` - `Book1CheapNordsArise`.
- `000ED02F` - `Book2CommonDreamOfSovngarde`.
- `000E2FC6` - `Book3ValuableSovngardeReexamination`.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains broad/focused Old Ways, Kyne/Talos context, and
  current patron state without turning every Nord hook into a reward faucet.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race nord --strict-manager
```

Expected log marker:

```text
RouteNordOldWaysState complete:
```

## Edge Build - Hircine/Arkay

Add the approved Hircine/Arkay edge book:

```text
player.additem 000F683F 1
```

Read normally from inventory:

- `000F683F` - `CR12TotemsOfHircine`.

Expected log marker:

```text
RouteNordHircineArkayEdge complete:
```

Current live status: dense-hook and werewolf stack audit remains pending even
if the book route passes.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 1
player.additem 000ED161 1
```

Expected: no Nord manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 0
```

Try generic kills, travel, tomb clears, sleep, crafting, anti-Thalmor violence,
or shrine repeats. Expected: no dense-hook over-trigger.

## Evidence To Bring Back

```text
Nord expected build: PASS/FAIL
Nord Hircine/Arkay edge: PASS/PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

