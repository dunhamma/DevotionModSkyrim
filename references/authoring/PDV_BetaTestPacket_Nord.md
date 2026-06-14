# PDV Beta Test Packet - Nord

Created: 2026-06-06
Status: ready to run - Old Ways and Hircine/Arkay book packet; dense-hook edge audit pending
Mode: console-assisted beta-feel packet

This packet starts Nord beta-feel proof from the approved Old Ways and
Hircine/Arkay book source families. It does not prove Kyne/Talos context,
werewolf stack behavior, dense generic hook rejection, or broad/focused reward
cap by itself.

## Preflight

Use a disposable save. Run both set lines as one setup block:

```text
set PDV_GLO_OriginRace to 0
set PDV_GLO_DebugLevel to 2
```

Origin index `0` is Nord.

## Expected Build - Old Ways

Add one approved Nord Old Ways book for the primary route proof:

```text
player.additem 000ED161 1
```

Read it normally from inventory:

- `000ED161` - `Book1CheapNordsArise`.

All three approved Old Ways books (`000ED161` NordsArise, `000ED02F`
DreamOfSovngarde, `000E2FC6` SovngardeReexamination) route through the same
`eventbus_150_po3_book_nord_old_ways` -> `HandleNordOldWaysState` ->
`RouteNordOldWaysState` marker, so one representative read proves the route.
The other two remain valid one-time identity signals for a fuller content pass
but are not needed for route safety here.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains broad/focused Old Ways, Kyne/Talos context, and
  current patron state without turning every Nord hook into a reward faucet.
  (This single broad-state Survey clarity check covers the broad-vs-focused
  reward-cap lever; the full focused-patron and pantheon-baseline survey
  variants are runtime-proven in `PDV_Phase18_StatusNord_Runbook.md` and are
  not re-walked here.)

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

Expected log marker (the unique curse/hunt-edge lever, route 72; not provable by
the Old Ways book):

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

## Trim log (2026-06-13)

- CUT: Old Ways "read all three books" reduced to ONE representative read
  (`000ED161` NordsArise). All three books hit the same
  `RouteNordOldWaysState` route, so reading three proved the same route three
  times. Other two books retained as documented optional identity signals.
- CONSOLIDATED: the two preflight `set` lines presented as a single setup block
  (cosmetic; no coverage lost).
- CONSOLIDATED: Survey clarity kept as one broad-state check; focused-patron and
  pantheon-baseline survey variants deferred to
  `PDV_Phase18_StatusNord_Runbook.md` (already runtime-proven there) instead of
  re-walking the full Phase 18 survey matrix.
- PRESERVED verbatim as runnable steps: wrong-origin rejection, generic-source
  silence (anti-farm), Old Ways book route + machine route marker, Hircine/Arkay
  edge route marker, and the broad-vs-focused reward-cap Survey clarity check.
- Step count: 11 -> 7.

## Current-Build Refresh (2026-06-14)

Ready to run NOW. Adds the consolidated build's Nord-relevant surfaces. Items
above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.

### Non-Kyne commitment offers (build-batch test 8) -- the headline new lever

Any pantheon-baseline god (or Talos) can now be offered for commitment, not just
Kyne (`IsNordOfferEligibleDeity`).

1. `set PDV_GLO_OriginRace to 0`, `set PDV_GLO_DebugLevel to 2`.
2. MCM Debug page -> `Selected deity` -> a NON-Kyne baseline god:
   - Old Ways: Shor / Tsun / Stuhn / Talos.
   - Nine Divines: Mara / Arkay / Akatosh / Stendarr / Zenithar / Dibella /
     Julianos / Kynareth.
3. `Apply target piety` -> **55** (above the 50 offer threshold).
4. Click `Seed commitment signals` (seeds the 2-day window for the selected
   deity), then `Run dawn pass`.
5. **PASS:** a commitment offer fires for that non-Kyne god (previously
   impossible -- only Kyne could offer).

KNOWN COPY GAP (not a fail): the offer prompt + MCM labels are still
Kyne-worded ("Evaluate the Kyne commitment offer now?"). Per-god offer/accept
copy and degenericized labels are a deferred editorial item; the offer FIRING
for a non-Kyne god is the pass criterion.

### Neglect vanilla top-left fallback (build-batch test 9)

A neglected committed patron now prints `<Deity>'s regard fades as your devotion
goes quiet.` top-left even with the Prisma overlay off. Prove it: commit a
patron (e.g. Kyne or Talos), drop it to ~5 Target piety, Run dawn pass until it
crosses neglect.

### Survey "recent events" log

Survey Devotion now lists the last few devotion beats in fiction voice. After
the Old Ways book read or the commitment offer, confirm the beat appears with no
route IDs or raw counters. Nord Survey copy already passed the 2026-06-14 spot
check ("the Old Ways", not "old road").

### Still pending (not in this build)

Dense generic-hook rejection audit and the Hircine/werewolf vs Kyne/Talos stack
cap audit remain open. The Hircine/Arkay edge book route is the only curse-edge
lever provable here; werewolf-stack behavior is not yet testable.
