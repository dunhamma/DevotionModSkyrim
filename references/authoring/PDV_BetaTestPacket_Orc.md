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

## Current-Build Refresh (2026-06-14)

Ready to run NOW for the life-mode no-flip gate; the Witnessed tranche records
exist (readback-clean) but manager runtime behavior + final-world emitters are
DEFERRED. Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.
- PDV `PDV_REFR_*Signal` objects are INVISIBLE in `coc qasmoke`. Fire by RefID:
  prefix XX once off `help "HoonDing" 0` (`SPEL:` FormID's first two hex digits),
  then `prid XX<refid>` + `activate player`.

Orc signal RefIDs (framework ESP): Stronghold `071027`, City `071028`, Legion
`071029`, SelfMade `07102A`.

### Life-mode no longer flips on one act (build-batch test 6) -- runnable now

1. `set PDV_GLO_OriginRace to 8`, `set PDV_GLO_DebugLevel to 2`, `coc qasmoke`.
2. Survey -> confirm life mode is **City** (default).
3. `prid XX071027` then `activate player` once (Stronghold forge signal). Log
   shows `Orc Stronghold forge routed` + evidence recorded, but Survey life mode
   **stays City**. **PASS = no flip on a single signal** (old build flipped
   instantly).
4. Optional full switch: sleep to a new in-game day (auto-dawn fires on the day
   rollover), then fire `prid XX071027` + `activate player` again -- the 2nd
   signal itself flips the mode to Stronghold (two evidence days in seven). No
   manual `Run dawn pass` needed. Verified in-game 2026-06-14.

### Code Holds survival beat (PENDING build-pass runtime)

`PDV_SPEL_OrcCodeHolds` / `_Devoted` are live/readback-clean (2026-06-14): on
surviving combat after dropping below 20% health, a flat survival restore fires
once per combat (Seeker +40 Health; Devoted/Champion +60 Health + 30 Stamina)
plus +0.5 Malacath piety. The heal is a scripted flat `RestoreActorValue` in
`TryOrcCodeHolds`, NOT the old HealRate regen pulse it once was (Requiem swallows
rate healing on a near-zero base); the two spell records are now gating-presence
flags only and are not cast. Detection is the shared below-20% combat-session
poll (`RoutePlayerBelowHealthSurvived` on combat exit). Runtime/manual proof
PENDING. Health-based, so the killing-blow caveat does not apply.

### Four Holds pilgrimage (route 75; QASmoke-readback only, organic DEFERRED)

First-arrival pulse at the 4 canonical strongholds (Dushnikh Yal, Mor Khazgur,
Largashbur, Narzulbur) + an all-four milestone. Records, route 75, and the four
QASmoke ACTI/REFR proof surfaces are readback-clean; the final-world
stronghold-ARRIVAL emitters are DEFERRED (and `coc` would skip a location event
anyway). For now this is provable only via the QASmoke proof surfaces ->
`HandleOrcFourHoldsVisit` (route 75 marker), not by walking into a stronghold.

### Witnessed tranche + oath-break (NOT testable in V1)

- Trial of Iron rite / The Watchers line / Hearth-Held: records live/readback-
  clean, but manager runtime behavior + cell restriction + arrival emitters are
  deferred. No runnable in-game step yet.
- Oath-break (route 74, `DELTA_OATH_BREAK = -1.5`): source/compile-clean but
  emitter-less -- no clean vanilla quest-abandonment hook is wired, so it is not
  testable in V1.

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey lists recent beats in fiction voice. KNOWN editorial gap: Orc
Survey still opens with dev language ("Malacath watches the code through City
life") and leaks the raw life-mode enum -- folded into the all-race Survey
rewrite, not a beta-feel blocker.
