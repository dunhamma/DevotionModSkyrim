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

## Current-Build Refresh (2026-06-14)

The vampire-rupture halt (build-batch test 1) is runnable now. The Concordat
graduated 8-action point table was wired and its two clean-hook emitters
(Stormcloak-side -20, Thalmor-Justiciar-kill -10) **route-proven by the build pass
(2026-06-14)**; the PENDING marks are cleared below. Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.

### Vampire-rupture halt (build-batch test 1) -- runnable now

The Nine Divines path stops growing while undead; a one-way scar remains after
cure.

1. `set PDV_GLO_OriginRace to 1`, `set PDV_GLO_DebugLevel to 2`.
2. State labels: `Curse vampire` -> Survey `civic faith halted`; `Curse none` ->
   `civic faith scarred` (one-way scar; does NOT return to blank);
   `Curse werewolf` -> `civic faith strained` (werewolf does not halt).
3. Accrual halt (deeper): with a Divine selected, `Apply target piety` ~30,
   `Run dawn pass`, `Show piety map` (note value). Then `Curse vampire`, earn
   civic piety (`player.additem 000ED04D 1`, read it), `Run dawn pass`,
   `Show piety map` -> that deity does NOT grow while halted. `Curse none`, earn
   again, `Run dawn pass` -> growth resumes.
4. **PASS:** label flips halted -> scarred on cure; no piety growth while halted.

CAVEAT (imperial-vampire-halt-v2-strictness): the halt voids gain at DAWN
consolidation, not earn-time -- so earn-while-vampire-then-cure-BEFORE-dawn still
grows (correct; moot in normal play because auto-dawn fires while still undead).
Test the accrual halt ONLY while still vampire.

### Concordat graduated 8-action point table (ROUTE-PROVEN 2026-06-14)

`PDV_ConcordatStandingTrack` (-100..+100, 5 states) carries the exact 8-action
point map (`ApplyImperialConcordatAction` / `GetImperialConcordatPressureForAction`).
NOTE: the committed band LABEL lags the raw value via the track's lock-in -- prove
via the raw value in the trace, not the Survey band. Two emitters are route-proven:

```text
Side with the Stormcloaks   -20  CW01B Stormcloak join routes the Concordat defiance
                                 mod event, now table-sourced to -20 (was flat -15).
                                 QUICK TEST: MCM Debug -> "Concordat defiance" button
                                 -> [trace: Concordat pressure -20 ... adjustment -20].
                                 (Compliance / CW01A Legion join stays +15, unchanged.)
Kill a Thalmor Justiciar     -10  PLAYER'S OWN killing blow on a ThalmorFaction member
                                 (00039F26) who is NOT a pre-set enemy (rank > -2);
                                 open kills count [trace: Concordat pressure -10].
Find/activate hidden Talos shrine -15  existing route (key "hidden_talos_shrine").
```

NOT on the Concordat track: reading "The Talos Mistake" book does NOT emit a Concordat
point -- it routes the separate Talos-PIETY axis (`RouteImperialTalosPressure`), not
ConcordatStanding. Do not test it as a Concordat action.

KILL-CREDIT CAVEAT: the Justiciar kill scores ONLY the player's own killing blow
(ATTR_DIRECT_PLAYER). Ally/environment kills are silent by design -- land the
final hit yourself or it false-FAILs.

Secondary modifiers (readback-clean, runtime PENDING): at Concordat >+50 (Public
Compliant + Enforcer) Arkay -15% and Stendarr -15% daily shift; at <-50 (Private
+ Open Defiant) Stendarr +15%. Wired as `[1.0,1.0,1.0,0.85,0.85]` (Arkay) and
`[1.15,1.15,1.0,0.85,0.85]` (Stendarr).

NOT testable in V1 (no clean vanilla hook -- do not write these as steps):
help / refuse / report-Talos-worshipper, attack-Talos-worshipper.

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey lists recent beats in fiction voice.
