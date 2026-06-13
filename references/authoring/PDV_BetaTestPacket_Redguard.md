# PDV Beta Test Packet - Redguard

Created: 2026-06-06
Status: ready to run - ancestor-spine book packet; sect/death-duty edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Redguard beta-feel proof from the approved ancestor-spine
book source. It does not prove Crown/Forebear branch behavior, Ash'abah death
duty, Far Shores token, or HoonDing cap by itself.

Gated behavior note (2026-06-13): the Redguard sect no longer flips on the first
signal. Crown<->Forebear now needs two sect-coded evidence days within seven plus
a 3-day lock-in; Ash'abah is entered only by a marked burden reason
(redguard_ashabah_burden / redguard_deathduty_major), not casual undead; and the
HoonDing make-way signal is weekly-capped. Score sect/HoonDing expectations
against this gated behavior, not first-signal flips.

Use a disposable save for every block below. Origin index `9` is Redguard.

## Expected Build - Ancestor Spine

Set the origin gate, then add and read the approved Redguard book:

```text
set PDV_GLO_OriginRace to 9
set PDV_GLO_DebugLevel to 2
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

> Deferred: Ash'abah / HoonDing / Crown-Forebear / Far Shores reward and cap
> levers pending exact approved source metadata (MS08, undead, vampire-cure);
> tracked in the GAP ledger. No runnable step this pass.

## Silence Checks

Run these two no-movement assertions back to back on the same save; both share
the same Survey/no-reward observation.

Wrong-origin check (origin 8 = not Redguard):

```text
set PDV_GLO_OriginRace to 8
player.additem 0001ACD1 1
```

Read the book. Expected: no Redguard manager state, reward, or Survey movement.

Generic-source silence (reset to origin 9 once; this is the only origin-9 reset
needed here):

```text
set PDV_GLO_OriginRace to 9
```

Try generic combat, undead clearing, fast travel, tomb proximity, random sword
use, faction membership, or Arkay shrine use. Expected: no Redguard state
movement (this also confirms the Arkay-not-Tu'whacca substitution guard).

Observe once and report both assertions: origin 8 = wrong-origin rejection;
origin 9 + generic acts = generic-source silence.

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

## Trim log (2026-06-13)

- CUT: "Edge Build - Ash'abah Or HoonDing Pressure" was entirely PENDING with no
  runnable step; replaced with a single deferred GAP-ledger pointer line so the
  Ash'abah/HoonDing/Crown-Forebear/Far Shores levers are not forgotten.
- MERGE: folded the standalone "Preflight" section's set-commands into each test
  block; dropped the duplicate origin-9 set (kept one explicit reset in the
  Silence Checks block after the origin-8 wrong-origin run).
- MERGE: combined "Wrong-Origin And Generic Silence" into one "Silence Checks"
  block with both distinct assertions (origin 8 = wrong origin; origin 9 +
  generic acts = generic silence) sharing one observe-and-report step.
- ADD: gated sect/HoonDing behavior note (two evidence days within seven +
  3-day lock-in for Crown<->Forebear; Ash'abah only by marked burden reason;
  HoonDing weekly-capped).
- Step count: 6 -> 4.
