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

## Current-Build Refresh (2026-06-14) -- READBACK CLEAN, RUNTIME PENDING

The ancestor-layer curse silence (build-batch test 2), twilight-window outdoor
emitter, and Layer-2 werewolf scaling are now source/compile/readback clean.
Runtime/manual proof is still pending. Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.
- The outdoor Good-Daedra shrine emitter fires from `PDV_MGEF_DunmerShrineCure`,
  the PDV CureDisease magic effect attached to the three DLC2 altar spells, NOT a
  cell/location change -- so `player.cast` on the altar spell or activating the
  real shrine works fine. It is DLC2 Solstheim altars only (the Good Daedra have
  no other vanilla blessing shrine).

### Ancestor-layer curse silence (build-batch test 2) -- runnable now

Vampire silences the ash-prayer (Layer 1 = 0x) -- the signature consequence.

1. `set PDV_GLO_OriginRace to 5`, `set PDV_GLO_DebugLevel to 2`.
2. Click `Dunmer ancestor prayer` 2-3x -> Survey "Ancestor practice is ..."
   rises a tier; note it.
3. `Curse vampire` -> Survey curse posture reads
   `silent, the ancestors cannot reach you`.
4. Click `Dunmer ancestor prayer` again -> NOTHING happens: practice does NOT
   rise, and the log shows `Dunmer ancestor layer silenced by curse posture`.
   **This is the key check.**
5. `Curse werewolf` -> posture `strained, the beast pulls at the ancestors`;
   the prayer now credits at half (log still shows it routed).
6. `Curse none` -> posture `restored, but scarred`; prayer credits fully again.
7. **PASS:** prayer is silent under vampire (0x) + correct 4 posture labels.

### Dawn/dusk twilight window (Azura) -- portable + outdoor readback clean (runtime pending)

Two 3-hour windows (06:00-09:00 dawn, 18:00-21:00 dusk), +0.25 piety each,
once-per-window daily cap (`SIGNAL_DUNMER_TWILIGHT_RITE = 704`).

- Portable-shrine prayer in-window is source/verifier-clean (runtime PENDING):
  use `set timescale` + wait to land inside a window, then trigger the portable
  ash-prayer; watch for the twilight signal. Confirm a second prayer in the same
  window is silent (once-per-window cap).
- OUTDOOR Good-Daedra shrine -- DLC2 Solstheim Azura/Boethiah/Mephala altars ONLY
  (the Good Daedra have no other vanilla blessing shrine). Built 2026-06-14,
  readback-clean, runtime PENDING. The altar spells `03BCFB`/`03BCFC`/`03BCFD`
  now use `PDV_MGEF_DunmerShrineCure` (`071554:Devotion.esp`),
  whose `PDV_DunmerShrinePrayerEffect` routes the signal on effect start.
  To test:
  - `set PDV_GLO_OriginRace to 5`, `set PDV_GLO_DebugLevel to 2`, `set gamehour to 7`.
  - Console shortcut (no Solstheim trip): the Azura altar spell is `03BCFB` in
    Dragonborn.esm; prefix it with Dragonborn's load index (`04` in this Anvil
    order -- loadorder.txt line 6) -> `player.cast 0403BCFB player`. Boethiah =
    `player.cast 0403BCFC player`, Mephala = `player.cast 0403BCFD player`.
    NOTE: `help` by EditorID does NOT work -- this list strips EditorIDs and the
    altar spell has no Name. If the load order changes, re-derive the prefix via
    `help "Bend Will" 0` (a NAMED Dragonborn shout) and read its 2-hex prefix.
  - Real-shrine path: travel or `coc` to the Solstheim altar location, activate
    the Azura/Boethiah/Mephala shrine, and read the Papyrus log for the same
    Dunmer twilight route marker.
  - Expect: `RouteDunmerOutdoorGoodDaedraShrine complete: dlc2_good_daedra_shrine`
    + `Dunmer Dawn twilight rite routed`. A second add in the same window/day logs
    `already recorded today`; outside the window (`set gamehour to 12`) -> no line.
  - Real-shrine alt: on Solstheim, activate any Reclamation altar inside the window.

### Layer-2 werewolf scaling (PENDING build-pass runtime)

`GetDunmerCurseLayerWeight(2)` returns 0.75x for Good Daedra
(Azura/Boethiah/Mephala) piety under werewolf curse (parallels the Layer-1 0.5x
ancestor scaling). Source/compile-clean; runtime/manual proof PENDING. To probe
once live: `Curse werewolf`, then trigger a Good-Daedra focus signal and confirm
the gain is 0.75x of the un-cursed value.

### NOT testable in V1

Grey Quarter solidarity (the curated Windhelm Dunmer NPC whitelist) has no
hardcoded list wired yet -- no runnable step. The deviation-price edge
(DA01/DA02) remains deferred per the Edge Build section above.

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey lists recent beats in fiction voice -- Dunmer Survey already
passed the 2026-06-14 spot check ("The Reclamations have answered a source you
sought out.").
