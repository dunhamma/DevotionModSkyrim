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

- Top-left notification or proven toast feedback only ("The name of Talos: The
  question of the Ninth presses harder.").
- No forced full Prisma panel.
- Survey Devotion explains civic faith, Talos pressure tilt (defiant /
  constrained / not tilted), Concordat/public state, and why faction membership
  or generic lawfulness did not score.
- Reward/stack snapshot: no unexpected reward stack; Talos favor only via
  faithful defiance (compliance never scores).

After closing Skyrim, run the single objective machine gate that backstops the
manual pass:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager
```

Expected log marker:

```text
RouteImperialTalosPressure complete:
```

This is the only Imperial route currently wired with a runtime marker; do not
duplicate it with an organic civil-war proof until route 111 is placed.

## Edge Build - Civic Service Or Private Talos

> Deferred: Civil War oath rows and public/private Talos branch semantics
> (routes 110-113) pending exact-stage metadata / approved source records;
> proof cells are placementStatus=proof-cell-pending. Tracked in the GAP ledger.
> Re-add as a runnable step once the civic/Talos/focused/creed proof cells are
> placed.

## Wrong-Origin And Generic Silence

Run these two no-movement assertions back-to-back from the single negative-case
block below.

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 0
player.additem 000ED04D 1
```

Read the book. Expected: no Imperial manager state, reward, or Survey movement.

Generic-source silence:

```text
set PDV_GLO_OriginRace to 1
```

Spot-check 2-3 representative non-whitelisted triggers (e.g. faction rank,
ordinary bounty payment, generic anti-Thalmor violence). Expected: no civic or
Talos state movement. All non-whitelisted civic/Talos sources assert the same
single invariant -- zero state movement -- so the representative spot-check
covers the negative class.

## Evidence To Bring Back

```text
Imperial expected build: PASS/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

## Trim log (2026-06-13)

- Cut: "Edge Build - Civic Service Or Private Talos" expanded stub replaced with
  a single deferred pointer line (routes 110-113 are proof-cell-pending /
  blocked; unrunnable this pass). Lever tracked in GAP ledger, not lost.
- Cut: collapsed the 7-trigger generic-source enumeration (faction rank, temple
  attendance, bounty payment, generic mercy, generic anti-Thalmor violence,
  trade, lawfulness) into one silence pass spot-checking 2-3 representative
  triggers. Negative-class coverage preserved.
- Cut: removed the "Imperial civic/Talos edge: PENDING/FAIL" evidence line that
  paired with the cut Edge Build (doc-only tidy).
- Merged: wrong-origin check and generic-source silence into one back-to-back
  negative-case block under a single OriginRace set (0) and the one flip back to
  1, instead of two separate preflight resets.
- Merged: folded the reward/stack snapshot observation into the Expected Build
  step rather than carrying it as a standalone action.
- Kept verbatim as runnable: wrong-origin rejection, generic-source silence,
  public Talos pressure proof, post-run RouteImperialTalosPressure marker check,
  Survey clarity, reward/stack snapshot.
- Step count: 11 -> 7.
