# PDV Beta Test Packet - Imperial

Created: 2026-06-06
Status: ready to run - public Talos book packet; civic service edge pending
Mode: console-assisted beta-feel packet

This packet starts Imperial beta-feel proof from the approved public Talos book
source. It does not prove civic service, public/private ConcordatStanding,
faction rejection, or focused patron civic acts by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 1
set PDV_GLO_DebugLevel to 2
```

Origin index `1` is Imperial.

## Expected Build - Public Talos Pressure

Add the approved Imperial public Talos book:

```text
player.additem 000ED04D 1
```

Read the book normally from inventory:

- `000ED04D` - `Book2ReligiousTalosWorship`.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains civic faith, Talos pressure, Concordat/public state,
  and why faction membership or generic lawfulness did not score.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager
```

Expected log marker:

```text
RouteImperialTalosPressure complete:
```

## Edge Build - Civic Service Or Private Talos

Current live status: pending. Civil War oath rows and public/private Talos
branch semantics are blocked until exact-stage metadata or exact source records
are approved.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 0
player.additem 000ED04D 1
```

Expected: no Imperial manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 1
```

Try faction rank, temple attendance, bounty payment, generic mercy, generic
anti-Thalmor violence, trade, or lawfulness. Expected: no civic or Talos state
movement.

## Evidence To Bring Back

```text
Imperial expected build: PASS/FAIL
Imperial civic/Talos edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

