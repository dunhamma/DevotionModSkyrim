# PDV Phase 21 -- ARR Channel Deploy + Smoke Runbook

Turnkey steps to deploy and runtime-prove the ARR devotion extension (quest-reaction channel + the
Daedric shrine-prayer feature) built on branch `feature/arr-extension-and-compat-closeout`. Runtime gate
only -- machine proof is green (`--matrix --check` PASS, 24 ARR cells / 22 keys / 20 quests /
24 faucet acts + 6 core; all scripts compile 0/0; core `--check` unchanged; 11 shrine-prayer
Activators readback-verified).

## What's being proven
The generic second-channel loader (core matrix + `PDV_QuestReactionMatrix_ARR`) loads, registers the
ARR new-land quests, and applies the right per-deity piety when a hooked stage fires. Separately, Base
Object Swapper turns the man_DaedricShrines statues into clickable PDV prayer activators that grant +2
to the Prince once per day.

## Prereqs
- ARR instance `D:\Wabbajack\modlists\ARR`, profile **PDV Test** (Archon family disabled, Devotion
  active before Requiem). This is the profile the compat work used.
- PDV debug level **2** (MCM -> Devotion dev page) so both traces emit.
- Papyrus logging on; log at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Deploy (into the ARR PDV test mod)
The ARR PDV test mod is `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test`
(confirm it is the Devotion the PDV Test profile loads).
1. **Recompiled scripts** -- copy these freshly built `.pex` (all under
   `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\`) into `...\Devotion - PlayerDevotion Local Test\Scripts\`.
   All four changed -- two for the matrix loader, two for the shrine-prayer route:
   - `PDV_PlayerEvents.pex`, `PDV__ManagerQuest.pex` (second-channel matrix loader)
   - `PDV_EventSignalActivator.pex`, `PDV_EventBus.pex` (shrine-prayer route 202)
2. **ARR matrix JSON** -- compile straight into the test mod (run from the worktree):
   ```
   node tools/pdv_quest_matrix_compile.mjs --matrix references/authoring/PDV_QuestReactionMatrix_ARR.csv --output "D:/Wabbajack/modlists/ARR/mods/Devotion - PlayerDevotion Local Test/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR.json"
   ```
   (Omit `--check` so it writes. Core `PDV_QuestReactionMatrix.json` must already be present -- it is.)
3. **Shrine-prayer compat ESP + BOS swap** -- copy both from `dist/PDV_AuthoriaARR_Compatibility/`:
   - `PDV_AuthoriaARR_Compatibility.esp` -> the test mod root, and ENABLE it in the PDV Test plugins
     (load after `Devotion.esp`; it masters `Skyrim.esm` + `Devotion.esp`).
   - `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini` -> the mod's `Data` root (Base Object Swapper auto-loads
     any `*_SWAP.ini`).

## Smoke
1. **Channel loads** -- load a save; in Papyrus.0.log expect BOTH:
   - `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix): <N core>`
   - `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix_ARR): ~19 quest entries`
   The second line is the proof the new channel registered. If it's missing -> JSON not deployed or
   `.pex` not updated.
2. **A hook fires** -- pick a high-confidence cell and drive its quest to the hooked stage (play it, or
   `setstage <runtimeFormID> <stage>` -- runtime FormID = the plugin's load-index byte + the local id
   below; get the byte from `help` on a named record from that plugin, per the signal-prefix method).
   Expect in log: `[PDV] QuestReaction: <decimalForm>|<stage> applied <n> cells`, and the deity's piety
   move (MCM Survey / Export Devotion Report).
   - Easiest single check: **Olenveld** `OlenveldBOTE` (local `50FC4D`) stage **80** -> +Arkay.
   - Or **Gray Cowl** `ccBGSSSE020_Quest` (local `00080F`) stage **100** -> +Nocturnal.
3. **RUNTIME-VERIFY list** (no ShutDownStage flag -- confirm each actually fires; if one does not,
   it's a one-line CSV stage fix + recompile, no script change):
   - Vigilant Aetherius `1363DB` s255 -> Akatosh
   - Vigilant Archer of Kyne `1279A1` s255 -> Kyne
   - Vigilant Knight of Julianos `1265FB` s999 -> Julianos
   - Vigilant Knight of Zenithar `1306FA` s999 -> Zenithar
   - Glenmoril Azura `355287` s10 -> Azura
4. **Negative check** -- a non-hooked quest stage applies nothing (no false `[PDV] QuestReaction` line).
5. **Shrine prayer (BOS + once/day +2)** -- travel (load-door/fast-travel, NOT `coc`) to a man_ Daedric
   shrine -- e.g. the Molag Bal or Mehrunes Dagon shrine. Confirm the statue now shows an activate prompt
   ("Pray"); if it doesn't, the `_SWAP.ini` didn't load (check it's in the Data root + BOS is active).
   Activate it -> expect `[PDV] Daedric shrine prayer: +2 <Prince>` in the log and that Prince's piety
   +2 (MCM Survey). Activate again the same day -> NO second award (once/day gate). Wait a day -> +2 again.
   The 11 covered Princes: Azura, Vaermina, Molag Bal, Mephala, Mehrunes Dagon, Sheogorath,
   Namira, Sanguine, Hermaeus Mora, Hircine, and Peryite. (Mehrunes Dagon rides the vanilla
   `ShrineMehrunes01` base -- confirm only the intended shrine swapped, no unwanted bleed.)

2026-06-25 ARR `PDV Test` result: shrine click produced the top-left prayer
line and Book of Days Chronicle entry. The Prisma overlay toast did not appear;
this is deferred to the Prisma parity backlog and is not a blocker for the ARR
shrine-prayer route/backend smoke slice.

## Report back
- Did the `_ARR` "hooks refreshed" line appear, and with how many entries?
- Which hooks fired correct piety; which RUNTIME-VERIFY stages did NOT fire (-> CSV stage adjust).
- Any Papyrus errors referencing the matrix/loader.

## Authored reference
- **ARR matrix channel:** 24 cells / 22 keys / 20 quests / 24 faucet acts across Vigilant,
  Glenmoril, Unslaad, Olenveld, ForgottenCity, SEC Saints&Seducers, DAc0da, and the Ebony
  Blade curse -- full list/valences in `PDV_QuestReactionMatrix_ARR.csv`
  + the cell table in `PDV_Phase21_ARR_ExtensionMap.md`.
- **Core matrix (promoted):** Gray Cowl + the QE stages (6 cells, Tranche6_CompatCore).
- **Shrine prayer:** 11 Activators + BOS swaps -- `PDV_Phase21_ARR_ShrinePrayer.manifest.json`.
