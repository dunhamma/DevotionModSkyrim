# Codex Handoff -- Strip 4 orphaned Redguard VMAD props (2026-07-05)

## Task
Remove four dead `ScriptObjectProperty` entries from the `PDV__ManagerQuest`
quest VMAD in `Devotion.esp`. They were dropped from the compiled
`PDV__ManagerQuest.pex` (superseded by the `*_Sect_*_Entry` notices), so the
engine logs "cannot find property" warnings at every load. No gameplay effect --
pure log-spam cleanup.

## Confirmed target (houseCARL, 2026-07-05)
- Record: QUST `00C325:Devotion.esp`, EditorID `PDV__ManagerQuest`.
- Script entry: `PDV__ManagerQuest` on `VMAD\Scripts`.
- Orphans at `Properties` indices 84-87 (of 419):
  - `PDV_Notif_Redguard_AncestorLayer_NeglectTexture`
  - `PDV_Notif_Redguard_Crown_NeglectTexture`
  - `PDV_Notif_Redguard_Forebear_NeglectTexture`
  - `PDV_Notif_Redguard_AshAbah_NeglectTexture`
- Live siblings that MUST remain (do not touch): `PDV_Notif_Redguard_Sect_Crown_Entry`
  / `..._Sect_Forebear_Entry` / `..._Sect_AshAbah_Entry` (165-167),
  `PDV_Notif_Redguard_FarShoresToken_Activate` (174),
  `PDV_Notif_Redguard_AncestorSpine_Rest` (315).

## Why not a headless tool
This must be an IN-PLACE edit to `Devotion.esp` (it is our own plugin; shipping an
override to patch our own orphans is wrong). houseCARL and `pdv_author.mjs` both
write override plugins only -- `pdv_author` explicitly "does not edit VMAD array
properties." So the fix is xEdit or a CK resave, not a data-layer override.

## Preferred method -- xEdit script (written, ready)
A safe, idempotent script is committed and deployed:
- Repo copy: `references/authoring/PDV_StripOrphanRedguardVMAD.pas`
- Deployed:  `<Anvil>/tools/xEdit/Edit Scripts/PDV_StripOrphanRedguardVMAD.pas`

It aborts with no changes unless the live sibling `PDV_Notif_Redguard_Sect_Crown_Entry`
is present (guards against wrong-record / already-cleaned edits), removes only the
four named orphans, and is a no-op on a clean plugin.

Run:
1. In MO2 (Anvil, Devotion Dev profile), launch `SSEEdit`. IMPORTANT: launch it
   THROUGH MO2 so the VFS presents the modlist load order -- a bare SSEEdit.exe
   run will not see `Devotion.esp`.
2. At the module-select prompt, load `Devotion.esp` (xEdit pulls its masters).
3. Right-click any record -> `Apply Script...` -> `PDV_StripOrphanRedguardVMAD`
   -> OK. The Messages tab should log `removed 4 orphan property/properties`.
4. Close SSEEdit -> when prompted, tick `Devotion.esp` -> Save. SSEEdit writes
   `Devotion.esp.backup` automatically.

Headless alternative (only via MO2's VFS, e.g. an MO2 tool entry or
`ModOrganizer.exe "moshortcut://:SSEEdit"` with args):
`-autoexit -script:"PDV_StripOrphanRedguardVMAD.pas"` -- but confirm it saved
(headless save is version-dependent); verify before trusting it.

## Fallback -- manual xEdit
Same launch (steps 1-2), then: `Devotion.esp` -> Quest -> `PDV__ManagerQuest
[00C325]` -> VMAD -> Scripts -> `PDV__ManagerQuest` -> Properties -> right-click
each of the four `*_NeglectTexture` entries -> Remove -> save on exit.

## Fallback -- CK resave
Open `Devotion.esp` in the Creation Kit, load the `PDV__ManagerQuest` quest,
resave; the CK rebuilds the VMAD property list from the current `.pex` and drops
orphans. Downside: CK may introduce unrelated churn/ITMs -- diff in xEdit after.

## Verify (any method)
- houseCARL: read `00C325:Devotion.esp`
  `VirtualMachineAdapter.Scripts[0].Properties` -> count 419 -> 415, and the four
  `*_NeglectTexture` names absent.
- Or load a save and confirm `Papyrus.0.log` no longer logs the NeglectTexture
  "cannot find property" lines (12 such lines were present in the 2026-07-05 log).

## Caution
- Do NOT run LOOT and do NOT let any tool re-sort the load order (curated list).
- houseCARL can hold a Mutagen lock on `Devotion.esp`; if SSEEdit reports the file
  is in use, ensure no houseCARL write/overlay is active, then retry.
