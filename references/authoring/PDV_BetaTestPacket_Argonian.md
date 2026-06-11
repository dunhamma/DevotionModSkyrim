# PDV Beta Test Packet - Argonian

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

## Edge Build - Void Or Curse Pressure

Current live status: pending. Do not use generic murder, one Dark Brotherhood
join, swimming loops, or same-bed sleep loops as proof. Void/Sithis and
People/community need exact approved sources before full pass evidence.

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

## Evidence To Bring Back

```text
Argonian expected build: PASS/FAIL
Argonian Void/curse edge: PENDING/FAIL
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

### Reward redesign snapshot (replaces old disease set)

Expected Active Effects per tier (disease resistance is GONE everywhere):

- Hist Memory (always): Resist Magic 5%.
- Hist Attunement (substrate HIGH): Health Regen 9%, Resist Poison 12%,
  Unarmed Damage +12.
- Hist Communion - Devoted (Hist 50): Health Regen 8%, Stamina Regen 10%.
- Chosen People - Kin (People 25): Carry Weight +25.
- Chosen People - Family (People 50): Resist Poison 8%, Health Regen 5%.
- Chosen People - Pillar (Champion 85): Health Regen 8%, Carry Weight +25,
  Resist Magic 5%.

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
- Sleep in a bed: a "Bed of Choice" prompt appears (Yes / Not yet). Yes is
  sleep #1 (count 1). Declining re-prompts only after 3 in-game days.
- Sleep in the SAME cell again (count 2), then a 3rd time (count 3): you wake
  with `Rooted Rest` (Stamina Regen 5%, 10 min) and "You wake rooted." Watch
  `Argonian bed-of-choice return routed`.
- Sleeping in a DIFFERENT cell: no routing for the declared place; instead you
  get the prompt for the new place.
- Quick test: `coc RiverwoodSleepingGiantInn`, sleep x3 in the same bed.

### Shadowscale signature (Void focus only)

- Requires IsVoidFullyActive (3 Void signals) AND Void relation > People
  relation. While SNEAKING, kill any hostile: brief invisibility moment +
  "The shadow takes you back." Once per day.
- KNOWN APPROXIMATION: sneak state is polled when the kill event routes; a
  kill credited just after leaving sneak can miss the veil. Not a bug.
- Log marker: `Shadowscale veil fired on sneak kill`.

### Waters That Remember

Six curated waters; first arrival each = one vision MessageBox + small Hist
pulse; all six = milestone toast. One-shot forever (anti-farm by design).

```text
coc EldergleamSanctuaryStart   (walk in, or coc, to a cave cell - NOT the exterior)
```

Sites: Eldergleam Sanctuary, Sleeping Tree Camp, Ilinalta's Deep, Ancestor
Glade (Dawnguard), Bloated Man's Grotto, Darkwater Crossing. Log marker:
`Sacred water remembered: N of 6`. All six -> milestone (now a MessageBox,
not a missable toast).

NOTE: Eldergleam fires INSIDE the cave (where the water and great tree are),
not at the exterior approach. Entering the sanctuary location arms a bounded
poll; the vision fires when you reach an interior cell (Start/Start02/Top).
The other five sites are outdoor and fire on arrival at the location.

- Sleeping Tree Sap (`player.additem 000AED90 1`, then drink): one-shot vision.
  Log marker: `Sleeping Tree Sap vision fired`.

### Hist Adaptations (dreaming root rite)

- Gate: substrate composite >= 75 AND sleeping in the declared bed (or at a
  sacred water) AND 7+ days since last rite.
- Rite menu offers Claws (+5 unarmed) / Skin (+5 sneak) / Sap (+5% magicka
  regen) / Marsh (+8% stamina regen) / Not yet. One active at a time; choosing
  again swaps (clear-before-add). "Not yet" does NOT spend the cooldown.
- If composite later drops below 75: adaptation fades at dawn ("The root grows
  quiet."); it returns automatically at dawn once composite recovers.
- Console shortcut to reach the gate fast: read the four Hist books daily for
  ~2 weeks, or use the SetPQV harness to seed substrate keys.

### Evidence to bring back (addendum)

```text
Reward redesign snapshot: PASS/FAIL
Sleep reaction 1/dawn cap: PASS/FAIL
Kill-hostile Sithis silence: PASS/FAIL
Posture dream observed: PASS/PENDING
Bed declaration + Rooted Rest: PASS/FAIL
Shadowscale veil: PASS/PENDING/FAIL
Waters visited (count): N/6 + sap PASS/PENDING
Adaptation rite + swap + fade: PASS/PENDING/FAIL
Blocking notes:
```

## Debug seeder (substrate-gated phases)

Reach the composite-75 / Void-active states without weeks of play. Use the
SetPQV poll harness (NOT cqf -- cqf is unreliable). Set the three values, then
flip DebugSeedGo to 1; the 1s OnUpdate tick applies the seed and resets the flag.
Close the console and wait ~1-2s for the confirming MessageBox.

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
