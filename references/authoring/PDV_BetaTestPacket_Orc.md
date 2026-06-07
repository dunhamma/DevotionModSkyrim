# PDV Beta Test Packet - Orc

Created: 2026-06-06
Status: ready to run - Malacath book packet; life-mode edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Orc beta-feel proof from the approved Malacath book source
family. It does not prove Stronghold forge, City dignity, Legion/Exile service,
or curse-code pressure by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 8
set PDV_GLO_DebugLevel to 2
```

Origin index `8` is Orc.

## Expected Build - Malacath Code

Add the approved Orc books:

```text
player.additem 0007EBC9 1
player.additem 0001AD16 1
```

Read each book normally from inventory:

- `0007EBC9` - `Book1CheapTheCodeofMalacath`.
- `0001AD16` - `Book4RareTrueNatureofOrcs`.

Expected in game:

- Top-left notifications only, unless a separately proven toast surface is in
  focus.
- No forced full Prisma panel.
- Survey Devotion explains Malacath, life mode, dignity/service posture, and
  last accepted proof in race language.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race orc --strict-manager
```

Expected log marker:

```text
RouteOrcMalacathConduct complete: mode 0 source po3_book_orc_malacath
```

## Edge Build - Life-Mode Pressure

Current live status: pending. Stronghold quality forge, City/self-made dignity,
Legion/Exile service, Blood-Kin, werewolf, and vampire-cured pressure need exact
approved sources before full pass evidence.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 7
player.additem 0007EBC9 1
```

Expected: no Orc manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 8
```

Try raw crafting, generic combat, mining, brawls, vendor sales, faction joining,
or random stronghold proximity. Expected: no Orc state movement.

## Evidence To Bring Back

```text
Orc expected build: PASS/FAIL
Orc life-mode edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

