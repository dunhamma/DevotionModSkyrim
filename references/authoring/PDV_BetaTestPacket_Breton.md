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

## Current-Build Refresh (2026-06-14)

Ready to run NOW for the WitchcraftExposure decay; the creed-loss persistent
spells are readback/compile-proven with in-game Active Effects PENDING. Items
above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.

### WitchcraftExposure decay (build-batch test 4) -- new, runnable now

Exposure is no longer a one-way ratchet -- it fades 1 per dawn.

1. `set PDV_GLO_OriginRace to 2`, `set PDV_GLO_DebugLevel to 2`.
2. Read a Hidden Art book to raise exposure: `player.additem 000ED60B 1`, read
   it (Hagravens) -> Survey `Hidden Art: <band>` rises (exposure +25).
3. Click `Run dawn pass` several times. Each dawn the log prints
   `Breton WitchcraftExposure passive decay -> N` and the Survey band steps back
   down (e.g. known -> suspected -> hidden).
4. **PASS:** exposure decreases across dawns (it was stuck climbing before).

### Creed-loss persistent spells (PENDING build-pass runtime)

Manager-side persistent application is now live (readback/compile-proven,
in-game Active Effects PENDING):

- `PDV_SPEL_CreedLoss_Breton_VowIntegrity` (Block -5% + Restoration -5%) -- held
  while KnightlyVowIntegrity is STRAINED (<70).
- `PDV_SPEL_CreedLoss_Breton_Excommunication` (HealRateMult -8%) -- held at
  BROKEN (<30).
- `PDV_SPEL_CreedLoss_Breton_ExposureRupture` (Conjuration -8% + Illusion -8%)
  -- held at WitchcraftExposure >= 100.
- `PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal` (StaminaRateMult -8% +
  Restoration -8%).

These are persistent-while-in-band (cleared on restoration above the band), and
a threshold-crossing HUD notice fires when each first becomes active. To reach a
band: drive exposure to >=100 via repeated Hidden Art reads + low decay, or use
the MCM debug page if a band setter is exposed.

DEFERRED (NOT testable in V1): the Knight's Road breach hooks that drive
Integrity DOWN organically -- Thieves Guild / Dark Brotherhood faction-add and
innocent-kill decrements -- have no live vanilla emitter yet, so Integrity can
only be moved through debug, not played down. Green Way DruidicStanding
degradation and tradition-differentiated vampire are likewise deferred.

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey Devotion lists recent beats in fiction voice -- confirm the
Hidden Art read appears there with no route IDs or raw counters.
