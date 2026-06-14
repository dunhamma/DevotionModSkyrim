# PDV Phase 21 — ARR Channel Deploy + Smoke Runbook

Turnkey steps to deploy and runtime-prove the ARR quest-reaction channel built on branch
`feature/arr-extension-and-compat-closeout`. Runtime gate only — all machine proof is already green
(`--matrix --check` PASS, 26 cells; both scripts compile 0/0; core `--check` unchanged).

## What's being proven
The generic second-channel loader (core matrix + `PDV_QuestReactionMatrix_ARR`) loads, registers the
ARR new-land quests, and applies the right per-deity piety when a hooked stage fires.

## Prereqs
- ARR instance `D:\Wabbajack\modlists\ARR`, profile **PDV Test** (Archon family disabled, Devotion
  active before Requiem). This is the profile the compat work used.
- PDV debug level **2** (MCM → Devotion dev page) so both traces emit.
- Papyrus logging on; log at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Deploy (two files into the ARR PDV test mod)
The ARR PDV test mod is `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test`
(confirm it is the Devotion the PDV Test profile loads).
1. **Recompiled scripts** — copy the freshly built `.pex` from the Anvil dev mod into the ARR test mod:
   - `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_PlayerEvents.pex`
   - `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV__ManagerQuest.pex`
   → `...\Devotion - PlayerDevotion Local Test\Scripts\`
2. **ARR matrix JSON** — compile straight into the test mod (run from the worktree):
   ```
   node tools/pdv_quest_matrix_compile.mjs --matrix references/authoring/PDV_QuestReactionMatrix_ARR.csv --output "D:/Wabbajack/modlists/ARR/mods/Devotion - PlayerDevotion Local Test/SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR.json"
   ```
   (Omit `--check` so it writes. Core `PDV_QuestReactionMatrix.json` must already be present — it is.)

## Smoke
1. **Channel loads** — load a save; in Papyrus.0.log expect BOTH:
   - `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix): <N core>`
   - `Quest reaction matrix hooks refreshed (PlayerDevotion/PDV_QuestReactionMatrix_ARR): ~20 quest entries`
   The second line is the proof the new channel registered. If it's missing → JSON not deployed or
   `.pex` not updated.
2. **A hook fires** — pick a high-confidence cell and drive its quest to the hooked stage (play it, or
   `setstage <runtimeFormID> <stage>` — runtime FormID = the plugin's load-index byte + the local id
   below; get the byte from `help` on a named record from that plugin, per the signal-prefix method).
   Expect in log: `[PDV] QuestReaction: <decimalForm>|<stage> applied <n> cells`, and the deity's piety
   move (MCM Survey / Export Devotion Report).
   - Easiest single check: **Olenveld** `OlenveldBOTE` (local `50FC4D`) stage **80** → +Arkay.
   - Or **Gray Cowl** `ccBGSSSE020_Quest` (local `00080F`) stage **100** → +Nocturnal.
3. **RUNTIME-VERIFY list** (no ShutDownStage flag — confirm each actually fires; if one does not,
   it's a one-line CSV stage fix + recompile, no script change):
   - Vigilant Aetherius `1363DB` s255 → Akatosh
   - Vigilant Archer of Kyne `1279A1` s255 → Kyne
   - Vigilant Knight of Julianos `1265FB` s999 → Julianos
   - Vigilant Knight of Zenithar `1306FA` s999 → Zenithar
   - Glenmoril Azura `355287` s10 → Azura
4. **Negative check** — a non-hooked quest stage applies nothing (no false `[PDV] QuestReaction` line).

## Report back
- Did the `_ARR` "hooks refreshed" line appear, and with how many entries?
- Which hooks fired correct piety; which RUNTIME-VERIFY stages did NOT fire (→ CSV stage adjust).
- Any Papyrus errors referencing the matrix/loader.

## Authored ARR cell reference
Full list + valences in `PDV_QuestReactionMatrix_ARR.csv` and the cell table in
`PDV_Phase21_ARR_ExtensionMap.md`. 26 cells / 22 keys / 20 quests across Vigilant, Glenmoril, Unslaad,
Olenveld, ForgottenCity, SEC Saints&Seducers, the QE expansion stages, and Gray Cowl.
