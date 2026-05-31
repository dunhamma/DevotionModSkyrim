# PDV Phase 20 Pre-Beta Manual Checks Runbook

**Created:** 2026-05-31
**Status:** Manual handoff packet after automated Phase 20 pre-beta gate work
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceScalingSpine.md`, and `PDV_Phase20_QASmokeRuntimeProof_Runbook.md`

## Purpose

This runbook starts where the automated implementation work stops. The source,
content, manifest, route-list, and placement-readback gates can prove that the
pre-beta packets are wired and readable. They do not prove player feel.

Use this packet for the manual checks that remain before any race can move from
`Fail - internal scaling only` to `Conditional` or `Pass` in
`PDV_PreBetaRaceGateLedger.md`.

## Before Manual Checks

Run these from `C:\Users\Admin\Documents\Devotion Mod Project`:

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
```

If source changed, compile first:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
```

## Universal Manual Checks

For each race under test:

```text
Wrong-origin rejection:
  Activate or trigger the race proof surface from a different origin.
  Expected: no scoring, no state movement, no misleading Survey text.

Generic-hook rejection:
  Try ordinary travel, sleep, combat, theft, crafting, faction membership,
  shrine use, or quest proximity where that race explicitly rejects it.
  Expected: no generic faucet, no broad hidden counter movement.

Survey/status clarity:
  Cast Survey Devotion or open the MCM Player page after a real accepted hook.
  Expected: the text explains what changed in race language, not route IDs or
  debug counters.

Stack snapshot:
  Record active boons, favors, prices, privileges, substrate, scars, curse
  state, Daedric modifiers, and any race-specific track.

Final placement:
  Confirm whether the proof still lives only in QASmoke or has a planned
  final-world placement. Do not count QASmoke as final placement.
```

## Race Checks

### Altmer

Expected build: Auri-El or Magnus scholar.
Edge build: Exiled vampire, werewolf halt, or mortal-world pressure run.

Check:
- Ordinary travel, friendships, generic spellcasting, College membership, and
  generic anti-Thalmor violence stay silent.
- Lorkhan pressure fires only from authored crisis/pressure routes.
- Survey explains crisis state, pressure, last favor, and curse posture.
- Exiled vampire and werewolf states surface as capped or halted, not stronger
  alternate builds.
- Final placement needs one dawn/study surface and one crisis/pressure surface
  outside QASmoke.

### Khajiit

Expected build: lunar road mage.
Edge build: Rajhin or Baan Dar play without theft spam.

Check:
- No required visual moon inspection.
- Moon-sugar, fast travel, generic theft, generic dragon kills, one-bed camping,
  and ordinary night stealth stay silent.
- Same road-home anchor repeat does not become a loop.
- Survey explains Lunar Lattice, moon practice, road-home cadence, and focus.
- CAT-6 source row exists, but `PDV_Bless_Khajiit_Lunar_T1` is not present as a
  live framework ESP EditorID as of the 2026-05-31 readback check. Treat CAT-6
  as target-record-needed work before manual feel proof, not as a manual
  player-check step.

### Argonian

Expected build: Hist/People community keeper.
Edge build: Void-aware assassin without replacing the floor.

Check:
- Swimming loops, same-bed sleep loops, generic murder, generic stealth, and one
  Dark Brotherhood join do not activate full Sithis depth.
- Hist/People maintenance can be felt before Void depth.
- Survey names Hist, People, Void, bed-of-choice, and Sithis posture without raw
  debug values.
- Final placement needs one Hist/People surface and one community/death-rite
  surface outside QASmoke.

### Orc

Expected build: stronghold smith or code-bound warrior.
Edge build: city dignity or Legion/exile service.

Check:
- Raw crafting, raw combat, raw mining, generic stronghold membership, and
  generic Legion membership stay silent.
- Quality/context filters matter for forge and service hooks.
- Survey names life mode, standing, and curse/code pressure.
- Stack snapshot confirms Malacath/code surfaces do not become a generic
  warrior buff stack.

### Redguard

Expected build: Crown or Forebear route.
Edge build: Ash'abah death-duty route.

Check:
- Generic combat, generic undead kills, fast travel, ordinary shrine visits, and
  Arkay substitution stay silent.
- Far Shores token and HoonDing pressure are capped.
- Survey names sect, standing, Far Shores weight, and curse-cycle pressure
  without numeric debug output.
- Final placement needs one sect surface and one death-duty/Far Shores surface
  outside QASmoke.

### Bosmer

Expected build: Living Story or Exchange non-hunter.
Edge build: Bandit Road reversal.

Check:
- Generic kindness, bard activity, forest travel, trade profit, theft, and
  random vengeance stay silent.
- Bandit Road reversal keeps its cooldown and does not become a theft faucet.
- Survey names path, standing, Pact binding/lapse, and recent favor memory.
- Final placement needs one non-hunter surface outside QASmoke before Green Pact
  item-tag expansion.

### Breton

Expected build: one chosen tradition.
Edge build: Hidden Art plus Daedric rupture or curse pressure.

Check:
- Casual tradition switching, generic spellcasting, generic artifact ownership,
  generic help, College membership, private curiosity, and generic shrine visits
  stay silent.
- Survey names tradition, vow, Hidden Art exposure, DruidicStanding, and curse
  posture.
- Stack snapshot records tradition, KnightlyVowIntegrity, WitchcraftExposure,
  DruidicStanding, patron focus, curse fork, and Daedric modifiers.

### Dunmer

Expected build: ash-prayer and ancestor practice into one Reclamation focus.
Edge build: ancestor substrate plus Daedric deviation or curse price.

Check:
- Generic crime, cruelty, twilight, magic, Tribunal memory, and non-Reclamation
  deviation stay silent unless a curated row owns the signal.
- Survey names ancestor layer, portable ash-prayer, private home rite, standing,
  and curse posture.
- Stack snapshot records ancestor substrate, Reclamation focus, active favor,
  deviation price, curse state, and Daedric modifiers.

### Imperial

Expected build: civic Nine Divines broad worship.
Edge build: public/private Talos pressure under ConcordatStanding.

Check:
- Faction membership, generic temple attendance, bounty payment alone, generic
  anti-Thalmor violence, and cruelty-as-order stay silent.
- Survey names civic faith, ConcordatStanding, Talos pressure tilt, repair gate,
  standing, and curse posture.
- Stack snapshot records ConcordatStanding, public/private Talos state, primary
  patron, civic favor, repair/rupture, curse state, and Daedric modifiers.

### Nord

Expected build: broad Old Ways into Kyne or Talos.
Edge build: Hircine/werewolf stack.

Check:
- Generic kill, generic travel, generic tomb clear, generic anti-Thalmor
  violence, and broad worship inheriting every patron boon stay silent.
- Survey remains the control/reference for clear race feel.
- Stack snapshot proves Kyne, Talos, Hircine, broad favors, vampire/scar, and
  Daedric modifiers do not overstack.

## Recording Results

After each race, update `PDV_PreBetaRaceGateLedger.md`:

```text
Verdict:
Evidence date:
Manual feel note:
Wrong-origin result:
Generic-hook result:
Survey/status result:
Stack snapshot:
Final placement result:
Blocking follow-up:
```

Only use `Pass` when the evidence proves the whole race-level gate. Use
`Conditional` when the race is coherent enough for scoped internal playfeel but
has named gaps. Keep `Fail` when the player would still be judging missing
systems.
