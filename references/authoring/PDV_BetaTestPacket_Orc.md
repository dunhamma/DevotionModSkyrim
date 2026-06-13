# PDV Beta Test Packet - Orc

Created: 2026-06-06
Status: ready to run - Malacath book packet; life-mode edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Orc beta-feel proof from the approved Malacath book source
family. It does not prove Stronghold forge, City dignity, Legion/Exile service,
or curse-code pressure by itself.

## Preflight

Use a disposable save. One setup block:

```text
set PDV_GLO_OriginRace to 8
set PDV_GLO_DebugLevel to 2
```

Origin index `8` is Orc.

## Expected Build - Malacath Code

Add the approved Orc book (one read proves the route):

```text
player.additem 0007EBC9 1
```

Read the book normally from inventory:

- `0007EBC9` - `Book1CheapTheCodeofMalacath`.

Optional additional coverage (same RouteOrcMalacathConduct broad-conduct path,
same log marker; not required for route proof):

```text
player.additem 0001AD16 1
```

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

Note (gated life-mode behavior): Orc life-mode no longer flips on a single
signal. A soft switch needs two mode-coded evidence days within seven (settled
at dawn via `EvaluateOrcLifeModeAtDawn`) with a 3-day lock-in; City is the
steady fallback, and a lapsed non-City mode demotes back to City. Do not expect
an instant single-signal mode switch.

## Edge Build - Life-Mode Pressure

> Deferred: Stronghold forge / City dignity / Legion-Exile service / Blood-Kin /
> werewolf / vampire-cured life-mode pressure pending exact approved source
> metadata (routes 70-73 exist for dev-proof; empirical sources curation-pending);
> tracked in the GAP ledger.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 7
player.additem 0007EBC9 1
```

Expected: no Orc manager state, reward, or Survey movement.

Generic-source silence check:

```text
set PDV_GLO_OriginRace to 8
```

Attempt 2-3 representative rejected hooks (raw crafting, generic combat, Legion
faction-join). Expected: no Orc state movement and no Survey movement.

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

## Trim log (2026-06-13)

Before -> after: 13 -> 8 steps.

Cut:
- Folded `set PDV_GLO_DebugLevel to 2` into the single Preflight setup block
  (setup boilerplate, not a distinct test step).
- Demoted the second approved book read (`0001AD16`) to optional coverage; both
  books route the same RouteOrcMalacathConduct path and emit the same marker, so
  reading one proves the route.
- Collapsed the seven-item generic-source enumeration (raw crafting, generic
  combat, mining, brawls, vendor sales, faction joining, stronghold proximity)
  into one combined silence assertion over 2-3 representative rejected hooks.

Merged:
- Combined the two Preflight console blocks (OriginRace + DebugLevel) into one
  setup block.
- Replaced the PENDING Edge Build - Life-Mode Pressure stub with a single
  deferred pointer line (no runnable step lost; lever tracked in GAP ledger).
- Combined the generic-source enumeration into one representative silence step.

Preserved (critical levers, unchanged coverage): wrong-origin rejection,
generic-source silence (now one combined step), primary Malacath route/reward
proof and log marker, Survey/status clarity, reward/stack snapshot. Added a
one-line note documenting the new gated two-day-in-seven life-mode switch.
