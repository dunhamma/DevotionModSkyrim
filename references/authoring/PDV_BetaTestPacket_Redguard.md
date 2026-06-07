# PDV Beta Test Packet - Redguard

Created: 2026-06-06
Status: ready to run - ancestor-spine book packet; sect/death-duty edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Redguard beta-feel proof from the approved ancestor-spine
book source. It does not prove Crown/Forebear branch behavior, Ash'abah death
duty, Far Shores token, or HoonDing cap by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 9
set PDV_GLO_DebugLevel to 2
```

Origin index `9` is Redguard.

## Expected Build - Ancestor Spine

Add the approved Redguard book:

```text
player.additem 0001ACD1 1
```

Read the book normally from inventory:

- `0001ACD1` - `Book2CommonManualMixedUnitTactics`.

Expected in game:

- Top-left notification only, unless a separately proven toast surface is in
  focus.
- No forced full Prisma panel.
- Survey Devotion explains sect posture, ancestor-spine pressure, death-duty
  state, and Far Shores/HoonDing cap state without debug labels.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race redguard --strict-manager
```

Expected log marker:

```text
RouteRedguardAncestorSpine complete: po3_book_redguard_spine
```

## Edge Build - Ash'abah Or HoonDing Pressure

Current live status: pending. MS08, Ash'abah, Forebear/Crown branch, Far Shores,
HoonDing, undead, and vampire-cure sources need exact approved source metadata
before full pass evidence.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 8
player.additem 0001ACD1 1
```

Expected: no Redguard manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 9
```

Try generic combat, undead clearing, fast travel, tomb proximity, random sword
use, faction membership, or Arkay shrine use. Expected: no Redguard state
movement.

## Evidence To Bring Back

```text
Redguard expected build: PASS/FAIL
Redguard sect/death-duty edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

