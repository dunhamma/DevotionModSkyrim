# PDV Beta Test Packet - Argonian

> **Superseded mechanics warning (2026-07-13):** This packet preserves older
> runtime evidence, but its composite metric, per-route magnitudes, and Hist
> Communion reward checks are no longer test authority. Current pacing and
> one-sitting steps live in `PDV_SubstratePacingContracts.json` and
> `PDV_1_0_CoTest_Runbook_2026-07-10.md`.

Created: 2026-06-06
Status: ready to run - Hist book packet; People/Void edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Argonian beta-feel proof from the approved Hist book source
family. It does not prove People/community, bed-of-choice, Void/Sithis, or curse
edge behavior by itself.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 7
set PDV_GLO_DebugLevel to 2
```

Origin index `7` is Argonian.

## Expected Build - Hist Memory

Add the approved Argonian Account books:

```text
player.additem 0001AFD7 1
player.additem 0001ACE7 1
player.additem 0001AFFC 1
player.additem 0001ACE8 1
```

Read each book normally from inventory:

- `0001AFD7` - `Book0ArgonianAccountBook1`.
- `0001ACE7` - `Book3ValuableArgonianAccountBook2`.
- `0001AFFC` - `Book0ArgonianAccountBook3`.
- `0001ACE8` - `Book3ValuableArgonianAccountBook4`.

Expected in game:

- Top-left notifications only, unless a separately proven toast surface is in
  focus.
- No forced full Prisma panel.
- Survey Devotion explains Hist memory, People floor, Void posture, and
  bed-of-choice state without route IDs or raw debug values.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race argonian --strict-manager
```

Expected log marker:

```text
RouteArgonianHistMaintenanceSource complete: po3_book_argonian_hist
```

> Deferred: Void/Sithis and People/community edge pressure pending exact
> approved source metadata; tracked in the GAP ledger. Live Void coverage is
> exercised by the Shadowscale step (Void-active seeder) and curse-posture
> texture by the posture-dream step below. The "do not accept this as proof"
> guard for these levers now lives in the Generic-source silence check.

## Edge Build - Void And People Guard

This packet does not approve a new Void/Sithis or People/community quest-stage
source. Use the generic-source silence procedure below as the edge guard:
generic murder, a single Dark Brotherhood join, swimming loops, and same-bed
sleep loops must not move Hist, People, Void, or bed-of-choice state. Shadowscale
and posture-dream steps later in this packet are seeded feature proofs, not
source-fill authority for new organic hooks.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 6
player.additem 0001AFD7 1
```

Expected: no Argonian manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 7
```

Try generic swimming, same-bed sleep, stealth, murder, alchemy, or swamp travel.
Expected: no Hist, People, Void, or bed-of-choice movement.

Void-invalid-proof guard (absorbed from the old Edge Build stub): generic murder,
a single Dark Brotherhood join, swimming loops, and same-bed sleep loops do NOT
count as Void/Sithis or People/community proof. Confirm none of them produce
Hist, People, Void, or bed-of-choice movement here.

## Evidence To Bring Back

```text
Argonian expected build: PASS/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```


## Variety Tranche Addendum (2026-06-11)

Status: records + scripts landed and machine-verified; ALL sections below need
a NEW SAVE or main-menu `coc qasmoke` (likes/dislikes version bump 5->6 and new
manager VMAD properties only take effect on fresh init). Disable the mod
`Devotion - Living Deities Test` in MO2 before running.

### Debug seeder setup (shared by adaptation rite, reward snapshot, Shadowscale)

Reach the composite-75 / Void-active states without weeks of play. Use the
SetPQV poll harness (NOT cqf -- cqf is unreliable). Set the three values, then
flip DebugSeedGo to 1; the 1s OnUpdate tick applies the seed and resets the flag.
Close the console and wait ~1-2s for the confirming MessageBox. This is shared
setup, not a separate proof; the steps below consume it.

Hist + People (reward tiers + adaptation rite; composite >= 75):

```text
setpqv PDV__ManagerQuest DebugSeedHist 90
setpqv PDV__ManagerQuest DebugSeedPeople 90
setpqv PDV__ManagerQuest DebugSeedVoid 0
setpqv PDV__ManagerQuest DebugSeedGo 1
```

Void fully active + Void focus (Shadowscale veil; Sithis emphasis rewards):

```text
setpqv PDV__ManagerQuest DebugSeedHist 50
setpqv PDV__ManagerQuest DebugSeedPeople 20
setpqv PDV__ManagerQuest DebugSeedVoid 80
setpqv PDV__ManagerQuest DebugSeedGo 1
```

Effects re-sync immediately; the adaptation rite fires on the next qualifying
sleep (declared bed or a sacred water). The DebugSeedArgonian function is still
cqf-callable if cqf works in your setup, but SetPQV is the supported path.

### Reward stack snapshot at seeded max

For the current contract, seed cultural practice to 75 and People to 85. Confirm
one highest-slot-only cultural boon plus one highest-slot-only relation emphasis:

- **Rooted Adaptation**: Magic Resistance +5%, Poison Resistance +22%, and
  Maximum Health +30 near water.
- **Chosen People - Pillar**: Carry Weight +50, Poison Resistance +8%, Health
  +20, and Magic Resistance +5%.
- No Hist Communion spell is present. Hist Communion records are retired
  compatibility artifacts and the active family cap is substrate plus either
  People or Void, never all three relation families.

### Reaction-layer fix checks

- Sleep in any bed twice in one day: Hist +0.25 / Sithis -0.25 fire ONCE only
  (cap now 1/dawn, was 3/day).
- Kill a hostile humanoid: NO Sithis movement at all (kill-hostile row removed;
  murder-defenseless rows unchanged).

### Hist dreams by posture

- Sleep on consecutive nights; expect occasional top-left dream lines (~8-12%
  per sleep, min 2 days apart). Force a posture change (e.g. let Hist decay to
  Distant) then sleep: dream chance jumps to 60% that night.
- Log marker: `Argonian posture dream fired`.

### Bed-of-choice declaration + Rooted Rest

- Identity is the CELL you sleep in (your room/home), NOT the bed furniture
  object -- GetFurnitureReference() is None at OnSleepStart, so the bed object
  can't be captured reliably; the parent cell at sleep-stop is reliable.
- **Settling intent (2026-06-18):** the "Bed of Choice" prompt only appears after
  you sleep in the SAME not-home cell **3 nights running** (any night elsewhere
  restarts the streak). This covers first home AND moving home, so a one-night inn
  stay never becomes your home. Decline quiets the prompt for 3 days.
- Sleep in the SAME cell on successive returns. The live gate is the bed-of-choice
  return count reaching 12 (`BedOfChoiceSleepCount >= 12`): on that return you wake
  with `Rooted Rest` (Stamina Regen 5%, 10 min) and "You wake feeling rooted."
  (Reaching 12 organically is slow -- use the debug seeder below.)
- **Moving home:** after 3 consecutive nights in a new place you are offered to make
  it home; accepting clears the old home's adaptation, resets the return count, and
  re-rolls the 10-14 day adaptation clock.
- Quick test (skip the 3-sleep settle): `coc RiverwoodSleepingGiantInn`, then declare
  the current cell as home directly, seed the return count to 11, and sleep once in
  that cell to fire Rooted Rest (the return makes it 12):
  ```text
  setpqv PDV__ManagerQuest DebugSeedDeclareHomeNow 1
  setpqv PDV__ManagerQuest DebugSeedBedCount 11
  setpqv PDV__ManagerQuest DebugSeedGo 1
  ```

### Shadowscale signature (Void focus only)

- Requires IsVoidFullyActive (3 Void signals) AND Void relation > People
  relation. While SNEAKING, kill any hostile: brief invisibility moment +
  "The shadow takes you back." Once per day.
- KNOWN APPROXIMATION: sneak state is polled when the kill event routes; a
  kill credited just after leaving sneak can miss the veil. Not a bug.
- Log marker: `Shadowscale veil fired on sneak kill`.

### Waters That Remember

Curated waters; first arrival each = one vision MessageBox + small Hist pulse;
all six = milestone toast. One-shot forever (anti-farm by design). Visit ONE
representative non-trivial site, then confirm the milestone via seeding rather
than walking all six.

Representative site -- Eldergleam (interior-only trigger):

```text
coc EldergleamSanctuaryStart   (walk in, or coc, to a cave cell - NOT the exterior)
```

NOTE: Eldergleam fires INSIDE the cave (where the water and great tree are),
not at the exterior approach. Entering the sanctuary location arms a bounded
poll; the vision fires when you reach an interior cell (Start/Start02/Top).
The other five sites (Sleeping Tree Camp, Ilinalta's Deep, Ancestor Glade
(Dawnguard), Bloated Man's Grotto, Darkwater Crossing) are outdoor and fire on
arrival; they share the same one-shot vision mechanism, so the one interior
visit proves it. Log marker: `Sacred water remembered: N of 6`.

Milestone confirmation (seed the count to size-1 instead of touring all six):
seed to 5, then make ONE unseen-water arrival (Eldergleam interior) so the live
visit increments to 6 and fires the milestone MessageBox alongside that site's
vision. Seed BEFORE the Eldergleam visit (a seed of 6 sets only the count and
will not fire the milestone, which only triggers on the crossing arrival).

```text
setpqv PDV__ManagerQuest DebugSeedArgWatersCount 5
setpqv PDV__ManagerQuest DebugSeedGo 1
```

Confirm the seen-key / milestone anti-farm assertion: the all-six milestone
fires as a MessageBox (not a missable toast) on the 6th arrival, and a repeat
arrival at the already-seen Eldergleam vision does NOT re-fire (one-shot forever).

- Sleeping Tree Sap (`player.additem 000AED90 1`, then drink): one-shot vision,
  one cultural-practice claim if that devotional day's +4 remains available,
  and one Hist relation/piety pulse. Log marker:
  `Sleeping Tree Sap vision fired`.

### Hist Adaptations (dreaming root rite) -- "grow into your home" model (2026-06-18)

- Gate: substrate composite >= 75 AND sleeping in your declared home (or at a
  sacred water) AND the randomized **10-14 day clock** rolled when you declared
  that home has elapsed. The rite no longer fires on the 2nd sleep.
- Rite menu offers Claws (+5 unarmed) / Skin (+5 sneak) / Sap (+5% magicka
  regen) / Marsh (+8% stamina regen) / Not yet. The choice is **permanent for
  that home -- no swap**. "Not yet" leaves the rite available next qualifying sleep.
- **Moving home:** sleeping somewhere that is not your current home offers "make
  this your place of rest?" Accepting clears the old home's adaptation, resets the
  Rooted Rest return count, and rolls a fresh 10-14 day clock so you re-adapt to
  the new home. A decline quiets the prompt for 3 days.
- If composite later drops below 75: adaptation fades at dawn ("The root grows
  quiet. The change fades from your scales."); it returns at dawn once composite
  recovers (the home/choice is remembered).
- Console shortcut: seed composite >= 75 (Hist + People seeder above), then stand
  in a bedroom cell and declare it home -- `DebugSeedDeclareHomeNow` declares the
  home, RESETS any already-taken adaptation (Adapt.Active persists even when
  faded, so the rite is otherwise one-per-home), AND matures the 10-14 day clock,
  so one flip leaves the home immediately and repeatably testable:
  ```text
  setpqv PDV__ManagerQuest DebugSeedDeclareHomeNow 1
  setpqv PDV__ManagerQuest DebugSeedGo 1
  ```
  then sleep in that cell to fire the rite. For an ORGANICALLY declared home (real
  3-sleep settle, not the shortcut), mature its clock separately with
  `setpqv ... DebugSeedAdaptDueNow 1` + `DebugSeedGo 1`, flipped ALONE. To test
  re-adapting, move home (3 consecutive sleeps in a new cell, accept), then mature
  the clock again and sleep.

### Evidence to bring back (addendum)

```text
Reward redesign snapshot: PASS/FAIL
Sleep reaction 1/dawn cap: PASS/FAIL
Kill-hostile Sithis silence: PASS/FAIL
Posture dream observed: PASS/PENDING
Bed declaration + Rooted Rest: PASS/FAIL
Shadowscale veil: PASS/PENDING/FAIL
Waters (Eldergleam vision + seeded milestone): PASS/PENDING
Adaptation rite + swap + fade: PASS/PENDING/FAIL
Blocking notes:
```

## Trim log (2026-06-13)

Trimmed for fewer steps with zero loss of safety coverage. Before -> after: 20
-> 13 steps.

Cuts:
- Removed the "Edge Build - Void Or Curse Pressure" PENDING prose stub (no
  runnable step). Replaced with a one-line deferred pointer under Expected Build
  and folded its only real content (the do-not-accept-as-proof guard: generic
  murder / single DB join / swim loops / same-bed loops) into the Generic-source
  silence check, so the Void-invalid-proof guard is preserved.
- Reduced "Waters That Remember" from a six-site cross-map walk to ONE
  representative interior visit (Eldergleam) plus a seeded milestone
  confirmation. The one-shot seen-key / all-six milestone anti-farm assertion is
  kept; the other five sites share the identical vision mechanism.
- De-duplicated reward verification: merged the main-packet "Reward/stack
  snapshot" and the addendum "Reward redesign snapshot" into one Active-Effects
  check taken at seeded max, reconciled to the spec magnitudes.

Merges / consolidations:
- Collapsed the two Debug-seeder configs (Hist+People; Void) into a single
  shared setup block consumed by the adaptation-rite, reward-snapshot, and
  Shadowscale steps instead of counting the seeder as standalone tests.
- Trimmed the duplicate "Reward/stack snapshot: PASS/PENDING/FAIL" line out of
  the main Evidence block (now covered once by the seeded reward snapshot) and
  dropped the "Void/curse edge: PENDING" line that paired with the removed stub.

Preserved verbatim as runnable checks (no safety lost): wrong-origin rejection,
generic-source silence (now also carrying the Void-invalid-proof guard), the
organic Hist-maintenance route + RouteArgonianHistMaintenanceSource marker,
sleep 1/dawn anti-farm cap, kill-hostile Sithis silence, bed-of-choice + Rooted
Rest, Shadowscale Void veil, Hist Adaptation rite, posture dream, the seeded
reward stack snapshot, and Survey/status clarity.

## Current-Build Refresh (2026-06-14)

Ready to run NOW for the near-water lever; the Sithis T3 burst + Corrupted
posture are source/readback-clean with runtime PENDING. Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.
- Argonian "Waters That Remember" anchors use Story location-change; `coc` does
  NOT fire them -- enter via load door / fast-travel (Eldergleam is the interior
  cell-poll exception). Already noted above; restated as the top false-FAIL.
- Bed-of-choice "Rooted Rest" gate is **12** returns (`BedOfChoiceSleepCount >=
  12`), NOT 3 -- seed the count up via the debug seeder for a quick check or it
  reads as a false FAIL.

### Near-water Hist maintenance (build-batch test 3) -- new, runnable now

Being in water maintains the Hist, once per in-game day (`IsSwimming` daily
poll).

1. `set PDV_GLO_OriginRace to 7`, `set PDV_GLO_DebugLevel to 2`.
2. Go to water and actually SWIM (deep enough to swim): `coc Riverwood` then walk
   to the river, or any lake/coast.
3. Remain continuously swimming for at least **10 real seconds**. The log then
   prints `Argonian near-water Hist maintenance routed`; cultural practice may
   claim that day's +4, Hist relation/piety moves once, and a "The water
   remembers you" toast may show.
4. Swim more the SAME day -> no second fire (day-capped; log stays quiet).
5. Sleep to advance a day, swim again -> it fires once more.
6. **PASS:** swimming credits Hist once/day, no per-second spam.

KNOWN COSMETIC QUIRK (not a fail): on a fresh Argonian the first maintenance can
show a one-time "growing thin" posture toast because the init posture is read
before the real relation settles. Folded into the editorial sweep.

### Sithis T3 near-death burst (PENDING build-pass runtime confirmation)

`PDV_Bless_Argonian_Sithis_T3` (always-on Fortify Stamina +40; 2026-07-13
Requiem conversion) plus `PDV_SPEL_ArgonianSithisNearDeathBurst` (below 20% health
-> now a scripted flat `RestoreActorValue("Stamina",100)` INSTANT restore, once/day;
the old +50 stamina-regen-for-10s buff still casts for flavor but is muted under
Requiem) are authored, wired, and readback-clean. The
below-20% detection uses the shared combat-session poll
(`RoutePlayerBelowHealthGate`). Runtime/manual proof of the once/day burst is
PENDING. This is health-based, not kill-based, so the killing-blow caveat does
not apply.

### DominationPressure -> Corrupted posture (PENDING build-pass runtime)

When Molag Bal path piety >= Seeker AND curse state == vampire, the manager
writes `PDV.Curse.Argonian.DominationPressure` and escalates the Hist posture to
**Corrupted (4)**; the neglect texture `PDV_MGEF_Neglect_ArgonianHist_Health`
(negative Fortify Health approx -10, felt under Requiem; converted 2026-07-13 from
the old HealRateMult -5) applies at Silenced or Corrupted. Molag Bal is
Argonian-accessible by record (`PDV_DaedricPath_Molag`). To exercise: origin 7,
MCM Daedric -> force the Molag Bal path to Seeker+, then Curse vampire -> Survey
Hist posture should read Corrupted. Source/readback-clean; runtime PENDING.

### Neglect vanilla top-left fallback + Survey recent-events

Neglect fallback line `<Deity>'s regard fades as your devotion goes quiet.` now
fires top-left. Survey Devotion lists the last few beats in fiction voice --
confirm the near-water maintenance shows there. The Argonian Normal-posture
opener and the Prisma posture labels are flagged for the editorial sweep (not
beta-feel blockers).
