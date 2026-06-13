# PDV Beta Test Packet - Breton

Created: 2026-06-06
Status: ready to run - Hidden Art book packet; Knight's Road and Green Way pending
Mode: console-assisted beta-feel packet

This packet starts Breton beta-feel proof from the approved Hidden Art book
source family. It does not prove Knight's Road, Green Way, vow integrity,
DruidicStanding, or curse/Daedric rupture by itself.

## Preflight

Use a disposable save. Origin index `2` is Breton.

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

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

Prove the route once at the machine layer, surfaced once in game. Expected in
game (organic-read clarity check, not a second route gate):

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel.
- Survey Devotion explains active Breton tradition, Hidden Art exposure, vow or
  cover pressure, and why parallel tradition rewards are not all active.

After closing Skyrim, the primary route proof is the machine marker check:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager
```

Expected log markers:

```text
RouteBretonTraditionChoice complete: 120 tradition 1
RouteBretonHiddenArtExposure complete:
```

## Edge Build - Daedric Or Curse Rupture

> Deferred: Knight's Road, Green Way, vow integrity, and curse/Daedric rupture
> pending exact approved source metadata; tracked in the GAP ledger
> (BC-0567 Druidic Trial, BC-0568/0569 vampire, BC-0653 curse onset). The
> exclusion list of what does NOT count as rupture proof now lives in the
> Generic-source silence check below.

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

Try generic spellcasting, generic artifact ownership/carrying, College
membership / faction joining, ordinary help, and shrine attendance. Expected:
no tradition state movement. None of these count as Hidden Art or rupture proof
(major-act-only; no generic inference).

## Evidence To Bring Back

```text
Breton expected build (route markers + Survey clarity): PASS/FAIL
Breton rupture edge: DEFERRED (see GAP ledger)
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Blocking notes:
```

## Trim log (2026-06-13)

- CUT "Edge Build - Daedric Or Curse Rupture": was a pending placeholder with no
  runnable step or PASS criterion. Replaced with a one-line deferred pointer to
  the GAP ledger. Its exclusion list folded into Generic-source silence.
- CUT "Expected Build - dual route proof": no longer run the in-game Survey read
  and the machine marker check as two independent route-pass gates. The machine
  marker (RouteBretonTraditionChoice / RouteBretonHiddenArtExposure) is the
  primary route proof; the in-game read is one Survey/status clarity check.
- MERGE: Edge-Build exclusion list ("these do NOT count") folded into the single
  Generic-source silence block so it lives in exactly one place.
- MERGE: Hidden Art route collapsed into one proof step (organic read + one
  post-close machine marker check).
- TRIM: Preflight prose -- the two `set` lines plus the "origin index 2 = Breton"
  note are the whole step; redundant restatement removed.
- Evidence line "Reward/stack snapshot" dropped from the manual checklist
  (record enablement is machine-proven; not a manual-only lever).
- Step count: 6 -> 4.
