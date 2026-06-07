# PDV Beta Test Packet - Breton

Created: 2026-06-06
Status: ready to run - Hidden Art book packet; Knight's Road and Green Way pending
Mode: console-assisted beta-feel packet

This packet starts Breton beta-feel proof from the approved Hidden Art book
source family. It does not prove Knight's Road, Green Way, vow integrity,
DruidicStanding, or curse/Daedric rupture by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Origin index `2` is Breton.

## Expected Build - Hidden Art

Add the approved Breton Hidden Art sources:

```text
player.additem 000ED60B 1
player.additem 0007EB03 1
player.additem 000DDFB6 1
```

Read or inspect each source normally:

- `000ED60B` - `Book2CommonHagravens`.
- `0007EB03` - `Book2CommonMadmenoftheReach`.
- `000DDFB6` - `dunPOIWitchNote`.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains active Breton tradition, Hidden Art exposure, vow or
  cover pressure, and why parallel tradition rewards are not all active.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager
```

Expected log markers:

```text
RouteBretonTraditionChoice complete: 120 tradition 1
RouteBretonHiddenArtExposure complete:
```

## Edge Build - Daedric Or Curse Rupture

Current live status: pending. Do not use generic spellcasting, generic artifact
ownership, generic help, College membership, or shrine attendance as proof.
Knight's Road, Green Way, and rupture pressure need exact approved sources.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 1
player.additem 000ED60B 1
```

Expected: no Breton manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 2
```

Try generic spellcasting, artifact carrying, faction joining, ordinary help,
and shrine attendance. Expected: no tradition state movement.

## Evidence To Bring Back

```text
Breton expected build: PASS/FAIL
Breton rupture edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

