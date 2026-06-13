# PDV Beta Test Packet - Dunmer

Created: 2026-06-06
Status: ready to run - Azura and Boethiah book packet; deviation-price edge deferred
Mode: console-assisted beta-feel packet

This packet starts Dunmer beta-feel proof from the approved Reclamation book
source families. It does not prove portable ash-prayer, home rite,
deviation-price, curse pressure, or generic Daedric rejection by itself.

## Expected Build - Reclamation Focus

Use a disposable save. Set the origin gate and debug level, then add one
approved Azura book and one approved Boethiah book:

```text
set PDV_GLO_OriginRace to 5
set PDV_GLO_DebugLevel to 2
player.additem 0001B245 1
player.additem 0001B233 1
```

Origin index `5` is Dunmer.

Read each book normally from inventory:

- `0001B245` - `Book4RareInvocationofAzura` (Azura patron).
- `0001B233` - `Book4RareBoethiahsGlory` (Boethiah patron).

(Other approved sources `0001ACE9` Book3ValuableAzuraandtheBox and `00032E72`
DA02BookBoethiahsProving route the same handler and remain valid one-time
identity signals for a fuller content pass; they are not needed for route
safety.)

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains ancestor layer, active Reclamation focus, private
  posture, and deviation/curse price state without generic Daedric scoring or
  leaked counters/route IDs.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer --strict-manager
```

Expected log markers (one Azura read = focus 0, one Boethiah read = focus 1,
proving both the route and that focus distinguishes patrons):

```text
RouteDunmerReclamationFocus complete: 130 focus 0
RouteDunmerReclamationFocus complete: 130 focus 1
```

## Edge Build - Deviation Price

> Deferred: DA01/DA02 deviation-price lever pending exact approved quest-stage
> and sacrifice-outcome source metadata; tracked in the GAP ledger. Do not count
> generic crime, cruelty, twilight, magic, shrine visits, or Daedric contact as
> proof.

## Silence Battery - Wrong-Origin And Generic Source

Run both negative checks back-to-back in sequence; both prove the same property
(no native Dunmer movement from a non-owning source) and share setup.

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 4
player.additem 0001B245 1
```

Read the Azura book. Expected: no Dunmer manager state, reward, or Survey
movement (unique negative lever).

Generic-source silence:

```text
set PDV_GLO_OriginRace to 5
```

Try generic Daedric contact, theft, murder, ash proximity, shrine visits, or
tomb travel. Expected: no native Dunmer layer movement unless the exact source
owns the route (anti-false-positive lever).

## Evidence To Bring Back

```text
Dunmer expected build (route + focus 0/1): PASS/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Blocking notes:
```

## Trim log (2026-06-13)

Optimized for fewer steps with zero loss of safety coverage.

Cuts:
- Collapsed the 4 individual book-read steps (0001B245, 0001ACE9, 0001B233,
  00032E72) to 2 reads (one Azura + one Boethiah). All 4 prove the same
  RouteDunmerReclamationFocus handler; 2 reads prove route 130 plus focus 0/1.
  The other 2 books are documented as optional identity signals, not cut from
  the record.
- Replaced the PENDING "Edge Build - Deviation Price" stub (DA01/DA02 metadata
  blocked, no runnable step) with a single deferred GAP-ledger pointer.
- Dropped the "Reward/stack snapshot" manual evidence line (reward records are
  machine-verified, readback 1280/0; manual in-game stack snapshot re-proves a
  toolchain-owned record-existence fact).

Consolidations:
- Folded Preflight (OriginRace 5 / DebugLevel 2) into the Expected Build header.
- Merged Wrong-Origin and Generic-Source into one back-to-back "Silence battery"
  block (shared property, shared setup), keeping both distinct assertions.

Critical levers preserved (5): wrong-origin rejection, generic-source silence,
positive Reclamation-focus route proof (Azura + Boethiah -> focus 0/1),
Survey/status clarity, disposable-save preflight OriginRace=5/DebugLevel=2.

Before -> after step count: 13 -> 7.
