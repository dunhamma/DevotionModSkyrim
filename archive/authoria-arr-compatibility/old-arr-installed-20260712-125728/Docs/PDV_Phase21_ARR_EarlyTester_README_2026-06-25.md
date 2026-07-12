# Devotion - Authoria / ARR Trusted Tester Package

Date: 2026-06-25
Audience: trusted tester on Authoria - Requiem Reforged.

This handoff is for a private first look. It is not a public Authoria support claim
and not maintainer approval. Machine/readback checks pass; runtime smoke is the
tester task.

## Archives

- `PDV_FirstLook_20260625.zip` - current Devotion core, rebuilt from
  `D:\Wabbajack\modlists\Anvil\mods\Devotion`.
- `PDV_AuthoriaARR_Compatibility_20260625.zip` - Authoria/ARR add-on with the
  shrine-prayer ESP, BOS swap file, ARR quest matrix JSON, and docs.
- `PDV_AuthoriaARR_TrustedTester_20260625.zip` - outer handoff bundle containing
  both archives and this readme.

## Install Order

1. Install `PDV_FirstLook_20260625.zip` in MO2 as `Devotion`.
2. Install `PDV_AuthoriaARR_Compatibility_20260625.zip` in MO2 as
   `Devotion - Authoria ARR Compatibility`.
3. Enable both mods.
4. Disable the 15 Archon-family plugins listed below.
5. Put `Devotion.esp` before `Requiem for the Indifferent.esp`.
6. Put `PDV_AuthoriaARR_Compatibility.esp` after `Devotion.esp`.
7. Re-run the Reqtificator from MO2 after plugin placement.

## Disable These Archon Plugins

```text
Archon.esp
Archon - Vigilant.esp
Archon - BDS.esp
Archon - Mandra Shrines.esp
Archon - Wyrmstooth.esp
Archon - HOHQE.esp
Archon - TG Alt Endings.esp
Archon - TOCQE.esp
Archon - TWDQE.esp
Archon - Markarth Entrance and Farm Overhaul.esp
Archon - Lux Via.esp
Lux - Archon.esp
Lux - Archon - Mandra Shrines.esp
Authoria - Master Patch - Archon.esp
Authoria - Papyrus - Missing Properties - Archon Fix.esp
```

## What The Add-On Contains

- `PDV_AuthoriaARR_Compatibility.esp`: ESL-flagged shrine-prayer ACTI plugin
  for 11 Daedric statue prayers.
- `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`: Base Object Swapper STAT-to-ACTI
  swaps that make the decorative Daedric statues clickable.
- `PDV_QuestReactionMatrix_ARR.json`: ARR extension matrix with 24 cells, 22
  quest keys, 20 watched quests, and 24 faucet acts.

## Current Proof Boundary

Passed locally:

- `node .\tools\pdv_compile.mjs` found no stale active scripts.
- `node .\tools\pdv_refresh_seq.mjs --write --json` passed with 39 SEQ quests.
- `node .\tools\pdv_verify.mjs --json` passed with no FAILs.
- ARR matrix compile/check passed at 24 cells / 22 keys / 20 quests / 24 faucet acts.
- Shrine-prayer readback passed for all 11 ACTIs, route 202, once/day keys, and
  EventBus wiring.
- Shrine blessing neutralization check passed for the core shrine spell slice.

Still required from the tester:

- Confirm the `_ARR` matrix channel loads in Papyrus log.
- Confirm one ARR quest hook applies the expected piety.
- Confirm one Daedric shrine statue is clickable, grants +2 once per day, and
  does not double-award on the same day.
- Confirm MCM/status opens and the Papyrus log has no new PDV errors.
