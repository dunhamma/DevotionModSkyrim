# Devotion - Authoria / ARR Trusted Tester Package

Date: 2026-06-25
Audience: trusted tester on Authoria - Requiem Reforged.

This handoff is for a private first look. It is not a public Authoria support claim
and not maintainer approval. Machine/readback checks pass, one ARR quest backend
route has passed local runtime smoke, and local shrine-prayer smoke passed for
click/top-left feedback, Book of Days entry, and same-day no-double-award.
MCM/status and clean-log tester smoke are still required on the recipient setup.

## Archives

- `PDV_FirstLook_20260625.zip` - current Devotion core, rebuilt from
  `D:\Wabbajack\modlists\Anvil\mods\Devotion`.
- `PDV_AuthoriaARR_Compatibility_20260625.zip` - Authoria/ARR add-on with the
  shrine-prayer ESP, BOS swap file, ARR quest matrix JSON, and docs.
- `PDV_AuthoriaARR_TrustedTester_20260625.zip` - outer handoff bundle containing
  both archives, this readme, and the `BetaTesterPack` run-sheets.
- `BetaTesterPack\PDV_BetaTester_Pack_V1.md` - tester-facing index for the
  universal Prisma checklist, per-race run-sheets, and Daedric path sheet.

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
- `node .\tools\pdv_refresh_seq.mjs --check --json` passed with 39 SEQ quests
  and no pending change.
- `node .\tools\pdv_refresh_seq.mjs --write --json` refreshed the live
  `Devotion.seq` after the Hist Sap ESP write; quest count stayed 39.
- `node .\tools\pdv_verify.mjs --json` passed with 3471 PASS / 1 WARN / 0 FAIL
  and 1719 major records.
- `dotnet run --project .\tools\pdv-argonian-histpotion-author -- --check`
  passed: `PDV_MGEF_ArgonianHistSap` and `PDV_ALCH_ArgonianHistSap` are present.
- `node .\tools\pdv_integrity_harness.mjs` passed with 39 GREEN / 0 RED.
- `node .\tools\pdv_formal_offer_check.mjs` passed with PASS=189 / FAIL=0.
- `node .\tools\pdv_prisma_parity_unitd_check.mjs` passed with PASS=39 / FAIL=0.
- ARR matrix compile/check passed at 24 cells / 22 keys / 20 quests / 24 faucet acts.
- Shrine-prayer readback passed for all 11 ACTIs, route 202, once/day keys, and
  EventBus wiring.
- Shrine blessing neutralization check passed for the core shrine spell slice.
- ARR backend runtime route passed on the `PDV Test` profile: MCM matrix reload
  showed core 73 watched quests and ARR channel 20 watched, then
  `setstage zzzAoMMqGoodEnd 255` logged Stendarr +12 and
  `[PDV] QuestReaction: 5047158|255 applied 1 cells.` No front-end toast was
  observed or required for this backend quest-reaction check.
- Local shrine-prayer runtime smoke passed for the clickable shrine route, the
  top-left prayer line, the Book of Days Chronicle entry, and same-day
  no-double-award. The Prisma overlay toast did not appear and is deferred to
  the broader Prisma parity backlog.

Still required from the tester:

- Run `BetaTesterPack\PDV_BetaTester_Pack_V1.md` first, then the universal
  Prisma checklist and the relevant race/Daedric run-sheets.
- Reconfirm the `_ARR` matrix channel loads in the tester's Papyrus log.
- Reconfirm one ARR quest hook applies the expected piety in the tester's setup.
- Confirm one Daedric shrine statue is clickable, grants +2 once per day, and
  does not double-award on the same day.
- Confirm MCM/status opens and the Papyrus log has no new PDV errors.
